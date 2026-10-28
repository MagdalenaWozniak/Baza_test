CREATE PROCEDURE CDN.SrTGenerujDokumentyPT
@SrTID  INT,
@DataOpe DATETIME,
@OpeID  INT,
@StaID  INT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @DataDok DATETIME
  CREATE TABLE #SrOO (SrOO_DataOd DATETIME, SrOO_DataDo DATETIME, SrOO_PrcID INT, SrOO_PrcImieNazwisko NVARCHAR(255),
                                                        SrOO_SrMU TINYINT, SrOO_SrMU_Nazwa NVARCHAR(255))
  DECLARE @SrOO_DataOd DATETIME
  DECLARE @SrOO_DataDo DATETIME
  DECLARE @SrOO_PrcID INT
  DECLARE @SrOO_PrcImieNazwisko NVARCHAR(255)
 DECLARE cOO CURSOR LOCAL FAST_FORWARD FOR
  SELECT SrOO_DataOd, SrOO_DataDo, SrOO_PrcID, SrOO_PrcImieNazwisko FROM CDN.TrwaleOsobyOdpowiedzialne
   WHERE SrOO_SrTID = @SrTID ORDER BY SrOO_DataOd
  OPEN cOO
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM cOO INTO @SrOO_DataOd, @SrOO_DataDo, @SrOO_PrcID, @SrOO_PrcImieNazwisko
  IF @@FETCH_STATUS <> 0 BREAK
  INSERT INTO #SrOO VALUES(@SrOO_DataOd, @SrOO_DataDo, @SrOO_PrcID, @SrOO_PrcImieNazwisko, 0, NULL)
  END
  CLOSE cOO
  DEALLOCATE cOO
  CREATE TABLE #SrMU (SrMU_DataOd DATETIME, SrMU_DataDo DATETIME, SrMU_Nazwa NVARCHAR(255))
  DECLARE @SrMU_DataOd DATETIME
  DECLARE @SrMU_DataDo DATETIME
  DECLARE @SrMU_Nazwa NVARCHAR(255)
 DECLARE cMU CURSOR LOCAL FAST_FORWARD FOR
  SELECT SrMU_DataOd, SrMU_DataDo, SrMU_Nazwa FROM CDN.TrwaleMiejscaUzytkowania
   WHERE SrMU_SrTID = @SrTID ORDER BY SrMU_DataOd
  OPEN cMU
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM cMU INTO @SrMU_DataOd, @SrMU_DataDo, @SrMU_Nazwa
  IF @@FETCH_STATUS <> 0 BREAK
  INSERT INTO #SrMU VALUES(@SrMU_DataOd, @SrMU_DataDo, @SrMU_Nazwa)
  END
  CLOSE cMU
  DEALLOCATE cMU
  -- Scalamy zmiany osób i miejsc o zgodnych zakresach dat (takie zmiany chcemy mieć na jednym, wspólnym dokumencie)
 DECLARE cMU2 CURSOR LOCAL FAST_FORWARD FOR
  SELECT SrMU_DataOd, SrMU_DataDo, SrMU_Nazwa FROM #SrMU ORDER BY SrMU_DataOd
  OPEN cMU2
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM cMU2 INTO @SrMU_DataOd, @SrMU_DataDo, @SrMU_Nazwa
  IF @@FETCH_STATUS <> 0 BREAK
  IF EXISTS (SELECT * FROM #SrOO WHERE (SrOO_DataOd = @SrMU_DataOd OR SrOO_DataOd Is Null AND @SrMU_DataOd Is Null) AND
                     (SrOO_DataDo = @SrMU_DataDo OR SrOO_DataDo Is Null AND @SrMU_DataDo Is Null))
  BEGIN
   UPDATE #SrOO SET SrOO_SrMU = 1, SrOO_SrMU_Nazwa = @SrMU_Nazwa
    WHERE (SrOO_DataOd = @SrMU_DataOd OR SrOO_DataOd Is Null AND @SrMU_DataOd Is Null) AND
       (SrOO_DataDo = @SrMU_DataDo OR SrOO_DataDo Is Null AND @SrMU_DataDo Is Null)
   DELETE #SrMU
    WHERE (SrMU_DataOd = @SrMU_DataOd OR SrMU_DataOd Is Null AND @SrMU_DataOd Is Null) AND
        (@SrMU_DataDo = @SrMU_DataDo OR @SrMU_DataDo Is Null AND @SrMU_DataDo Is Null)
  END
  END
  CLOSE cMU2
  DEALLOCATE cMU2
  CREATE TABLE #SrOOMU (Typ TINYINT, DataOd DATETIME, DataDo DATETIME, PrcID INT, PrcImieNazwisko NVARCHAR(255), MUNazwa NVARCHAR(255))
  INSERT INTO #SrOOMU SELECT (CASE WHEN SrOO_SrMU=0 THEN 1 ELSE 3 END), SrOO_DataOd, SrOO_DataDo, SrOO_PrcID, SrOO_PrcImieNazwisko, SrOO_SrMU_Nazwa FROM #SrOO
  INSERT INTO #SrOOMU SELECT 2, SrMU_DataOd, SrMU_DataDo, NULL, NULL, SrMU_Nazwa FROM #SrMU
  DECLARE @Typ TINYINT
  DECLARE @DataOd DATETIME
  DECLARE @DataDo DATETIME
  DECLARE @PrcID INT
  DECLARE @PrcImieNazwisko NVARCHAR(255)
  DECLARE @MUNazwa NVARCHAR(255)
  BEGIN TRAN
  DELETE cdn.TrwaleHist WHERE SrH_SrTID = @SrTID AND SrH_TypDokumentu = 6
      AND NOT EXISTS (SELECT * FROM #SrOOMU WHERE
           (DataOd = SrH_DataPrzekazaniaOd OR DataOd Is Null AND SrH_DataPrzekazaniaOd Is Null) AND
           (DataDo = SrH_DataPrzekazaniaDo OR DataDo Is Null AND SrH_DataPrzekazaniaDo Is Null))
  IF @@Error<>0 GOTO KONIEC
  DECLARE cSrOOMU1 CURSOR LOCAL FAST_FORWARD FOR
   SELECT Typ, DataOd, DataDo, PrcID, PrcImieNazwisko, MUNazwa FROM #SrOOMU ORDER BY DataOd
  OPEN cSrOOMU1
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM cSrOOMU1 INTO @Typ, @DataOd, @DataDo, @PrcID, @PrcImieNazwisko, @MUNazwa
   IF @@FETCH_STATUS <> 0 BREAK
   IF YEAR(@DataOd) > 1900
    SELECT @DataDok = @DataOd
   ELSE
    SELECT @DataDok = @DataOpe
   EXEC cdn.SrTDodajAktualizujDokumentPT @Typ, @SrTID, @DataDok, @OpeID, @StaID, @DataOd, @DataDo, @PrcID, @PrcImieNazwisko, @MUNazwa
   IF @@Error<>0 BREAK
  END
  CLOSE cSrOOMU1
  DEALLOCATE cSrOOMU1
  DECLARE cSrOOMU2 CURSOR LOCAL FAST_FORWARD FOR
   SELECT Typ, DataOd, DataDo, PrcID, PrcImieNazwisko, MUNazwa FROM #SrOOMU ORDER BY DataOd
  OPEN cSrOOMU2
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM cSrOOMU2 INTO @Typ, @DataOd, @DataDo, @PrcID, @PrcImieNazwisko, @MUNazwa
   IF @@FETCH_STATUS <> 0 BREAK
   IF NOT EXISTS (SELECT * FROM cdn.TrwaleHist WHERE SrH_SrTID = @SrTID AND SrH_TypDokumentu = 6 AND
              (SrH_DataPrzekazaniaOd = @DataOd OR SrH_DataPrzekazaniaOd Is Null AND @DataOd Is Null) AND
              (SrH_DataPrzekazaniaDo = @DataDo OR SrH_DataPrzekazaniaDo Is Null AND @DataDo Is Null))
   BEGIN
     IF YEAR(@DataOd) > 1900
      SELECT @DataDok = @DataOd
     ELSE
     SELECT @DataDok = @DataOpe
    EXEC cdn.SrTDodajAktualizujDokumentPT 0, @SrTID, @DataDok, @OpeID, @StaID, @DataOd, @DataDo, @PrcID, @PrcImieNazwisko, @MUNazwa
   END
   IF @@Error<>0 BREAK
  END
  CLOSE cSrOOMU2
  DEALLOCATE cSrOOMU2
KONIEC:
 IF @@Error<>0
 BEGIN
  IF @@TranCount<>0 ROLLBACK TRAN
 END
 ELSE
 BEGIN
  IF @@TranCount<>0 COMMIT TRAN
 END
 -- SELECT * FROM #SrOO
 -- SELECT * FROM #SrMU
  -- SELECT * FROM #SrOOMU
 DROP TABLE #SrOO
 DROP TABLE #SrMU
 DROP TABLE #SrOOMU
  SET NOCOUNT OFF
END
