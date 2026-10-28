create procedure CDN.ListaPlacRenumeracja @akcja smallint, @idLPL int
as
set nocount on
declare @ID int
declare @COUNT int
--MC12
declare @NAZWA NVARCHAR(40)
set @COUNT = 0
declare WYPLATY cursor local fast_forward for
 select wpl_wplid, wpl_nazwa from cdn.wyplaty join cdn.prackod on wpl_praid = pra_praid
  where wpl_lplid = @idLPL order by pra_kod, wpl_datadok
open WYPLATY
while (1=1)
 begin
  fetch next from WYPLATY into @ID, @NAZWA
  if @@fetch_status <> 0
   break
  if(@akcja = 1)
   begin
    set @COUNT = @COUNT + 1
    update cdn.wyplaty set wpl_numernr = @COUNT
     where wpl_wplid = @ID
   end
  else
   begin
    set @COUNT = @COUNT - 1
    update cdn.wyplaty set wpl_numernr = @COUNT
     where wpl_wplid = @ID
   end
  --//MC12
  declare @ID2 int, @NR NVARCHAR(32)
  declare ZDARZENIA cursor local fast_forward for
   select bzd_bzdid, wpl_numerpelny from cdn.bnkzdarzenia inner join cdn.wyplaty on bzd_dokumentid = wpl_wplid where bzd_dokumentid = @ID and bzd_dokumenttyp = 8
    order by bzd_numer
   open ZDARZENIA
   while (1=1)
    begin
     fetch next from ZDARZENIA into @ID2, @NR
     if @@fetch_status <> 0
      break
     update cdn.bnkzdarzenia set bzd_numerpelny = @NR
      where bzd_bzdid = @ID2
     update cdn.bnkzdarzenia set bzd_opis = 'Wypłata: ' + @NR + ' ' + @NAZWA
      where bzd_bzdid = @ID2
    end
   close ZDARZENIA
   deallocate ZDARZENIA
  --//
  end
close WYPLATY
deallocate WYPLATY
