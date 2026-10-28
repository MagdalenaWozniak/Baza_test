Create Function CDN.KierunekOrg (@DDfId Int)
Returns Int
As
 Begin
  Declare @Kierunek Int
  Select @Kierunek = DDf_KierunekOrg From CDN.DokDefinicje Where DDf_DDfId = @DDfId
  Return @Kierunek
 End
