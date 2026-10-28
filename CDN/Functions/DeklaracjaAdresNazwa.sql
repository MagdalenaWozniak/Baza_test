Create Function CDN.DeklaracjaAdresNazwa ( @Id_Dek Int )
Returns @Firma Table (
 NazwaSkrocona NVARCHAR(50),
 NazwaPelna NVARCHAR(150),
 AdresMiastoUlica NVARCHAR(100),
 AdresKodPoczta NVARCHAR(50),
 Adres NVARCHAR(150)
 )
As
Begin
Declare
@Dekl_Typ Int,
@Skrocona NVARCHAR(50),
@Pelna    NVARCHAR(150),
@Miasto   NVARCHAR(30),
@Ulica    NVARCHAR(30),
@Kod      NVARCHAR(10),
@Poczta   NVARCHAR(30),
@NrDomu   NVARCHAR(10),
@Lokal    NVARCHAR(10)
-- Typ deklaracji
If Not Exists (Select * From CDN.DeklNag Where DkN_DkNID = @Id_Dek)
 Return
Select @Dekl_Typ = DkN_TypDeklar From CDN.DeklNag Where DkN_DkNID = @Id_Dek
If ( @Dekl_Typ In (2,4,12,15,16,20,41,42) )
 Begin
-- PIT5
  Select @Skrocona = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1119
  Set @Pelna = ''
  Select
   @Pelna = Pod_Nazwa1 + ' ' + Pod_Nazwa2,
   @Poczta = Pod_Poczta,
   @Miasto = Pod_Miasto ,
   @Ulica  = Pod_Ulica,
   @NrDomu = Pod_NrDomu ,
   @Lokal  = Pod_NrLokalu,
   @Kod    = Pod_KodPocztowy
  From CDN.PodmiotyView Join CDN.DeklNag On DkN_PraID = Pod_PodId And Pod_PodmiotTyp = 3
  Where DkN_DkNId =@Id_Dek
 End
Else If ( @Dekl_Typ In (3,8,17,6) )
 Begin
  Select @Skrocona = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1119
  Select @Pelna    = Fir_Wartosc From CDN.FIrma Where Fir_Numer = 1104
  Select @Pelna    = @Pelna + ' ' + Fir_Wartosc From CDN.FIrma Where Fir_Numer = 1159
  Select @Poczta   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1114
  Select @Miasto   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1112
  Select @Ulica    = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1109
  Select @NrDomu   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1110
  Select @Lokal    = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1111
  Select @Kod      = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1113
 End
Else If ( @Dekl_Typ = 1 )
 Begin
  Select @Skrocona = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1119
  Select @Pelna    = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1104
  Select @Pelna    = @Pelna + ' ' + Fir_Wartosc From CDN.FIrma Where Fir_Numer = 1159
  Select @Poczta   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1599
  Select @Miasto   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1597
  Select @Ulica    = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1594
  Select @NrDomu   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1595
  Select @Lokal    = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1596
  Select @Kod      = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1598
 End
Else
 Begin
  Select @Skrocona = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1119
  Select @Pelna    = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1156
  Select @Poczta   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1154
  Select @Miasto   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1152
  Select @Ulica    = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1149
  Select @NrDomu   = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1150
  Select @Lokal    = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1151
  Select @Kod      = Fir_Wartosc From CDN.Firma Where Fir_Numer = 1153
 End
Insert InTo @Firma (
 NazwaSkrocona,
 NazwaPelna,
 AdresMiastoUlica,
 AdresKodPoczta,
 Adres
 )
Values (
 @Skrocona,
 @Pelna,
 Case When @Poczta <> '' And @Miasto <> '' And @Poczta <> @Miasto Then @Miasto + ', ' Else '' End + @Ulica + ' ' + @NrDomu + Case @Lokal When '' Then '' Else '/' + @Lokal End,
 Case @Kod When '00-000' Then '' Else @Kod + ' ' End + Case @Poczta When '' Then @Miasto Else @Poczta End,
 Case @Poczta When '' Then '' When @Miasto Then '' Else @Miasto + ', ' End +
   @Ulica + ' ' + @NrDomu + Case @Lokal When '' Then '' Else '/' + @Lokal End +
   CHAR(10) +
   Case @Kod When '00-000' Then '' Else @Kod + ' ' End +
   Case @Poczta When '' Then @Miasto Else @Poczta End
 )
Return
End
