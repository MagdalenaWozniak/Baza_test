create procedure cdn.SetAdresDzialu
 as
 set nocount on
  if (select top 1 isnull(COUNT(dzl_adreswezla), 0)
   from cdn.Dzialy
   group by DZL_AdresWezla
   having COUNT(dzl_adreswezla) > 1) > 0
  begin
   declare @DzlId int, @DzlParentId int, @DzlPoziom int, @DzlLisc int, @DzlAdresWezla nvarchar(512)
   declare DZIALY cursor local fast_forward for
    select dzl_dzlid, dzl_parentid, dzl_poziom, dzl_lisc, dzl_adreswezla
     from cdn.dzialy
     order by dzl_dzlid
   open DZIALY
    while (1=1)
    begin
     fetch next from DZIALY into @DzlId, @DzlParentId, @DzlPoziom, @DzlLisc, @DzlAdresWezla
     if @@fetch_status <> 0 break
     declare @DzlId2 int
     if exists (select dzl_dzlid from cdn.dzialy where dzl_dzlid <> @dzlid and dzl_adreswezla = @DzlAdresWezla)
     begin
      declare
       @Adres nvarchar(512),
       @LP int
      select @DzlId2 = min(DZL_DzlId) from cdn.Dzialy where dzl_adreswezla = @DzlAdresWezla
      if @DzlId2 <> @DzlId
      begin
       if @DzlParentId > 0
       begin
        select @Adres = DZL_AdresWezla from cdn.Dzialy where DZL_DzlId = @DzlParentId
        select @LP = max(DZL_Lisc) from cdn.Dzialy where DZL_ParentId = @DzlParentId
        --select @LP = max(right(rtrim(DZL_AdresWezla), 3)) from cdn.Dzialy where DZL_ParentId = @DzlParentId
       end
       else
       begin
        select @Adres = DZL_AdresWezla from cdn.Dzialy where DZL_DzlId = 3
        --select @LP = max(right(rtrim(DZL_AdresWezla), 3)) from cdn.Dzialy where DZL_ParentId = 3
        select @LP = max(DZL_Lisc) from cdn.Dzialy where DZL_ParentId = 3
       end
       if @LP is null
        set @LP = 1
       else
        set @LP = @LP + 1
       set @Adres = cdn.UtworzAdresWezla(@Adres, @LP)
       update cdn.dzialy
        set dzl_adreswezla = @Adres, DZL_Lisc = @LP where DZL_DzlId = @DzlId
       update cdn.PracEtaty set PRE_AdresDzialu = @Adres where PRE_DzlId = @DzlId
       update cdn.Pracidx set PRI_AdresDzialu = @Adres where PRI_DzlId = @DzlId
       execute cdn.SetAdresDzialuSub @DzlId, 0
      end
     end
    end
   close DZIALY
   deallocate DZIALY
 end
 set nocount off
