CREATE FUNCTION [CDN].[DetalNumerPelny](@Numer INT, @Seria NVARCHAR(31))
RETURNS NVARCHAR(30)
WITH SCHEMABINDING
AS
BEGIN
DECLARE @NumerStr NVARCHAR(10), @NumerStrS NVARCHAR(10), @NumerOut NVARCHAR(30)
SET @NumerStrS = LTRIM(CAST(@Numer AS NVARCHAR(10)))
SET @NumerStr =
 CASE
  WHEN LEN(@NumerStrS)<6 THEN REPLICATE('0', 6 - LEN(@NumerStrS)) + @NumerStrS
  ELSE @NumerStrS
 END
SET @NumerOut = REPLACE(@Seria, '@numerS', @NumerStrS)
SET @NumerOut = REPLACE(@NumerOut, '@numer', @NumerStr)
RETURN @NumerOut
END
