CREATE Procedure [CDN].[StazCalc]
@DataOd DateTime,
@DataDo DateTime,
@Lata Int Output,
@Mies Int Output,
@Dni Int Output
AS
SET NOCOUNT ON
IF @Lata is null SET @Lata = 0
IF @Mies is null SET @Mies = 0
IF @Dni is null SET @Dni = 0
IF DAY(@DataOd)=1 and MONTH(@DataOd)=1 and DAY(@DataDo)=31 and MONTH(@DataDo)=12
 BEGIN
  IF YEAR(@DataOd)=YEAR(@DataDo)
   SET @Lata = @Lata + 1
  ELSE
   SET @Lata = @Lata + (YEAR(@DataDo) - YEAR(@DataOd) + 1)
 END
ELSE
 BEGIN
  IF MONTH(@DataOd)=MONTH(@DataDo) and YEAR(@DataOd)=YEAR(@DataDo)
   BEGIN
    IF DAY(@DataOd)=1 and DAY(DATEADD(day,1,@DataDo))= 1
     SET @Mies = @Mies + 1
    ELSE
     BEGIN
      SET @Dni =  @Dni + Day(@DataDo) - Day(@DataOd) + 1
     END
   END
  ELSE
  BEGIN
   IF  YEAR(@DataOd)=YEAR(@DataDo)
    BEGIN
     SET @Mies = @Mies + (MONTH(@DataDo) - MONTH(@DataOd) - 1)
    END
   ELSE
    BEGIN
     SET @Lata = @Lata + (YEAR(@DataDo) - YEAR(@DataOd) - 1)
     SET @Mies = @Mies + (12 - Month(@DataOd) + Month(@DataDo) -1)
                END
    IF DAY(@DataOd)= 1
     SET @Mies = @Mies + 1
    ELSE
    IF DAY(@DataOd)>1
     BEGIN
     DECLARE @TempData datetime
     SET @TempData = DATEADD(month,1,DATEADD(day,1-DAY(@DataOd),@DataOd))
     SET @Dni = @Dni + DATEDIFF(day,@DataOd,@TempData)
     END
    IF DAY(DATEADD(day,1,@DataDo))<>1
     SET @Dni = @Dni + DAY(@DataDo)
      IF DAY(DATEADD(day,1,@DataDo))=1
     SET @Mies = @Mies+1
  END
 END
SET @Mies = @Mies + @Dni/30
SET @Dni = @Dni%30
SET @Lata = @Lata + @Mies/12
SET @Mies = @Mies%12
