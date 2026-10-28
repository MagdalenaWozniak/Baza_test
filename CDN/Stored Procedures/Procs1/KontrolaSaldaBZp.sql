Create Procedure CDN.KontrolaSaldaBZp @AccId Int, @BRKKwota Numeric (15,2), @BRKKwotaWal Numeric (15,2), @BRRDokId Int, @Strona Int, @DeNZrdId Int, @DeNZrdNumer NVARCHAR(30)
As
Begin
Declare @BZpNumerObcy NVARCHAR(30), @BZpNumerPelny NVARCHAR(30), @BZpKwota Numeric (15,2), @BZpKwotaWal Numeric (15,2), @BRpId Int, @DeNId Int, @DeEId Int, @AccRozId Int
Declare @PodmiotTyp Int, @PodmiotId Int, @DeNNumer NVARCHAR (30), @DokNumer NVARCHAR(30)
Declare @KwotaWn Numeric(15,2), @KwotaMa Numeric(15,2), @KwotaWnWal Numeric(15,2), @KwotaMaWal Numeric(15,2), @Strona2 Int
Declare @TmpOpis NVARCHAR(70)
Declare @Kierunek Int
Declare @AccWaluta NVARCHAR(3)
Select @AccWaluta = Acc_Waluta From CDN.Konta Where Acc_AccId = @AccId
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
If @BRKKwota >= 0 Set @Kierunek = 1
Else Set @Kierunek = -1
If Not Exists (Select * From CDN.BnkZapisy Where BZp_BZpId = @BRRDokId)
 Begin
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Błąd odczytu zapisu rozliczającego', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, '', null, null
  Return
 End
Select @BRpId = BZp_BRpId, @DokNumer = BRp_NumerPelny, @BZpKwota = BZp_KwotaSys, @BZpKwotaWal = BZp_Kwota, @BZpNumerObcy = BZp_NumerObcy , @BZpNumerPelny = BZp_NumerPelny, @PodmiotTyp = BZp_PodmiotTyp, @PodmiotId = BZp_PodmiotId
 From CDN.BnkZapisy Join CDN.BnkRaporty On BRp_BRpId = BZp_BRpId Where BZp_BZpId = @BRRDokId
If @AccWaluta = '' Set @BZpKwotaWal = @BZpKwota
Set @DeNId = Null
-- Szukam dekretu
Select @DeNId = BRp_DekId, @DeNNumer = LTrim(Str(DeN_NrKsiegi)) + Case DeN_Bufor When 1 Then ' (b)' Else '' End
  From CDN.BnkRaporty Left Outer Join CDN.DekretyNag On DeN_DeNId = Brp_DekId Where BRp_BRpId = @BRpId
If @DeNId Is Null
 Begin
-- Zgłaszamy, że raport jest niezaksięgowany
  exec CDN.KontrolaSaldaInfo 2, 'W', 'Raport kasowy zawierający zapis rozliczający nie został zaksięgowany', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DokNumer, 9, @BRpId
  Return
 End
Set @AccRozId = Null
-- Uwaga poniższe jest po to, że szukamy dokumentu w którym zgadza się kwota, ale takiego, żeby zgadzał się przynajmniej numer dokumentu albo podmiot
Select Top 1 @AccRozId = Case When DeE_AccWnId=@AccId Then DeE_AccWnId When DeE_AccMaId=@AccId Then DeE_AccMaId When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then DeE_AccWnId Else DeE_AccMaId End, @DokNumer = DeN_Dokument
 From CDN.DekretyElem Join CDN.DekretyNag On DeE_DeNId = DeN_DeNId
 Where DeN_DeNId = @DeNId And Abs(DeE_Kwota) = @BZpKwota And Abs(DeE_KwotaWal) = @BZpKwotaWal
 Order By
  Case When DeE_Dokument In (@BZpNumerPelny, @BZpNumerObcy) Then 0 Else 1 End,
  Case When DeE_SlownikTyp = @PodmiotTyp And DeE_SlownikId = @PodmiotId Then 0 Else 1 End,
  Case When Case When DeE_AccWnId=@AccId Then DeE_AccWnId When DeE_AccMaId=@AccId Then DeE_AccMaId When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then DeE_AccWnId Else DeE_AccMaId End = @AccId Then 0 Else 1 End
If @AccRozId Is Null
 Begin
-- Zgłaszamy, że nie znaleźliśmy elementu dekretu odpowiadającego zapisowi
  Set @TmpOpis = Case When @BZpNumerObcy<>'' Then @BZpNumerObcy Else @BZpNumerPelny End
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Błąd ustalania księgowania rozliczającego', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @TmpOpis, -1, @BRRDokId
  Return
 End
-- Pobieramy konto powiązane w poprzednim i następnym okresie
Declare @NextAccId INT
Select @NextAccId = Acc_NextAccId from CDN.Konta where Acc_AccId = @AccId
Declare @PrevAccId INT
Select @PrevAccId = Acc_AccId from CDN.Konta where Acc_NextAccId = @AccId
If Not (@AccRozId = @PrevAccId or @AccRozId = @AccId or @AccRozId = @NextAccId)
 Begin
  Declare @AccNumer NVARCHAR(50)
  Set @AccNumer = ''
  Select @AccNumer = Acc_Numer From CDN.Konta Where Acc_AccId = @AccRozId
  Set @TmpOpis = 'Księgowanie dokumentu rozliczającego na inne konto ' + @AccNumer
  exec CDN.KontrolaSaldaInfo 2, 'W', @TmpOpis, @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DeNNumer, -3, @DeNId
  Return
 End
End
