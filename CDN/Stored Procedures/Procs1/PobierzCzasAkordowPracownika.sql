create procedure CDN.PobierzCzasAkordowPracownika @ID INT, @DtEnd DATETIME
AS
BEGIN
SET NOCOUNT ON
DECLARE @lMYAkordow INT
DECLARE @tSumaCzasow DATETIME
DECLARE @odKiedyUzupCzasAkord DATETIME
DECLARE @DateEnd DATETIME
DECLARE @odKiedyUzupCzasAkordMiesiac INT
SET @lMYAkordow = (SELECT DATEPART(YEAR, @DtEnd) * 12 + DATEPART(MONTH, @DtEnd))
SET @tSumaCzasow = (select convert(datetime,'1899-12-30',120))
SET @DateEnd = (select convert(datetime,'1899-12-30',120))
SET @odKiedyUzupCzasAkord = @DtEnd
SET @odKiedyUzupCzasAkordMiesiac = (SELECT DATEPART(MONTH, @odKiedyUzupCzasAkord))
DECLARE @AkordID INT
DECLARE @AkordWaznyOd DATETIME
DECLARE @AkordMiesiac INT
DECLARE @AkordHistID INT
DECLARE @AkordHistTypID INT
DECLARE @AkordHistWartID INT
DECLARE @AkordHistWartMiesiac INT
DECLARE @AkordHistWartRok INT
DECLARE @AkordHistWartCzas DATETIME
DECLARE @sekundy bigint
set @sekundy = 0
/*IF not exists(SELECT AKR_AkrId, AKR_WaznyOd, AKR_Nieaktywny from cdn.Akordy
where AKR_PraId = @ID and AKR_Nieaktywny <> 1)
return
*/
DECLARE PracAkordy CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT AKR_AkrId, AKR_WaznyOd from cdn.Akordy
where AKR_PraId = @ID and AKR_Nieaktywny <> 1
  OPEN PracAkordy
  WHILE 1 = 1
  BEGIN
      FETCH NEXT FROM PracAkordy INTO @AkordID, @AkordWaznyOd
   IF @@FETCH_STATUS <> 0 BREAK
   SET @AkordMiesiac = (SELECT DATEPART(MONTH, @AkordWaznyOd))
   IF @AkordMiesiac = @odKiedyUzupCzasAkordMiesiac
   BEGIN
  IF EXISTS (SELECT 1 WHERE DATEDIFF(day, @odKiedyUzupCzasAkord, @AkordWaznyOd) >= 0)
  BEGIN
   SET @odKiedyUzupCzasAkord = @AkordWaznyOd
   SET @odKiedyUzupCzasAkordMiesiac = @AkordMiesiac
  END
   END
   DECLARE PracAkordyHist CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT AKH_AkhId, AKH_AdfId from cdn.AkordyHist
   where AKH_AkrId = @AkordID
    OPEN PracAkordyHist
    WHILE 1 = 1
    BEGIN
     FETCH NEXT FROM PracAkordyHist INTO @AkordHistID, @AkordHistTypID
     IF @@FETCH_STATUS <> 0 BREAK
     IF EXISTS( SELECT * FROM CDN.AkordDefinicja WHERE ADF_AdfId = @AkordHistTypID and ADF_Pomniejszenie <> 1)
    CONTINUE
        DECLARE PracAkordyHistWart CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT AHW_AhwId, AHW_Miesiac, AHW_Rok, AHW_Czas from cdn.AkordyHistWartosci
      where AHW_AkhId = @AkordHistID
       OPEN PracAkordyHistWart
       WHILE 1 = 1
       BEGIN
        FETCH NEXT FROM PracAkordyHistWart INTO @AkordHistWartID, @AkordHistWartMiesiac, @AkordHistWartRok, @AkordHistWartCzas
        IF @@FETCH_STATUS <> 0 BREAK
        DECLARE @lWartMY INT
        SET @lWartMY = (SELECT @AkordHistWartRok*12 + @AkordHistWartMiesiac)
        DECLARE @sekCzas BIGINT
        SET @sekCzas = (select DATEDIFF(SECOND, @DateEnd,@AkordHistWartCzas))
        IF @lWartMY = @lMYAkordow
        BEGIN
       SET @tSumaCzasow = (SELECT DATEADD(second,@sekCzas,@tSumaCzasow))
       IF @sekCzas is not null
        SET @sekundy =  (select @sekundy + @sekCzas)
        END
       END
       CLOSE PracAkordyHistWart
       deallocate PracAkordyHistWart
    END
    CLOSE PracAkordyHist
    deallocate PracAkordyHist
  END
  CLOSE PracAkordy
  deallocate PracAkordy
SELECT @odKiedyUzupCzasAkord as CzasAkord, @tSumaCzasow as SumaCzasow, @sekundy / 3600 as godziny, (@sekundy / 60) % 60 as minuty, @sekundy
SET NOCOUNT OFF
END
