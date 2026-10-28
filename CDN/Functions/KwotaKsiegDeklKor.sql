Create Function CDN.KwotaKsiegDeklKor (@DkNId Int, @Numer Int)
Returns Numeric (15,2)
As
Begin
Declare @Wynik Numeric(15,2), @PrevDkNId Int
Select Top 1 @PrevDkNId = B.DkN_DkNId
From CDN.DeklNag A
Join CDN.DeklNag B On A.DkN_TypDeklar = B.DkN_TypDeklar And A.DkN_RokMiesiac = B.DkN_RokMiesiac And IsNull(A.DkN_PraId,0) = IsNull(B.DkN_PraId,0) And B.DkN_Numer < A.DkN_Numer
Where A.DkN_DkNId = @DkNId
Order By B.DkN_Numer Desc
If @PrevDkNId Is Not Null
 Select @Wynik = Sum(
   Case When DkE_DkNId = @DkNId Then 1 Else -1 End * DkE_WartoscL / Case When DkE_WartoscM=0 Then 1.0 Else DkE_WartoscM End
   )
  From CDN.DeklElem
 Where DkE_DkNId In (@DkNId, @PrevDkNId) And DkE_Numer = @Numer
Return IsNull(@Wynik, 0)
End
