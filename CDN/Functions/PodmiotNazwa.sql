CREATE FUNCTION [CDN].[PodmiotNazwa] (@podmiotTyp int, @podmiotId int)
    RETURNS NVARCHAR(352)
BEGIN
  DECLARE @nazwa NVARCHAR(352)
  IF @podmiotTyp = 4 OR  @podmiotTyp = 3    -- właściciel
 SELECT TOP 1 @nazwa = Pod_Nazwa2 + SPACE(1) + Pod_Nazwa1 + SPACE(1) + Pod_Nazwa3 FROM Cdn.PodmiotyView WHERE Pod_PodmiotTyp = @podmiotTyp AND Pod_PodId = @podmiotId
  ELSE
 SELECT TOP 1 @nazwa = Pod_Nazwa1 + SPACE(1) + Pod_Nazwa2 + SPACE(1) + Pod_Nazwa3 FROM Cdn.PodmiotyView WHERE Pod_PodmiotTyp = @podmiotTyp AND Pod_PodId = @podmiotId
  IF @nazwa IS NULL SET @nazwa = ''
  RETURN LTRIM(RTRIM(@nazwa))
END
