CREATE PROCEDURE CDN.EcodOrderInsert
 @name AS VARCHAR(128),
 @value  AS NVARCHAR(350),
 @mode AS INT
AS
BEGIN
 INSERT INTO #EcodOrderXml (Tag, Wartosc, Flaga) VALUES(@name, @value, @mode)
END
