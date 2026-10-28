CREATE FUNCTION [CDN].[DokZawieraTylkoUslugi] (@TrNId INT)
RETURNS INT
AS
BEGIN
  DECLARE @Wynik            INT
  DECLARE @LiczbaPozycji    INT
  DECLARE @LiczbaUslug      INT
  SET @Wynik = 0
  SELECT @LiczbaPozycji = Count(*) FROM cdn.TraElem WHERE Tre_TrnId = @TrNId
  SELECT @LiczbaUslug   = Count(*) FROM cdn.TraElem
                                   JOIN cdn.Towary ON Twr_Typ = 0 and Tre_TwrId = Twr_TwrId
  WHERE Tre_TrnId = @TrNId
  IF @LiczbaPozycji = @LiczbaUslug
    SET @Wynik = 1
  RETURN @Wynik
END
