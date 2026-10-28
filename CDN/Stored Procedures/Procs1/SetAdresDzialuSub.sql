create procedure cdn.SetAdresDzialuSub @ParentId int, @Lisc int
 as
 set nocount on
  declare @DzlId int, @DzlParentId int, @DzlPoziom int, @DzlLisc int, @DzlAdresWezla nvarchar(512)
  declare PODWYDZIALY cursor local fast_forward for
   select dzl_dzlid, dzl_parentid, dzl_poziom, dzl_lisc, dzl_adreswezla from cdn.dzialy
    where dzl_parentid = @ParentId
   open PODWYDZIALY
   while (1=1)
    begin
     fetch next from PODWYDZIALY into @DzlId, @DzlParentId, @DzlPoziom, @DzlLisc, @DzlAdresWezla
     if @@fetch_status <> 0 break
     declare
       @Adres nvarchar(512),
       @LP int
     if @ParentId > 0
     begin
      select @Adres = DZL_AdresWezla from cdn.Dzialy where DZL_DzlId = @ParentId
     end
     else
     begin
      select @Adres = DZL_AdresWezla from cdn.Dzialy where DZL_DzlId = 3
     end
     if @LP is null
      set @LP = 1
     else
      set @LP = @Lisc + 1
     set @Adres = cdn.UtworzAdresWezla(@Adres, @LP)
     update cdn.dzialy
      set dzl_adreswezla = @Adres, DZL_Lisc = @LP where DZL_DzlId = @DzlId
     update cdn.PracEtaty set PRE_AdresDzialu = @Adres where PRE_DzlId = @DzlId
     update cdn.Pracidx set PRI_AdresDzialu = @Adres where PRI_DzlId = @DzlId
     execute cdn.SetAdresDzialuSub @DzlId, 0
    end
   close PODWYDZIALY
  deallocate PODWYDZIALY
 set nocount off
