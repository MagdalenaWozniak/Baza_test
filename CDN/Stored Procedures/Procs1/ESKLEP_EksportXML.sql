CREATE PROCEDURE [CDN].[ESKLEP_EksportXML]
  @ID INT             -- ID e-sklepu
 ,@Opcje INT          -- Maska opcji eksportu
 AS
SET NOCOUNT ON
 --SELECT '<?xml version="1.0" encoding="windows-1250" ?> '
 --SELECT '<ROOT xmlns="&quot;http://www.comarch.pl/cdn&quot;">'
DECLARE  @ExpCennik    INT -- Eksport cennika (0 - nie, 1 - tak)
  ,@ExpCennikTyp   INT -- Typ eksportu cennika (0 - różnicowy, 1 - pełny)
  ,@ExpGrup    INT -- Eksport grup (0 - nie, 1 - tak)
  ,@ExpGrupTyp   INT -- Typ eksportu grup (0 - różnicowy, 1 - pełny)
   ,@ExpDaneBinarne  INT -- Eksport danych binarnych (0 - nie, 1 - tak)
  ,@ExpDaneBinarneTyp  INT -- Typ eksportu danych binarnych (0 - różnicowy, 1 - pełny)
  ,@ExpDaneBinarnePaczki INT -- Eksport danych binarnych w paczkach (0 - pierwsza paczka, 1 - kolejne paczki z sami danymi binarnymi)
  ,@ExpZasoby    INT -- Eksport Zasobow (0 - nie,  1 - tak)
  ,@ExpCen    INT -- Export tylko cen ( 0 - nie, 1 - tak )
  ,@ExpKontrahenci  INT -- Export kontrahentów ( 0 - nie, 1 - tak )
  ,@ExpKontrahenciTyp  INT -- Typ Exportu kontrahentów (0 - różnicowy, 1 - pełny)
  ,@ExpZestawy   INT --Eksport zestawów( 0 - nie, 1 - tak )
  ,@ExpZestawyTyp   INT --Typ Eksport zestawów(0 - różnicowy, 1 - pełny)
DECLARE @DABID INT   -- ID danych binarnych, które były wysłane jako ostatnie w poprzedniej paczce
SELECT   @ExpCennik    =  @Opcje & 1
  ,@ExpCennikTyp   = (@Opcje & 2) / 2
  ,@ExpGrup    = (@Opcje & 4) / 4
     ,@ExpGrupTyp   = (@Opcje & 8) / 8
  ,@ExpDaneBinarne  = (@Opcje & 16) / 16
  ,@ExpDaneBinarneTyp  = (@Opcje & 32) / 32
  ,@ExpDaneBinarnePaczki = (@Opcje & 64) / 64
  ,@ExpZasoby    = (@Opcje & 128) / 128
  ,@ExpCen    = (@Opcje & 256) / 256
  ,@ExpKontrahenci  = (@Opcje & 512) / 512
  ,@ExpZestawy   = (@Opcje & 1024) / 1024
  ,@ExpZestawyTyp   = (@Opcje & 2048) / 2048
  ,@ExpKontrahenciTyp  = 0
SELECT '<ROOT>'
 EXEC CDN.ESKLEP_EksportInfoBlok @ID, @Opcje
IF @ExpDaneBinarnePaczki = 0
  BEGIN
  SELECT '<PTWI>'
  EXEC CDN.ESKLEP_EksportPtw @ID
  SELECT '</PTWI>'
  EXEC CDN.ESKLEP_EksportPDF @ID
  EXEC CDN.ESKLEP_EksportWaluty @ID
  END
 IF @ExpDaneBinarnePaczki = 0 AND @Opcje <> 0
  BEGIN
  --UPDATE CDN.Firma SET Fir_Wartosc = 0 WHERE Fir_Numer = 1854
  UPDATE CDN.eSklepStanowiska SET ESS_OstatnieDabId = 0 WHERE ESS_IdISklep = @ID
  --rodo
  EXEC  [CDN].[ESKLEP_EksportZgodyKanaly] @ID,0
  EXEC  [CDN].[ESKLEP_EksportZgodyTresci] @ID,0
  IF (@ExpZasoby = 1)
   BEGIN
     -- Eksport stanów handlowych
    EXEC CDN.ESKLEP_EksportTwrZasoby @ID, 1 -- eksport pełny zasobów towaru
   END
  IF (@ExpCennik = 1)
   BEGIN
     SELECT '<DABI>'
     EXEC CDN.ESKLEP_EksportDaneBinarne @ID, @ExpDaneBinarneTyp, 0
     SELECT '</DABI>'
   END
  IF (@ExpGrup = 1)
   BEGIN
     SELECT '<TWGI>'
     EXEC CDN.ESKLEP_EksportGrup @ID, @ExpGrupTyp
     SELECT '</TWGI>'
   END
   IF (@ExpCennik = 1 or @ExpKontrahenci = 1 )
     EXEC [CDN].[ESKLEP_EksportOpiekunowie] @ID,@ExpCennikTyp,@ExpKontrahenci,@ExpCennik
  IF (@ExpCennik = 1 )
   BEGIN
     SELECT '<CNDY>'
     EXEC CDN.ESKLEP_EksportNazwyCen
     SELECT '</CNDY>'
     exec [CDN].[ESKLEP_EksportDefAtrybuty] @ID, @ExpCennikTyp
     --exec  [CDN].[ESKLEP_EksportDefAtrybutyTyp] @ID, @ExpCennikTyp --od wersji 14 sjklepu niepotrzebne, dopiero po właczeniu łaczenia element dok atrybut
     SELECT '<TWRI>'
    EXEC CDN.ESKLEP_EksportTwr @ID, @ExpCennikTyp,0
     SELECT '</TWRI>'
     exec [CDN].[ESKLEP_EksportTwrAtrybuty] @ID, @ExpCennikTyp
     --SELECT '<ZSTI>'
     --EXEC CDN.ESKLEP_EksportTwrZestawy @ID, @ExpCennikTyp
     --SELECT '</ZSTI>'
     SELECT '<TWPII>'
     EXEC CDN.ESKLEP_EksportTwrZamienniki @ID, @ExpCennikTyp
     SELECT '</TWPII>'
     --SELECT '<ZMNI>'
     --EXEC CDN.ESKLEP_EksportTwrZamiennikiStare @ID, @ExpCennikTyp
     --SELECT '</ZMNI>'
     SELECT '<PDRI>'
     EXEC CDN.ESKLEP_EksportProducenci @ID, @ExpCennikTyp
     SELECT '</PDRI>'
     SELECT '<MRKI>'
     EXEC CDN.ESKLEP_EksportMarki @ID, @ExpCennikTyp
     SELECT '</MRKI>'
     --SELECT '<RBTI>'
     EXEC CDN.ESKLEP_EksportRabatyNew @ID
     --SELECT '</RBTI>'
     EXEC  CDN.ESKLEP_EksportCechy @ID, @ExpCennikTyp
     EXEC  CDN.ESKLEP_EksportCechyWartosci @ID, @ExpCennikTyp
           EXEC  CDN.ESKLEP_EksportCechyWartosciTowar @ID, @ExpCennikTyp
   END
   ELSE
   IF( @ExpCen = 1 )
    BEGIN
      SELECT '<CNDY>'
      EXEC CDN.ESKLEP_EksportNazwyCen
      SELECT '</CNDY>'
      SELECT '<TWRI>'
      EXEC CDN.ESKLEP_EksportTwr @ID, @ExpCennikTyp, @ExpCen
      SELECT '</TWRI>'
    END
  IF ( @ExpKontrahenci = 1 )
   BEGIN
   EXEC [CDN].[ESKLEP_EksportKontrahenci] @ID ,@ExpKontrahenciTyp
   END
  IF (@ExpKontrahenci = 1 and @ExpCennik != 1 )
   BEGIN
   EXEC CDN.ESKLEP_EksportRabatyNew @ID
   END
  END
 ELSE IF @ExpDaneBinarnePaczki <> 0 AND @Opcje <> 0
  BEGIN
  --SET @DABID = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1854)
  SET @DABID = (SELECT ESS_OstatnieDabId FROM CDN.eSklepStanowiska WHERE ESS_IdISklep = @ID)
  SELECT '<DABI>'
  EXEC CDN.ESKLEP_EksportDaneBinarne @ID, @ExpDaneBinarneTyp, @DABID
  SELECT '</DABI>'
  END
  IF ( @ExpZestawy = 1 )
  EXEC [CDN].[ESKLEP_EksportCrosSeling] @ID, @ExpZestawyTyp
SELECT '</ROOT>'
