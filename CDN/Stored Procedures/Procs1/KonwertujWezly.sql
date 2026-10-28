create procedure cdn.KonwertujWezly
 as
 set nocount on
  declare
   @DzlId int,
   @AdresWezla varchar(255),
   @Result varchar(255)
  declare DZIALY cursor local fast_forward
   for
    select dzl_dzlid, dzl_adreswezla
     from
      cdn.dzialy
     where
      dzl_dzlid > 3
   open DZIALY
    while (1=1)
    begin
     fetch next from DZIALY into @DzlId, @AdresWezla
     if @@fetch_status <> 0 break
     set @Result = rtrim(cdn.KonwertujAdresWezla(@AdresWezla))
     update cdn.Dzialy
      set
       DZL_AdresWezla = @Result,
       DZL_Lisc = right(rtrim(@Result), 3)
      where
       DZL_DzlId = @DzlId
     update cdn.PracEtaty
      set
       PRE_AdresDzialu = @Result
      where
       PRE_DzlId = @DzlId
     update cdn.Pracidx
      set
       PRI_AdresDzialu = @Result
      where
       PRI_DzlId = @DzlId
    end
   close DZIALY
  deallocate DZIALY
 set nocount off
