Create Function CDN.KwotaPlatnosciPojedynczyDokument (@DokTyp Int, @DokId Int, @Tryb NVARCHAR(20))
Returns Numeric (15,2)
As
Begin
 Declare @Wynik Numeric(15,2)
 Declare @ZalTyp Int, @ZalId Int
 If @Tryb = 'Razem'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (BZd_KwotaSys * BZd_Kierunek) From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId Where TrN_VaNId = @DokId
  Else
    Select @Wynik = Sum (BZd_KwotaSys * BZd_Kierunek) From CDN.BnkZdarzenia Where IsNull(BZd_KomornikZajecieWynagr, 0) = 0 and BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId
   End
 Else If @Tryb = 'RazemWal'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (BZd_Kwota * BZd_Kierunek) From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId Where TrN_VaNId = @DokId
  Else
    Select @Wynik = Sum (BZd_Kwota * BZd_Kierunek) From CDN.BnkZdarzenia Where IsNull(BZd_KomornikZajecieWynagr, 0) = 0 and BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId
   End
 Else If @Tryb = 'Rozliczona'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (BZd_KwotaRozSys * BZd_Kierunek) From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId Where TrN_VaNId = @DokId
  Else
    Select @Wynik = Sum (BZd_KwotaRozSys * BZd_Kierunek) From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId
   End
 Else If @Tryb = 'RozliczonaWal'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (BZd_KwotaRoz * BZd_Kierunek) From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId Where TrN_VaNId = @DokId
  Else
    Select @Wynik = Sum (BZd_KwotaRoz * BZd_Kierunek) From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId
   End
 Else If @Tryb ='RozliczonaAuto'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (Case When BRK_LDokTyp=1 And BRK_LDokID=BZd_BZdId Then BZd_Kierunek*BRK_KwotaSysL Else BZd_Kierunek*BRK_KwotaSysP End) From
    CDN.BnkZdarzenia
    Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId
    Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
    Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
    Join CDN.BnkZapisy     On BZp_BZpId = BRR_DDokId And 2 = BRR_DDokTyp
    Where TrN_VaNId = @DokId And BZp_ZapisAutomatyczny = 1
  Else
    Select @Wynik = Sum (Case When BRK_LDokTyp=1 And BRK_LDokID=BZd_BZdId Then BZd_Kierunek*BRK_KwotaSysL Else BZd_Kierunek*BRK_KwotaSysP End) From
    CDN.BnkZdarzenia
    Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
    Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
    Join CDN.BnkZapisy     On BZp_BZpId = BRR_DDokId And 2 = BRR_DDokTyp
    Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId And BZp_ZapisAutomatyczny = 1
   End
 Else If @Tryb ='RozliczonaAutoWal'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (BZd_Kierunek*BRK_Kwota) From
    CDN.BnkZdarzenia
    Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId
    Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
    Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
    Join CDN.BnkZapisy     On BZp_BZpId = BRR_DDokId And 2 = BRR_DDokTyp
    Where TrN_VaNId = @DokId And BZp_ZapisAutomatyczny = 1
  Else
    Select @Wynik = Sum (BZd_Kierunek*BRK_Kwota) From
    CDN.BnkZdarzenia
    Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
    Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
    Join CDN.BnkZapisy     On BZp_BZpId = BRR_DDokId And 2 = BRR_DDokTyp
    Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId And BZp_ZapisAutomatyczny = 1
   End
 Else If @Tryb = 'Pozostaje'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum ((BZd_KwotaSys - BZd_KwotaRozSys)*BZd_Kierunek) From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId Where TrN_VaNId = @DokId
  Else
    Select @Wynik = Sum ((BZd_KwotaSys - BZd_KwotaRozSys)*BZd_Kierunek) From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId
   End
 Else If @Tryb = 'PozostajeWal'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum ((BZd_Kwota - BZd_KwotaRoz)*BZd_Kierunek) From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId Where TrN_VaNId = @DokId
  Else
    Select @Wynik = Sum ((BZd_Kwota - BZd_KwotaRoz)*BZd_Kierunek) From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId
   End
 Else If @Tryb ='Zaliczka'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (Case When BRK_LDokTyp=1 And BRK_LDokID=BZd_BZdId Then BZd_Kierunek*BRK_KwotaSysL Else BZd_Kierunek*BRK_KwotaSysP End) From
    CDN.BnkZdarzenia
    Join CDN.TraNag        On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId
    Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
    Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
    Join CDN.BnkZapisy     On BZp_BZpId = BRR_DDokId And 2 = BRR_DDokTyp
    Where TrN_VaNId = @DokId And BZp_PodmiotTyp = TrN_PodmiotZalTyp And BZp_PodmiotId = TrN_PodZalId
  Else
    Begin
   Set @ZalTyp = Null
   Set @ZalId  = Null
   If @DokTyp = 1
     Select @ZalTyp = TrN_PodmiotZalTyp, @ZalId = TrN_PodZalId From CDN.TraNag Where TrN_TrNId = @DokId
   Else If @DokTyp = 2
     Select @ZalTyp = VaN_PodmiotZalTyp, @ZalId = VaN_PodZalId From CDN.VatNag Where VaN_VaNId = @DokId
   Else If @DokTyp = 12
     Select @ZalTyp = EDN_PodmiotZalTyp, @ZalId = EDN_PodZalId From CDN.EwidDodNag Where EDN_EDNId = @DokId
   Select @Wynik = Sum (Case When BRK_LDokTyp=1 And BRK_LDokID=BZd_BZdId Then BZd_Kierunek*BRK_KwotaSysL Else BZd_Kierunek*BRK_KwotaSysP End) From
   CDN.BnkZdarzenia
   Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
   Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
   Join CDN.BnkZapisy     On BZp_BZpId = BRR_DDokId And 2 = BRR_DDokTyp
   Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId And BZp_PodmiotTyp = @ZalTyp And BZp_PodmiotId = @ZalId
    End
   End
 Else If @Tryb ='ZaliczkaWal'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (BZd_Kierunek*BRK_Kwota) From
    CDN.BnkZdarzenia
    Join CDN.TraNag        On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId
    Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
    Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
    Join CDN.BnkZapisy     On BZp_BZpId = BRR_DDokId And 2 = BRR_DDokTyp
    Where TrN_VaNId = @DokId And BZp_PodmiotTyp = TrN_PodmiotZalTyp And BZp_PodmiotId = TrN_PodZalId
  Else
    Begin
   Set @ZalTyp = Null
   Set @ZalId  = Null
   If @DokTyp = 1
     Select @ZalTyp = TrN_PodmiotZalTyp, @ZalId = TrN_PodZalId From CDN.TraNag Where TrN_TrNId = @DokId
   Else If @DokTyp = 2
     Select @ZalTyp = VaN_PodmiotZalTyp, @ZalId = VaN_PodZalId From CDN.VatNag Where VaN_VaNId = @DokId
   Else If @DokTyp = 12
     Select @ZalTyp = EDN_PodmiotZalTyp, @ZalId = EDN_PodZalId From CDN.EwidDodNag Where EDN_EDNId = @DokId
   Select @Wynik = Sum (BZd_Kierunek*BRK_Kwota) From
   CDN.BnkZdarzenia
   Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
   Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
   Join CDN.BnkZapisy     On BZp_BZpId = BRR_DDokId And 2 = BRR_DDokTyp
   Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId And BZp_PodmiotTyp = @ZalTyp And BZp_PodmiotId = @ZalId
    End
   End
 Else If @Tryb = 'Kierunek'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select Top 1 @Wynik = BZd_Kierunek From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId Where TrN_VaNId = @DokId
  Else
    Select Top 1 @Wynik = BZd_Kierunek From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId
   End
 Else If @Tryb = 'Przelew'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (BZd_Kierunek*BZd_KwotaSys) From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId
    Join CDN.FormyPlatnosci On FPl_FPlId = BZd_FPlId
    Where TrN_VaNId = @DokId And FPl_Typ = 2
  Else
    Select @Wynik = Sum (BZd_KwotaSys) From CDN.BnkZdarzenia
    Join CDN.FormyPlatnosci On FPl_FPlId = BZd_FPlId
    Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId  And FPl_Typ = 2 And IsNull(BZd_KomornikZajecieWynagr, 0) = 0 And IsNull(BZd_KomornikZajecieWynagr, 0) = 0
   End
 Else If @Tryb = 'PrzelewWal'
   Begin
  If @DokTyp = 2 And Exists (Select * From CDN.VatNag Where VaN_VaNId = @DokId And VaN_TrNId Is Not Null)
    Select @Wynik = Sum (BZd_Kierunek*BZd_Kwota) From CDN.BnkZdarzenia Join CDN.TraNag On 1 = BZd_DokumentTyp And TrN_TrNId = BZd_DokumentId
    Join CDN.FormyPlatnosci On FPl_FPlId = BZd_FPlId
    Where TrN_VaNId = @DokId And FPl_Typ = 2
  Else
    Select @Wynik = Sum (BZd_Kwota) From CDN.BnkZdarzenia
    Join CDN.FormyPlatnosci On FPl_FPlId = BZd_FPlId
    Where BZd_DokumentTyp = @DokTyp And BZd_DokumentId = @DokId  And FPl_Typ = 2 And IsNull(BZd_KomornikZajecieWynagr, 0) = 0
   End
 Else
   Set @Wynik = Null
 Return IsNull(@Wynik,0)
End
