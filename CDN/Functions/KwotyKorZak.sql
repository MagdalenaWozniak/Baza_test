CREATE FUNCTION [CDN].[KwotyKorZak] (@DkNId Int, @DataOd NVARCHAR(6), @DataDo NVARCHAR(6), @Rok  NVARCHAR(4))
Returns @Table Table(
RecId Int Identity(1,1),
DkNId Int,
WSP Decimal(15,2),
WSP_SZ Decimal(15,2),
WSP_FIN2 Decimal(15,2),
BTMN Decimal(15,2),
BTMN_O Decimal(15,2),
BTMN_PON15 Decimal(15,2),
BTMN_PON15_O Decimal(15,2),
BTMN_POW15 Decimal(15,2),
BTMN_POW15_O Decimal(15,2),
BTMV Decimal(15,2),
BTMV_O Decimal(15,2),
BTMV_PON15 Decimal(15,2),
BTMV_PON15_O Decimal(15,2),
BTMV_POW15 Decimal(15,2),
BTMV_POW15_O Decimal(15,2),
NTUPN Decimal(15,2),
NTUPN_O Decimal(15,2),
NTUPV Decimal(15,2),
NTUPV_O Decimal(15,2),
ZNSozN Decimal(15,2),
ZNSozN_O Decimal(15,2),
ZNSozN_PON15 Decimal(15,2),
ZNSozN_PON15_O Decimal(15,2),
ZNSozN_POW15 Decimal(15,2),
ZNSozN_POW15_O Decimal(15,2),
ZNSozV Decimal(15,2),
ZNSozV_O Decimal(15,2),
ZNSozV_PON15 Decimal(15,2),
ZNSozV_PON15_O Decimal(15,2),
ZNSozV_POW15 Decimal(15,2),
ZNSozV_POW15_O Decimal(15,2)
)
As
Begin
Declare @WSP_SZ Decimal(15,2)
Declare @WSP_FIN2 Decimal(15,2)
Declare @DataStart NVARCHAR(6)
Declare @DataOdOld NVARCHAR(6)
Declare @DataDoOld NVARCHAR(6)
Declare @Wspolczynnik2011 SmallInt
Set @DataStart = (Select Case @Rok When '2005' Then '200501' Else @DataOd End)
Set @Wspolczynnik2011 = (select DkE_WartoscL from cdn.deklelem where DkE_DkNID=@DkNID and DkE_Numer=18000)
Set @WSP_SZ = IsNull((Select Top 1 Cast (IsNull(WSP.DkW_Wartosc, '0') As Money)
From CDN.DeklWydr WAR Join CDN.DeklNag  On (WAR.DkW_DkNID = DkN_DkNID) Join CDN.DeklWydr WSP On (WSP.DkW_DkNID = WAR.DkW_DkNID)
Where  DkN_RokMiesiac >= @DataStart And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And WAR.DkW_Rubryka = 1002 And WAR.DkW_SubRubryka = 3 And WSP.DkW_Rubryka = 1003), 0)
Set @WSP_FIN2 = IsNull((Select Case When @WSP_SZ > 98  Then 100 Else case When  @WSP_SZ <= 2  Then 0 Else @WSP_SZ End End), 0)
Insert Into @Table (DkNId)
Select @DkNId
Update @Table
Set WSP = IsNull((Select Top 1 DkW_Wartosc From CDN.DeklWydr Where DkW_Rubryka = 1003 And DkW_DkNId = @DkNId), 0)
Update @Table
Set WSP_SZ = @WSP_SZ
Update @Table
Set BTMN_POW15 = IsNUll((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 3), 0)
Update @Table
Set BTMV_POW15 = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 4), 0)
Update @Table
Set BTMN_POW15_O = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end)   * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 3), 0)
Update @Table
Set BTMV_POW15_O =  IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 4), 0)
Update @Table
Set BTMN_PON15 = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 32), 0)
Update @Table
Set BTMV_PON15 = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID =  DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 33), 0)
Update @Table
Set BTMN_PON15_O = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 32), 0)
Update @Table
Set BTMV_PON15_O = IsNull((Select Sum (Cast (IsNull(DkW_Wartosc, '0') As MOney) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 33), 0)
Update @Table
Set ZNSozN_POW15 = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 9), 0)
Update @Table
Set ZNSozV_POW15 = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 10), 0)
Update @Table
Set ZNSozN_POW15_O = IsNull((Select Sum(Cast (IsNull(DkW_Wartosc, '0') As Money) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 9), 0)
Update @Table
Set ZNSozV_POW15_O = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 10), 0)
Update @Table
Set ZNSozN_PON15 = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 36), 0)
Update @Table
Set ZNSozV_PON15 = IsNull((Select Sum(Cast (IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 37), 0)
Update @Table
Set ZNSozN_PON15_O = IsNull((Select Sum(Cast (IsNull(DkW_Wartosc, '0') As Money) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 36), 0)
Update @Table
Set ZNSozV_PON15_O = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 37), 0)
Update @Table
Set NTUPN = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 7), 0)
Update @Table
Set NTUPV = IsNull((Select Sum (Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DAtaDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 8), 0)
Update @Table
Set NTUPN_O = IsNull((Select Sum (Cast(IsNull(DkW_Wartosc, '0') As MOney) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 7), 0)
Update @Table
Set NTUPV_O = IsNull((Select Sum (Cast(IsNull(DkW_Wartosc, '0') As Money) *  Case when (@Wspolczynnik2011=1 and DkN_RokMiesiac in (201101,201102,201103)) OR DkN_RokMiesiac<201101
then @WSP_FIN2 else @WSP_SZ end) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOd And DkN_RokMiesiac <= @DataDo And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 8), 0)
-- obliczenia wartooci dla 2004 i 2005 roku
Set @DataOdOld = (Select Case @Rok When '2004' Then '200405' Else '200501' End)
Set @DataDoOld = (Select Case @Rok When '2004' Then '200412' Else '200505' End)
Update @Table
Set BTMN = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOdOld And DkN_RokMiesiac <= @DataDoOld And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 3), 0)
Update @Table
Set BTMV = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOdOld And DkN_RokMiesiac <= @DataDoOld  And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 4), 0)
Update @Table
Set BTMN_O = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) * @WSP_FIN2) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOdOld And DkN_RokMiesiac <= @DataDoOld  And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 3), 0)
Update @Table
Set BTMV_O = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) * @WSP_FIN2) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOdOld And DkN_RokMiesiac <= @DataDoOld  And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 4), 0)
Update @Table
Set ZNSozN = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOdOld And DkN_RokMiesiac <= @DataDoOld  And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 9), 0)
Update @Table
Set ZNSozV = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money))
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOdOld And DkN_RokMiesiac <= @DataDoOld  And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 10), 0)
Update @Table
Set ZNSozN_O = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) * @WSP_FIN2) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOdOld And DkN_RokMiesiac <= @DataDoOld  And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 9), 0)
Update @Table
Set ZNSozV_O = IsNull((Select Sum(Cast(IsNull(DkW_Wartosc, '0') As Money) * @WSP_FIN2) * 0.01
From CDN.DeklWydr Join CDN.DeklNag On (DkW_DkNID = DkN_DkNID)
Where DkN_RokMiesiac >= @DataOdOld And DkN_RokMiesiac <= @DataDoOld  And DkN_Finalna = 1 And DkW_Rubryka = 1002 And DkW_SubRubryka = 10), 0)
Return
End
