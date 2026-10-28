CREATE PROCEDURE CDN.rsTraVat @TrNId INT
AS
SELECT
 TrV_Stawka,
 TrV_Flaga,
 Sum(TrV_Netto) As TrV_Netto,
 Sum(TrV_Vat) As TrV_Vat,
 Sum(TrV_Brutto) As TrV_Brutto,
 Sum(TrV_NettoWal) As TrV_NettoWal,
 Sum(TrV_VatWal) As TrV_VatWal,
 Sum(TrV_BruttoWal) As TrV_BruttoWal
FROM CDN.fnTraVat(@TrnId)
GROUP BY TrV_Stawka, TrV_Flaga
ORDER BY TrV_Stawka, TrV_Flaga
