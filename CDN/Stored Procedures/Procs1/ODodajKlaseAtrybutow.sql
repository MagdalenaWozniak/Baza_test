Create Procedure CDN.ODodajKlaseAtrybutow @Nazwa varchar(41), @Opis nvarchar(256), @Wymagany tinyint, @Automat tinyint, @Zamknieta tinyint, @Typ tinyint,
@SynchronizowanyXL tinyint, @Format nvarchar(21), @Domyslna nvarchar(101) = ''
AS
begin
set nocount on
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
  declare
   @s nvarchar,
   @Maska nvarchar(max)
 if @Format = '1234'
  set @Maska  = '@n4.0'
 else if @Format = '1234.56'
  set @Maska  = '@n7.2'
 else if @Format = '1234.5678'
  set @Maska  = '@n9.4'
 else if @Format = 'Data'
  set @Maska  = '@d17'
 else if @Format = 'Tekst'
  set @Maska  = '@s100'
 else
  set @Maska = @Format
  set @Format = '(*)Zaawansowany'
 IF @Typ = 1
  BEGIN
   if @Domyslna = 'TAK'
    set @Domyslna = 'Tak'
   else if @Domyslna = 'NIE'
    set @Domyslna = 'Nie'
  END
if LEN(@Nazwa) > 0
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
     atk_SynchronizowanyXL
    )
    values
    (
     @Nazwa,
     @Typ,
     @Opis,
     @Format,
     0,
     @Zamknieta,
     @Wymagany,
     0,
     0,
     0,
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
     1
    )
  IF @Typ = 1
  BEGIN
   declare @idAtk int
   set @idAtk =  (select SCOPE_IDENTITY())
   insert into CDN.OAtrybutyKlasyElem (AKE_AtkId,AKE_Wartosc) values (@idAtk,'Nie')
   insert into CDN.OAtrybutyKlasyElem (AKE_AtkId,AKE_Wartosc) values (@idAtk,'Tak')
  END
   END
if @@error<>0 and @@trancount<>0
    begin
        rollback tran
        set @s = '##OPT32379##'
        raiserror(@s, 16, 1)
    end
End
