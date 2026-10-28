CREATE PROCEDURE CDN.BO_AktualizujStanyKont
@OObId    int
AS
 SET NOCOUNT ON
    if IsNull(@OObId,0) = 0
        Select @OObId = Cast(Fir_Wartosc As Int) From CDN.Firma Where Fir_Numer = 244
    if @OObId Is Not Null
        Begin
            Begin Transaction
            Alter Table CDN.DekretyKonta Disable Trigger All;
            Alter Table CDN.Obroty Disable Trigger All;
            Delete CDN.DekretyKonta
            From CDN.DekretyKonta Join CDN.DekretyNag On DeK_DeNId = DeN_DeNId
            Where DeN_Typ=2 and DeN_OObId=@OObId
            Delete CDN.Obroty
            From CDN.Obroty Join CDN.Konta On Obr_AccId = Acc_AccId
            Where Acc_OObId = @OObId
            Insert InTo CDN.DekretyKonta(   DeK_DeEId,
                                            DeK_DeNId,
                                            DeK_DziId,
                                            DeK_AccId,
                                            DeK_Strona,
                                            DeK_DataDok,
                                            DeK_Kwota,
                                            DeK_KwotaWal,
                                            DeK_Waluta,
                                            DeK_Bufor   )
            Select  DeE_DeEId,
                    DeN_DeNId,
                    DeN_DziId,
                    DeE_AccWnId,
                    1,
                    DeN_DataDok,
                    DeE_Kwota,
                    DeE_KwotaWal,
                    DeE_Waluta,
                    DeN_Bufor
            From CDN.DekretyElem Join CDN.DekretyNag On DeE_DeNId=DeN_DeNId
            Where DeN_Typ=2 and DeN_OObId = @OObId And DeE_AccWnId Is Not Null
            Insert InTo CDN.DekretyKonta(   DeK_DeEId,
                                            DeK_DeNId,
                                            DeK_DziId,
                                            DeK_AccId,
                                            DeK_Strona,
                                            DeK_DataDok,
                                            DeK_Kwota,
                                            DeK_KwotaWal,
                                            DeK_Waluta,
                                            DeK_Bufor  )
            Select  DeE_DeEId,
                    DeN_DeNId,
                    DeN_DziId,
                    DeE_AccMaId,
                    2,
                    DeN_DataDok,
                    DeE_Kwota,
                    DeE_KwotaWal,
                    DeE_Waluta,
                    DeN_Bufor
            From CDN.DekretyElem Join CDN.DekretyNag On DeE_DeNId=DeN_DeNId
            Where DeN_Typ=2 and DeN_OObId = @OObId And DeE_AccMaId Is Not Null
            Alter Table CDN.DekretyKonta Enable Trigger All
            Insert InTo CDN.Obroty(     Obr_AccId,
                                        Obr_RokMies,
                                        Obr_Typ,
                                        Obr_ObrotyWn,
                                        Obr_ObrotyMa,
                                        Obr_ObrotyWnBufor,
                                        Obr_ObrotyMaBufor,
                                        Obr_ObrotyWnWal,
                                        Obr_ObrotyMaWal,
                                        Obr_ObrotyWnBuforWal,
                                        Obr_ObrotyMaBuforWal    )
            Select  DeK_AccId,
                    100*Year(DeK_DataDok)+Month(DeK_DataDok),
                    0,
                    Sum(Case When DeK_Strona=1 And DeK_Bufor=0 Then DeK_Kwota Else 0 End),
                    Sum(Case When DeK_Strona=2 And DeK_Bufor=0 Then DeK_Kwota Else 0 End),
                    Sum(Case When DeK_Strona=1 Then DeK_Kwota Else 0 End),
                    Sum(Case When DeK_Strona=2 Then DeK_Kwota Else 0 End),
                    Sum(Case When DeK_Strona=1 And DeK_Bufor=0 Then DeK_KwotaWal Else 0 End),
                    Sum(Case When DeK_Strona=2 And DeK_Bufor=0 Then DeK_KwotaWal Else 0 End),
                    Sum(Case When DeK_Strona=1 Then DeK_KwotaWal Else 0 End),
                    Sum(Case When DeK_Strona=2 Then DeK_KwotaWal Else 0 End)
            From CDN.DekretyKonta Join CDN.DekretyNag On DeK_DeNId = DeN_DeNId
            Where DeN_Typ=2 and DeN_OObId = @OObId
            Group By  DeK_AccId, 100*Year(DeK_DataDok)+Month(DeK_DataDok)
            Insert InTo CDN.Obroty( Obr_AccId,
                                    Obr_RokMies,
                                    Obr_Typ,
                                    Obr_ObrotyWn,
                                    Obr_ObrotyMa,
                                    Obr_ObrotyWnBufor,
                                    Obr_ObrotyMaBufor,
                                    Obr_ObrotyWnWal,
                                    Obr_ObrotyMaWal,
                                    Obr_ObrotyWnBuforWal,
                                    Obr_ObrotyMaBuforWal    )
            Select  BOE_AccId,
                    Null,
                    1,
                    Sum(Case When BON_Bufor=0 Then BOE_KwotaWn Else 0 End),
                    Sum(Case When BON_Bufor=0 Then BOE_KwotaMa Else 0 End),
                    Sum(BOE_KwotaWn),
                    Sum(BOE_KwotaMa),
                    Sum(Case When BON_Bufor=0 Then BOE_KwotaWnWal Else 0 End),
                    Sum(Case When BON_Bufor=0 Then BOE_KwotaMaWal Else 0 End),
                    Sum(BOE_KwotaWnWal),
                    Sum(BOE_KwotaMaWal)
            From CDN.BOElem Join CDN.BONag On BOE_BONId=BON_BONId
            Where BON_OObId = @OObId
            Group By BOE_AccId
            Insert InTo CDN.Obroty( Obr_AccId,
                                    Obr_RokMies,
                                    Obr_Typ,
                                    Obr_ObrotyWn,
                                    Obr_ObrotyMa,
                                    Obr_ObrotyWnBufor,
                                    Obr_ObrotyMaBufor,
                                    Obr_ObrotyWnWal,
                                    Obr_ObrotyMaWal,
                                    Obr_ObrotyWnBuforWal,
                                    Obr_ObrotyMaBuforWal   )
            Select  BOE_AccPrevId,
                    Null,
                    2,
                    Sum(Case When BON_Bufor=0 Then BOE_KwotaWn Else 0 End),
                    Sum(Case When BON_Bufor=0 Then BOE_KwotaMa Else 0 End),
                    Sum(BOE_KwotaWn),
                    Sum(BOE_KwotaMa),
                    Sum(Case When BON_Bufor=0 Then BOE_KwotaWnWal Else 0 End),
                    Sum(Case When BON_Bufor=0 Then BOE_KwotaMaWal Else 0 End),
                    Sum(BOE_KwotaWnWal),
                    Sum(BOE_KwotaMaWal)
            From CDN.BOElem Join CDN.BONag On BOE_BONId=BON_BONId
            Where BON_OObPrevId = @OObId And BON_BilansZamkniecia=1
            Group By BOE_AccPrevId
            Alter Table CDN.Obroty Enable Trigger All;
            if @@TranCount <> 0 Commit Transaction
        End
    SET NOCOUNT OFF
