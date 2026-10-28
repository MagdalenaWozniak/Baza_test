CREATE PROCEDURE CDN.KntScal_KodyJPKV7
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 DECLARE @KntNadKod NVARCHAR(20)
 DECLARE @KntPodKod NVARCHAR(20)
 SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
 SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.DokKodyJPKV7', A.DKV7_KV7ID, B.KV7_Kod, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.DokKodyJPKV7 A JOIN cdn.KodyJPKV7 B ON B.KV7_KV7ID = A.DKV7_KV7ID
   WHERE A.DKV7_ParentTyp = 0 AND A.DKV7_ParentID = @KntPodID AND NOT EXISTS (SELECT * FROM cdn.DokKodyJPKV7 B WHERE B.DKV7_ParentTyp = 0 AND B.DKV7_ParentID = @KntNadID AND B.DKV7_KV7ID = A.DKV7_KV7ID)
 -- Jeśli na kontrahencie głównym jest już ten sam kod, to nie przenosimy takiego kodu bo byłaby duplikacja indeksu.
 INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID)
  SELECT A.DKV7_ParentTyp, @KntNadID, A.DKV7_KV7ID
   FROM cdn.DokKodyJPKV7 A
    WHERE A.DKV7_ParentTyp = 0 AND A.DKV7_ParentID = @KntPodID
     AND NOT EXISTS (SELECT * FROM cdn.DokKodyJPKV7 B WHERE B.DKV7_ParentTyp = 0 AND B.DKV7_ParentID = @KntNadID AND B.DKV7_KV7ID = A.DKV7_KV7ID)
 SET NOCOUNT OFF
