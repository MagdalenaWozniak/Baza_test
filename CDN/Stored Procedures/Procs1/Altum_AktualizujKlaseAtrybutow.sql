create procedure cdn.Altum_AktualizujKlaseAtrybutow
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
  if len(@Nazwa) = 0
  begin
   set @Throw = '##OPT34224##'
   return
  end
   declare
     @Maska nvarchar(max)
     if @Synchronizowany = 0
     begin
   Update CDN.OAtrybutyKlasy
     set
      ATK_SynchronizowanyAltum = @Synchronizowany
     where ATK_ImportRowId = @AtkSynchId
    return
     end
  set @Aktywny = case when @Aktywny = 0 then 1 else 0 end;
 declare @FormatZap nvarchar(max)
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
     Update CDN.OAtrybutyKlasy
     set
      ATK_Nazwa = @Nazwa,
      ATK_Opis = @Opis,
      ATK_Typ = @Typ,
      ATK_Format = @FormatZap,
      Atk_zamknieta = @Zamkniety,
      ATK_Wymagany = @Wymagany,
      ATK_Maska = @Maska,
      ATK_Domyslna = @Domyslna,
      ATK_SynchronizowanyAltum = @Synchronizowany,
   atk_SynchronizowanyXL = 0,
   ATK_Nieaktywny = @Aktywny
     where ATK_ImportRowId = @AtkSynchId
  end try
  begin catch
   set @Throw = '##OPT34232##'
  end catch
set nocount off
