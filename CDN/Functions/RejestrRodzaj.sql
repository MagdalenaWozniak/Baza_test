CREATE FUNCTION [CDN].[RejestrRodzaj] ( @RUP_PodID INT, @RUP_PodmiotTyp INT )
  RETURNS     INT
  AS
  BEGIN
 DECLARE @RESULT     INT
 IF(@RUP_PodmiotTyp = 1)
 BEGIN
 SET @RESULT = 1
 END
 ELSE IF @RUP_PodmiotTyp = 3
 BEGIN
  SELECT @RESULT = -Pod_Rodzaj  FROM CDN.PodmiotyView WHERE Pod_PodId = @RUP_PodID AND Pod_PodmiotTyp = @RUP_PodmiotTyp
 END
 RETURN @RESULT
  END
