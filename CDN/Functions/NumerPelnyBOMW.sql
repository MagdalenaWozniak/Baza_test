CREATE FUNCTION CDN.NumerPelnyBOMW(@BRaID INT, @Numer INT, @Kierunek INT)
RETURNS NVARCHAR(30)
WITH SCHEMABINDING
AS
BEGIN
DECLARE @NumerStr NVARCHAR(10), @NumerStrS NVARCHAR(10), @BRaSymbol NVARCHAR(10), @NumerOut NVARCHAR(30)
SET @NumerStrS = LTRIM(CAST(@Numer AS NVARCHAR(10)))
SET @NumerStr =
CASE
WHEN LEN(@NumerStrS)<6 THEN REPLICATE('0', 6 - LEN(@NumerStrS)) + @NumerStrS
ELSE @NumerStrS
END
SET @BRaSymbol = (SELECT BRa_Symbol FROM cdn.BnkRachunki WHERE BRa_BRaID = @BRaID)
IF @Kierunek = -1
SET @NumerOut = 'BOMWKW/' + @NumerStrS + '/' + @BRaSymbol
ELSE
BEGIN
IF @Kierunek = 1
SET @NumerOut = 'BOMWKP/' + @NumerStrS + '/' + @BRaSymbol
ELSE
SET @NumerOut = 'BOMW/' + @NumerStrS + '/' + @BRaSymbol
END
RETURN @NumerOut
END
