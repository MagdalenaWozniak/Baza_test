create procedure cdn.OKasujProjekt @OProjektId int
 as
 set nocount on
  declare @TRanWewnetrzna int
  set @TRanWewnetrzna = 0
  if @@trancount = 0
  begin
   begin tran
   set @TRanWewnetrzna = 1
  end
  --[logowanie]
  declare @obj_name nvarchar(128)
  select @obj_name = PRJ_Nazwa from cdn.DefProjekty where PRJ_PrjId = @OProjektId
  delete from cdn.DefProjekty where PRJ_PrjId = @OProjektId
  if @@error <> 0
   begin
    if @@trancount <> 0
     rollback tran
    --declare @s nvarchar
    --set @s = 'Błąd usuwania projektu' --ERR_SQL_Place_BladUsuwaniaProjektu
    --RAISERROR('##OPT32152##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32152
   end
  else
   begin
    --[logowanie]
    declare @oid int
    set @oid = cdn.GetXLOperatorID()
    if @oid > 0
    begin
     exec CDN.RejestrOperacjiContextInfo @oid
     exec CDN.RejestrOperacjiDodaj 24502, 0, @OProjektId, @obj_name, 3, ''
    end
    if @@trancount <> 0 and @TRanWewnetrzna = 1
     commit tran
            end
 set nocount off
