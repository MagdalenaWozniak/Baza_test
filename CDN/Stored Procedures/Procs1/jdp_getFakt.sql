CREATE PROCEDURE [CDN].jdp_getFakt
 @ID int
AS
SELECT
 TrN_PodID AS KntID,
 Knt_Nazwa1 AS KntNazwa,
 Knt_KodPocztowy AS KodPocztowy,
 Knt_Miasto AS Miasto,
 Knt_Ulica AS Ulica,
 Knt_NrDomu AS NrDomu,
 Knt_NrLokalu AS NrLokalu,
 TrN_Waluta AS Waluta
FROM
 CDN.TraNag
 LEFT OUTER JOIN CDN.Kontrahenci ON TrN_PodID = Knt_KntID
WHERE
 TrN_TrNId = @ID
