CREATE PROCEDURE cdn.AktualnaPieczatka2CdnFirmaDanePIT4RCIT8ZUSDRA(@AktualizujTylkoNipRegon TINYINT)
AS
BEGIN
 -- CfgDaneFirmyView.cs
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
  @Miasto   NVARCHAR(40),
  @Ulica   NVARCHAR(40),
  @NrDomu   NVARCHAR(10),
  @NrLokalu  NVARCHAR(10),
  @KodP   VARCHAR(10),
  @Poczta   NVARCHAR(40),
  @Telefon  VARCHAR(20)
 DECLARE @dtNow DATETIME
 SELECT @dtNow = GETDATE()
 SELECT @NipKraj = IsNull(PC_NipKraj, ''), @NipE = IsNull(PC_NipE, ''),
  @Nazwa1 = IsNull(PC_Nazwa1, ''), @Nazwa2 = IsNull(PC_Nazwa2, ''), @Nazwa3 = IsNull(PC_Nazwa3, ''),
  @Kraj = IsNull(PC_Kraj, ''), @KrajISO = IsNull(PC_KrajISO, ''), @Wojewodztwo = IsNull(PC_Wojewodztwo, ''), @Powiat = IsNull(PC_Powiat, ''), @Gmina = IsNull(PC_Gmina, ''), @Miasto = IsNull(PC_Miasto, ''), @Ulica = IsNull(PC_Ulica, ''), @NrDomu = IsNull(PC_NrDomu, ''), @NrLokalu = IsNull(PC_NrLokalu, ''), @KodP = IsNull(PC_KodP, ''), @Poczta = IsNull(PC_Poczta, ''),
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
   DECLARE @Nazwa NVARCHAR(75); SELECT @Nazwa = RTRIM(SUBSTRING(@Nazwa1 + ' ' + @Nazwa2 + ' ' + @Nazwa3, 1, 75))
   EXEC cdn.AktualizujWpisCdnFirma 1104, 'Nazwa pełna lub nazwisko', @Nazwa
  END
 END
 IF @AktualizujTylkoNipRegon = 0
 BEGIN
  EXEC cdn.AktualizujWpisCdnFirma 1105, 'Siedziba lub adres zamieszkania - kraj', @Kraj
  EXEC cdn.AktualizujWpisCdnFirma 1170, 'Siedziba lub adres zamieszkania - kod ISO kraju', @KrajISO
  EXEC cdn.AktualizujWpisCdnFirma 1106, 'Siedziba lub adres zamieszkania - województwo', @Wojewodztwo
  EXEC cdn.AktualizujWpisCdnFirma 1107, 'Siedziba lub adres zamieszkania - powiat', @Powiat
  EXEC cdn.AktualizujWpisCdnFirma 1108, 'Siedziba lub adres zamieszkania - gmina', @Gmina
  EXEC cdn.AktualizujWpisCdnFirma 1112, 'Siedziba lub adres zamieszkania - miejscowość', @Miasto
  EXEC cdn.AktualizujWpisCdnFirma 1109, 'Siedziba lub adres zamieszkania - ulica', @Ulica
  EXEC cdn.AktualizujWpisCdnFirma 1110, 'Siedziba lub adres zamieszkania - nr domu', @NrDomu
  EXEC cdn.AktualizujWpisCdnFirma 1111, 'Siedziba lub adres zamieszkania - nr lokalu', @NrLokalu
  EXEC cdn.AktualizujWpisCdnFirma 1113, 'Siedziba lub adres zamieszkania - kod pocztowy', @KodP
  EXEC cdn.AktualizujWpisCdnFirma 1114, 'Siedziba lub adres zamieszkania - poczta', @Poczta
  EXEC cdn.AktualizujWpisCdnFirma 1115, 'Siedziba lub adres zamieszkania - telefon', @Telefon
 END
END
