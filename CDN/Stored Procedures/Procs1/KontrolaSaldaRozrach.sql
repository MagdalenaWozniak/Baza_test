Create Procedure CDN.KontrolaSaldaRozrach @AccId Int, @Poziom Int = 1
As
Begin
Set NoCount On
Declare @AccNumer NVARCHAR(50), @AccWaluta NVARCHAR(3)
Declare @BoWn Numeric(15,2), @BoMa Numeric(15,2), @BoWnWal Numeric(15,2), @BoMaWal Numeric(15,2), @KwotaWn Numeric(15,2), @KwotaMa Numeric(15,2), @KwotaTotWn Numeric(15,2), @KwotaTotMa Numeric(15,2), @KwotaWnWal Numeric(15,2), @KwotaMaWal Numeric(15,2), @KwotaTotWnWal Numeric(15,2), @KwotaTotMaWal Numeric(15,2)
Declare @DeNId Int, @Zrodlo Int, @Strona Int, @ZrodloId Int, @KwotaDek Numeric (15,2), @KwotaDekWal Numeric (15,2), @KwotaDok Numeric (15,2), @KwotaDokWal Numeric (15,2), @KwotaRoz Numeric (15,2), @KwotaRozWal Numeric (15,2)
Declare @BRKKwota Numeric(15,2), @BRKKwotaWal Numeric(15,2), @BRRDDokTyp Int, @BRRDDokId Int, @DeNNumer NVARCHAR(30), @DokNumer NVARCHAR(30), @DeENumer NVARCHAR(30), @PodmiotTyp Int, @PodmiotId Int
Declare @TmpOpis NVARCHAR(70)
Declare @Kierunek Int, @RoznicaK Decimal(15,2), @Platnosci Int, @DeEId Int
Declare @BZpId Int, @BZdId Int, @BZpNumer NVARCHAR(30), @BRKId Int
If Not Exists (Select Acc_AccId From CDN.Konta Where Acc_AccId = @AccId)
 Begin
  exec CDN.RiseOptimaException 32471
  Return
 End
Select @AccNumer = Acc_Numer, @AccWaluta = Acc_waluta From CDN.Konta Where Acc_AccId = @AccId
-- Tabela pomocnicza
Create Table #Dokumenty (Poziom Int, Status Char(1), Opis NVARCHAR(70), KwotaWn Numeric(15,2), KwotaMa Numeric(15,2), KwotaWnWal Numeric(15,2), KwotaMaWal Numeric(15,2), Waluta NVARCHAR(3), DeNNumer NVARCHAR(30), DeNId Int, DokNumer NVARCHAR(30), DokTyp Int, DokId Int)
-- Pobranie salda i bilansu otwarcia
Create Table #TmpObr (Tmp_AccId INT, Tmp_NumerIdx NVARCHAR(50), Tmp_BoWn Numeric(15,2), Tmp_BoMa Numeric(15,2), Tmp_ObrotyWn Numeric(15,2), Tmp_ObrotyMa Numeric(15,2), Tmp_ObrotyTotWn Numeric(15,2), Tmp_ObrotyTotMa Numeric(15,2), Tmp_SaldoWn Numeric(15,2), Tmp_SaldoMa Numeric(15,2), Tmp_PrstSaldaWn Numeric(15,2), Tmp_PrstSaldaMa Numeric(15,2), Tmp_Numer NVARCHAR(50), Tmp_Nazwa NVARCHAR(50), Tmp_Nazwa2 NVARCHAR(50), Tmp_Poziom Int, Tmp_ParId Int, Tmp_Analityka Int)
Insert #TmpObr Execute CDN.ObrotySalda null, null, 1, null, @AccId, 0
Select @BoWn = Tmp_BoWn, @BoMa = Tmp_BoMa, @KwotaTotWn = Tmp_SaldoWn, @KwotaTotMa = Tmp_SaldoMa From #TmpObr Where Tmp_AccId = @AccId
If @AccWaluta = ''
 Begin
  Set @BoWnWal       = @BoWn;
  Set @BoMaWal       = @BoMa;
  Set @KwotaTotWnWal = @KwotaTotWn;
  Set @KwotaTotMaWal = @KwotaTotMa;
 End
Else
 Begin
  Delete From #TmpObr
  Insert #TmpObr Execute CDN.ObrotySalda null, null, 1, null, @AccId, 0, 0, '', '', 0, @AccWaluta
  Select @BoWnWal = Tmp_BoWn, @BoMaWal = Tmp_BoMa, @KwotaTotWnWal = Tmp_SaldoWn, @KwotaTotMaWal = Tmp_SaldoMa From #TmpObr Where Tmp_AccId = @AccId
 End
Drop Table #TmpObr
-- Dodanie nagłówka
Set @TmpOpis = 'Konto ' + @AccNumer + ', saldo'
exec CDN.KontrolaSaldaInfo 1, 'I', @TmpOpis, @KwotaTotWn, @KwotaTotMa, @KwotaTotWnWal, @KwotaTotMaWal, @AccWaluta, '', null, '', null, null
If Not Exists (Select Acc_AccId From CDN.Konta Where Acc_AccId = @AccId And Acc_SlownikTyp In (1, 2, 3, 4, 5))
 Begin
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Konto nie jest kontem słownikowym', 0, 0, 0, 0, '', '', null, '', null, null
  Return
 End
-- Lista księgowań na koncie słownikowym + BO
Declare Ksiegowania Cursor Local Fast_Forward For
 Select -BON_BONId, -4, BON_NumerPelny, Case BOE_Dokument When '' Then BON_NumerPelny Else BOE_Dokument End, Acc_SlownikTyp, Acc_SlownikId, 1, BOE_Platnosci, Case BOE_Platnosci When 1 Then BOE_BOEId Else 0 End,
 -BOE_KwotaWn, -BOE_KwotaWnWal
 From CDN.BONag Join CDN.BOElem On BON_BONId = BOE_BONId Join CDN.Konta On BOE_AccId = Acc_AccId
 Where Acc_AccId = @AccId And (BOE_KwotaWn<>0 Or BOE_KwotaWnWal<>0)
Union All
 Select -BON_BONId, -4, BON_NumerPelny, Case BOE_Dokument When '' Then BON_NumerPelny Else BOE_Dokument End, Acc_SlownikTyp, Acc_SlownikId, 2, BOE_Platnosci, Case BOE_Platnosci When 1 Then BOE_BOEId Else 0 End,
 BOE_KwotaMa, BOE_KwotaMaWal
 From CDN.BONag Join CDN.BOElem On BON_BONId = BOE_BONId Join CDN.Konta On BOE_AccId = Acc_AccId
 Where Acc_AccId = @AccId And (BOE_KwotaMa<>0 Or BOE_KwotaMaWal<>0)
Union All
 Select DeN_DeNId, DeN_Zrodlo, LTrim(Str(DeN_NrKsiegi)) + Case DeN_Bufor When 1 Then ' (b)' Else '' End, DeE_Dokument, DeE_SlownikTyp, DeE_SlownikId, Max(DeK_Strona), DeE_Platnosci, Case DeE_Platnosci When 1 Then DeE_DeEId Else 0 End,
 Sum(Case DeK_Strona When 2 Then 1 Else -1 End * DeK_Kwota),  Sum(Case DeK_Strona When 2 Then 1 Else -1 End * DeK_KwotaWal)
 From CDN.DekretyKonta Join CDN.DekretyElem On DeK_DeEId = DeE_DeEId Join CDN.DekretyNag On DeK_DeNId = DeN_DeNId
 Where DeK_AccId = @AccId
 Group By
  DeN_DeNId,
  DeN_Zrodlo,
  LTrim(Str(DeN_NrKsiegi)) + Case DeN_Bufor When 1 Then ' (b)' Else '' End,
  DeE_Dokument,
  DeE_SlownikTyp,
  DeE_SlownikId,
  DeE_Platnosci,
  Case DeE_Platnosci When 1 Then DeE_DeEId Else 0 End,
  Case When DeN_Zrodlo=10 Then 0 Else DeK_Strona End
Open Ksiegowania
While 1=1
 Begin
  Fetch Next From Ksiegowania InTo @DeNId, @Zrodlo, @DeNNumer, @DeENumer, @PodmiotTyp, @PodmiotId, @Strona, @Platnosci, @DeEId, @KwotaDek, @KwotaDekWal
  If @@Fetch_Status <> 0 Break
  If @Strona = 1
   Begin
   Set @KwotaDek    = -1 * @KwotaDek
   Set @KwotaDekWal = -1 * @KwotaDekWal
   End
  If @KwotaDek >= 0
   Set @Kierunek = 1
  Else
   Set @Kierunek = -1
  Set @Zrodlo = IsNull(@Zrodlo, 0)
  Set @ZrodloId = 0
  Set @KwotaDok = 0
  Set @KwotaRoz = 0
  If @Zrodlo In (1, 2, 6, 10, 11, 12) Or @Zrodlo = 0 And @Platnosci <> 0 Or @Zrodlo = -4 And @Platnosci <> 0
   Begin
    -- Odczytanie Id dokumentu źródłowego
    If @Zrodlo = 0
     Begin
      If @Strona = 1 Set @Zrodlo = 27 Else Set @Zrodlo = 28
      Set @ZrodloId = @DeEId
      Select @DokNumer = DeE_Dokument From CDN.DekretyElem Where DeE_DeEId = @DeEId
     End
    If @Zrodlo = -4
     Begin
      If @Strona = 1 Set @Zrodlo = 39 Else Set @Zrodlo = 40
      Set @ZrodloId = @DeEId
      Set @DokNumer = @DeENumer
     End
    Else If @Zrodlo = 1
     Select @ZrodloId = TrN_TrNId, @DokNumer = Case When TrN_NumerObcy<>'' Then TrN_NumerObcy Else TrN_NumerPelny End From CDN.TraNag Where TrN_DekId = @DeNId
    Else If @Zrodlo = 2
     Select @ZrodloId = VaN_VaNId, @DokNumer = VaN_Dokument From CDN.VatNag Where VaN_DekId = @DeNId
    Else If @Zrodlo = 6
     Select @ZrodloId = DkN_DkNId, @DokNumer = CDN.DeklNumer(DkN_DkNId) From CDN.DeklNag Where DkN_DekId = @DeNId
    Else If @Zrodlo = 11
     Select @ZrodloId = NON_NONId, @DokNumer = NON_NumerPelny From CDN.NotyOdsNag Where NON_DekId = @DeNId
    Else If @Zrodlo = 12
     Select @ZrodloId = EDN_EDNId, @DokNumer = Case When EDN_NumerObcy <> '' Then EDN_NumerObcy Else EDN_NumerPelny End From CDN.EwidDodNag Where EDN_DekId = @DeNId
    Else If @Zrodlo = 10
     Begin
      -- "Przesiadka" z LPL na WPL
      Select Top 1 @ZrodloId = WPL_WPLId, @DokNumer = WPL_NumerPelny
       From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId Join CDN.BnkZdarzenia On BZd_DOkumentTyp = 8 And BZd_DOkumentId = WPL_WPLId
       Where LPL_DekId = @DeNId
       Group By WPL_WPLId, WPL_NumerPelny, WPL_PraId
       Having Abs(@KwotaDek) = Abs(Sum (BZd_KwotaSys*BZd_Kierunek))
       Order By Case When @DeENumer = WPL_NumerPelny Then 0 Else 1 End,
       Case When 3 = @PodmiotTyp And WPL_PraId = @PodmiotId Then 0 Else 1 End
      Set @Zrodlo = 8
     End
    Select @KwotaDok    = IsNull(Sum(BZd_Kierunek*BZd_KwotaSys), 0),
     @KwotaDokWal = IsNull(Sum(BZd_Kierunek*BZd_Kwota)   , 0)
     From CDN.BnkZdarzenia
     Where BZd_BZdId In (Select BZd_BZdId From CDN.fnBnkZdarzenia (@Zrodlo, @ZrodloId))
    If @AccWaluta = '' Set @KwotaDokWal = @KwotaDok
-- Sprawdzenie, czy suma płatności na dokumencie jest równa sumie księgowań na konto słownikowe
    If Not (Abs (@KwotaDok) = Abs(@KwotaDek) And Abs (@KwotaDokWal) = Abs(@KwotaDekWal) )
     Begin
      Set @KwotaWn    = 0
      Set @KwotaMa    = 0
      Set @KwotaWnWal = 0
      Set @KwotaMaWal = 0
      If @Strona = 1
       Begin
       Set @KwotaWn    = @Kierunek * Abs (@KwotaDek)
       Set @KwotaWnWal = @Kierunek * Abs (@KwotaDekWal)
       End
      Else
       Begin
       Set @KwotaMa    = @Kierunek * Abs (@KwotaDek)
       Set @KwotaMaWal = @Kierunek * Abs (@KwotaDekWal)
       End
      If @KwotaDok = 0 And @KwotaDokWal = 0
       exec CDN.KontrolaSaldaInfo 2, 'W', 'Dokument źródłowy nie posiada płatności.', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, @DokNumer, @Zrodlo, @ZrodloId
      Else
       exec CDN.KontrolaSaldaInfo 2, 'W', 'Nie ustalono powiązania kwoty dekretu z dokumentem źródłowym', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, @DokNumer, @Zrodlo, @ZrodloId
      Continue
     End
-- Obliczenie kwoty rozliczonej
    Select
     @KwotaRoz    = IsNull(Sum(Case When 1 = BRK_LDokTyp And BZd_BZdId = BRK_LDokID Then BRK_KwotaSysL Else BRK_KwotaSysP End), 0),
     @KwotaRozWal = IsNull(Sum(BRK_Kwota), 0)
     From CDN.BnkZdarzenia
     Join CDN.BnkRozRelacje On 1 = BRR_ZDokTyp And BZd_BZdId = BRR_ZDokId
     Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
     Where BZd_BZdId In (Select BZd_BZdId From CDN.fnBnkZdarzenia (@Zrodlo, @ZrodloId))
    If @AccWaluta = '' Set @KwotaRozWal = @KwotaRoz
    If Not (Abs(@KwotaDok) = Abs (@KwotaRoz) And Abs(@KwotaDokWal) = Abs (@KwotaRozWal))
     Begin
      Set @KwotaWn    = 0
      Set @KwotaMa    = 0
      Set @KwotaWnWal = 0
      Set @KwotaMaWal = 0
      If @Strona = 1
       Begin
       Set @KwotaWn    = @Kierunek * (Abs (@KwotaDok)    - Abs (@KwotaRoz))
       Set @KwotaWnWal = @Kierunek * (Abs (@KwotaDokWal) - Abs (@KwotaRozWal))
       End
      Else
       Begin
       Set @KwotaMa    = @Kierunek * (Abs (@KwotaDok)    - Abs (@KwotaRoz))
       Set @KwotaMaWal = @Kierunek * (Abs (@KwotaDokWal) - Abs (@KwotaRozWal))
       End
      -- Dla zdarzeń podpiętych pod dekrety trzeba zrobić "przesiadkę"
      If @Zrodlo Not In (27,28,39,40)
       Begin
       exec CDN.KontrolaSaldaInfo 2, 'W', 'Dokument nierozliczony', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, @DokNumer, @Zrodlo, @ZrodloId
       End
      Else
       Begin
       Select Top 1 @BZdId=BZd_BZdId From CDN.BnkZdarzenia Where BZd_BZdId In (Select BZd_BZdId From CDN.fnBnkZdarzenia (@Zrodlo, @ZrodloId)) And BZd_Rozliczono<2
       exec CDN.KontrolaSaldaInfo 2, 'W', 'Dokument nierozliczony', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, @DokNumer, -2, @BZdId
       End
     End
-- Przeglądanie rozliczeń dokumentu źródłowego
    Declare Rozliczenia Cursor Local Fast_Forward For
     Select Sum(BRK_KwotaSysP), Sum(BRK_Kwota), BRR_DDokTyp, BRR_DDokId From
     CDN.BnkZdarzenia
     Join CDN.BnkRozRelacje On 1 = BRR_ZDokTyp And BZd_BZdId = BRR_ZDokId
     Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
     Where BZd_BZdId In (Select BZd_BZdId From CDN.fnBnkZdarzenia (@Zrodlo, @ZrodloId))
     Group By BRR_DDokTyp, BRR_DDokId
    Open Rozliczenia
    While 1 = 1
     Begin
      Fetch Next From Rozliczenia InTo @BRKKwota, @BRKKwotaWal, @BRRDDokTyp, @BRRDDokId
      If @@Fetch_Status <> 0 Break
      Set @BRKKwota    = @Kierunek * @BRKKwota
      If @AccWaluta = ''
       Set @BRKKwotaWal = @BRKKwota
      Else
       Set @BRKKwotaWal = @Kierunek * @BRKKwotaWal
      If @BRRDDokTyp = 1 -- zdarzenie
       Execute CDN.KontrolaSaldaBZd @AccId, @BRKKwota, @BRKKwotaWal, @BRRDDokId, @Strona, @DeNId, @DeNNumer
      Else
       Execute CDN.KontrolaSaldaBZp @AccId, @BRKKwota, @BRKKwotaWal, @BRRDDokId, @Strona, @DeNId, @DeNNumer
     End  -- Koniec pętli wewnętrznego kursora
    Close Rozliczenia
    Deallocate Rozliczenia
-- Przeglądanie różnic kursowych
    Declare Roznice Cursor Local Fast_Forward For
     Select Case When 1 = BRK_LDokTyp And BZd_BZdId = BRK_LDokID Then -BRK_RoznicaKursowaSys Else 0 End, BRK_BRKId
     From CDN.BnkZdarzenia
     Join CDN.BnkRozRelacje On 1 = BRR_ZDokTyp And BZd_BZdId = BRR_ZDokId
     Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
     Where BZd_BZdId In (Select BZd_BZdId From CDN.fnBnkZdarzenia (@Zrodlo, @ZrodloId))
    Open Roznice
    While 1 = 1
     Begin
      Fetch Next From Roznice InTo @BRKKwota, @BRRDDokId
      If @@Fetch_Status <> 0 Break
      If @BRKKwota <> 0
       Execute CDN.KontrolaSaldaBRK @AccId, @BRKKwota, @BRRDDokId, @Strona, @DeNId, @DeNNumer
     End  -- Koniec pętli wewnętrznego kursora
    Close Roznice
    Deallocate Roznice
   End -- Koniec źródła (1,2,6,10,11,12)
  Else If @Zrodlo In (9)
   Begin
-- Raport kasowy
-- Odczytanie Id dokumentu źródłowego
    Select @ZrodloId = BRp_BRpId, @DokNumer = BRp_NumerPelny From CDN.BnkRaporty Where BRp_DekId = @DeNId
    Set @BZpId = Null
    Select Top 1 @BZpId = BZp_BZpId, @BZpNumer = Case When BZp_NumerObcy<>'' Then BZp_NumerObcy Else BZp_NumerPelny End
     From CDN.BnkZapisy
     Where BZp_BRpId = @ZrodloId And Abs(BZp_KwotaSys) = Abs(@KwotaDek) And Abs(Case @AccWaluta When '' Then BZp_KwotaSys Else BZp_Kwota End) = Abs(@KwotaDekWal)
     Order By Case When @DeENumer In (BZp_NumerPelny, BZp_NumerObcy) Then 0 Else 1 End,
     Case When BZp_PodmiotTyp = @PodmiotTyp And BZp_PodmiotId = @PodmiotId Then 0 Else 1 End
    If @BZpId Is Null
     Begin
      Set @KwotaWn    = 0
      Set @KwotaMa    = 0
      Set @KwotaWnWal = 0
      Set @KwotaMaWal = 0
      If @Strona = 1
       Begin
       Set @KwotaWn    = @KwotaDek
       Set @KwotaWnWal = @KwotaDekWal
       End
      Else
       Begin
       Set @KwotaMa    = @KwotaDek
       Set @KwotaMaWal = @KwotaDekWal
       End
      Set @TmpOpis = 'Błąd ustalania źrodłowego zapisu kasowego ' + @DeENumer
      exec CDN.KontrolaSaldaInfo 2, 'E', @TmpOpis, @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, @DokNumer, @Zrodlo, @ZrodloId
      Continue
     End
-- Obliczenie kwoty rozliczonej
    Select
     @KwotaRoz = IsNull(Sum(Case When 2 = BRK_LDokTyp And BZp_BZpId = BRK_LDokID Then BRK_KwotaSysL Else BRK_KwotaSysP End),0),
     @KwotaRozWal = IsNull(Sum(BRK_Kwota),0)
     From CDN.BnkZapisy
     Join CDN.BnkRozRelacje On 2 = BRR_ZDokTyp And BZp_BZpId = BRR_ZDokId
     Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
     Where BZp_BZpId = @BZpId
    If @AccWaluta = '' Set @KwotaRozWal = @KwotaRoz
    If Not (Abs(@KwotaDek) = Abs (@KwotaRoz) And Abs(@KwotaDekWal) = Abs (@KwotaRozWal) )
     Begin
      Set @KwotaWn    = 0
      Set @KwotaMa    = 0
      Set @KwotaWnWal = 0
      Set @KwotaMaWal = 0
      If @Strona = 1
       Begin
       Set @KwotaWn    = @Kierunek * (Abs(@KwotaDek) - Abs (@KwotaRoz))
       Set @KwotaWnWal = @Kierunek * (Abs(@KwotaDekWal) - Abs (@KwotaRozWal))
       End
      Else
       Begin
       Set @KwotaMa    = @Kierunek * (Abs(@KwotaDek) - Abs (@KwotaRoz))
       Set @KwotaMaWal = @Kierunek * (Abs(@KwotaDekWal) - Abs (@KwotaRozWal))
       End
      exec CDN.KontrolaSaldaInfo 2, 'W', 'Dokument nierozliczony', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, @BZpNumer, -1, @BZpId
     End
-- Przeglądanie rozliczeń dokumentu źródłowego
    Declare Rozliczenia Cursor Local Fast_Forward For
     Select BRK_KwotaSysP, BRK_Kwota, BRR_DDokTyp, BRR_DDokId From
     CDN.BnkZapisy
     Join CDN.BnkRozRelacje On 2 = BRR_ZDokTyp And BZp_BZpId = BRR_ZDokId
     Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
     Where BZp_BZpId = @BZpId
    Open Rozliczenia
    While 1 = 1
     Begin
      Fetch Next From Rozliczenia InTo @BRKKwota, @BRKKwotaWal, @BRRDDokTyp, @BRRDDokId
      If @@Fetch_Status <> 0 Break
      Set @BRKKwota = @Kierunek * @BRKKwota
      If @AccWaluta = '' Set @BRKKwotaWal = @BRKKwota
      Else   Set @BRKKwotaWal = @Kierunek * @BRKKwotaWal
      If @BRRDDokTyp = 1 -- zdarzenie
       Execute CDN.KontrolaSaldaBZd @AccId, @BRKKwota, @BRKKwotaWal, @BRRDDokId, @Strona, @DeNId, @DeNNumer
      Else
       Execute CDN.KontrolaSaldaBZp @AccId, @BRKKwota, @BRKKwotaWal, @BRRDDokId, @Strona, @DeNId, @DeNNumer
     End  -- Koniec pętli wewnętrznego kursora
    Close Rozliczenia
    Deallocate Rozliczenia
-- Przeglądanie różnic kursowych
    Declare Roznice Cursor Local Fast_Forward For
     Select Case When 2 = BRK_LDokTyp And BZp_BZpId = BRK_LDokID Then BRK_RoznicaKursowaSys Else 0 End, BRK_BRKId
     From CDN.BnkZapisy
     Join CDN.BnkRozRelacje On 2 = BRR_ZDokTyp And BZp_BZpId = BRR_ZDokId
     Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
     Where BZp_BZpId = @BZpId
    Open Roznice
    While 1 = 1
     Begin
      Fetch Next From Roznice InTo @BRKKwota, @BRRDDokId
      If @@Fetch_Status <> 0 Break
      If @BRKKwota <> 0
       Execute CDN.KontrolaSaldaBRK @AccId, @BRKKwota, @BRRDDokId, @Strona, @DeNId, @DeNNumer
     End  -- Koniec pętli wewnętrznego kursora
    Close Roznice
    Deallocate Roznice
   End -- Koniec źródła (9)
  Else If @Zrodlo = 13 -- Księgowania różnic kursowych
   Begin
    Set @KwotaWn    = 0
    Set @KwotaMa    = 0
    Set @KwotaWnWal = 0
    Set @KwotaMaWal = 0
    If @Strona = 1
     Begin
     Set @KwotaWn = @KwotaDek
     Set @KwotaWnWal = @KwotaDekWal
     End
    Else
     Begin
     Set @KwotaMa    = @KwotaDek
     Set @KwotaMaWal = @KwotaDekWal
     End
    If Exists (Select * From CDN.BnkRozKwoty Where BRK_Dek2Id = @DeNId)
     Begin
      Select @BRKId = BRKV_BRKId, @DokNumer = BRKV_Numer1 From CDN.BnkRozKwotyView Where BRKV_Dek2Id = @DeNId
      exec CDN.KontrolaSaldaInfo 2, 'W', 'Księgowanie rozliczenia lub kompensaty', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, @DokNumer, 18, @BRKId
     End
    Else
     Begin
      Set @BRKId = Null
      Select @BRKId = BRK_BRKId, @BRRDDokTyp = BRK_LDokTyp, @BRRDDokId = BRK_LDokId, @BRKKwota = (Case When @KwotaDek<0 Then -1 Else 1 End) * Abs(BRK_RoznicaKursowaSys) From CDN.BnkRozKwoty Where BRK_DekId = @DeNId And Abs(BRK_RoznicaKursowaSys)=Abs(@KwotaDek)
      If @AccWaluta = '' Set @BRKKwotaWal = @BRKKwota
      Else   Set @BRKKwotaWal    = 0
      If @BRKId Is Null
       exec CDN.KontrolaSaldaInfo 2, 'W', 'Błąd ustalania różnicy kursowej', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, '', null, null
      Else
       If @BRRDDokTyp = 1 -- zdarzenie
        Execute CDN.KontrolaSaldaBZd @AccId, @BRKKwota, @BRKKwotaWal, @BRRDDokId, @Strona, @DeNId, @DeNNumer
       Else
        Execute CDN.KontrolaSaldaBZp @AccId, @BRKKwota, @BRKKwotaWal, @BRRDDokId, @Strona, @DeNId, @DeNNumer
     End
   End -- Koniec księgowań różnic kursowych
  Else If @Zrodlo = 50 -- Księgowania różnic kursowych
   Begin
    Set @KwotaWn    = 0
    Set @KwotaMa    = 0
    Set @KwotaWnWal = 0
    Set @KwotaMaWal = 0
    If @Strona = 1
     Begin
     Set @KwotaWn    = @KwotaDek
     Set @KwotaWnWal = @KwotaDekWal
     End
    Else
     Begin
     Set @KwotaMa    = @KwotaDek
     Set @KwotaMaWal = @KwotaDekWal
     End
     exec CDN.KontrolaSaldaInfo 2, 'W', 'Księgowanie dokumentu kompensaty', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, '', null, null
   End -- Koniec księgowań "z ręki"
  Else -- Księgowania "z ręki" bez płatności
   Begin
    Set @KwotaWn    = 0
    Set @KwotaMa    = 0
    Set @KwotaWnWal = 0
    Set @KwotaMaWal = 0
    If @Strona = 1
     Begin
     Set @KwotaWn    = @KwotaDek
     Set @KwotaWnWal = @KwotaDekWal
     End
    Else
     Begin
     Set @KwotaMa    = @KwotaDek
     Set @KwotaMaWal = @KwotaDekWal
     End
    If @Zrodlo = -4
     exec CDN.KontrolaSaldaInfo 2, 'W', 'Bilans otwarcia (bez płatności)', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, '', null, null
    Else If Exists (Select * From CDN.DekretyNag Where DeN_DeNId = @DeNId And DeN_WzorzecTyp = 22)
     exec CDN.KontrolaSaldaInfo 2, 'W', 'Księgowanie okresowe', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, '', null, null
    Else If Exists (Select * From CDN.DekretyNag Where DeN_DeNId = @DeNId And DeN_Zrodlo in (41,42))
     exec CDN.KontrolaSaldaInfo 2, 'W', 'Dekret pochodzący z przeszacowania walut', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, '', null, null
    Else
     exec CDN.KontrolaSaldaInfo 2, 'W', 'Księgowanie ręczne', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, @DeNNumer, @DeNId, '', null, null
   End -- Koniec księgowań "z ręki"
 End -- Koniec pętli zewnętrznego kursora
Close Ksiegowania
Deallocate Ksiegowania
Set @KwotaWn    = 0
Set @KwotaMa    = 0
Set @KwotaWnWal = 0
Set @KwotaMaWal = 0
If Exists (Select * From #Dokumenty Where Poziom = 2)
 Begin
  Select @KwotaWn = Sum(KwotaWn), @KwotaMa = Sum(KwotaMa), @KwotaWnWal = Sum(KwotaWnWal), @KwotaMaWal = Sum(KwotaMaWal)  From #Dokumenty Where Poziom = 2
  If @KwotaWn > @KwotaMa
   Begin
    Set @KwotaWn = @KwotaWn - @KwotaMa
    Set @KwotaMa = 0
   End
  Else
   Begin
    Set @KwotaMa = @KwotaMa - @KwotaWn
    Set @KwotaWn = 0
   End
  If @KwotaWnWal > @KwotaMaWal
   Begin
    Set @KwotaWnWal = @KwotaWnWal - @KwotaMaWal
    Set @KwotaMaWal = 0
   End
  Else
   Begin
    Set @KwotaMaWal = @KwotaMaWal - @KwotaWnWal
    Set @KwotaWnWal = 0
   End
 End
If Not ((@KwotaTotWn - @KwotaTotMa) - (@KwotaWn - @KwotaMa) = 0 And (@KwotaTotWnWal - @KwotaTotMaWal) - (@KwotaWnWal - @KwotaMaWal) = 0)
 Begin
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Saldo konta wynikające z dokumentów nierozliczonych', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, '', null, '', null, null
  If (@KwotaTotWn - @KwotaTotMa) - (@KwotaWn - @KwotaMa) > 0
   Begin
    Set @KwotaMa = (@KwotaTotMa - @KwotaTotWn) - (@KwotaMa - @KwotaWn)
    Set @KwotaWn = 0
   End
  Else
   Begin
    Set @KwotaWn = (@KwotaTotWn - @KwotaTotMa) - (@KwotaWn - @KwotaMa)
    Set @KwotaMa = 0
   End
  If (@KwotaTotWnWal - @KwotaTotMaWal) - (@KwotaWnWal - @KwotaMaWal) > 0
   Begin
    Set @KwotaMaWal = (@KwotaTotMaWal - @KwotaTotWnWal) - (@KwotaMaWal - @KwotaWnWal)
    Set @KwotaWnWal = 0
   End
  Else
   Begin
    Set @KwotaWnWal = (@KwotaTotWnWal - @KwotaTotMaWal) - (@KwotaWnWal - @KwotaMaWal)
    Set @KwotaMaWal = 0
   End
  exec CDN.KontrolaSaldaInfo 2, 'E', 'Saldo konta niezgodne z saldem nierozliczonych', @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @AccWaluta, '', null, '', null, null
 End
Set NoCount Off
If @Poziom = 1
Or @Poziom = 2 And Exists (Select * From #Dokumenty Where Poziom = 1 And Status <> 'I')
Or @Poziom = 3 And Exists (Select * From #Dokumenty Where Poziom = 1 And Status = 'E')
  Select * From #Dokumenty
Else
  Select * From #Dokumenty Where 1=0
End
