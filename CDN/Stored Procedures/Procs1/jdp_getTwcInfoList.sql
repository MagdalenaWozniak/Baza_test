CREATE PROCEDURE [CDN].jdp_getTwcInfoList
   @ID int = 0,
   @CenyZak bit = 1
AS
SELECT
   TwC_TwCNumer AS Numer,
   TwC_Typ AS Typ,
   DfC_Nazwa AS Nazwa,
   TwC_Waluta AS Waluta,
   TwC_Wartosc AS Wartosc
FROM
   CDN.TwrCeny
   LEFT JOIN CDN.DefCeny ON TwC_TwCNumer = DfC_Lp
WHERE
   TwC_TwrID = @ID AND
   (@CenyZak = 1 OR TwC_TwCNumer <> 1)
ORDER BY
   TwC_TwCNumer
