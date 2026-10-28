CREATE FUNCTION CDN.KontrahenciZeSchematemWindykacji (@schematId INT)
RETURNS NVARCHAR(1024)
AS
BEGIN
 DECLARE @wynik NVARCHAR(1024)
 SET @wynik = NULL
 SELECT @wynik = COALESCE(@wynik + ',' , '' ) + Knt_Kod
 FROM cdn.Kontrahenci WHERE Knt_WindykacjaSchematId = @schematId
 ORDER BY Knt_Kod
 RETURN @wynik
END
