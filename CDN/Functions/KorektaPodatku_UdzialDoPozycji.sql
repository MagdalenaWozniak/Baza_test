CREATE FUNCTION CDN.KorektaPodatku_UdzialDoPozycji(@DataWystawienia DATETIME, @RycID INTEGER, @KprID INTEGER, @DekID INTEGER, @PraID INTEGER)
RETURNS REAL
AS
BEGIN
 DECLARE @Udzial REAL
  SET @Udzial = 1;
 DECLARE @RodzajKsi TINYINT
 Set @RodzajKsi = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1204)
 DECLARE @Typ INTEGER
 IF @RodzajKsi = 1
  SET @Typ = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1177)
 ELSE
  SET @Typ = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1122)
 DECLARE @DataKsiegowania DATETIME
  SET @DataKsiegowania = CDN.KorektaPodatku_DataKsiegowania(@DataWystawienia, @RycID, @KprID, @DekID)
 IF @PraID IS NOT NULL
 BEGIN
  SELECT @Udzial = ISNULL(
   (SELECT TOP 1 PPU_UdzialL / PPU_UdzialM
   FROM CDN.PracPitMies
   LEFT OUTER JOIN CDN.PracPitDzialalnosci ON PPD_PPMId = PPM_PPMId
   LEFT OUTER JOIN CDN.PracPitUdzialy ON PPU_PPDID = PPD_PPDId
   WHERE PPM_PraId = @PraID
   AND PPD_Glowna = 1
   AND PPD_Typ = @Typ
   AND PPD_DkNID IS NULL
   AND PPU_DataOd <= @DataKsiegowania
   AND
   (
    PPU_DataDo >= @DataKsiegowania OR DATEADD(DAY,  0 - DAY(DATEADD(MONTH, 1, PPU_DataDo)), DATEADD(MONTH, 1, PPU_DataDo)) = PPU_DataDo
   )
   ORDER BY PPM_Rok DESC, PPM_Miesiac DESC)
  , 0)
 END
 RETURN @Udzial
END
