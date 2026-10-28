CREATE  Function [CDN].[BR_KwotyPitCit] (@Rok Int, @Miesiac TinyInt)
Returns
@Tabela Table (DkNId Int, Typ Char(20), PracId Int, Status Char(20), Przychody Dec(15,2), Koszty Dec(15,2), Dochod Dec(15,2), Strata Dec(15,2))
As
Begin
Declare @RodzajKsi TinyInt
Declare @OObMonthEnd TinyInt
Set @RodzajKsi = (Select Fir_Wartosc From CDN.Firma Where Fir_Numer = 1204)
Set @OObMonthEnd = (Select Month(OOb_DataKoncowa) From CDN.OkresyObrach Join CDN.Firma On Fir_Wartosc = OOb_OObId Where Fir_Numer = 244)
Declare @Przychody Dec(15,2)
Declare @Koszty Dec(15,2)
Declare @Dochod Dec(15,2)
Declare @Strata Dec(15,2)
Declare @DeklId Int
Declare @Kwart TinyInt
Declare @TypDekl Int
If Exists (Select * From CDN.Firma Where Fir_Numer = 1769 And Fir_Wartosc='1') And @RodzajKsi = 3
Begin
   /*deklaracja CIT-8 (roczna)*/
   If @Miesiac = @OObMonthEnd
      Begin
      If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 17 And DkN_RokMiesiac = (100*@Rok+@Miesiac))
   And Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 8 And DkN_RokMiesiac = (100*@Rok+@Miesiac))
         Insert Into @Tabela (DkNId, Typ, PracId, Status, Przychody, Koszty, Dochod, Strata)
         Values (0, 'Deklaracja CIT-8', 0, 'Nie policzona', 0, 0, 0, 0)
      Else
         --obliczenie wartosci
         Set @DeklId = (Select DkN_DkNId From CDN.DeklNag Where DkN_Finalna=1 and DkN_TypDeklar = 17 And DkN_RokMiesiac = (100*@Rok+@Miesiac))
         Set @Przychody = (Select Sum(DkE_WartoscL) From CDN.DeklElem Where DkE_DkNId = @DeklId And (DkE_Numer = 2502601 Or DkE_Numer =250260))
         Set @Koszty =
         case when exists (Select * From CDN.DeklElem join cdn.DeklNag on DkN_DkNID=DkE_DkNID Where DkE_DkNId = @DeklId and DkN_Wersja='21')
         then (Select Sum(DkE_WartoscL) From CDN.DeklElem join cdn.DeklNag on DkN_DkNID=DkE_DkNID Where DkE_DkNId = @DeklId And (DkE_Numer = 250280))
         else (Select Sum(DkE_WartoscL) From CDN.DeklElem join cdn.DeklNag on DkN_DkNID=DkE_DkNID Where DkE_DkNId = @DeklId And (DkE_Numer = 2502801 Or DkE_Numer = 250280))
          end
   Set @Dochod = (Select Sum(DkE_WartoscL) From CDN.DeklElem Where DkE_DkNId = @DeklId And (DkE_Numer = 2503201 Or DkE_Numer =250320))
   Set @Strata = (Select Sum(DkE_WartoscL) From CDN.DeklElem Where DkE_DkNId = @DeklId And (DkE_Numer = 2503301 Or DkE_Numer =250330))
         --wypelnienie tabeli
         Insert Into @Tabela (DkNId, Typ, PracId, Status, Przychody, Koszty, Dochod, Strata)
         Select Distinct
             DkN_DkNId,
             'Deklaracja CIT-8',
             0,
             Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
             @Przychody,
             @Koszty,
             @Dochod,
    @Strata
         From CDN.DeklNag
             Left Outer Join CDN.DeklElem On DkE_DkNId = DkN_DkNId Where DkN_Finalna=1 and DkN_TypDeklar = 17 And DkN_RokMiesiac = (100*@Rok+@Miesiac)
      End
/*deklaracja CIT-2 lub zaliczka CIT-8*/
   If @Miesiac <> @OObMonthEnd Or (@Miesiac = @OObMonthEnd and Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 17 And DkN_RokMiesiac = (100*@Rok+@Miesiac)))
       Begin
       Select @Kwart = CDN.Konfiguracja(2, 'Księgowość\Deklaracje\Zaliczki na podatek dochodowy', @Rok, @Miesiac)
       If @Kwart = 1 Or (@Kwart = 2 And @Miesiac In (3,6,9,12))
          If Not Exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 8 And DkN_RokMiesiac = (100*@Rok+@Miesiac)) and @Miesiac <> @OObMonthEnd
             Insert Into @Tabela (DkNId, Typ, PracId, Status, Przychody, Koszty, Dochod, Strata)
             Values (0, 'Zaliczka CIT-8', 0, 'Nie policzona', 0, 0, 0, 0)
          Else
             --obliczenie wartosci
             Set @DeklId = (Select DkN_DkNId From CDN.DeklNag Where DkN_Finalna=1 and DkN_TypDeklar = 8 And DkN_RokMiesiac = (100*@Rok+@Miesiac))
             Set @Przychody = (Select Sum(DkE_WartoscL) From CDN.DeklElem Where DkE_DkNId = @DeklId And (DkE_Numer = 2514001 Or DkE_Numer = 251400))
             Set @Koszty = (Select Sum(DkE_WartoscL) From CDN.DeklElem Where DkE_DkNId = @DeklId And (DkE_Numer = 2520001 Or DkE_Numer = 252000))
    Set @Dochod = (Select Sum(DkE_WartoscL) From CDN.DeklElem Where DkE_DkNId = @DeklId And (DkE_Numer = 2510271 Or DkE_Numer =251027))
       Set @Strata = (Select Sum(DkE_WartoscL) From CDN.DeklElem Where DkE_DkNId = @DeklId And (DkE_Numer = 2510281 Or DkE_Numer =251028))
             --wypelnienie tabeli
             Insert Into @Tabela (DkNId, Typ, PracId, Status, Przychody, Koszty, Dochod, Strata)
             Select
                   DkN_DkNId,
                   'Zaliczka CIT-8',
                   0,
                   Case DkN_Zablokowana When 1 Then 'Zatwierdzona' Else 'Bufor' End,
                   @Przychody,
                   @Koszty,
          @Dochod,
          @Strata
             From CDN.DeklNag
                   Join CDN.DeklElem On DkE_DkNId = DkN_DkNId Where DkN_Finalna=1 and DkN_TypDeklar = 8 And DkN_RokMiesiac = (100*@Rok+@Miesiac)
       End
END
If @RodzajKsi=2 Or @RodzajKsi = 3
/*deklaracja lub zaliczka do PIT-36*/
   If Exists (Select * From CDN.Firma Where Fir_Numer=1773 And Fir_Wartosc='1')
       Begin
         Set @TypDekl = (Case When @Miesiac = 12 and (exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 15 And DkN_RokMiesiac = (100*@Rok+@Miesiac))
   or not exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 2 And DkN_RokMiesiac = (100*@Rok+@Miesiac)))
   Then 15 Else 2 End)
         --deklaracja PIT-36
  If @TypDekl = 15
         Insert Into @Tabela (DkNId, Typ, PracId, Status, Przychody, Koszty, Dochod, Strata)
         Select DkN_DkNId,
             Case @TypDekl When 15 Then 'Deklaracja PIT-36' Else Case When DkN_Wersja < 16 Then 'Deklaracja PIT-5' Else 'Zaliczka PIT-36' End End,
             PrE_PraId,
             Case When DkN_DkNId Is Null Then 'Nie policzona' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
             --CDN.KwotaKsiegDekl (DkN_DkNId, 21300) As Przychody --stare
             case when DkN_Wersja<13
              then  CDN.KwotaKsiegDekl (DkN_DkNId, 20500) + CDN.KwotaKsiegDekl (DkN_DkNId, 20900)
    else CDN.KwotaKsiegDekl (DkN_DkNId, 20590) End As Przychody,
             --CDN.KwotaKsiegDekl (DkN_DkNId, 21400) As Koszty, --stare
             case when DkN_Wersja<13
              then  CDN.KwotaKsiegDekl (DkN_DkNId, 20600) + CDN.KwotaKsiegDekl (DkN_DkNId, 21000)
    else CDN.KwotaKsiegDekl (DkN_DkNId, 20600) End As Koszty,
             --CDN.KwotaKsiegDekl (DkN_DkNId, 21500) As Dochod,  --stare
             case when DkN_Wersja<13
              then  CDN.KwotaKsiegDekl (DkN_DkNId, 21500)
    else CDN.KwotaKsiegDekl (DkN_DkNId, 20610) End As  Dochod,
             --CDN.KwotaKsiegDekl (DkN_DkNId, 21600) As Strata  --stare
             case when DkN_Wersja<13
              then  CDN.KwotaKsiegDekl (DkN_DkNId, 20800) + CDN.KwotaKsiegDekl (DkN_DkNId, 21200)
    else
     CDN.KwotaKsiegDekl (DkN_DkNId, 20230) +
     CDN.KwotaKsiegDekl (DkN_DkNId, 20310) +
     CDN.KwotaKsiegDekl (DkN_DkNId,20370) +
     CDN.KwotaKsiegDekl (DkN_DkNId, 20420) +
     CDN.KwotaKsiegDekl (DkN_DkNId,20470) +
     CDN.KwotaKsiegDekl (DkN_DkNId,20520) +
     CDN.KwotaKsiegDekl (DkN_DkNId,20570)
             End
             As Strata
         From CDN.PracEtaty
             Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = @TypDekl And DkN_Finalna=1 And DkN_RokMiesiac = 100 * @Rok + @Miesiac
             Join CDN.PracPitMies On PPM_PraId = PRE_PraId
         Where PRE_TypPracownika = 1
             And PRE_DataDo = Convert(DateTime,'2999-12-31',120)
             And PPM_Rok = @Rok
             And PPM_Miesiac = @Miesiac
             And CDN.KwotyWspolnika(PRE_PraId, 21705, @Rok, @Miesiac) <> 1
             And (CDN.KwotyWspolnika(PRE_PraId, 45205, @Rok, @Miesiac) = 0 Or (CDN.KwotyWspolnika(PRE_PraId, 45205, @Rok, @Miesiac) = 1 And @Miesiac In (3,6,9,12) ))
         --zaliczka do PIT-36
   If @TypDekl = 2
         Insert Into @Tabela (DkNId, Typ, PracId, Status, Przychody, Koszty, Dochod, Strata)
         Select DkN_DkNId,
             Case @TypDekl When 15 Then 'Deklaracja PIT-36' Else Case When DkN_Wersja < 16 Then 'Deklaracja PIT-5' Else 'Zaliczka PIT-36' End End,
             PrE_PraId,
             Case When DkN_DkNId Is Null Then 'Nie policzona' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
             CDN.KwotaKsiegDekl (DkN_DkNId, 21300) As Przychody,
             CDN.KwotaKsiegDekl (DkN_DkNId, 21400) As Koszty,
             CDN.KwotaKsiegDekl (DkN_DkNId, 21500) As Dochod,
             CDN.KwotaKsiegDekl (DkN_DkNId, 21600) As Strata
         From CDN.PracEtaty
             Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = @TypDekl And DkN_Finalna=1 And DkN_RokMiesiac = 100 * @Rok + @Miesiac
         Where PRE_TypPracownika = 1
             And PRE_DataDo = Convert(DateTime,'2999-12-31',120)
             And (CDN.KwotaKsiegDekl (DkN_DkNId, 21300) <> 0 Or CDN.KwotaKsiegDekl (DkN_DkNId, 21400) <> 0)
             --And DkN_TypDeklar = @TypDekl
       End
/*deklaracja lub zaliczka do PIT-36L*/
   If Exists (Select * From CDN.Firma Where Fir_Numer=1774 And Fir_Wartosc='1')
       Begin
         Select @TypDekl = Case When @Miesiac = 12 and (exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 16 And DkN_RokMiesiac = (100*@Rok+@Miesiac))
   or not exists (Select * From CDN.DeklNag Where DkN_TypDeklar = 12 And DkN_RokMiesiac = (100*@Rok+@Miesiac))) Then 16 Else 12 End
         --deklaracja PIT-36L
   If @TypDekl = 16
         Insert Into @Tabela (DkNId, Typ, PracId, Status, Przychody, Koszty, Dochod, Strata)
         Select DkN_DkNId,
             Case @TypDekl When 16 Then 'Deklaracja PIT-36L' Else Case When DkN_Wersja < 4 Then 'Deklaracja PIT-5L' Else 'Zaliczka PIT-36L' End End,
             PrE_PraId,
             Case When DkN_DkNId Is Null Then 'Nie policzona' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
             --CDN.KwotaKsiegDekl (DkN_DkNId, 20500) As Przychody,  -stare
             Case when DkN_Wersja<5
              then  CDN.KwotaKsiegDekl (DkN_DkNId, 20500)
    else CDN.KwotaKsiegDekl (DkN_DkNId, 20500)+  CDN.KwotaKsiegDekl (DkN_DkNId, 20030)
             end As Przychody,
             --CDN.KwotaKsiegDekl (DkN_DkNId, 20600) As Koszty, -stare
             Case when DkN_Wersja<5
              then  CDN.KwotaKsiegDekl (DkN_DkNId, 20600)
    else CDN.KwotaKsiegDekl (DkN_DkNId, 20600)+  CDN.KwotaKsiegDekl (DkN_DkNId, 20040)
             end As Koszty,
             --CDN.KwotaKsiegDekl (DkN_DkNId, 20700) As Dochod,  -stare
             case when DkN_Wersja<5
              then  CDN.KwotaKsiegDekl (DkN_DkNId, 20700)
    else CDN.KwotaKsiegDekl (DkN_DkNId, 20700)+  CDN.KwotaKsiegDekl (DkN_DkNId, 20050)
             end As Dochod,
             --CDN.KwotaKsiegDekl (DkN_DkNId, 20800)  -stare
             case when DkN_Wersja<5
              then  CDN.KwotaKsiegDekl (DkN_DkNId, 20800)
    else CDN.KwotaKsiegDekl (DkN_DkNId, 20800)+  CDN.KwotaKsiegDekl (DkN_DkNId, 20060)
             end As Strata
         From CDN.PracEtaty
             Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = @TypDekl And DkN_Finalna=1 And DkN_RokMiesiac = 100 * @Rok + @Miesiac
             Join CDN.PracPitMies On PPM_PraId = PRE_PraId
         Where PRE_TypPracownika = 1
             And PRE_DataDo = Convert(DateTime,'2999-12-31',120)
             And PPM_Rok = @Rok
             And PPM_Miesiac = @Miesiac
             And CDN.KwotyWspolnika (PRE_PraId, 21705, @Rok, @Miesiac) = 1
             And (CDN.KwotyWspolnika(PRE_PraId, 45205, @Rok, @Miesiac) = 0 Or (CDN.KwotyWspolnika(PRE_PraId, 45205, @Rok, @Miesiac) = 1
             And @Miesiac In (3,6,9,12) ))
         --zaliczka do PIT-36L
   If @TypDekl = 12
         Insert Into @Tabela (DkNId, Typ, PracId, Status, Przychody, Koszty, Dochod, Strata)
         Select DkN_DkNId,
             Case @TypDekl When 16 Then 'Deklaracja PIT-36L' Else Case When DkN_Wersja < 4 Then 'Deklaracja PIT-5L' Else 'Zaliczka PIT-36L' End End,
             PrE_PraId,
             Case When DkN_DkNId Is Null Then 'Nie policzona' When DkN_Zablokowana = 1 Then 'Zatwierdzona' Else 'Bufor' End,
             CDN.KwotaKsiegDekl (DkN_DkNId, 20500) As Przychody,
             CDN.KwotaKsiegDekl (DkN_DkNId, 20600) As Koszty,
             CDN.KwotaKsiegDekl (DkN_DkNId, 20700) As Dochod,
             CDN.KwotaKsiegDekl (DkN_DkNId, 20800) As Strata
         From CDN.PracEtaty
              Left Outer Join CDN.DeklNag On PrE_PraId = DkN_PraId And DkN_TypDeklar = @TypDekl And DkN_Finalna=1 And DkN_RokMiesiac = 100 * @Rok + @Miesiac
         Where PRE_TypPracownika = 1
              And PRE_DataDo = Convert(DateTime,'2999-12-31',120)
              And (CDN.KwotaKsiegDekl (DkN_DkNId, 20500) <> 0 Or CDN.KwotaKsiegDekl (DkN_DkNId, 20600) <> 0)
       End
Return
End
