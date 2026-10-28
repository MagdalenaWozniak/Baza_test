CREATE  PROCEDURE [CDN].[Detal_EksportPotwierdzenia]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
DECLARE
            @Typ INT
           ,@OptimaId INT
           ,@DetalId INT
           --,@CzyTaSamaBaza TINYINT
          -- ,@StanowiskoId INT
if @CzyTaSamaBaza = 1
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
select 1,0,DTrN_DSTrNID from CDN.DetalTraNag where DTrN_StanDetalId = @ID and DTrN_StanSynchronizacji = 2
union
select 2,0,DZKB_DSZKBID from CDN.DetalZapisyKB where DZKB_StanDetalId = @ID and DZKB_StanSynchronizacji = 2
union
select 3,DKnt_OptimaId,DKnt_DSKntID from CDN.DetalKontrahenci where DKnt_StanDetalId = @ID and DKnt_StanSynchronizacji = 2
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
            @Typ
           ,@OptimaId
           ,@DetalId
   IF @@FETCH_STATUS <> 0 BREAK
  exec [CDN].[DetalStan_Potwierdzenia]
            @Typ
           ,@OptimaId
           ,@DetalId
           ,@ID
           ,@CzyTaSamaBaza
 IF @Typ = 1
 BEGIN
  DELETE FROM CDN.DetalTraNag WHERE  DTrN_StanDetalID = @ID AND DTrN_DSTrNID = @DetalId
 END
 IF @Typ = 2
 BEGIN
  DELETE FROM CDN.DetalZapisyKB WHERE  DZKB_StanDetalID = @ID AND DZKB_DSZKBID = @DetalId
 END
 IF @Typ = 3
 BEGIN
  DELETE FROM CDN.DetalKontrahenci WHERE  DKnt_StanDetalID = @ID AND DKnt_DSKntID = @DetalId
 END
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
select 1,0,DTrN_DSTrNID from CDN.DetalTraNag where DTrN_StanDetalId = @ID and DTrN_StanSynchronizacji = 2
union
select 2,0,DZKB_DSZKBID from CDN.DetalZapisyKB where DZKB_StanDetalId = @ID and DZKB_StanSynchronizacji = 2
union
select 3,DKnt_OptimaId,DKnt_DSKntID from CDN.DetalKontrahenci where DKnt_StanDetalId = @ID and DKnt_StanSynchronizacji = 2
