Create Procedure CDN.ZestawieniaKsiegowe_RenumerujPozycje @ZKNID int, @ParentId Int, @Poziom Int
As
Begin
 DECLARE @ZKPId int = 0;
 DECLARE @lp int = 0;
 DECLARE @zkp TABLE (id int);
  if IsNull(@ParentId, 0) <> 0
  begin
 insert into @zkp (id) select ZKP_ZKPId FROM CDN.ZestKsiPoz where ZKP_ParId = @ParentId and ZKP_Poziom = @Poziom order by ZKP_Lp asc
    DECLARE doRenumeracji CURSOR LOCAL FAST_FORWARD FOR
    SELECT id FROM @zkp
    OPEN doRenumeracji
    WHILE 1=1
    BEGIN
      FETCH NEXT FROM doRenumeracji INTO @ZKPId
      IF @@FETCH_STATUS <> 0 BREAK
      set @lp = @lp + 1
      update CDN.ZestKsiPoz Set ZKP_Lp = @lp where ZKP_ZKPId = @ZKPId;
    END
  end
  else
  begin
 insert into @zkp (id) SELECT ZKP_ZKPId FROM CDN.ZestKsiPoz where ZKP_ParId is null and ZKP_ZKNID=@ZKNID and ZKP_Poziom = @Poziom order by ZKP_Lp asc
    DECLARE doRenumeracji CURSOR LOCAL FAST_FORWARD FOR
 SELECT id FROM @zkp
    OPEN doRenumeracji
    WHILE 1=1
    BEGIN
      FETCH NEXT FROM doRenumeracji INTO @ZKPId
      IF @@FETCH_STATUS <> 0 BREAK
      set @lp = @lp + 1
      update CDN.ZestKsiPoz Set ZKP_Lp = @lp where ZKP_ZKPId = @ZKPId;
    END
  end
 return;
End
