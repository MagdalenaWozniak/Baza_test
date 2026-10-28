CREATE PROCEDURE [CDN].[IGaleria_DaneFirmy]
@ID int
AS
 SET NOCOUNT ON
 DECLARE
   @CustomerID    INT
  ,@Name          nvarchar(50)
  ,@Description   nvarchar(254)
  ,@Street        nvarchar(50)
  ,@HouseNo       nvarchar(20)
  ,@FlatNo        nvarchar(20)
  ,@PostalCode    nvarchar(20)
  ,@City          nvarchar(50)
  ,@Country       nvarchar(2)
  ,@Province      nvarchar(50)
  ,@Phone         nvarchar(254)
  ,@StartYear     nvarchar(50)
  ,@Email         nvarchar(192)
  ,@URL           nvarchar(192)
  ,@GG            nvarchar(254)
  ,@Skype         nvarchar(254)
  ,@PhoneGSM      nvarchar(254)
  ,@FBUrl         nvarchar(254)
  ,@Payments      INT
  ,@Idsklep    INT
  ,@Logo          INT
 set @Payments = 0;
  select  top 1  @Idsklep = ESS_ESSId,
  @CustomerID = ESS_IdKlienta,
  @Name= ESS_DaneFirmyNazwa,
  @Description = ESS_DaneFirmyOpis,
  @Street = ESS_DaneFirmyUlica,
  @HouseNo = ESS_DaneFirmyNrDomu,
  @FlatNo = ESS_DaneFirmyNrMieszkania,
  @City = ESS_DaneFirmyMiasto,
  @PostalCode = ESS_DaneFirmyKodPocztowy,
  @Province = ESS_DaneFirmyWojewodztwo,
  @Phone  = ESS_DaneFirmyTelefon,
  @Email = ESS_DaneFirmyEmail,
  @URL = ESS_DaneFirmyURL,
  @GG = ESS_DaneFirmyGG,
  @Skype = ESS_DaneFirmySkype,
  @PhoneGSM = ESS_DaneFirmyGSM,
  @FBUrl = ESS_DaneFirmyFacebook,
  @StartYear = ESS_DaneFirmyRok,
  @Logo = ESS_DaneFirmyLogo
   from cdn.eSklepStanowiska where ESS_typ = 2
 if exists (select ESF_IGFPlId from cdn.esklepFormyPlatnosci where ESF_ESSId = @Idsklep and isnull(ESF_FPlId,0) > 0)
  select @Payments = sum(ESF_IGFPlId) from cdn.esklepFormyPlatnosci where ESF_ESSId = @Idsklep and  isnull(ESF_FPlId,0) > 0
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1911) SELECT @CustomerID = 0 ELSE SELECT @CustomerID = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1911
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1913) SELECT @Name = '' ELSE SELECT @Name = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1913
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1914) SELECT @Description = '' ELSE SELECT @Description = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1914
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1915) SELECT @Street  = '' ELSE SELECT @Street  = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1915
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1916) SELECT @HouseNo = '' ELSE SELECT @HouseNo = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1916
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1917) SELECT @FlatNo = 0 ELSE SELECT @FlatNo = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1917
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1918) SELECT @City = '' ELSE SELECT @City = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1918
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1919) SELECT @PostalCode = '' ELSE SELECT @PostalCode = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1919
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1920) SELECT @Province = '' ELSE SELECT @Province = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1920
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1921) SELECT @Phone  = '' ELSE SELECT @Phone  = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1921
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1922) SELECT @Email = '' ELSE SELECT @Email = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1922
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1923) SELECT @URL = '' ELSE SELECT @URL  = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1923
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1924) SELECT @GG = '' ELSE SELECT @GG = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1924
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1925) SELECT @Skype = '' ELSE SELECT @Skype  = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1925
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1936) SELECT @PhoneGSM = '' ELSE SELECT @PhoneGSM = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1936
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1937) SELECT @FBUrl = '' ELSE SELECT @FBUrl  = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1937
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1927) SELECT @StartYear = '' ELSE SELECT @StartYear = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1927
SET NOCOUNT OFF
SELECT '<Shops>'
  SELECT  TOP 1
   @CustomerID    AS CustomerID
  ,1     AS ShopID
  ,@Name          AS Name
  ,@Description   AS Description
  ,@Street        AS Street
  ,@HouseNo       AS HouseNo
  ,@FlatNo        AS FlatNo
  ,@PostalCode    AS PostalCode
  ,@City          AS City
  ,'PL'           AS Country
  ,@Province      AS Province
  , case when dab_wartosc is null then '' else  dab_wartosc end   AS Logo
  ,@Phone         AS Phone
  ,@StartYear     AS StartYear
  ,@Email         AS Email
  ,@URL           AS URL
  ,@GG            AS GG
  ,@Skype         AS Skype
  ,@PhoneGSM      AS PhoneGSM
  ,@FBUrl         AS FBUrl
  ,@Payments      AS Payments
  ,1073741823     AS Delivery
  ,1              AS Source
FROM CDN.firma  AS Shop
left join cdn.danebinarne on dab_dabid = @Logo
--where fir_numer = 1926
FOR XML AUTO/*, root ('Shops')*/,BINARY BASE64
SELECT '</Shops>'
