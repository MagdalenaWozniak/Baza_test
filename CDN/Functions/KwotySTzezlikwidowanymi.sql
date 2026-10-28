CREATE FUNCTION [CDN].[KwotySTzezlikwidowanymi] (@Ksieg SmallInt, @SrTId Int, @DataWydruku Int, @Historyczny Int)
Returns @Table Table (RecId Int Identity(1,1),
SrTId Int,
SrTNazwa NVARCHAR(256),
SrTKST NVARCHAR(20),
SrTGrupa NVARCHAR(20),
SrTStan Int,
SrTUlgaInwestycyjna Decimal(15,2),
ZwiekszeniaKoszt Decimal(15,2),
ZwiekszeniaBilan Decimal(15,2),
AmortyzacjaBR Decimal(15,2),
UmorzeniaBR Decimal(15,2),
AmortyzacjaBRminus Decimal(15,2),
UmorzeniaBRminus Decimal(15,2),
AmortyzacjaBRL Decimal(15,2),
UmorzeniaBRL Decimal(15,2),
AmortyzacjaUR Decimal(15,2),
UmorzeniaUR Decimal(15,2),
ZwiekszKosztPozaOkres Decimal(15,2),
ZwiekszBilanPozaOkres Decimal(15,2),
ZwiekszWartosciBilan Decimal(15,2),
ZwiekszWartosciKoszt Decimal(15,2),
ZmniejszWartosciBilan Decimal(15,2),
ZmniejszWartosciKoszt Decimal(15,2),
WartoscBilanUR Decimal(15,2),
WartoscKosztUR Decimal(15,2),
DataOd DateTime,
DataDo DateTime,
Miejsce nVarChar(255),
Osoba nVarChar(255)
)
As
Begin
Declare @OkresObrach Int
Declare @RodzajKs NVARCHAR(2)
Declare @PrintDate DateTime
Declare @DataMin DateTime
Declare @DataMax DateTime
Declare @DataOd DateTime
Declare @DataDo DateTime
Declare @X Int
--ustalenie daty pocz1tkowej i koncowej okresu obrachunkowego, do którego nale?y ustalona data wydruku
Set @PrintDate = Convert(DateTime, @DataWydruku, 120)
Set @RodzajKs = (Select Case When @Ksieg = 3 Then 'KH' When @Ksieg = 2 Then 'KP' Else 'RY' End)
If @RodzajKs = 'KH'
   Set @OkresObrach = (Select OOb_OObID From CDN.OkresyObrach Where OOb_DataOtw <= @PrintDate And OOb_DataKoncowa >= @PrintDate)
Else
   Set @OkresObrach = ''
Select @DataMin = Min(OOb_DataOtw), @DataMax= Max(OOb_DataKoncowa) From CDN.OkresyObrach;
If @PrintDate < @DataMin Select @X = 2 Else If @Printdate > @DataMax Select @X = 3 Else If Exists (Select * From CDN.OkresyObrach Where @PrintDate Between OOb_DataOtw And OOb_DataKoncowa) Select @X = 1 Else Select @X =4
If @RodzajKs = 'KH'
  Begin
   If @X = 1
      Set @DataOd = (Select Max(OOb_DataOtw) From CDN.OkresyObrach Where OOb_OObID = @OkresObrach)
      Set @DataDo = (Select Max(OOb_DataKoncowa) From CDN.OkresyObrach Where OOb_OObID = @OkresObrach)
   If @X = 2
      Set @DataOd = (Select Max(OOb_DataOtw) From CDN.OkresyObrach)
      Set @DataDo = (Select Min(OOb_DataKoncowa) From CDN.OkresyObrach)
   If @X = 3
      Set @DataOd = (Select Max(OOb_DataKoncowa)+1 From CDN.OkresyObrach)
      Set @DataDo = Convert(DateTime, '2904-12-31', 120)
   End
Else
   Set @DataOd = Convert(DateTime, Cast(Year(@DataWydruku) As NVARCHAR(4)) + '-1-1',120)
   Set @DataDo = Convert(DateTime, Cast(Year(@DataWydruku) As NVARCHAR(4)) + '-12-31',120)
If @Historyczny = 1 Set @DataDo = @PrintDate
-- ustalenie kwot zwi1zanych ze orodkiem trwa3ym
Declare @Min Int
Declare @Max Int
Declare @KwotaKoszt Decimal(15,2)
Declare @KwotaBilan Decimal(15,2)
Declare @KwotaAmBR Decimal(15,2)
Declare @KwotaUmBR Decimal(15,2)
Declare @KwotaAmBRminus Decimal(15,2)
Declare @KwotaUmBRminus Decimal(15,2)
Declare @KwotaAmBRL Decimal(15,2)
Declare @KwotaUmBRL Decimal(15,2)
Declare @KwotaAmUR Decimal(15,2)
Declare @KwotaUmUR Decimal(15,2)
Declare @KwotaPozaOkresK Decimal(15,2)
Declare @KwotaPozaOkresB Decimal(15,2)
Declare @KwotaZwiekszWartBilan Decimal(15,2)
Declare @KwotaZmniejszWartBilan Decimal(15,2)
Declare @KwotaZwiekszWartKoszt Decimal(15,2)
Declare @KwotaZmniejszWartKoszt Decimal(15,2)
Declare @WartoscBilanUR Decimal(15,2)
Declare @WartoscKosztUR Decimal(15,2)
Declare @Miejsce nVarChar(255)
Declare @Osoba nVarChar(255)
--ustalenie czy orodek trwa3y mo?e braa udzia3 w obliczeniach
Insert Into @Table (SrTId, SrTNazwa, SrTKST, SrTGrupa, SrTStan, SrTUlgaInwestycyjna, DataOd, DataDo)
Select SrT_SrTId, SrT_Nazwa, SrT_KRST, SrT_Grupa,  SrT_Stan, SrT_UlgaInwestyc, @dataOd, @DataDo From CDN.Trwale
Where SrT_SrTId = @SrTId
And (@Historyczny = 0 Or (@Historyczny = 1 And ((@PrintDate >= SrT_DataZak) )))
Set @Min = 1
Select @Max = Max(RecId) From @Table
While 1=1
Begin
Set @KwotaKoszt = 0; Set @KwotaBilan = 0
If @Historyczny = 0
   (Select @KwotaKoszt = Sum(SrH_KwotaKoszt), @KwotaBilan = Sum(SrH_KwotaBilan)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6)
Else
  (Select @KwotaKoszt = Sum(SrH_KwotaKoszt), @KwotaBilan = Sum(SrH_KwotaBilan)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And SrH_DataOpe <= @PrintDate)
Update @Table
Set ZwiekszeniaKoszt = IsNull(@KwotaKoszt,0), ZwiekszeniaBilan = IsNull(@KwotaBilan,0)
Where RecId = @Min
Set @KwotaAmBR = 0; Set @KwotaUmBR = 0; Set @KwotaAmBRminus = 0; Set @KwotaUmBRminus = 0;
If @Historyczny = 0
   Select @KwotaAmBR = Sum(SrH_KwotaAm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd And SrH_DataOpe <= @DataDo) Or SrH_DataOpe = @DataOd) And SrH_TypDokumentu <> 2 and SrH_KwotaAm>0
Else
   Select @KwotaAmBR = Sum(SrH_KwotaAm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd Or SrH_DataOpe = @DataOd And SrH_TypDokumentu <> 2) And SrH_DataOpe <= @DataDo)  and SrH_KwotaAm>0
If @Historyczny = 0
   Select @KwotaUmBR = Sum(SrH_KwotaUm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd And SrH_DataOpe <= @DataDo) Or SrH_DataOpe = @DataOd) And SrH_TypDokumentu <> 2 and SrH_KwotaUm>0
Else
   Select @KwotaUmBR = Sum(SrH_KwotaUm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd Or SrH_DataOpe = @DataOd And SrH_TypDokumentu <> 2) And SrH_DataOpe <= @DataDo)  and SrH_KwotaUm>0
If @Historyczny = 0
   Select @KwotaAmBRminus = Sum(SrH_KwotaAm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd And SrH_DataOpe <= @DataDo) Or SrH_DataOpe = @DataOd) And SrH_TypDokumentu <> 2 and SrH_KwotaAm<0
Else
   Select @KwotaAmBRminus = Sum(SrH_KwotaAm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd Or SrH_DataOpe = @DataOd And SrH_TypDokumentu <> 2) And SrH_DataOpe <= @DataDo)  and SrH_KwotaAm<0
If @Historyczny = 0
   Select @KwotaUmBRminus = Sum(SrH_KwotaUm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd And SrH_DataOpe <= @DataDo) Or SrH_DataOpe = @DataOd) And SrH_TypDokumentu <> 2 and SrH_KwotaUm<0
Else
   Select @KwotaUmBRminus = Sum(SrH_KwotaUm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd Or SrH_DataOpe = @DataOd And SrH_TypDokumentu <> 2) And SrH_DataOpe <= @DataDo)  and SrH_KwotaUm<0
Update @Table
Set AmortyzacjaBR = IsNull(@KwotaAmBR,0), UmorzeniaBR = IsNull(@KwotaUmBR,0),AmortyzacjaBRminus = IsNull(@KwotaAmBRminus,0), UmorzeniaBRminus = IsNull(@KwotaUmBRminus,0) Where RecId = @Min
Set @KwotaAmBRL = 0; Set @KwotaUmBRL = 0
If @Historyczny = 0
   Select @KwotaAmBRL = Sum(SrH_KwotaAm), @KwotaUmBRL = Sum(SrH_KwotaUm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And ((SrH_DataOpe > @DataOd And SrH_DataOpe <= @DataDo) Or SrH_DataOpe = @DataOd And SrH_TypDokumentu <> 2) And SrH_TypDokumentu = 5
Else
   Select @KwotaAmBRL = Sum(SrH_KwotaAm), @KwotaUmBRL = Sum(SrH_KwotaUm)
   From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
   Where RecId = @Min And SrH_TypDokumentu<>6 And (((SrH_DataOpe > @DataOd Or SrH_DataOpe = @DataOd And SrH_TypDokumentu <> 2) And SrH_DataOpe <= @DataDo) And SrH_TypDokumentu = 5)
Update @Table
Set AmortyzacjaBRL = IsNull(@KwotaAmBRL,0), UmorzeniaBRL = IsNull(@KwotaUmBRL,0) Where RecId = @Min
Set @KwotaAmUR = 0; Set @KwotaUmUR = 0
Select @KwotaAmUR = Sum(SrH_KwotaAm), @KwotaUmUR = Sum(SrH_KwotaUm)
From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
Where RecId = @Min And SrH_TypDokumentu<>6 And SrH_DataOpe < @DataOd Or SrH_DataOpe = @DataOd And SrH_TypDokumentu = 2
Update @Table
Set AmortyzacjaUR = IsNull(@KwotaAmUR,0), UmorzeniauR = IsNull(@KwotaUmuR,0) Where RecId = @Min
Set @KwotaPozaOkresK = 0; Set @KwotaPozaOkresB = 0
Select @KwotaPozaOkresK = Sum(SrH_KwotaKoszt), @KwotaPozaOkresB = Sum(SrH_KwotaBilan)
From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
Where RecId = @Min And SrH_TypDokumentu<>6 And SrH_DataOpe > @DataDo
Update @Table
Set ZwiekszKosztPozaOkres = IsNull(@KwotaPozaOkresK,0), ZwiekszBilanPozaOkres = IsNull(@KwotaPozaOkresB,0) Where RecId = @Min
Set @KwotaZwiekszWartBilan = 0
Select @KwotaZwiekszWartBilan = Sum(SrH_KwotaBilan)
From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
Where RecId = @Min And SrH_TypDokumentu<>6 And SrH_DataOpe Between @DataOd And @DataDo And (SrH_TypDokumentu = 1 or (SrH_TypDokumentu = 5)) And SrH_KwotaBilan > 0
Set @KwotaZwiekszWartKoszt = 0
Select @KwotaZwiekszWartKoszt = Sum(SrH_KwotaKoszt)
From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
Where RecId = @Min And SrH_TypDokumentu<>6 And SrH_DataOpe Between @DataOd And @DataDo And (SrH_TypDokumentu = 1 or (SrH_TypDokumentu = 5)) And SrH_KwotaKoszt > 0
Set @KwotaZmniejszWartBilan = 0
Select @KwotaZmniejszWartBilan = Sum(SrH_KwotaBilan)
From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
Where RecId = @Min And SrH_TypDokumentu<>6 And SrH_DataOpe Between @DataOd And @DataDo And (SrH_TypDokumentu = 1 or (SrH_TypDokumentu = 5)) And SrH_KwotaBilan < 0
Set @KwotaZmniejszWartKoszt = 0
Select @KwotaZmniejszWartKoszt = Sum(SrH_KwotaKoszt)
From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
Where RecId = @Min And SrH_TypDokumentu<>6 And SrH_DataOpe Between @DataOd And @DataDo And (SrH_TypDokumentu = 1 or (SrH_TypDokumentu = 5)) And SrH_KwotaKoszt < 0
Update @Table
Set ZwiekszWartosciBilan = IsNull(@KwotaZwiekszWartBilan,0), ZwiekszWartosciKoszt = IsNull(@KwotaZwiekszWartKoszt,0),
ZmniejszWartosciBilan = IsNull(@KwotaZmniejszWartBilan,0), ZmniejszWartosciKoszt = IsNull(@KwotaZmniejszWartKoszt,0)
Where RecId = @Min
Set @WartoscBilanUR = 0
Select @WartoscBilanUR = Sum(SrH_KwotaBilan)
From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
Where RecId = @Min And SrH_TypDokumentu<>6 And
(SrH_DataOpe < @DataOd And (SrH_TypDokumentu = 2 Or SrH_TypDokumentu = 4)) Or (SrH_DataOpe < @DataOd And (SrH_TypDokumentu = 1 or (SrH_TypDokumentu = 5)))
Set @WartoscKosztUR = 0
Select @WartoscKosztUR = Sum(SrH_KwotaKoszt)
From CDN.TrwaleHist Join @Table On SrH_SrTId = SrTId
Where RecId = @Min And SrH_TypDokumentu<>6 And
(SrH_DataOpe < @DataOd And (SrH_TypDokumentu = 2 Or SrH_TypDokumentu = 4)) Or (SrH_DataOpe < @DataOd And (SrH_TypDokumentu = 1 or (SrH_TypDokumentu = 5)))
Update @Table
Set WartoscBilanUR = IsNull(@WartoscBilanUR,0), WartoscKosztUR = IsNull(@WartoscKosztUR,0)
Where RecId = @Min
Select @Miejsce = SrMU_Nazwa
From CDN.TrwaleMiejscaUzytkowania Join @Table On SrMU_SrTID = SrTId
Where RecId = @Min And
((SrMU_SrTID = SrTId And ((@PrintDate Between SrMU_DataOd And SrMU_DataDo) Or (SrMU_DataOd Is Null And @PrintDate <= SrMU_DataDo)) Or
(SrMU_DataDo Is Null And @PrintDate >= SrMU_DataOd)) Or (SrMU_DataOd Is Null And SrMU_DataDo Is Null))
Update @Table
Set Miejsce = IsNull(@Miejsce,'')
Where RecId = @Min
Select @Osoba = SrOO_PrcImieNazwisko
From CDN.TrwaleOsobyOdpowiedzialne Join @Table On SrOO_SrTId = SrTId
Where RecId = @Min And
((SrOO_SrTID = SrTId And ((@PrintDate Between SrOO_DataOd And SrOO_DataDo) Or (SrOO_DataOd Is Null And @PrintDate <= SrOO_DataDo)) Or
(SrOO_DataDo Is Null And @PrintDate >= SrOO_DataOd)) Or (SrOO_DataOd Is Null And SrOO_DataDo Is Null))
Update @Table
Set Osoba = IsNull(@Osoba,'')
Where RecId = @Min
If @@Rowcount = 0 Break
Else
Select @Min = @Min + 1
End
Return
End
