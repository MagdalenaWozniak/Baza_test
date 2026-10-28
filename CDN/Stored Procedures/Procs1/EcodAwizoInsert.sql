CREATE PROCEDURE CDN.EcodAwizoInsert
 @name AS VARCHAR(128),
 @value  AS NVARCHAR(350),
 @mode AS INT
AS
BEGIN
 INSERT INTO #EcodAwizoXml (Tag, Wartosc, Flaga) VALUES(@name, @value, @mode)
END
