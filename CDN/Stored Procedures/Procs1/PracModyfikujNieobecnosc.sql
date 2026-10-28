create procedure CDN.PracModyfikujNieobecnosc
 @prac int,   -- id pracownika
 @czas datetime = null,  -- czas modyfikacji danych
 @id int = null,   -- id nieobecności (gdy null to dodajemy)
 @typ int = null,  -- id typu nieobecności (gdy null to usuwamy)
 @dataOd datetime = null, -- okres od
 @dataDo datetime = null, -- okres do
 @opis NVARCHAR(253) = null, -- opis nieobecności
 @orgTyp int = null,  -- id typu nieobecności
 @orgOd datetime = null,  -- okres od
 @orgDo datetime = null,  -- okres do
 @orgOpis NVARCHAR(253) = null, -- opis nieobecności
 @przyczyna int = null,  -- przyczyna nieobecności
 @orgPrzyczyna int = null -- przyczyna nieobecności
as
begin
set nocount on
if @czas is null set @czas=GETDATE()
declare @baza datetime
set @baza = convert(datetime,'1899-12-30',120)
declare @limId int
declare @limTp int
declare @limOd datetime
declare @limDo datetime
declare @limWa datetime
declare @limGd smallint
declare @dni decimal(15,4)
declare @min int
if @dataOd>@dataDo
  begin
    RAISERROR('##OPT32122##', 16, 1)--raiserror('Nieprawidłowy okres nieobecności.',16,1) --ERR_SQL_Place_NieprawidlowyOkresNieob
    return
  end
if (select TNB_Nieaktywny from CDN.TypNieobec where TNB_TnbId=@typ)<>0
  begin
    RAISERROR('##OPT32123##', 16, 1)--raiserror('Typ nieobecności jest nieaktywny.',16,1) --ERR_SQL_Place_TypNieobecNieaktywny
    return
  end
begin tran
if @id is null
  begin
    insert into CDN.PracNieobec (PNB_PraId,PNB_TnbId,PNB_Tryb,PNB_OkresOd,PNB_OkresDo,PNB_Opis,
  PNB_TyUId,PNB_RozliczData,PNB_KodNieobecnosci,PNB_PomnZasilek,PNB_PrzedluzenieOZ,
  PNB_KontynuacjaOZ,PNB_UrlopNaZadanie,PNB_Przyczyna,PNB_NaPodstPoprzNB,PNB_Seria,PNB_Numer,
  PNB_DniPracy,PNB_DniKalend,PNB_Calodzienna,PNB_Godz,PNB_WymiarL,PNB_WymiarM,PNB_TS_Zal,PNB_TS_Mod)
 select @prac,@typ,0,@dataOd,@dataDo,@opis,99999,@baza,'',0,0,0,0,isnull(@przyczyna,1),0,'','',
  count(*),datediff(day,@dataOd,@dataDo)+1,1,null,null,null,@czas,@czas
 from CDN.PracCzasPracyFN(3,@prac,@dataOd,@dataDo)
 where TypDnia=1
    set @id = @@IDENTITY
  end
else
  begin
    if exists(select * from CDN.WypSkladniki where WPS_PraId=@prac
 and WPS_DataOd<@orgDo and @orgOd<WPS_DataDo
 and (select TWP_Zasadnicze from CDN.TypWyplata where TWP_TwpId=WPS_TwpId)>0)
      begin
 rollback
 RAISERROR('##OPT32124##', 16, 1)--raiserror('Naliczono wypłatę w poprzednim okresie nieobecności.',16,1) --ERR_SQL_Place_NaliczonoOkresNieob
 return
      end
    declare Limity cursor local fast_forward for
      select PLN_PlnId, PLN_LnbId, PLN_OkresOd, PLN_OkresDo, PLN_WaznyOd, LNB_Godzinowy
 from CDN.TypNieobec
 inner join CDN.LimitNieobec on LNB_LnbId=TNB_LnbId
 inner join CDN.PracLimit on PLN_LnbId=LNB_LnbId and PLN_PraId=@prac
 where TNB_TnbId=@orgTyp and PLN_OkresOd<=@orgDo and @orgOd<=PLN_OkresDo
    open Limity
    while 1=1
      begin
 fetch next from Limity into @LimId, @limTp, @limOd, @limDo, @limWa, @limGd
 if @@fetch_status<>0 break
 select top 1 @limDo = PLN_WaznyOd
     from CDN.PracLimit
     where PLN_PraId=@prac and PLN_LnbId=@limTp and @limWa<PLN_WaznyOd and PLN_WaznyOd<@limDo
     order by PLN_WaznyOd
        if @limOd<@orgOd set @limOd=@orgOd
 if @limDo>@orgDo set @limDo=@orgDo
 if @limOd>@limDo continue
 select @dni = sum(case when TypDnia=1 then 1 else 0 end), @min = sum(Norma)
     from CDN.PracCzasPracyFN(2,@prac,@limOd,@limDo)
 if @limGd=0
   set @min = 0
 else
   select @dni = CONVERT(decimal(15,4),@min)/datediff(minute,@baza,PRE_ETANormaDobowa)
     from CDN.PracEtaty where PRE_PraId=@prac and @limDo between PRE_DataOd and PRE_DataDo
 update CDN.PracLimit
     set PLN_WykorzystaneCzas = case when
  dateadd(minute,-@min,PLN_WykorzystaneCzas)<@baza then
  @baza else dateadd(minute,-@min,PLN_WykorzystaneCzas) end,
  PLN_PozostaloCzas = case when dateadd(minute,-@min,PLN_WykorzystaneCzas)<@baza then
   PLN_NalezneLacznieCzas else dateadd(minute,abs(datediff(minute,@baza,PLN_NalezneLacznieCzas)
   -datediff(minute,@baza,dateadd(minute,-@min,PLN_WykorzystaneCzas))),@baza) end,
  PLN_WykorzystaneF = case when PLN_WykorzystaneF<@dni then 0 else PLN_WykorzystaneF-@dni end,
  PLN_PozostaloF = case when PLN_WykorzystaneF<@dni then PLN_NalezneLacznieF else PLN_PozostaloF+@dni end
     where PLN_PlnId=@limId
 if @@RowCount=0
   begin
     close Limity
     deallocate Limity
     rollback
     RAISERROR('##OPT32125##', 16, 1)--raiserror('Błąd podczas przywracania limitu nieobecności.',16,1) --ERR_SQL_Place_BladPrzywracaniaLimitu
     return
   end
      end
    close Limity
    deallocate Limity
    if @typ is null
      begin
     delete from CDN.PracNieobec where PNB_PnbId=@id and PNB_PraId=@prac and PNB_TnbId=@orgTyp
     and PNB_OkresOd=@orgOd and PNB_OkresDo=@orgDo and PNB_Opis=@orgOpis and PNB_Przyczyna=isnull(@orgPrzyczyna,PNB_Przyczyna)
      end
    else
      begin
 update CDN.PracNieobec set PNB_TnbId=@typ, PNB_OkresOd=@dataOd, PNB_OkresDo=@dataDo,
  PNB_Opis=@opis, PNB_TS_Mod=@czas, PNB_OpeModId=null, PNB_StaModId=null,
  PNB_DniPracy=(select count(*) from CDN.PracCzasPracyFN(3,@prac,@dataOd,@dataDo) where TypDnia=1),
  PNB_DniKalend=datediff(day,@dataOd,@dataDo)+1, PNB_Przyczyna=isnull(@przyczyna,PNB_Przyczyna)
      where PNB_PnbId=@id and PNB_PraId=@prac and PNB_TnbId=@orgTyp
  and PNB_OkresOd=@orgOd and PNB_OkresDo=@orgDo and PNB_Opis=@orgOpis and PNB_Przyczyna=isnull(@orgPrzyczyna,PNB_Przyczyna)
    end
  end
if @@RowCount=0
  begin
    rollback
    RAISERROR('##OPT32128##', 16, 1)--raiserror('Nieobecność została zmieniona na innym stanowisku.',16,1) --ERR_SQL_Place_NieobZmienionaStan
    return
  end
if @typ is not null
  begin
    if exists(select * from CDN.WypSkladniki where WPS_PraId=@prac
 and WPS_DataOd<@dataDo and @dataOd<WPS_DataDo
 and (select TWP_Zasadnicze from CDN.TypWyplata where TWP_TwpId=WPS_TwpId)>0)
      begin
 rollback
 RAISERROR('##OPT32129##', 16, 1)--raiserror('Naliczono wypłatę w bieżacym okresie nieobecności.',16,1) --ERR_SQL_Place_NaliczonoWyplateBiezOkres
 return
      end
    if exists(select * from CDN.PracPracaDni
 where PPR_PraId=@prac and PPR_Data between @dataOd and @dataDo)
      or exists(select * from CDN.PracNieobec where PNB_PraId=@prac and PNB_Tryb<>1
 and PNB_PnbId<>ISNULL(@id,0) and PNB_OkresOd<=@dataDo and @dataOd<=PNB_OkresDo)
      begin
 rollback
 RAISERROR('##OPT32131##', 16, 1)--raiserror('Pracownik ma wprowadzone inne zapisy w okresie nieobecności.',16,1) --ERR_SQL_Place_PracownikZapisyNieob
 return
      end
    declare Limity cursor local fast_forward for
      select PLN_PlnId, PLN_LnbId, PLN_OkresOd, PLN_OkresDo, PLN_WaznyOd, LNB_Godzinowy
 from CDN.TypNieobec
 inner join CDN.LimitNieobec on LNB_LnbId=TNB_LnbId
 inner join CDN.PracLimit on PLN_LnbId=LNB_LnbId and PLN_PraId=@prac
 where TNB_TnbId=@typ and PLN_OkresOd<=@dataDo and @dataOd<=PLN_OkresDo
    open Limity
    while 1=1
      begin
 fetch next from Limity into @LimId, @limTp, @limOd, @limDo, @limWa, @limGd
 if @@fetch_status<>0 break
 select top 1 @limDo = PLN_WaznyOd
     from CDN.PracLimit
     where PLN_PraId=@prac and PLN_LnbId=@limTp and @limWa<PLN_WaznyOd and PLN_WaznyOd<@limDo
     order by PLN_WaznyOd
        if @limOd<@dataOd set @limOd=@dataOd
 if @limDo>@dataDo set @limDo=@dataDo
 if @limOd>@limDo continue
 select @dni = sum(case when TypDnia=1 then 1 else 0 end), @min = sum(Norma)
     from CDN.PracCzasPracyFN(2,@prac,@limOd,@limDo)
 if @limGd=0
   set @min = 0
 else
   select @dni = CONVERT(decimal(15,4),@min)/datediff(minute,@baza,PRE_ETANormaDobowa)
     from CDN.PracEtaty where PRE_PraId=@prac and @limDo between PRE_DataOd and PRE_DataDo
 update CDN.PracLimit
     set PLN_WykorzystaneCzas = dateadd(minute,@min,PLN_WykorzystaneCzas),
  PLN_PozostaloCzas = dateadd(minute,abs(datediff(minute,@baza,PLN_NalezneLacznieCzas)
   -datediff(minute,@baza,dateadd(minute,@min,PLN_WykorzystaneCzas))),@baza),
  PLN_WykorzystaneF = PLN_WykorzystaneF+@dni, PLN_PozostaloF = PLN_PozostaloF-@dni
     where PLN_PlnId=@limId
 if @@RowCount=0
   begin
     close Limity
     deallocate Limity
     rollback
     RAISERROR('##OPT32132##', 16, 1)--raiserror('Błąd podczas aktualizowania limitu nieobecności.',16,1) --ERR_SQL_Place_BladAktLimit
     return
   end
      end
    close Limity
    deallocate Limity
  end
commit
set nocount off
end
