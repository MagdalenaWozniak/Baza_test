CREATE Function CDN.NumeryZaznaczonych(@MarkId NVARCHAR(255))
Returns @Table Table (NumeryDok NVARCHAR(255), Kwota Decimal(15,2))
As
Begin
Declare @NumeryFA NVARCHAR(255)
Declare @Kwota Decimal(15,2)
Set @NumeryFA = ''
Set @Kwota = 0
While 1=1
Begin
 If Not Exists (Select * From CDN.RptZaznaczenia2 Where RpZ2_GUID = @MarkId) Break
 Select @NumeryFA = RTrim(@NumeryFA) + '; ' + Case BZd_NumerObcy When '' Then RTrim(BZd_NumerPelny)
   Else RTrim(BZd_NumerObcy) End, @Kwota = @Kwota + BZd_KwotaSys
  From CDN.BnkZdarzenia, CDN.RptZaznaczenia2 Where RpZ2_GUID = @MarkId And BZd_BZdId = RpZ2_GIDNumer
 Break
End
Insert Into @Table (NumeryDok, Kwota)
Select  Substring(@NumeryFA,3,255), @Kwota
Return
End
