CREATE PROCEDURE [CDN].jdp_getTwrGroupList
   @Group NVARCHAR(255) = ''
AS
DECLARE @GroupRep As NVARCHAR(255)
IF @Group = ''
   SET @GroupRep = 'Grupa Główna'
ELSE
   SET @GroupRep = ' ' + REPLACE('/' + @Group, '/', '\ ')
SELECT
   0 AS ID,
   Kod AS Nazwa,
   '' AS Opis
FROM
   CDN.TwrGrupyView
WHERE
    GrONumer = (SELECT GIDNumer FROM CDN.TwrGrupyView WHERE Sciezka = @GroupRep)
    AND GIDNumer <> 0
ORDER BY Kod
