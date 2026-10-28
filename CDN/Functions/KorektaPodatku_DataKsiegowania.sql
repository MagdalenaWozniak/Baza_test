CREATE FUNCTION CDN.KorektaPodatku_DataKsiegowania(@DataWystawienia DATETIME, @RycID INTEGER, @KprID INTEGER, @DekID INTEGER)
RETURNS DATETIME
AS
BEGIN
 DECLARE @DataKsiegowania DATETIME
  SET @DataKsiegowania = @DataWystawienia;
 DECLARE @RodzajKsi TINYINT
 Set @RodzajKsi = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1204)
 IF @RodzajKsi = 1 AND @RycID IS NOT NULL
  SELECT @DataKsiegowania = RYC_DataWpi FROM CDN.Ryczalt WHERE RYC_RycID = @RycID
 ELSE IF @RodzajKsi = 2 AND @KprID IS NOT NULL
  SELECT @DataKsiegowania = KPR_DataOpe FROM CDN.ZapisyKPR WHERE KPR_KPRID = @KprID
 ELSE IF @RodzajKsi = 3 AND @DekID IS NOT NULL
  SELECT @DataKsiegowania = DeN_DataDok FROM CDN.DekretyNag WHERE DeN_DeNId = @DekID
 RETURN @DataKsiegowania
END
