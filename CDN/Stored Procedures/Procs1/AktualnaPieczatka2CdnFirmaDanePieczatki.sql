CREATE PROCEDURE cdn.AktualnaPieczatka2CdnFirmaDanePieczatki
AS
BEGIN
 IF NOT EXISTS (SELECT * FROM cdn.Pieczatki WHERE PC_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120))
  RETURN
 DECLARE
  @Nazwa1   NVARCHAR(50),
  @Nazwa2   NVARCHAR(50),
  @Nazwa3   NVARCHAR(512),
  @NipKraj  VARCHAR(2),
  @NipE     NVARCHAR(20),
  @Regon     NVARCHAR(20),
  @Kraj     NVARCHAR(40),
  @KrajISO    NVARCHAR(2),
  @Wojewodztwo NVARCHAR(40),
  @Powiat   NVARCHAR(40),
  @Gmina   NVARCHAR(40),
  @KodGminy  VARCHAR(7),
  @Miasto   NVARCHAR(40),
  @Ulica   NVARCHAR(40),
  @NrDomu   NVARCHAR(10),
  @NrLokalu  NVARCHAR(10),
  @KodP   VARCHAR(10),
  @Poczta   NVARCHAR(40),
  @Telefon  VARCHAR(20),
  @Email   VARCHAR(127),
  @URL   VARCHAR(254),
  @KRS_Sad  NVARCHAR(100),
  @KRS_Numer  NVARCHAR(10),
  @KRS_KapitalZak NVARCHAR(20),
  @KRS_KapitalWpl NVARCHAR(20),
  @Opis   NVARCHAR(50),
  @ILNGLNWlasny VARCHAR(13),
  @ILNGLNCentrali VARCHAR(13),
  @PUESC   NVARCHAR(50),
  @BDO     NVARCHAR(20)
 DECLARE @dtNow DATETIME
 SELECT @dtNow = GETDATE()
 SELECT @Nazwa1 = IsNull(PC_Nazwa1, ''), @Nazwa2 = IsNull(PC_Nazwa2, ''), @Nazwa3 = IsNull(PC_Nazwa3, ''),
  @NipKraj = IsNull(PC_NipKraj, ''), @NipE = IsNull(PC_NipE, ''), @Regon = IsNull(PC_Regon, ''),
  @Kraj = IsNull(PC_Kraj, ''), @KrajISO = IsNull(PC_KrajISO, ''), @Wojewodztwo = IsNull(PC_Wojewodztwo, ''), @Powiat = IsNull(PC_Powiat, ''), @Gmina = IsNull(PC_Gmina, ''), @KodGminy = IsNull(PC_KodGminy, ''), @Miasto = IsNull(PC_Miasto, ''), @Ulica = IsNull(PC_Ulica, ''), @NrDomu = IsNull(PC_NrDomu, ''), @NrLokalu = IsNull(PC_NrLokalu, ''), @KodP = IsNull(PC_KodP, ''), @Poczta = IsNull(PC_Poczta, ''),
  @Telefon = IsNull(PC_Telefon, ''), @Email = IsNull(PC_Email, ''), @URL = IsNull(PC_URL, ''),
  @KRS_Sad = IsNull(PC_KRS_Sad, ''), @KRS_Numer = IsNull(PC_KRS_Numer, ''), @KRS_KapitalZak = IsNull(PC_KRS_KapitalZak, ''), @KRS_KapitalWpl = IsNull(PC_KRS_KapitalWpl, ''),
  @Opis = IsNull(PC_Opis, ''),
  @ILNGLNWlasny = IsNull(PC_ILNGLNWlasny, ''), @ILNGLNCentrali = IsNull(PC_ILNGLNCentrali, ''), @PUESC = IsNull(PC_PUESC, ''), @BDO = IsNull(PC_BDO, '')
 FROM cdn.Pieczatki WHERE PC_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120)
 EXEC cdn.AktualizujWpisCdnFirma 1167, 'Numer NIP - Kraj', @NipKraj
 EXEC cdn.AktualizujWpisCdnFirma 1101, 'Numer NIP', @NipE
 EXEC cdn.AktualizujWpisCdnFirma 1118, 'Regon firmy', @Regon
 EXEC cdn.AktualizujWpisCdnFirma 1156, 'Pieczątka - Nazwa 1', @Nazwa1
 EXEC cdn.AktualizujWpisCdnFirma 1157, 'Pieczątka - Nazwa 2', @Nazwa2
 EXEC cdn.AktualizujWpisCdnFirma 2166, 'Pieczątka - Nazwa 3', @Nazwa3
 EXEC cdn.AktualizujWpisCdnFirma 1145, 'Pieczątka - Siedziba lub adres zamieszkania - kraj', @Kraj
 EXEC cdn.AktualizujWpisCdnFirma 1169, 'Pieczątka - Siedziba lub adres zamieszkania - kod ISO kraju', @KrajISO
 EXEC cdn.AktualizujWpisCdnFirma 1146, 'Pieczątka - Siedziba lub adres zamieszkania - województwo', @Wojewodztwo
 EXEC cdn.AktualizujWpisCdnFirma 1147, 'Pieczątka - Siedziba lub adres zamieszkania - powiat', @Powiat
 EXEC cdn.AktualizujWpisCdnFirma 1148, 'Pieczątka - Siedziba lub adres zamieszkania - gmina', @Gmina
 EXEC cdn.AktualizujWpisCdnFirma 1168, 'Pieczątka - Siedziba lub adres zamieszkania - gmina', @KodGminy
 EXEC cdn.AktualizujWpisCdnFirma 1152, 'Pieczątka - Siedziba lub adres zamieszkania - miasto', @Miasto
 EXEC cdn.AktualizujWpisCdnFirma 1149, 'Pieczątka - Siedziba lub adres zamieszkania - ulica', @Ulica
 EXEC cdn.AktualizujWpisCdnFirma 1150, 'Pieczątka - Siedziba lub adres zamieszkania - nr domu', @NrDomu
 EXEC cdn.AktualizujWpisCdnFirma 1151, 'Pieczątka - Siedziba lub adres zamieszkania - nr lokalu', @NrLokalu
 EXEC cdn.AktualizujWpisCdnFirma 1153, 'Pieczątka - Siedziba lub adres zamieszkania - kod pocztowy', @KodP
 EXEC cdn.AktualizujWpisCdnFirma 1154, 'Pieczątka - Siedziba lub adres zamieszkania - poczta', @Poczta
 EXEC cdn.AktualizujWpisCdnFirma 1155, 'Pieczątka - Siedziba lub adres zamieszkania - telefon', @Telefon
 EXEC cdn.AktualizujWpisCdnFirma 2221, 'Pieczątka - adres e-mail', @Email
 EXEC cdn.AktualizujWpisCdnFirma 3087, 'Pieczątka - adres URL', @URL
 EXEC cdn.AktualizujWpisCdnFirma 1171, 'Pieczątka - KRS - Sąd Rejonowy', @KRS_Sad
 EXEC cdn.AktualizujWpisCdnFirma 1172, 'Pieczątka - KRS - Numer', @KRS_Numer
 EXEC cdn.AktualizujWpisCdnFirma 1173, 'Pieczątka - KRS - Kapitał zakładowy', @KRS_KapitalZak
 EXEC cdn.AktualizujWpisCdnFirma 1174, 'Pieczątka - KRS - Kapitał wpłacony', @KRS_KapitalWpl
 EXEC cdn.AktualizujWpisCdnFirma 1158, 'Pieczątka - Opis', @Opis
 EXEC cdn.AktualizujWpisCdnFirma 1165, 'Pieczątka - GLN własny', @ILNGLNWlasny
 EXEC cdn.AktualizujWpisCdnFirma 1166, 'Pieczątka - GLN centrali', @ILNGLNCentrali
 EXEC cdn.AktualizujWpisCdnFirma 3080, 'Identyfikator firmy w PUESC', @PUESC
 EXEC cdn.AktualizujWpisCdnFirma 1881, 'Identyfikator firmy w BDO', @BDO
 IF (SELECT Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 3126) = 1
 BEGIN
  DECLARE @Nazwa NVARCHAR(256); SELECT @Nazwa = RTRIM(SUBSTRING(@Nazwa1 + ' ' + @Nazwa2, 1, 256))
  EXEC cdn.AktualizujWpisCdnFirma 3127, 'Administrator danych osobowych - nazwa', @Nazwa
  EXEC cdn.AktualizujWpisCdnFirma 3128, 'Administrator danych osobowych - kraj', @Kraj
  EXEC cdn.AktualizujWpisCdnFirma 3129, 'Administrator danych osobowych - miasto', @Miasto
  EXEC cdn.AktualizujWpisCdnFirma 3130, 'Administrator danych osobowych - poczta', @Poczta
  EXEC cdn.AktualizujWpisCdnFirma 3131, 'Administrator danych osobowych - kod pocztowy', @KodP
  EXEC cdn.AktualizujWpisCdnFirma 3132, 'Administrator danych osobowych - ulica', @Ulica
  EXEC cdn.AktualizujWpisCdnFirma 3133, 'Administrator danych osobowych - nr domu', @NrDomu
  EXEC cdn.AktualizujWpisCdnFirma 3134, 'Administrator danych osobowych - nr lokalu', @NrLokalu
  EXEC cdn.AktualizujWpisCdnFirma 3135, 'Administrator danych osobowych - telefon', @Telefon
  EXEC cdn.AktualizujWpisCdnFirma 3136, 'Administrator danych osobowych - E-Mail', @Email
 END
END
