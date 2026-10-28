CREATE  PROCEDURE [CDN].[ESKLEP_EksportXML_ver2]
  @ID INT             -- ID e-sklepu
 ,@Opcje INT          -- Maska opcji eksportu
 ,@OpcjeFull INT          -- Maska opcji eksportu
 ,@Guid nvarchar(256)
 AS
SET NOCOUNT ON
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
  ,@ExpRabaty   INT --Eksport rabatów( 0 - nie, 1 - tak )
  ,@ExpPTW INT
  ,@ExpPDF INT
  ,@ExpOpiekun INT
  ,@ExpAtrybuty INT
  ,@ExpZamienniki INT
  ,@ExpProducenci INT
  ,@ExpMarki INT
  ,@ExpCechy INT
  ,@ExpZgody INT
  ,@ExpTowaryPaczki INT
DECLARE @DABID INT, @TWRID INT   -- ID danych binarnych, towarów które były wysłane jako ostatnie w poprzedniej paczce
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
  ,@ExpRabaty   = (@Opcje & 4096) / 4096 --new
  ,@ExpPTW   = (@Opcje & 8192) / 8192
  ,@ExpPDF   = (@Opcje & 16384) / 16384
  ,@ExpOpiekun   = (@Opcje & 32768) / 32768
  ,@ExpAtrybuty   = (@Opcje & 65536) / 65536
  ,@ExpZamienniki   = (@Opcje & 131072) / 131072
  ,@ExpProducenci   = (@Opcje & 262144) / 262144
  ,@ExpMarki   = (@Opcje & 524288) / 524288
  ,@ExpCechy   = (@Opcje & 1048576) / 1048576
  ,@ExpZgody   = (@Opcje & 2097152) / 2097152
  ,@ExpTowaryPaczki  = (@Opcje & 4194304) / 4194304
DECLARE
  @ExpCennikTypFull    INT
  ,@ExpKontrahenciFull   INT
  ,@ExpCennikFull    INT
SELECT
  @ExpCennikTypFull =  (@OpcjeFull & 2) / 2
  ,@ExpKontrahenciFull = (@OpcjeFull & 512) / 512
  ,@ExpCennikFull = @OpcjeFull & 1
SELECT '<ROOT>'
EXEC CDN.ESKLEP_EksportInfoBlok @ID, @OpcjeFull, @Guid,@ExpPTW
if @ExpPTW = 1
BEGIN
  SELECT '<PTWI>'
  EXEC CDN.ESKLEP_EksportPtw @ID
  SELECT '</PTWI>'
  EXEC CDN.ESKLEP_EksportWaluty @ID
  SELECT '<CNDY>'
  EXEC CDN.ESKLEP_EksportNazwyCen
  SELECT '</CNDY>'
END
IF ( @ExpPDF = 1 )
BEGIN
  select '<DOKI Pelny="0">'
  EXEC CDN.ESKLEP_EksportPDF_ver2 @ID
  select '</DOKI>'
END
IF (@ExpZgody = 1 )
BEGIN
  select '<ZGKI Pelny="0">'
  EXEC  [CDN].[ESKLEP_EksportZgodyKanaly_ver2] @ID,0
  select '</ZGKI>'
  select '<ZGDI Pelny="0">'
  EXEC  [CDN].[ESKLEP_EksportZgodyTresci_ver2] @ID,0
  select '</ZGDI>'
END
IF (@ExpZasoby = 1)
BEGIN
    -- Eksport stanów handlowych
  select '<ZSBI Pelny="1">'
  EXEC CDN.ESKLEP_EksportTwrZasoby_ver2 @ID, 1 -- eksport pełny zasobów towaru
  select '</ZSBI>'
END
IF ( @ExpZestawy = 1 )
BEGIN
 select '<CSRSS Pelny="'+convert( varchar(1),@ExpZestawyTyp)+'">'
 EXEC [CDN].[ESKLEP_EksportCrosSeling_ver2] @ID, @ExpZestawyTyp
 select '</CSRSS>'
END
IF ( @ExpKontrahenci = 1 )
BEGIN
 select '<KNTI Pelny="'+convert( varchar(1),@ExpKontrahenciTyp)+'">'
 EXEC [CDN].[ESKLEP_EksportKontrahenci_ver2] @ID ,@ExpKontrahenciTyp
 select '</KNTI>'
END
IF (@ExpRabaty = 1)-- @ExpCennik = 1 or @ExpKontrahenci = 1
BEGIN
 select '<RBTIOPT Pelny="1">'
 EXEC CDN.ESKLEP_EksportRabatyNew_ver2 @ID
 select '</RBTIOPT>'
END
IF (@ExpGrup = 1)
BEGIN
 SELECT '<TWGI Pelny="'+convert( varchar(1),@ExpGrupTyp)+'">'
 EXEC CDN.ESKLEP_EksportGrup @ID, @ExpGrupTyp
 SELECT '</TWGI>'
END
IF (@ExpOpiekun = 1)
BEGIN
  SELECT '<OPII>'
  EXEC [CDN].[ESKLEP_EksportOpiekunowie_ver2] @ID,@ExpCennikTypFull,@ExpKontrahenciFull,@ExpCennikFull
  SELECT '</OPII>'
END
IF( @ExpCen = 1 )
BEGIN
 SELECT '<TWRI Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'" Start="1">'
 EXEC CDN.ESKLEP_EksportTwr_ver2 @ID, @ExpCennikTypFull, @ExpCen, 0
 SELECT '</TWRI>'
END
IF (@ExpTowaryPaczki = 0 and @ExpCennik =1)
   BEGIN
     UPDATE CDN.eSklepStanowiska SET ESS_OstatnieTwrId = 0 WHERE ESS_IdISklep = @ID
     SELECT '<TWRI Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'" Start="1">'
     EXEC CDN.ESKLEP_EksportTwr_ver2 @ID, @ExpCennikTypFull, 0,0
    SELECT '</TWRI>'
   END
IF @ExpTowaryPaczki <> 0 and @ExpCennik =1 AND @Opcje <> 0
BEGIN
 SET @TWRID = (SELECT ESS_OstatnieTwrId FROM CDN.eSklepStanowiska WHERE ESS_IdISklep = @ID)
 SELECT '<TWRI Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'" Start="0">'
 EXEC CDN.ESKLEP_EksportTwr_ver2 @ID, @ExpCennikTypFull,0, @TWRID
 SELECT '</TWRI>'
END
IF (@ExpAtrybuty = 1 )
BEGIN
  SELECT '<SATRI Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'">'
  EXEC [CDN].[ESKLEP_EksportDefAtrybuty_ver2] @ID, @ExpCennikTypFull
  SELECT '</SATRI>'
  --SELECT '<TWRATRI Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'">'
  --EXEC [CDN].[ESKLEP_EksportTwrAtrybuty_ver2] @ID, @ExpCennikTypFull
  --SELECT '</TWRATRI>'
END
IF (@ExpZamienniki = 1 )
BEGIN
    SELECT '<TWPII Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'">'
    EXEC CDN.ESKLEP_EksportTwrZamienniki @ID, @ExpCennikTypFull
    SELECT '</TWPII>'
END
IF (@ExpProducenci = 1 )
BEGIN
    SELECT '<PDRI Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'">'
    EXEC CDN.ESKLEP_EksportProducenci @ID, @ExpCennikTypFull
    SELECT '</PDRI>'
END
IF (@ExpMarki = 1 )
BEGIN
    SELECT '<MRKI Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'">'
    EXEC CDN.ESKLEP_EksportMarki @ID, @ExpCennikTypFull
    SELECT '</MRKI>'
END
IF (@ExpCechy = 1 )
BEGIN
  SELECT '<CECI Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'">'
  EXEC  CDN.ESKLEP_EksportCechy_ver2 @ID, @ExpCennikTypFull
  SELECT '</CECI>'
  SELECT '<CECA Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'">'
  EXEC  CDN.ESKLEP_EksportCechyWartosci_ver2 @ID, @ExpCennikTypFull
  SELECT '</CECA>'
  SELECT '<CETC Pelny="'+convert( varchar(1),@ExpCennikTypFull)+'">'
  EXEC  CDN.ESKLEP_EksportCechyWartosciTowar_ver2 @ID, @ExpCennikTypFull
 SELECT '</CETC>'
END
IF (@ExpDaneBinarnePaczki = 0 and @ExpDaneBinarne =1)
   BEGIN
     UPDATE CDN.eSklepStanowiska SET ESS_OstatnieDabId = 0 WHERE ESS_IdISklep = @ID
      SELECT '<DABI Pelny="'+convert( varchar(1),@ExpDaneBinarneTyp)+'">'
     EXEC CDN.ESKLEP_EksportDaneBinarne @ID, @ExpDaneBinarneTyp, 0
     SELECT '</DABI>'
   END
IF @ExpDaneBinarnePaczki <> 0 and @ExpDaneBinarne =1 AND @Opcje <> 0
BEGIN
 SET @DABID = (SELECT ESS_OstatnieDabId FROM CDN.eSklepStanowiska WHERE ESS_IdISklep = @ID)
 SELECT '<DABI Pelny="'+convert( varchar(1),@ExpDaneBinarneTyp)+'">'
 EXEC CDN.ESKLEP_EksportDaneBinarne @ID, @ExpDaneBinarneTyp, @DABID
 SELECT '</DABI>'
END
SELECT '</ROOT>'
