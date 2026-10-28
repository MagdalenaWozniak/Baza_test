create proc CDN.DRA @year int, @month int, @pracid int, @tyuid int
as
begin
set nocount on
CREATE TABLE #RCA (rodzaj varchar(5))
declare @suma int
begin try
if @tyuid / 10000 = 5
begin
set @suma =  (select MAX(CASE WHEN ((999=TWP_PdzId or 0=TWP_PdzId) AND (WPE_NrZUS &    (1 | 2 | 4 | 8)) <> 0 AND  ((WPE_NrZUS & (128))= 0 or (WPE_NrZUS & (128) = 128)))THEN 1 ELSE 0 END) from cdn.wypelementy join cdn.wyplaty on wpl_wplid = wpe_wplid and wpl_tryb not in (1,2)
join cdn.listyplac on lpl_lplid = wpl_lplid join cdn.prackod on wpl_praid = pra_praid join cdn.TypWyplata on TWP_TwpId = WPE_TwpId where lpl_miesiac = @month and lpl_rok = @year  and @pracid = pra_praid and Wpe_tyUb = @tyuid and WPE_NrZUS <> 0)
end
else
begin
set @suma =  (select MAX(CASE WHEN ((999=TWP_PdzId or 0=TWP_PdzId) AND (WPE_NrZUS &    (1 | 2 | 4 | 8)) <> 0 AND  ((WPE_NrZUS & (128))= 0 or (WPE_NrZUS & (128) = 128)))THEN 1 ELSE 0 END) from cdn.wypelementy join cdn.wyplaty on wpl_wplid = wpe_wplid and wpl_tryb not in (1,2)
join cdn.listyplac on lpl_lplid = wpl_lplid join cdn.prackod on wpl_praid = pra_praid join cdn.TypWyplata on TWP_TwpId = WPE_TwpId where lpl_miesiac = @month and lpl_rok = @year  and @pracid = pra_praid and Wpe_tyUb = @tyuid)
end
insert into #RCA select(case when  @suma = 0  then 'RZA' else 'RCA' end) as DRA
end try
begin catch
insert into #RCA values  ('RCA')
end catch
if exists (select * from #RCA where rodzaj = 'RCA')
select 1
else
select 0
set nocount off
end
