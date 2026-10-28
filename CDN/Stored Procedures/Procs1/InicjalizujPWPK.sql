CREATE PROCEDURE CDN.InicjalizujPWPK @TreOrgId INT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE
     @TrE_Ilosc DECIMAL(15,4),
     @TrE_PdrId INT
  -- Pobranie danych ze wszystkich elementów grupy korekt
  SELECT
    @TrE_Ilosc = SUM(IsNull(TrE_Ilosc,0)),
    @TrE_PdrId = MAX(TrE_PdrId)
  FROM CDN.TraElem
    JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
  WHERE TrN_Bufor <> 1 AND TrE_Aktywny = 1 AND (tre_treid=@TreOrgId  or tre_zwrid=@TreOrgId)
  SELECT
    @TrE_Ilosc as TrE_Ilosc,
    @TrE_PdrId as TrE_PdrId,
    A.Pde_PdeID,
    A.Pde_TwrId,
    A.Pde_MagId,
    A.Pde_IloscJM,
    A.PdE_IloscJM + SUM(IsNull(B.PdE_IloscJM,0))as PdE_IloscMaxKor,
    A.Pde_JM,A.Pde_JMPrzelicznikL,
    A.Pde_JMPrzelicznikM,
 A.Pde_WartoscZakupu + SUM(IsNull(B.Pde_WartoscZakupu,0))as Pde_WartoscZakupu,
  max(A.PdE_Lp) as PdE_Lp,
  max(A.PdE_TrEId)  as TrEId,
   A.PdE_WyborDostaw
  FROM CDN.ProdElem A
    LEFT OUTER JOIN ( SELECT
                        PdE_ZwrId= PdE_ZwrId,
                        PdE_IloscJM  = PdE_IloscJM,
      Pde_WartoscZakupu = Pde_WartoscZakupu
                        FROM CDN.ProdElem
                          JOIN cdn.TraElem ON TrE_TrEId = PdE_TrEId AND TrE_Aktywny = 1
                          JOIN cdn.TraNag  ON TrN_TrNId = TrE_TrNId AND TrN_Korekta <> 5 AND TrN_Bufor = 0
                        WHERE PdE_TrEId IN ( select tre_treid
                                               from cdn.traelem
                                               where TrE_Aktywny = 1
                                                 and (tre_treid=@TreOrgId  or tre_zwrid=@TreOrgId)
                                           )
                          AND PdE_ZwrId IS NOT NULL
                     ) AS B ON B.PdE_ZwrId = A.PdE_PdEId
  WHERE A.PdE_TreId IN ( select tre_treid
                           from cdn.traelem
                           where TrE_Aktywny = 1
                             and (tre_treid=@TreOrgId  or tre_zwrid=@TreOrgId)
                       )
    AND A.PdE_ZwrID IS NULL --@TreOrgId
  GROUP BY A.PdE_PdEId,A.Pde_IloscJM,A.Pde_PdeID,A.Pde_TwrId,A.Pde_MagId,A.Pde_JM,A.Pde_JMPrzelicznikL,A.Pde_JMPrzelicznikM,A.Pde_WartoscZakupu,A.PdE_WyborDostaw
  ORDER BY TrEId, PdE_Lp
  SET NOCOUNT OFF
END
