CREATE view [CDN].[WartoscZakupuFAPAView] as
SELECT     S1.EId,
MAX(
case when ISNULL(S1.W, 0) <>0 then ISNULL(S1.W, 0) else
 case when ISNULL(S2.W, 0) <>0 then ISNULL(S2.W, 0) else
  case when ISNULL(S3.W, 0) <>0 then ISNULL(S3.W, 0) else
   case when ISNULL(S4.W, 0) <>0 then ISNULL(S4.W, 0) else
    case when ISNULL(S5.W, 0) <>0 then ISNULL(S5.W, 0) end
    end
  end
 end
end
 )
 AS WartoscZakupu,
CONVERT(int,
                      CDN.TypSkojarzenia2(S1.NId,S1.EId)) AS Skojazone
FROM         (SELECT     TrE_TrEID AS EId, ISNULL(TrE_KosztUslugi, 0) AS W
                       FROM          CDN.TraElem) AS S3 LEFT OUTER JOIN
                          (
        /*SELECT     CDN.TraElem.TrE_TrEID AS EId, ISNULL(SUM(CASE WHEN TrS_Rodzaj = 312000 AND TrS_Ilosc < 0 AND TrS_ZwrId IS NULL
                                                   THEN 0 ELSE TrS_Wartosc END), 0) AS W, Trn.TrN_TrNID AS NId
                            FROM          CDN.TraElem LEFT OUTER JOIN
                                                   CDN.TraSElem ON CDN.TraElem.TrE_TrEID = CDN.TraSElem.TrS_TrEId LEFT OUTER JOIN
                                                   CDN.TraNag AS Trn ON Trn.TrN_TrNID = CDN.TraElem.TrE_TrNId
                            GROUP BY CDN.TraElem.TrE_TrEID, Trn.TrN_TrNID*/
       select CDN.TraElem.TrE_TrEID AS EId ,PP.wartoscZakupu as W ,Trn1.TrN_TrNID AS NId
       from CDN.TraElem LEFT OUTER JOIN cdn.traNag as TrN1 on trn1.Trn_TrnId = tre_trnid
       join
          (
           select tre_treID,  ISNULL(SUM(CASE WHEN TrS_Rodzaj in (312000,312008) AND TrS_Ilosc < 0 AND TrS_ZwrId IS NULL THEN 0
                  WHEN (TrS_Rodzaj = 308000 OR TrS_Rodzaj = 308011) AND TrS_Ilosc < 0                       THEN 0
                  ELSE TrS_Wartosc
                END),0) + tre_KosztUslugi  as wartoscZakupu
                from
         (
         select PP.tre_treID,PP.tre_KosztUslugi,TrS_Rodzaj, TrS_Ilosc,TrS_ZwrId,TrS_Wartosc
         from cdn.traelem PP
         --join cdn.traselem on PP.tre_treID = TrS_TrEId
         --join cdn.traelem SS on TrS_TrEId = SS.TrE_TrEId AND SS.tre_lppow=pp.tre_lppow AND ss.TrE_TwrID = pp.TrE_TwrID and ss.TrE_TypDokumentu NOT IN ( 318,309,308,301,304,317 )
         join cdn.traelem SS on SS.tre_lppow=pp.tre_lppow AND ss.TrE_TwrID = pp.TrE_TwrID and ss.TrE_TypDokumentu NOT IN ( 318,309,308,301,304,317 )
         join cdn.TraNagRelacje ON SS.TrE_TrNId = TrR_TrNId AND TrR_Flaga <> 1 AND TrR_FaId = PP.TrE_TrNId AND  NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306)  AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307) AND TrR_FaTyp != 320
         join cdn.traselem on SS.tre_treID = TrS_TrEId
         UNION ALL
         select PP.tre_treID ,PP.tre_KosztUslugi,TrS_Rodzaj, TrS_Ilosc,TrS_ZwrId,TrS_Wartosc
         from cdn.traelem PP
         left join cdn.traselem on PP.tre_treID = TrS_TrEId -- left join, aby dla każdego elementu było choćby 0, nawet gdy nic nie ma w traselem
         ) as TTT
         group BY tre_treID,tre_KosztUslugi
          ) AS PP on CDN.TraElem.TrE_TrEID=PP.Tre_TreID
       ) AS S1 ON S3.EId = S1.EId LEFT OUTER JOIN
                          (
                          SELECT     FA_E.TrE_TrEID AS EId, ISNULL(SUM(CASE WHEN WZ_S.TrS_Rodzaj = 312000 AND WZ_S.TrS_Ilosc < 0 AND WZ_S.TrS_ZwrId IS NULL
                                                   THEN 0 ELSE WZ_S.TrS_Wartosc END), 0) AS W
                            FROM
        CDN.TraSElem AS WZ_S INNER JOIN
        CDN.TraElem AS WZ_E ON WZ_S.TrS_TrEId = WZ_E.TrE_TrEID and wz_e.TrE_TypDokumentu = 306  INNER JOIN
        CDN.TraNag AS WZ_N ON WZ_E.TrE_TrNId = WZ_N.TrN_TrNID  INNER JOIN
        -- Wz razem z selem elem i nag
        cdn.TraNagRelacje on TrR_TrNId = wz_e.tre_trnid and ( TrR_FaTyp=302 or TrR_FaTyp=305 )
        join CDN.TraElem AS FA_E ON FA_E.TrE_TrNId = TrR_FaId
        AND WZ_E.TrE_LpPow = FA_E.TrE_LpPow
                            WHERE      (WZ_E.TrE_TypDokumentu <> 318)
                            GROUP BY FA_E.TrE_TrEID)
                            AS S2 ON S3.EId = S2.EId LEFT OUTER JOIN
                          (SELECT     PA_E.TrE_TrEID AS EId, ISNULL(SUM(CASE WHEN WZ_S.TrS_Rodzaj = 312000 AND WZ_S.TrS_Ilosc < 0 AND WZ_S.TrS_ZwrId IS NULL
                                                   THEN 0 ELSE WZ_S.TrS_Wartosc END), 0) AS W
                            FROM          CDN.TraSElem AS WZ_S INNER JOIN
                                                   CDN.TraElem AS WZ_E ON WZ_S.TrS_TrEId = WZ_E.TrE_TrEID INNER JOIN
                                                   CDN.TraNag AS WZ_N ON WZ_E.TrE_TrNId = WZ_N.TrN_TrNID INNER JOIN
                                                   CDN.TraNag AS FA_N ON FA_N.TrN_TrNID = WZ_N.TrN_FaId INNER JOIN
                                                   CDN.TraElem AS FA_E ON FA_E.TrE_TrNId = WZ_N.TrN_FaId AND WZ_E.TrE_LpPow = FA_E.TrE_LpPow INNER JOIN
                                                   CDN.TraNag AS PA_N ON PA_N.TrN_TrNID = FA_N.TrN_FaId AND PA_N.TrN_TypDokumentu = 305 INNER JOIN
                                                   CDN.TraElem AS PA_E ON PA_E.TrE_TrNId = PA_N.TrN_TrNID AND FA_E.TrE_LpPow = PA_E.TrE_LpPow
                            WHERE      (WZ_E.TrE_TypDokumentu <> 318)
                            GROUP BY PA_E.TrE_TrEID) AS S4 ON S4.EId = S3.EId
                        LEFT OUTER JOIN
                      (select sum( case trs_typ when 1 then -1 *trs_wartosc
       when 2 then trs_wartosc
       else 0 end) as W , EId = E.tre_treid
       from cdn.TraNag join cdn.TraElem as E on e.tre_trnid = trn_trnid
      join cdn.TraNagRelacje  on TrR_TrNId=E.tre_trnId and TrR_FaTyp in (303,304)
      join cdn.TraElem as D on D.tre_trnid = TrR_FaID and E.TrE_LpPow=D.TrE_LpPow
      join CDN.TraSElem ON TrS_TrEId = D.TrE_TrEID
     where trn_Rodzaj in (302101,305101)
     group by E.tre_treid
     )  as S5 on S5.EId = S3.EId
GROUP BY S1.EId, S1.NId
