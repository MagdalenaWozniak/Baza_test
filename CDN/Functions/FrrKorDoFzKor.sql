CREATE FUNCTION CDN.FrrKorDoFzKor(@TrNId INT, @TrnRodzaj INT)
RETURNS INT
AS
BEGIN
 DECLARE @Wynik  INT
  DECLARE @FrrId  INT
  SET @Wynik = 0
  IF  @TrnRodzaj/1000 = 350
    BEGIN
      SELECT TOP 1 @FrrId = IsNull(TrN_TrnId,0)
      FROM CDN.TraNag JOIN cdn.TraNagRelacje ON TrN_TrNId = TrR_TrNId
      WHERE TrN_Rodzaj in( 301051,301052,301053,301050) AND TrR_FaID = @TrNId
      SET @Wynik = IsNull(@FrrId, 0)
    END
  RETURN @Wynik
END
