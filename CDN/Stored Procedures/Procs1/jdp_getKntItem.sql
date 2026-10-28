CREATE PROCEDURE [CDN].jdp_getKntItem
   @ID int
AS
SELECT
   Knt_KntID AS ID,
   Knt_Kod AS Akronim,
   '/' + Knt_Grupa AS Grupa,
   RTRIM(Knt_Nazwa1) + CHAR(13) + CHAR(10) + LTRIM(Knt_Nazwa2) AS Nazwa,
   Knt_Kodpocztowy AS KodPocztowy,
   Knt_Miasto AS Miasto,
   Knt_Ulica AS Ulica,
   Knt_NrDomu AS NrDomu,
   Knt_NrLokalu AS NrLokalu,
   Knt_Kraj AS Kraj,
   Knt_Regon AS Regon,
   Knt_Pesel AS Pesel,
   Knt_NipE AS Nip,
   Tel = CASE WHEN Knt_Telefon1 <> '' AND Knt_Telefon2 <> '' THEN Knt_Telefon1 + ', ' + Knt_Telefon2
              ELSE Knt_Telefon1 + Knt_Telefon2
         END,
   Knt_Fax AS Fax,
   Knt_Email AS Email,
   Knt_Opis AS Opis,
   Knt_Export AS Export,
   Kat_KodSzczegol AS KatKod,
   Kat_Opis AS KatOpis
FROM
   CDN.Kontrahenci
   LEFT JOIN CDN.Kategorie ON Knt_KatID = Kat_KatID
WHERE
   Knt_KntID = @ID
