create procedure CDN.WyplataStatus @akcja smallint, @iYDekl int, @iMDekl int, @idPRA int, @idWPL int, @idLPL int = 0
as
set nocount on
 declare @Trans int
 set @Trans = 0
 if exists
  (select wpl_wplid from cdn.wyplaty
   where (wpl_praid = @idPRA and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0)
 begin
 if @idLPL > 0 --2018.1 nie zamykać wypłat z tej samej listy płac
 begin
   begin Transaction
   set @Trans = 1
   update cdn.BnkZdarzenia
    set bzd_stan = 1
    where bzd_dokumentTyp = 8 and bzd_dokumentId in
     (select wpl_wplid from cdn.wyplaty
      where (wpl_praid = @idPRA and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0 and WPL_LplId <> @idLPL)
   update cdn.Wyplaty
    set wpl_zamknieta = 1
     where (wpl_praid = @idPRA and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0 and WPL_LplId <> @idLPL
 end
 else
  begin
   begin Transaction
   set @Trans = 1
   update cdn.BnkZdarzenia
    set bzd_stan = 1
    where bzd_dokumentTyp = 8 and bzd_dokumentId in
     (select wpl_wplid from cdn.wyplaty
      where (wpl_praid = @idPRA and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0)
   update cdn.Wyplaty
    set wpl_zamknieta = 1
     where (wpl_praid = @idPRA and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0
  end
 end
 --14 dodanie obsługi wieloetatowości
 declare @Nadrzedny int, @ParentId int
 select @Nadrzedny = PRA_Nadrzedny, @ParentId = PRA_ParentId from cdn.prackod where pra_praid = @idPRA
 if @Nadrzedny > 0
  begin
   declare @ID1 int
   declare PRACOWNICY1 cursor local fast_forward for
    select pra_praid from cdn.prackod
     where pra_parentid = @idPRA
   open PRACOWNICY1
   while (1=1)
    begin
     fetch next from PRACOWNICY1 into @ID1
     if @@fetch_status <> 0
      break
     if exists
      (select wpl_wplid from cdn.wyplaty
       where (wpl_praid = @ID1 and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0)
     begin
      if @Trans <= 0
       begin
        begin Transaction
        set @Trans = 1
       end
      update cdn.BnkZdarzenia
       set bzd_stan = 1
       where bzd_dokumentTyp = 8 and bzd_dokumentId in
        (select wpl_wplid from cdn.wyplaty
         where (wpl_praid = @ID1 and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0)
      update cdn.Wyplaty
       set wpl_zamknieta = 1
        where (wpl_praid = @ID1 and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0
     end
    end
   close PRACOWNICY1
   deallocate PRACOWNICY1
  end
 if @ParentId > 0
  begin
   declare @ID2 int
   declare PRACOWNICY2 cursor local fast_forward for
    select pra_praid from cdn.prackod
     where (pra_parentid = @ParentId or pra_praid = @ParentId) and pra_praid <> @idPRA
   open PRACOWNICY2
   while (1=1)
    begin
     fetch next from PRACOWNICY2 into @ID2
     if @@fetch_status <> 0
      break
     if exists
      (select wpl_wplid from cdn.wyplaty
       where (wpl_praid = @ID2 and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0)
     begin
      if @Trans <= 0
       begin
        begin Transaction
        set @Trans = 1
       end
      update cdn.BnkZdarzenia
       set bzd_stan = 1
       where bzd_dokumentTyp = 8 and bzd_dokumentId in
        (select wpl_wplid from cdn.wyplaty
         where (wpl_praid = @ID2 and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0)
        update cdn.Wyplaty
        set wpl_zamknieta = 1
        where (wpl_praid = @ID2 and wpl_miesiac = @iMDekl and wpl_rok = @iYDekl) and wpl_wplid <> @idWPL and wpl_zamknieta = 0
     end
    end
   close PRACOWNICY2
   deallocate PRACOWNICY2
  end
 if @@TranCount <> 0 commit transaction
