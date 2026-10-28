Create Procedure CDN.KontrolaSaldaInfo @Poziom Int, @Status Char(1), @Opis NVARCHAR(70), @KwotaWn Numeric(15,2), @KwotaMa Numeric(15,2), @KwotaWnWal Numeric(15,2), @KwotaMaWal Numeric(15,2), @Waluta NVARCHAR(3), @DeNNumer NVARCHAR(30), @DeNId Int, @DokNumer NVARCHAR(30), @DokTyp Int, @DokId Int
As
Begin
If @Waluta = '' Set @Waluta = CDN.Waluta('')
Insert InTo #Dokumenty (Poziom,  Status,  Opis,  KwotaWn,  KwotaMa,  KwotaWnWal,  KwotaMaWal,  Waluta,  DeNNumer,  DeNId,  DokNumer,  DokTyp,  DokId)
                Values (@Poziom, @Status, @Opis, @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @Waluta, @DeNNumer, @DeNId, @DokNumer, @DokTyp, @DokId)
If @Poziom = 2 And @Status <> 'I'
 Begin
-- Ustawienie statusu w nagłówku
  Declare @RootStat NVARCHAR(1)
  Select @RootStat = Status From #Dokumenty Where Poziom = 1
  If @Status = 'E' And @RootStat <> 'E' Or @Status = 'W' And @RootStat = 'I'
  Update #Dokumenty Set Status = @Status Where Poziom = 1
 End
End
