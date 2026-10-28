CREATE PROCEDURE [CDN].jdp_getTwrItem
   @ID int,
   @KntID int
AS
DECLARE @KntCeny tinyint
SELECT @KntCeny = Knt_Ceny FROM CDN.Kontrahenci WHERE Knt_KntID = @KntID
SELECT
   Twr_TwrID AS ID,
   Twr_Kod AS Kod,
   Twr_Typ AS Typ,
   '' AS Grupa,
   RTRIM(Twr_Nazwa) AS Nazwa,
   Twr_EAN AS EAN,
   Twr_URL AS URL,
   Twr_Opis AS Opis,
   Twr_Produkt AS Produkt,
   Kat_KodSzczegol AS KatKod,
   Twr_Kategoria AS KatOpis,
   Twr_Jm AS Jm,
   Twr_JmCalkowite AS JmCalkowite,
   Twr_Stawka AS Vat,
   Twr_Flaga AS VatTyp,
   CASE
      WHEN @KntCeny <> 0 THEN @KntCeny
      ELSE Twr_TwCNumer
   END AS TwCNumer
FROM
   CDN.Towary
   LEFT JOIN CDN.Kategorie ON Twr_KatID = Kat_KatID
WHERE
   Twr_TwrID = @ID
