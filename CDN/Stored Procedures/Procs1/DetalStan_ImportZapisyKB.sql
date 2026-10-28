CREATE PROCEDURE [CDN].[DetalStan_ImportZapisyKB]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
declare
 @DSZKBID int ,
 @StanDetalID int ,
 @DSFPlId int ,
 @TypDokumentu int ,
 @NumerNr int ,
 @NumerString NVARCHAR(31) ,
 @NumerPelny NVARCHAR(50) ,
 @DataDok datetime ,
 @PodID int ,
 @RazemBrutto decimal(15, 2) ,
 @OpeID int,
    @Opis NVARCHAR(254)
if @CzyTaSamaBaza = 1
BEGIN
 update CDN.DetalStanZapisyKB SET DSZKB_StanSynchronizacji = 2 WHERE DSZKB_StanDetalID = @ID and DSZKB_DSZKBID in
 (select DZKB_DSZKBID from cdn.detalZapisyKB where DZKB_StanSynchronizacji =2  and DZKB_StanDetalID = @ID)
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  SELECT
       DSZKB_DSZKBID
      ,DSZKB_StanDetalID
      ,DSFpl_OptimaId
      ,DSZKB_TypDokumentu
      ,DSZKB_NumerNr
      ,DSZKB_NumerString
      ,DSZKB_NumerPelny
      ,DSZKB_DataDok
      ,DSKnt_OptimaId
      ,DSZKB_RazemBrutto
      ,DSOpe_OptimaId
      ,ISNULL(DSZKB_Opis,'') as DSZKB_Opis
  FROM CDN.DetalStanZapisyKB
  join CDN.DetalStanFormyPlatnosci ON DSZKB_DSFplID = DSFpl_DSFplID
  join CDN.DetalStanOperatorzy ON DSZKB_OpeID = DSOpe_DSOpeID
  join CDN.DetalStanKontrahenci ON DSZKB_PodID = DSKnt_DSKntID
 where ISNULL(DSZKB_StanSynchronizacji,0) < 2 and DSZKB_StanDetalID = @ID and DSKnt_OptimaId <> 0 and DSZKB_Bufor = 0
 order by DSZKB_NumerNr
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
 @DSZKBID ,
 @StanDetalID ,
 @DSFPlId ,
 @TypDokumentu,
 @NumerNr,
 @NumerString ,
 @NumerPelny ,
 @DataDok ,
 @PodID ,
 @RazemBrutto,
 @OpeID,
    @Opis
   IF @@FETCH_STATUS <> 0 BREAK
  EXEC CDN.Detal_AktualizujZapisyKB
 @DSZKBID ,
 @StanDetalID ,
 @DSFPlId ,
 @TypDokumentu,
 @NumerNr,
 @NumerString ,
 @NumerPelny ,
 @DataDok ,
 @PodID ,
 @RazemBrutto,
 @OpeID,
    @Opis
END
    UPDATE CDN.DetalStanZapisyKB SET DSZKB_StanSynchronizacji = 1 WHERE DSZKB_DSZKBID = @DSZKBID and DSZKB_StanDetalID = @ID
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
  SELECT
       DSZKB_DSZKBID
      ,DSZKB_StanDetalID
      ,DSFpl_OptimaId
      ,DSZKB_TypDokumentu
      ,DSZKB_NumerNr
      ,DSZKB_NumerString
      ,DSZKB_NumerPelny
      ,DSZKB_DataDok
      ,DSKnt_OptimaId
      ,DSZKB_RazemBrutto
      ,DSOpe_OptimaId
      ,ISNULL(DSZKB_Opis,'') as DSZKB_Opis
  FROM CDN.DetalStanZapisyKB
  join CDN.DetalStanFormyPlatnosci ON DSZKB_DSFplID = DSFpl_DSFplID
  join CDN.DetalStanOperatorzy ON DSZKB_OpeID = DSOpe_DSOpeID
  join CDN.DetalStanKontrahenci ON DSZKB_PodID = DSKnt_DSKntID
 where ISNULL(DSZKB_StanSynchronizacji,0) < 2 and DSZKB_StanDetalID = @ID and DSKnt_OptimaId <> 0 and DSZKB_Bufor = 0
 order by DSZKB_NumerNr
SET NOCOUNT OFF
