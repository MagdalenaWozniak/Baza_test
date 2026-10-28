CREATE PROCEDURE [CDN].jdp_getKntGroupList
   @Group NVARCHAR(255) = ''
AS
SELECT
   0 AS ID,
   REPLACE(Gru_Nazwa, '/', '//') AS Nazwa,
   Gru_Opis AS Opis
FROM
   CDN.Grupy
WHERE
   Gru_Typ = 31 AND @Group = ''
ORDER BY
   Gru_Nazwa
