CREATE PROCEDURE cdn.AktualnaPieczatka2CdnFirmaDaneVATAKCWW(@AktualizujTylkoNipRegon TINYINT)
AS
BEGIN
 -- CfgDaneFirmyVAT7View.cs
 IF NOT EXISTS (SELECT * FROM cdn.Pieczatki WHERE PC_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120))
  RETURN
 DECLARE
  @NipKraj  VARCHAR(2),
  @NipE     NVARCHAR(20),
  @Nazwa1   NVARCHAR(50),
  @Nazwa2   NVARCHAR(50),
  @Nazwa3   NVARCHAR(512),
  @Kraj     NVARCHAR(40),
  @KrajISO    NVARCHAR(2),
  @Wojewodztwo NVARCHAR(40),
  @Powiat   NVARCHAR(40),
  @Gmina   NVARCHAR(40),
  @KodGminy  VARCHAR(7),
  @Ulica   NVARCHAR(40),
  @NrDomu   NVARCHAR(10),
  @NrLokalu  NVARCHAR(10),
  @Miasto   NVARCHAR(40),
  @KodP   VARCHAR(10),
  @Poczta   NVARCHAR(40),
  @Telefon  VARCHAR(20)
 DECLARE @dtNow DATETIME
 SELECT @dtNow = GETDATE()
 SELECT @NipKraj = IsNull(PC_NipKraj, ''), @NipE = IsNull(PC_NipE, ''),
  @Nazwa1 = IsNull(PC_Nazwa1, ''), @Nazwa2 = IsNull(PC_Nazwa2, ''), @Nazwa3 = IsNull(PC_Nazwa3, ''),
  @Kraj = IsNull(PC_Kraj, ''), @KrajISO = IsNull(PC_KrajISO, ''), @Wojewodztwo = IsNull(PC_Wojewodztwo, ''), @Powiat = IsNull(PC_Powiat, ''), @Gmina = IsNull(PC_Gmina, ''), @KodGminy = IsNull(PC_KodGminy, ''), @Ulica = IsNull(PC_Ulica, ''), @NrDomu = IsNull(PC_NrDomu, ''), @NrLokalu = IsNull(PC_NrLokalu, ''), @Miasto = IsNull(PC_Miasto, ''), @KodP = IsNull(PC_KodP, ''), @Poczta = IsNull(PC_Poczta, ''),
  @Telefon = IsNull(PC_Telefon, '')
 FROM cdn.Pieczatki WHERE PC_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120)
 DECLARE @OsFiz TINYINT
 SELECT @OsFiz = CASE WHEN IsNull(Fir_Wartosc, '') = '' OR IsNull(Fir_Wartosc, '') = '0' THEN 0 ELSE 1 END FROM cdn.Firma WHERE Fir_Numer = 1103
 IF @OsFiz = 0
 BEGIN
  EXEC cdn.AktualizujWpisCdnFirma 1167, 'Numer NIP - Kraj', @NipKraj
  EXEC cdn.AktualizujWpisCdnFirma 1101, 'Numer NIP', @NipE
  IF @AktualizujTylkoNipRegon = 0
  BEGIN
   DECLARE @Nazwa NVARCHAR(240); SELECT @Nazwa = RTRIM(SUBSTRING(@Nazwa1 + ' ' + @Nazwa2 + ' ' + @Nazwa3, 1, 240))
   EXEC cdn.AktualizujWpisCdnFirma 1104, 'Nazwa pełna lub nazwisko', @Nazwa
  END
 END
 IF @AktualizujTylkoNipRegon = 0
 BEGIN
  EXEC cdn.AktualizujWpisCdnFirma 1590, 'Siedziba lub adres zamieszkania - kraj', @Kraj
  EXEC cdn.AktualizujWpisCdnFirma 1767, 'Siedziba lub adres zamieszkania - kod ISO kraju', @KrajISO
  EXEC cdn.AktualizujWpisCdnFirma 1591, 'Siedziba lub adres zamieszkania - województwo', @Wojewodztwo
  EXEC cdn.AktualizujWpisCdnFirma 1592, 'Siedziba lub adres zamieszkania - powiat', @Powiat
  EXEC cdn.AktualizujWpisCdnFirma 1593, 'Siedziba lub adres zamieszkania - gmina', @Gmina
  EXEC cdn.AktualizujWpisCdnFirma 3037, 'Gmina w której mieści się firma VAT7', @KodGminy
  EXEC cdn.AktualizujWpisCdnFirma 1597, 'Siedziba lub adres zamieszkania - miejscowość', @Miasto
  EXEC cdn.AktualizujWpisCdnFirma 1594, 'Siedziba lub adres zamieszkania - ulica', @Ulica
  EXEC cdn.AktualizujWpisCdnFirma 1595, 'Siedziba lub adres zamieszkania - nr domu', @NrDomu
  EXEC cdn.AktualizujWpisCdnFirma 1596, 'Siedziba lub adres zamieszkania - nr lokalu', @NrLokalu
  EXEC cdn.AktualizujWpisCdnFirma 1598, 'Siedziba lub adres zamieszkania - kod pocztowy', @KodP
  EXEC cdn.AktualizujWpisCdnFirma 1599, 'Siedziba lub adres zamieszkania - poczta', @Poczta
  EXEC cdn.AktualizujWpisCdnFirma 1600, 'Siedziba lub adres zamieszkania - telefon', @Telefon
 END
END
