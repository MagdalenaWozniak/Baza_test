CREATE FUNCTION CDN.StatusWydaniaCzesciNaZleceniuTxt( @id INT )
RETURNS    NVARCHAR(23)
AS
BEGIN
    DECLARE @status NVARCHAR(23)
    SET @status = CDN.TeRStatusString(902, @id, 0)
    SET @status = REPLACE(@status, 'MM', '')
    SET @status = REPLACE(@status, 'ZD', '')
    IF LTRIM(RTRIM(@status)) = '' SET @status = 'nie wydano'
    RETURN @status
END
