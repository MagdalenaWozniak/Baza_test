CREATE FUNCTION [CDN].[ObrotyPrzedOkresem] (@Syn SmallInt, @AccId Int, @OObId Int, @DataOd Int, @DataDo Int, @DziId Int, @Bufor SmallInt, @Waluta NVARCHAR(20), @FiltrProsty NVARCHAR(255))
Returns @Table Table (
RecId Int Identity(1,1),
AccNumer NVARCHAR(255),
ObrotyWN Decimal(15,2),
ObrotyMA Decimal(15,2) Default 0,
DataOd DateTime,
DataDo DateTime)
As
Begin
Declare @ObrotyWN Decimal(15,2)
Declare @ObrotyMA Decimal(15,2)
If @Syn = 1
(Select @ObrotyWN = Case When @Waluta = '-wszystkie-' Or @Waluta = '' Then
Sum(DeE_Kwota) Else Sum(DeE_KwotaWal) End
From CDN.DekretyElem Join CDN.DekretyNag On  DeE_DeNId = DeN_DeNId
Where  CDN.CzyOjciecKonta (DeE_AccWnId, @AccId ) <> 0
And DeN_Typ = 2
And DeN_OObId = @OObId
And DeE_DataOpe >= Convert(DateTime, @DataOd,120) And DeE_DataOpe <= Convert(DateTime,@DataDo,120)
And (@Bufor = 2 Or (@Bufor = 1 And DeN_Bufor = 1) Or (@Bufor = 0 And DeN_Bufor = 0))
And (@DziId = 0 Or (@DziId <> 0 And DeN_DziId = @DziId)))
If @Syn = 1
(Select @ObrotyMA= Case When @Waluta = '-wszystkie-' Or @Waluta = '' Then
Sum(DeE_Kwota) Else Sum(DeE_KwotaWal) End
From CDN.DekretyElem Join CDN.DekretyNag On  DeE_DeNId = DeN_DeNId
Where  CDN.CzyOjciecKonta (DeE_AccMaId, @AccId ) <> 0
And DeN_Typ = 2
And DeN_OObId = @OObId
And DeE_DataOpe >= Convert(DateTime, @DataOd,120) And DeE_DataOpe <= Convert(DateTime,@DataDo,120)
And (@Bufor = 2 Or (@Bufor = 1 And DeN_Bufor = 1) Or (@Bufor = 0 And DeN_Bufor = 0))
And (@DziId = 0 Or (@DziId <> 0 And DeN_DziId = @DziId)))
Insert Into @Table (AccNumer, ObrotyWN, ObrotyMA, DataOd, DataDo)
Select Acc_Numer, IsNull(@ObrotyWN,0), IsNull(@ObrotyMA,0), @DataOd, @DataDo
From CDN.Konta
Where Acc_AccId = @AccId
Return
End
