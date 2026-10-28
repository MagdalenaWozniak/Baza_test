Create Function CDN.KwotaKsiegDekl (@DkNId Int, @Numer Int)
Returns Numeric (15,2)
As
Begin
Declare @Wynik Numeric(15,2)
 Select @Wynik = Sum(DkE_WartoscL / Case When DkE_WartoscM=0 Then 1.0 Else DkE_WartoscM End)
  From CDN.DeklElem
 Where DkE_DkNId = @DkNId And DkE_Numer = @Numer
Return IsNull(@Wynik, 0)
End
