CREATE PROCEDURE CDN.AnonimizujKontrahenta( @id INT, @opeId INT, @opeKod VARCHAR(20), @opeNazwisko NVARCHAR(50), @rejestrOperacji INT )
AS
BEGIN
 DECLARE @maxLp INT, @newKod VARCHAR(20), @newNazwa NVARCHAR(150), @newLp VARCHAR(19), @errorcount INT
 DECLARE @nipKnt NVARCHAR(20)
 SELECT TOP 1 @nipKnt = Knt_Nip FROM cdn.Kontrahenci WHERE Knt_KntId = @id
 IF @nipKnt IS NULL SET @nipKnt = N''
 SET @errorcount = 0
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
 SET @newNazwa = N'Dane zanonimizowane'
 BEGIN TRANSACTION
 UPDATE cdn.Kontrahenci SET
 Knt_Kod = @newKod,
 Knt_LpAnonimizacji = @maxLp,
 Knt_DataAnonimizacji = GetDate(),
 Knt_Nazwa1 = @newNazwa,
 Knt_Nazwa2 = N'',
 Knt_Nazwa3 = N'',
 [Knt_GLN] = '',
 [Knt_EAN] = '',
 [Knt_Grupa] = '',
 [Knt_Kraj] = N'',
 [Knt_Wojewodztwo] = N'',
 [Knt_Powiat] = N'',
 [Knt_Gmina] = N'',
 [Knt_Ulica] = N'',
 [Knt_NrDomu] = N'',
 [Knt_NrLokalu] = N'',
 [Knt_Miasto] = N'',
 [Knt_KodPocztowy]  = '',
 [Knt_Poczta] = N'',
 [Knt_Adres2]  = N'',
 [Knt_NipKraj] = '',
 [Knt_NipE]  = N'',
 [Knt_Nip]  = N'',
 [Knt_Regon]  = '',
 [Knt_Pesel] = N'',
 [Knt_Telefon1] = '',
 [Knt_Telefon2] = '',
 [Knt_TelefonSms] = '',
 [Knt_Fax] = '',
 [Knt_Email] = N'',
 [Knt_URL] = '',
 [Knt_KrajISO] = N'',
 [Knt_Zezwolenie] = N'',
 [Knt_KodTransakcji] = N'',
 [Knt_BazaBR_GUID]= NULL,
 [Knt_BNaID] = NULL,
 [Knt_RachunekNr] = N'',
 [Knt_IBAN] = 0,
 [Knt_OsTytul] = N'',
 [Knt_OsPlec] = 0,
 [Knt_OsNazwisko] = N'',
 [Knt_OsKraj] = N'',
 [Knt_OsWojewodztwo] = N'',
 [Knt_OsPowiat] = N'',
 [Knt_OsGmina] = N'',
 [Knt_OsUlica] = N'',
 [Knt_OsNrDomu] = N'',
 [Knt_OsNrLokalu] = N'',
 [Knt_OsMiasto] = N'',
 [Knt_OsKodPocztowy] = '',
 [Knt_OsPoczta] = N'',
 [Knt_OsAdres2] = N'',
 [Knt_OsTelefon] = N'',
 [Knt_OsGSM] = '',
 [Knt_OsEmail] = N'',
 [Knt_Informacje] = 0,
 [Knt_Ceny] = 0,
 [Knt_Upust] = 0,
 [Knt_LimitFlag] = 0,
 [Knt_LimitKredytu] = 0,
 [Knt_LimitPrzeterKredytFlag] = 0,
 [Knt_LimitPrzeterKredytWartosc] = 0,
 [Knt_MaxZwloka] = 0,
 [Knt_TerminPlat] = 0,
 [Knt_Termin] = 0,
 [Knt_KontoOdb] = N'',
 [Knt_KontoDost] = N'',
 [Knt_KatID] = NULL,
 [Knt_KatZakID] = NULL,
 [Knt_BlokadaDok] = 0,
 [Knt_LimitKredytuWal] = '',
 [Knt_LimitKredytuWykorzystany] = 0,
 [Knt_NieRozliczac] = 0,
 [Knt_PodatekVat] = 0,
 [Knt_Finalny] = 0,
 [Knt_FinalnyWegiel] = 0,
 [Knt_Export] = 0,
 [Knt_Rodzaj] = 0,
 [Knt_Rodzaj_Dostawca] = 0,
 [Knt_Rodzaj_Odbiorca] = 0,
 [Knt_Rodzaj_Konkurencja] = 0,
 [Knt_Rodzaj_Partner] = 0,
 [Knt_Rodzaj_Potencjalny] = 0,
 [Knt_Medialny] = 0,
 [Knt_MalyPod] = 0,
 [Knt_Rolnik]= 0,
 [Knt_Nieaktywny] = 1,
 [Knt_Chroniony] = 0,
 [Knt_NieUwzglVATZD] = 0,
 [Knt_Opis] = N'',
 [Knt_OdbiorcaId] = NULL,
 [Knt_OpiekunTyp] = NULL,
 [Knt_OpiekunId] = NULL,
 [Knt_OpiekunKsiegTyp] = NULL,
 [Knt_OpiekunKsiegID] = NULL,
 [Knt_OpiekunKsiegDomyslny] =  NULL,
 [Knt_OpiekunPiKTyp] = NULL,
 [Knt_OpiekunPiKID] = NULL,
 [Knt_OpiekunPiKDomyslny] = NULL,
 [Knt_OpiekunDomyslny] = NULL,
 [Knt_TerminZwrotuKaucji] = 0,
 [Knt_NaliczajPlatnosc]  = 0,
 [Knt_ZakazDokumentowHaMag]  = 0,
 [Knt_ZgodaNaEFaktury] = 0,
 [Knt_TypWymiany] = NULL,
 [Knt_PowiazanyUoV] = 0,
 [Knt_MetodaKasowa] = 0,
 [Knt_UWDId] = NULL,
 [Knt_UWDOddzial] = NULL,
 [Knt_UWDEmail] = NULL,
 [Knt_TS_Export] = NULL,
 [Knt_ImportAppId] = NULL,
 [Knt_ImportRowId] = NEWID(),
 [Knt_TS_Mod] = GetDate(),
 [Knt_OpeModId] = @opeId,
 [Knt_OpeModKod] = @opeKod,
 [Knt_OpeModNazwisko] = @opeNazwisko,
 [Knt_FCzynnosci] = 0,
 [Knt_FCzesci] = 0,
 [Knt_KorKraj] = NULL,
 [Knt_KorMiasto] = NULL,
 [Knt_KorKodPocztowy] = NULL,
 [Knt_KorPoczta] = NULL,
 [Knt_KorUlica] = NULL,
 [Knt_KorNrDomu] =  NULL,
 [Knt_KorNrLokalu] = NULL,
 [Knt_NieNaliczajOdsetek] = 0,
 [Knt_ESklep] = 0,
 [Knt_ZwolnionyZAkcyzy] = 0,
 [Knt_WindykacjaSchematId] = NULL,
 [Knt_WindykacjaOsobaId] = NULL,
 [Knt_WindykacjaEMail] = N'',
 [Knt_WindykacjaTelefonSms] = '',
 [Knt_Komornik] = 0,
 [Knt_KomornikOkreg] = NULL,
 [Knt_KomornikMiasto] = NULL,
 [Knt_KomornikRewir] = NULL,
 [Knt_Waluta] = '',
 [Knt_Algorytm] = 0,
 [Knt_LoginComarchCloud] =  NULL,
 [Knt_CJBTyp] = NULL,
 [Knt_CJBId] = NULL,
 [Knt_SplitPay] = 0,
 [Knt_Domena] = N'',
 [Knt_DokumentTozsamosci] = N'',
 [Knt_UmowaWegiel] = 0
 WHERE Knt_KntId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1   EXEC [CDN].[RejestrOperacjiDodaj] 1103, 0, @id, @newKod, 212, '';
 UPDATE cdn.RejestrOperacji
 SET ROP_ObiektNazwa = @newKod
 WHERE ROP_ObiektTyp = 1103 AND ROP_ObiektID = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[KntScalHist] SET [KSH_NumerDok] = @newKod, [KSH_NewKntID] = NULL WHERE [KSH_NazwaTabeli] = 'cdn.KntKarty' AND [KSH_NewKntID] = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[PodmiotyView] SET
 [Pod_Kod] = @newKod,
 [Pod_Nazwa1] = @newNazwa ,
 [Pod_Nazwa2] = N'',
 [Pod_Nazwa3] = N'',
 [Pod_Kraj] = N'',
 [Pod_Wojewodztwo] = N'',
 [Pod_Powiat] = N'',
 [Pod_Gmina] = N'',
 [Pod_Ulica] = N'',
 [Pod_NrDomu] = N'',
 [Pod_NrLokalu] = N'',
 [Pod_Miasto] = N'',
 [Pod_KodPocztowy] = '',
 [Pod_Poczta] = N'',
 [Pod_Telefon1] = '',
 [Pod_Telefon2] = '',
 [Pod_TelefonSms] = '',
 [Pod_Adres2] = N'',
 [Pod_Email] = N'',
 [Pod_Nieaktywny] = 1,
 [Pod_Rodzaj] = 0,
 [Pod_RodzajOpis] = N'',
 [Pod_Grupa] = '',
 [Pod_NipKraj] = '',
 [Pod_NIP] = N'',
 [Pod_Regon] = '',
 [Pod_Pesel]  = N'',
 [Pod_LimitKredytu] = 0,
 [Pod_ImportRowId] = '',
 [Pod_KontoOdb] = N'',
 [Pod_KontoDost]= N'',
 [Pod_GlKod] = @newKod,
 [Pod_GlNazwa12] = @newNazwa
 WHERE [Pod_PodmiotTyp]=1 AND [Pod_PodId]=@id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.KntAtrybuty WHERE KnA_PodmiotTyp=1 AND KnA_PodmiotId=@id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.TwrKntAtrybuty WHERE TKA_PodmiotTyp = 1 AND TKA_PodmiotId = @id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.Rabaty WHERE Rab_PodmiotTyp=1 AND Rab_PodmiotId=@id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.KntESklepy WHERE KES_KntID = @id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.RejestrUpowaznien WHERE RUP_PodmiotTyp=1 AND RUP_PodID=@id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM CDN.PodmiotRejestracjaZgod WHERE PRZ_PodmiotTyp=1 AND PRZ_PodmiotID=@id
 IF @@ERROR > 0 GOTO KONIEC
 IF COL_LENGTH('cdn.KntESklepyPrzedstawiciele', 'KESP_NieAktywny') IS NOT NULL
 BEGIN
        DECLARE @sqltxt NVARCHAR(512)
        DECLARE @paramDefinition NVARCHAR(32)
        SET @paramDefinition = N'@anonimKod varchar(20) OUTPUT';
  SET @sqltxt = N'UPDATE [CDN].[KntESklepyPrzedstawiciele] SET [KESP_Domyslny] = 0,[KESP_NieAktywny] = 1,[KESP_Email] = N'''',[KESP_Nazwisko] = @anonimKod WHERE [KESP_KntID] = ' + Convert(nvarchar(20), @id)
        EXEC sp_executeSql @sqltxt, @paramDefinition, @anonimKod=@newKod
  IF @@ERROR > 0 GOTO KONIEC
 END
 UPDATE [CDN].[SenditZleceniePrzesylki] SET
 [SZL_OdbNazwa] = @newNazwa,
 [SZL_OdbUlica] = N'',
 [SZL_OdbNrDomu] = N'',
 [SZL_OdbNrLokalu] = N'',
 [SZL_OdbMiasto] = N'',
 [SZL_OdbKodPocztowy] = N'',
 [SZL_OdbTelefon] = '',
 [SZL_OdbEmail] = N'',
 [SZL_Odebral] = N'',
 [SZL_OpeModID] = @opeId,
 [SZL_TS_Mod] = GetDate(),
 [SZL_OpeModKod]= @opeKod,
 [SZL_OpeModNazwisko] = @opeNazwisko
 WHERE SZL_OdbiorcaTyp=1 AND SZL_OdbID = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 370, NULL, SZL_SZLId, SZL_NumerPelny, GetDate(), @opeNazwisko, 212, N''
  FROM CDN.[SenditZleceniePrzesylki] WHERE SZL_OdbiorcaTyp=1 AND SZL_OdbID = @id
 END
 UPDATE [CDN].[DetalStanKontrahenci] SET
 [DSKnt_Kod] = @newKod,
 [DSKnt_EAN] = '',
 [DSKnt_Nazwa1] = @newNazwa,
 [DSKnt_Nazwa2] = N'',
 [DSKnt_Nazwa3] = N'',
 [DSKnt_Kraj] = N'',
 [DSKnt_Wojewodztwo] = N'',
 [DSKnt_Powiat] = N'',
 [DSKnt_Gmina] = N'',
 [DSKnt_Ulica] = N'',
 [DSKnt_NrDomu] = N'',
 [DSKnt_NrLokalu] = N'',
 [DSKnt_Miasto] = N'',
 [DSKnt_KodPocztowy] = '',
 [DSKnt_Poczta] = N'',
 [DSKnt_Adres2] = N'',
 [DSKnt_NipKraj] = '',
 [DSKnt_NipE] = N'',
 [DSKnt_Nip] = N'',
 [DSKnt_Regon] = '',
 [DSKnt_Pesel] = N'',
 [DSKnt_NieAktywny] = 1,
 [DSKnt_Telefon] = '',
 [DSKnt_Opis] = N'',
 [DSKnt_OsobaOdbierajaca] = N'',
 [DSKnt_TS_Mod] = GetDate(),
 [DSKnt_OpeID] = @opeId
 WHERE DSKnt_OptimaId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[DetalKontrahenci] SET
 [DKnt_Kod] = @newKod,
 [DKnt_EAN] = '',
 [DKnt_Nazwa1] = @newNazwa,
 [DKnt_Nazwa2] = N'',
 [DKnt_Nazwa3] = N'',
 [DKnt_Kraj] = N'',
 [DKnt_Wojewodztwo] = N'',
 [DKnt_Powiat] = N'',
 [DKnt_Gmina] = N'',
 [DKnt_Ulica] = N'',
 [DKnt_NrDomu] = N'',
 [DKnt_NrLokalu] = N'',
 [DKnt_Miasto] = N'',
 [DKnt_KodPocztowy] = '',
 [DKnt_Poczta] = N'',
 [DKnt_Adres2] = N'',
 [DKnt_NipKraj] = '',
 [DKnt_NipE] = N'',
 [DKnt_Nip]  = N'',
 [DKnt_Regon] = '',
 [DKnt_Pesel] = N'',
 [DKnt_Telefon] = '',
 [DKnt_Opis] = N'',
 [DKnt_OsobaOdbierajaca] = N'',
 [DKnt_TS_Mod] = GetDate(),
 [DKnt_OpeID] = @opeId,
 [DKnt_Telefon1] = '',
 [DKnt_eMail] = '',
 [DKnt_URL] = '',
 [DKnt_Fax] = ''
 WHERE DKnt_OptimaId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE cdn.Konta SET
 Acc_NieAktywne = 1,
 Acc_Nazwa = @newNazwa,
 Acc_Nazwa2 = N''
 WHERE Acc_SlownikTyp = 1 AND Acc_SlownikId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
  INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 450, NULL, Acc_AccId, Acc_Numer, GetDate(), @opeNazwisko, 212, N'' FROM CDN.Konta WHERE Acc_SlownikTyp = 1 AND Acc_SlownikId = @id
 END
 IF @rejestrOperacji = 1
 BEGIN
  INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 25000, NULL, SPL_SPLId, SPL_RachunekNr, GetDate(), @opeNazwisko, 212, N'' FROM CDN.SchematPlatnosci WHERE  SPL_PodmiotTyp=1 AND SPL_PodmiotId=@id
 END
 DELETE FROM cdn.SchematPlatnosci WHERE SPL_PodmiotTyp=1 AND SPL_PodmiotId=@id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 1103, NULL, Knt_KntId, Knt_Kod, GetDate(), @opeNazwisko, 212, N''
  FROM CDN.Kontrahenci JOIN cdn.KntOdbiorcy ON Knt_KntId = Odb_KntOdbID AND Odb_OdbKntID = @id
 END
 UPDATE k SET
  k.Knt_OdbiorcaId = NULL,
  k.[Knt_TS_Mod] = GetDate(),
  k.[Knt_OpeModId] = @opeId,
  k.[Knt_OpeModKod] = @opeKod,
  k.[Knt_OpeModNazwisko] = @opeNazwisko
 FROM [CDN].Kontrahenci k JOIN cdn.KntOdbiorcy ON k.Knt_KntId = Odb_KntOdbID AND Odb_OdbKntID = @id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.KntOdbiorcy WHERE Odb_OdbKntID = @id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.KntOdbiorcy WHERE Odb_KntOdbID = @id
 IF @@ERROR > 0 GOTO KONIEC
 DECLARE @nazwisko NVARCHAR(40), @knOId INT
 WHILE(@id > 0)
 BEGIN
  SET @knOId = 0
  SELECT TOP 1 @knOId = KnO_KnOId, @nazwisko = KnO_Nazwisko FROM cdn.KntOsoby WHERE KnO_KntId = @id AND (KnO_LpAnonimizacji IS NULL OR KnO_LpAnonimizacji=0)
  IF @knOId = 0 BREAK
  EXEC CDN.AnonimizujPrzedstawiciela @knOId, @opeId, @opeKod, @opeNazwisko, 0, @errorcount OUTPUT
  IF @errorcount > 0 GOTO KONIEC
 END
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM CDN.KntWeryfStatHist  WHERE KWSH_KntID = @id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.WdrKopieElektroniczne WHERE WdKE_ObjSubjectType = 1 AND WdKE_ObjSubjectId = @id
 IF @@ERROR > 0 GOTO KONIEC
 DELETE FROM cdn.Rabaty WHERE Rab_PodmiotTyp = 1 AND Rab_PodmiotId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE cdn.Towary SET
 Twr_KodDostawcy = N'',
 Twr_KntId = NULL
 WHERE Twr_KntId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE  [CDN].[IntrastatNag] SET
 [IsN_ZglNazwa1] = @newNazwa,
 [IsN_ZglNazwa2] = N'',
 [IsN_ZglNazwa3] = N'',
 [IsN_ZglKraj] = N'',
 [IsN_ZglWojewodztwo] = N'',
 [IsN_ZglPowiat] = N'',
 [IsN_ZglGmina] = N'',
 [IsN_ZglUlica] = N'',
 [IsN_ZglNrDomu] = N'',
 [IsN_ZglNrLokalu] = N'',
 [IsN_ZglMiasto] = N'',
 [IsN_ZglKodPocztowy] = '',
 [IsN_ZglPoczta] = N'',
 [IsN_ZglAdres2] = N'',
 [IsN_ZglRegon]  = '',
 [IsN_ZglNipKraj]  = '',
 [IsN_ZglNipE]  = N'',
 [IsN_TS_Mod] = GetDate(),
 [IsN_OpeModId] = @opeId,
 [IsN_OpeModKod] = @opeKod,
 [IsN_OpeModNazwisko] = @opeNazwisko
 WHERE  [IsN_ZglTyp] = 1 AND [IsN_ZglId] = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 100, NULL, IsN_IsNId, IsN_Numer, GetDate(), @opeNazwisko, 212, N'' FROM CDN.[IntrastatNag] WHERE  [IsN_ZglTyp] = 1 AND [IsN_ZglId] = @id
 END
 UPDATE cdn.TraNag SET
  [TrN_PodNazwa1] = @newNazwa,
  [TrN_PodNazwa2] = N'',
  [TrN_PodNazwa3] = N'',
  [TrN_PodKraj] = N'',
  [TrN_PodWojewodztwo] = N'',
  [TrN_PodPowiat] = N'',
  [TrN_PodGmina] = N'',
  [TrN_PodUlica] = N'',
  [TrN_PodNrDomu] = N'',
  [TrN_PodNrLokalu] = N'',
  [TrN_PodMiasto] = N'',
  [TrN_PodKodPocztowy] = '',
  [TrN_PodPoczta] = N'',
  [TrN_PodAdres2] = N'',
  [TrN_PodNipKraj] = '',
  [TrN_PodNipE] = N'',
  [TrN_PodmiotGLN] = '',
  [TrN_Pesel] = N'',
  [TrN_Odebral] = N'',
  [TrN_DokumentTozsamosci] = N'',
  [TrN_TS_Mod] = GetDate(),
  [TrN_OpeModID] = @opeId,
  [TrN_OpeModKod] = @opeKod,
  [TrN_OpeModNazwisko] = @opeNazwisko
 WHERE  TrN_PodmiotTyp = 1 AND TrN_PodId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE cdn.TraNag SET
  [TrN_OdbNazwa1] = @newNazwa,
  [TrN_OdbNazwa2] = N'',
  [TrN_OdbNazwa3] = N'',
  [TrN_OdbKraj] = N'',
  [TrN_OdbWojewodztwo] = N'',
  [TrN_OdbPowiat] = N'',
  [TrN_OdbGmina] = N'',
  [TrN_OdbUlica] = N'',
  [TrN_OdbNrDomu] = N'',
  [TrN_OdbNrLokalu] = N'',
  [TrN_OdbMiasto] = N'',
  [TrN_OdbKodPocztowy] = '',
  [TrN_OdbPoczta] = N'',
  [TrN_OdbAdres2] = N'',
  [TrN_OdbNipKraj] = '',
  [TrN_OdbNipE] = N'',
  [TrN_OdbiorcaGLN] = '',
  [TrN_OdbTelefon] = '',
  [TrN_OdbEmail] = N'',
  [TrN_Odebral] = N'',
  [TrN_TS_Mod] = GetDate(),
  [TrN_OpeModID] = @opeId,
  [TrN_OpeModKod] = @opeKod,
  [TrN_OpeModNazwisko] = @opeNazwisko
 WHERE TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id AND TrN_TypDokumentu IN (301,302,305,306,307,308,309,313,314,320)
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT TrN_TypDokumentu, NULL, TrN_TrNId, TrN_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM CDN.TraNag
  WHERE ((TrN_PodmiotTyp = 1 AND TrN_PodId = @id)
   OR (TrN_TypDokumentu IN (301,302,305,306,307,308,309,313,314,320) AND (TrN_OdbiorcaTyp=1 AND TrN_OdbId = @id)))
   OR ((TrN_PlatnikTyp = 1 AND TrN_PlatnikId = @id) OR (TrN_PodmiotZalTyp=1 AND TrN_PodZalId = @id))
   OR (TrN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
         OR TrN_TrNId IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=1 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)))
 END
 UPDATE cdn.OfertyKnt SET
  [OfK_Kod] = @newKod,
  [OfK_PodNazwa1] = @newNazwa,
  [OfK_PodNazwa2] = N'',
  [OfK_PodNazwa3] = N'',
  [OfK_PodKraj] = N'',
  [OfK_PodWojewodztwo] = N'',
  [OfK_PodPowiat] = N'',
  [OfK_PodGmina] = N'',
  [OfK_PodUlica] = N'',
  [OfK_PodNrDomu] = N'',
  [OfK_PodNrLokalu] = N'',
  [OfK_PodMiasto] = N'',
  [OfK_PodKodPocztowy] = '',
  [OfK_PodPoczta] = N'',
  [OfK_PodAdres2] = N'',
  [OfK_PodNipKraj] = '',
  [OfK_PodNipE] = N'',
  [OfK_PodmiotGLN] = '',
  [OfK_PodEmail] = N''
 WHERE OfK_PodmiotTyp=1 AND OfK_PodID = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 800, NULL, OfD_OfDId, OfD_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM cdn.OfertyKnt JOIN cdn.OfertyDok ON OfK_OfDId = OfD_OfDId WHERE OfK_PodmiotTyp=1 AND OfK_PodID = @id
 END
 UPDATE CDN.VatNag  SET
  [VaN_KntNazwa1] = @newNazwa,
  [VaN_KntNazwa2] = N'',
  [VaN_KntNazwa3] = N'',
  [VaN_KntKraj] = N'',
  [VaN_KntWojewodztwo] = N'',
  [VaN_KntPowiat] = N'',
  [VaN_KntGmina] = N'',
  [VaN_KntUlica] = N'',
  [VaN_KntNrDomu] = N'',
  [VaN_KntNrLokalu] = N'',
  [VaN_KntMiasto] = N'',
  [VaN_KntKodPocztowy] = '',
  [VaN_KntPoczta] = N'',
  [VaN_KntAdres2] = N'',
  [VaN_KntNipKraj] = '',
  [VaN_KntNipE] = N'',
  [VaN_Pesel] = N'',
  [VaN_TS_Mod] = GetDate(),
  [VaN_OpeModId] = @opeId,
  [VaN_OpeModKod] = @opeKod,
  [VaN_OpeModNazwisko] = @opeNazwisko
 WHERE VaN_PodmiotTyp=1 AND VaN_PodID = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.VatNag  SET
  [VaN_PlatnikKraj] = N'',
  [VaN_PlatnikWojewodztwo] = N'',
  [VaN_PlatnikPowiat] = N'',
  [VaN_PlatnikGmina] = N'',
  [VaN_PlatnikUlica] = N'',
  [VaN_PlatnikNrDomu] = N'',
  [VaN_PlatnikNrLokalu] = N'',
  [VaN_PlatnikMiasto] = N'',
  [VaN_PlatnikKodPocztowy] = N'',
  [VaN_PlatnikPoczta] = N'',
  [VaN_PlatnikAdres2] = N'',
  [VaN_PlatnikNazwa1] = @newNazwa,
  [VaN_PlatnikNazwa2] = N'',
  [VaN_PlatnikNazwa3] = N'',
  [Van_PlatnikRachunekNr] = N'',
  [VaN_PlatnikRachunekLp] = NULL,
  [VaN_TS_Mod] = GetDate(),
  [VaN_OpeModId] = @opeId,
  [VaN_OpeModKod] = @opeKod,
  [VaN_OpeModNazwisko] = @opeNazwisko
 WHERE VaN_PlatnikTyp=1 AND VaN_PlatnikID = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 999, VaN_Typ, VaN_VaNId, VaN_Dokument, GetDate(), @opeNazwisko, 212, N'' FROM cdn.VatNag
  WHERE ((VaN_PodmiotTyp=1 AND VaN_PodID = @id) OR (VaN_PlatnikTyp=1 AND VaN_PlatnikID = @id) OR (VaN_PodmiotZalTyp=1 AND VaN_PodZalId = @id)
   OR (VaN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
   OR (VaN_VaNID IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=2 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id))))
  )
 END
 UPDATE CDN.EwidDodNag  SET
  [EDN_Nazwa1] = @newNazwa,
  [EDN_Nazwa2] = N'',
  [EDN_Nazwa3] = N'',
  [EDN_Kraj] = N'',
  [EDN_Wojewodztwo] = N'',
  [EDN_Powiat] = N'',
  [EDN_Gmina] = N'',
  [EDN_Ulica] = N'',
  [EDN_NrDomu] = N'',
  [EDN_NrLokalu] = N'',
  [EDN_Miasto] = N'',
  [EDN_KodPocztowy] = '',
  [EDN_Poczta] = N'',
  [EDN_Adres2] = N'',
  [EDN_NipKraj] = '',
  [EDN_NipE] = N'',
  [EDN_TS_Mod] = GetDate(),
  [EDN_OpeModId] = @opeId,
  [EDN_OpeModKod] = @opeKod,
  [EDN_OpeModNazwisko] = @opeNazwisko
 WHERE  (EdN_PodmiotTyp=1 AND EdN_PodID = @id)
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.EwidDodNag  SET
  [EDN_PlatnikKraj] = N'',
  [EDN_PlatnikWojewodztwo] = N'',
  [EDN_PlatnikPowiat] = N'',
  [EDN_PlatnikGmina] = N'',
  [EDN_PlatnikUlica] = N'',
  [EDN_PlatnikNrDomu] = N'',
  [EDN_PlatnikNrLokalu] = N'',
  [EDN_PlatnikMiasto] = N'',
  [EDN_PlatnikKodPocztowy] = N'',
  [EDN_PlatnikPoczta] = N'',
  [EDN_PlatnikAdres2] = N'',
  [EDN_PlatnikNazwa1]  = @newNazwa,
  [EDN_PlatnikNazwa2] = N'',
  [EDN_PlatnikNazwa3] = N'',
  [EDN_PlatnikRachunekNr] = N'',
  [EDN_PlatnikRachunekLp] = NULL,
  [EDN_TS_Mod] = GetDate(),
  [EDN_OpeModId] = @opeId,
  [EDN_OpeModKod] = @opeKod,
  [EDN_OpeModNazwisko] = @opeNazwisko
 WHERE  (EdN_PlatnikTyp=1 AND EdN_PlatnikID = @id)
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 1003, EDN_Typ, EdN_EdNId, EdN_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM cdn.EwidDodNag
  WHERE ( EdN_PodmiotTyp=1 AND EdN_PodID = @id )
       OR (EdN_PlatnikTyp=1 AND EdN_PlatnikID = @id)
       OR (EdN_PodmiotZalTyp=1 AND EdN_PodZalId = @id)
       OR (EdN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
       OR (EdN_EdNID IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=12 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id))))
 END
 UPDATE CDN.BnkZapisy SET
   BZp_Nazwa1 = @newNazwa,
   BZp_Nazwa2 = N'',
   BZp_Nazwa3 = N'',
   BZp_Kraj = N'',
   BZp_Wojewodztwo = N'',
   BZp_Powiat = N'',
   BZp_Gmina = N'',
   BZp_Ulica = N'',
   BZp_NrDomu = N'',
   BZp_NrLokalu = N'',
   BZp_Miasto = N'',
   BZp_KodPocztowy = '',
   BZp_Poczta = N'',
   BZp_Adres2 = N'',
   BZp_RachunekNr = N'',
   BZp_PodmiotRachunekLp = 0,
   BZp_BNaID = NULL,
   [BZp_KKrID] = NULL,
   BZp_KartaNr = N'',
  [BZp_TS_Mod] = GetDate(),
  [BZp_OpeModId] = @opeId,
  [BZp_OpeModKod] = @opeKod,
  [BZp_OpeModNazwisko] = @opeNazwisko
 WHERE BzP_PodmiotTyp=1 AND BzP_PodmiotID = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 1000, NULL, BzP_BZPId, BzP_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM cdn.BnkZapisy WHERE  BzP_PodmiotTyp=1 AND BzP_PodmiotID = @id
 END
 UPDATE [CDN].[BnkZdarzenia] SET
 [BZd_PodmiotRachunekLp] = 0,
 [BZd_BNaID] = NULL,
 [BZd_RachunekNr] = N'',
 [BZd_OpeModId] = @opeId,
 [BZd_TS_Mod] = GetDate(),
 [BZd_OpeModKod] = @opeKod,
 [BZd_OpeModNazwisko]= @opeNazwisko
 WHERE BZd_PodmiotTyp=1 AND BZd_PodmiotID = @id
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 1001, NULL, BzD_BZDId, BzD_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM cdn.[BnkZdarzenia] WHERE BZd_PodmiotTyp=1 AND BZd_PodmiotID = @id
 END
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.ZapisyKPR  SET
  [KPR_KntNazwa1] = @newNazwa,
  [KPR_KntNazwa2] = N'',
  [KPR_KntNazwa3] = N'',
  [KPR_KntKraj] = N'',
  [KPR_KntWojewodztwo] = N'',
  [KPR_KntPowiat] = N'',
  [KPR_KntGmina] = N'',
  [KPR_KntUlica] = N'',
  [KPR_KntNrDomu] = N'',
  [KPR_KntNrLokalu] = N'',
  [KPR_KntMiasto] = N'',
  [KPR_KntKodPocztowy] = '',
  [KPR_KntPoczta] = N'',
  [KPR_KntAdres2] = N'',
  [KPR_KntNipKraj] = '',
  [KPR_KntNipE] = N'',
  [KPR_TS_Mod] = GetDate(),
  [KPR_OpeModId] = @opeId,
  [KPR_OpeModKod] = @opeKod,
  [KPR_OpeModNazwisko] = @opeNazwisko
 WHERE KPR_PodmiotTyp=1 AND KPR_PodID = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 1008, NULL, KPR_KpRId, KPR_Dokument, GetDate(), @opeNazwisko, 212, N'' FROM cdn.ZapisyKPR  WHERE KPR_PodmiotTyp=1 AND KPR_PodID = @id
 END
 UPDATE CDN.SentZgloszenia  SET
  Sent_PodNazwa = @newNazwa,
  Sent_PodUlica = N'',
  Sent_PodNrDomu = N'',
  Sent_PodNrLokalu = N'',
  Sent_PodMiasto = N'',
  Sent_PodKodPocztowy = N'',
  Sent_PodNipKraj = '',
  Sent_PodNipE = N'',
  Sent_PodKraj = N'',
  [Sent_TS_Mod] = GetDate(),
  [Sent_OpeModId] = @opeId,
  [Sent_OpeModKod] = @opeKod,
  [Sent_OpeModNazwisko] = @opeNazwisko
 WHERE Sent_PodmiotTyp=1 AND Sent_PodID = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 351, NULL, Sent_SentID, Sent_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM cdn.SentZgloszenia WHERE Sent_PodmiotTyp=1 AND Sent_PodID = @id
 END
 UPDATE CDN.SrsZlecenia  SET
  [SrZ_PodNazwa1] = @newNazwa,
  [SrZ_PodNazwa2] = N'',
  [SrZ_PodNazwa3] = N'',
  [SrZ_PodKraj] = N'',
  [SrZ_PodWojewodztwo] = N'',
  [SrZ_PodPowiat] = N'',
  [SrZ_PodGmina] = N'',
  [SrZ_PodUlica] = N'',
  [SrZ_PodNrDomu] = N'',
  [SrZ_PodNrLokalu] = N'',
  [SrZ_PodMiasto] = N'',
  [SrZ_PodKodPocztowy] = '',
  [SrZ_PodPoczta] = N'',
  [SrZ_PodAdres2] = N'',
  [SrZ_Telefon] = '',
  [SrZ_Email] = N'',
  [SrZ_TS_Mod] = GetDate(),
  [SrZ_OpeModId] = @opeId,
  [SrZ_OpeModKod] = @opeKod,
  [SrZ_OpeModNazwisko] = @opeNazwisko
 WHERE SrZ_PodmiotTyp = 1 AND SrZ_PodmiotId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.SrsZlecenia  SET
  [SrZ_OdbNazwa1] = @newNazwa,
  [SrZ_OdbNazwa2] = N'',
  [SrZ_OdbNazwa3] = N'',
  [SrZ_OdbKraj] = N'',
  [SrZ_OdbWojewodztwo] = N'',
  [SrZ_OdbPowiat] = N'',
  [SrZ_OdbGmina] = N'',
  [SrZ_OdbUlica] = N'',
  [SrZ_OdbNrDomu] = N'',
  [SrZ_OdbNrLokalu] = N'',
  [SrZ_OdbMiasto] = N'',
  [SrZ_OdbKodPocztowy] = '',
  [SrZ_OdbPoczta] = N'',
  [SrZ_OdbAdres2] = N'',
  [SrZ_OdbTelefon] = '',
  [SrZ_OdbEmail] = N'',
  [SrZ_TS_Mod] = GetDate(),
  [SrZ_OpeModId] = @opeId,
  [SrZ_OpeModKod] = @opeKod,
  [SrZ_OpeModNazwisko] = @opeNazwisko
 WHERE SrZ_OdbiorcaTyp=1 AND SrZ_OdbId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 900, NULL, SrZ_SrZId, SrZ_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM CDN.SrsZlecenia WHERE ((SrZ_PodmiotTyp = 1 AND SrZ_PodmiotId = @id) OR (SrZ_OdbiorcaTyp=1 AND SrZ_OdbId = @id))
 END
 UPDATE CDN.SrsCyklNag  SET
  [SrW_PodNazwa1] = @newNazwa,
  [SrW_PodNazwa2] = N'',
  [SrW_PodNazwa3] = N'',
  [SrW_PodKraj] = N'',
  [SrW_PodWojewodztwo] = N'',
  [SrW_PodPowiat] = N'',
  [SrW_PodGmina] = N'',
  [SrW_PodUlica] = N'',
  [SrW_PodNrDomu] = N'',
  [SrW_PodNrLokalu] = N'',
  [SrW_PodMiasto] = N'',
  [SrW_PodKodPocztowy] = '',
  [SrW_PodPoczta] = N'',
  [SrW_PodAdres2] = N'',
  [SrW_Telefon] = '',
  [SrW_Email] = N'',
  [SrW_TS_Mod] = GetDate(),
  [SrW_OpeModId] = @opeId,
  [SrW_OpeModKod] = @opeKod,
  [SrW_OpeModNazwisko] = @opeNazwisko
 WHERE SrW_PodmiotTyp = 1 AND SrW_PodmiotId = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.SrsCyklNag  SET
  [SrW_OdbNazwa1] = @newNazwa,
  [SrW_OdbNazwa2] = N'',
  [SrW_OdbNazwa3] = N'',
  [SrW_OdbKraj] = N'',
  [SrW_OdbWojewodztwo] = N'',
  [SrW_OdbPowiat] = N'',
  [SrW_OdbGmina] = N'',
  [SrW_OdbUlica] = N'',
  [SrW_OdbNrDomu] = N'',
  [SrW_OdbNrLokalu] = N'',
  [SrW_OdbMiasto] = N'',
  [SrW_OdbKodPocztowy] = '',
  [SrW_OdbPoczta] = N'',
  [SrW_OdbAdres2] = N'',
  [SrW_OdbTelefon] = '',
  [SrW_OdbEmail] = N'',
  [SrW_TS_Mod] = GetDate(),
  [SrW_OpeModId] = @opeId,
  [SrW_OpeModKod] = @opeKod,
  [SrW_OpeModNazwisko] = @opeNazwisko
 WHERE SrW_OdbiorcaTyp=1 AND SrW_OdbId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 906, NULL, SrW_SrWId, SrW_Kod, GetDate(), @opeNazwisko, 212, N'' FROM CDN.SrsCyklNag WHERE ((SrW_PodmiotTyp = 1 AND SrW_PodmiotId = @id) OR (SrW_OdbiorcaTyp=1 AND SrW_OdbId = @id))
 END
 UPDATE FC SET
  FCT_NabywcaKod = @newKod,
  FCT_NabywcaNazwa = @newNazwa
 FROM cdn.FaCyklTwrKnt FC JOIN cdn.FaCyklKnt ON FC.FCT_FCKId = FCK_FCKId AND FCK_PodmiotTyp=1 AND FCK_PodmiotID=@id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE FC SET
  FCT_OdbiorcaKod = @newKod,
  FCT_OdbiorcaNazwa = @newNazwa
 FROM cdn.FaCyklTwrKnt FC JOIN cdn.FaCyklKnt ON FC.FCT_FCKId = FCK_FCKId AND FCK_OdbiorcaTyp=1 AND FCK_OdbiorcaID=@id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE cdn.FaCyklKnt SET
  FCK_Kod = @newKod,
  FCK_Nazwa = @newNazwa
 WHERE FCK_PodmiotTyp=1 AND FCK_PodmiotID=@id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE cdn.FaCyklKnt SET
  FCK_OdbiorcaKod = @newKod,
  FCK_OdbiorcaNazwa = @newNazwa
 WHERE FCK_OdbiorcaTyp=1 AND FCK_OdbiorcaID=@id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
  INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 900, NULL, FcN_FcNId, FcN_Kod, GetDate(), @opeNazwisko, 212, N'' FROM cdn.FaCyklNag JOIN cdn.FaCyklKnt  ON FCN_FcNID = FCK_FcNID WHERE (FCK_PodmiotTyp=1 AND FCK_PodmiotID=@id) OR (FCK_OdbiorcaTyp=1 AND FCK_OdbiorcaID=@id)
 END
 IF @rejestrOperacji = 1
 BEGIN
  SELECT DISTINCT 714, NULL, AnkWaN_AnkWaNId, AnkWaN_Kod, GetDate(), @opeNazwisko, 212, N''
  FROM cdn.AnkWzorzecAnkietyNag JOIN cdn.AnkWzorzecAnkietyAnkietowani ON AnkWaN_AnkWaNId = AnkWaA_AnkWaNId WHERE AnkWaA_PodmiotTyp = 1 AND [AnkWaA_PodID] = @id
 END
 DELETE FROM CDN.AnkWzorzecAnkietyAnkietowani WHERE AnkWaA_PodmiotTyp = 1 AND [AnkWaA_PodID] = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 710, NULL, AnkAnN_AnkAnNId, AnkAnN_NumerPelny, GetDate(), @opeNazwisko, 212, N''
  FROM cdn.AnkAnkietyNag WHERE AnkAnN_PodmiotTyp = 1 AND AnkAnN_PodID = @id
 END
 UPDATE cdn.FormyPlatnosci SET
 FPl_PodmiotTyp = NULL,
 FPl_PodmiotID = NULL
 WHERE FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.[CRMKontakty] SET
 [CRK_OsobaNazwisko] = N'',
 [CrK_AutomatycznePrzypomnieniaEmailAdres] = N'',
 [CrK_AutomatycznePrzypomnieniaSmsNumerTelefonu] = N'',
 [CRK_OpeModID] = @opeId,
 [CRK_TS_Mod] =GetDate(),
 [CRK_OpeModKod] = @opeKod,
 [CRK_OpeModNazwisko] = @opeNazwisko
 WHERE CrK_PodmiotTyp=1 AND CrK_PodID = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 700, NULL, CrK_CrKId, CrK_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM cdn.CrmKontakty WHERE CrK_PodmiotTyp=1 AND CrK_PodID = @id
 END
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 750, NULL, DoN_DoNId, DoN_NumerPelny, GetDate(), @opeNazwisko, 212, N'' FROM cdn.DokNag JOIN cdn.DokPodmioty ON DoN_DonId = DoP_DoNID WHERE DoP_PodmiotTyp=1 AND DoP_PodmiotID = @id
 END
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 30011, NULL, DkN_DkNId, LTrim(Str(DkN_RokMiesiac)), GetDate(), @opeNazwisko, 212, N''
     FROM cdn.DeklNag LEFT OUTER JOIN CDN.DeklVUEK ON DkN_DkNID = DVU_DkNID AND DVU_NIP = @nipKnt AND @nipKnt <> N''
  WHERE (DkN_TypDeklar IN(11, 22))  AND DVU_NIP IS NOT NULL
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 30011, NULL, DkN_DkNId, LTrim(Str(DkN_RokMiesiac)), GetDate(), @opeNazwisko, 212, N''
     FROM cdn.DeklNag JOIN CDN.DeklElem  ON (DkN_DkNID = DkE_DkNID)
  WHERE DkN_TypDeklar IN (11, 22) AND DkE_Opis Like N'Numer VAT kontrahenta%' AND DkE_WartoscTekst = @nipKnt AND @nipKnt <> N''
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 30011, NULL, DkN_DkNId, LTrim(Str(DkN_RokMiesiac)), GetDate(), @opeNazwisko, 212, N''
  FROM cdn.DeklNag JOIN cdn.DeklWydr ON (DkN_DkNID = DkW_DkNID)
  WHERE DkN_TypDeklar IN (11, 22) AND DkW_Opis Like N'Numer VAT kontrahenta%' AND DkW_Wartosc = @nipKnt AND @nipKnt <> N''
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 30033, NULL, DkN_DkNId, LTrim(Str(DkN_RokMiesiac)), GetDate(), @opeNazwisko, 212, N''
     FROM cdn.DeklNag LEFT OUTER JOIN CDN.DeklV27 ON DkN_DkNID = V27_DkNID AND V27_NIP = @nipKnt  AND @nipKnt <> N''
  WHERE (DkN_TypDeklar IN(33, 34))  AND V27_NIP IS NOT NULL
 END
 UPDATE CDN.DeklV27 SET V27_NIP = N'', V27_Nazwa = @newNazwa WHERE V27_NIP = @nipKnt AND V27_NIP IS NOT NULL  AND @nipKnt <> N''
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE CDN.DeklVUEK SET DVU_NIP = N''  WHERE DVU_NIP = @nipKnt AND DVU_NIP IS NOT NULL AND @nipKnt <> N''
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE e
 SET DkE_WartoscTekst = N''
 FROM CDN.DeklElem e JOIN CDN.DeklNag ON (DkN_DkNID = DkE_DkNID)
 WHERE DkN_TypDeklar IN (11, 22) AND DkE_Opis Like N'Numer VAT kontrahenta%' AND DkE_WartoscTekst = @nipKnt AND @nipKnt <> N''
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE e
 SET DkW_Wartosc = N''
 FROM CDN.DeklWydr e JOIN CDN.DeklNag ON (DkN_DkNID = DkW_DkNID)
 WHERE DkN_TypDeklar IN (11, 22) AND DkW_Opis Like N'Numer VAT kontrahenta%' AND DkW_Wartosc = @nipKnt AND @nipKnt <> N''
 IF @@ERROR > 0 GOTO KONIEC
 UPDATE [CDN].[RejestrNaruszen] SET
 [RUN_Akronim] = @newKod,
 [RUN_ImieNazwisko] = N'',
 [RUN_OpeModID] = @opeId,
 [RUN_TS_Mod] =GetDate(),
 [RUN_OpeModKod] = @opeKod,
 [RUN_OpeModNazwisko] = @opeNazwisko
 WHERE RUN_PodmiotTyp = 1 AND RUN_PodId = @id
 IF @@ERROR > 0 GOTO KONIEC
 IF @rejestrOperacji = 1
 BEGIN
     INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
  SELECT DISTINCT 1801, NULL, RUN_RUNId,  CAST(RUN_CharakterNaruszenia AS  NVARCHAR(100)), GetDate(), @opeNazwisko, 212, N'' FROM cdn.[RejestrNaruszen] WHERE RUN_PodmiotTyp = 1 AND RUN_PodId = @id
 END
KONIEC:
 IF @@TRANCOUNT <> 0
 BEGIN
  IF @@ERROR <> 0 OR @errorcount > 0
   ROLLBACK TRANSACTION
  ELSE
   COMMIT TRANSACTION
 END
END
