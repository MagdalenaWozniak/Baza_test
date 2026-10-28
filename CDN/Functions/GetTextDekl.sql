CREATE   Function CDN.GetTextDekl( @DkNId Int, @DkEId Int )
Returns NVARCHAR(50)
As
Begin
Declare @WartTekstowa NVARCHAR(50)
Set @WartTekstowa = ''
  Select @WartTekstowa = DkE_WartoscTekst
  From CDN.DeklElem Where DkE_DkNId = @DknId And DkE_Numer = @DkEId
Return @WartTekstowa
End
