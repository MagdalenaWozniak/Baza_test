Create Function CDN.OdsetkiSys (@NOEId Int)
Returns Decimal(15,2)
As
Begin
 Declare @Wynik Decimal(15,2), @NONId Int, @MinNOEId Int
 Select @NONId = NOE_NONId From CDN.NotyOdsElem Where NOE_NOEId = @NOEId
 Select @MinNOEId = Min(NOE_NOEId) From CDN.NotyOdsElem Where NOE_NONId = @NONId
 Select @Wynik = NOE_OdsetkiKwota * NON_KursL / NON_KursM From CDN.NotyOdsElem Join CDN.NotyOdsNag On NOE_NONId = NON_NONId Where NOE_NOEId = @NOEId
 If @NOEId = @MinNOEId
  Select @Wynik = @Wynik + NON_RazemOdsetkiSys - SUM(ROUND(NOE_OdsetkiKwota * NON_KursL / NON_KursM, 2)) From CDN.NotyOdsElem Join CDN.NotyOdsNag On NOE_NONId = NON_NONId Where NON_NONId = @NONId Group By NON_RazemOdsetkiSys
 Return @Wynik
End
