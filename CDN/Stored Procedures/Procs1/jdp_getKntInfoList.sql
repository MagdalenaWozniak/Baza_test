CREATE PROCEDURE [CDN].jdp_getKntInfoList
   @Group NVARCHAR(255) = ''
AS
SELECT
   Knt_KntID AS ID,
   Knt_Kod AS Akronim,
   '/' + Knt_Grupa AS Grupa,
   CASE
      WHEN RTRIM(Knt_Nazwa1) = '' THEN Knt_Kod
      ELSE RTRIM(Knt_Nazwa1)
   END AS Nazwa
FROM
   CDN.Kontrahenci
WHERE
   Knt_Grupa = REPLACE(@Group, '//', '/')
ORDER BY
   Knt_Nazwa1
