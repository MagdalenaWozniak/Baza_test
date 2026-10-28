create procedure cdn.OKasujDzial @ODzialId int
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
  select @obj_name = DZL_Nazwa from cdn.Dzialy where DZL_DzlId = @ODzialId
  delete from cdn.Dzialy where DZL_DzlId = @ODzialId
  if @@error <> 0
   begin
    if @@trancount <> 0
     rollback tran
    --declare @s nvarchar
    --set @s = 'Błąd usuwania wydziału' --ERR_SQL_Place_BladUsuwaniaWydzialu
    --RAISERROR('##OPT32151##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32151
   end
  else
   begin
    --[logowanie]
    declare @oid int
    set @oid = cdn.GetXLOperatorID()
    if @oid > 0
    begin
     exec CDN.RejestrOperacjiContextInfo @oid
     exec CDN.RejestrOperacjiDodaj 24500, 0, @ODzialId, @obj_name, 3, ''
    end
                if @@trancount <> 0 and @TRanWewnetrzna = 1
        commit tran
            end
 set nocount off
