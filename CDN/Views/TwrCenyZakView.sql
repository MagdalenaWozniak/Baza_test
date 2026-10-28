CREATE VIEW CDN.TwrCenyZakView As
SELECT TwC_TwCNumer AS TwCZV_TwCNumer,
TwC_TwrId AS TwCZV_TwrId,
TwC_Wartosc AS TwCZV_Wartosc,
TwC_Waluta AS TwCZV_Waluta
FROM CDN.TwrCeny WHERE TwC_TwCNumer = 1
