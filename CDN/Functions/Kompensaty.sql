CREATE  Function CDN.Kompensaty (@OperatorId Int, @PodmiotTyp SmallInt, @PodmiotId Int, @DataOd Int, @DataDo Int, @DataRealOd Int, @DataRealDo Int, @Waluta NVARCHAR(15), @Filtr NVARCHAR(254))
Returns @Table Table (
ZakazRach1 SmallInt, NumerPelny1 NVARCHAR(30), NumerObcy1 NVARCHAR(256), Opis1 NVARCHAR(254), Termin1 DateTime, DataReal1 DateTime, Kwota1 Decimal(15,2), Waluta1 NVARCHAR(3),
PodmiotTyp1 SmallInt, PodmiotKod1 NVARCHAR(20), Podmiot1Nazwa1 NVARCHAR(50), Podmiot2Nazwa1 NVARCHAR(50), Podmiot3Nazwa1 NVARCHAR(50), Kategoria1 NVARCHAR(20),
ZakazRach2 SmallInt, NumerPelny2 NVARCHAR(30), NumerObcy2 NVARCHAR(256), Opis2 NVARCHAR(254), Termin2 DateTime, DataReal2 DateTime, Kwota2 Decimal(15,2), Waluta2 NVARCHAR(3),
PodmiotTyp2 SmallInt, PodmiotKod2 NVARCHAR(20), Podmiot1Nazwa2 NVARCHAR(50), Podmiot2Nazwa2 NVARCHAR(50), Podmiot3Nazwa2 NVARCHAR(50), Kategoria2 NVARCHAR(20),
KwotaKompensaty Decimal(15,2), DataKompensaty DateTime)
As
Begin
--wypełnienie tablicy danymi
Insert Into @Table (
ZakazRach1, NumerPelny1, NumerObcy1, Opis1, Termin1, DataReal1, Kwota1, Waluta1, PodmiotTyp1, PodmiotKod1, Podmiot1Nazwa1, Podmiot2Nazwa1, Podmiot3Nazwa1, Kategoria1,
ZakazRach2, NumerPelny2, NumerObcy2, Opis2, Termin2, DataReal2, Kwota2, Waluta2, PodmiotTyp2, PodmiotKod2, Podmiot1Nazwa2, Podmiot2Nazwa2, Podmiot3Nazwa2, Kategoria2,
KwotaKompensaty, DataKompensaty)
Select (Select CDN.ZakazDoRachunkuPlus(B.BZd_BRaId, @OperatorId, Case When BRK_LDokTyp = 1 Then 3 Else 4 End,2)), B.BZd_NumerPelny, B.BZd_NumerObcy, B.BZd_Opis,
B.BZd_Termin, B.BZd_DataReal, B.BZd_Kwota, IsNull(B.BZd_Waluta,''), B.BZd_PodmiotTyp, PB.Pod_Kod, PB.Pod_Nazwa1, PB.Pod_Nazwa2, PB.Pod_Nazwa3, IsNull(KB.Kat_KodSzczegol, ''),
(Select CDN.ZakazDoRachunkuplus(A.BZd_BRaId, @OperatorId, Case When BRK_PDokTyp = 1 Then 3 Else 4 End,2)) As Zakaz, A.BZd_NumerPelny, A.BZd_NumerObcy, A.BZd_Opis,
A.BZd_Termin, A.BZd_DataReal, A.BZd_Kwota, IsNull(A.BZd_Waluta,''), A.BZd_PodmiotTyp, PA.Pod_Kod, PA.Pod_Nazwa1, PA.Pod_Nazwa2, PA.Pod_Nazwa3, IsNull(KA.Kat_KodSzczegol, ''),
BRK_Kwota, BRK_DataDok
From CDN.BnkRozKwoty
Right Outer Join CDN.BnkZdarzenia As A On BRK_LDokID = A.BZd_BZdID
Join CDN.PodmiotyView As PA On PA.Pod_PodmiotTyp = A.BZd_PodmiotTyp And PA.Pod_PodId = A.BZd_PodmiotId
Left Outer Join CDN.Kategorie As KA On KA.Kat_KatId = A.BZd_KatId
Right Outer Join CDN.BnkZdarzenia As B On BRK_PDokID = B.BZd_BZdID
Join CDN.PodmiotyView As PB On PB.Pod_PodmiotTyp = B.BZd_PodmiotTyp And PB.Pod_PodId = B.BZd_PodmiotId
Left Outer Join CDN.Kategorie As KB On KB.Kat_KatId = B.BZd_KatId
Where (BRK_LDokTyp = BRK_PDokTyp And BRK_LDokTyp <> 2 And BRK_PDokTyp <> 2)
And BRK_DataDok >= Convert(DateTime,@DataOd,120) And BRK_DataDok <= Convert(DateTime,@DataDo,120)
And (BRK_LPodTyp = @PodmiotTyp And PA.Pod_GlId = @PodmiotId Or BRK_PPodTyp = @PodmiotTyp And PB.Pod_GlId = @PodmiotId)
Order By BRK_DataDok
--filtr na walutę
Set @Waluta = (Select Case When @Waluta = 'PLN' Then '' Else @Waluta End)
If @Waluta <> '-wszystkie-'
Delete From @Table Where Waluta1<> @Waluta Or Waluta2 <> @Waluta
--filtr na datę realizacji
If @DataRealOd <> 0 And @DataRealDo <> 0
Delete From @Table Where
(DataReal1 Not Between Convert(DateTime,@DataRealOd,120) And Convert(DateTime,@DataRealDo,120)) And
(DataReal2 Not Between Convert(DateTime,@DataRealOd,120) And Convert(DateTime,@DataRealDo,120))
--filtr na filtr prosty
If @Filtr <> ''
Delete From @Table Where
NumerPelny1 Not Like '%' + @Filtr + '%' And NumerPelny2 Not Like '%' + @Filtr + '%'
And NumerObcy1 Not Like '%' + @Filtr + '%' And NumerObcy2 Not Like '%' + @Filtr + '%'
And Opis1 Not Like '%' + @Filtr + '%' And Opis2 Not Like '%' + @Filtr + '%' And
Kategoria1 Not Like '%' + @Filtr + '%' And Kategoria2 Not Like '%' + @Filtr + '%' And
(PodmiotKod1 Not Like '%' + @Filtr + '%' And PodmiotKod2 Not Like '%' + @Filtr + '%') And
(Podmiot1Nazwa1 Not Like '%' + @Filtr + '%' And Podmiot1Nazwa2 Not Like '%' + @Filtr + '%') And
(Podmiot2Nazwa1 Not Like '%' + @Filtr + '%' And Podmiot2Nazwa2 Not Like '%' + @Filtr + '%') And
(Podmiot3Nazwa1 Not Like '%' + @Filtr + '%' And Podmiot3Nazwa2 Not Like '%' + @Filtr + '%')
Return
End
