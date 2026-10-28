CREATE FUNCTION CDN.EcodPrzedKorekta(@TrEId AS INT, @iloscPoKor AS DECIMAl(15,4), @korekta INT, @mode AS INT)
RETURNS DECIMAL(15,4)
AS
BEGIN
 DECLARE @Wynik nvarchar(15)
 SET @Wynik = ''
 IF @mode = 1 Select TOP 1 @Wynik = IsNull(IloscJMOrg, 0.0000)  FROM CDN.TraElemKorektaForEcod(@TrEId)
 IF @mode = 2 Select TOP 1 @Wynik = IsNull(CenaTOrg, 0.00)   FROM CDN.TraElemKorektaForEcod(@TrEId)
    IF @mode = 3 Select TOP 1 @Wynik = IsNull(StawkaVatOrg, 22.00)  FROM CDN.TraElemKorektaForEcod(@TrEId)  --As PreviousTaxRate,
    IF @mode = 4 Select TOP 1 @Wynik = IsNull(FlagaVatOrg, 2)   FROM CDN.TraElemKorektaForEcod(@TrEId)
    IF @mode = 5
    BEGIN
 IF @korekta = 2
   Select TOP 1 @Wynik = ((WartoscNOrg - ((IloscJMOrg-@iloscPoKor) * CenaTOrg))*StawkaVatOrg)/100 FROM CDN.TraElemKorektaForEcod(@TrEId)  --As PreviousTaxAmount,
 ELSE
   Select TOP 1 @Wynik = (WartoscNOrg*StawkaVatOrg)/100 FROM CDN.TraElemKorektaForEcod(@TrEId)  --As PreviousTaxAmount,
    END
    IF @mode = 6
    BEGIN
 IF @korekta = 2
         Select TOP 1 @Wynik = IsNull(((WartoscNOrg - ((IloscJMOrg-@iloscPoKor) * CenaTOrg))), 0.00)  FROM CDN.TraElemKorektaForEcod(@TrEId) -- As PreviousNetAmount,
 ELSE
  Select TOP 1 @Wynik = IsNull(WartoscNOrg, 0.00) FROM CDN.TraElemKorektaForEcod(@TrEId) -- As PreviousNetAmount,
    END
    IF @mode = 7
    BEGIN
 IF @korekta = 2
  Select TOP 1 @Wynik = Sum(IsNull(((WartoscNOrg - ((IloscJMOrg-@iloscPoKor) * CenaTOrg))), 0.00)) FROM CDN.TraElemKorektaForEcod(@TrEId) WHERE FlagaVatOrg NOT IN (1,4) -- As PreviousTaxableBasisAmount
 ELSE
  Select TOP 1 @Wynik = Sum(IsNull(WartoscNOrg, 0.00)) FROM CDN.TraElemKorektaForEcod(@TrEId) WHERE FlagaVatOrg NOT IN (1,4) -- As PreviousTaxableBasisAmount
     END
 RETURN LTrim(@Wynik)
END
