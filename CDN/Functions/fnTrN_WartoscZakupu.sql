CREATE FUNCTION CDN.fnTrN_WartoscZakupu ( @TrN_TrNId INT )
RETURNS DECIMAL(15,2)
AS
BEGIN
  RETURN
         (
            SELECT ISNULL(SUM(CASE WHEN TrS_Rodzaj in (312000,312008) AND TrS_Ilosc < 0 AND TrS_ZwrId IS NULL THEN 0
                                   WHEN (TrS_Rodzaj = 308000 OR TrS_Rodzaj = 308011) AND TrS_Ilosc < 0                       THEN 0
                                   ELSE TrS_Wartosc
                              END),0)
            FROM cdn.TraSElem
            JOIN ( SELECT TrE_TrEId = TrE_TrEId
                   FROM cdn.TraElem
                   WHERE TrE_TrNId = @TrN_TrNId
                   UNION ALL
                   SELECT TrE_TrEId = WZ.TrE_TrEId
                     FROM ( SELECT TrE_TrEId = TrE_TrEId,  TrE_LpPow = TrE_LpPow, TrE_TwrId = TrE_TwrId
                            FROM cdn.TraElem
                              JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
                              JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId AND TrR_Flaga <> 1
                             WHERE TrR_FaId = @TrN_TrNId AND TrE_TypDokumentu NOT IN ( 318,308,309,301,304,317 )
        AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306)  AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307)  AND TrR_FaTyp != 320
                          ) AS WZ
                     JOIN ( SELECT TrE_TrEId = TrE_TrEId, TrE_LpPow = TrE_LpPow, TrE_TwrId = TrE_TwrId
                            FROM cdn.TraElem
                            WHERE TrE_TrNId = @TrN_TrNId
                          ) AS FA ON WZ.TrE_LpPow = FA.TrE_LpPow AND WZ.TrE_TwrID = FA.TrE_TwrID
                 ) AS Elem ON TrS_TrEId = Elem.TrE_TrEId
         )
          +
        (
            SELECT ISNULL(SUM(TrE_KosztUslugi), 0 )
            FROM cdn.TraElem
            WHERE TrE_TrNId = @TrN_TrNId
         )
END
