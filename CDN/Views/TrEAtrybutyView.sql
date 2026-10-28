CREATE VIEW CDN.TrEAtrybutyView As
SELECT
Tra_TreId, Tra_DeAId, Tra_Kod, Tra_Wartosc,
Tre_TwrId, Tre_TrnId, Tre_TwrKod, Tre_Lp, Tre_Jm,
Tre_IloscJm, Tre_TwrNazwa, Tre_WartoscNetto,
Tre_CenaT, TrE_DataOpe,
CASE
WHEN DeA_Format=2 THEN CASE WHEN IsNumeric(Replace(Tra_Wartosc, ',','.' ))=1 THEN Cast(Replace(Tra_Wartosc, ',','.' ) As Decimal(37,4)) ELSE -999999999999999 END
WHEN DeA_Format=4 THEN CASE WHEN IsNumeric(TrA_Wartosc)=1 THEN CAST(TrA_Wartosc AS DECIMAL(37,4)) ELSE -999999999999999 END
ELSE -999999999999999 END As 'TrA_WartoscDecimal'
FROM CDN.TraElemAtr
JOIN CDN.DefAtrybuty ON TrA_DeAId = DeA_DeAId
JOIN CDN.TraElem on Tra_TreId = Tre_TreId
