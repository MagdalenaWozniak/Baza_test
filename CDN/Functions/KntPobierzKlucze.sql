Create Function CDN.KntPobierzKlucze (@Ciag NVARCHAR(1024), @tryb Int)
Returns @Klucze Table (Lp Int, Klucz NVARCHAR(50))
As
Begin
Declare @Wyjatki Table (Wyjatek NVARCHAR(50))
Insert @Wyjatki Values('AGENCJA')
Insert @Wyjatki Values('APTEKA')
Insert @Wyjatki Values('BANK')
Insert @Wyjatki Values('BAR')
Insert @Wyjatki Values('BIURO')
Insert @Wyjatki Values('CENTRUM')
Insert @Wyjatki Values('CHEMICZN%')
Insert @Wyjatki Values('DETAL%')
Insert @Wyjatki Values('DRUKARNIA')
Insert @Wyjatki Values('DYSTRYBU%')
Insert @Wyjatki Values('FABRYKA')
Insert @Wyjatki Values('FH')
Insert @Wyjatki Values('FHU')
Insert @Wyjatki Values('FHUP')
Insert @Wyjatki Values('FIRMA')
Insert @Wyjatki Values('FUH')
Insert @Wyjatki Values('FUNDACJA')
Insert @Wyjatki Values('FUNDUSZ')
Insert @Wyjatki Values('GOSPODARSTWO')
Insert @Wyjatki Values('GRUPA')
Insert @Wyjatki Values('HANDEL')
Insert @Wyjatki Values('HANDLOW_')
Insert @Wyjatki Values('HOTEL')
Insert @Wyjatki Values('HURT')
Insert @Wyjatki Values('HURTOW%')
Insert @Wyjatki Values('HUTA')
Insert @Wyjatki Values('INWALIDÓW')
Insert @Wyjatki Values('KAWIARNIA')
Insert @Wyjatki Values('KIOSK')
Insert @Wyjatki Values('LABORATORI%')
Insert @Wyjatki Values('MIEJSK%')
Insert @Wyjatki Values('ODDZIAŁ')
Insert @Wyjatki Values('OKRĘGOW%')
Insert @Wyjatki Values('OO')
Insert @Wyjatki Values('PAŃSTWOW%')
Insert @Wyjatki Values('PODATK%')
Insert @Wyjatki Values('POLIGRAF%')
Insert @Wyjatki Values('POLSK%')
Insert @Wyjatki Values('POWIAT%')
Insert @Wyjatki Values('PPHU')
Insert @Wyjatki Values('PRACOWNIA')
Insert @Wyjatki Values('PRODUKCYJN_')
Insert @Wyjatki Values('PRYWATN%')
Insert @Wyjatki Values('PRZEDSIĘBIORSTWO')
Insert @Wyjatki Values('PRZEMYSŁ%')
Insert @Wyjatki Values('PRZETWÓR%')
Insert @Wyjatki Values('PRZYCHODNIA')
Insert @Wyjatki Values('PUNKT')
Insert @Wyjatki Values('RACHUNKO%')
Insert @Wyjatki Values('REGIONALN%')
Insert @Wyjatki Values('RESTAURACJA')
Insert @Wyjatki Values('SA')
Insert @Wyjatki Values('SALON')
Insert @Wyjatki Values('SAM')
Insert @Wyjatki Values('SC')
Insert @Wyjatki Values('SERWIS')
Insert @Wyjatki Values('SIEDZIB%')
Insert @Wyjatki Values('SKLEP')
Insert @Wyjatki Values('SP')
Insert @Wyjatki Values('SPÓŁDZIELNIA')
Insert @Wyjatki Values('SPÓŁKA')
Insert @Wyjatki Values('SPOŻYWCZ_')
Insert @Wyjatki Values('STACJA')
Insert @Wyjatki Values('STOWARZYSZ%')
Insert @Wyjatki Values('STUDIO')
Insert @Wyjatki Values('SUPERMARKET')
Insert @Wyjatki Values('SZKOŁA')
Insert @Wyjatki Values('SZPITAL')
Insert @Wyjatki Values('TAXI')
Insert @Wyjatki Values('TOWARZYSTWO')
Insert @Wyjatki Values('URZĄD')
Insert @Wyjatki Values('USŁUGOW_')
Insert @Wyjatki Values('WIELOBRANŻOW_')
Insert @Wyjatki Values('WOJEWÓDZK%')
Insert @Wyjatki Values('WYDAWNIC%')
Insert @Wyjatki Values('WYROBÓW')
Insert @Wyjatki Values('WYTWÓRNIA')
Insert @Wyjatki Values('ZAGRANICZ%')
Insert @Wyjatki Values('ZAKŁAD')
Insert @Wyjatki Values('ZESPÓŁ')
Insert @Wyjatki Values('ZIELARSK%')
Declare @Ciag2 NVARCHAR(1024), @Poz1 Int, @Poz2 Int, @Znak Char(1), @Lp Int, @K NVARCHAR(50)
Set @Ciag2 = ''
Set @Poz1 = 1
While @Poz1 <= Len(@Ciag)
 Begin
  Set @Znak = SubString(@Ciag, @Poz1, 1)
  If @Znak Like '[0-9]' Or @Znak Like '[A-Ż]'
   Set @Ciag2 = @Ciag2 + @Znak
  Else If Len(@Ciag2)>0 And SubString(@Ciag2, Len(@Ciag2), 1) <> '.'
   Set @Ciag2 = @Ciag2 + '.'
  Set @Poz1 = @Poz1 + 1
 End
Set @Ciag2 = Upper(@Ciag2)
Set @Poz1 = 1
Set @Poz2 = 0
Set @Lp   = 0
While @Poz2 <= Len(@Ciag2)
 Begin
  Set @Poz2 = @Poz2 + 1
  If SubString(@Ciag2, @Poz2, 1) = '.' Or @Poz2 = Len(@Ciag2)
   Begin
    If SubString(@Ciag2, @Poz2, 1) <> '.' Set @Poz2 = @Poz2 + 1
    Set @K = SubString(@Ciag2, @Poz1, @Poz2-@Poz1)
    Set @Poz2 = @Poz2 + 1
    Set @Poz1 = @Poz2
    If Len (@K) < 2 Or Len (@K) > 50
      Continue
    If @Tryb = 1 And Exists (Select * From @Wyjatki Where @K Like Wyjatek)
      Continue
    If Exists (Select * From @Klucze Where @K = Klucz)
      Continue
    Set @Lp = @Lp + 1
    Insert InTo @Klucze Values(@Lp, @K)
   End
 End
Return
End
