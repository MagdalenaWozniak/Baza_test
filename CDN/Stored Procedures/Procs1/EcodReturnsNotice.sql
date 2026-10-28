CREATE PROCEDURE CDN.EcodReturnsNotice( @faId INT, @returnsNoticeNumber NVARCHAR(35) OUTPUT,  @returnsNoticeDate NVARCHAR(10) OUTPUT)
AS
BEGIN
 SELECT TOP 1  @returnsNoticeNumber = DAT_WartoscTxt FROM cdn.DokAtrybuty WHERE DAt_TrNId=@faId AND DAt_Kod = 'RETURNSNOTICENUMBER'  ORDER BY DAT_DATID
 SELECT TOP 1  @returnsNoticeDate   = CDN.AtrybutDateTimeValue(DaT_WartoscTxt) FROM cdn.DokAtrybuty WHERE DAt_TrNId=@faId AND DAt_Kod = 'RETURNSNOTICEDATE' ORDER BY DAT_DATID
 IF @returnsNoticeNumber IS NULL SET @returnsNoticeNumber = N''
 IF @returnsNoticeDate IS NULL SET @returnsNoticeDate = N''
 RETURN
END
