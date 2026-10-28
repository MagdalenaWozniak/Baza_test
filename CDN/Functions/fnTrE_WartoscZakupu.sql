CREATE FUNCTION CDN.fnTrE_WartoscZakupu ( @TrE_TrEId INT, @TrE_TrNId INT, @TrE_LpPow INT ,@TrE_TwrID INT )
RETURNS DECIMAL(15,2)
AS
BEGIN
  RETURN (
            SELECT ISNULL(SUM(CASE WHEN TrS_Rodzaj in (312000,312008) AND TrS_Ilosc < 0 AND TrS_ZwrId IS NULL THEN 0
                                   WHEN (TrS_Rodzaj = 308000 OR TrS_Rodzaj = 308011) AND TrS_Ilosc < 0                       THEN 0
                                   ELSE TrS_Wartosc
                              END),0)
            FROM cdn.TraSElem
            JOIN ( SELECT TrE_TrEId = @TrE_TrEId
                   UNION ALL
                   SELECT TrE_TrEId = TrE_TrEId
                     FROM cdn.TraElem
                       JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
                       JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId AND TrR_Flaga <> 1
                     WHERE TrR_FaId = @TrE_TrNId AND TrE_LpPow = @TrE_LpPow AND TrE_TwrID = @TrE_TwrID AND TrE_TypDokumentu NOT IN ( 318,309,308,301,304,317 )
      AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306)  AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307) AND TrR_FaTyp != 320
                 ) AS Elem ON TrS_TrEId = Elem.TrE_TrEId
         )
END
