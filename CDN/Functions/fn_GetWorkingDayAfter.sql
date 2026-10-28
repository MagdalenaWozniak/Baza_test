CREATE FUNCTION cdn.fn_GetWorkingDayAfter(@date DATETIME)
RETURNS DATETIME
AS
BEGIN
 DECLARE @retVal DATETIME
 SELECT @retVal = @date
 WHILE 1 = 1
 BEGIN
  /*
  IF cdn.fn_IsWorkingDay(@retVal) = 1
   BREAK
  SELECT @retVal = DATEADD(DAY, 1, @retVal)
  */
   IF (
    MONTH(@retVal) =  1 AND DAY(@retVal) = 1 OR
    MONTH(@retVal) =  1 AND DAY(@retVal) = 6 OR
    MONTH(@retVal) =  5 AND DAY(@retVal) = 1 OR
    MONTH(@retVal) =  5 AND DAY(@retVal) = 3 OR
    MONTH(@retVal) =  8 AND DAY(@retVal) = 15 OR
    MONTH(@retVal) = 11 AND DAY(@retVal) =  1 OR
    MONTH(@retVal) = 11 AND DAY(@retVal) = 11 OR
    MONTH(@retVal) = 12 AND DAY(@retVal) = 25 OR
    MONTH(@retVal) = 12 AND DAY(@retVal) = 26
    )
    BEGIN
   SELECT @retVal = DATEADD(DAY, 1, @retVal)
   CONTINUE
    END
  DECLARE @dayOfWeek TINYINT
  IF @@DATEFIRST + DATEPART(dw, CONVERT(DATETIME, @retVal, 120)) > 7
   SELECT @dayOfWeek = @@DATEFIRST + DATEPART(dw, CONVERT(DATETIME, @retVal, 120)) - 8
  ELSE
   SELECT @dayOfWeek = @@DATEFIRST + DATEPART(dw, CONVERT(DATETIME, @retVal, 120)) - 1
  IF @dayOfWeek = 0
   SELECT @dayOfWeek = 7
  IF @dayOfWeek = 6 OR @dayOfWeek = 7
  BEGIN
   SELECT @retVal = DATEADD(DAY, 1, @retVal)
   CONTINUE
  END
  IF EXISTS (SELECT * FROM cdn.SwietaRuchome WHERE SwR_Data = @retVal)
  BEGIN
   SELECT @retVal = DATEADD(DAY, 1, @retVal)
   CONTINUE
  END
  BREAK
 END
 RETURN @retVal
END
