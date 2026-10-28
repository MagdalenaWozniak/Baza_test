create proc cdn.ZeroweRcaRza @date_od datetime, @date_do datetime, @nowoZatr bit = 0
as
begin
 set nocount on
 CREATE TABLE #RCA (id int, UMW_PraId int, val int, rodzaj varchar(5), ident tinyint)
 DECLARE @miesiac int, @rok int
 set @rok  = (select YEAR(@date_od))
 set @miesiac = (select  MONTH(@date_do))
 if @nowoZatr = 1
  insert into #RCA
   select UMW_UmwId ,UMW_PraId, UMW_PraId * 10000 + UMW_TyuId ,
    (case when (
      (UMW_ZusOd is not NULL
      and UMW_ZusOd <= @date_do
      and UMW_ZusOd <> '18991230')
     or (UMW_EmerOd is not NULL
      and UMW_EmerOd <= @date_do
      and UMW_EmerOd <> '18991230') )
     then 'RCA' else
    (case when (
      (UMW_ZdrowOd is not NULL
      and UMW_ZdrowOd <= @date_do
      and UMW_ZdrowOd <> '18991230')
     or (UMW_ZdrowDobrOd is not NULL
      and UMW_ZdrowDobrOd <= @date_do
      and UMW_ZdrowDobrOd <> '18991230'))
     then 'RZA'
    else 'NIC' end) end), 0
   from cdn.Umowy
   where
    (
      (UMW_DataDo >= @date_od
      and UMW_DataDo <> '29991231')
     or ((
      (
       UMW_Splacona = 0
       or (UMW_Splacona = 2
        and UMW_Splacono < UMW_Brutto)
      )
      and UMW_DataDo >= @date_od
      and UMW_TyuId < 99999))
     or (    YEAR(UMW_DataOd) = @rok
      and MONTH(UMW_DataOd) = @miesiac)
    )
    and
     (UMW_PraId * 10000 + UMW_TyuId)
      not in (
       select distinct wpl_praid*10000 + WPE_TyUb/100
        from cdn.wypelementy
        join cdn.wyplaty
         on wpl_wplid = wpe_wplid
          and wpl_tryb not in (1,2)
        join cdn.listyplac
         on lpl_lplid = wpl_lplid
        join cdn.prackod
         on wpl_praid = pra_praid
        where lpl_miesiac = @miesiac
         and lpl_rok = @rok
       )
    and
     (UMW_PraId * 10000 +UMW_TyuId)
      not in (
       select PRE_PraId * 10000 + PRE_UBZTyuId
        from cdn.PracEtaty
        where   year(PRE_ZatrudnionyOd) = @rok
         and month(PRE_ZatrudnionyOd) = @miesiac)
 else
  insert into #RCA
   select UMW_UmwId, UMW_PraId,  UMW_PraId * 10000 + UMW_TyuId ,
    (case when (
      (UMW_ZusOd is not NULL
      and UMW_ZusOd <= @date_do
      and UMW_ZusOd <> '18991230')
     or (UMW_EmerOd is not NULL
      and UMW_EmerOd <= @date_do
      and UMW_EmerOd <> '18991230'))
     then 'RCA' else
    (case when (
      (UMW_ZdrowOd is not NULL
      and UMW_ZdrowOd <= @date_do
      and UMW_ZdrowOd <> '18991230')
     or (UMW_ZdrowDobrOd is not NULL
      and UMW_ZdrowDobrOd <= @date_do
      and UMW_ZdrowDobrOd <> '18991230'))
     then 'RZA'
    else 'NIC' end) end), 0
   from cdn.Umowy
   where
    (
      (UMW_DataDo >= @date_od
      and UMW_DataDo <> '29991231')
     or ((
      ( UMW_Splacona = 0
       or (
        UMW_Splacona=2
        and UMW_Splacono<UMW_Brutto)
      )
      and UMW_DataDo >= @date_od
      and UMW_TyuId<99999))
     or (YEAR(UMW_DataOd) = @rok
      and MONTH(UMW_DataOd)= @miesiac)
    )
    and (
     UMW_PraId * 10000 +UMW_TyuId)
      not in (
       select distinct wpl_praid * 10000 + WPE_TyUb/100
       from cdn.wypelementy
       join cdn.wyplaty
        on wpl_wplid = wpe_wplid
         and wpl_tryb not in (1,2)
       join cdn.listyplac
        on lpl_lplid = wpl_lplid
       join cdn.prackod
        on wpl_praid = pra_praid
       where lpl_miesiac = @miesiac
        and lpl_rok = @rok)
 DECLARE @count int, @id int, @val int, @rodzaj varchar(5)
 DECLARE db_cursor CURSOR FOR
  SELECT id,val,rodzaj FROM #RCA
 OPEN db_cursor
 FETCH NEXT FROM db_cursor INTO @id,@val,@rodzaj
 WHILE @@FETCH_STATUS = 0
 BEGIN
   if @rodzaj = 'RCA'
   begin
    delete from #RCA
    where val = @val and rodzaj = 'RZA'
    set @count = ( select COUNT(*) from #RCA where val = @val and rodzaj = 'RCA')
    if @count > 1
    begin
     delete from #RCA
     where id = @id
    end
   end
   else if @rodzaj = 'RZA'
   begin
    if exists (select * from #RCA where val = @val and rodzaj = 'RCA')
  begin
   delete from #RCA
   where val = @val and rodzaj = 'RZA'
  end
  set @count = ( select COUNT(*) from #RCA where val = @val and rodzaj = 'RZA')
  if @count > 1
  begin
     delete from #RCA
     where id = @id
  end
   end
  FETCH NEXT FROM db_cursor INTO @id,@val,@rodzaj
 END
 CLOSE db_cursor
 DEALLOCATE db_cursor
 delete from #RCA where rodzaj = 'NIC'
 update #RCA set ident = 1 where UMW_PraId in (select Pracownik from cdn.GetHistoriaAktualnaAll(@date_do))
 select * from #RCA
 set nocount off
end
