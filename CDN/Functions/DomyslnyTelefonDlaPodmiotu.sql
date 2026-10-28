CREATE  FUNCTION CDN.DomyslnyTelefonDlaPodmiotu(@podmiotTyp INT, @podmiotId INT)
RETURNS NVARCHAR(100)
BEGIN
DECLARE @result NVARCHAR(100)
SELECT TOP 1 @result = Pod_TelefonSms FROM cdn.PodmiotyView WHERE Pod_PodmiotTyp = @podmiotTyp AND Pod_PodId = @podmiotId
IF @result IS NULL SET @result = N''
IF Len(LTrim(RTrim(@result))) = 0 AND @podmiotTyp = 1
BEGIN
 SELECT TOP 1 @result = KnO_TelefonSms FROM cdn.KntOsoby WHERE KnO_KntId = @podmiotId AND KnO_Domyslny = 1
END
IF @result IS NULL SET @result = N''
RETURN @result
END
