CREATE FUNCTION CDN.BR_PodatkiDoZaplaty(@Rok Char(4), @Mies Char(2), @OperatorId Int)
RETURNS @Deklaracje Table (DkNId Int, Typ Char(30), PraId Int, Status Char(20), KwotaZap Dec(15,2), KwotaZwr Dec(15,2), US Char(50), OpeId Int)
As
Begin
Declare @RodzajKsi NVARCHAR(1)
Declare @OObEnd NVARCHAR(6)
Declare @MaxDeklNumer Int
Declare @ZaliczkiCit Int
Set @RodzajKsi = (Select Cast(Fir_Wartosc As Char(1)) From CDN.Firma Where Fir_Numer = 1204)
Set @OObEnd = (Select Convert(Char(4),Year(OOb_DataKoncowa)) + Case When Month(OOb_DataKoncowa) Between 1 And 9 Then '0' + Convert(Char(2),Month(OOb_DataKoncowa)) Else Convert(Char(2),Month(OOb_DataKoncowa)) End
               From CDN.OkresyObrach Where Convert(DateTime,@Rok+@Mies+'01') Between OOb_DataOtw And OOb_DataKoncowa)
Set @ZaliczkiCit = (Select OOb_ZaliczkiUproszczone From CDN.OkresyObrach Where Convert(DateTime,@Rok+@Mies+'01') Between OOb_DataOtw And OOb_DataKoncowa)
/*VAT-7*/
If Exists(Select * From CDN.Firma Where Fir_Numer = 1771 And Fir_Wartosc = '1')
 If (CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Rozliczanie VAT kwartalnie', @Rok, @Mies) <> '1' Or @Mies In(3,6,9,12))
    And Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 1 And DkN_RokMiesiac = @Rok + @Mies)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Values (0, case when (@Rok<2020 or (@Rok=2020 and @Mies<7)) then 'Deklaracja VAT-7' else 'JPK_V7' end, 0, 'Brak', 0, 0, 'Brak', 0)
 Else
  Insert Into @Deklaracje (DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, case when (@Rok<2020 or (@Rok=2020 and @Mies<7)) then 'Deklaracja VAT-7' else 'JPK_V7' end, 0, Case DkN_Numer When 0 Then '' Else 'Korekta/' End + Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
  Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then ABS(DkN_Kwota) Else 0 End,
  CDN.GetTextDekl(DkN_DkNId, 1102), DkN_OpeModId
  From CDN.DeklNag
  Where DkN_TypDeklar = 1 And DkN_RokMiesiac = @Rok+@Mies And DkN_Finalna = 1
/*PIT-4R*/
If Exists (Select * From CDN.Firma Where Fir_Numer = 1768 And Fir_Wartosc = '1')
 If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 3 And DkN_RokMiesiac = @Rok + @Mies)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US,OpeId)
  Values (0, Case When @Mies = 12 Then 'Deklaracja PIT-4R' Else 'Zaliczka PIT-4R' End, 0, 'Brak', 0, 0, 'Brak', 0)
 Else
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, Case When DkN_Wersja < 18 Then 'Deklaracja PIT-4' Else Case When @Mies = 12 Then 'Deklaracja PIT-4R' Else 'Zaliczka PIT-4R' End End, 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
  DkN_Kwota, 0, CDN.GetTextDekl(DkN_DkNId,1102), DkN_OpeModId
  From CDN.DeklNag
  Where DkN_TypDeklar = 3 And DkN_RokMiesiac = @Rok+@Mies
/*PIT-8AR*/
If Exists (Select * From CDN.Firma Where Fir_Numer = 1770 And Fir_Wartosc = '1')
 If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 6 And DkN_RokMiesiac = @Rok + @Mies)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Values (0, Case When @Mies = 12 Then 'Deklaracja PIT-8AR' Else 'Zaliczka PIT-8AR' End, 0, 'Brak', 0, 0, 'Brak', 0)
 Else
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, Case When DkN_RokMiesiac < '200701' Then 'Deklaracja PIT-8A' Else Case When @Mies = 12 Then 'Deklaracja PIT-8AR' Else 'Zaliczka PIT-8AR' End End, 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
  DkN_Kwota, 0, CDN.GetTextDekl(DkN_DkNId, 150006), DkN_OpeModId
  From CDN.DeklNag
  Where DkN_TypDeklar = 6 And DkN_RokMiesiac = @Rok+@Mies
/*CIT-2 Zaliczka CIT-8*/
If Exists (Select * From CDN.Firma Where Fir_Numer = 1769 And Fir_Wartosc = '1')
 If @RodzajKsi = 3 and @ZaliczkiCit=0
  Begin
     If CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Zaliczki na podatek dochodowy', @Rok, @Mies) = '1' Or
        (CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Zaliczki na podatek dochodowy', @Rok, @Mies) <> '1' And @Mies In(3,6,9,12))
         If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 8 And DkN_RokMiesiac = @Rok + @Mies) and @Rok+@Mies <> @OObEnd
            Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
            Values (0, 'Zaliczka CIT-8', 0, 'Brak', 0, 0, 'Brak', 0)
         Else
            Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
            Select DkN_DkNId, Case When DkN_Wersja < 18 Then 'Deklaracja CIT-2' Else 'Zaliczka CIT-8' End, 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
            Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then Abs(DkN_Kwota) Else 0 End, CDN.GetTextDekl(DkN_DkNId, 2510006), DkN_OpeModId
            From CDN.DeklNag
            Where DkN_Finalna=1 and DkN_TypDeklar = 8 And DkN_RokMiesiac = @Rok + @Mies
  End;
/*Zaliczka uproszczona CIT-8*/
 If @RodzajKsi = 3 and @ZaliczkiCit=1
  Begin
     If CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Zaliczki na podatek dochodowy', @Rok, @Mies) = '1' Or
        (CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Zaliczki na podatek dochodowy', @Rok, @Mies) <> '1' And @Mies In(3,6,9,12))
         If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 40 And DkN_RokMiesiac = @Rok + @Mies) and @Rok+@Mies <> @OObEnd
            Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
            Values (0, 'Zaliczka uproszczona CIT-8', 0, 'Brak', 0, 0, 'Brak', 0)
         Else
            Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
            Select DkN_DkNId, 'Zaliczka uproszczona CIT-8', 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
            Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then Abs(DkN_Kwota) Else 0 End, CDN.GetTextDekl(DkN_DkNId, 2510006), DkN_OpeModId
            From CDN.DeklNag
            Where DkN_Finalna=1 and DkN_TypDeklar = 40 And DkN_RokMiesiac = @Rok + @Mies
  End;
/*CIT-8*/
If Exists (Select * From CDN.Firma Where Fir_Numer = 1769 And Fir_Wartosc = '1')
 If @RodzajKsi = 3
  If @Rok+@Mies = @OObEnd
   Begin
    If CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Zaliczki na podatek dochodowy', @Rok, @Mies) = '1' Or
        (CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Zaliczki na podatek dochodowy', @Rok, @Mies) <> '1' And @Mies In(3,6,9,12))
        If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 17 And DkN_RokMiesiac = @Rok + @Mies And @Rok+@Mies = @OObEnd)
    And Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 8 And DkN_RokMiesiac = @Rok + @Mies)
           Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
           Values (0, 'Deklaracja CIT-8', 0, 'Brak', 0, 0, 'Brak', 0)
        Else If Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 17 And DkN_RokMiesiac = @Rok + @Mies And @Rok+@Mies = @OObEnd)
           Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
           Select DkN_DkNId, 'Deklaracja CIT-8', 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
           Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then Abs(DkN_Kwota) Else 0 End, CDN.GetTextDekl(DkN_DkNId, 250050), DkN_OpeModId
           From CDN.DeklNag
           Where DkN_Finalna=1 and DkN_TypDeklar = 17 And DkN_RokMiesiac = @Rok + @Mies
  End;
/*PIT-36*/
If @RodzajKsi <> 1
 Begin
 If Exists (Select * From CDN.Firma Where Fir_Numer = 1773 And Fir_Wartosc = '1')
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId,
  Case DkN_TypDeklar When 15 Then 'Deklaracja PIT-36' Else Case When DkN_TypDeklar = 41 then 'Zaliczka uproszczona PIT-36' Else Case When DkN_Wersja < 16 Then 'Deklaracja PIT-5' Else (Case when @Mies =12 and DkN_TypDeklar is null then 'Deklaracja PIT-36' else 'Zaliczka PIT-36' End) End End End,
  PrE_PraId,
  Case When DkN_DkNId Is Null Then 'Brak' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
  Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then Abs(DkN_Kwota) Else 0 End, CDN.GetTextDekl(DkN_DkNId,2140),
  DkN_OpeModId
  From CDN.PracEtaty Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar in (15,2,41) And DkN_Finalna=1 And DkN_RokMiesiac = @Rok + @Mies
  Where PRE_TypPracownika = 1 And PRE_DataDo = Convert(DateTime,'2999-12-31',120) And (CDN.KwotyWspolnika(PRE_PRAId, 21705, Convert(Int,@Rok), Convert(Int, @Mies)) <> 1
  And CDN.KwotyWspolnika(PRE_PRAId, 29001, Convert(Int, @Rok), Convert(Int, @Mies)) Not In ('','0.00')
  Or CDN.KwotyWspolnika(PRE_PRAId, 33501, Convert(Int, @Rok), Convert(Int, @Mies)) Not In ('','0.00')
  Or CDN.KwotyWspolnika(PRE_PRAId, 31001, Convert(Int, @Rok), Convert(Int, @Mies)) Not In ('','0.00'))
  And ((CDN.KwotyWspolnika(PRE_PRAId, 45205, Convert(Int, @Rok), Convert(Int, @Mies)) Not In ('','0.00','0') And @Mies In(3,6,9,12))
  Or (CDN.KwotyWspolnika(PRE_PRAId, 45205, Convert(Int, @Rok), Convert(Int, @Mies)) In ('','0.00','0') And @Mies In(1,2,3,4,5,6,7,8,9,10,11,12)))
/*PIT-36L*/
 If Exists (Select * From CDN.Firma Where Fir_Numer = 1774 And Fir_Wartosc = '1')
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, Case DkN_TypDeklar When 16 Then 'Deklaracja PIT-36L' Else Case When DkN_TypDeklar = 42 then 'Zaliczka uproszczona PIT-36L' Else Case When DkN_Wersja < 4 Then 'Deklaracja PIT-5L' Else (Case when @Mies =12 and DkN_TypDeklar is null then 'Deklaracja PIT-36L' else 'Zaliczka PIT-36L' End) End End End, PrE_PraId,
  Case When DkN_DkNId Is Null Then 'Brak' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
  Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then Abs(DkN_Kwota) Else 0 End, CDN.GetTextDekl(DkN_DkNId, 2140),
  DkN_OpeModId
  From CDN.PracEtaty Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar in (12,16,42) And DkN_Finalna=1 And DkN_RokMiesiac = @Rok + @Mies
  Where PRE_TypPracownika = 1 And PRE_DataDo = Convert(DateTime,'2999-12-31',120) And CDN.KwotyWspolnika(PRE_PRAId, 21705, Convert(Int, @Rok), Convert(Int, @Mies)) = 1
  And CDN.KwotyWspolnika(PRE_PRAId, 29001, Convert(Int, @Rok), Convert(Int, @Mies)) Not In ('','0.00')
  And ((CDN.KwotyWspolnika(PRE_PRAId, 45205, Convert(Int, @Rok), Convert(Int, @Mies)) Not In ('','0.00','0') And @Mies In(3,6,9,12))
  Or (CDN.KwotyWspolnika(PRE_PRAId, 45205, Convert(Int, @Rok), Convert(Int, @Mies)) In ('','0.00','0') And @Mies In(1,2,3,4,5,6,7,8,9,10,11,12)))
 End
/*ZNPR*/
If @RodzajKsi = 1 And (CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Rozliczanie ryczałt kwartalnie', Convert(Int, @Rok),Convert(Int, @Mies)) <> '1' Or 3 In(3, 6, 9, 12))
  Insert Into @Deklaracje (DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'ZNPR', PrE_PraId, Case When DkN_DkNId Is Null Then 'Brak' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
  DkN_Kwota, 0, CDN.GetTextDekl(DkN_DkNId, 2140), DkN_OpeModId
  From CDN.PracEtaty Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = 4 And DkN_RokMiesiac = @Rok + @Mies
  Where DkN_Finalna=1 and PRE_TypPracownika = 1 And PRE_DataDo = Convert(DateTime,'2999-12-31',120) And CDN.KwotyWspolnika(PRE_PRAId, 43101, Convert(Int,@Rok), Convert(Int, @Mies)) Not In ('','0.00')
/*DRA*/
If Exists (Select * From CDN.Firma Where Fir_Numer = 1775 And Fir_Wartosc = '1')
Begin
 If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies)
  Insert Into @Deklaracje (DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Values (0, 'DRA', 0, 'Brak', 0, 0, 'Nie dotyczy', 0)
 Else
 Begin
 If CAST(@Rok+@Mies AS INT)<201712
  Begin
  /*społeczne*/
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'DRA społeczne', 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End, BZd_Kwota, 0, 'Nie dotyczy', DkN_OpeModId
  From CDN.DeklNag Join CDN.BnkZdarzenia On BZd_DokumentId = DkN_DkNId
  Where DkN_TypDeklar = 120 And DkN_PraId Is Null And DkN_RokMiesiac = @Rok+@Mies And BZd_DokumentTyp = 6 And BZd_PodmiotRachunekLp = 1
  And DkN_Numer = (Select Max(DkN_Numer) From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_PraId Is Null And DkN_RokMiesiac = @Rok+@Mies And BZd_DokumentTyp = 6 And BZd_PodmiotRachunekLp = 1 )
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'DRA społeczne właściciela', PrE_PraId, Case When DkN_DkNId Is Null Then 'Brak' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
  BZd_Kwota, 0, 'Nie dotyczy', DkN_OpeModId
  From CDN.PracEtaty Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies Join CDN.BnkZdarzenia On BZd_DokumentId = DkN_DkNId
  Where PRE_IndywDRA = 1 And PRE_DataDo = Convert(DateTime,'2999-12-31',120) And BZd_DokumentTyp = 6 And BZd_PodmiotRachunekLp = 1
  And DkN_Numer = (Select Max(DkN_Numer) From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies And DkN_PraId = PrE_PraId)
  /*zdrowotne*/
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'DRA zdrowotne', 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End, BZd_Kwota, 0, 'Nie dotyczy', DkN_OpeModId
  From CDN.DeklNag Join CDN.BnkZdarzenia On BZd_DokumentId = DkN_DkNId
  Where DkN_TypDeklar = 120 And DkN_PraId Is Null And DkN_RokMiesiac = @Rok+@Mies And BZd_DokumentTyp = 6 And BZd_PodmiotRachunekLp = 2
  And DkN_Numer = (Select Max(DkN_Numer) From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_PraId Is Null And DkN_RokMiesiac = @Rok+@Mies And BZd_DokumentTyp = 6 And BZd_PodmiotRachunekLp = 2)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'DRA zdrowotne właściciela', PrE_PraId, Case When DkN_DkNId Is Null Then 'Brak' When DkN_Zablokowana=1 Then 'Zatwierdzona' Else 'Bufor' End, BZd_Kwota, 0, 'Nie dotyczy', DkN_OpeModId
  From CDN.PracEtaty Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies Join CDN.BnkZdarzenia On BZd_DokumentId = DkN_DkNId
  Where PRE_IndywDRA = 1 And PRE_DataDo = Convert(DateTime,'2999-12-31',120) And BZd_DokumentTyp = 6  And BZd_PodmiotRachunekLp = 2
  And DkN_Numer = (Select Max(DkN_Numer) From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies And DkN_PraId = PrE_PraId)
   /*FP i FGŚP*/
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'DRA FP i FGŚP', 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End, BZd_Kwota, 0, 'Nie dotyczy', DkN_OpeModId
  From CDN.DeklNag Join CDN.BnkZdarzenia On BZd_DokumentId = DkN_DkNId
  Where DkN_TypDeklar = 120 And DkN_PraId Is Null And DkN_RokMiesiac = @Rok+@Mies And BZd_DokumentTyp = 6 And BZd_PodmiotRachunekLp = 3
  And DkN_Numer = (Select Max(DkN_Numer) From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_PraId Is Null And DkN_RokMiesiac = @Rok+@Mies And BZd_DokumentTyp = 6 And BZd_PodmiotRachunekLp = 3)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'DRA FP i FGŚP właściciela', PrE_PraId, Case When DkN_DkNId Is Null Then 'Brak' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End, BZd_Kwota, 0, 'Nie dotyczy', DkN_OpeModId
  From CDN.PracEtaty Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies Join CDN.BnkZdarzenia On BZd_DokumentId = DkN_DkNId
  Where PRE_IndywDRA = 1 And PRE_DataDo = Convert(DateTime,'2999-12-31',120) And BZd_DokumentTyp=6 And BZd_PodmiotRachunekLp = 3
  And DkN_Numer = (Select Max(DkN_Numer) From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies And DkN_PraId = PrE_PraId)
  End
  Else
  Begin
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'DRA', 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End, BZd_Kwota, 0, 'Nie dotyczy', DkN_OpeModId
  From CDN.DeklNag Join CDN.BnkZdarzenia On BZd_DokumentId = DkN_DkNId
  Where DkN_TypDeklar = 120 And DkN_PraId Is Null And DkN_RokMiesiac = @Rok+@Mies And BZd_DokumentTyp = 6
  And DkN_Numer = (Select Max(DkN_Numer) From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_PraId Is Null And DkN_RokMiesiac = @Rok+@Mies And BZd_DokumentTyp = 6)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'DRA właściciela', PrE_PraId, Case When DkN_DkNId Is Null Then 'Brak' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
  BZd_Kwota, 0, 'Nie dotyczy', DkN_OpeModId
  From CDN.PracEtaty Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies Join CDN.BnkZdarzenia On BZd_DokumentId = DkN_DkNId
  Where PRE_IndywDRA = 1 And PRE_DataDo = Convert(DateTime,'2999-12-31',120) And BZd_DokumentTyp = 6 And DkN_Numer = (Select Max(DkN_Numer) From CDN.DeklNag Where DkN_TypDeklar = 120 And DkN_RokMiesiac = @Rok+@Mies And DkN_PraId = PrE_PraId)
  End
 End
End
/*VAT-9M*/
If Exists(Select * From CDN.Firma Where Fir_Numer = 3000 And Fir_Wartosc = '1')
 If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 404 And DkN_RokMiesiac = @Rok + @Mies)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US,OpeId)
  Values (0, 'Deklaracja VAT-9M', 0, 'Brak', 0, 0, 'Brak', 0)
else
  Insert Into @Deklaracje (DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'Deklaracja VAT-9M', 0, Case DkN_Numer When 0 Then '' Else 'Korekta/' End + Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
  Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then ABS(DkN_Kwota) Else 0 End,
  CDN.GetTextDekl(DkN_DkNId, 1102), DkN_OpeModId
  From CDN.DeklNag
  Where DkN_TypDeklar = 404 And DkN_RokMiesiac = @Rok+@Mies And DkN_Finalna = 1
/*VAT-8*/
If Exists(Select * From CDN.Firma Where Fir_Numer = 3137 And Fir_Wartosc = '1')
 If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 43 And DkN_RokMiesiac = @Rok + @Mies)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US,OpeId)
  Values (0, 'Deklaracja VAT-8', 0, 'Brak', 0, 0, 'Brak', 0)
else
  Insert Into @Deklaracje (DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'Deklaracja VAT-8', 0, Case DkN_Numer When 0 Then '' Else 'Korekta/' End + Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
  Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then ABS(DkN_Kwota) Else 0 End,
  CDN.GetTextDekl(DkN_DkNId, 1102), DkN_OpeModId
  From CDN.DeklNag
  Where DkN_TypDeklar = 43 And DkN_RokMiesiac = @Rok+@Mies And DkN_Finalna = 1
/*PPK*/
 If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 500 And DkN_RokMiesiac = @Rok + @Mies)
  Insert Into @Deklaracje(DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US,OpeId)
  Values (0, 'Deklaracja PPK', 0, 'Brak', 0, 0, 'Brak', 0)
else
  Insert Into @Deklaracje (DkNId, Typ, PraId, Status, KwotaZap, KwotaZwr, US, OpeId)
  Select DkN_DkNId, 'Deklaracja PPK', 0, Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
  Case When DkN_Kwota >= 0 Then DkN_Kwota Else 0 End, Case When DkN_Kwota < 0 Then ABS(DkN_Kwota) Else 0 End,
  'Nie dotyczy' , DkN_OpeModId
  From CDN.DeklNag
  Where DkN_TypDeklar = 500 And DkN_RokMiesiac = @Rok+@Mies And DkN_Finalna = 1
Return
End
