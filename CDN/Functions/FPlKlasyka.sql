Create Function CDN.FPlKlasyka (@Nr Int)
 Returns Int
As
 Begin
 Declare @FplId Int
 Set @FPlId = Null
 Select Top 1 @FPlId = FPl_FPlId From CDN.FormyPlatnosci
 Where FPl_NieAktywny=0 And FPl_Nazwa = Case @Nr
  When 1 Then 'gotówka'
  When 2 Then 'czek'
  When 3 Then 'przelew'
  When 4 Then 'kredyt'
  When 5 Then 'inne'
  When 6 Then 'karta płatnicza'
  When 7 Then 'kompensata'
  When 8 Then 'zaliczka'
  Else ''
  End
 If @FPlId Is Null
  Begin
   If @Nr In (1,2)
    -- gotówka, czek
    Select Top 1 @FPlId = FPl_FPlId From CDN.FormyPlatnosci
    Where FPl_NieAktywny=0 And FPl_Typ = 1 And FPl_Termin = 0
    Order By FPl_FPlId
   Else If @Nr = 3
    -- przelew
    Select Top 1 @FPlId = FPl_FPlId From CDN.FormyPlatnosci
    Where FPl_NieAktywny=0 And FPl_Typ = 2
    Order By FPl_FPlId
   Else If @Nr = 4
    -- kredyt
    Select Top 1 @FPlId = FPl_FPlId From CDN.FormyPlatnosci
    Where FPl_NieAktywny=0 And FPl_Typ = 1 And FPl_Termin <> 0
    Order By FPl_FPlId
   Else If @Nr = 6
    -- karta
    Select Top 1 @FPlId = FPl_FPlId From CDN.FormyPlatnosci
    Where FPl_NieAktywny=0 And FPl_Typ = 3
    Order By FPl_FPlId
   Else If @Nr = 7
    -- kompensata
    Select Top 1 @FPlId = FPl_FPlId From CDN.FormyPlatnosci
    Where FPl_NieAktywny=0 And FPl_Typ = 4
    Order By FPl_FPlId
  End
 If @FPlId Is Null
    Select Top 1 @FPlId = FPl_FPlId From CDN.FormyPlatnosci
    Where FPl_NieAktywny=0
    Order By FPl_FPlId
 Return @FPlId
 End
