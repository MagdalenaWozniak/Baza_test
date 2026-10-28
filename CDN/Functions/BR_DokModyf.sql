CREATE Function CDN.BR_DokModyf(@DataOd DateTime, @DataDo DateTime)
Returns Table
Return (
  Select Status = 0, Rodzaj=CDN.KsiegTypZrodla('AuR', AuR_AuRId), OpeId = AuR_OpeZalId, Liczba = Count(*), OpeModId = '', LiczbaW = 0
  From CDN.AutoRozlicz
  Where AuR_TS_Zal Between @DataOd And @DataDo + 1 And (AuR_OpeZalId = AuR_OpeModId And AuR_TS_Zal = AuR_TS_Mod)
  Group By CDN.KsiegTypZrodla('AuR', AuR_AuRId), AuR_OpeZalId, AuR_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('AuR', AuR_AuRId), AuR_OpeZalId, Count(*), AuR_OpeModId, Count(*)
  From CDN.AutoRozlicz
  Where AuR_TS_Zal Between @DataOd And @DataDo + 1 And (AuR_OpeZalId = AuR_OpeModId And AuR_TS_Zal <> AuR_TS_Mod)
  Group By CDN.KsiegTypZrodla('AuR', AuR_AuRId), AuR_OpeZalId, AuR_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('AuR', AuR_AuRId), AuR_OpeZalId, Count(*), AuR_OpeModId, Count(*)
  From CDN.AutoRozlicz
  Where AuR_TS_Zal Between @DataOd And @DataDo + 1 And (AuR_OpeZalId <> AuR_OpeModId And AuR_TS_Zal <> AuR_TS_Mod)
  Group By CDN.KsiegTypZrodla('AuR', AuR_AuRId), AuR_OpeZalId, AuR_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('VaN', VaN_VaNId), OpeId = VaN_OpeZalId, Count(*), '', 0
  From CDN.VatNag
  Where VaN_TS_Zal Between @DataOd And @DataDo + 1 And (VaN_OpeZalId = VaN_OpeModId And VaN_TS_Zal = VaN_TS_Mod)
  Group By CDN.KsiegTypZrodla('VaN', VaN_VaNId), VaN_OpeZalId, VaN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('VaN', VaN_VaNId), OpeId = VaN_OpeZalId, Count(*), OpeModId = VaN_OpeModId, Count(*)
  From CDN.VatNag
  Where VaN_TS_Zal Between @DataOd And @DataDo + 1 And (VaN_OpeZalId = VaN_OpeModId And VaN_TS_Zal <> VaN_TS_Mod)
  Group By CDN.KsiegTypZrodla('VaN', VaN_VaNId), VaN_OpeZalId, VaN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('VaN', VaN_VaNId), OpeId = VaN_OpeZalId, Count(*), OpeModId = VaN_OpeModId, Count(*)
  From CDN.VatNag
  Where VaN_TS_Zal Between @DataOd And @DataDo + 1 And (VaN_OpeZalId <> VaN_OpeModId And VaN_TS_Zal <> VaN_TS_Mod)
  Group By CDN.KsiegTypZrodla('VaN', VaN_VaNId), VaN_OpeZalId, VaN_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('BZp', BZp_BZpId), BZp_OpeZalId, Count(*), '', 0
  From CDN.BnkZapisy Join CDN.BnkRaporty On BZp_BRpId = BRp_BRpId
  Where BZp_TS_Zal Between @DataOd And @DataDo + 1 And (BZp_OpeZalId = BZp_OpeModId And BZp_TS_Zal = BZp_TS_Mod)
  Group By BZp_OpeZalId, CDN.KsiegTypZrodla('BZp', BZp_BZpId), BZp_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('BZp', BZp_BZpId), BZp_OpeZalId, Count(*), BZp_OpeModId, Count(*)
  From CDN.BnkZapisy Join CDN.BnkRaporty On BZp_BRpId = BRp_BRpId
  Where BZp_TS_Zal Between @DataOd And @DataDo + 1 And (BZp_OpeZalId = BZp_OpeModId And BZp_TS_Zal <> BZp_TS_Mod)
  Group By BZp_OpeZalId, CDN.KsiegTypZrodla('BZp', BZp_BZpId), BZp_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('BZp', BZp_BZpId), BZp_OpeZalId, Count(*), BZp_OpeModId, Count(*)
  From CDN.BnkZapisy Join CDN.BnkRaporty On BZp_BRpId = BRp_BRpId
  Where BZp_TS_Zal Between @DataOd And @DataDo + 1 And (BZp_OpeZalId <> BZp_OpeModId And BZp_TS_Zal <> BZp_TS_Mod)
  Group By BZp_OpeZalId, CDN.KsiegTypZrodla('BZp', BZp_BZpId), BZp_OpeModId
  Union All
  Select 0, CDN.KsiegTypZrodla('KPN', KPN_KPNId), KPN_OpeZalId, Count(*), '', 0
  From CDN.KompensatyNag
  Where KPN_TS_Zal Between @DataOd And @DataDo + 1 And (KPN_OpeZalId = KPN_OpeModId And KPN_TS_Zal = KPN_TS_Mod)
  Group By KPN_OpeZalId, CDN.KsiegTypZrodla('KPN', KPN_KPNId), KPN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('KPN', KPN_KPNId), KPN_OpeZalId, Count(*), KPN_OpeModId, Count(*)
  From CDN.KompensatyNag
  Where KPN_TS_Zal Between @DataOd And @DataDo + 1 And (KPN_OpeZalId = KPN_OpeModId And KPN_TS_Zal <> KPN_TS_Mod)
  Group By KPN_OpeZalId, CDN.KsiegTypZrodla('KPN', KPN_KPNId), KPN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('KPN', KPN_KPNId), KPN_OpeZalId, Count(*), KPN_OpeModId, Count(*)
  From CDN.KompensatyNag
  Where KPN_TS_Zal Between @DataOd And @DataDo + 1 And (KPN_OpeZalId <> KPN_OpeModId And KPN_TS_Zal <> KPN_TS_Mod)
  Group By KPN_OpeZalId, CDN.KsiegTypZrodla('KPN', KPN_KPNId), KPN_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('RKUR', BRK_BRKId), BRK_OpeZalId, Count(*), '', 0
  From CDN.BnkRozKwoty
  Where BRK_RoznicaKursowaSys <> 0 And BRK_TS_Zal Between @DataOd And @DataDo +1 And (BRK_OpeZalId = BRK_OpeModId And BRK_TS_Zal = BRK_TS_Mod)
  Group By BRK_OpeZalId, CDN.KsiegTypZrodla('RKUR', BRK_BRKId), BRK_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('RKUR', BRK_BRKId), BRK_OpeZalId, Count(*), BRK_OpeModId, Count(*)
  From CDN.BnkRozKwoty
  Where BRK_RoznicaKursowaSys <> 0 And BRK_TS_Zal Between @DataOd And @DataDo +1 And (BRK_OpeZalId = BRK_OpeModId And BRK_TS_Zal <> BRK_TS_Mod)
  Group By BRK_OpeZalId, CDN.KsiegTypZrodla('RKUR', BRK_BRKId), BRK_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('RKUR', BRK_BRKId), BRK_OpeZalId, Count(*), BRK_OpeModId, Count(*)
  From CDN.BnkRozKwoty
  Where BRK_RoznicaKursowaSys <> 0 And BRK_TS_Zal Between @DataOd And @DataDo +1 And (BRK_OpeZalId <> BRK_OpeModId And BRK_TS_Zal <> BRK_TS_Mod)
  Group By BRK_OpeZalId, CDN.KsiegTypZrodla('RKUR', BRK_BRKId), BRK_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('RKURMW', BRKMW_BRKMWId), BRKMW_OpeZalId, Count(*), '', 0
  From CDN.BnkRozKwotyMW
  Where BRKMW_RoznicaKursowaSys <> 0 And BRKMW_TS_Zal Between @DataOd And @DataDo +1 And (BRKMW_OpeZalId = BRKMW_OpeModId And BRKMW_TS_Zal = BRKMW_TS_Mod)
  Group By BRKMW_OpeZalId, CDN.KsiegTypZrodla('RKURMW', BRKMW_BRKMWId), BRKMW_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('RKURMW', BRKMW_BRKMWId), BRKMW_OpeZalId, Count(*), BRKMW_OpeModId, Count(*)
  From CDN.BnkRozKwotyMW
  Where BRKMW_RoznicaKursowaSys <> 0 And BRKMW_TS_Zal Between @DataOd And @DataDo +1 And (BRKMW_OpeZalId = BRKMW_OpeModId And BRKMW_TS_Zal <> BRKMW_TS_Mod)
  Group By BRKMW_OpeZalId, CDN.KsiegTypZrodla('RKURMW', BRKMW_BRKMWId), BRKMW_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('RKURMW', BRKMW_BRKMWId), BRKMW_OpeZalId, Count(*), BRKMW_OpeModId, Count(*)
  From CDN.BnkRozKwotyMW
  Where BRKMW_RoznicaKursowaSys <> 0 And BRKMW_TS_Zal Between @DataOd And @DataDo +1 And (BRKMW_OpeZalId <> BRKMW_OpeModId And BRKMW_TS_Zal <> BRKMW_TS_Mod)
  Group By BRKMW_OpeZalId, CDN.KsiegTypZrodla('RKURMW', BRKMW_BRKMWId), BRKMW_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('DkN', DkN_DkNId), DkN_OpeZalId, Count(*), '', 0
  From CDN.DeklNag Left Outer Join CDN.DeklElem On DkE_DkNId = DkN_DkNId And (DkN_TypDeklar In (5,7) And DkE_Numer = 100005 Or DkN_TypDeklar In (9) And DkE_Numer = 300202 Or DkN_TypDeklar In (10) And DkE_Numer = 350104)
  Where DkN_TS_Zal Between @DataOd And @DataDo + 1 And (DkN_OpeZalId = DkN_OpeModId And DkN_TS_Zal = DkN_TS_Mod) And DkN_TypDeklar Not In (311,321,25,26,27,28,29,30,36,37)
  Group By DkN_OpeZalId, CDN.KsiegTypZrodla('DkN', DkN_DkNId), DkN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('DkN', DkN_DkNId), DkN_OpeZalId, Count(*), DkN_OpeModId, Count(*)
  From CDN.DeklNag Left Outer Join CDN.DeklElem On DkE_DkNId = DkN_DkNId And (DkN_TypDeklar In (5,7) And DkE_Numer = 100005 Or DkN_TypDeklar In (9) And DkE_Numer = 300202 Or DkN_TypDeklar In (10) And DkE_Numer = 350104)
  Where DkN_TS_Zal Between @DataOd And @DataDo + 1 And (DkN_OpeZalId = DkN_OpeModId And DkN_TS_Zal <> DkN_TS_Mod) And DkN_TypDeklar Not In (311,321,25,26,27,28,29,30,36,37)
  Group By DkN_OpeZalId, CDN.KsiegTypZrodla('DkN', DkN_DkNId), DkN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('DkN', DkN_DkNId), DkN_OpeZalId, Count(*), DkN_OpeModId, Count(*)
  From CDN.DeklNag Left Outer Join CDN.DeklElem On DkE_DkNId = DkN_DkNId And (DkN_TypDeklar In (5,7) And DkE_Numer = 100005 Or DkN_TypDeklar In (9) And DkE_Numer = 300202 Or DkN_TypDeklar In (10) And DkE_Numer = 350104)
  Where DkN_TS_Zal Between @DataOd And @DataDo + 1 And (DkN_OpeZalId <> DkN_OpeModId And DkN_TS_Zal <> DkN_TS_Mod) And DkN_TypDeklar Not In (311,321,25,26,27,28,29,30,36,37)
  Group By DkN_OpeZalId, CDN.KsiegTypZrodla('DkN', DkN_DkNId), DkN_OpeModId
Union All
 Select 0, CDN.KsiegTypZrodla('EDN', EDN_EDNId), EDN_OpeZalId, Count(*), '', 0
  From CDN.EwidDodNag
  Where EDN_TS_Zal Between @DataOd And @DataDo + 1 And (EDN_OpeZalId = EDN_OpeModId And EDN_TS_Zal = EDN_TS_Mod)
  Group By EDN_Typ, EDN_OpeZalId, CDN.KsiegTypZrodla('EDN', EDN_EDNId), EDN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('EDN', EDN_EDNId), EDN_OpeZalId, Count(*), EDN_OpeModId, Count(*)
  From CDN.EwidDodNag
  Where EDN_TS_Zal Between @DataOd And @DataDo + 1 And (EDN_OpeZalId = EDN_OpeModId And EDN_TS_Zal <> EDN_TS_Mod)
  Group By EDN_Typ, EDN_OpeZalId, CDN.KsiegTypZrodla('EDN', EDN_EDNId), EDN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('EDN', EDN_EDNId), EDN_OpeZalId, Count(*), EDN_OpeModId, Count(*)
  From CDN.EwidDodNag
  Where EDN_TS_Zal Between @DataOd And @DataDo + 1 And (EDN_OpeZalId <> EDN_OpeModId And EDN_TS_Zal <> EDN_TS_Mod)
  Group By EDN_Typ, EDN_OpeZalId, CDN.KsiegTypZrodla('EDN', EDN_EDNId), EDN_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('WPL_E', WPL_WPLId), WPL_OpeZalId, Count(*), '', 0
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo +1 And LPL_Kategoria = 1 And (WPL_OpeZalId = WPL_OpeModId And WPL_TS_Zal = WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_E', WPL_WPLId), WPL_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('WPL_E', WPL_WPLId), WPL_OpeZalId, Count(*), WPL_OpeModId, Count(*)
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo +1 And LPL_Kategoria = 1 And (WPL_OpeZalId = WPL_OpeModId And WPL_TS_Zal <> WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_E', WPL_WPLId), WPL_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('WPL_E', WPL_WPLId), WPL_OpeZalId, Count(*), WPL_OpeModId, Count(*)
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo +1 And LPL_Kategoria = 1 And (WPL_OpeZalId <> WPL_OpeModId And WPL_TS_Zal <> WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_E', WPL_WPLId), WPL_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('WPL_U', WPL_WPLId), WPL_OpeZalId, Count(*), '', 0
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria = 2 And (WPL_OpeZalId = WPL_OpeModId And WPL_TS_Zal = WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_U', WPL_WPLId), WPL_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('WPL_U', WPL_WPLId), WPL_OpeZalId, Count(*), WPL_OpeModId, Count(*)
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria = 2 And (WPL_OpeZalId = WPL_OpeModId And WPL_TS_Zal <> WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_U', WPL_WPLId), WPL_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('WPL_U', WPL_WPLId), WPL_OpeZalId, Count(*), WPL_OpeModId, Count(*)
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria = 2 And (WPL_OpeZalId <> WPL_OpeModId And WPL_TS_Zal <> WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_U', WPL_WPLId), WPL_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('WPL_P', WPL_WPLId), WPL_OpeZalId, Count(*), '', 0
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria <> 1 And LPL_Kategoria <> 2 And LPL_Kategoria <> 8 And (WPL_OpeZalId = WPL_OpeModId And WPL_TS_Zal = WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_P', WPL_WPLId), WPL_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('WPL_P', WPL_WPLId), WPL_OpeZalId, Count(*), WPL_OpeModId, Count(*)
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria <> 1 And LPL_Kategoria <> 2 And LPL_Kategoria <> 8 And (WPL_OpeZalId = WPL_OpeModId And WPL_TS_Zal <> WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_P', WPL_WPLId), WPL_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('WPL_P', WPL_WPLId), WPL_OpeZalId, Count(*), WPL_OpeModId, Count(*)
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria <> 1 And LPL_Kategoria <> 2 And LPL_Kategoria <> 8 And (WPL_OpeZalId <> WPL_OpeModId And WPL_TS_Zal <> WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_P', WPL_WPLId), WPL_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('WPL_W', WPL_WPLId), WPL_OpeZalId, Count(*), '', 0
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria = 8 And (WPL_OpeZalId = WPL_OpeModId And WPL_TS_Zal = WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_W', WPL_WPLId), WPL_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('WPL_W', WPL_WPLId), WPL_OpeZalId, Count(*), WPL_OpeModId, Count(*)
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria = 8 And (WPL_OpeZalId = WPL_OpeModId And WPL_TS_Zal <> WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_W', WPL_WPLId), WPL_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('WPL_W', WPL_WPLId), WPL_OpeZalId, Count(*), WPL_OpeModId, Count(*)
  From CDN.ListyPlac Join CDN.Wyplaty On LPL_LPLId = WPL_LPLId
  Where LPL_TS_Zal Between @DataOd And @DataDo + 1 And LPL_Kategoria = 8 And (WPL_OpeZalId <> WPL_OpeModId And WPL_TS_Zal <> WPL_TS_Mod)
  Group By WPL_OpeZalId, CDN.KsiegTypZrodla('WPL_W', WPL_WPLId), WPL_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('NON', NON_NONId), NON_OpeZalId, Count(*), '', 0
  From CDN.NotyOdsNag
  Where NON_TS_Zal Between @DataOd And @DataDo + 1 And (NON_OpeZalId = NON_OpeModId And NON_TS_Zal = NON_TS_Mod)
  Group By NON_OpeZalId, CDN.KsiegTypZrodla('NON', NON_NONId), NON_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('NON', NON_NONId), NON_OpeZalId, Count(*), NON_OpeModId, Count(*)
  From CDN.NotyOdsNag
  Where NON_TS_Zal Between @DataOd And @DataDo + 1 And (NON_OpeZalId = NON_OpeModId And NON_TS_Zal <> NON_TS_Mod)
  Group By NON_OpeZalId, CDN.KsiegTypZrodla('NON', NON_NONId), NON_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('NON', NON_NONId), NON_OpeZalId, Count(*), NON_OpeModId, Count(*)
  From CDN.NotyOdsNag
  Where NON_TS_Zal Between @DataOd And @DataDo + 1 And (NON_OpeZalId <> NON_OpeModId And NON_TS_Zal <> NON_TS_Mod)
  Group By NON_OpeZalId, CDN.KsiegTypZrodla('NON', NON_NONId), NON_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('KDN', KDN_KDNId), KDN_OpeZalId, Count(*), '', 0
  From CDN.KsiDokNag
  Where KDN_TS_Zal Between @DataOd And @DataDo + 1 And (KDN_OpeZalId = KDN_OpeModId And KDN_TS_Zal = KDN_TS_Mod)
  Group By KDN_OpeZalId, CDN.KsiegTypZrodla('KDN', KDN_KDNId), KDN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('KDN', KDN_KDNId), KDN_OpeZalId, Count(*), KDN_OpeModId, Count(*)
  From CDN.KsiDokNag
  Where KDN_TS_Zal Between @DataOd And @DataDo + 1 And (KDN_OpeZalId = KDN_OpeModId And KDN_TS_Zal <> KDN_TS_Mod)
  Group By KDN_OpeZalId, CDN.KsiegTypZrodla('KDN', KDN_KDNId), KDN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('KDN', KDN_KDNId), KDN_OpeZalId, Count(*), KDN_OpeModId, Count(*)
  From CDN.KsiDokNag
  Where KDN_TS_Zal Between @DataOd And @DataDo + 1 And (KDN_OpeZalId <> KDN_OpeModId And KDN_TS_Zal <> KDN_TS_Mod)
  Group By KDN_OpeZalId, CDN.KsiegTypZrodla('KDN', KDN_KDNId), KDN_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('ReN', ReN_ReNId), ReN_OpeZalId, Count(*), '', 0
  From CDN.RemanentNag
  Where ReN_TS_Zal Between @DataOd And @DataDo + 1 And (ReN_OpeZalId = ReN_OpeModId And ReN_TS_Zal = ReN_TS_Mod)
  Group By ReN_OpeZalId, CDN.KsiegTypZrodla('ReN', ReN_ReNId), ReN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('ReN', ReN_ReNId), ReN_OpeZalId, Count(*), ReN_OpeModId, Count(*)
  From CDN.RemanentNag
  Where ReN_TS_Zal Between @DataOd And @DataDo + 1 And (ReN_OpeZalId = ReN_OpeModId And ReN_TS_Zal <> ReN_TS_Mod)
  Group By ReN_OpeZalId, CDN.KsiegTypZrodla('ReN', ReN_ReNId), ReN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('ReN', ReN_ReNId), ReN_OpeZalId, Count(*), ReN_OpeModId, Count(*)
  From CDN.RemanentNag
  Where ReN_TS_Zal Between @DataOd And @DataDo + 1 And (ReN_OpeZalId <> ReN_OpeModId And ReN_TS_Zal <> ReN_TS_Mod)
  Group By ReN_OpeZalId, CDN.KsiegTypZrodla('ReN', ReN_ReNId), ReN_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('TrN', TrN_TrNId), TrN_OpeZalId, Count(*), '', 0
  From CDN.TraNag
  Where TrN_TS_Zal Between @DataOd And @DataDo + 1 And (TrN_OpeZalId = TrN_OpeModId And TrN_TS_Zal = TrN_TS_Mod)
  Group By CDN.KsiegTypZrodla('TrN', TrN_TrNId), TrN_OpeZalId, TrN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('TrN', TrN_TrNId), TrN_OpeZalId, Count(*), TrN_OpeModId, Count(*)
  From CDN.TraNag
  Where TrN_TS_Zal Between @DataOd And @DataDo + 1 And (TrN_OpeZalId = TrN_OpeModId And TrN_TS_Zal <> TrN_TS_Mod)
  Group By CDN.KsiegTypZrodla('TrN', TrN_TrNId), TrN_OpeZalId, TrN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('TrN', TrN_TrNId), TrN_OpeZalId, Count(*), TrN_OpeModId, Count(*)
  From CDN.TraNag
  Where TrN_TS_Zal Between @DataOd And @DataDo + 1 And (TrN_OpeZalId <> TrN_OpeModId And TrN_TS_Zal <> TrN_TS_Mod)
  Group By CDN.KsiegTypZrodla('TrN', TrN_TrNId), TrN_OpeZalId, TrN_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('SrH', SrH_SrHId), SrH_OpeZalId, Count(*), '', 0
  From CDN.TrwaleHist
  Where SrH_TS_Zal Between @DataOd And @DataDo + 1 And (SrH_OpeZalId = SrH_OpeModId And SrH_TS_Zal = SrH_TS_Mod)
  Group By CDN.KsiegTypZrodla('SrH', SrH_SrHId), SrH_OpeZalId, SrH_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('SrH', SrH_SrHId), SrH_OpeZalId, Count(*), SrH_OpeModId, Count(*)
  From CDN.TrwaleHist
  Where SrH_TS_Zal Between @DataOd And @DataDo + 1 And (SrH_OpeZalId = SrH_OpeModId And SrH_TS_Zal <> SrH_TS_Mod)
  Group By CDN.KsiegTypZrodla('SrH', SrH_SrHId), SrH_OpeZalId, SrH_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('SrH', SrH_SrHId), SrH_OpeZalId, Count(*), SrH_OpeModId, Count(*)
  From CDN.TrwaleHist
  Where SrH_TS_Zal Between @DataOd And @DataDo + 1 And (SrH_OpeZalId <> SrH_OpeModId And SrH_TS_Zal <> SrH_TS_Mod)
  Group By CDN.KsiegTypZrodla('SrH', SrH_SrHId), SrH_OpeZalId, SrH_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('WyN', WyN_WyNId), WyN_OpeZalId, Count(*), '', 0
  From CDN.WyplatyNag
  Where WyN_TS_Zal Between @DataOd And @DataDo + 1 And (WyN_OpeZalId = WyN_OpeModId And WyN_TS_Zal = WyN_TS_Mod)
  Group By WyN_OpeZalId, CDN.KsiegTypZrodla('WyN', WyN_WyNId), WyN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('WyN', WyN_WyNId), WyN_OpeZalId, Count(*), WyN_OpeModId, Count(*)
  From CDN.WyplatyNag
  Where WyN_TS_Zal Between @DataOd And @DataDo + 1 And (WyN_OpeZalId = WyN_OpeModId And WyN_TS_Zal <> WyN_TS_Mod)
  Group By WyN_OpeZalId, CDN.KsiegTypZrodla('WyN', WyN_WyNId), WyN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('WyN', WyN_WyNId), WyN_OpeZalId, Count(*), WyN_OpeModId, Count(*)
  From CDN.WyplatyNag
  Where WyN_TS_Zal Between @DataOd And @DataDo + 1 And (WyN_OpeZalId <> WyN_OpeModId And WyN_TS_Zal <> WyN_TS_Mod)
  Group By WyN_OpeZalId, CDN.KsiegTypZrodla('WyN', WyN_WyNId), WyN_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('BZd', BZd_BZdId), BZd_OpeZalId, Count(*), '', 0
  From CDN.BnkZdarzenia
  Where BZd_TS_Zal Between @DataOd And @DataDo + 1 And IsNull(BZd_DokumentTyp,0) = 0 And (BZd_OpeZalId = BZd_OpeModId And BZd_TS_Zal = BZd_TS_Mod)
  Group By BZd_OpeZalId, CDN.KsiegTypZrodla('BZd', BZd_BZdId), BZd_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('BZd', BZd_BZdId), BZd_OpeZalId, Count(*), BZd_OpeModId, Count(*)
  From CDN.BnkZdarzenia
  Where BZd_TS_Zal Between @DataOd And @DataDo + 1 And IsNull(BZd_DokumentTyp,0) = 0 And (BZd_OpeZalId = BZd_OpeModId And BZd_TS_Zal <> BZd_TS_Mod)
  Group By BZd_OpeZalId, CDN.KsiegTypZrodla('BZd', BZd_BZdId), BZd_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('BZd', BZd_BZdId), BZd_OpeZalId, Count(*), BZd_OpeModId, Count(*)
  From CDN.BnkZdarzenia
  Where BZd_TS_Zal Between @DataOd And @DataDo + 1 And IsNull(BZd_DokumentTyp,0) = 0 And (BZd_OpeZalId <> BZd_OpeModId And BZd_TS_Zal <> BZd_TS_Mod)
  Group By BZd_OpeZalId, CDN.KsiegTypZrodla('BZd', BZd_BZdId), BZd_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('Dlg', Dln_DlnId), Dln_OpeZalId, Count(*), '', 0
  From CDN.DlgNag
  Where Dln_TS_Zal Between @DataOd And @DataDo + 1 And (Dln_OpeZalId = Dln_OpeModId And Dln_TS_Zal = Dln_TS_Mod)
  Group By Dln_OpeZalId, CDN.KsiegTypZrodla('Dlg', Dln_DlnId), Dln_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('Dlg', Dln_DlnId), Dln_OpeZalId, Count(*), Dln_OpeModId, Count(*)
  From CDN.DlgNag
  Where Dln_TS_Zal Between @DataOd And @DataDo + 1 And (Dln_OpeZalId = Dln_OpeModId And Dln_TS_Zal <> Dln_TS_Mod)
  Group By Dln_OpeZalId, CDN.KsiegTypZrodla('Dlg', Dln_DlnId), Dln_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('Dlg', Dln_DlnId), Dln_OpeZalId, Count(*), Dln_OpeModId, Count(*)
  From CDN.DlgNag
  Where Dln_TS_Zal Between @DataOd And @DataDo + 1 And (Dln_OpeZalId <> Dln_OpeModId And Dln_TS_Zal <> Dln_TS_Mod)
  Group By Dln_OpeZalId, CDN.KsiegTypZrodla('Dlg', Dln_DlnId), Dln_OpeModId
Union All
  Select 0, CDN.KsiegTypZrodla('BDN', BDN_BDNId), BDN_OpeZalId, Count(*), '', 0
  From CDN.BnkDokNag
  Where BDN_TS_Zal Between @DataOd And @DataDo + 1 And (BDN_OpeZalId = BDN_OpeModId And BDN_TS_Zal = BDN_TS_Mod)
  Group By BDN_OpeZalId, CDN.KsiegTypZrodla('BDN', BDN_BDNId), BDN_OpeModId
Union All
  Select 1, CDN.KsiegTypZrodla('BDN', BDN_BDNId), BDN_OpeZalId, Count(*), BDN_OpeModId, Count(*)
  From CDN.BnkDokNag
  Where BDN_TS_Zal Between @DataOd And @DataDo + 1 And (BDN_OpeZalId = BDN_OpeModId And BDN_TS_Zal <> BDN_TS_Mod)
  Group By BDN_OpeZalId, CDN.KsiegTypZrodla('BDN', BDN_BDNId), BDN_OpeModId
Union All
  Select 2, CDN.KsiegTypZrodla('BDN', BDN_BDNId), BDN_OpeZalId, Count(*), BDN_OpeModId, Count(*)
  From CDN.BnkDokNag
  Where BDN_TS_Zal Between @DataOd And @DataDo + 1 And (BDN_OpeZalId <> BDN_OpeModId And BDN_TS_Zal <> BDN_TS_Mod)
  Group By BDN_OpeZalId, CDN.KsiegTypZrodla('BDN', BDN_BDNId), BDN_OpeModId
)
