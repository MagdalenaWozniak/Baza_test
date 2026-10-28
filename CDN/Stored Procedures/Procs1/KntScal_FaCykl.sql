CREATE PROCEDURE CDN.KntScal_FaCykl
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 DECLARE @KntNadKod NVARCHAR(20)
 DECLARE @KntPodKod NVARCHAR(20)
 DECLARE @KntNadNazwa NVARCHAR(20)
 IF EXISTS(SELECT * FROM cdn.FaCyklKnt A WHERE A.FCK_TypKnt = 2 AND A.FCK_PodmiotTyp = 1 AND A.FCK_PodmiotID = @KntPodID
      AND NOT EXISTS(SELECT * FROM cdn.FaCyklKnt B WHERE B.FCK_FcNID = A.FCK_FcNID AND B.FCK_TypKnt = A.FCK_TypKnt AND B.FCK_PodmiotTyp = 1 AND B.FCK_PodmiotID = @KntNadID))
 BEGIN
  ALTER TABLE cdn.FaCyklKnt DISABLE TRIGGER ALL
  SELECT @KntNadKod = Knt_Kod, @KntNadNazwa = Knt_Nazwa1 FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
  SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
  INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
       SELECT 'cdn.FaCyklKnt', A.FCK_FcKID, A.FCK_Kod, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.FaCyklKnt A
   WHERE A.FCK_TypKnt = 2 AND A.FCK_PodmiotTyp = 1 AND A.FCK_PodmiotID = @KntPodID
    AND NOT EXISTS(SELECT * FROM cdn.FaCyklKnt B WHERE B.FCK_FcNID = A.FCK_FcNID AND B.FCK_TypKnt = A.FCK_TypKnt AND B.FCK_PodmiotTyp = 1 AND B.FCK_PodmiotID = @KntNadID)
  INSERT INTO cdn.FaCyklKnt (  FCK_FcNID,   FCK_TypKnt,   FCK_LpDlaTypKnt,   FCK_PodmiotTyp, FCK_PodmiotID, FCK_Kod,    FCK_Nazwa,      FCK_ObowiazujeOd,   FCK_TerminOd,   FCK_ObowiazujeDo,   FCK_TerminDo)
  SELECT        A.FCK_FcNID, A.FCK_TypKnt, A.FCK_LpDlaTypKnt, A.FCK_PodmiotTyp, @KntNadID,     @KntNadKod, @KntNadNazwa, A.FCK_ObowiazujeOd, A.FCK_TerminOd, A.FCK_ObowiazujeDo, A.FCK_TerminDo
  FROM cdn.FaCyklKnt A
   WHERE A.FCK_TypKnt = 2 AND A.FCK_PodmiotTyp = 1 AND A.FCK_PodmiotID = @KntPodID
    AND NOT EXISTS(SELECT * FROM cdn.FaCyklKnt B WHERE B.FCK_FcNID = A.FCK_FcNID AND B.FCK_TypKnt = A.FCK_TypKnt AND B.FCK_PodmiotTyp = 1 AND B.FCK_PodmiotID = @KntNadID)
  ALTER TABLE cdn.FaCyklKnt ENABLE TRIGGER ALL
 END
 EXEC CDN.FaCyklKntRenumeracja
 SET NOCOUNT OFF
