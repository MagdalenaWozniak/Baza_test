CREATE PROCEDURE [CDN].[IGaleria_EksportXML]
 @Opcje INT          -- Maska opcji eksportu
 AS
SET NOCOUNT ON
 --SELECT '<?xml version="1.0" encoding="windows-1250" ?> '
 --SELECT '<ROOT xmlns="&quot;http://www.comarch.pl/cdn&quot;">'
DECLARE
   @ExpCennik    INT -- Eksport cennika (0 - nie, 1 - tak)
  ,@ExpCennikTyp   INT -- Typ eksportu cennika (0 - różnicowy, 1 - pełny)
  ,@ExpDaneBinarneTyp  INT -- Typ eksportu danych binarnych (0 - różnicowy, 1 - pełny)
  ,@ExpDaneBinarnePaczki INT -- Eksport danych binarnych w paczkach (0 - pierwsza paczka, 1 - kolejne paczki z sami danymi binarnymi)
  ,@ExpZasoby    INT -- Eksport Zasobow (0 - nie,  1 - tak)
  ,@ExpZestawy   INT --Eksport zestawów( 0 - nie, 1 - tak )
  ,@ExpZestawyTyp   INT --Typ Eksport zestawów(0 - różnicowy, 1 - pełny)
  ,@ExpTylkoCeny   INT --eksport tylko cen
  ,@ExpPdf   INT --eksport pdf
DECLARE @DABID INT   -- ID danych binarnych, które były wysłane jako ostatnie w poprzedniej paczce
SELECT   @ExpCennik    =  @Opcje & 1
  ,@ExpCennikTyp   = (@Opcje & 2) / 2
  ,@ExpDaneBinarnePaczki = (@Opcje & 64) / 64
  ,@ExpZasoby    = (@Opcje & 128) / 128
  ,@ExpZestawy   = (@Opcje & 1024) / 1024
  ,@ExpZestawyTyp   = (@Opcje & 2048) / 2048
  ,@ExpTylkoCeny   = (@Opcje & 4096) / 4096
  ,@ExpPdf   = (@Opcje & 8192) / 8192
   IF @ExpDaneBinarnePaczki = 0 AND @Opcje <> 0
  BEGIN
  UPDATE CDN.Firma SET Fir_Wartosc = 0 WHERE Fir_Numer = 1854
  END
SELECT '<ROOT>'
 EXEC CDN.IGaleria_EksportInfoBlok @Opcje
IF @ExpDaneBinarnePaczki = 0 AND @Opcje = 0
BEGIN
  SELECT '<PTWI>'
  EXEC CDN.IGaleria_EksportPtw
  SELECT '</PTWI>'
END
IF @ExpDaneBinarnePaczki = 0 AND @ExpPdf = 1
BEGIN
  EXEC CDN.IGaleria_EksportPDF
END
IF @ExpDaneBinarnePaczki = 0 AND @Opcje <> 0
BEGIN
  IF (@ExpZasoby = 1)
  BEGIN
   SELECT '<ZSBI>'  -- Eksport stanów handlowych
    EXEC CDN.IGaleria_EksportTwrZasoby  1 -- eksport pełny zasobów towaru
   SELECT '</ZSBI>'
  END
  IF (@ExpCennik = 1)
  BEGIN
     IF(@ExpTylkoCeny =1)
     BEGIN
  EXEC CDN.IGaleria_EksportTwr  @ExpCennikTyp, @ExpTylkoCeny
     END
     ELSE
  BEGIN
   SELECT '<TWRI>'
   EXEC CDN.IGaleria_EksportTwr  @ExpCennikTyp, @ExpTylkoCeny
   SELECT '</TWRI>'
   SELECT '<PDRI>'
   EXEC CDN.IGaleria_EksportProducenci  @ExpCennikTyp
   SELECT '</PDRI>'
   SELECT '<MRKI>'
   EXEC CDN.IGaleria_EksportMarki  @ExpCennikTyp
   SELECT '</MRKI>'
   SELECT '<TWRD>'
   EXEC CDN.IGaleria_EksportTwrUsuwanie
   SELECT '</TWRD>'
  END
  END
END
ELSE IF @ExpDaneBinarnePaczki <> 0 AND @Opcje <> 0
BEGIN
  SELECT '<DABI>'
  EXEC CDN.IGaleria_EksportDaneBinarne  @ExpCennikTyp
  SELECT '</DABI>'
END
IF (@ExpDaneBinarnePaczki = 0 AND @Opcje <> 0 AND @ExpZestawy = 1 )
BEGIN
  EXEC CDN.IGaleria_EksportCrosSeling @ExpZestawyTyp
  EXEC CDN.IGaleria_EksportCrosSelingUsuwanie
END
SELECT '</ROOT>'
