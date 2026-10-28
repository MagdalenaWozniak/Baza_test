CREATE PROCEDURE [CDN].[Detal_KontrolaZasobow]
@StanowiskoDetalId INT
AS
SET NOCOUNT ON
declare
@id int,
@idzasob int,
@twrid INT,
@magid INT,
@magidzasob INT,
@ilosc decimal(15,4),
@ilosczasoby decimal(15,4),
@ilosczasob decimal(15,4),
@datadok datetime
CREATE TABLE  #Towary( id int identity(1,1),twrid INT,ilosc decimal(15,4),data datetime, magid int)
CREATE TABLE  #Zasoby( id int identity(1,1),twrid INT,ilosc decimal(15,4),data datetime, magid int)
exec CDN.Detal_ImportDok @StanowiskoDetalId
if @StanowiskoDetalId < 1
insert into #Towary
select dtre_twrid,sum(dtre_ilosc),dtrn_datadok ,DSta_MagId from cdn.detaltraelem
join cdn.detaltranag on dtre_dstrnid = dtrn_dstrnid and DTrN_StanDetalID =  DTrE_StanDetalId
join cdn.detalstanowiska on DTrN_StanDetalID = DSta_DStaId and Dtrn_stansynchronizacji = 1
join cdn.towary on  dtre_twrid = twr_twrid
where twr_typ = 1 and (DTrN_TypDokumentu = 305)-- or (DTrN_TypDokumentu = 302 and DSta_Typ = 2))
group by dtre_twrid,dtrn_datadok,DSta_MagId
else
insert into #Towary
select dtre_twrid,sum(dtre_ilosc),dtrn_datadok ,DSta_MagId from cdn.detaltraelem
join cdn.detaltranag on dtre_dstrnid = dtrn_dstrnid and DTrN_StanDetalID =  DTrE_StanDetalId
join cdn.detalstanowiska on DTrN_StanDetalID = DSta_DStaId and Dtrn_stansynchronizacji = 1
join cdn.towary on  dtre_twrid = twr_twrid
where twr_typ = 1 and DSta_DStaId = @StanowiskoDetalId and (DTrN_TypDokumentu = 305 )--or (DTrN_TypDokumentu = 302 and DSta_Typ = 2))
group by dtre_twrid,dtrn_datadok,DSta_MagId
insert into  #Zasoby
select twz_twrid,sum(twz_ilosc),twz_data ,twz_magid from cdn.twrzasoby where twz_twrid in (select distinct(twrid) from #Towary)  --and twz_magid =
group by twz_twrid,twz_data,twz_magid
delete from #Towary where ilosc <= 0
DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  select * from #Towary order by data
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
           @id,
           @twrid ,
           @ilosc ,
           @datadok,
           @magid
   IF @@FETCH_STATUS <> 0 BREAK
  select @ilosczasoby = isnull(sum(ilosc),0) from #Zasoby where twrid = @twrid and data <= @datadok and magid = @magid
  while(@ilosczasoby > 0)
  begin
     select @ilosczasob = 0,@idzasob = 0
     select top 1 @ilosczasob = ilosc,@idzasob = id from #Zasoby where twrid = @twrid and data <= @datadok and magid = @magid
     if @ilosczasob = 0
       break
     if @ilosczasob  >  @ilosc
     begin
        delete from #Towary where id = @id
        update #Zasoby set ilosc = ilosc - @ilosc where id = @idzasob
        break
     end
    if @ilosczasob  =  @ilosc
     begin
        delete from #Towary where id = @id
        delete from #Zasoby where id = @idzasob
        break
     end
    if @ilosczasob  <  @ilosc
     begin
        delete from #Zasoby where id = @idzasob
        update #Towary set ilosc = ilosc - @ilosczasob where id = @id
        set @ilosc = @ilosc - @ilosczasob
     end
     select @ilosczasoby = isnull(sum(ilosc),0) from #Zasoby where twrid = @twrid and data <= @datadok
  end
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
select id as ID,twr_kod as kod,twr_nazwa as nazwa,ilosc as ilosc, Mag_Symbol as Magazyn, data as data, magid,twrid from #Towary
join cdn.towary on twrid = twr_twrid
join cdn.magazyny on magid = mag_magid
order by data,magid,kod
drop TABLE  #Towary
drop TABLE  #Zasoby
SET NOCOUNT OFF
