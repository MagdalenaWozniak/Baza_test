CREATE PROCEDURE CDN.Ustaw_ZwroconoCalaIlosc
@TrN_ZwrId INT
AS
SET NOCOUNT ON
  DECLARE
    @TrN_ZwroconoCalaIlosc INT
  IF EXISTS ( SELECT Ilosc
              FROM
                  ( SELECT Ilosc = MAX(p.TrE_Ilosc) + SUM(ISNULL(k.TrE_Ilosc,0))
                      FROM cdn.TraElem p
                      LEFT OUTER JOIN cdn.TraElem k on p.TrE_TrEId = k.TrE_ZwrId AND k.TrE_Aktywny = 1
                      WHERE p.TrE_TrNId = @TrN_ZwrId
                      GROUP BY p.TrE_TrEId
                      HAVING MAX(p.TrE_Ilosc) + SUM(ISNULL(k.TrE_Ilosc,0)) <> 0
                  ) AS D
  WHERE Ilosc <> 0 )
    SET @TrN_ZwroconoCalaIlosc = NULL
  ELSE
    SET @TrN_ZwroconoCalaIlosc = 1
  UPDATE cdn.TraNag SET TrN_ZwroconoCalaIlosc = @TrN_ZwroconoCalaIlosc  WHERE TrN_TrNId = @TrN_ZwrId
 SET NOCOUNT OFF
