CREATE FUNCTION CDN.StatusWydaniaCzesciNaZleceniu( @id INT)
RETURNS    INT
AS
BEGIN
    DECLARE @wynik INT, @status NVARCHAR(255)
 SET @wynik = 0
    SET @status = CDN.TeRStatusString(902, @id, 0)
    SET @status = REPLACE(@status, 'MM', '')
    SET @status = REPLACE(@status, 'ZD', '')
    IF LTRIM(RTRIM(@status)) <> ''
    SET @wynik = 1
    RETURN @wynik
END
