CREATE PROCEDURE [CDN].[Swiadectwo1] @OkresOd DATETIME,@OkresDo DATETIME, @PrcId INT
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
DECLARE @poprzDataZwol DATETIME
DECLARE @DataZwol DATETIME
DECLARE @ZatrOd DATETIME
DECLARE @RodzajUmowy NVarChar(40)
DECLARE @Licz INT
SET @Data1      = CONVERT ( DATETIME, '1900-01-01 00:00:00' , 120 )
SET @Data2      = CONVERT ( DATETIME, '2999-12-31 00:00:00' , 120 )
SET @Licz = 1
CREATE TABLE #Swiad (
 Tmp_DataOd  DATETIME,
 Tmp_DataDo  DATETIME,
 Tmp_EtatL   INT,
 Tmp_EtatM   INT,
 Tmp_DataZwol DATETIME,
 Tmp_RodzaUmowy NVarChar(40)
)
-- Znalezienie daty zatrudnienia z zapisu historycznego obejmującego @OkresOd
SET @ZatrOd = (SELECT PRE_ZatrudnionyOd FROM CDN.PracEtaty WHERE PRE_PraID = @PrcId and @OkresOd between PRE_DataOd and PRE_DataDo)
-- Sprawdzamy ile rekordów spełnia warunen na PRE_ZatrudnionyOd = @ZatrOd oraz, że zapisy historyczne są z zakresu @OkresOd, @OkresDo
SET @IleRec = (SELECT COUNT(*) FROM CDN.PracEtaty WHERE PRE_PraID = @PrcId and PRE_ZatrudnionyOd = @ZatrOd and PRE_DataDo>=@OkresOd and PRE_DataOd<=@OkresDo)
-- Sprawdzenie warunków
DECLARE Tmp_SwiadPrc CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
--Case When @Data1=PRE_DataOd Then PRE_ZatrudnionyOd Else PRE_DataOd End,
--Case When @Data2=PRE_DataDo Then PRE_ZatrudnionyDo Else PRE_DataDo End,
 Case When PRE_DataOd <=PRE_ZatrudnionyOd Then PRE_ZatrudnionyOd Else PRE_DataOd End,
 PRE_ZatrudnionyDo,
 PRE_ETAEtatL,
        PRE_ETAEtatM,
   PRE_ZatrudnionyDo,
   PRE_ETARodzajUmowy
  FROM CDN.PracEtaty
  WHERE PRE_PraID = @PrcId and PRE_ZatrudnionyOd = @ZatrOd and PRE_DataDo>=@OkresOd and PRE_DataOd<=@OkresDo
  ORDER BY PRE_DataOd
  OPEN Tmp_SwiadPrc
  WHILE 1=1
BEGIN
  --IF  @IleRec <> 1 and @IleRec <> 2
  --BEGIN
    FETCH NEXT FROM Tmp_SwiadPrc INTO  @DataOd, @DataDo, @EtatL, @EtatM, @DataZwol, @RodzajUmowy
    IF @@FETCH_STATUS <> 0 BREAK
BEGIN
    IF @Licz = 1
     BEGIN
     SET @poprzDataOd = @DataOd
     SET @poprzDataDo = @DataDo
     SET @poprzEtatL=@EtatL
     SET @poprzEtatM=@EtatM
     SET @poprzDataZwol=@DataZwol
     SET @Licz = @Licz + 1
     INSERT INTO #Swiad values (@DataOd, @DataDo, @EtatL, @EtatM, @DataZwol, @RodzajUmowy)
     END
    ELSE
  BEGIN
    IF @DataZwol = @Data2
      BREAK
    IF @poprzEtatL=@EtatL and @poprzEtatM=@EtatM and @poprzDataZwol=@DataZwol
      BEGIN
      SET @Licz = @Licz + 1
      END
    ELSE
      BEGIN
      INSERT INTO #Swiad values (@DataOd, @DataDo, @EtatL, @EtatM,@DataZwol, @RodzajUmowy)
      SET @poprzEtatL = @EtatL
      SET @poprzEtatM = @EtatM
      SET @poprzDataOd = @DataOd
      SET @poprzDataZwol=@DataZwol
         IF @Licz <>  @IleRec
         SET @Licz = @Licz + 1
      END
      --IF @Licz = @IleRec
       --INSERT INTO #Swiad values (@poprzDataOd, @DataDo, @EtatL+20, @EtatM,@DataZwol, @RodzajUmowy)
   END
END
END
 CLOSE  Tmp_SwiadPrc
 DEALLOCATE  Tmp_SwiadPrc
 SET NOCOUNT OFF
 --Select 'Wynik'
SELECT
  * FROM #Swiad
