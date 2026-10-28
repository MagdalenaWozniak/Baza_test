CREATE FUNCTION cdn.KnODaneOsoboweXML(@knOID INT, @optimaVer VARCHAR(20))
RETURNS NVARCHAR(MAX)
--RETURNS XML
AS
BEGIN
 DECLARE @retVal NVARCHAR(MAX)
 DECLARE @xml XML
 SELECT @xml = (SELECT
    (SELECT
   RTRIM(A.KnO_Nazwisko) AS [Name]
   FROM cdn.KntOsoby A WHERE A.KnO_KnOID = @knOID
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
   CASE WHEN IsNull(Country, '') = '' THEN NULL ELSE Country END AS [Country]
   FROM
   (
    SELECT AddressType = 'GeneralAddress', Street = A.KnO_Ulica, StreetNo = A.KnO_NrDomu, UnitNumber = A.KnO_NrLokalu,
    ZIPCode = A.KnO_KodPocztowy, Post = A.KnO_Poczta, City = A.KnO_Miasto,
    aState = A.KnO_Wojewodztwo, Country = A.KnO_Kraj
     FROM cdn.KntOsoby A WHERE A.KnO_KnOID = @knOID AND (IsNull(A.KnO_Ulica, '') <> '' OR IsNull(A.KnO_NrDomu, '') <> '' OR IsNull(A.KnO_NrLokalu, '') <> '' OR
    IsNull(A.KnO_KodPocztowy, '') <> '' OR IsNull(A.KnO_Poczta, '') <> '' OR IsNull(A.KnO_Miasto, '') <> '' OR
    IsNull(A.KnO_Wojewodztwo, '') <> '' OR IsNull(A.KnO_Kraj, '') <> '')
   )
   AS Addresses FOR XML PATH('Address'), TYPE) AS [Addresses],
    (SELECT
   CASE WHEN IsNull(t, '') = '' THEN NULL ELSE t END AS [@Type], CASE WHEN IsNull(v, '') = '' THEN NULL ELSE v END AS [@Value]
   FROM
   (
   SELECT t = 'Phone', v = A.KnO_Telefon FROM cdn.KntOsoby A WHERE A.KnO_KnOID = @knOID AND IsNull(A.KnO_Telefon, '') <> ''
   UNION ALL
   SELECT t = 'Phone', v = A.KnO_GSM FROM cdn.KntOsoby A WHERE A.KnO_KnOID = @knOID AND IsNull(A.KnO_GSM, '') <> ''
   UNION ALL
   SELECT t = 'Phone', v = A.KnO_TelefonSMS FROM cdn.KntOsoby A WHERE A.KnO_KnOID = @knOID AND IsNull(A.KnO_TelefonSMS, '') <> ''
   UNION ALL
    SELECT t = 'E-mail', v = A.KnO_Email FROM cdn.KntOsoby A WHERE A.KnO_KnOID = @knOID AND IsNull(A.KnO_Email, '') <> ''
   )
   AS ContactDetails FOR XML PATH('ContactData'), TYPE) AS [ContactDetails]
  FROM cdn.KntOsoby WHERE KnO_KnOID = @KnOID FOR XML PATH('PersonalData')
 )
 SELECT @retVal = '<?xml version="1.0" ?> ' + CONVERT(NVARCHAR(MAX), @xml)
 SELECT @retVal = REPLACE(@retVal,
 '<PersonalData>',
 '<PersonalData xmlns="http://tempuri.org/XMLSchema.xsd" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" CurrentDate="' + CONVERT(VARCHAR(40), GETDATE(), 126) + '" Version="Comarch ERP Optima ' + @optimaVer + '" OwnerType="Representative">')
 --RETURN @xml
 RETURN @retVal
END
