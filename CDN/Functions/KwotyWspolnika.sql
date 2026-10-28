Create Function CDN.KwotyWspolnika (@PrcId Int, @KwotaId Int, @Rok Int, @Miesiac Int)
Returns NVARCHAR(255)
As
Begin
Declare @Wynik NVARCHAR(255)
Set @Wynik = ''
Select Top 1 @Wynik = PPK_Wartosc
From CDN.PracPitKwoty
Join CDN.PracPitMies On PPM_PPMId = PPK_PPMId
Where PPM_PraId = @PrcId
  And PPK_Numer = @KwotaId
  And 100 * PPM_Rok + PPM_Miesiac <= 100 * @Rok + @Miesiac
Order By PPM_Rok Desc, PPM_Miesiac Desc
Return IsNull(@Wynik, '')
End
