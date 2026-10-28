CREATE PROCEDURE [CDN].[ESKLEP_PrzepnijKontrahentow]
@KntZrdID INT, -- ID kontrahenta źródłowego w Optimie
@KntDocID INT -- ID kontrahenta docelowego w Optimie
AS
BEGIN
 SET NOCOUNT ON
 IF EXISTS (SELECT * FROM cdn.Kontrahenci WHERE Knt_KntID = @KntDocID AND Knt_LpAnonimizacji > 0)
 BEGIN
  DECLARE @nadKod NVARCHAR(20)
  SELECT @nadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntId = @KntDocID
  RAISERROR('##OPT34422##%%nadKod%%=%s%%##', 16, 1, @nadKod)
  RETURN
 END
 BEGIN TRAN
 -- Usuwamy najpierw te rekordy z eSklepKntRelacje, które dotyczą kontrahenta docelowego i wskazują na jeden z e-sklepów, które będziemy przepinać z kontrahenta źródłowego.
 -- Na ich miejsce pojawią się nowe rekordy na kontrahenta docelowego, z danymi skopiowanymi z rekordów na kontrahenta źródłowego
 DELETE CDN.eSklepKntRelacje WHERE ESK_KntOptimaID = @KntDocID AND ESK_eSklepID IN (SELECT B.ESK_eSklepID FROM CDN.eSklepKntRelacje B WHERE B.ESK_KntOptimaID = @KntZrdID)
 -- Teraz dla każdego rekordu eSklepKntRelacje, dotyczącego kontrahenta źródłowego, dodajemy na jego podstawie rekord z kontrahentem docelowym,
 -- a w rekordzie z kontrahentem źródłowym przed ESK_KnteSklepID dajemy znak minus.
 DECLARE @ESKID INT; DECLARE @eSklepID INT; DECLARE @KntOptimaID INT; DECLARE @KnteSklepID INT
 DECLARE cRel CURSOR LOCAL FAST_FORWARD FOR SELECT ESK_ESKId, ESK_eSklepID, ESK_KnteSklepID, ESK_KntOptimaID FROM CDN.eSklepKntRelacje WHERE ESK_KntOptimaID = @KntZrdID
 OPEN cRel
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM cRel INTO @ESKID, @eSklepID, @KnteSklepID, @KntOptimaID
  IF @@fetch_status <> 0
   BREAK
  INSERT INTO CDN.eSklepKntRelacje (ESK_eSklepID, ESK_KnteSklepID, ESK_KntOptimaID) VALUES(@eSklepID, @KnteSklepID, @KntDocID)
  UPDATE CDN.eSklepKntRelacje SET ESK_KnteSklepID = - ESK_KnteSklepID WHERE ESK_ESKID = @ESKID
 END
 CLOSE cRel; DEALLOCATE cRel
 -- W tabeli KntESklepy przepinamy rekordy z kontrahentem źródłowym na docelowego
 DECLARE @KESID INT; DECLARE @eKntID INT; DECLARE @TypCeny INT
 DECLARE cEsk CURSOR LOCAL FAST_FORWARD FOR SELECT KES_KESID, KES_KntID, KES_eSklepID, KES_TypCenyDomyslnej FROM CDN.KntESklepy WHERE KES_KntID = @KntZrdID
 OPEN cEsk
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM cEsk INTO @KESID, @eKntID, @eSklepID, @TypCeny
  IF @@fetch_status <> 0
   BREAK
  IF NOT EXISTS(SELECT * FROM CDN.KntESklepy WHERE KES_eSklepID = @eSklepID AND KES_KntID = @KntDocID)
   UPDATE CDN.KntESklepy SET KES_KntID = @KntDocID WHERE KES_KESID = @KESID
  ELSE
   DELETE CDN.KntESklepy WHERE KES_KESID = @KESID
 END
 CLOSE cEsk; DEALLOCATE cEsk
 -- W tabeli KntESklepyPrzedstawiciele przepinamy rekordy z kontrahentem źródłowym na docelowego
 DECLARE @KESPID INT,@KESPKntID INT,@KESPEmail nvarchar(250),@KESPESklepID INT, @KESPPrzedstawicielID INT,@PrzedstawicielID INT
 DECLARE cEskP CURSOR LOCAL FAST_FORWARD FOR SELECT KESP_KESPID, KESP_KntID, KESP_eSklepID, KESP_Email,KESP_PrzedstawicielID FROM CDN.KntESklepyPrzedstawiciele WHERE KESP_KntID = @KntZrdID
 OPEN cEskP
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM cEskP INTO @KESPID, @KESPKntID, @KESPeSklepID, @KESPEmail, @KESPPrzedstawicielID
  IF @@fetch_status <> 0
   BREAK
  IF NOT EXISTS(SELECT * FROM CDN.KntESklepyPrzedstawiciele WHERE KESP_eSklepID = @eSklepID AND KESP_KntID = @KntDocID  AND KESP_Email = @KESPEmail)
  BEGIN
      set @PrzedstawicielID = 0
   select Top 1 @PrzedstawicielID = KnO_KnOId from CDN.KntOsoby where KnO_KntId = @KntDocID and KnO_Email = @KESPEmail
   -- znalesc przedstawiciela
   if @PrzedstawicielID = 0
   BEGIN
    INSERT INTO [CDN].[KntOsoby]
    ([KnO_KntId]
    ,[KnO_Plec]
    ,[KnO_KodPocztowy]
    ,[KnO_Telefon]
    ,[KnO_GSM]
    ,[KnO_Informacje]
    ,[KnO_Domyslny]
    ,[KnO_Adres2]
    ,[KnO_Email]
    ,[KnO_Gmina]
    ,[KnO_Kraj]
    ,[KnO_Miasto]
    ,[KnO_Nazwisko]
    ,[KnO_NrDomu]
    ,[KnO_NrLokalu]
    ,[KnO_Poczta]
    ,[KnO_Powiat]
    ,[KnO_Tytul]
    ,[KnO_Ulica]
    ,[KnO_Wojewodztwo]
    ,[KnO_Mailing]
    ,[KnO_TelefonSms]
    ,[KnO_Nieaktywny]
    ,[KnO_LpAnonimizacji]
    ,[KnO_OpeZalId]
    ,[KnO_StaZalId]
    ,[KnO_TS_Zal]
    ,[KnO_OpeModId]
    ,[KnO_StaModId]
    ,[KnO_TS_Mod]
    ,[KnO_OpeModKod]
    ,[KnO_OpeModNazwisko]
    ,[KnO_OpeZalKod]
    ,[KnO_OpeZalNazwisko]
    ,[KnO_EmailESklep])
    select
    @KntDocID
    ,1
    ,''
    ,''
    ,''
    ,''
    ,0
    ,''
    ,@KESPEmail
    ,''
    ,''
    ,''
    ,KnO_Nazwisko
    ,''
    ,''
    ,''
    ,''
    ,''
    ,''
    ,''
    ,0
    ,''
    ,0
    ,0
    ,KnO_OpeZalId
    ,KnO_StaZalId
    ,KnO_TS_Zal
    ,KnO_OpeZalId
    ,KnO_StaZalId
    ,GETDATE()
    ,KnO_OpeZalKod
    ,KnO_OpeZalNazwisko
    ,KnO_OpeZalKod
    ,KnO_OpeZalNazwisko
    ,''
    from cdn.KntOsoby where KnO_KnOId = @KESPPrzedstawicielID
    SELECT @PrzedstawicielID = KnO_KnOId FROM Cdn.KntOsoby WHERE KnO_KntId = @KntDocID and KnO_Email = @KESPEmail
   END
   IF NOT EXISTS(SELECT * FROM CDN.KntESklepyPrzedstawiciele WHERE KESP_eSklepID = @eSklepID AND KESP_KntID = @KntDocID  AND KESP_Domyslny = 1)
    UPDATE CDN.KntESklepyPrzedstawiciele SET KESP_KntID = @KntDocID, KESP_PrzedstawicielID = @PrzedstawicielID WHERE KESP_KESPID = @KESPID
   ELSE
    UPDATE CDN.KntESklepyPrzedstawiciele SET KESP_KntID = @KntDocID, KESP_PrzedstawicielID = @PrzedstawicielID, KESP_Domyslny = 0 WHERE KESP_KESPID = @KESPID
  END
  ELSE
   delete CDN.KntESklepyPrzedstawiciele  WHERE KESP_KESPID = @KESPID
 END
 CLOSE cEskP; DEALLOCATE cEskP
 DECLARE @eMailZrd NVARCHAR(127)
 SELECT @eMailZrd = Knt_Email FROM CDN.Kontrahenci WHERE Knt_KntId = @KntZrdID
 IF @eMailZrd <> ''
  UPDATE CDN.Kontrahenci SET Knt_Email = @eMailZrd WHERE Knt_KntId = @KntDocID AND Knt_Email = ''
 UPDATE cdn.Kontrahenci SET Knt_TS_Mod = GETDATE() WHERE Knt_KntID = @KntZrdID
 UPDATE cdn.Kontrahenci SET Knt_TS_Mod = GETDATE() WHERE Knt_KntID = @KntDocID
 COMMIT
 SET NOCOUNT OFF
END
