create procedure cdn.AktualizujPracIdx @praid int, @Archiwalny int, @ParentId int , @Nadrzedny int
as
set nocount on
if not exists (select * from cdn.pracetaty where pre_praid = @praid)
    return
--14
if @ParentId = 0
 set @ParentId = null
declare @priid int,
  @dziid int,
  @kod nvarchar(20),
  @nazwisko nvarchar(40),
  @imie1 nvarchar(30),
  @pesel nvarchar(11),
  @typpracownika int,
  @cntid int
declare @dataod1 datetime,
  @datado1 datetime,
  @dataod10 datetime,
  @datado10 datetime,
  @dataod20 datetime,
  @datado20 datetime
declare @adreswezla nvarchar(50),
  @adreswezla_c nvarchar(50),
  @opis nvarchar(128)
set @dataod1 = null;
set @datado1 = null;
set @dataod10 = null;
set @datado10 = null;
set @dataod20 = null;
set @datado20 = null;
select top 1 @dziid = pre_dzlid from cdn.pracetaty where pre_praid = @praid order by pre_dataod desc
 if @dziid is null
  set @dziid = 3
select top 1 @cntid = pre_cntid from cdn.pracetaty where pre_praid = @praid order by pre_dataod desc
 if @cntid is null
  set @cntid = 3
select top 1 @adreswezla = dzl_adreswezla from cdn.dzialy
 where dzl_dzlid = @dziid
select top 1 @adreswezla_c = cnt_adreswezla from cdn.centra
 where cnt_cntid = @cntid
select top 1
 @kod = pre_kod,
 @nazwisko = pre_nazwisko,
 @imie1 = pre_imie1,
 @pesel = pre_pesel,
 @typpracownika = pre_typpracownika,
 @opis = pre_opis
 from cdn.pracetaty
  where pre_praid = @praid
 order by pre_dataod desc
-- odczytanie danych dla typ 10
if exists (select * from cdn.pracetaty where pre_praid = @praid and pre_zatrudnionyod is not null)
  select
    @dataod10 = min(case when  pre_zatrudnionyod > pre_dataod then pre_zatrudnionyod else pre_dataod end),
    @datado10 = max(case when  pre_zatrudnionydo < pre_datado then pre_zatrudnionydo else pre_datado end)
    from cdn.pracetaty where pre_praid = @praid and pre_zatrudnionyod is not null
-- odczytanie danych dla typ 20
if exists (select * from cdn.umowy where umw_praid = @praid)
  select
    @dataod20 = min(umw_dataod),
    @datado20 = max(umw_datado)
    from cdn.umowy where umw_praid = @praid
-- ustalenie danych dla typ 1
if @dataod10 is not null set @dataod1 = @dataod10
if @dataod20 <  @dataod10 and @dataod20 is not null set @dataod1 = @dataod20
if @datado10 is not null set @datado1 = @datado10
if @datado20 >  @datado10 and @datado20 is not null set @datado1 = @datado20
 -- usuwanie starych rekordów
 delete from cdn.pracidx where pri_praid = @praid
 -- odczytanie słusznego @priid
 --MC2015.5 updlock
 select @priid = isnull(max(pri_priid),0) + 1 from cdn.pracidx with (updlock)
 -- aktualizacja rekordów o typ = 1
 if @typpracownika = 1
  insert into cdn.pracidx
   (pri_priid, pri_typ, pri_dzlid, pri_praid, pri_kod, pri_nazwisko, pri_imie1, pri_pesel, pri_dataod, pri_datado, pri_adresdzialu, pri_opis, pri_archiwalny, pri_parentid, pri_nadrzedny, pri_cntid, pri_adrescentrum)
   values (@priid, 2, @dziid, @praid, @kod, @nazwisko, @imie1, @pesel, @dataod1, @datado1, @adreswezla, @opis, @Archiwalny, @ParentId, @Nadrzedny, @cntid, @adreswezla_c)
 else
  insert into cdn.pracidx
   (pri_priid, pri_typ, pri_dzlid, pri_praid, pri_kod, pri_nazwisko, pri_imie1, pri_pesel, pri_dataod, pri_datado, pri_adresdzialu, pri_opis, pri_archiwalny, pri_parentid, pri_nadrzedny, pri_cntid, pri_adrescentrum)
   values (@priid, 1, @dziid, @praid, @kod, @nazwisko, @imie1, @pesel, @dataod1, @datado1, @adreswezla, @opis, @Archiwalny, @ParentId, @Nadrzedny, @cntid, @adreswezla_c)
 set @priid = @priid + 1
 -- aktualizacja rekordów o typ = 10 (etat)
 if @dataod10 is not null and @datado10 is not null
 begin
  insert into cdn.pracidx
   (pri_priid, pri_typ, pri_dzlid, pri_praid, pri_kod, pri_nazwisko, pri_imie1, pri_pesel, pri_dataod, pri_datado, pri_adresdzialu, pri_opis, pri_archiwalny, pri_parentid, pri_nadrzedny, pri_cntid, pri_adrescentrum)
   values (@priid, 10, @dziid, @praid, @kod, @nazwisko, @imie1, @pesel, @dataod10, @datado10, @adreswezla, @opis, @Archiwalny, @ParentId, @Nadrzedny, @cntid, @adreswezla_c)
  set @priid = @priid + 1
 end
 -- aktualizacja rekordów o typ = 20 (umowy)
 if @dataod20 is not null and @datado20 is not null
 begin
  insert into cdn.pracidx
   (pri_priid, pri_typ, pri_dzlid, pri_praid, pri_kod, pri_nazwisko, pri_imie1, pri_pesel, pri_dataod, pri_datado, pri_adresdzialu, pri_opis, pri_archiwalny, pri_parentid, pri_nadrzedny, pri_cntid, pri_adrescentrum)
   values (@priid, 20, @dziid, @praid, @kod, @nazwisko, @imie1, @pesel,  @dataod20, @datado20, @adreswezla, @opis, @Archiwalny, @ParentId, @Nadrzedny, @cntid, @adreswezla_c)
  set @priid = @priid + 1
 end
set nocount off
