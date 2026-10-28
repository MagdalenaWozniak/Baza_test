CREATE View CDN.BnkRozKwotyView
As
Select
BRKV_BRKID               = BRK.BRK_BRKID ,
BRKV_Kwota               = BRK.BRK_Kwota ,
BRKV_KwotaSysL           = BRK.BRK_KwotaSysL ,
BRKV_KwotaSysP           = BRK.BRK_KwotaSysP ,
BRKV_RoznicaKursowaSys   = BRK.BRK_RoznicaKursowaSys ,
BRKV_DDfId               = BRK.BRK_DDfId ,
BRKV_NumerString         = BRK.BRK_NumerString ,
BRKV_NumerNr             = BRK.BRK_NumerNr ,
BRKV_NumerPelny          = BRK.BRK_NumerPelny ,
BRKV_DataDok             = BRK.BRK_DataDok ,
BRKV_Zwloka              = BRK.BRK_Zwloka ,
BRKV_LDokTyp             = BRK.BRK_LDokTyp ,
BRKV_LDokID              = BRK.BRK_LDokID ,
BRKV_PDokTyp             = BRK.BRK_PDokTyp ,
BRKV_PDokID              = BRK.BRK_PDokID ,
BRKV_DekId               = BRK.BRK_DekId ,
BRKV_Dek2Id              = BRK.BRK_Dek2Id ,
BRKV_KPRId               = BRK.BRK_KPRId ,
BRKV_KolumnaKPR          = BRK.BRK_KolumnaKPR ,
BRKV_KontoWn1            = BRK.BRK_KontoWn1 ,
BRKV_KontoMa1            = BRK.BRK_KontoMa1 ,
BRKV_KontoWn2            = BRK.BRK_KontoWn2 ,
BRKV_KontoMa2            = BRK.BRK_KontoMa2 ,
BRKV_AutoOffLine         = BRK.BRK_AutoOffLine ,
BRKV_TS_Export           = BRK.BRK_TS_Export ,
BRKV_ImportAppId         = BRK.BRK_ImportAppId ,
BRKV_ImportRowId         = BRK.BRK_ImportRowId ,
BRKV_OpeZalId            = BRK.BRK_OpeZalId ,
BRKV_StaZalId            = BRK.BRK_StaZalId ,
BRKV_TS_Zal              = BRK.BRK_TS_Zal ,
BRKV_OpeModId            = BRK.BRK_OpeModId ,
BRKV_StaModId            = BRK.BRK_StaModId ,
BRKV_TS_Mod              = BRK.BRK_TS_Mod ,
BRKV_DokumentLP          = BRK.BRK_DokumentLP ,
BRKV_Waluta              = Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Waluta Else LZp.BZp_Waluta End,
BRKV_DokTyp1             = Case BRK.BRK_DokumentLP When 1 Then BRK.BRK_LDokTyp Else BRK.BRK_PDokTyp End,
BRKV_DokId1              = Case BRK.BRK_DokumentLP When 1 Then BRK.BRK_LDokId  Else BRK.BRK_PDokId  End,
BRKV_Numer1              = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Numer              Else LZp.BZp_Numer              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_Numer              Else PZp.BZp_Numer              End) End,
BRKV_Data1               = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_DataDok            Else LZp.BZp_DataDok            End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_DataDok            Else PZp.BZp_DataDok            End) End,
BRKV_Termin1             = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Termin             Else LZp.BZp_DataDok            End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_Termin             Else PZp.BZp_DataDok            End) End,
BRKV_BRaId1              = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_BRaId              Else LZp.BZp_BRaId              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_BRaId              Else PZp.BZp_BRaId              End) End,
BRKV_KursNumer1          = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KursNumer          Else LZp.BZp_KursNumer          End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KursNumer          Else PZp.BZp_KursNumer          End) End,
BRKV_KursL1              = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KursL              Else LZp.BZp_KursL              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KursL              Else PZp.BZp_KursL              End) End,
BRKV_KursM1              = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KursM              Else LZp.BZp_KursM              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KursM              Else PZp.BZp_KursM              End) End,
BRKV_Opis1               = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Opis               Else LZp.BZp_Opis               End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_Opis               Else PZp.BZp_Opis               End) End,
BRKV_KontoPrzeciwstawne1 = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KontoPrzeciwstawne Else LZp.BZp_KontoPrzeciwstawne End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KontoPrzeciwstawne Else PZp.BZp_KontoPrzeciwstawne End) End,
BRKV_PodmiotTyp1         = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_PodmiotTyp         Else LZp.BZp_PodmiotTyp         End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_PodmiotTyp         Else PZp.BZp_PodmiotTyp         End) End,
BRKV_PodmiotId1          = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_PodmiotId          Else LZp.BZp_PodmiotId          End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_PodmiotId          Else PZp.BZp_PodmiotId          End) End,
BRKV_Kwota1              = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Kwota              Else LZp.BZp_Kwota              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_Kwota              Else PZp.BZp_Kwota              End) End,
BRKV_KwotaSys1           = Case BRK.BRK_DokumentLP When 1 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KwotaSys           Else LZp.BZp_KwotaSys           End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KwotaSys           Else PZp.BZp_KwotaSys           End) End,
BRKV_KwotaRozSys1        = Case BRK.BRK_DokumentLP When 1 Then BRK.BRK_KwotaSysL Else BRK.BRK_KwotaSysP End,
BRKV_Typ1                =
 Case BRK.BRK_DokumentLP
   When 1 Then
     Case BRK_LDokTyp
       When 1 Then
         Case
           When LZd.BZd_Kierunek =  1 And CDN.KierunekOrg(LZd.BZd_DDfId) =  1 Then 'FS'
           When LZd.BZd_Kierunek = -1 And CDN.KierunekOrg(LZd.BZd_DDfId) =  1 Then 'FSK'
           When LZd.BZd_Kierunek = -1 And CDN.KierunekOrg(LZd.BZd_DDfId) = -1 Then 'FZ'
           When LZd.BZd_Kierunek =  1 And CDN.KierunekOrg(LZd.BZd_DDfId) = -1 Then 'FZK'
         End
       Else
         Case
           When LZp.BZp_Kierunek =  1 Then 'KP'
           When LZp.BZp_Kierunek = -1 Then 'KW'
         End
     End
   Else
     Case BRK_PDokTyp
       When 1 Then
         Case
           When PZd.BZd_Kierunek =  1 And CDN.KierunekOrg(PZd.BZd_DDfId) =  1 Then 'FS'
           When PZd.BZd_Kierunek = -1 And CDN.KierunekOrg(PZd.BZd_DDfId) =  1 Then 'FSK'
           When PZd.BZd_Kierunek = -1 And CDN.KierunekOrg(PZd.BZd_DDfId) = -1 Then 'FZ'
           When PZd.BZd_Kierunek =  1 And CDN.KierunekOrg(PZd.BZd_DDfId) = -1 Then 'FZK'
         End
       Else
         Case
           When PZp.BZp_Kierunek =  1 Then 'KP'
           When PZp.BZp_Kierunek = -1 Then 'KW'
         End
     End
 End,
BRKV_Wynagrodzenie1      = Case BRK.BRK_DokumentLP
                           When 1 Then
                             (Case BRK.BRK_LDokTyp When 1 Then (Case LZd.BZd_DokumentTyp When 8 Then 1 Else 0 End) Else LZp.BZp_Wynagrodzenie End)
                           Else
                             (Case BRK.BRK_PDokTyp When 1 Then (Case PZd.BZd_DokumentTyp When 8 Then 1 Else 0 End) Else PZp.BZp_Wynagrodzenie End) End,
BRKV_DokTyp2             = Case BRK.BRK_DokumentLP When 2 Then BRK.BRK_LDokTyp Else BRK.BRK_PDokTyp End,
BRKV_DokId2              = Case BRK.BRK_DokumentLP When 2 Then BRK.BRK_LDokId  Else BRK.BRK_PDokId  End,
BRKV_Numer2              = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Numer              Else LZp.BZp_Numer              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_Numer              Else PZp.BZp_Numer              End) End,
BRKV_Data2               = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_DataDok            Else LZp.BZp_DataDok            End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_DataDok            Else PZp.BZp_DataDok            End) End,
BRKV_Termin2             = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Termin             Else LZp.BZp_DataDok            End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_Termin             Else PZp.BZp_DataDok            End) End,
BRKV_BRaId2              = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_BRaId              Else LZp.BZp_BRaId              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_BRaId              Else PZp.BZp_BRaId              End) End,
BRKV_KursNumer2          = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KursNumer          Else LZp.BZp_KursNumer          End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KursNumer          Else PZp.BZp_KursNumer          End) End,
BRKV_KursL2              = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KursL              Else LZp.BZp_KursL              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KursL              Else PZp.BZp_KursL              End) End,
BRKV_KursM2              = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KursM              Else LZp.BZp_KursM              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KursM              Else PZp.BZp_KursM              End) End,
BRKV_Opis2               = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Opis               Else LZp.BZp_Opis               End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_Opis               Else PZp.BZp_Opis               End) End,
BRKV_KontoPrzeciwstawne2 = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KontoPrzeciwstawne Else LZp.BZp_KontoPrzeciwstawne End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KontoPrzeciwstawne Else PZp.BZp_KontoPrzeciwstawne End) End,
BRKV_PodmiotTyp2         = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_PodmiotTyp         Else LZp.BZp_PodmiotTyp         End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_PodmiotTyp         Else PZp.BZp_PodmiotTyp         End) End,
BRKV_PodmiotId2          = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_PodmiotId          Else LZp.BZp_PodmiotId          End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_PodmiotId          Else PZp.BZp_PodmiotId          End) End,
BRKV_Kwota2              = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_Kwota              Else LZp.BZp_Kwota              End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_Kwota              Else PZp.BZp_Kwota              End) End,
BRKV_KwotaSys2           = Case BRK.BRK_DokumentLP When 2 Then (Case BRK.BRK_LDokTyp When 1 Then LZd.BZd_KwotaSys           Else LZp.BZp_KwotaSys           End) Else (Case BRK_PDokTyp When 1 Then PZd.BZd_KwotaSys           Else PZp.BZp_KwotaSys           End) End,
BRKV_KwotaRozSys2        = Case BRK.BRK_DokumentLP When 2 Then BRK.BRK_KwotaSysL Else BRK.BRK_KwotaSysP End,
BRKV_Typ2                =
 Case BRK.BRK_DokumentLP
   When 2 Then
     Case BRK_LDokTyp
       When 1 Then
         Case
           When LZd.BZd_Kierunek =  1 And CDN.KierunekOrg(LZd.BZd_DDfId) =  1 Then 'FS'
           When LZd.BZd_Kierunek = -1 And CDN.KierunekOrg(LZd.BZd_DDfId) =  1 Then 'FSK'
           When LZd.BZd_Kierunek = -1 And CDN.KierunekOrg(LZd.BZd_DDfId) = -1 Then 'FZ'
           When LZd.BZd_Kierunek =  1 And CDN.KierunekOrg(LZd.BZd_DDfId) = -1 Then 'FZK'
         End
       Else
         Case
           When LZp.BZp_Kierunek =  1 Then 'KP'
           When LZp.BZp_Kierunek = -1 Then 'KW'
         End
     End
   Else
     Case BRK_PDokTyp
       When 1 Then
         Case
           When PZd.BZd_Kierunek =  1 And CDN.KierunekOrg(PZd.BZd_DDfId) =  1 Then 'FS'
           When PZd.BZd_Kierunek = -1 And CDN.KierunekOrg(PZd.BZd_DDfId) =  1 Then 'FSK'
           When PZd.BZd_Kierunek = -1 And CDN.KierunekOrg(PZd.BZd_DDfId) = -1 Then 'FZ'
           When PZd.BZd_Kierunek =  1 And CDN.KierunekOrg(PZd.BZd_DDfId) = -1 Then 'FZK'
         End
       Else
         Case
           When PZp.BZp_Kierunek =  1 Then 'KP'
           When PZp.BZp_Kierunek = -1 Then 'KW'
         End
     End
 End,
BRKV_Wynagrodzenie2      = Case BRK.BRK_DokumentLP
                           When 2 Then
                             (Case BRK.BRK_LDokTyp When 1 Then (Case LZd.BZd_DokumentTyp When 8 Then 1 Else 0 End) Else LZp.BZp_Wynagrodzenie End)
                           Else
                             (Case BRK.BRK_PDokTyp When 1 Then (Case PZd.BZd_DokumentTyp When 8 Then 1 Else 0 End) Else PZp.BZp_Wynagrodzenie End) End,
BRKV_Automatyczny =
 Case
  When BRK_LDokTyp <> BRK_PDokTyp Then
   Case BRK_DokumentLP
    When 1 Then
      PZp.BZp_ZapisAutomatyczny
    Else
      LZp.BZp_ZapisAutomatyczny
    End
  Else
   0
 End
From CDN.BnkRozKwoty BRK
Left Outer Join CDN.BnkZdarzenia LZd On BRK.BRK_LDokTyp = LZd.BZd_TypDokumentuKB And BRK.BRK_LDokId = LZd.BZd_BZdId
Left Outer Join CDN.BnkZapisy    LZp On BRK.BRK_LDokTyp = LZp.BZp_TypDokumentuKB And BRK.BRK_LDokId = LZp.BZp_BZpId
Left Outer Join CDN.BnkZdarzenia PZd On BRK.BRK_PDokTyp = PZd.BZd_TypDokumentuKB And BRK.BRK_PDokId = PZd.BZd_BZdId
Left Outer Join CDN.BnkZapisy    PZp On BRK.BRK_PDokTyp = PZp.BZp_TypDokumentuKB And BRK.BRK_PDokId = PZp.BZp_BZpId
