CREATE Function [CDN].[RozrachunkiNaDzien] (@NaDzienInt Int, @DataOdInt Int, @DataDoInt Int, @TerminOdInt Int, @TerminDoInt Int, @KontoOdId Int, @KontoDoId Int, @Bufor SmallInt, @Strona SmallInt, @Waluta NVARCHAR(11), @TypDaty SmallInt, @OObId Int) Returns
@Table Table (Typ SmallInt, Dokument NVARCHAR(256), NrDziennika NVARCHAR(30), Dziennik NVARCHAR(30),NumerDziennika Int,IdOkresuObr Int,IdentKsieg NVARCHAR(50), DataDokumentu DateTime, DataDokInt Int, DataWystawienia DateTime,
TerminPlatnosci DateTime, Zwloka Int, Opis NVARCHAR(50), Bufor SmallInt, NrKsiegi NVARCHAR(30), KontoPrzeciw NVARCHAR(50), Strona SmallInt, KontoNumer NVARCHAR(50),
KontoIdx NVARCHAR(50), KontoNazwa NVARCHAR(120), DeEId Int, BOEId Int, DataOpe DateTime, DataRoz DateTime, Waluta NVARCHAR(3), KwotaDok Decimal(15,2),
KwotaDokWal Decimal(15,2), KwotaRoz Decimal(15,2), KwotaRozWal Decimal(15,2), PozostajeWN Decimal(15,2), PozostajeWN_Wal Decimal(15,2),
 PozostajeMA Decimal(15,2), PozostajeMA_Wal Decimal(15,2), Kierunek SmallInt, PodmiotTyp SmallInt, PodmiotKod NVARCHAR(20), PodmiotNazwa NVARCHAR(352))
As
Begin
Declare @NaDzien DateTime
Declare @DataOd DateTime
Declare @DataDo DateTime
Declare @TerminOd DateTime
Declare @TerminDo DateTime
Declare @KontoOdIdx NVARCHAR(50)
Declare @KontoDoIdx NVARCHAR(50)
Set @NaDzien = Convert(DateTime, @NaDzienInt, 120)
Set @DataOd = Convert(DateTime, @DataOdInt, 120)
Set @DataDo = Convert(DateTime, @DataDoInt, 120)
Set @TerminOd = Convert(DateTime, @TerminOdInt, 120)
Set @TerminDo = Convert(DateTime, @TerminDoInt, 120)
Set @KontoOdIdx = (Select Acc_NumerIdx From CDN.Konta Where Acc_AccId = @KontoOdId)
Set @KontoDoIdx = (Select Acc_NumerIdx From CDN.Konta Where Acc_AccId = @KontoDoId)
Insert Into @Table (Typ, Dokument, NrDziennika, Dziennik, NumerDziennika, IdOkresuObr, IdentKsieg,
DataDokumentu, DataDokInt, DataWystawienia, TerminPlatnosci, Zwloka, Opis, Bufor, NrKsiegi,
KontoPrzeciw, Strona, KontoNumer, KontoIdx, KontoNazwa, DeEId, BOEId, DataOpe, DataRoz, Waluta, KwotaDok, KwotaDokWal, KwotaRoz, KwotaRozWal,
PozostajeWN, PozostajeWN_Wal, PozostajeMA, PozostajeMA_Wal, Kierunek, PodmiotTyp, PodmiotKod, PodmiotNazwa)
Select 1, '', '','',0,0, '', '', 0, DeN_DataWys, '', 0, '', 0, '', '', 0, '', '', '', DeE_DeEId, 0, DeE_DataOpe, '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', ''
From CDN.DekretyElem
Left Outer Join CDN.DekretyNag On DeN_DeNId = DeE_DeNId
Where DeN_Typ = 2 and DeE_Rozrachunki = 1 And DeN_DataDok >= @DataOd And DeN_DataDok <= @DataDo And DeE_Termin >= @TerminOd And DeE_Termin <= @TerminDo
Union All
Select 2, '', '','',0,0, '', '', 0, '', '', 0, '', 0, '', '', 0, '', '', '', 0, BOE_BOEId, BOE_DataDok, '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', ''
From CDN.BOElem
Where BOE_Rozrachunki = 1 And BOE_DataDok >= @DataOd And BOE_DataDok <= @DataDo And BoE_Termin >= @TerminOd And BoE_Termin <= @TerminDo
Update @Table
Set Typ = KRo_Typ, Dokument = KRo_Dokument, NrDziennika = KRo_NrDziennika,Dziennik = KRo_Dziennik,NumerDziennika = KRo_NumerDziennika, IdOkresuObr=KRo_OObId, IdentKsieg = KRo_IdentKsieg,
DataDokumentu = KRo_DataDokumentu,TerminPlatnosci = KRo_TerminPlatnosci, DataDokInt = Convert(Int, KRo_DataDokumentu), Opis = KRo_Opis, Bufor = KRo_Bufor, NrKsiegi = KRo_NrKsiegi,
KontoPrzeciw = IsNull(KRo_KontoPrzeciw,''), Strona = KRo_Strona, KontoNumer = KRo_Konto, KontoIdx = KRo_KontoIdx, KontoNazwa = '',
DataRoz = KRo_DataRoz, Waluta = IsNull(KRo_Waluta,''), KwotaDok = KRo_KwotaDok, KwotaDokWal = KRo_KwotaDokWal, KwotaRoz = 0, KwotaRozWal = 0,
PozostajeWN = 0, PozostajeWN_Wal = 0, PozostajeMA = 0, PozostajeMA_Wal = 0, Kierunek = (Case KRo_Strona When 2 Then -1 Else 1 End), PodmiotTyp = 0,
 PodmiotKod = '', PodmiotNazwa = '',
Zwloka =  (Case @TypDaty When 0 Then 0 Else case when @NaDzien > CDN.fn_GetWorkingDayAfter(KRo_TerminPlatnosci) then DATEDIFF(DAY, CDN.fn_GetWorkingDayAfter(KRo_TerminPlatnosci), @NaDzien) else NULL end End)
From CDN.KsiRozrachunki
Where KRo_Typ = 1 And KRo_DeEId = DeEId
Update @Table
Set Typ = KRo_Typ, Dokument = KRo_Dokument, NrDziennika = KRo_NrDziennika,Dziennik = KRo_Dziennik,NumerDziennika = KRo_NumerDziennika, IdOkresuObr=Kro_OObId,
IdentKsieg = KRo_IdentKsieg, DataDokumentu = KRo_DataDokumentu,
TerminPlatnosci = KRo_TerminPlatnosci, DataDokInt = Convert(Int, KRo_DataDokumentu), Opis = KRo_Opis, Bufor = KRo_Bufor, NrKsiegi = KRo_NrKsiegi,
KontoPrzeciw = IsNull(KRo_KontoPrzeciw,''), Strona = KRo_Strona, KontoNumer = KRo_Konto, KontoIdx = KRo_KontoIdx, KontoNazwa = '',
 DataRoz = KRo_DataRoz, Waluta = IsNull(KRo_Waluta,''), KwotaDok = KRo_KwotaDok, KwotaDokWal = KRo_KwotaDokWal, KwotaRoz = 0, KwotaRozWal = 0,
PozostajeWN = 0, PozostajeWN_Wal = 0, PozostajeMA = 0, PozostajeMA_Wal = 0, Kierunek = (Case KRo_Strona When 2 Then -1 Else 1 End), PodmiotTyp = 0,
PodmiotKod = '', PodmiotNazwa = '',
Zwloka =  (Case @TypDaty When 0 Then 0 Else case when @NaDzien > CDN.fn_GetWorkingDayAfter(KRo_TerminPlatnosci) then DATEDIFF(DAY, CDN.fn_GetWorkingDayAfter(KRo_TerminPlatnosci), @NaDzien) else NULL end End)
From CDN.KsiRozrachunki
Where KRo_Typ = 2 And KRo_BOEId = BOEId
--usuniecie zbednych zapisow
Delete From @Table Where KontoNumer = '' Or Not((KontoIdx Between @KontoOdIdx And @KontoDoIdx Or KontoIdx Like @KontoDoIdx + '.%'))
-- filtr na walute
If @Waluta <> '-wszystkie-'
Delete From @Table Where Waluta <> @Waluta
--filtr na bufor
If @Bufor = 0
Delete From @Table Where Bufor = 1
--uzupelnienie numeru dziennika czastkowego
Update @Table
Set NrDziennika =  RTRIM(Case when Boeid='' then (case when
(select oob_ciaglaNumeracjadc from cdn.OkresyObrach where OOb_OObID=IdOkresuObr) = 0 then Dziennik+ '/' + convert(char(7), DataDokumentu, 111)
+ '/' + convert (char, NumerDziennika) else Dziennik+
'/' + convert (char, NumerDziennika) end) else NrDziennika end)
--uzupelnienie nazw kont
Update @Table
Set KontoNazwa = (Select Top 1 Acc_Nazwa + ' ' + IsNull(Acc_Nazwa2,'') From CDN.Konta Where Acc_NumerIdx = KontoIdx Order By Acc_OObId Desc)
--uzupelnienie danych o podmiocie
Update @Table
Set
PodmiotTyp = Pod_PodmiotTyp,
PodmiotKod = Pod_Kod,
PodmiotNazwa = Pod_Nazwa1 + ' ' + Pod_Nazwa2 + ' ' + Pod_Nazwa3
From CDN.PodmiotyView Left Outer Join CDN.Konta On Acc_SlownikTyp = Pod_PodmiotTyp And Acc_SlownikId = Pod_PodId
Where Acc_NumerIdx = KontoIdx And Acc_OObId = @OObId
--obliczenie kwot rozliczonych dla zapisow ksiegowych
Update @Table
set
kwotaroz=kwota,
KwotaRozWal =kwotawal
From
(select IsNull(Sum(KRo_Kwota),0) as kwota,
IsNull(Sum(KRo_KwotaWal),0) as kwotawal,
KRo_Typ, KRo_DeEId
From CDN.KsiRozrachunki
Where KRo_DataRoz Is Not Null and Kro_typ=1
And Convert(DateTime,KRo_DataRoz,120) <= Convert(DateTime,@NaDzien, 120)
group by KRo_Typ, KRo_DeEId) as agregaty
inner join @Table on KRo_Typ = Typ And  KRo_DeEId = DeEId
Update @Table
set
kwotaroz=kwotaroz+kwota,
KwotaRozWal =KwotaRozWal+kwotawal
From
(select IsNull(Sum(KRo_Kwota),0) as kwota,
IsNull(Sum(KRo_KwotaWal),0) as kwotawal,
KRo_Typ, KRo_BoEId
From CDN.KsiRozrachunki
Where KRo_DataRoz Is Not Null and Kro_typ=2
And Convert(DateTime,KRo_DataRoz,120) <= Convert(DateTime,@NaDzien, 120)
group by KRo_Typ, KRo_BoEId) as agregaty
inner join @Table on KRo_Typ = Typ And  KRo_BoeId = BoEId
Update @Table
Set
PozostajeWN = (Case When Strona = 1 Then IsNull(KwotaDok - KwotaRoz, 0) Else 0 End),
PozostajeWN_Wal = (Case When Strona = 1 Then IsNull(KwotaDokWal - KwotaRozWal, 0) Else 0 End),
PozostajeMA = (Case When Strona = 2 Then IsNull(KwotaDok - KwotaRoz, 0) Else 0 End),
PozostajeMA_Wal = (Case When Strona = 2 Then IsNull(KwotaDokWal - KwotaRozWal, 0) Else 0 End)
--filtr na strone
If @Strona <> 3
   If @Strona = 1
      Delete From @Table Where Strona = 2
   If @Strona = 2
      Delete From @Table Where Strona = 1
--filtr na pozycje zerowe
Delete From @Table Where
(@Waluta = '-wszystkie-' And PozostajeWN = 0 And PozostajeMA = 0)
Or (@Waluta <> '-wszystkie-' And PozostajeWN = 0 And PozostajeMA = 0 And KwotaRoz = KwotaDok)
Return
End
