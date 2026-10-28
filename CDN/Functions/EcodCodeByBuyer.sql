CREATE FUNCTION CDN.EcodCodeByBuyer( @faId INT, @podmiotTyp INT, @podmiotId INT)
RETURNS NVARCHAR(35)
AS
BEGIN
 DECLARE @codeByBuyer NVARCHAR(35)
 IF @faId > 0
  SELECT  TOP 1 @codeByBuyer = DAT_WartoscTxt FROM cdn.DokAtrybuty WHERE DAt_TrNId=@faId AND DAt_Kod = 'CODEBYBUYER' ORDER BY DAT_DATId
 IF @codeByBuyer IS NULL
  SELECT @codeByBuyer = KnA_WartoscTxt FROM CDN.KntAtrybuty JOIN CDN.DefAtrybuty ON KnA_DeAId=DeA_DeAId WHERE DeA_Kod = 'CODEBYBUYER' AND KnA_PodmiotTyp = @podmiotTyp And KnA_PodmiotId = @podmiotId
 IF @codeByBuyer IS NULL   SET @codeByBuyer = N''
 RETURN @codeByBuyer
END
