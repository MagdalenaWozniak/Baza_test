CREATE  FUNCTION CDN.KwotyMW(@BRaId Int, @Data1 Int, @Data2 Int)
RETURNS @KwotyMW Table(DokTyp SmallInt, Id Int, Kierunek Int, Kwota Dec(15,2), Waluta NVARCHAR(10), KwotaSys Dec(15,2), KursNumer SmallInt,
DataKur NVARCHAR(20), KursL Decimal(15,4), KursM Decimal(15,4), PodmiotTyp SmallInt, Wynagrodzenie SmallInt, NumerObcy NVARCHAR(256),
NumerPelny NVARCHAR(40), DataDok NVARCHAR(20))
As
Begin
Declare @DataOd DateTime
Declare @DataDo DateTime
Set @DataOd = Convert(DateTime, @Data1, 120)
Set @DataDo = Convert(DateTime, @Data2, 120)
Insert Into @KwotyMW (DokTyp, Id, Kierunek, Kwota, Waluta, KwotaSys, KursNumer, DataKur, KursL, KursM, PodmiotTyp, Wynagrodzenie, NumerObcy, NumerPelny, DataDok)
Select DokTyp = 1,
Id = BOMW_BOMWID,
Kierunek = BOMW_Kierunek,
Kwota = BOMW_Kwota - BOMW_KwotaRozMW,
Waluta =  BOMW_Waluta,
KwotaSys = BOMW_KwotaSys - BOMW_KwotaRozSysMW,
KursNumer = BOMW_KursNumer,
DataKur = Convert(NVARCHAR(40),BOMW_DataKur, 120),
KursL = BOMW_KursL,
KursM = BOMW_KursM,
PodmiotTyp = 0,
Wynagrodzenie = 0,
NumerObcy = BOMW_NumerObcy,
NumerPelny = BOMW_NumerPelny,
DataDok = Convert(NVARCHAR(40), BOMW_DataDok, 120)
From CDN.BnkBOMW
Where BOMW_BRaID = @BRaId AND BOMW_RozliczonoMW = 1 AND BOMW_DataDok Between @dataOd And @DataDo
Union All
Select DokTyp = 2,
Id = BZp_BZpID,
Kierunek = BZp_Kierunek,
Kwota = Case BZp_Kierunek When 1 Then BZp_Kwota - BZp_KwotaRozMW Else -(BZp_Kwota - BZp_KwotaRozMW) End,
Waluta = BZp_Waluta,
KwotaSys = CASE BZp_Kierunek When 1 Then BZp_KwotaSys - BZp_KwotaRozSysMW Else -(BZp_KwotaSys - BZp_KwotaRozSysMW) End,
KursNumer = BZp_KursNumer,
DataKur = Convert(NVARCHAR(40), BZp_DataKur, 120),
KursL = BZp_KursL,
KursM = BZp_KursM,
PodmiotTyp = BZp_PodmiotTyp,
Wynagrodzenie = BZp_Wynagrodzenie,
--NumerObcy  = Case When (0=1 And (BZp_PodmiotTyp = 3 Or BZp_PodmiotTyp = 4)) Or (0=1 And BZp_Wynagrodzenie=1) Then '
--NumerPelny = Case When (0=1 And (BZp_PodmiotTyp = 3 Or BZp_PodmiotTyp = 4)) Or (0=1 And BZp_Wynagrodzenie=1) Then '
NumerObcy = BZp_NumerObcy,
NumerPelny = BZp_NumerPelny,
DataDok = Convert(NVARCHAR(40), BZp_DataDok, 120)
From CDN.BnkZapisy
Where BZp_BRaID = @BRaId And BZp_MagazynWalut = 1 And BZp_RozliczonoMW = 1 And BZp_DataDok Between @DataOd And @DataDo
Order By DataDok, DokTyp, Id
Return
End
