CREATE FUNCTION [CDN].[DokNagPodmiotKod] (@podmiotTyp int, @podmiotId int)
    RETURNS VARCHAR(20)
BEGIN
  DECLARE @kod VARCHAR(20)
  IF @podmiotTyp = 4 SET @podmiotTyp = 3    -- właściciel
  SELECT TOP 1 @kod = Pod_Kod FROM Cdn.PodmiotyView WHERE Pod_PodmiotTyp = @podmiotTyp AND Pod_PodId = @podmiotId
  IF @kod IS NULL SET @kod = ''
  RETURN LTRIM(RTRIM(@kod))
END
