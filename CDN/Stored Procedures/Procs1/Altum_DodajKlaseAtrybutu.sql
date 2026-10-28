create procedure cdn.Altum_DodajKlaseAtrybutu
@AtkSynchId nvarchar(36),
@Nazwa nvarchar(41),
@Typ smallint,
@Format smallint,
@Domyslna nvarchar(1000),--13
@Zamkniety bit,
@Aktywny bit,
@Wymagany bit,
@Opis nvarchar(1000),--256
@Synchronizowany tinyint,
@Throw nvarchar(256) output
 as
 set nocount on
  set @Throw = ''
  begin try
   declare
   @Maska nvarchar(max),
   @FormatZap nvarchar(max)
set @Aktywny = case when @Aktywny = 0 then 1 else 0 end;
if @Format = 1
  set @FormatZap  = 'Tekst'
 else if @Format = 2
  set @FormatZap  = '1234'
 else if @Format = 3
  set @FormatZap  = '1234.56'
 else if @Format = 4
  set @FormatZap  = '1234.5678'
 if @FormatZap = '1234'
  set @Maska  = '@n4.0'
 else if @FormatZap = '1234.56'
  set @Maska  = '@n7.2'
 else if @FormatZap = '1234.5678'
  set @Maska  = '@n9.4'
 else if @FormatZap = 'Tekst'
  set @Maska  = '@s100'
 if @Typ = 1
  set @Typ  = 2
 else if @Typ = 2
  set @Typ  = 3
 else if @Typ = 4
  set @Typ  = 1
 else if @Typ = 5
  set @Typ  = 4
 IF @Typ = 1
  BEGIN
   if @Domyslna = 'TRUE'
    set @Domyslna = 'Tak'
   else if @Domyslna = 'FALSE'
    set @Domyslna = 'Nie'
  END
if len(@Nazwa) = 0
  begin
   set @Throw = '##OPT34224##'
   return
  end
    Begin
    insert into CDN.OAtrybutyKlasy
    (
     ATK_Nazwa,
     atk_typ,
     atk_opis,
     atk_format,
     atk_zlisty,
     atk_zamknieta,
     atk_wymagany,
     atk_controlling,
     atk_automat,
     atk_nieaktywny,
     atk_historia,
     atk_sql,
     atk_domyslna,
     atk_domyslnaapi,
     atk_domyslnasql,
     atk_domyslnaapisql,
     atk_typdom,
     atk_typdomapi,
     atk_charset,
     atk_maska,
     atk_SynchronizowanyXL,
  ATK_ImportRowId,
  ATK_SynchronizowanyAltum
    )
    values
    (
     @Nazwa,
     @Typ,
     @Opis,
     @FormatZap,
     0,
     @Zamkniety,
     @Wymagany,
     0,
     0,
     @Aktywny,
     0,
  '',
    @Domyslna,
     '',
     '',
     '',
     0,
     0,
     238,
     @Maska,
     0,
  @AtkSynchId,
  @Synchronizowany
    )
  IF @Typ = 1
  BEGIN
   declare @idAtk int
   set @idAtk =  (select SCOPE_IDENTITY())
   insert into CDN.OAtrybutyKlasyElem (AKE_AtkId,AKE_Wartosc) values (@idAtk,'Nie')
   insert into CDN.OAtrybutyKlasyElem (AKE_AtkId,AKE_Wartosc) values (@idAtk,'Tak')
  END
   END
  end try
  begin catch
   set @Throw = '##OPT34225##'
  end catch
set nocount off
