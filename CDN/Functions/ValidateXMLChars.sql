create FUNCTION [CDN].[ValidateXMLChars] (@Chars NVARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
        DECLARE @sResult VARCHAR(MAX)
        DECLARE @i INT
        DECLARE @sChar CHAR
        SET @i = 1
        SET @sResult = ''
        WHILE @i<=len(@Chars)
        BEGIN
                SET @sChar = SUBSTRING(@Chars, @i, 1)
                IF (ASCII(@sChar) NOT IN (9,10,13) AND ASCII(@sChar) < 32)
                  BEGIN
                                  RETURN 1
                             END
                             SET @i = @i+1
        END
     RETURN 0
END
