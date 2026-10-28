CREATE PROCEDURE CDN.DetalStan_WydrukiPozycjeDokumentuKorygowanego
@receiptId int,
@corrId int
AS
BEGIN
SET NOCOUNT ON
SELECT A.DSTrE_TwrNazwa, A.DSTrE_TwrKod, A.DSTrE_CenaPoRabacie,
A.DSTrE_WartoscBrutto + SUM(CASE WHEN C.DSTrN_DSTrNId = @corrId THEN 0 ELSE IsNull(B.DSTrE_WartoscBrutto,0.00) END),
A.DSTrE_Stawka, A.DSTrE_Flaga,
A.DSTrE_Ilosc + SUM(CASE WHEN C.DSTrN_DSTrNId = @corrId THEN 0 ELSE IsNull(B.DSTrE_Ilosc,0.00) END),
A.DSTrE_Jm, A.DSTrE_Kaucja, A.DSTrE_Lp,
A.DSTrE_Cena, A.DSTrE_Rabat
FROM CDN.DetalStanTraElem A
LEFT OUTER JOIN (CDN.DetalStanTraElem B JOIN CDN.DetalStanTraNag C ON B.DSTrE_DSTrNId = C.DSTrN_DSTrNId AND C.DSTrN_Korekta = 1 AND C.DSTrN_Bufor<>1)
ON A.DSTrE_DSTrEId = B.DSTrE_ZwrId
WHERE A.DSTrE_DSTrNId = @receiptId AND A.DSTrE_StornoId = 0 AND A.DSTrE_DSTrEID in
(select DSTrE_ZwrId from cdn.detalstantraelem where DSTrE_DSTrNId = @corrId) GROUP BY
A.DSTrE_DSTrEId, A.DSTrE_Ilosc, A.DSTrE_TwrNazwa, A.DSTrE_TwrKod, A.DSTrE_CenaPoRabacie, A.DSTrE_Stawka,
A.DSTrE_Flaga, A.DSTrE_Jm, A.DSTrE_Kaucja, A.DSTrE_WartoscBrutto, A.DSTrE_Lp, A.DSTrE_Cena, A.DSTrE_Rabat
SET NOCOUNT OFF
END
