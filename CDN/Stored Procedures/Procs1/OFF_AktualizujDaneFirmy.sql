CREATE  PROCEDURE CDN.OFF_AktualizujDaneFirmy
    @Nazwa1        nvarchar(254),
    @Nazwa2        nvarchar(254),
    @Nazwa3        nvarchar(254),
    @NipKraj       nvarchar(254),
    @NIP           nvarchar(254),
    @KodPocztowy   nvarchar(254),
    @Miasto        nvarchar(254),
    @Regon         nvarchar(254),
    @Telefon       nvarchar(254),
    @Ulica         nvarchar(254),
    @Powiat        nvarchar(254),
    @Wojewodztwo   nvarchar(254),
    @Poczta        nvarchar(254),
    @Kraj          nvarchar(254),
    @Opis          nvarchar(254),
    @Sad           nvarchar(254),
    @Numer         nvarchar(254),
    @KapitalZak    nvarchar(254),
    @KapitalWpl    nvarchar(254),
 @OpeZalIDChr                nvarchar(11),
    @StaZalIdChr                nvarchar(11)
AS
  SET NOCOUNT ON
      EXEC CDN.OFF_AktualizujFirma 1101, @NIP, 'NIP'
      EXEC CDN.OFF_AktualizujFirma 1118, @Regon, 'Regon'
      EXEC CDN.OFF_AktualizujFirma 1145, @Kraj, 'Kraj'
      EXEC CDN.OFF_AktualizujFirma 1146, @Wojewodztwo, 'Wojewodztwo'
      EXEC CDN.OFF_AktualizujFirma 1147, @Powiat, 'Powiat'
      EXEC CDN.OFF_AktualizujFirma 1149, @Ulica, 'Ulica'
      EXEC CDN.OFF_AktualizujFirma 1152, @Miasto, 'Miasto'
      EXEC CDN.OFF_AktualizujFirma 1153, @KodPocztowy, 'KodPocztowy'
      EXEC CDN.OFF_AktualizujFirma 1154, @Poczta, 'Poczta'
      EXEC CDN.OFF_AktualizujFirma 1155, @Telefon, 'Telefon'
      EXEC CDN.OFF_AktualizujFirma 1156, @Nazwa1, 'Nazwa1'
      EXEC CDN.OFF_AktualizujFirma 1157, @Nazwa2, 'Nazwa2'
   EXEC CDN.OFF_AktualizujFirma 2166, @Nazwa3, 'Nazwa3'
      EXEC CDN.OFF_AktualizujFirma 1158, @Opis, 'Opis'
      EXEC CDN.OFF_AktualizujFirma 1167, @NipKraj, 'Numer NIP - Kraj'
      EXEC CDN.OFF_AktualizujFirma 1171, @Sad, 'Pieczątka - KRS - Sąd Rejonowy'
      EXEC CDN.OFF_AktualizujFirma 1172, @Numer, 'Pieczątka - KRS - Numer'
      EXEC CDN.OFF_AktualizujFirma 1173, @KapitalZak, 'Pieczątka - KRS - Kapitał zakładowy'
      EXEC CDN.OFF_AktualizujFirma 1174, @KapitalWpl, 'Pieczątka - KRS - Kapitał wpłacony'
 DECLARE
  @Nazwa1p   NVARCHAR(50),
  @Nazwa2p   NVARCHAR(50),
  @Nazwa3p   NVARCHAR(512),
  @NipKrajp  VARCHAR(2),
  @NipEp     NVARCHAR(20),
  @Regonp    NVARCHAR(20),
  @Krajp     NVARCHAR(40),
  @KrajISOp    NVARCHAR(2),
  @Wojewodztwop NVARCHAR(40),
  @Powiatp   NVARCHAR(40),
  @Gminap   NVARCHAR(40),
  @KodGminyp  VARCHAR(7),
  @Miastop   NVARCHAR(40),
  @Ulicap   NVARCHAR(40),
  @NrDomup   NVARCHAR(10),
  @NrLokalup  NVARCHAR(10),
  @KodPp   VARCHAR(10),
  @Pocztap   NVARCHAR(40),
  @Telefonp  VARCHAR(20),
  @Emailp   VARCHAR(127),
  @URLp   VARCHAR(254),
  @KRS_Sadp  NVARCHAR(100),
  @KRS_Numerp  NVARCHAR(10),
  @KRS_KapitalZakp NVARCHAR(20),
  @KRS_KapitalWplp NVARCHAR(20),
  @Opisp   NVARCHAR(50),
  @ILNGLNWlasnyp VARCHAR(13),
  @ILNGLNCentralip VARCHAR(13),
  @PUESCp   NVARCHAR(50),
  @BDOp   NVARCHAR(20),
  @OpeZalID                   INT,
        @StaZalId                   INT,
  @OpeModID                   INT,
        @StaModId                   INT
 DECLARE @dtNow DATETIME
 SELECT @dtNow = GETDATE(), @OpeZalID  = CONVERT(INT,@OpeZalIDChr),@StaZalId = CONVERT(INT,@StaZalIdChr)
 SET @OpeModID  = @OpeZalID
    SET @StaModId  = @StaZalId
    declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
    exec CDN.OpeKodNazwisko @OpeModID, @OpeModKod OUT, @OpeModNazwisko OUT
 SELECT @Nazwa1p = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1156
 SELECT @Nazwa2p = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1157
 SELECT @Nazwa3p = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2166
 SELECT @NipKrajp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1167
 SELECT @NipEp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1101
 SELECT @Regonp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1118
 SELECT @Krajp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1145
 SELECT @KrajISOp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1169
 SELECT @Wojewodztwop = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1146
 SELECT @Powiatp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1147
 SELECT @Gminap = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1148
 SELECT @KodGminyp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1168
 SELECT @Miastop = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1152
 SELECT @Ulicap = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1149
 SELECT @NrDomup = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1150
 SELECT @NrLokalup = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1151
 SELECT @KodPp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1153
 SELECT @Pocztap = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1154
 SELECT @Telefonp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1155
 SELECT @Emailp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2221
 SELECT @URLp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 3087
 SELECT @KRS_Sadp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1171
 SELECT @KRS_Numerp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1172
 SELECT @KRS_KapitalZakp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1173
 SELECT @KRS_KapitalWplp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1174
 SELECT @Opisp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1158
 SELECT @ILNGLNWlasnyp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1165
 SELECT @ILNGLNCentralip = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1166
 SELECT @PUESCp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 3080
 SELECT @BDOp = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1881
 DECLARE @dataOd DATETIME
 DECLARE @dataStr VARCHAR(32)
 DECLARE @pcID INT
 SELECT @pcID = PC_PCID FROM cdn.Pieczatki WHERE PC_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120)
 IF @pcID Is Null
 BEGIN
  SET IDENTITY_INSERT cdn.Pieczatki ON
  ALTER TABLE [CDN].[Pieczatki] DISABLE TRIGGER ALL
  INSERT INTO [CDN].[Pieczatki]
   (PC_PCID,
   PC_DataOd, PC_DataDo,
   PC_Nazwa1, PC_Nazwa2, PC_Nazwa3,
   PC_NipKraj, PC_NipE, PC_Regon,
   PC_Kraj, PC_KrajISO, PC_Wojewodztwo, PC_Powiat, PC_Gmina, PC_KodGminy, PC_Miasto, PC_Ulica, PC_NrDomu, PC_NrLokalu, PC_KodP, PC_Poczta,
   PC_Telefon, PC_Email, PC_URL,
   PC_KRS_Sad, PC_KRS_Numer, PC_KRS_KapitalZak, PC_KRS_KapitalWpl, PC_Opis, PC_ILNGLNWlasny, PC_ILNGLNCentrali, PC_PUESC, PC_BDO,
   PC_ImportRowId,
   PC_OpeZalId, PC_StaZalId, PC_TS_Zal, PC_OpeModId, PC_StaModId, PC_TS_Mod, PC_OpeZalKod, PC_OpeZalNazwisko, PC_OpeModKod, PC_OpeModNazwisko)
   VALUES(
   1,
   CONVERT(DATETIME, '1900-01-01 00:00:00', 120), CONVERT(DATETIME, '2999-12-31 00:00:00', 120),
   @Nazwa1p, @Nazwa2p, @Nazwa3p,
   @NipKrajp, @NipEp, @Regonp,
   @Krajp, @KrajISOp, @Wojewodztwop, @Powiatp, @Gminap, @KodGminyp, @Miastop, @Ulicap, @NrDomup, @NrLokalup, @KodPp, @Pocztap,
   @Telefonp, @Emailp, @URLp,
   @KRS_Sadp, @KRS_Numerp, @KRS_KapitalZakp, @KRS_KapitalWplp, @Opisp, @ILNGLNWlasnyp, @ILNGLNCentralip, @PUESCp, @BDOp,
   NewId(),
   @OpeZalID, @StaZalID, @dtNow, @OpeModID, @StaModID, @dtNow, @OpeModKod, @OpeModNazwisko, @OpeModKod, @OpeModNazwisko)
  ALTER TABLE [CDN].[Pieczatki] ENABLE TRIGGER ALL
  SET IDENTITY_INSERT cdn.Pieczatki OFF
  UPDATE cdn.DaneBinarne SET DAB_TwAID = 1 WHERE DAB_Typ = 13
  SELECT @dataOd = CONVERT(DATETIME, '1900-01-01 00:00:00', 120)
  ALTER TABLE cdn.TraNag DISABLE TRIGGER ALL
  UPDATE cdn.TraNag SET TrN_PCID = 1
  ALTER TABLE cdn.TraNag ENABLE TRIGGER ALL
 END
 ELSE
 BEGIN
  ALTER TABLE cdn.Pieczatki DISABLE TRIGGER ALL
  UPDATE cdn.Pieczatki
   SET
   PC_Nazwa1 = @Nazwa1p,
   PC_Nazwa2 = @Nazwa2p,
   PC_Nazwa3 = @Nazwa3p,
   PC_NipKraj = @NipKrajp,
   PC_NipE = @NipEp,
   PC_Regon = @Regonp,
   PC_Kraj = @Krajp,
   PC_KrajISO = @KrajISOp,
   PC_Wojewodztwo = @Wojewodztwop,
   PC_Powiat = @Powiatp,
   PC_Gmina = @Gminap,
   PC_KodGminy = @KodGminyp,
   PC_Miasto = @Miastop,
   PC_Ulica = @Ulicap,
   PC_NrDomu = @NrDomup,
   PC_NrLokalu = @NrLokalup,
   PC_KodP = @KodPp,
   PC_Poczta = @Pocztap,
   PC_Telefon = @Telefonp,
   PC_Email = @Emailp,
   PC_URL = @URLp,
   PC_KRS_Sad = @KRS_Sadp,
   PC_KRS_Numer = @KRS_Numerp,
   PC_KRS_KapitalZak = @KRS_KapitalZakp,
   PC_KRS_KapitalWpl = @KRS_KapitalWplp,
   PC_Opis = @Opis,
   PC_ILNGLNWlasny = @ILNGLNWlasnyp,
   PC_ILNGLNCentrali = @ILNGLNCentralip,
   PC_PUESC = @PUESCp,
   PC_BDO = @BDOp,
   PC_OpeModId = @OpeModID,
   PC_StaModId = @StaModId,
   PC_TS_Mod = @dtNow,
   PC_OpeModKod = @OpeModKod,
   PC_OpeModNazwisko = @OpeModNazwisko
  WHERE PC_PCID = @pcID
  ALTER TABLE cdn.Pieczatki ENABLE TRIGGER ALL
 END
      update cdn.DefCeny set Dfc_Nieaktywna = 1
  SET NOCOUNT OFF
