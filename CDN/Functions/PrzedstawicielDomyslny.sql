CREATE FUNCTION CDN.PrzedstawicielDomyslny(@KntId INT)
RETURNS NVARCHAR(40)
AS
BEGIN
DECLARE @wynik NVARCHAR(40)
IF EXISTS(SELECT * FROM cdn.KntOsoby WHERE KnO_Domyslny = 1 AND KnO_KntId = @KntId AND KnO_LpAnonimizacji IS NULL)
 SELECT TOP 1 @wynik = KnO_Nazwisko FROM cdn.KntOsoby WHERE KnO_Domyslny = 1 AND KnO_KntId = @KntId
ELSE
 SELECT TOP 1  @wynik = KnO_Nazwisko FROM cdn.KntOsoby WHERE KnO_KntId = @KntId AND KnO_LpAnonimizacji IS NULL ORDER BY KnO_KnOId
RETURN IsNull(@wynik, '')
END
