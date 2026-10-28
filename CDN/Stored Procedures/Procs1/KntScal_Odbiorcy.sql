CREATE PROCEDURE CDN.KntScal_Odbiorcy
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
  -- Podpięcie do kontrahenta nadrzędnego tych odbiorców z kontrahenta podrzędnego, którzy nie są jeszcze odbiorcami kontrahenta nadrzędnego
 IF EXISTS(SELECT * FROM cdn.KntOdbiorcy A WHERE A.Odb_KntOdbID = @KntPodID AND A.Odb_OdbKntID <> @KntNadID
     AND NOT EXISTS (SELECT * FROM cdn.KntOdbiorcy B WHERE B.Odb_KntOdbID = @KntNadID AND B.Odb_OdbKntID = A.Odb_OdbKntID))
 BEGIN
  DECLARE @KntNadKod NVARCHAR(20)
  DECLARE @KntPodKod NVARCHAR(20)
  SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
  SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
  INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
       SELECT 'cdn.KntOdbiorcy', A.Odb_OdbID, '', @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
   FROM cdn.KntOdbiorcy A
    WHERE A.Odb_KntOdbID = @KntPodID AND A.Odb_OdbKntID <> @KntNadID
     AND NOT EXISTS (SELECT * FROM cdn.KntOdbiorcy B WHERE B.Odb_KntOdbID = @KntNadID AND B.Odb_OdbKntID = A.Odb_OdbKntID)
  ALTER TABLE cdn.KntOdbiorcy DISABLE TRIGGER ALL
  INSERT INTO cdn.KntOdbiorcy (Odb_KntOdbID, Odb_OdbKntID, Odb_Domyslny)
   SELECT @KntNadID, A.Odb_OdbKntID, 0
   FROM cdn.KntOdbiorcy A
    WHERE A.Odb_KntOdbID = @KntPodID AND A.Odb_OdbKntID <> @KntNadID
     AND NOT EXISTS (SELECT * FROM cdn.KntOdbiorcy B WHERE B.Odb_KntOdbID = @KntNadID AND B.Odb_OdbKntID = A.Odb_OdbKntID)
  ALTER TABLE cdn.KntOdbiorcy ENABLE TRIGGER ALL
 END
  -- Podpięcie kontrahenta nadrzędnego jako odbiorcy do tych kontrahentów, którzy mają podpiętego jako odbiorcę kontrahenta podrzędnego, a nie mają jeszcze kontrahenta nadrzędnego jako odbiorcy
  IF EXISTS(SELECT * FROM cdn.KntOdbiorcy A WHERE A.Odb_OdbKntID = @KntPodID
     AND NOT EXISTS (SELECT * FROM cdn.KntOdbiorcy B WHERE B.Odb_KntOdbID = @KntNadID AND B.Odb_OdbKntID = A.Odb_OdbKntID))
  BEGIN
    SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
    SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
    INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
       SELECT 'cdn.KntOdbiorcy', A.Odb_OdbID, '', @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
    FROM cdn.KntOdbiorcy A
      WHERE A.Odb_OdbKntID = @KntPodID
      AND NOT EXISTS (SELECT * FROM cdn.KntOdbiorcy B WHERE B.Odb_KntOdbID = A.Odb_KntOdbID AND B.Odb_OdbKntID = @KntNadID)
    ALTER TABLE cdn.KntOdbiorcy DISABLE TRIGGER ALL
    INSERT INTO cdn.KntOdbiorcy (Odb_KntOdbID, Odb_OdbKntID, Odb_Domyslny)
      SELECT A.Odb_KntOdbID, @KntNadID, A.Odb_Domyslny
      FROM cdn.KntOdbiorcy A
        WHERE A.Odb_OdbKntID = @KntPodID
          AND NOT EXISTS (SELECT * FROM cdn.KntOdbiorcy B WHERE B.Odb_KntOdbID = A.Odb_KntOdbID AND B.Odb_OdbKntID = @KntNadID)
    UPDATE cdn.KntOdbiorcy SET Odb_Domyslny = 0
      FROM cdn.KntOdbiorcy A
        WHERE A.Odb_OdbKntID = @KntPodID
          AND EXISTS (SELECT * FROM cdn.KntOdbiorcy B WHERE B.Odb_KntOdbID = A.Odb_KntOdbID AND B.Odb_OdbKntID = @KntNadID AND B.Odb_Domyslny = 1)
    ALTER TABLE cdn.KntOdbiorcy ENABLE TRIGGER ALL
  END
    -- Wyłączenie domyślności wszystkich odbiorców - duplikatów na jakichkolwiek kontrahentach
  IF EXISTS(SELECT * FROM cdn.KntOdbiorcy WHERE Odb_OdbKntID = @KntPodID AND Odb_Domyslny = 1)
  BEGIN
    ALTER TABLE cdn.KntOdbiorcy DISABLE TRIGGER ALL
    UPDATE cdn.KntOdbiorcy SET Odb_Domyslny = 0 WHERE Odb_OdbKntID = @KntPodID AND Odb_Domyslny = 1
    ALTER TABLE cdn.KntOdbiorcy ENABLE TRIGGER ALL
 END
 SET NOCOUNT OFF
