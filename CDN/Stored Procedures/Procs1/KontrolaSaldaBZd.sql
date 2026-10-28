Create Procedure CDN.KontrolaSaldaBZd @AccId Int, @BRKKwota Numeric (15,2), @BRKKwotaWal Numeric (15,2), @BRRDokId Int, @Strona Int, @DeNZrdId Int, @DeNZrdNumer NVARCHAR(30)
As
Begin
Declare @KwotaWn Numeric(15,2), @KwotaMa Numeric(15,2), @KwotaWnWal Numeric(15,2), @KwotaMaWal Numeric(15,2), @KwotaRazem Numeric(15,2), @KwotaRazemWal Numeric(15,2), @Strona2 Int
Declare @TypDok Int, @IdDok Int, @DokNumer NVARCHAR(30), @DeNNumer NVARCHAR(30), @BZdKwota Numeric(15,2), @BZdKwotaWal Numeric(15,2), @PodmiotTyp Int, @PodmiotId Int, @DeNId Int
Declare @AccRozId Int, @KwotaRoz Decimal(15,2), @KwotaRozWal Decimal(15,2)
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
If @BRKKwota < 0 Set @Kierunek = 1
Else Set @Kierunek = -1
If Not Exists (Select * From CDN.BnkZdarzenia Where BZd_BZdId = @BRRDokId)
 Begin
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Błąd odczytu zdarzenia rozliczającego', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, '', null, null
  Return
 End
Select
 @DokNumer = Case When BZd_NumerObcy <> '' Then BZd_NumerObcy Else BZd_NumerPelny End,
 @TypDok = BZd_DokumentTyp,
 @IdDok = BZd_DokumentId,
 @BZdKwota = BZd_KwotaSys,
 @BZdKwotaWal = BZd_Kwota,
 @PodmiotId = BZd_PodmiotId,
 @PodmiotTyp = BZd_PodmiotTyp
 From CDN.BnkZdarzenia
 Where BZd_BZdId = @BRRDokId
If @AccWaluta = '' Set @BZdKwotaWal = @BZdKwota
Set @DeNId = Null
If @TypDok = 0 Or @TypDok Is Null
 Begin
  exec CDN.KontrolaSaldaInfo 2, 'W', 'Zdarzenie rozliczające "ręczne"', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DokNumer, -2, @BRRDokId
  Return
 End
Else If @TypDok = 1
 Select @DeNId = TrN_DekId, @DokNumer = Case When TrN_NumerObcy <> '' Then TrN_NumerObcy Else TrN_NumerPelny End From CDN.TraNag Where TrN_TrNId = @IdDok
Else If @TypDok = 2
 Select @DeNId = VaN_DekId, @DokNumer = VaN_Dokument From CDN.VatNag Where VaN_VaNId = @IdDok
Else If @TypDok = 6
 Select @DeNId = DkN_DekId, @DokNumer = CDN.DeklNumer(DkN_DkNId) From CDN.DeklNag Where DkN_DkNId = @IdDok
Else If @TypDok = 11
 Select @DeNId = NON_DekId, @DokNumer = NON_NumerPelny From CDN.NotyOdsNag Where NON_NONId = @IdDok
Else If @TypDok = 12
 Select @DeNId = EDN_DekId, @DokNumer = Case When EDN_NumerObcy <> '' Then EDN_NumerObcy Else EDN_NumerPelny End From CDN.EwidDodNag Where EDN_EDNId = @IdDok
Else If @TypDok = 8
 Select @DeNId = LPL_DekId, @DokNumer = WPL_NumerPelny From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId Where WPL_WPLId = @IdDok
Else If @TypDok In (27,28)
 Select @DeNId = DeE_DeNId, @DokNumer = DeE_Dokument From CDN.DekretyElem Where DeE_DeEId = @IdDok
Else If @TypDok In (39,40)
 Select @DeNId = -BOE_BONId, @DokNumer = Case BOE_Dokument When '' Then BON_NumerPelny Else BOE_Dokument End From CDN.BONag Join CDN.BOElem On BON_BONId = BOE_BONId Where BOE_BOEId = @IdDok
If @DeNId Is Null
 Begin
-- Zgłaszamy, że raport jest niezaksięgowany
  exec CDN.KontrolaSaldaInfo 2, 'W', 'Dokument rozliczany (źródłowy) nie został zaksięgowany', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DokNumer, @TypDok, @IdDok
  Return
 End
-- Szukam dekretu lub dokumentu BO
If @TypDok In (39,40)
 Select @DenNumer = BON_NumerPelny From CDN.BONag Where BON_BONId = -@DeNId
Else
 Select @DeNNumer = LTrim(Str(DeN_NrKsiegi)) + Case DeN_Bufor When 1 Then ' (b)' Else '' End From CDN.DekretyNag Where DeN_DeNId = @DeNId
-- Tu trzeba zrobić przesiadkę ze zbiorczego księgowania paragonów na rejestr VAT
If @TypDok = 1
  If Exists (Select * From CDN.TraNag A Join CDN.TraNag B On A.TrN_VaNId = B.TrN_VaNId And A.TrN_DekId = B.TrN_DekId And A.TrN_TrNId <> B.TrN_TrNId Where A.TrN_TrNId = @IdDok)
    Begin
      Set @TypDok = 2
      Select @IdDok = VaN_VaNId, @DokNumer = VaN_Dokument From CDN.TraNag Join CDN.VatNag On TrN_VaNId = VaN_VaNId Where TrN_TrNId = @IdDok
    End
-- liczę całkowitą kwotę płatności na dokumencie
Select
 @KwotaRazem    = Abs(Sum(BZd_KwotaSys*BZd_Kierunek)),
 @KwotaRazemWal = Abs(Sum(BZd_Kwota*BZd_Kierunek))
From CDN.BnkZdarzenia
-- Where BZd_DokumentTyp = @TypDok And BZd_DokumentId = @IdDok
Where BZd_BZdId In (Select BZd_BZdId From CDN.fnBnkZdarzenia (@TypDok, @IdDok))
If @AccWaluta = '' Set @KwotaRazemWal = @KwotaRazem
-- Uwaga poniższe jest po to, że szukamy dokumentu w którym zgadza się kwota, ale takiego, żeby zgadzał się przynajmniej numer dokumentu albo podmiot
Set @AccRozId = Null
If @TypDok In (27,28)
  Select @AccRozId = Case @TypDok When 27 Then DeE_AccWnId Else DeE_AccMaId End From CDN.DekretyElem Where DeE_DeEId = @IdDok
Else If @TypDok In (39,40)
  Select @AccRozId = BOE_AccId From CDN.BOElem Where BOE_BOEId = @IdDok
Else
 Select Top 1 @AccRozId = Case When DeE_AccWnId=@AccId Then DeE_AccWnId When DeE_AccMaId=@AccId Then DeE_AccMaId When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then DeE_AccMaId Else DeE_AccWnId End, @KwotaRoz = Sum(DeE_Kwota * (Case When DeE_AccWnId=@AccId Then 1 When DeE_AccMaId=@AccId Then -1 When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then -1 Else -1 End))
  From CDN.DekretyElem
  Where DeE_DeNId = @DeNId
  Group By Case When DeE_AccWnId=@AccId Then DeE_AccWnId When DeE_AccMaId=@AccId Then DeE_AccMaId When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then DeE_AccMaId Else DeE_AccWnId End, DeE_Dokument, DeE_SlownikTyp, DeE_SlownikId
  Having Abs(Sum(DeE_Kwota * (Case When DeE_AccWnId=@AccId Then 1 When DeE_AccMaId=@AccId Then -1 When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then -1 Else -1 End))) = @KwotaRazem
  Order By
   Case When DeE_SlownikTyp = @PodmiotTyp And DeE_SlownikId = @PodmiotId Then 0 Else 1 End,
   Case When Case When DeE_AccWnId=@AccId Then DeE_AccWnId When DeE_AccMaId=@AccId Then DeE_AccMaId When @Kierunek*DeE_Kwota<0 And @Strona=1 Or @Kierunek*DeE_Kwota>=0 And @Strona = 2 Then DeE_AccMaId Else DeE_AccWnId End = @AccId Then 0 Else 1 End
If @AccRozId Is Null
 Begin
-- Zgłaszamy, że nie znaleźliśmy elementu dekretu odpowiadającego zapisowi
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Błąd ustalania księgowania rozliczającego', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DokNumer, @TypDok, @IdDok
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
  Set @TmpOpis = 'Księgowanie dokumentu rozliczanego na inne konto ' + @AccNumer
  Set @TypDok = Case When @TypDok In (39,40) Then -4 Else -3 End
  exec CDN.KontrolaSaldaInfo 2, 'W', @TmpOpis, @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNZrdNumer, @DeNZrdId, @DeNNumer, @TypDok, @DeNId
  Return
 End
End
