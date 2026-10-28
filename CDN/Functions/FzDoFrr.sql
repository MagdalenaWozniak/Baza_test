CREATE FUNCTION CDN.FzDoFrr(@TrNId INT, @TrnRodzaj INT)
RETURNS INT
AS
BEGIN
  DECLARE @Wynik  INT
  DECLARE @FrrId  INT
  SET @Wynik = 0
  IF  @TrnRodzaj/1000 = 301 --anulowanie FZ
    BEGIN
      SELECT TOP 1 @FrrId = IsNull(TrN_TrnId,0)
      FROM CDN.TraNag JOIN cdn.TraNagRelacje ON TrN_TrNId = TrR_TrNId
      WHERE TrN_Rodzaj = 350008 AND TrR_FaID = @TrNId
      SET @Wynik = IsNull(@FrrId, 0)
    END
  RETURN @Wynik
END
