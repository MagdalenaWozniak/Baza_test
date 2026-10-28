CREATE PROCEDURE [CDN].jdp_getTwrInfoList
   @Group NVARCHAR(255) = ''
AS
DECLARE @GroupRep As NVARCHAR(255)
IF @Group = ''
   SET @GroupRep = 'Grupa Główna'
ELSE
   SET @GroupRep = ' ' + REPLACE('/' + @Group, '/', '\ ')
SELECT
   Twr_TwrID AS ID,
   Twr_Kod AS Kod,
   Twr_Typ AS Typ,
   Sciezka AS Grupa,
   CASE
      WHEN RTRIM(Twr_Nazwa) = '' THEN Twr_Kod
      ELSE RTRIM(Twr_Nazwa)
   END AS Nazwa
FROM
   CDN.Towary
   JOIN CDN.TwrGrupy On TwG_GIDTyp=16 And TwG_GIDNumer = Twr_GIDNumer
   JOIN CDN.TwrGrupyView on TwG_GroTyp=-16 And TwG_GroNumer=GIDNumer
WHERE   Sciezka = REPLACE(REPLACE(@GroupRep, '//', '/'), '/', '\ ')
ORDER BY
   Twr_Nazwa
