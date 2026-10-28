Create Function CDN.Waluta (@Waluta NVARCHAR(3))
Returns NVARCHAR(3)
As
 Begin
  If IsNull(@Waluta, '') = ''
   Select @Waluta = Cast (Fir_Wartosc As NVARCHAR(3)) From CDN.Firma Where Fir_Numer = 3
  Return IsNull(@Waluta, '')
 End
