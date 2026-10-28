CREATE FUNCTION CDN.AnalitykaWymiaru(@opis nvarchar(4000))
RETURNS nvarchar(4000)
AS
BEGIN
 declare @Result nvarchar(4000) = REVERSE( CDN.KodWymiaru( REVERSE (@opis) ) )
 return @Result
END
