CREATE PROCEDURE CDN.KntScal_Przedstawiciele
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 IF EXISTS(SELECT * FROM cdn.KntOsoby A WHERE A.KnO_KntID = @KntPodID
     AND NOT EXISTS (SELECT * FROM cdn.KntOsoby B WHERE B.KnO_KntID = @KntNadID AND UPPER(B.KnO_Nazwisko) = UPPER(A.KnO_Nazwisko)))
 BEGIN
  ALTER TABLE cdn.KntOsoby DISABLE TRIGGER ALL
  ALTER TABLE cdn.PodmiotRejestracjaZgod DISABLE TRIGGER ALL
  DECLARE @KntNadKod NVARCHAR(20)
  DECLARE @KntPodKod NVARCHAR(20)
  SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
  SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
  DECLARE @OrgKnOID INT
  DECLARE c CURSOR READ_ONLY FOR SELECT A.KnO_KnOID FROM cdn.KntOsoby A
    WHERE A.KnO_KntID = @KntPodID
     AND NOT EXISTS (SELECT * FROM cdn.KntOsoby B WHERE B.KnO_KntID = @KntNadID AND UPPER(B.KnO_Nazwisko) = UPPER(A.KnO_Nazwisko))
  OPEN c
  WHILE 1 = 1
  BEGIN
   FETCH NEXT FROM c INTO @OrgKnOID
   IF @@FETCH_STATUS <> 0 BREAK
   INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
       SELECT 'cdn.KntOsoby', KnO_KnOID, KnO_Nazwisko, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
   FROM cdn.KntOsoby WHERE KnO_KntID = @OrgKnOID
   INSERT INTO cdn.KntOsoby (KnO_KntId, KnO_Nazwisko, KnO_Plec, KnO_Tytul, KnO_Domyslny, KnO_Nieaktywny,
    KnO_Kraj, KnO_Powiat, KnO_Wojewodztwo, KnO_Gmina, KnO_Miasto, KnO_Ulica, KnO_NrDomu, KnO_NrLokalu, KnO_KodPocztowy, KnO_Poczta, KnO_Adres2,
    KnO_Telefon, KnO_GSM, KnO_TelefonSMS, KnO_Email, KnO_Mailing,
    KnO_Informacje)
    SELECT @KntNadID, KnO_Nazwisko, KnO_Plec, KnO_Tytul, 0, KnO_Nieaktywny,
     KnO_Kraj, KnO_Powiat, KnO_Wojewodztwo, KnO_Gmina, KnO_Miasto, KnO_Ulica, KnO_NrDomu, KnO_NrLokalu, KnO_KodPocztowy, KnO_Poczta, KnO_Adres2,
     KnO_Telefon, KnO_GSM, KnO_TelefonSMS, KnO_Email, KnO_Mailing,
     KnO_Informacje
    FROM cdn.KntOsoby
     WHERE KnO_KnOID = @OrgKnOID
   DECLARE @NewKnOID INT
   SELECT @NewKnOID = SCOPE_IDENTITY()
   /*
   INSERT INTO cdn.PodmiotRejestracjaZgod (PRZ_PodmiotTyp, PRZ_PodmiotID, PRZ_PrzedstawicielId, PRZ_TrescZgodyId, PRZ_EMAIL, PRZ_SMS, PRZ_Telefon, PRZ_List,
       PRZ_DataWyrazenia, PRZ_ZrodloPozyskaniaId, PRZ_IPWyrazenia, PRZ_DataWycofania, PRZ_ZrodloWycofaniaId, PRZ_IPWycofania, PRZ_PowodWycofania, PRZ_Akronim, PRZ_ImieNazwisko)
   SELECT 0, 0, @NewKnOID, PRZ_TrescZgodyId, PRZ_EMAIL, PRZ_SMS, PRZ_Telefon, PRZ_List,
       PRZ_DataWyrazenia, PRZ_ZrodloPozyskaniaId, PRZ_IPWyrazenia, PRZ_DataWycofania, PRZ_ZrodloWycofaniaId, PRZ_IPWycofania, PRZ_PowodWycofania, PRZ_Akronim, PRZ_ImieNazwisko
   FROM cdn.PodmiotRejestracjaZgod
    WHERE PRZ_PrzedstawicielId = @OrgKnOID
   */
   DECLARE @staraZgodaID INT
   DECLARE cZgody CURSOR LOCAL FAST_FORWARD FOR SELECT PRZ_PRZID FROM cdn.PodmiotRejestracjaZgod WHERE PRZ_PrzedstawicielId = @OrgKnOID
   OPEN cZgody
   WHILE 1=1
   BEGIN
    FETCH NEXT FROM cZgody INTO @staraZgodaID
    IF @@fetch_status <> 0 BREAK
    INSERT INTO cdn.PodmiotRejestracjaZgod (PRZ_PodmiotTyp, PRZ_PodmiotID, PRZ_PrzedstawicielId, PRZ_TrescZgodyId, PRZ_EMAIL, PRZ_SMS, PRZ_Telefon, PRZ_List,
     PRZ_DataWyrazenia, PRZ_ZrodloPozyskaniaId, PRZ_IPWyrazenia, PRZ_DataWycofania, PRZ_ZrodloWycofaniaId, PRZ_IPWycofania, PRZ_PowodWycofania, PRZ_Akronim, PRZ_ImieNazwisko)
    SELECT A.PRZ_PodmiotTyp, A.PRZ_PodmiotID, @NewKnOID, A.PRZ_TrescZgodyId, A.PRZ_EMAIL, A.PRZ_SMS, A.PRZ_Telefon, A.PRZ_List,
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
   CLOSE cZgody
   DEALLOCATE cZgody
  END
  CLOSE c
  DEALLOCATE c
  /*
  INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
       SELECT 'cdn.KntOsoby', A.KnO_KnOID, A.KnO_Nazwisko, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
   FROM cdn.KntOsoby A
    WHERE A.KnO_KntID = @KntPodID
     AND NOT EXISTS (SELECT * FROM cdn.KntOsoby B WHERE B.KnO_KntID = @KntNadID AND UPPER(B.KnO_Nazwisko) = UPPER(A.KnO_Nazwisko))
  INSERT INTO cdn.KntOsoby (KnO_KntId, KnO_Nazwisko, KnO_Plec, KnO_Tytul, KnO_Domyslny, KnO_Nieaktywny,
   KnO_Kraj, KnO_Powiat, KnO_Wojewodztwo, KnO_Gmina, KnO_Miasto, KnO_Ulica, KnO_NrDomu, KnO_NrLokalu, KnO_KodPocztowy, KnO_Poczta, KnO_Adres2,
   KnO_Telefon, KnO_GSM, KnO_TelefonSMS, KnO_Email, KnO_Mailing,
   KnO_Informacje)
   SELECT @KntNadID, A.KnO_Nazwisko, A.KnO_Plec, A.KnO_Tytul, 0, A.KnO_Nieaktywny,
    A.KnO_Kraj, A.KnO_Powiat, A.KnO_Wojewodztwo, A.KnO_Gmina, A.KnO_Miasto, A.KnO_Ulica, A.KnO_NrDomu, A.KnO_NrLokalu, A.KnO_KodPocztowy, A.KnO_Poczta, A.KnO_Adres2,
    A.KnO_Telefon, A.KnO_GSM, A.KnO_TelefonSMS, A.KnO_Email, A.KnO_Mailing,
    A.KnO_Informacje
   FROM cdn.KntOsoby A
    WHERE A.KnO_KntID = @KntPodID
     AND NOT EXISTS (SELECT * FROM cdn.KntOsoby B WHERE B.KnO_KntID = @KntNadID AND UPPER(B.KnO_Nazwisko) = UPPER(A.KnO_Nazwisko))
  */
  ALTER TABLE cdn.KntOsoby ENABLE TRIGGER ALL
  ALTER TABLE cdn.PodmiotRejestracjaZgod ENABLE TRIGGER ALL
 END
 SET NOCOUNT OFF
