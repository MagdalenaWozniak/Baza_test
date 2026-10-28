Create Function CDN.TrNZaokraglenieNB (@TrNId Int)
Returns Decimal (15,2)
As
Begin
 Declare @Wynik Decimal(15,2), @TypNB Int
 Set @Wynik = 0
 Select @TypNB = TrN_TypNB From CDN.TraNag Where TrN_TrNId = @TrNId
 Set @Wynik =
   (Select Sum(Case @TypNB When 1 Then TrV_Netto + TrV_Vat Else TrV_Netto        End) From CDN.TraVat  Where TrV_TrNId = @TrNId And TrV_Typ=0)
  -(Select Sum(Case @TypNB When 1 Then TrE_WartoscBrutto   Else TrE_WartoscNetto End) From CDN.TraElem Where TrE_TrNId = @TrNId)
 Return IsNull(@Wynik, 0)
End
