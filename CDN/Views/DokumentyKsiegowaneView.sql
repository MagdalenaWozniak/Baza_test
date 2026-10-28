Create View CDN.DokumentyKsiegowaneView
As
Select
 DKs_Typ = 1,
 DKs_DKsId  = TrN_TrNId,
 DKs_DekId  = TrN_DekId,
 DKs_KPRId  = Null,
 DKs_RycId  = Null,
 DKs_TypStr = Case TrN_TypDokumentu
  When 301 Then 'Faktura zakupu'
  When 302 Then 'Faktura sprzedaży'
  When 303 Then 'Przyjęcie wewnętrzne'
  When 304 Then 'Rozchód wewnętrzny'
  When 305 Then 'Paragon'
  When 306 Then 'Wydanie zewnętrzne'
  When 307 Then 'Przyjęcie zewnętrzne'
  When 309 Then 'Zamówienie u dostawcy'
  When 310 Then 'Bilans magazynu'
  When 311 Then 'Arkusz Inwentaryzacyjny'
  When 312 Then 'Przesunięcie MM'
  When 313 Then 'Przyjęcie kaucji'
  When 314 Then 'Wydanie kaucji'
  When 317 Then 'Przyjęcie wewnętrzne produktów'
  When 318 Then 'Rozchód wewnętrzny składników'
  When 320 Then 'Faktura pro-forma'
  When 321 Then 'Faktura wewnętrzna zakupu'
  When 322 Then 'Faktura wewnętrzna sprzedaży'
  When 345 Then 'Tax-Free'
  Else '' End,
 DKs_Numer = Case When TrN_NumerObcy<>'' And TrN_TypDokumentu Not In (321,322) Then TrN_NumerObcy Else TrN_NumerPelny End,
 DKs_Data = TrN_DataDok,
 DKs_Kwota = TrN_RazemBrutto
From CDN.TraNag
Union All
Select
 DKs_Typ = 2,
 DKs_DKsId  = VaN_VaNId,
 DKs_DekId  = VaN_DekId,
 DKs_KPRId  = VaN_KPRId,
 DKs_RycId  = VaN_RycId,
 DKs_TypStr = Case VaN_Typ
  When 1 Then 'Rejestr zakupów VAT'
  When 2 Then 'Rejestr sprzedaży VAT'
  Else '' End,
 DKs_Numer = VaN_Dokument,
 DKs_Data = VaN_DataZap,
 DKs_Kwota = VaN_RazemBrutto
From CDN.VatNag
Union All
Select
 DKs_Typ = 3,
 DKs_DKsId  = AuR_AuRId,
 DKs_DekId  = AuR_DekId,
 DKs_KPRId  = AuR_KPRId,
 DKs_RycId  = Null,
 DKs_TypStr = 'Rozliczenie samochodu',
 DKs_Numer = AuE_Rejestracja + '/' + Substring(LTrim(Str(AuR_RokMies)),1,4)+ '/' + Substring(LTrim(Str(AuR_RokMies)),5,2),
 DKs_Data = CDN.EoMonth(AuR_RokMies),
 DKs_Kwota = AuR_KsiegMiesiac
From CDN.AutoEwid Join CDN.AutoRozlicz On AuE_AuEId = AuR_AuEId
Union All
Select
 DKs_Typ = 5,
 DKs_DKsId  = WyN_WyNId,
 DKs_DekId  = WyN_DekId,
 DKs_KPRId  = WyN_KPRId,
 DKs_RycId  = Null,
 DKs_TypStr = 'Ewidencja wynagrodzeń',
 DKs_Numer = 'PŁACE/' + Substring(LTrim(Str(WyN_RokMies)),1,4)+ '/' + Substring(LTrim(Str(WyN_RokMies)),5,2),
 DKs_Data = WyN_DataWyp,
 DKs_Kwota = WyN_BruttoRazem
From CDN.WyplatyNag
Union All
Select
 DKs_Typ = 6,
 DKs_DKsId  = DkN_DkNId,
 DKs_DekId  = DkN_DekId,
 DKs_KPRId  = Null,
 DKs_RycId  = Null,
 DKs_TypStr = 'Deklaracja',
 DKs_Numer = CDN.DeklNumer(DkN_DkNId),
 DKs_Data = CDN.DeklTermin(DkN_DkNId),
 DKs_Kwota = DkN_Kwota
From CDN.DeklNag
Union All
Select
 DKs_Typ = 7,
 DKs_DKsId  = SrH_SrHId,
 DKs_DekId  = SrH_DekId,
 DKs_KPRId  = SrH_KPRId,
 DKs_RycId  = Null,
 DKs_TypStr = Case SrH_TypDokumentu
  When 1 Then 'Ulepszenie ST'
  When 2 Then 'Przeszacownie'
  When 3 Then 'Amortyzacja'
  When 4 Then 'Otrzymanie ST'
  When 5 Then 'Likwidacja ST'
  Else '' End,
 DKs_Numer = SrH_Numer,
 DKs_Data = SrH_DataOpe,
 DKs_Kwota = Case SrH_TypDokumentu When 3 Then SrH_KwotaAm Else SrH_KwotaKoszt End
From CDN.TrwaleHist
Union All
Select
 DKs_Typ = 9,
 DKs_DKsId  = BRp_BRpId,
 DKs_DekId  = BRp_DekId,
 DKs_KPRId  = Null,
 DKs_RycId  = Null,
 DKs_TypStr = Case BRa_Typ When 1 Then 'Raport kasowy' Else 'Wyciąg bankowy' End,
 DKs_Numer = Case When BRp_NumerObcy<>'' Then BRp_NumerObcy Else BRp_NumerPelny End,
 DKs_Data = BRp_DataZam,
 DKs_Kwota = BRp_PrzychodySys - BRp_RozchodySys
From CDN.BnkRaporty Join CDN.BnkRachunki On BRp_BRaId = BRa_BRaId
Union All
Select
 DKs_Typ = 10,
 DKs_DKsId  = WPL_WPLId,
 DKs_DekId  = LPL_DekId,
 DKs_KPRId  = LPL_KPRId,
 DKs_RycId  = Null,
 DKs_TypStr = 'Wypłata',
 DKs_Numer = WPL_NumerPelny,
 DKs_Data = WPL_DataDok,
 DKs_Kwota = WPL_Wartosc
From CDN.Wyplaty Join CDN.ListyPlac On LPL_LPLId = WPL_LPLId
Union All
Select
 DKs_Typ = 11,
 DKs_DKsId  = NON_NONId,
 DKs_DekId  = NON_DekId,
 DKs_KPRId  = Null,
 DKs_RycId  = Null,
 DKs_TypStr = 'Nota odsetkowa',
 DKs_Numer = NON_NumerPelny,
 DKs_Data = NON_DataDok,
 DKs_Kwota = NON_RazemOdsetki
From CDN.NotyOdsNag
Union All
Select
 DKs_Typ = 12,
 DKs_DKsId  = EDN_EDNId,
 DKs_DekId  = EDN_DekId,
 DKs_KPRId  = EDN_KPRId,
 DKs_RycId  = EDN_RycId,
 DKs_TypStr = Case EDN_Typ When 101 Then 'Ewidencja dodatkowa przychodów' Else 'Ewidencja dodatkowa kosztów' End,
 DKs_Numer = Case When EDN_NumerObcy<>'' Then EDN_NumerObcy Else EDN_NumerPelny End,
 DKs_Data = EDN_DataDok,
 DKs_Kwota = EDN_KwotaRazemSys
From CDN.EwidDodNag
Union All
Select
 DKs_Typ = 13,
 DKs_DKsId  = BRK_BRKId,
 DKs_DekId  = BRK_DekId,
 DKs_KPRId  = BRK_KPRId,
 DKs_RycId  = Null,
 DKs_TypStr = 'Różnica kursowa',
 DKs_Numer = BRK_NumerPelny,
 DKs_Data = BRK_DataDok,
 DKs_Kwota = BRK_RoznicaKursowaSys
From CDN.BnkRozKwoty
Union All
Select
 DKs_Typ    = 18,
 DKs_DKsId  = BRKV_BRKId,
 DKs_DekId  = BRKV_Dek2Id,
 DKs_KPRId  = Null,
 DKs_RycId  = Null,
 DKs_TypStr = 'Rozliczenie',
 DKs_Numer  = BRKV_Numer1,
 DKs_Data   = BRK_DataDok,
 DKs_Kwota  = BRKV_KwotaSys1
From CDN.BnkRozKwoty Join CDN.BnkRozKwotyView On BRK_BRKId = BRKV_BRKId
Union All
Select
 DKs_Typ   = 41,
 DKs_DKsId  = PWN_PWNID,
 DKs_DekId  = PWN_DekID,
 DKs_KPRId  = NULL,
 DKs_RycId  = Null,
 DKs_TypStr = 'Przeszacowanie walut',
 DKs_Numer  = PWN_Numer,
 DKs_Data   = PWN_DataDok,
 DKs_Kwota  = 0.00
From CDN.PrzeszacWalutNag where PWN_DekID is not NULL
Union All
Select
 DKs_Typ   = 42,
 DKs_DKsId  = PWN_PWNID,
 DKs_DekId  = PWN_NextDekID,
 DKs_KPRId  = NULL,
 DKs_RycId  = Null,
 DKs_TypStr = 'Przeszacowanie walut',
 DKs_Numer  = PWN_Numer,
 DKs_Data   = PWN_DataDok,
 DKs_Kwota  = 0.00
From CDN.PrzeszacWalutNag where PWN_NextDekID is not NULL
Union All
Select
 DKs_Typ   = 43,
 DKs_DKsId  = BRKMW_BRKMWID,
 DKs_DekId  = BRKMW_DekId,
 DKs_KPRId  = NULL,
 DKs_RycId  = Null,
 DKs_TypStr = 'Różnica kursowa MW',
 DKs_Numer  = BRKMW_NumerPelny,
 DKs_Data   = BRKMW_DataDok,
 DKs_Kwota  = BRKMW_RoznicaKursowaSys
From CDN.BnkRozKwotyMW where BRKMW_DekId is not NULL
Union All
Select
 DKs_Typ   = 49,
 DKs_DKsId  = KDN_KDNID,
 DKs_DekId  = KDN_DekId,
 DKs_KPRId  = NULL,
 DKs_RycId  = Null,
 DKs_TypStr = 'Nota odsetkowa KH',
 DKs_Numer  = KDN_NumerPelny,
 DKs_Data   = KDN_DataDok,
 DKs_Kwota  = KDN_RazemKwota2
From CDN.KsiDokNag where KDN_DekId is not NULL
Union All
Select
 DKs_Typ  = 50,
 DKs_DKsId  = KPN_KPNID,
 DKs_DekId  = KPN_DekId,
 DKs_KPRId  = NULL,
 DKs_RycId  = Null,
 DKs_TypStr = 'Kompensata',
 DKs_Numer  = KPN_NumerPelny,
 DKs_Data   = KPN_DataDok,
 DKs_Kwota  = KPN_RazemKwotaRoz
From CDN.KompensatyNag where KPN_DekId is not NULL
Union All
Select
 DKs_Typ  = 108,
 DKs_DKsId  = DLN_DLNID,
 DKs_DekId  = DLN_DekId,
 DKs_KPRId  = NULL,
 DKs_RycId  = Null,
 DKs_TypStr = 'Delegacja',
 DKs_Numer  = DLN_NumerPelny,
 DKs_Data   = DLN_DataDok,
 DKs_Kwota  = DLN_KwotaSys
From CDN.DlgNag where DLN_DekId is not NULL
Union All
Select
 DKs_Typ   = 222,
 DKs_DKsId  = BDN_BDNID,
 DKs_DekId  = BDN_DekID,
 DKs_KPRId  = NULL,
 DKs_RycId  = Null,
 DKs_TypStr = 'Ponaglenie zapłaty',
 DKs_Numer  = BDN_NumerPelny,
 DKs_Data   = BDN_DataDok,
 DKs_Kwota  = BDN_RazemKwota2
From CDN.BnkDokNag where BDN_DekID is not NULL
