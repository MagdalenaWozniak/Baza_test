CREATE FUNCTION CDN.NumerDokumentuVatDlaJpk( @VaNId int)
RETURNS nvarchar(256)
AS
BEGIN
 if exists(select * from cdn.VatNag where VaN_Wewnetrzna <> 0 and VaN_Rodzaj<> 8 and VaN_VaNId=@VaNId)
 begin
  declare @result nvarchar(512) = '';
  declare @SingleNumebers TABLE (dokument varchar(256));
  declare @Dokument nvarchar(512) = '';
  insert into @SingleNumebers
  select distinct Dokument from (
   Select C.VaN_Dokument as Dokument
   From CDN.VatNag A
   Join CDN.VatNag B On A.VaN_VaNOrgId  = B.VaN_VaNId
   Join CDN.VatNag C On C.VaN_ZbVaNId = B.VaN_VaNId
   Where C.VaN_Wewnetrzna = 0 and A.VaN_VaNId = @VaNId
   union all
   Select C.VaN_Dokument as Dokument
   From CDN.VatNag A
   Join CDN.VatNag B On A.VaN_VaNOrgId  = B.VaN_VaNId
   Join CDN.VatNag C On C.VaN_VaNId  = B.VaN_VaNOrgId
   Where C.VaN_Wewnetrzna = 0 and A.VaN_VaNId = @VaNId
   Union All
   Select VaN_Dokument as Dokument From CDN.VatNag Where VaN_wewnetrzna = 0 and VaN_ZbVaNId = @VaNId
   Union All
   select A.VaN_Dokument as Dokument from cdn.vatnag A
   join cdn.vatnag B on (B.VaN_VaNOrgId = A.VaN_VaNId)
      where A.VaN_Wewnetrzna = 0 and B.VaN_VaNId = @VaNId
      Union All
      select A.VaN_Dokument as Dokument
      from cdn.vatnag A
      join cdn.vatnag B on (B.VaN_VaNOrgId = A.VaN_VaNId)
      join cdn.vatnag C on (C.VaN_VaNOrgId = B.VaN_VaNId)
      where A.VaN_Wewnetrzna = 0 and C.VaN_VaNId = @VaNId
   Union All
   Select
   Case When TrN_NumerObcy <> '' Then TrN_NumerObcy Else TrN_NumerPelny End as Dokument
      From CDN.TraNag
      Where TrN_VaNId = @VaNId
  ) D
  declare @dokumentCursor Cursor;
  set @dokumentCursor = CURSOR FAST_FORWARD FOR select Dokument from @SingleNumebers order by 1 asc;
  open @dokumentCursor;
  while 1=1
  begin
   fetch next from @dokumentcursor into @dokument;
   if @@fetch_status <> 0 break
   if (len(@result) + len(@Dokument) + 1) >= 256
    break;
   else
   begin
    if len(@result)=0
     set @result = @Dokument;
    else
     set @result = @result + ','+@Dokument;
   end
  end
  close @dokumentCursor
  deallocate @dokumentCursor
  if len(@result) = 0
   select @Result=VaN_Dokument from cdn.vatnag where van_vanid = @VaNId;
 end
 else
 begin
  select @Result=VaN_Dokument from cdn.vatnag where van_vanid = @VaNId;
 end
 set @Result = replace(@Result, char(31), '');
 return @Result
END
