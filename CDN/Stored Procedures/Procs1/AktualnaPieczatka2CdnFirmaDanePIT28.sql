CREATE PROCEDURE cdn.AktualnaPieczatka2CdnFirmaDanePIT28(@AktualizujTylkoNipRegon TINYINT)
AS
BEGIN
 -- CfgDaneDeklPIT28View.cs
 IF NOT EXISTS (SELECT * FROM cdn.Pieczatki WHERE PC_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120))
  RETURN
 DECLARE
  @NipKraj  VARCHAR(2),
  @NipE     NVARCHAR(20),
  @Regon     NVARCHAR(20),
  @Nazwa1   NVARCHAR(50),
  @Nazwa2   NVARCHAR(50),
  @Nazwa3   NVARCHAR(512),
  @Miasto   NVARCHAR(40),
  @Ulica   NVARCHAR(40),
  @NrDomu   NVARCHAR(10),
  @NrLokalu  NVARCHAR(10),
  @KodP   VARCHAR(10),
  @Poczta   NVARCHAR(40)
 DECLARE @dtNow DATETIME
 SELECT @dtNow = GETDATE()
 SELECT @NipKraj = IsNull(PC_NipKraj, ''), @NipE = IsNull(PC_NipE, ''), @Regon = IsNull(PC_Regon, ''),
  @Nazwa1 = IsNull(PC_Nazwa1, ''), @Nazwa2 = IsNull(PC_Nazwa2, ''), @Nazwa3 = IsNull(PC_Nazwa3, ''),
  @Miasto = IsNull(PC_Miasto, ''), @Ulica = IsNull(PC_Ulica, ''), @NrDomu = IsNull(PC_NrDomu, ''), @NrLokalu = IsNull(PC_NrLokalu, ''), @KodP = IsNull(PC_KodP, ''), @Poczta = IsNull(PC_Poczta, '')
 FROM cdn.Pieczatki WHERE PC_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120)
 EXEC cdn.AktualizujWpisCdnFirma 1167, 'Numer NIP - Kraj', @NipKraj
 EXEC cdn.AktualizujWpisCdnFirma 1101, 'Numer NIP', @NipE
 EXEC cdn.AktualizujWpisCdnFirma 1118, 'Regon firmy', @Regon
 IF @AktualizujTylkoNipRegon = 0
 BEGIN
  DECLARE @Nazwa NVARCHAR(100); SELECT @Nazwa = RTRIM(SUBSTRING(@Nazwa1 + ' ' + @Nazwa2, 1, 100))
  EXEC cdn.AktualizujWpisCdnFirma 1175, 'Nazwa na deklaracji PIT-28', @Nazwa
  DECLARE @Adres NVARCHAR(150); SELECT @Adres = RTRIM(SUBSTRING(cdn.PieczatkaAdresDlaDeklaracji(@Miasto, @Ulica, @NrDomu, @NrLokalu, @KodP, @Poczta), 1, 150))
  EXEC cdn.AktualizujWpisCdnFirma 1120, 'Miejsce prowadzenia działalności', @Adres
 END
END
