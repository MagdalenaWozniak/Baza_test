CREATE PROCEDURE CDN.TraElemPorownajAtrybutyDlaDwochPozycji
  @TrEIdPierwszy    INT,
  @TrEIdDrugi     INT
AS
  BEGIN
    SET NOCOUNT ON
 if exists(
  select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr where TrA_TrEId = @TrEIdPierwszy
  EXCEPT
  select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr where TrA_TrEId = @TrEIdDrugi
  )
  or exists
  (
  select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr where TrA_TrEId = @TrEIdDrugi
  EXCEPT
  select TrA_DeAId,TrA_Wartosc from CDN.TraElemAtr where TrA_TrEId = @TrEIdPierwszy
  ) select 1 else select 0
    SET NOCOUNT OFF
  END
