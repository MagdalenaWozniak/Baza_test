CREATE PROCEDURE CDN.EcodCatalogueInsert
 @name AS VARCHAR(128),
 @value  AS NVARCHAR(350),
 @mode AS INT
AS
BEGIN
 INSERT INTO #EcodCatalogueXmlTable (Tag, Wartosc, Flaga) VALUES(@name, @value, @mode)
END
