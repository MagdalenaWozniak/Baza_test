CREATE PROCEDURE CDN.KntScal_Zgody
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 IF EXISTS (SELECT * FROM cdn.PodmiotRejestracjaZgod A WHERE A.PRZ_PodmiotTyp = 1 AND A.PRZ_PodmiotID = @KntPodID)
 BEGIN
  DECLARE @KntNadKod NVARCHAR(20)
  DECLARE @KntPodKod NVARCHAR(20)
  SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
  SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
  INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
       SELECT 'cdn.PodmiotRejestracjaZgod', A.PRZ_PRZId, (SELECT RZT_Tytul FROM cdn.RejestracjaZgodTresc WHERE RZT_RZTID = A.PRZ_TrescZgodyId), @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
   FROM cdn.PodmiotRejestracjaZgod A
    WHERE A.PRZ_PodmiotTyp = 1 AND A.PRZ_PodmiotID = @KntPodID
     /* AND NOT EXISTS (SELECT * FROM cdn.PodmiotRejestracjaZgod B WHERE B.PRZ_PodmiotTyp = 1 AND B.PRZ_PodmiotID = @KntPodID AND B.PRZ_TrescZgodyId = A.PRZ_TrescZgodyId) */
  ALTER TABLE cdn.PodmiotRejestracjaZgod DISABLE TRIGGER ALL
  DECLARE @staraZgodaID INT
  DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT PRZ_PRZID FROM cdn.PodmiotRejestracjaZgod WHERE PRZ_PodmiotTyp = 1 AND PRZ_PodmiotID = @KntPodID
  OPEN c
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM c INTO @staraZgodaID
   IF @@fetch_status <> 0 BREAK
   INSERT INTO cdn.PodmiotRejestracjaZgod (PRZ_PodmiotTyp, PRZ_PodmiotID, PRZ_PrzedstawicielId, PRZ_TrescZgodyId, PRZ_EMAIL, PRZ_SMS, PRZ_Telefon, PRZ_List,
    PRZ_DataWyrazenia, PRZ_ZrodloPozyskaniaId, PRZ_IPWyrazenia, PRZ_DataWycofania, PRZ_ZrodloWycofaniaId, PRZ_IPWycofania, PRZ_PowodWycofania, PRZ_Akronim, PRZ_ImieNazwisko)
   SELECT 1, @KntNadID, A.PRZ_PrzedstawicielId, A.PRZ_TrescZgodyId, A.PRZ_EMAIL, A.PRZ_SMS, A.PRZ_Telefon, A.PRZ_List,
    A.PRZ_DataWyrazenia, A.PRZ_ZrodloPozyskaniaId, A.PRZ_IPWyrazenia, A.PRZ_DataWycofania, A.PRZ_ZrodloWycofaniaId, A.PRZ_IPWycofania, A.PRZ_PowodWycofania, A.PRZ_Akronim, A.PRZ_ImieNazwisko
   FROM cdn.PodmiotRejestracjaZgod A
   WHERE A.PRZ_PRZID = @staraZgodaID
   DECLARE @nowaZgodaID INT
   SELECT @nowaZgodaID = SCOPE_IDENTITY()
   -- Podpięcie do utworzonej zgody załączników starej zgody (poprzez skopiowanie linków, bez kopiowania samych załączników!)
   INSERT INTO cdn.DaneBinarneLinki
    (
     DBL_DokumentTyp, DBL_DokumentId,
     DBL_TwrID, DBL_Lp, DBL_Typ, DBL_NazwaPliku, DBL_Sciezka, DBL_WBazie, DBL_DabId, DBL_FileMode,
     DBL_ESklep, DBL_JezykId, DBL_TagLink, DBL_TagAlt, DBL_TagRel, DBL_TagTitle
    )
    SELECT
     DBL_DokumentTyp, @nowaZgodaID,
     DBL_TwrID, DBL_Lp, DBL_Typ, DBL_NazwaPliku, DBL_Sciezka, DBL_WBazie, DBL_DabId, DBL_FileMode,
     DBL_ESklep, DBL_JezykId, DBL_TagLink, DBL_TagAlt, DBL_TagRel, DBL_TagTitle
    FROM cdn.DaneBinarneLinki WHERE DBL_DokumentTyp = 1119 AND DBL_DokumentId = @staraZgodaID
   --UPDATE cdn.DaneBinarneLinki SET DBL_DokumentId = @nowaZgodaID WHERE DBL_DokumentTyp = 1119 AND DBL_DokumentId = @staraZgodaID
   -- Podpięcie do utworzonej zgody dokumentów (np. dokumenty OBD i kontakty CRM) starej zgody (poprzez skopiowanie relacji do dokumentów, bez kopiowania samych dokumentów!)
   INSERT INTO cdn.DokRelacje
    (
     DoR_ParentTyp, DoR_ParentId, DoR_ParentGUID,
     DoR_DokumentTyp, DoR_DokumentId,
     DoR_Flaga
    )
    SELECT
     DoR_ParentTyp, DoR_ParentId, DoR_ParentGUID,
     DoR_DokumentTyp, @nowaZgodaID,
     DoR_Flaga
    FROM cdn.DokRelacje WHERE DoR_DokumentTyp = 1119 AND DoR_DokumentId = @staraZgodaID
   --UPDATE cdn.DokRelacje SET DoR_DokumentId = @nowaZgodaID WHERE DoR_DokumentTyp = 1119 AND DoR_DokumentId = @staraZgodaID
   --UPDATE cdn.DokRelacje SET DoR_DokumentId = @nowaZgodaID WHERE DoR_ParentTyp = 750 AND DoR_DokumentTyp = 1119 AND DoR_DokumentId = @staraZgodaID -- OBD
   --UPDATE cdn.DokRelacje SET DoR_DokumentId = @nowaZgodaID WHERE DoR_ParentTyp = 700 AND DoR_DokumentTyp = 1119 AND DoR_DokumentId = @staraZgodaID -- CRM
  END
  CLOSE c
  DEALLOCATE c
  ALTER TABLE cdn.PodmiotRejestracjaZgod ENABLE TRIGGER ALL
 END
 SET NOCOUNT OFF
