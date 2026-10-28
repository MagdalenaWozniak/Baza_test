Create Procedure CDN.ZestawieniaKsiegowe_PrzeniesPozycje @SourceId Int, @DestinationId Int, @InsertPosition Int
As
Begin
/*
  @InsertPosition :
  None = 0,
        AsChild = 1,
        Before = 2,
        After = 3,
*/
 declare @moveAsChild int = 1;
 declare @moveBefore int = 2;
 declare @moveAfter int = 3;
 declare @parentId int = 0;
 declare @lp int = 0;
 declare @lisc int = 0;
 declare @poziom int = 0;
 declare @SourceZKNId int = 0;
 declare @DestinationZKNId int = 0;
 declare @SourceParentId int = 0;
 declare @SourcePoziom int = 0;
 declare @DestinationParentId int = 0;
 declare @DestinationPoziom int  = 0;
 select @SourceZKNId = ZKP_ZKNID, @SourceParentId = ZKP_ParId, @SourcePoziom = ZKP_Poziom FROM CDN.ZestKsiPoz where ZKP_ZKPId = @SourceId;
 select @DestinationZKNId = ZKP_ZKNID, @DestinationParentId = ZKP_ParId, @DestinationPoziom = ZKP_Poziom FROM CDN.ZestKsiPoz where ZKP_ZKPId = @DestinationId;
  if @SourceZKNId <> @DestinationZKNId
    return;
 if @SourceId <> @DestinationId
 begin
  if @InsertPosition = @moveAsChild
  begin
   set @DestinationPoziom = @DestinationPoziom + 1
   if @parentId is not null
    update CDN.ZestKsiPoz Set ZKP_LP=ZKP_LP+1 where ZKP_ZKNID = @SourceZKNId and ZKP_LP >= @lp and ZKP_ParId = @parentId and ZKP_Poziom = @DestinationPoziom
   else
    update CDN.ZestKsiPoz Set ZKP_LP=ZKP_LP+1 where ZKP_ZKNID = @SourceZKNId and ZKP_LP >= @lp and ZKP_Poziom = @DestinationPoziom
   update CDN.ZestKsiPoz Set ZKP_LP=1, ZKP_ParId = @DestinationId, ZKP_Poziom = @DestinationPoziom where ZKP_ZKNID = @SourceZKNId and ZKP_ZKPId = @SourceId
  end
  else if @InsertPosition = @moveBefore
  begin
   select @parentId = ZKP_ParId, @lp = ZKP_LP, @lisc = ZKP_Lisc, @poziom = ZKP_Poziom from CDN.ZestKsiPoz where ZKP_ZKPId = @DestinationId;
   if @parentId is not null
    update CDN.ZestKsiPoz Set ZKP_LP=ZKP_LP+1 where ZKP_ZKNID = @SourceZKNId and ZKP_LP >= @lp and ZKP_ParId = @parentId and ZKP_Poziom = @poziom
   else
    update CDN.ZestKsiPoz Set ZKP_LP=ZKP_LP+1 where ZKP_ZKNID = @SourceZKNId and ZKP_LP >= @lp and ZKP_Poziom = @poziom
   update CDN.ZestKsiPoz Set ZKP_ParId = @parentId, ZKP_Lp = @lp, ZKP_Lisc = @lisc, ZKP_Poziom = @poziom where ZKP_ZKNID = @SourceZKNId and ZKP_ZKPId = @SourceId
   --exec CDN.ZestawieniaKsiegowe_RenumerujPozycje @DestinationZKNId, @parentId, @poziom;
  end
  else if @InsertPosition = @moveAfter
  begin
   select @parentId = ZKP_ParId, @lp = ZKP_LP, @lisc = ZKP_Lisc, @poziom = ZKP_Poziom from CDN.ZestKsiPoz where ZKP_ZKPId = @DestinationId;
   if @parentId is not null
    update CDN.ZestKsiPoz Set ZKP_LP=ZKP_LP+1 where ZKP_ZKNID = @SourceZKNId and ZKP_LP > @lp and ZKP_ParId = @parentId and ZKP_Poziom = @poziom
   else
    update CDN.ZestKsiPoz Set ZKP_LP=ZKP_LP+1 where ZKP_ZKNID = @SourceZKNId and ZKP_LP > @lp and ZKP_Poziom = @poziom
   update CDN.ZestKsiPoz Set ZKP_ParId = @parentId, ZKP_Lp = @lp+1, ZKP_Lisc = @lisc, ZKP_Poziom = @poziom where ZKP_ZKNID = @SourceZKNId and ZKP_ZKPId = @SourceId
   --exec CDN.ZestawieniaKsiegowe_RenumerujPozycje @DestinationZKNId, @parentId, @poziom;
  end
  --if @DestinationParentId is null
  -- set @DestinationParentId = @DestinationId;
  --exec CDN.ZestawieniaKsiegowe_RenumerujPozycje @DestinationZKNId, @DestinationParentId, @DestinationPoziom;
  --if IsNUll(@SourceParentId,0) <> IsNull(@DestinationParentId, 0)
  -- exec CDN.ZestawieniaKsiegowe_RenumerujPozycje @SourceZKNId, @SourceParentId, @SourcePoziom;
  --if IsNUll(@SourceParentId,0) <> IsNull(@DestinationParentId, 0)
  -- exec CDN.ZestawieniaKsiegowe_RenumerujPozycje @DestinationZKNId, @DestinationParentId, @DestinationPoziom;
 end
 return;
End
