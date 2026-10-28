CREATE FUNCTION cdn.KodPodmiotu( @podmiotTyp INT, @podmiotId INT)
RETURNS NVARCHAR(20)
AS
BEGIN
 DECLARE @kod NVARCHAR(20)
 SELECT @kod = Pod_Kod FROM cdn.PodmiotyView WHERE Pod_PodmiotTyp=@podmiotTyp AND Pod_PodID = @podmiotId
 IF @kod Is NULL
  SET  @kod = ''
 RETURN @kod
END
