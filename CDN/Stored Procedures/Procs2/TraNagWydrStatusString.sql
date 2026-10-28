create procedure CDN.TraNagWydrStatusString @ID int
as
SET NOCOUNT ON
declare @wynik NVARCHAR(100)
if not exists (select * from tempdb.dbo.sysobjects where name like '##OpisyStatusow' and xtype='U')
begin
declare @idoc int
declare @doc NVARCHAR(MAX)
set @doc=
'<data itemname="TypHaMagDoWydruku">
<row Rodzaj="301000" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301001" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301002" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301003" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301004" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301005" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301006" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301008" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301009" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301010" Typ="301" Skrot="NK"></row>
<row Rodzaj="301011" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301018" Typ="301" Skrot=""></row>
<row Rodzaj="301050" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301090" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301091" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301092" Typ="301" Skrot=""></row>
<row Rodzaj="301100" Typ="301" Skrot="FZ"></row>
<row Rodzaj="301101" Typ="301" Skrot=""></row>
<row Rodzaj="301102" Typ="301" Skrot=""></row>
<row Rodzaj="301103" Typ="301" Skrot=""></row>
<row Rodzaj="302000" Typ="302" Skrot="FA"></row>
<row Rodzaj="302001" Typ="302" Skrot="FA"></row>
<row Rodzaj="302002" Typ="302" Skrot="FA"></row>
<row Rodzaj="302003" Typ="302" Skrot="FA"></row>
<row Rodzaj="302004" Typ="302" Skrot="FA"></row>
<row Rodzaj="302005" Typ="302" Skrot="FA"></row>
<row Rodzaj="302006" Typ="302" Skrot="FA"></row>
<row Rodzaj="302007" Typ="302" Skrot="FA"></row>
<row Rodzaj="302008" Typ="302" Skrot="FA"></row>
<row Rodzaj="302009" Typ="302" Skrot="FA"></row>
<row Rodzaj="302080" Typ="302" Skrot="FA"></row>
<row Rodzaj="302081" Typ="302" Skrot="FA"></row>
<row Rodzaj="302082" Typ="302" Skrot="AF"></row>
<row Rodzaj="302083" Typ="302" Skrot="FA"></row>
<row Rodzaj="302090" Typ="302" Skrot="FA"></row>
<row Rodzaj="302091" Typ="302" Skrot="FA"></row>
<row Rodzaj="302092" Typ="302" Skrot="FA"></row>
<row Rodzaj="302100" Typ="302" Skrot="FA"></row>
<row Rodzaj="302101" Typ="302" Skrot="FA"></row>
<row Rodzaj="302102" Typ="302" Skrot="FA"></row>
<row Rodzaj="302103" Typ="302" Skrot="FA"></row>
<row Rodzaj="302200" Typ="302" Skrot="ZL"></row>
<row Rodzaj="302202" Typ="302" Skrot="ZL"></row>
<row Rodzaj="303000" Typ="303" Skrot="PW"></row>
<row Rodzaj="303001" Typ="303" Skrot="PW"></row>
<row Rodzaj="303010" Typ="303" Skrot="PW"></row>
<row Rodzaj="304000" Typ="304" Skrot="RW"></row>
<row Rodzaj="304001" Typ="304" Skrot="RW"></row>
<row Rodzaj="304010" Typ="304" Skrot="RW"></row>
<row Rodzaj="305000" Typ="305" Skrot="PA"></row>
<row Rodzaj="305001" Typ="305" Skrot="PA"></row>
<row Rodzaj="305004" Typ="305" Skrot="PA"></row>
<row Rodzaj="305005" Typ="305" Skrot="PA"></row>
<row Rodzaj="305008" Typ="305" Skrot="PA"></row>
<row Rodzaj="305100" Typ="305" Skrot="PA"></row>
<row Rodzaj="305101" Typ="305" Skrot="PA"></row>
<row Rodzaj="306000" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306001" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306002" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306004" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306005" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306006" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306007" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306008" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306009" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306010" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306061" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306071" Typ="306" Skrot="WZ"></row>
<row Rodzaj="306072" Typ="306" Skrot="WZ"></row>
<row Rodzaj="307000" Typ="307" Skrot=""></row>
<row Rodzaj="307001" Typ="307" Skrot="PZ"></row>
<row Rodzaj="307002" Typ="307" Skrot="PZ"></row>
<row Rodzaj="307004" Typ="307" Skrot="PZ"></row>
<row Rodzaj="307005" Typ="307" Skrot="PZ"></row>
<row Rodzaj="307006" Typ="307" Skrot="PZ"></row>
<row Rodzaj="307010" Typ="307" Skrot="PZ"></row>
<row Rodzaj="308000" Typ="308" Skrot="RO"></row>
<row Rodzaj="308008" Typ="308" Skrot="RO"></row>
<row Rodzaj="308009" Typ="308" Skrot="RO"></row>
<row Rodzaj="308010" Typ="308" Skrot="RO"></row>
<row Rodzaj="308011" Typ="308" Skrot="RO"></row>
<row Rodzaj="308100" Typ="308" Skrot="RO"></row>
<row Rodzaj="309000" Typ="309" Skrot="ZD"></row>
<row Rodzaj="309008" Typ="309" Skrot="ZD"></row>
<row Rodzaj="309009" Typ="309" Skrot="ZD"></row>
<row Rodzaj="309100" Typ="309" Skrot="ZD"></row>
<row Rodzaj="309308" Typ="309" Skrot="RO"></row>
<row Rodzaj="310000" Typ="310" Skrot="BO"></row>
<row Rodzaj="310001" Typ="310" Skrot="BO"></row>
<row Rodzaj="310002" Typ="310" Skrot="BO"></row>
<row Rodzaj="310005" Typ="310" Skrot="BO"></row>
<row Rodzaj="311000" Typ="311" Skrot="PI"></row>
<row Rodzaj="311001" Typ="311" Skrot="PI"></row>
<row Rodzaj="312000" Typ="312" Skrot="MM"></row>
<row Rodzaj="312001" Typ="312" Skrot="MM"></row>
<row Rodzaj="312010" Typ="312" Skrot="MM"></row>
<row Rodzaj="312100" Typ="312" Skrot="MM"></row>
<row Rodzaj="313000" Typ="313" Skrot="PK"></row>
<row Rodzaj="313001" Typ="313" Skrot="PK"></row>
<row Rodzaj="313002" Typ="313" Skrot="PK"></row>
<row Rodzaj="313004" Typ="313" Skrot="PK"></row>
<row Rodzaj="314000" Typ="314" Skrot="WK"></row>
<row Rodzaj="314001" Typ="314" Skrot="WK"></row>
<row Rodzaj="314002" Typ="314" Skrot="WK"></row>
<row Rodzaj="314004" Typ="314" Skrot="WK"></row>
<row Rodzaj="314006" Typ="314" Skrot="WK"></row>
<row Rodzaj="317000" Typ="317" Skrot="PWP"></row>
<row Rodzaj="317001" Typ="317" Skrot="PWP"></row>
<row Rodzaj="318000" Typ="318" Skrot="PWS"></row>
<row Rodzaj="318001" Typ="318" Skrot="PWS"></row>
<row Rodzaj="320000" Typ="320" Skrot="PF"></row>
<row Rodzaj="320008" Typ="320" Skrot="PF"></row>
<row Rodzaj="320009" Typ="320" Skrot="PF"></row>
<row Rodzaj="320200" Typ="320" Skrot="PF"></row>
<row Rodzaj="321001" Typ="321" Skrot="FA"></row>
<row Rodzaj="321002" Typ="321" Skrot="FA"></row>
<row Rodzaj="321003" Typ="321" Skrot="W"></row>
<row Rodzaj="321022" Typ="321" Skrot="W"></row>
<row Rodzaj="322000" Typ="322" Skrot="W"></row>
<row Rodzaj="322001" Typ="322" Skrot=""></row>
<row Rodzaj="322002" Typ="322" Skrot=""></row>
<row Rodzaj="322003" Typ="322" Skrot=""></row>
<row Rodzaj="322021" Typ="322" Skrot="W"></row>
<row Rodzaj="345000" Typ="345" Skrot="X"></row>
<row Rodzaj="350000" Typ="350" Skrot="RR"></row>
<row Rodzaj="350008" Typ="350" Skrot="RR"></row>
</data>'
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc
create table ##OpisyStatusow
(
Rodzaj int,
Typ int,
Skrot NVARCHAR(4)
)
insert into ##OpisyStatusow (Rodzaj,Typ,Skrot)
SELECT    Rodzaj,Typ,Skrot
FROM       OPENXML (@idoc, '/data/row',1)
            WITH (Skrot NVARCHAR(4),Rodzaj int,Typ int)
end
declare @kod NVARCHAR (4)
declare kursor_listapowiazanych CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
select Skrot from cdn.TraNagRelacje a
join cdn.TraNag b on a.TrR_FaId = b.TrN_TrnID
join ##OpisyStatusow on b.TrN_Rodzaj = ##OpisyStatusow.Rodzaj
where a.TrR_TrnID = @ID
group by Skrot
set @wynik = ' '
open kursor_listapowiazanych
while 1=1
begin
fetch next from kursor_listapowiazanych into @kod
      IF @@FETCH_STATUS <> 0 BREAK
 set @wynik = @wynik + @kod +' '
end
close kursor_listapowiazanych
deallocate kursor_listapowiazanych
select @wynik
SET NOCOUNT OFF
