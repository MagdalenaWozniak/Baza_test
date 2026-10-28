CREATE PROCEDURE CDN.AnonimizujPrzedstawiciela( @id INT, @opeId INT, @opeKod VARCHAR(20), @opeNazwisko NVARCHAR(50), @rejestrOperacji INT, @errorCount INT OUTPUT)
AS
BEGIN
 SET @errorCount = 0
 DECLARE  @newKod NVARCHAR(40), @kntId INT, @nazwisko NVARCHAR(40), @maxLp INT,
 @telefon varchar(20), @telefonSms varchar(20), @GSM varchar(20), @email nvarchar(60)
 SELECT TOP 1 @kntId = KnO_KntId, @nazwisko = KnO_Nazwisko, @telefon=KnO_Telefon, @telefonSms=KnO_TelefonSms, @GSM=KnO_GSM, @email=KnO_Email FROM cdn.KntOsoby WHERE KnO_KnOId = @id
 SELECT @maxLp = MAX(Lp)
 FROM
 (SELECT MAX(Knt_LpAnonimizacji) As Lp FROM cdn.Kontrahenci WHERE Knt_LpAnonimizacji > 0
 UNION
 SELECT MAX(KnO_LpAnonimizacji) As Lp FROM cdn.KntOsoby WHERE KnO_LpAnonimizacji > 0) t
 IF @maxLp IS NULL SET @maxLp = 0
 WHILE(1 = 1)
 BEGIN
  SET @maxLp = @maxLp + 1
  SET @newKod = 'ANONIM' + LTRIM(RTRIM(STR(@maxLp)))
  IF NOT EXISTS(SELECT KnT_KntId FROM  [CDN].Kontrahenci WHERE Knt_Kod = @newKod)
  BEGIN
   IF NOT EXISTS(SELECT KnO_KnOId FROM  [CDN].[KntOsoby] WHERE [KnO_Nazwisko] = @newKod)  BREAK
  END
 END
 BEGIN TRANSACTION
 update K SET K.DSKnt_OsobaOdbierajaca =N'' FROM [CDN].[DetalStanKontrahenci] AS K
 inner join CDN.Kontrahenci on Knt_KntId = DSKnt_OptimaId
 inner join CDN.KntOsoby on KnO_KntId = Knt_KntId
 where K.DSKnt_OsobaOdbierajaca = KnO_Nazwisko and KnO_KnOId =@id
 IF @@ERROR > 0 GOTO KONIEC
 update K SET K.DKnt_OsobaOdbierajaca =N'' FROM [CDN].[DetalKontrahenci] AS K
 inner join CDN.Kontrahenci on Knt_KntId = DKnt_OptimaId
 inner join CDN.KntOsoby on KnO_KntId = Knt_KntId
 where K.DKnt_OsobaOdbierajaca = KnO_Nazwisko and KnO_KnOId =@id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[KntOsoby] SET
 [KnO_Tytul] = N'',
 [KnO_Plec] = 0,
 [KnO_Nazwisko] = @newKod,
 [KnO_Kraj] = N'',
 [KnO_Wojewodztwo] = N'',
 [KnO_Powiat] = N'',
 [KnO_Gmina] = N'',
 [KnO_Ulica] = N'',
 [KnO_NrDomu] = N'',
 [KnO_NrLokalu] = N'',
 [KnO_Miasto] = N'',
 [KnO_KodPocztowy] = N'',
 [KnO_Poczta] = N'',
 [KnO_Adres2] = N'',
 [KnO_Telefon]  = '',
 [KnO_TelefonSms]  = '',
 [KnO_GSM]  = '',
 [KnO_Email]  = N'',
 [KnO_Mailing]  = 0,
 [KnO_Informacje] = 0,
 [KnO_Domyslny] = 0,
 [KnO_Nieaktywny] = 1,
 [KnO_DataAnonimizacji] = GetDate(),
 [KnO_LpAnonimizacji] = @maxLp
 WHERE KnO_KnOId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE cdn.RejestrOperacji
 SET ROP_ObiektNazwa = @newKod
 WHERE ROP_ObiektTyp = 1114 AND ROP_ObiektID = @id
 IF @@ERROR > 0 GOTO KONIEC
    EXEC [CDN].[RejestrOperacjiDodaj]   @ObiektTyp      = 1114,
                                        @ObiektSubTyp   = 0,
                                        @ObiektID       = @id,
                                        @ObiektNazwa    = @newKod,
                                        @OperacjaTyp    = 212,
                                        @Opis           = N''
 DELETE FROM cdn.RejestrUpowaznien WHERE RUP_OsobaID=@id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM CDN.PodmiotRejestracjaZgod WHERE PRZ_PrzedstawicielId=@id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[DetalKntOsoby] SET
 [DKnO_Telefon] = '',
 [DKnO_GSM] = '',
 [DKnO_Email] = N'',
 [DKnO_Nazwisko] = N''
 WHERE [DKnO_OptimaId] = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[KntScalHist] SET [KSH_NumerDok] = @newKod, [KSH_NewKntID] = NULL WHERE [KSH_NazwaTabeli] = 'cdn.KntOsoby' AND [KSH_NewKntID] = @kntId AND [KSH_NumerDok] = @nazwisko
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
  INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT TrN_TypDokumentu, NULL, TrN_TrNId, TrN_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM CDN.TraNag
  WHERE TrN_Odebral = @nazwisko AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @kntId) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @kntId))
 END
 UPDATE CDN.TraNag SET
  TrN_Odebral = N'',
  [TrN_TS_Mod] = GetDate(),
  [TrN_OpeModId] = @opeId,
  [TrN_OpeModKod] = @opeKod,
  [TrN_OpeModNazwisko] = @opeNazwisko
 WHERE TrN_Odebral = @nazwisko AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @kntId) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @kntId))
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 800, NULL, OfD_OfDId, OfD_NumerPelny, GetDate(), @opeNazwisko, 212, N''
  FROM cdn.OfertyKnt JOIN cdn.OfertyDok ON OfK_OfDId = OfD_OfDId WHERE OfK_PodmiotTyp=1  AND OfK_PodID = @kntId AND OfK_KnO_KnOId = @id AND OfK_PodEmail = @email
 END
 UPDATE cdn.OfertyKnt SET
  [OfK_PodEmail] = N''
 WHERE OfK_PodmiotTyp=1 AND OfK_PodID = @kntId AND OfK_KnO_KnOId = @id AND OfK_PodEmail = @email
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 370, NULL, SZL_SZLId, SZL_NumerPelny, GetDate(), @opeNazwisko, 212, N''
  FROM CDN.[SenditZleceniePrzesylki] WHERE
  (SZL_OdbiorcaTyp = 1 AND SZL_OdbID = @kntId)
  AND (SZL_Odebral = @nazwisko OR [SZL_OdbTelefon]=@telefon OR [SZL_OdbTelefon]=@telefonSms OR [SZL_OdbTelefon]=@GSM OR SZL_OdbEmail=@email)
 END
 UPDATE [CDN].[SenditZleceniePrzesylki] SET
 [SZL_OdbTelefon] = '',
 [SZL_OpeModID] = @opeId,
 [SZL_TS_Mod] = GetDate(),
 [SZL_OpeModKod]= @opeKod,
 [SZL_OpeModNazwisko] = @opeNazwisko
 WHERE SZL_Odebral = @nazwisko AND (SZL_OdbiorcaTyp = 1 AND SZL_OdbID = @kntId) AND ([SZL_OdbTelefon]=@telefon OR [SZL_OdbTelefon]=@telefonSms OR [SZL_OdbTelefon]=@GSM)
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[SenditZleceniePrzesylki] SET
 [SZL_OdbEmail] = N'',
 [SZL_OpeModID] = @opeId,
 [SZL_TS_Mod] = GetDate(),
 [SZL_OpeModKod]= @opeKod,
 [SZL_OpeModNazwisko] = @opeNazwisko
 WHERE SZL_Odebral = @nazwisko AND (SZL_OdbiorcaTyp = 1 AND SZL_OdbID = @kntId) AND (SZL_OdbEmail=@email)
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[SenditZleceniePrzesylki] SET
 [SZL_Odebral] = N'',
 [SZL_OpeModID] = @opeId,
 [SZL_TS_Mod] = GetDate(),
 [SZL_OpeModKod]= @opeKod,
 [SZL_OpeModNazwisko] = @opeNazwisko
 WHERE SZL_Odebral = @nazwisko AND (SZL_OdbiorcaTyp = 1 AND SZL_OdbID = @kntId)
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.CrmKontakty SET
   CrK_OsobaNazwisko = @newKod,
  [CrK_TS_Mod] = GetDate(),
  [CrK_OpeModId] = @opeId,
  [CrK_OpeModKod] = @opeKod,
  [CrK_OpeModNazwisko] = @opeNazwisko
 WHERE CrK_OsobaId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
  INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 700, NULL, CrK_CrKId, CrK_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM CDN.CrmKontakty
  WHERE CrK_OsobaId = @id
 END
 UPDATE CDN.SrsZlecenia  SET
  SrZ_ZlecajacyNazwisko = @newKod,
  SrZ_ZlecajacyTelefon = N'',
  [SrZ_TS_Mod] = GetDate(),
  [SrZ_OpeModId] = @opeId,
  [SrZ_OpeModKod] = @opeKod,
  [SrZ_OpeModNazwisko] = @opeNazwisko
 WHERE SrZ_Bufor > -1 AND SrZ_ZlecajacyId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.SrsZlecenia SET
  SrZ_PrzedstawicielNazwisko = @newKod,
  SrZ_PrzedstawicielTelefon = N'',
  [SrZ_TS_Mod] = GetDate(),
  [SrZ_OpeModId] = @opeId,
  [SrZ_OpeModKod] = @opeKod,
  [SrZ_OpeModNazwisko] = @opeNazwisko
 WHERE SrZ_Bufor > -1 AND SrZ_PrzedstawicielId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 900, NULL, SrZ_SrZId, SrZ_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM CDN.SrsZlecenia WHERE SrZ_Bufor > -1 AND (SrZ_ZlecajacyId = @id OR SrZ_PrzedstawicielId = @id)
 END
 UPDATE CDN.SrsCyklNag  SET
  SrW_ZlecajacyNazwisko = @newKod,
  SrW_ZlecajacyTelefon = N'',
  [SrW_TS_Mod] = GetDate(),
  [SrW_OpeModId] = @opeId,
  [SrW_OpeModKod] = @opeKod,
  [SrW_OpeModNazwisko] = @opeNazwisko
 WHERE SrW_ZlecajacyId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.SrsCyklNag  SET
  SrW_PrzedstawicielNazwisko = @newKod,
  SrW_PrzedstawicielTelefon = N'',
  [SrW_TS_Mod] = GetDate(),
  [SrW_OpeModId] = @opeId,
  [SrW_OpeModKod] = @opeKod,
  [SrW_OpeModNazwisko] = @opeNazwisko
 WHERE SrW_PrzedstawicielId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 906, NULL, SrW_SrWId, SrW_Kod, GetDate(), @opeNazwisko, 212, N'' FROM CDN.SrsCyklNag WHERE SrW_ZlecajacyId = @id OR SrW_PrzedstawicielId = @id
 END
 IF @rejestrOperacji = 1
 BEGIN
  SELECT DISTINCT 714, NULL, AnkWaN_AnkWaNId, AnkWaN_Kod, GetDate(), @opeNazwisko, 212, N''
  FROM cdn.AnkWzorzecAnkietyNag JOIN cdn.AnkWzorzecAnkietyAnkietowani ON AnkWaN_AnkWaNId = AnkWaA_AnkWaNId WHERE AnkWaA_PodmiotTyp = 1 AND AnkWaA_OsobaId = @id
 END
 DELETE FROM CDN.AnkWzorzecAnkietyAnkietowani WHERE AnkWaA_PodmiotTyp = 1 AND AnkWaA_OsobaId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.AnkAnkietyNag SET
  AnkAnN_OsobaNazwisko = @newKod,
  AnkAnN_OsobaTelefon = '',
  [AnkAnN_TS_Mod] = GetDate(),
  [AnkAnN_OpeModId] = @opeId,
  [AnkAnN_OpeModKod] = @opeKod,
  [AnkAnN_OpeModNazwisko] = @opeNazwisko
 WHERE AnkAnN_PodmiotTyp = 1 AND AnkAnN_OsobaId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 710, NULL, AnkAnN_AnkAnNId, AnkAnN_NumerPelny, GetDate(), @opeNazwisko, 212, N''
  FROM cdn.AnkAnkietyNag WHERE AnkAnN_PodmiotTyp = 1 AND AnkAnN_OsobaId = @id
 END
 UPDATE [CDN].[RejestrNaruszen] SET
 [RUN_ImieNazwisko] = @newKod,
 [RUN_OpeModID] = @opeId,
 [RUN_TS_Mod] =GetDate(),
 [RUN_OpeModKod] = @opeKod,
 [RUN_OpeModNazwisko] = @opeNazwisko
 WHERE RUN_PodmiotTyp = 1 AND RUN_PodId = @id AND RUN_OsobaId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 1801, NULL, RUN_RUNId,  CAST(RUN_CharakterNaruszenia AS  NVARCHAR(100)), GetDate(), @opeNazwisko, 212, N'' FROM cdn.[RejestrNaruszen] WHERE RUN_PodmiotTyp = 1 AND RUN_PodId = @id
 END
 IF COL_LENGTH('cdn.KntESklepyPrzedstawiciele', 'KESP_NieAktywny') IS NOT NULL
 BEGIN
        DECLARE @sqltxt NVARCHAR(512)
        DECLARE @paramDefinition NVARCHAR(32)
        SET @paramDefinition = N'@anonimKod varchar(20) OUTPUT';
  SET @sqltxt = N'UPDATE [CDN].[KntESklepyPrzedstawiciele] SET [KESP_Domyslny] = 0,[KESP_NieAktywny] = 1,[KESP_Email] = N'''',[KESP_Nazwisko] = @anonimKod WHERE [KESP_PrzedstawicielID] = ' + Convert(nvarchar(20), @id)
        EXEC sp_executeSql @sqltxt, @paramDefinition, @anonimKod=@newKod
  IF @@ERROR > 0 GOTO KONIEC
 END
KONIEC:
 IF @@TRANCOUNT <> 0
 BEGIN
  IF @@ERROR <> 0
  BEGIN
   SET @errorCount = @@ERROR
   ROLLBACK TRANSACTION
  END
  ELSE
  BEGIN
   COMMIT TRANSACTION
  END
 END
END
