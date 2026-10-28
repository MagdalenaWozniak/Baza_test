CREATE PROCEDURE CDN.Swiadectwo @ZatrOd DATETIME, @PrcId INT
AS
SET NOCOUNT ON
DECLARE @Dzien  DATETIME
DECLARE @DataOd DATETIME
DECLARE @DataDo DATETIME
DECLARE @Data1  DATETIME
DECLARE @Data2  DATETIME
DECLARE @EtatL  INT
DECLARE @EtatM  INT
DECLARE @IleRec INT
DECLARE @poprzEtatL INT
DECLARE @poprzEtatM INT
DECLARE @poprzDataOd DATETIME
DECLARE @poprzDataDo DATETIME
DECLARE @Licz INT
SET @Data1      = CONVERT ( DATETIME, '1900-01-01 00:00:00' , 120 )
SET @Data2      = CONVERT ( DATETIME, '2999-12-31 00:00:00' , 120 )
SET @Licz = 1
CREATE TABLE #Swiad (
 Tmp_DataOd  DATETIME,
 Tmp_DataDo  DATETIME,
 Tmp_EtatL   INT,
 Tmp_EtatM   INT,
)
SET @IleRec = (SELECT COUNT(*) FROM CDN.PracEtaty WHERE PRE_PraID = @PrcId and PRE_ZatrudnionyOd = @ZatrOd)
DECLARE Tmp_SwiadPrc CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
Case When @Data1=PRE_DataOd Then PRE_ZatrudnionyOd Else PRE_DataOd End,
Case When @Data2=PRE_DataDo Then PRE_ZatrudnionyDo Else PRE_DataDo End,
 PRE_ETAEtatL,
        PRE_ETAEtatM
  FROM CDN.PracEtaty
  WHERE PRE_PraID = @PrcId and PRE_ZatrudnionyOd = @ZatrOd
  ORDER BY PRE_DataOd
  OPEN Tmp_SwiadPrc
  WHILE 1=1
BEGIN
  IF  @IleRec <> 1 and @IleRec <> 2
  BEGIN
    FETCH NEXT FROM Tmp_SwiadPrc INTO  @DataOd, @DataDo, @EtatL, @EtatM
 IF @@FETCH_STATUS <> 0 BREAK
        BEGIN
         IF @Licz = 1
   BEGIN
     SET @poprzDataOd = @DataOd
     SET @poprzDataDo = @DataDo
     SET @poprzEtatL=@EtatL
     SET @poprzEtatM=@EtatM
     SET @Licz = @Licz + 1
     END
    ELSE
  BEGIN
    IF @poprzEtatL=@EtatL and @poprzEtatM=@EtatM
       BEGIN
   SET @Licz = @Licz + 1
       END
    ELSE
         BEGIN
      INSERT INTO #Swiad values (@poprzDataOd, @DataOd-1, @poprzEtatL, @poprzEtatM)
      SET @poprzEtatL = @EtatL
      SET @poprzEtatM = @EtatM
      SET @poprzDataOd = @DataOd
             IF @Licz <>  @IleRec
         SET @Licz = @Licz + 1
        END
    IF @Licz = @IleRec
       INSERT INTO #Swiad values (@poprzDataOd, @DataDo, @EtatL, @EtatM)
  END
    END
  END
   ELSE
 BEGIN
   IF @IleRec = 2
  BEGIN
     FETCH NEXT FROM Tmp_SwiadPrc INTO  @DataOd, @DataDo, @EtatL, @EtatM
     IF @@FETCH_STATUS <> 0 BREAK
          IF @Licz = 1
    BEGIN
      IF @DataOd <> @ZatrOd
         SET @poprzDataOd = @ZatrOd
 ELSE
  SET @poprzDataOd = @DataOd
      SET @poprzDataDo = @DataDo
      SET @poprzEtatL=@EtatL
      SET @poprzEtatM=@EtatM
      SET @Licz = @Licz + 1
      END
     ELSE
   BEGIN
     IF @poprzEtatL=@EtatL and @poprzEtatM=@EtatM
        INSERT INTO #Swiad values (@poprzDataOd, @poprzDataDo, @poprzEtatL, @poprzEtatM)
     ELSE
        BEGIN
       INSERT INTO #Swiad values (@poprzDataOd, @DataOd-1, @poprzEtatL, @poprzEtatM)
            INSERT INTO #Swiad values (@DataOd, @DataDo, @EtatL, @EtatM)
        END
   END
  END
   ELSE
  BEGIN
     FETCH NEXT FROM Tmp_SwiadPrc INTO  @DataOd, @DataDo, @EtatL, @EtatM
     IF @@FETCH_STATUS <> 0 BREAK
     INSERT INTO #Swiad values (@DataOd, @DataDo, @EtatL, @EtatM)
    END
 END
END
 CLOSE  Tmp_SwiadPrc
 DEALLOCATE  Tmp_SwiadPrc
 SET NOCOUNT OFF
SELECT
  * FROM #Swiad
