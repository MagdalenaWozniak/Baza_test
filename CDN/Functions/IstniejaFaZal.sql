CREATE FUNCTION CDN.IstniejaFaZal(@TrNId INT)
RETURNS INT
AS
BEGIN
  DECLARE @FaPfZal        INT
  DECLARE @TrnRodzaj      INT
  SELECT TOP 1 @TrnRodzaj = IsNull(TrN_Rodzaj,0) FROM cdn.TraNag WHERE TrN_TrNId = @TrNId
  SET @FaPfZal = 0
  IF  @TrnRodzaj/1000 = 302 -- tylko dla faktur sprzedaży
    BEGIN
      IF (EXISTS (SELECT TrN_TrNId FROM cdn.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TrNId <> @TrnID AND TrN_Rodzaj IN (302200,302202) AND TrN_Bufor <> -1 AND
                  TrR_FaId IN (SELECT IsNull(TrN_TrNId,0) FROM cdn.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 320 AND TrR_FaId = @TrnID)))
        SET @FaPfZal = 1
    END
  RETURN @FaPfZal
END
