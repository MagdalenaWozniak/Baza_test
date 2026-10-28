CREATE FUNCTION CDN.KorektaPodatku_PozycjeVAT(@VaNID INT)
RETURNS decimal(15,2)
AS
BEGIN
 DECLARE @SumNetto decimal(15, 2)
 DECLARE @SumBrutto decimal(15, 2)
 SELECT @SumNetto = ISNULL(SUM(VaT_Netto), 0)
 FROM CDN.VatTab
 WHERE VaT_VaNID = @VaNID AND VaT_Odliczenia <> 0
 SELECT @SumBrutto = ISNULL(SUM(VaT_Netto + VaT_VAT), 0)
 FROM CDN.VatTab
 WHERE VaT_VaNID = @VaNID AND VaT_Odliczenia = 0
 RETURN @SumNetto + @SumBrutto
END
