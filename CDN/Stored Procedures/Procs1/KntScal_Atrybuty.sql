CREATE PROCEDURE CDN.KntScal_Atrybuty
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 IF EXISTS (SELECT * FROM cdn.KntAtrybuty A WHERE A.KnA_PodmiotTyp = 1 AND A.KnA_PodmiotId = @KntPodID)
 BEGIN
  DECLARE @KntNadKod NVARCHAR(20)
  DECLARE @KntPodKod NVARCHAR(20)
  SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
  SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
  INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
       SELECT 'cdn.KntAtrybuty', A.KnA_KnAID, (SELECT DeA_Kod FROM cdn.DefAtrybuty WHERE DeA_DeAId = A.KnA_DeAId), @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
   FROM cdn.KntAtrybuty A
    WHERE A.KnA_PodmiotTyp = 1 AND A.KnA_PodmiotId = @KntPodID
     AND NOT EXISTS (SELECT * FROM cdn.KntAtrybuty B WHERE B.KnA_PodmiotTyp = 1 AND B.KnA_PodmiotId = @KntNadID AND B.KnA_DeAId = A.KnA_DeAId)
  ALTER TABLE cdn.KntAtrybuty DISABLE TRIGGER ALL
  INSERT INTO cdn.KntAtrybuty (KnA_PodmiotTyp, KnA_PodmiotID, KnA_DeAId, KnA_WartoscTxt, KnA_CzyKopiowac, KnA_CzyKopiowacDoVAT, KnA_CzyKod, KnA_CzyPrzenosic, KnA_CzyDrukowac)
   SELECT 1, @KntNadID, A.KnA_DeAId, A.KnA_WartoscTxt, A.KnA_CzyKopiowac, A.KnA_CzyKopiowacDoVAT, A.KnA_CzyKod, A.KnA_CzyPrzenosic, A.KnA_CzyDrukowac
   FROM cdn.KntAtrybuty A
    WHERE A.KnA_PodmiotTyp = 1 AND A.KnA_PodmiotId = @KntPodID
     AND NOT EXISTS (SELECT * FROM cdn.KntAtrybuty B WHERE B.KnA_PodmiotTyp = 1 AND B.KnA_PodmiotId = @KntNadID AND B.KnA_DeAId = A.KnA_DeAId)
  ALTER TABLE cdn.KntAtrybuty ENABLE TRIGGER ALL
 END
 SET NOCOUNT OFF
