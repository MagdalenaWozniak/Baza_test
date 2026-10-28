Create Procedure CDN.KontrolaSaldaBRK @AccId Int, @BRKKwota Numeric (15,2), @BRRDokId Int, @Strona Int, @DeNZrdId Int, @DeNZrdNumer NVARCHAR(30)
As
Begin
Declare @KwotaWn Numeric(15,2), @KwotaMa Numeric(15,2), @KwotaWnWal Numeric(15,2), @KwotaMaWal Numeric(15,2), @BRKKwotaWal Numeric(15,2)
Declare @DokNumer NVARCHAR(30), @DeNNumer NVARCHAR(30), @DeNId Int
Declare @AccRozId Int
Declare @TmpOpis NVARCHAR(70)
Declare @Kierunek Int
Declare @AccWaluta NVARCHAR(3)
Select @AccWaluta = Acc_Waluta From CDN.Konta Where Acc_AccId = @AccId
If @AccWaluta = '' Set @BRKKwotaWal = @BRKKwota
Else  Set @BRKKwotaWal = 0
Set @KwotaWn    = 0
Set @KwotaMa    = 0
Set @KwotaWnWal = 0
Set @KwotaMaWal = 0
If @Strona = 1
 Begin
 Set @KwotaWn    = @BRKKwota
 Set @KwotaWnWal = @BRKKwotaWal
 End
Else
 Begin
 Set @KwotaMa    = @BRKKwota
 Set @KwotaMaWal = @BRKKwotaWal
 End
If @BRKKwota < 0 Set @Kierunek = 1
Else Set @Kierunek = -1
If Not Exists (Select * From CDN.BnkRozKwoty Where BRK_BRKId = @BRRDokId)
 Begin
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Błąd odczytu różnicy kursowej', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, '', null, null
  Return
 End
Set @DeNId = Null
 Select @DeNId = BRK_DekId, @DokNumer = BRK_NumerPelny From CDN.BnkRozKwoty Where BRK_BRKId = @BRRDokId
If @DeNId Is Null
 Begin
-- Zgłaszamy, że różnica jest niezaksięgowana
  exec CDN.KontrolaSaldaInfo 2, 'W', 'Różnica kursowa nie została zaksięgowana', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DokNumer, 13, @BRRDokId
  Return
 End
Select @DeNNumer = LTrim(Str(DeN_NrKsiegi)) + Case DeN_Bufor When 1 Then ' (b)' Else '' End From CDN.DekretyNag Where DeN_DeNId = @DeNId
Set @AccRozId = Null
Select Top 1 @AccRozId = Case When DeE_AccWnId=@AccId Then DeE_AccWnId When DeE_AccMaId=@AccId Then DeE_AccMaId When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then DeE_AccMaId Else DeE_AccWnId End
 From CDN.DekretyElem
 Where DeE_DeNId = @DeNId And Abs(DeE_Kwota) = Abs(@BRKKwota) And Abs(DeE_KwotaWal) = Abs(@BRKKwotaWal)
 Order By
  Case When Case When DeE_AccWnId=@AccId Then DeE_AccWnId When DeE_AccMaId=@AccId Then DeE_AccMaId When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then DeE_AccMaId Else DeE_AccWnId End = @AccId Then 0 Else 1 End
If @AccRozId Is Null
 Begin
-- Zgłaszamy, że nie znaleźliśmy elementu dekretu odpowiadającego różnicy
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Błąd ustalania księgowania różnicy kursowej', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DokNumer, 13, @BRRDokId
  Return
 End
If Not (@AccRozId = @AccId)
 Begin
  Declare @AccNumer NVARCHAR(50)
  Set @AccNumer = ''
  Select @AccNumer = Acc_Numer From CDN.Konta Where Acc_AccId = @AccRozId
  Set @TmpOpis = 'Księgowanie różnicy kursowej na inne konto ' + @AccNumer
  exec CDN.KontrolaSaldaInfo 2, 'W', @TmpOpis, @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DeNNumer, -3, @DeNId
  Return
 End
End
