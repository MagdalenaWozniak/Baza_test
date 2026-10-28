CREATE PROCEDURE [CDN].jdp_getFaktElemList
 @ID int
AS
SELECT
 TrE_TrEID AS ID,
 TrE_TwrNazwa AS Nazwa,
 TrE_Stawka AS Stawka,
 TrE_Ilosc AS Ilosc,
 TrE_CenaW AS Cena,
 TrE_WartoscNetto AS Netto,
 TrE_WartoscBrutto AS Brutto
FROM
 TraElem
WHERE
 TrE_TrNId = @ID
ORDER BY
 TrE_Lp
