CREATE PROCEDURE CDN.KntScal_Karty
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT, -- ID kontrahenta podrzędnego (duplikata)
 @Rekurencja AS TINYINT -- czy procedura została wywołana przez samą siebie (rekurencja przy przepinaniu duplikatów z jednej karty na inną)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 1
 IF @@ERROR <> 0 RETURN
 DECLARE @KntNadKod NVARCHAR(20)
 DECLARE @KntPodKod NVARCHAR(20)
 DECLARE @KntNadNazwa12 NVARCHAR(102)
 SELECT @KntNadKod = Knt_Kod, @KntNadNazwa12 = Knt_Nazwa1 + ' ' + Knt_Nazwa2 FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
 SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
 ALTER TABLE cdn.Kontrahenci DISABLE TRIGGER Kontrahenci_Update_Limity_Trigger
  UPDATE A
   SET
    Knt_LimitKredytuWykorzystany = A.Knt_LimitKredytuWykorzystany + B.Knt_LimitKredytuWykorzystany,
    Knt_GLN = CASE WHEN (A.Knt_GLN <> '0000000000000' AND A.Knt_GLN <> '') THEN A.Knt_GLN ELSE B.Knt_GLN END
  FROM cdn.Kontrahenci A INNER JOIN cdn.Kontrahenci B ON B.Knt_KntID = @KntPodID WHERE A.Knt_KntId = @KntNadID
 UPDATE cdn.Kontrahenci SET Knt_TS_Mod = GETDATE() WHERE Knt_KntID = @KntNadID
 UPDATE cdn.Kontrahenci SET Knt_NadID = @KntNadID, Knt_GlID = @KntNadID, Knt_Nieaktywny = 1, Knt_LimitKredytuWykorzystany = 0, Knt_TS_Mod = GETDATE() WHERE Knt_KntID = @KntPodID
 UPDATE cdn.PodmiotyView SET Pod_NadID = @KntNadID, Pod_GlID = @KntNadID, Pod_GlKod = @KntNadKod, Pod_GlNazwa12 = @KntNadNazwa12 WHERE Pod_PodmiotTyp = 1 AND Pod_PodId = @KntPodID
 DECLARE @OpisTmp NVARCHAR(256)
 SELECT @OpisTmp = 'Połączono z kontrahentem podrzędnym ' + @KntPodKod
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 1103, -- OptimaObjectType_Kontrahent
   @ObiektSubTyp = 0,
   @ObiektID = @KntNadID,
   @ObiektNazwa = @KntNadKod,
   @OperacjaTyp = 2, -- modyfikacja
   @Opis = @OpisTmp
 SELECT @OpisTmp = 'Połączono z kontrahentem głównym ' + @KntNadKod
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 1103, -- OptimaObjectType_Kontrahent
   @ObiektSubTyp = 0,
   @ObiektID = @KntPodID,
   @ObiektNazwa = @KntPodKod,
   @OperacjaTyp = 2, -- modyfikacja
   @Opis = @OpisTmp
 IF @Rekurencja = 0
 BEGIN
  UPDATE A
   SET Knt_Komornik = B.Knt_Komornik, Knt_KomornikOkreg = B.Knt_KomornikOkreg, Knt_KomornikRewir = B.Knt_KomornikRewir, Knt_KomornikMiasto = B.Knt_KomornikMiasto
   FROM cdn.Kontrahenci A INNER JOIN cdn.Kontrahenci B ON B.Knt_KntID = @KntPodID AND B.Knt_Komornik = 1 WHERE A.Knt_KntId = @KntNadID AND B.Knt_Komornik <> 0
  UPDATE A
   SET Knt_EMail = B.Knt_EMail
   FROM cdn.Kontrahenci A INNER JOIN cdn.Kontrahenci B ON B.Knt_KntID = @KntPodID AND B.Knt_EMail <> '' WHERE A.Knt_KntId = @KntNadID AND A.Knt_EMail = ''
  UPDATE A
   SET Knt_Telefon1 = B.Knt_Telefon1
   FROM cdn.Kontrahenci A INNER JOIN cdn.Kontrahenci B ON B.Knt_KntID = @KntPodID AND B.Knt_Telefon1 <> '' WHERE A.Knt_KntId = @KntNadID AND A.Knt_Telefon1 = ''
  UPDATE A
   SET Knt_Telefon2 = B.Knt_Telefon2
   FROM cdn.Kontrahenci A INNER JOIN cdn.Kontrahenci B ON B.Knt_KntID = @KntPodID AND B.Knt_Telefon2 <> '' WHERE A.Knt_KntId = @KntNadID AND A.Knt_Telefon2 = ''
  UPDATE A
   SET Knt_TelefonSMS = B.Knt_TelefonSMS
   FROM cdn.Kontrahenci A INNER JOIN cdn.Kontrahenci B ON B.Knt_KntID = @KntPodID AND B.Knt_TelefonSMS <> '' WHERE A.Knt_KntId = @KntNadID AND A.Knt_TelefonSMS = ''
  UPDATE A
   SET Knt_CJBTyp = B.Knt_CJBTyp, Knt_CJBID = B.Knt_CJBID
   FROM cdn.Kontrahenci A INNER JOIN cdn.Kontrahenci B ON B.Knt_KntID = @KntPodID AND B.Knt_CJBTyp Is Not Null AND B.Knt_CJBID Is Not Null WHERE A.Knt_KntId = @KntNadID AND A.Knt_CJBTyp Is Null AND A.Knt_CJBID Is Null
 END
 ALTER TABLE cdn.Kontrahenci ENABLE TRIGGER Kontrahenci_Update_Limity_Trigger
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
           VALUES('cdn.Kontrahenci', 0, '', @KntPodID, @KntPodKod, @KntNadID, @KntNadKod)
 IF @Rekurencja = 0 AND EXISTS (SELECT Knt_KntID FROM cdn.Kontrahenci WHERE Knt_NadID = @KntPodID)
 BEGIN
  CREATE TABLE #KntPodDupIDs (DupID INT)
  INSERT INTO #KntPodDupIDs SELECT Knt_KntID FROM cdn.Kontrahenci WHERE Knt_NadID = @KntPodID
  DECLARE @DupID INT
  DECLARE c CURSOR LOCAL FAST_FORWARD FOR
   SELECT DupID FROM #KntPodDupIDs
  OPEN c
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM c INTO @DupID
   IF @@fetch_status <> 0
    BREAK
   EXEC CDN.KntScal_Karty @KntNadID, @DupID, 1
  END
  CLOSE c
  DEALLOCATE c
  DROP TABLE #KntPodDupIDs
 END
 SET NOCOUNT OFF
