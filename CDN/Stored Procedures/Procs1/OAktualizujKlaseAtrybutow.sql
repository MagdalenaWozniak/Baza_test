Create Procedure CDN.OAktualizujKlaseAtrybutow @OptimaID int, @Nazwa varchar(41), @Opis nvarchar(256), @Wymagany tinyint, @Automat tinyint, @Zamknieta tinyint, @Typ tinyint,
@SynchronizowanyXL tinyint, @Format nvarchar(21), @Domyslna nvarchar(101) = ''
AS
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
@s nvarchar
Begin
  declare
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
      Update CDN.OAtrybutyKlasy
      set
          ATK_Nazwa = @Nazwa,
          ATK_Opis = @Opis,
          ATK_Typ = @Typ,
          ATK_Format = @Format,
          Atk_zamknieta = @Zamknieta,
          ATK_Wymagany = @Wymagany,
          ATK_Automat = @Automat,
          ATK_SynchronizowanyXL = @SynchronizowanyXL,
    ATK_Maska = @Maska,
    ATK_Domyslna = @Domyslna
      where ATK_AtkId = @OptimaID
    IF @Typ = 1
  BEGIN
  delete from cdn.OAtrybutyKlasyElem where AKE_AtkId =  @OptimaID
   insert into CDN.OAtrybutyKlasyElem (AKE_AtkId,AKE_Wartosc) values (@OptimaID,'Nie')
   insert into CDN.OAtrybutyKlasyElem (AKE_AtkId,AKE_Wartosc) values (@OptimaID,'Tak')
  END
   END
if @@error<>0 and @@trancount<>0
    begin
        rollback tran
        set @s = '##OPT32380##'
        raiserror(@s, 16, 1)
    end
End
