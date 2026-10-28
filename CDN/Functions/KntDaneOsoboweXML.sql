CREATE FUNCTION cdn.KntDaneOsoboweXML(@kntID INT, @optimaVer VARCHAR(20))
RETURNS NVARCHAR(MAX)
--RETURNS XML
AS
BEGIN
 DECLARE @retVal NVARCHAR(MAX)
 DECLARE @xml XML
 SELECT @xml = (SELECT
   (SELECT
    RTRIM(A.Knt_Nazwa1 + ' ' + A.Knt_Nazwa2 + ' ' + A.Knt_Nazwa3) AS [Name],
    CASE WHEN IsNull(A.Knt_NIP, '') = '' THEN NULL ELSE A.Knt_NIP END AS [TIN],
    CASE WHEN IsNull(A.Knt_Regon, '') = '' THEN NULL ELSE A.Knt_Regon END AS [EIN],
    CASE WHEN IsNull(A.Knt_Pesel, '') = '' THEN NULL ELSE A.Knt_Pesel END AS [NIN]
    FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID
   FOR XML PATH('BasicData'), TYPE),
   (SELECT
    CASE WHEN IsNull(AddressType, '') = '' THEN NULL ELSE AddressType END AS [AddressType],
    CASE WHEN IsNull(Street, '') = '' THEN NULL ELSE Street END AS [Street],
    CASE WHEN IsNull(StreetNo, '') = '' THEN NULL ELSE StreetNo END AS [StreetNo],
    CASE WHEN IsNull(UnitNumber, '') = '' THEN NULL ELSE UnitNumber END AS [UnitNumber],
    CASE WHEN IsNull(ZIPCode, '') = '' THEN NULL ELSE ZIPCode END AS [ZIPCode],
    CASE WHEN IsNull(Post, '') = '' THEN NULL ELSE Post END AS [Post],
    CASE WHEN IsNull(City, '') = '' THEN NULL ELSE City END AS [City],
    CASE WHEN IsNull(aState, '') = '' THEN NULL ELSE aState END AS [State],
    CASE WHEN IsNull(Country, '') = '' THEN NULL ELSE Country END AS [Country],
    CASE WHEN IsNull(County, '') = '' THEN NULL ELSE County END AS [County]
    FROM
    (
     SELECT AddressType = 'GeneralAddress', Street = A.Knt_Ulica, StreetNo = A.Knt_NrDomu, UnitNumber = A.Knt_NrLokalu,
      ZIPCode = A.Knt_KodPocztowy, Post = A.Knt_Poczta, City = A.Knt_Miasto,
      aState = A.Knt_Wojewodztwo, Country = A.Knt_Kraj, County = A.Knt_Powiat
      FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND (IsNull(A.Knt_Ulica, '') <> '' OR IsNull(A.Knt_NrDomu, '') <> '' OR IsNull(A.Knt_NrLokalu, '') <> '' OR
      IsNull(A.Knt_KodPocztowy, '') <> '' OR IsNull(A.Knt_Poczta, '') <> '' OR IsNull(A.Knt_Miasto, '') <> '' OR
      IsNull(A.Knt_Wojewodztwo, '') <> '' OR IsNull(A.Knt_Kraj, '') <> '' OR IsNull(A.Knt_Powiat, '') <> '')
     UNION ALL
     SELECT AddressType = 'CorrespondenceAddress', Street = A.Knt_KorUlica, StreetNo = A.Knt_KorNrDomu, UnitNumber = A.Knt_KorNrLokalu,
     ZIPCode = A.Knt_KorKodPocztowy, Post = A.Knt_KorPoczta, City = A.Knt_KorMiasto,
      aState = NULL, Country = A.Knt_KorKraj, County = NULL
     FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND (IsNull(A.Knt_KorUlica, '') <> '' OR IsNull(A.Knt_KorNrDomu, '') <> '' OR IsNull(A.Knt_KorNrLokalu, '') <> '' OR
     IsNull(A.Knt_KorKodPocztowy, '') <> '' OR IsNull(A.Knt_KorPoczta, '') <> ''OR IsNull(A.Knt_KorMiasto, '') <> '' OR
     IsNull(A.Knt_KorKraj, '') <> '')
    )
    AS Addresses FOR XML PATH('Address'), TYPE) AS [Addresses],
   (SELECT
    CASE WHEN IsNull(t, '') = '' THEN NULL ELSE t END AS [@Type], CASE WHEN IsNull(v, '') = '' THEN NULL ELSE v END AS [@Value]
    FROM
    (
    SELECT t = 'Phone', v = A.Knt_Telefon1 FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND IsNull(A.Knt_Telefon1, '') <> ''
    UNION ALL
    SELECT t = 'Phone', v = A.Knt_Telefon2 FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND IsNull(A.Knt_Telefon2, '') <> ''
    UNION ALL
    SELECT t = 'Phone', v = A.Knt_TelefonSMS FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND IsNull(A.Knt_TelefonSMS, '') <> ''
    UNION ALL
     SELECT t = 'FAX', v = A.Knt_FAX FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND IsNull(A.Knt_FAX, '') <> ''
    UNION ALL
     SELECT t = 'E-mail', v = A.Knt_Email FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND IsNull(A.Knt_Email, '') <> ''
    UNION ALL
     SELECT t = 'URL', v = A.Knt_URL FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND IsNull(A.Knt_URL, '') <> ''
    )
    AS ContactDetails FOR XML PATH('ContactData'), TYPE) AS [ContactDetails],
   (SELECT
    CASE WHEN IsNull(RTRIM(BNa_Nazwa1 + ' ' + BNa_Nazwa2), '') = '' THEN NULL ELSE BNa_Nazwa1 + ' ' + BNa_Nazwa2 END AS [@Bank],
    CASE WHEN IsNull(SPL_RachunekNr, '') = '' THEN NULL ELSE SPL_RachunekNr END AS [@AccountNumber]
    FROM cdn.SchematPlatnosci JOIN cdn.BnkNazwy ON BNa_BNaId = SPL_BnaId WHERE SPL_PodmiotTyp = 1 AND SPL_PodmiotID = @kntID
    FOR XML PATH('BankAccount'), TYPE) AS [BankDetails],
   (SELECT
    CASE WHEN IsNull(n, '') = '' THEN NULL ELSE n END AS [@Type], CASE WHEN IsNull(v, '') = '' THEN NULL ELSE v END AS [@Value]
    FROM
    (SELECT n = 'GLN', v = A.Knt_GLN FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND IsNull(A.Knt_GLN, '') <> ''
    UNION ALL
     SELECT n = 'ComarchCloud', v = A.Knt_LoginComarchCloud FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @kntID AND IsNull(A.Knt_LoginComarchCloud, '') <> ''
    )
    AS OtherInformations FOR XML PATH('Data'), TYPE) AS [OtherInformations]
  FROM cdn.Kontrahenci WHERE Knt_KntID = @KntID FOR XML PATH('PersonalData')
 )
 SELECT @retVal = '<?xml version="1.0" ?> ' + CONVERT(NVARCHAR(MAX), @xml)
 SELECT @retVal = REPLACE(@retVal,
 '<PersonalData>',
 '<PersonalData xmlns="http://tempuri.org/XMLSchema.xsd" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" CurrentDate="' + CONVERT(VARCHAR(40), GETDATE(), 126) + '" Version="Comarch ERP Optima ' + @optimaVer + '" OwnerType="Customer">')
 --RETURN @xml
 RETURN @retVal
END
