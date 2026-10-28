CREATE PROCEDURE CDN.rsTraVatKat @TrNId INT
AS
SELECT
 @TrNId as TrN_TrNId,
 TrV_Stawka,
 TrV_Flaga,
 Sum(TrV_Netto)     As TrV_Netto,
 Sum(TrV_Vat)       As TrV_Vat,
 Sum(TrV_Brutto)    As TrV_Brutto,
 TrV_KatID,
 TrV_Rodzaj,
 TrV_Typ,
 Sum(TrV_NettoWal)  As TrV_NettoWal,
 Sum(TrV_VatWal)    As TrV_VatWal,
 Sum(TrV_BruttoWal) As TrV_BruttoWal
FROM CDN.TraVatKat(@TrnId)
GROUP BY TrV_Stawka, TrV_Flaga, TrV_KatId, TrV_Rodzaj, TrV_Typ
ORDER BY TrV_Stawka, TrV_Flaga, TrV_Brutto ASC
