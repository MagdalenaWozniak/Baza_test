CREATE  PROCEDURE [CDN].[DetalStan_Potwierdzenia]
            @Typ INT
           ,@OptimaId INT
           ,@DetalId INT
           ,@CzyTaSamaBaza TINYINT
           ,@StanowiskoId INT
AS
SET NOCOUNT ON
 IF @Typ = 1
 BEGIN
  UPDATE CDN.DetalStanTraNag SET DSTrN_StanSynchronizacji = 2 Where DSTrN_DSTrNID = @DetalId
  --DELETE FROM CDN.DetalTraNag WHERE  DTrN_StanDetalID = @StanowiskoId AND DTrN_DSTrNID = @DetalId
 END
 IF @Typ = 2
 BEGIN
  UPDATE CDN.DetalStanZapisyKB SET DSZKB_StanSynchronizacji = 2 Where DSZKB_DSZKBID = @DetalId
  --DELETE FROM CDN.DetalZapisyKB WHERE  DZKB_StanDetalID = @StanowiskoId AND DZKB_DSZKBID = @DetalId
 END
 IF @Typ = 3
 BEGIN
  UPDATE CDN.DetalStanKontrahenci SET DSKnt_StanSynchronizacji = 0, DSKnt_OptimaId = @OptimaId Where DSKnt_DSKntID = @DetalId
  --DELETE FROM CDN.DetalKontrahenci WHERE  DKnt_StanDetalID = @StanowiskoId AND DKnt_DSKntID = @DetalId
 END
  SET NOCOUNT OFF
