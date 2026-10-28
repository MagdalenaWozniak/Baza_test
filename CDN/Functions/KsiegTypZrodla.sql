CREATE   Function CDN.KsiegTypZrodla (@Tryb NVARCHAR(20), @Id Int)
Returns NVARCHAR(50)
As
 Begin
 Declare @Wynik NVARCHAR(50)
 Declare @TypWzorca Int
 Declare @Zrodlo Int
 Set @Wynik = ''
 If @Tryb = 'DeN'
  Begin
   Select @Zrodlo = DeN_Zrodlo, @TypWzorca = DeN_WzorzecTyp From CDN.DekretyNag Where DeN_DeNId = @Id
   If @Zrodlo = 0
    Begin
     If @TypWzorca = 22 Set @Wynik = 'Księgowanie okresowe'
     Else Set @Wynik = 'Księgowanie ręczne'
    End
   If @Zrodlo = 1
    Begin
     Set @Tryb = 'TrN'
     Select Top 1 @Id = TrN_TrNId From CDN.TraNag Where TrN_DekId = @Id
    End
   If @Zrodlo = 2
    Begin
     Set @Tryb = 'VaN'
     Select Top 1 @Id = VaN_VaNId From CDN.VatNag Where VaN_DekId = @Id
    End
   If @Zrodlo = 6
    Begin
     Set @Tryb = 'DkN'
     Select Top 1 @Id = DkN_DkNId From CDN.DeklNag Where DkN_DekId = @Id Order By DkN_DkNId
    End
   If @Zrodlo = 7
    Begin
     Set @Tryb = 'SrH'
     Select Top 1 @Id = SrH_SrHId From CDN.TrwaleHist Where SrH_DekId = @Id
    End
   If @Zrodlo = 9
    Begin
     Set @Tryb = 'BRp'
     Select Top 1 @Id = BRp_BRpId From CDN.BnkRaporty Where BRp_DekId = @Id
    End
   If @Zrodlo = 10
    Begin
     Set @Tryb = 'LPL'
    End
   If @Zrodlo = 11
    Begin
     Set @Tryb = 'NON'
    End
   If @Zrodlo = 12
    Begin
     Set @Tryb = 'EDN'
     Select Top 1 @Id = EDN_EDNId From CDN.EwidDodNag Where EDN_DekId = @Id
    End
   If @Zrodlo = 13
    Begin
     If Exists (Select * From CDN.BnkRozKwoty Where BRK_DekId = @Id)
      Begin
       Set @Tryb = 'RKUR'
      End
     Else If Exists (Select * From CDN.BnkRozKwoty Where BRK_Dek2Id = @Id)
      Begin
       Set @Tryb = 'BRK'
      End
    End
   If @Zrodlo = 41 Or @Zrodlo = 42
    Begin
     Set @Tryb = 'PWN'
     Select Top 1 @Id = PWN_PWNId From CDN.PrzeszacWalutNag Where PWN_PWNId = @Id Order By PWN_PWNId
    End
   If @Zrodlo = 43
    Begin
     Set @Tryb = 'RKURMW'
    End
   If @Zrodlo = 49
    Begin
     Set @Tryb = 'KDN'
     Select Top 1 @Id = KDN_KDNId From CDN.KsiDokNag Where KDN_DekID = @Id Order By KDN_KDNId
    End
   If @Zrodlo = 50
    Begin
     Set @Tryb = 'KPN'
     Select Top 1 @Id = KPN_KPNId From CDN.KompensatyNag Where KPN_DekID = @Id Order By KPN_KPNId
    End
  End
 If @Tryb = 'KPR'
  Begin
   Select @Zrodlo = KPR_Zrodlo From CDN.ZapisyKPR Where KPR_KPRId = @Id
   If @Zrodlo = 0
    Begin
     Set @Wynik = 'Księgowanie ręczne'
    End
   If @Zrodlo = 2
    Begin
     Set @Tryb = 'VaN'
     Select Top 1 @Id = VaN_VaNId From CDN.VatNag Where VaN_KPRId = @Id
    End
   If @Zrodlo = 3
    Begin
     Set @Tryb = 'AuR'
    End
   If @Zrodlo = 4
    Begin
     Set @Tryb = 'ReN'
    End
   If @Zrodlo = 5
    Begin
     Set @Tryb = 'WyN'
    End
   If @Zrodlo = 7
    Begin
     Set @Tryb = 'SrH'
     Select Top 1 @Id = SrH_SrHId From CDN.TrwaleHist Where SrH_KPRId = @Id
    End
   If @Zrodlo = 10
    Begin
     Set @Tryb = 'LPL'
    End
   If @Zrodlo = 12
    Begin
     Set @Tryb = 'EDN'
     Select Top 1 @Id = EDN_EDNId From CDN.EwidDodNag Where EDN_KPRId = @Id
    End
   If @Zrodlo = 13
    Begin
       Set @Tryb = 'RKUR'
    End
   If @Zrodlo = 14
    Begin
       Set @Tryb = 'Zapis kasa/bank'
    End
   If @Zrodlo = 43
    Begin
       Set @Tryb = 'RKURMW'
    End
  End
 If @Tryb = 'RYC'
  Begin
   Select @Zrodlo = RYC_Zrodlo From CDN.Ryczalt Where RYC_RYCId = @Id
   If @Zrodlo = 0
    Begin
     Set @Wynik = 'Księgowanie ręczne'
    End
   If @Zrodlo = 2
    Begin
     Set @Tryb = 'VaN'
     Select Top 1 @Id = VaN_VaNId From CDN.VatNag Where VaN_RYCId = @Id
    End
   If @Zrodlo = 12
    Begin
     Set @Tryb = 'EDN'
     Select Top 1 @Id = EDN_EDNId From CDN.EwidDodNag Where EDN_RYCId = @Id
    End
  End
 If @Tryb = 'TrN'
    Select @Wynik =
    Case TrN_TypDokumentu
     When 301 Then 'Faktura zakupu'
     When 302 Then 'Faktura sprzedaży'
     When 303 Then 'Przyjęcie wewnętrzne'
     When 304 Then 'Rozchód wewnętrzny'
     When 305 Then 'Paragon'
     When 306 Then 'Wydanie zewnętrzne'
     When 307 Then 'Przyjęcie zewnętrzne'
     When 308 Then 'Rezerwacja odbiorcy'
     When 309 Then 'Zamówienie u dostawcy'
     When 310 Then 'Bilans magazynu'
     When 311 Then 'Arkusz Inwentaryzacyjny'
     When 312 Then 'Przesunięcie MM'
     When 313 Then 'Przyjęcie kaucji'
     When 314 Then 'Wydanie kaucji'
     When 317 Then 'Przyjęcie wewnętrzne produktów'
     When 318 Then 'Rozchód wewnętrzny składników'
     When 320 Then 'Faktura pro-forma'
     When 321 Then 'Dokument wewnętrzny zakupu'
     When 322 Then 'Dokument wewnętrzny sprzedaży'
     When 345 Then 'Tax Free'
     When 350 Then 'Faktura RR'
     Else '' End
    From CDN.TraNag Where TrN_TrNId = @Id
   If @Tryb = 'VaN'
    Select @Wynik =
    Case VaN_Typ
     When 1 Then 'Rejestr zakupów VAT'
     When 2 Then 'Rejestr sprzedaży VAT'
     Else '' End
    From CDN.VatNag Where VaN_VaNId = @Id
   If @Tryb = 'BDN'
    Select @Wynik =
    Case BDN_Typ
     When 222 Then 'Ponaglenie zapłaty'
     When 223 Then 'Potwierdzenie salda'
     Else '' End
    From CDN.BnkDokNag Where BDN_BDNId = @Id
   If @Tryb = 'DkN'
    Select @Wynik = '' +
    Case DkN_TypDeklar
     When 1 Then Case When DkN_Wersja < 21 Then 'Deklaracja VAT-7' Else 'JPK-V7' End
     When 2 Then Case When DkN_Wersja < 16 Then 'Deklaracja PIT-5' Else 'Zaliczka PIT-36' End
     When 3 Then Case When DkN_Wersja < 18 Then 'Deklaracja PIT-4' Else 'Zaliczka PIT-4R' End
     When 4 Then 'Zaliczka na podatek ryczałtowy'
     When 5 Then 'Deklaracja PIT-11'
     When 6 Then Case When DkN_RokMiesiac < '200701' Then 'Deklaracja PIT-8A' Else 'Zaliczka PIT-8AR' End
     When 7 Then 'Deklaracja PIT-8B'
     When 8 Then Case When DkN_Wersja < 18 Then 'Deklaracja CIT-2' Else 'Zaliczka CIT-8' End
     When 9 Then 'Deklaracja PIT-40'
     When 10 Then 'Deklaracja IFT-1'
     When 24 Then 'Deklaracja IFT-1R'
     When 11 Then 'Deklaracja VAT-UE'
     When 12 Then Case When DkN_Wersja < 4 Then 'Deklaracja PIT-5L' Else 'Zaliczka PIT-36L' End
     When 13 Then 'Deklaracja VAT-UE/A'
     When 14 Then 'Deklaracja VAT-UE/B'
     When 15 Then 'Deklaracja PIT-36'
     When 16 Then 'Deklaracja PIT-36L'
     When 17 Then 'Deklaracja CIT-8'
     When 18 Then 'Deklaracja PIT-4R'
     When 19 Then 'Deklaracja PIT-8AR'
     When 20 Then 'Deklaracja PIT-28'
     When 21 Then 'Deklaracja PIT-8C'
     When 22 Then 'Deklaracja VAT-UEK'
     When 23 Then 'Deklaracja VAT-UE/C'
     When 25 Then 'Deklaracja PIT/B'
     When 26 Then 'Deklaracja PIT-28/B'
     When 27 Then 'Deklaracja PIT-O'
  When 28 Then 'Deklaracja CIT-D'
  When 29 Then 'Deklaracja CIT-ST'
  When 30 Then 'Deklaracja CIT-ST/A'
  When 33 Then 'Deklaracja VAT-27'
  When 35 Then 'Deklaracja PIT-37'
  When 36 Then 'Deklaracja PIT-ZG'
  When 37 Then 'Deklaracja PIT-Z'
  When 40 Then 'Zaliczka uproszczona CIT-8'
  When 41 Then 'Zaliczka uproszczona PIT-36'
  When 42 Then 'Zaliczka uproszczona PIT-36L'
  When 43 Then 'Deklaracja VAT-8'
     When 100 Then 'Deklaracja ZUS ZUA'
     When 101 Then 'Deklaracja ZUS ZIUA'
     When 102 Then 'Deklaracja ZUS ZCNA'
     When 103 Then 'Deklaracja ZUS ZCZA'
     When 104 Then 'Deklaracja ZUS ZWUA'
     When 105 Then 'Deklaracja ZUS ZZA'
  When 106 Then 'Deklaracja ZUS ZSWA'
     When 110 Then 'Deklaracja ZUS ZPA'
     When 111 Then 'Deklaracja ZUS ZFA'
     When 112 Then 'Deklaracja ZUS ZIPA'
     When 113 Then 'Deklaracja ZUS ZWPA'
     When 114 Then 'Deklaracja ZUS ZBA'
     When 115 Then 'Deklaracja ZUS ZAA'
     When 120 Then 'Deklaracja DRA'
     When 121 Then 'Deklaracja ZUS RCA'
     When 122 Then 'Deklaracja ZUS RNA'
     When 123 Then 'Deklaracja ZUS RZA'
     When 124 Then 'Deklaracja ZUS RSA'
     When 125 Then 'Deklaracja ZUS RGA'
     When 130 Then 'Deklaracja IWA'
     When 300 Then 'Deklaracja PFRON INFD'
     When 301 Then 'Deklaracja PFRON INFDP'
     When 302 Then 'Deklaracja PFRON INFDZ'
     When 303 Then 'Deklaracja PFRON WND'
     When 310 Then 'Deklaracja PFRON WN-D'
     When 320 Then 'Deklaracja PFRON WN-U'
  When 401 Then 'Deklaracja AKC-WW'
  When 402 Then 'VAT-ZD zakup'
  When 403 Then 'Deklaracja VAT-ZD'
  When 404 Then 'Deklaracja VAT-9M'
  When 500 Then 'Deklaracja PPK'
     Else 'Deklaracja ???' End
    From CDN.DeklNag Where DkN_DkNId = @Id
   If @Tryb = 'SrH'
    Select @Wynik =
    Case SrH_TypDokumentu
     When 1 Then 'Ulepszenie'
     When 2 Then 'Przeszacownie'
     When 3 Then 'Amortyzacja'
     When 4 Then 'Otrzymanie'
     When 5 Then 'Likwidacja'
     When 6 Then 'Przekazanie'
     Else '' End
    + ' ' + Case SrH_Typ
     When 11 Then 'S.T.'
     When 12 Then 'W.N.P.'
     Else '' End
    From CDN.TrwaleHist Where SrH_SrHId = @Id
   If @Tryb = 'BRp'
    Select @Wynik =
     Case BRa_Typ When 1 Then 'Raport kasowy' Else 'Wyciąg bankowy' End
    From CDN.BnkRachunki Join CDN.BnkRaporty On BRa_BRaId = BRp_BRaId Where BRp_BRpId = @Id
   If @Tryb = 'BZp'
      Select @Wynik =
      Case BRa_Typ When 1 Then 'Pozycje raportu kasowego' Else 'Pozycje wyciągu bankowego' End
      From CDN.BnkRachunki Join CDN.BnkZapisy On BRa_BRaId = BZp_BRaId Where BZp_BZpId = @Id
   If @Tryb = 'LPL'
    Set @Wynik = 'Lista płac'
   If @Tryb = 'WPL_E'
    Set @Wynik = 'Wypłaty pracowników - etaty'
   If @Tryb = 'WPL_U'
    Set @Wynik = 'Wypłaty pracowników - umowy'
   If @Tryb = 'WPL_P'
    Set @Wynik = 'Wypłaty pracowników - pozostałe'
   If @Tryb = 'WPL_W'
    Set @Wynik = 'Wypłaty właścicieli'
   If @Tryb = 'NON'
    Set @Wynik = 'Nota odsetkowa'
   If @Tryb = 'EDN'
      Select Top 1 @Wynik =
      Case EDN_Typ When 101 Then 'Ewidencja dodatkowa przychodów' Else 'Ewidencja dodatkowa kosztów' End
      From CDN.EwidDodNag Where EDN_EDNId = @Id
   If @Tryb = 'BRK'
    Set @Wynik = 'Rozliczenie'
   If @Tryb = 'RKUR'
    Set @Wynik = 'Różnica kursowa'
   If @Tryb = 'RKURMW'
    Set @Wynik = 'Różnica kursowa magazynu walut'
   If @Tryb = 'AuR'
    Set @Wynik = 'Rozliczenia samochodu'
   If @Tryb = 'ReN'
    Set @Wynik = 'Remanent'
   If @Tryb = 'WyN'
    Set @Wynik = 'Ewidencja wynagrodzeń'
   If @Tryb = 'BZd'
    Set @Wynik = 'Płatności'
   If @Tryb = 'Dlg'
    Set @Wynik = 'Delegacje'
   If @Tryb = 'PWN'
    Set @Wynik = 'Przeszacowanie walut'
   If @Tryb = 'KPN'
    Set @Wynik = 'Kompensata'
   If @Tryb = 'Zapis kasa/bank'
    Set @Wynik = 'Zapis kasa/bank'
   If @Tryb = 'KDN'
      Select Top 1 @Wynik =
      Case KDN_Typ When 111 Then 'Potwierdzenie salda KH' When 112 Then 'Ponaglenie zapłaty KH' When 113 Then 'Nota odsetkowa KH' End
      From CDN.KsiDokNag Where KDN_KDNId = @Id
 Return @Wynik
 End
