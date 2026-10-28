create procedure cdn.WypelnijCentraLink
 as
 set nocount on
 insert into cdn.centralink (cnl_cntid, cnl_parentid)
  select cnt_cntid, 0 from cdn.Centra order by cnt_cntid
  declare
   @CentrumId int,
   @ParentId int,
   @Adres nvarchar(512)
  declare CENTRA_CUR cursor local fast_forward
   for
    select cnt_cntid, cnt_parentid, cnt_adreswezla
     from cdn.Centra
   open CENTRA_CUR
    while (1=1)
    begin
     fetch next from CENTRA_CUR into @CentrumId, @ParentId, @Adres
     if @@fetch_status <> 0 break
     declare @i int, @Parent int
     set @i = 1
     set @Parent = @ParentId
     while @Parent > 0
     begin
      if @Parent > 0
      begin
       insert into cdn.centralink (cnl_cntid, cnl_parentid) values (@CentrumId, @Parent)
       select @Parent = CNT_ParentId from cdn.centra where CNT_CntId = @Parent
      end
     end
    end
   close CENTRA_CUR
  deallocate CENTRA_CUR
 set nocount off
