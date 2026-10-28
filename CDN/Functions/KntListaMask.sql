Create Function CDN.KntListaMask (@NipE NVARCHAR(20), @Nazwa NVARCHAR(130), @Miasto NVARCHAR(50), @AdresCdBezZnakowSpecjalnychIPrefiksow NVARCHAR(256))
Returns @KntId Table (KntId Int)
As
Begin
Declare @Poz Int, @Nip NVARCHAR(20), @Znak Char(1)
Set @Poz = 1
Set @Nip = ''
If @NipE <> ''
 While @Poz <= Len(@NipE)
  Begin
   Set @Znak = SubString(@NipE, @Poz, 1)
   If @Znak Like '[0-9]' Or @Znak Like '[a-z]'
    Set @Nip = @Nip + @Znak
   Set @Poz = @Poz + 1
  End
Declare @N1 NVARCHAR(50), @N2 NVARCHAR(50), @N3 NVARCHAR(50)
Declare @M1 NVARCHAR(50), @M2 NVARCHAR(50)
Set @N1 = ''
Set @N2 = ''
Set @N3 = ''
Set @M1 = ''
Set @M2 = ''
If @Nazwa <> ''
 Select
  @N1 = IsNull(Max(Case Lp When 1 Then Klucz Else '' End), ''),
  @N2 = IsNull(Max(Case Lp When 2 Then Klucz Else '' End), ''),
  @N3 = IsNull(Max(Case Lp When 3 Then Klucz Else '' End), '')
 From CDN.KntPobierzKlucze (@Nazwa, 1)
If @Miasto <> ''
 Select
  @M1 = IsNull(Max(Case Lp When 1 Then Klucz Else '' End), ''),
  @M2 = IsNull(Max(Case Lp When 2 Then Klucz Else '' End), '')
 From CDN.KntPobierzKlucze (@Miasto, 0)
If @N1 <> '' Set @N1 = '%[^a-z]' + @N1 + '[^a-z]%'
If @N2 <> '' Set @N2 = '%[^a-z]' + @N2 + '[^a-z]%'
If @N3 <> '' Set @N3 = '%[^a-z]' + @N3 + '[^a-z]%'
If @M1 <> '' Set @M1 = '%[^a-z]' + @M1 + '[^a-z]%'
Else Set @M1 = '%'
If @M2 <> '' Set @M2 = '%[^a-z]' + @M2 + '[^a-z]%'
Insert InTo @KntId
Select Knt_KntId From CDN.Kontrahenci
Where @Nip <> '' And @Nip = Knt_Nip
   Or (@Nip = '' Or Knt_Nip = '')
  And ('.'+Knt_Miasto+'.' = '' Or '.'+Knt_Miasto+'.' Like @M1 Or '.'+Knt_Miasto+'.' Like @M2)
  And Knt_Nazwa1+Knt_Nazwa2 <> '' And ('.'+Knt_Nazwa1+'.'+Knt_Nazwa2+'.' Like @N1 And (@N2 = '' Or '.'+Knt_Nazwa1+'.'+Knt_Nazwa2+'.' Like @N2 Or '.'+Knt_Nazwa1+'.'+Knt_Nazwa2+'.' Like @N3) Or
      '.'+Knt_Nazwa1+'.'+Knt_Nazwa2+'.' Like @N2 And '.'+Knt_Nazwa1+'.'+Knt_Nazwa2+'.' Like @N3)
  AND CDN.KntListaUsunZnakiSpecjalneIPrefiksy(Knt_Ulica, Knt_NrDomu, Knt_NrLokalu) = @AdresCdBezZnakowSpecjalnychIPrefiksow
Return
End
