CREATE PROCEDURE CDN.AnonimizacjaDokBlokujaceKnt(@id INT, @thresholdDate  DATE)
AS
BEGIN
 DECLARE @thresholdRM INT, @nipKnt NVARCHAR(20)
 IF @thresholdDate IS NULL
  SET @thresholdRM = 0
 ELSE
  SET @thresholdRM = YEAR(@thresholdDate) * 100 + MONTH(@thresholdDate)
 SELECT TOP 1 @nipKnt = Knt_Nip FROM cdn.Kontrahenci WHERE Knt_KntId = @id
 IF @nipKnt IS NULL SET @nipKnt = N''
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
    FROM cdn.TraNag WHERE TrN_TypDokumentu IN (301,302,303,304,305,306,307,313,314,321,322,345,350)
 AND (TrN_PodmiotTyp = 1 AND TrN_PodId = @id)
 AND TrN_Bufor > -1 AND (TrN_DataDok > @thresholdDate OR TrN_DataOpe > @thresholdDate OR TrN_DataWys > @thresholdDate)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
    FROM cdn.TraNag WHERE TrN_TypDokumentu IN (301,302,305,306,307,313,314)
 AND (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id)
 AND TrN_Bufor > -1 AND (TrN_DataDok > @thresholdDate OR TrN_DataOpe > @thresholdDate OR TrN_DataWys > @thresholdDate)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
    FROM cdn.TraNag WHERE TrN_TypDokumentu IN (301,302,305,313,314,350)
 AND ((TrN_PlatnikTyp = 1 AND TrN_PlatnikId = @id) OR (TrN_PodmiotZalTyp=1 AND TrN_PodZalId = @id))
 AND TrN_Bufor > -1 AND (TrN_DataDok > @thresholdDate OR TrN_DataOpe > @thresholdDate OR TrN_DataWys > @thresholdDate)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TypDokumentu As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
    FROM cdn.TraNag WHERE TrN_TypDokumentu IN (301,302,305,350)
 AND TrN_Bufor > -1 AND (TrN_DataDok > @thresholdDate OR TrN_DataOpe > @thresholdDate OR TrN_DataWys > @thresholdDate)
 AND (   TrN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
      OR TrN_TrNId IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=1 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)))
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
    FROM cdn.TraNag WHERE TrN_TypDokumentu IN (308, 309) AND TrN_RezerwacjaWew = 0
 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @id) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id))
 AND ((TrN_Bufor=1) OR (TrN_Bufor=0 AND TrN_ZwroconoCalaIlosc<3))
 UNION
 SELECT DISTINCT 999 As TypDok, cdn.OptimaNazwaObiektu(999,VaN_Typ) As TypDokDesc, 0 As Mode, VaN_VaNId As Id, VaN_Dokument As NumerDok, VaN_DataWys As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.VatNag WHERE
 ((VaN_PodmiotTyp=1 AND VaN_PodID = @id) OR (VaN_PlatnikTyp=1 AND VaN_PlatnikID = @id) OR (VaN_PodmiotZalTyp=1 AND VaN_PodZalId = @id))
 AND (VaN_DataWys > @thresholdDate OR VaN_DataZap > @thresholdDate OR VaN_DataOpe > @thresholdDate)
 UNION
 SELECT DISTINCT 999 As TypDok, cdn.OptimaNazwaObiektu(999, VaN_Typ) As TypDokDesc, 0 As Mode, VaN_VaNId As Id, VaN_Dokument As NumerDok, VaN_DataWys As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.VatNag WHERE (VaN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
  OR  (VaN_VaNID IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=2 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id))))
  AND (VaN_DataWys > @thresholdDate OR VaN_DataZap > @thresholdDate OR VaN_DataOpe > @thresholdDate)
 UNION
 SELECT DISTINCT 1003 As TypDok, cdn.OptimaNazwaObiektu(1003,EDN_Typ) As TypDokDesc, 0 As Mode, EdN_EdNId As Id, EdN_NumerPelny As NumerDok, EDN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.EwidDodNag WHERE EdN_PodmiotTyp=1 AND EdN_PodID = @id AND (EDN_DataWys > @thresholdDate OR EDN_DataDok > @thresholdDate OR EDN_DataOpe > @thresholdDate)
 UNION
 SELECT DISTINCT 1003 As TypDok, cdn.OptimaNazwaObiektu(1003,EDN_Typ) As TypDokDesc, 0 As Mode, EdN_EdNId As Id, EdN_NumerPelny As NumerDok, EDN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.EwidDodNag WHERE ( (EdN_PlatnikTyp=1 AND EdN_PlatnikId = @id) OR (EdN_PodmiotZalTyp=1 AND EdN_PodZalId = @id) )
       AND (EDN_DataWys > @thresholdDate OR EDN_DataDok > @thresholdDate OR EDN_DataOpe > @thresholdDate)
 UNION
 SELECT DISTINCT 1003 As TypDok, cdn.OptimaNazwaObiektu(1003,EDN_Typ) As TypDokDesc, 0 As Mode, EDN_EDNID As Id, EdN_NumerPelny As NumerDok, EDN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.EwidDodNag  WHERE (EdN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
       OR  (EdN_EdNID IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=12 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id))))
       AND (EDN_DataWys > @thresholdDate OR EDN_DataDok > @thresholdDate OR EDN_DataOpe > @thresholdDate)
 UNION
 SELECT DISTINCT 1000  As TypDok, cdn.OptimaNazwaObiektu(1000, BZP_Kierunek) As TypDokDesc, 0 As Mode, BzP_BZPId As Id, BzP_NumerPelny As NumerDok, BzP_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.BnkZapisy WHERE BZp_PodmiotTyp = 1 AND BZp_PodmiotID = @id AND EXISTS (SELECT * FROM cdn.BnkRozKwoty WHERE BRK_LDokTyp = 2 AND BRK_LDokID = BZp_BZpID AND BRK_PDokTyp =1 AND BRK_PDokID IN (SELECT BZd_BZdID FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp = 8) OR BRK_PDokTyp = 2 AND BRK_PDokID = BZp_BZpID AND BRK_LDokTyp = 1 AND BRK_LDokID IN (SELECT BZd_BZdID FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp = 8))
 UNION
 SELECT DISTINCT 1001  As TypDok, cdn.OptimaNazwaObiektu(1001, BZd_Kierunek) As TypDokDesc, 0 As Mode, BzD_BZDId As Id,
    CASE WHEN BZd_NumerObcy<>'' THEN BZd_NumerObcy ELSE CASE WHEN BZd_NumerPelny<>'' THEN BZd_NumerPelny ELSE CASE WHEN BZd_Opis <>'' THEN CAST(BZd_Opis As VARCHAR(30)) ELSE STR(BZD_BZDID) END END END As NumerDok,
 BZd_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp = 8 AND BZd_PodmiotTyp=1 AND BZd_PodmiotID = @id
 UNION
 SELECT DISTINCT 1006  As TypDok, cdn.OptimaNazwaObiektu(1006, 0) As TypDokDesc, 0 As Mode, DeE_DeEId As Id, DeE_Dokument As NumerDok, DeE_DataOpe As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.DekretyNag JOIN cdn.DekretyElem ON DeN_DeNId = DeE_DeNId JOIN cdn.Konta ON   DeE_AccMaId = Acc_AccId  OR DeE_AccWnId = Acc_AccId
 WHERE Acc_SlownikTyp = 1 AND Acc_SlownikID = @id AND (DeE_DataWys > @thresholdDate OR DeE_DataOpe > @thresholdDate)
 UNION
 SELECT DISTINCT 500  As TypDok, cdn.OptimaNazwaObiektu(500, 0) As TypDokDesc, 0 As Mode, BoE_BoEId As Id, CASE WHEN LEN(LTRIM(RTRIM(BoE_Dokument))) > 0  THEN BoE_Dokument ELSE BON_NumerPelny END As NumerDok, BoE_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.BONag JOIN cdn.BOElem ON BON_BONId = BOE_BONId JOIN cdn.Konta ON   BoE_AccId = Acc_AccId
 WHERE Acc_SlownikTyp = 1 AND Acc_SlownikID = @id AND (BoE_DataDok > @thresholdDate)
 UNION   -- potwierdzenie salda  ponaglenie zaplaty nota odsetkowa
 SELECT DISTINCT KDN_Typ As TypDok, cdn.OptimaNazwaObiektu(KDN_Typ, 0) As TypDokDesc, 0 As Mode, KDN_KDNId As Id, KDN_NumerPelny As NumerDok, KDN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.KsiDokNag JOIN CDN.Konta ON (KDN_AccID = Acc_AccId) WHERE Acc_SlownikTyp = 1 AND Acc_SlownikId = @id AND KDN_DataDok > @thresholdDate
 UNION
 SELECT DISTINCT 1130 As TypDok, cdn.OptimaNazwaObiektu(1130, 0) As TypDokDesc, 0 As Mode, NON_NONId As Id, NON_NumerPelny As NumerDok, NON_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.NotyOdsNag WHERE NON_PodmiotTyp = 1 AND NON_PodmiotID = @id AND NON_DataDok > @thresholdDate
 UNION
 SELECT DISTINCT 1145 As TypDok, cdn.OptimaNazwaObiektu(1145, 0) As TypDokDesc, 0 As Mode, KPN_KPNId As Id, KPN_NumerPelny As NumerDok, KPN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.KompensatyNag WHERE KPN_PodmiotTyp = 1 AND KPN_PodmiotID = @id AND KPN_DataDok > @thresholdDate
 UNION
 SELECT DISTINCT BDN_Typ  As TypDok, cdn.OptimaNazwaObiektu(BDN_Typ,0) As TypDokDesc, 0 As Mode, BdN_BdNId As Id, BdN_NumerPelny As NumerDok, BDN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.BnkDokNag WHERE BDN_PodmiotTyp=1 AND BDN_PodmiotID = @id AND BDN_DataDok > @thresholdDate
 UNION
 SELECT DISTINCT 1008 As TypDok, cdn.OptimaNazwaObiektu(1008,0) As TypDokDesc, 0 As Mode, KPR_KpRId As Id, KPR_Dokument As NumerDok, KPR_DataOpe As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.ZapisyKPR WHERE KPR_Skreslony=0 AND KPR_PodmiotTyp=1 AND KPR_PodID = @id AND KPR_DataOpe > @thresholdDate
 UNION  -- oferty
 SELECT DISTINCT 800 As TypDok, cdn.OptimaNazwaObiektu(800,0) As TypDokDesc, 0 As Mode, OfD_OfDId As Id, OfD_NumerPelny As NumerDok, OfD_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.OfertyKnt JOIN cdn.OfertyDok ON OfK_OfDId = OfD_OfDId WHERE OfD_Bufor = 1 AND OfK_PodmiotTyp=1 AND OfK_PodID = @id
 UNION  -- kontakty CRM
 SELECT 700 As TypDok, cdn.OptimaNazwaObiektu(700,0) As TypDokDesc, 0 As Mode, CrK_CrKId As Id, CrK_NumerPelny As NumerDok, CrK_DataDok As DataDok, N'' As Opis, 0 As SekcjaId  FROM cdn.CrmKontakty WHERE CrK_PodmiotTyp = 1 AND CrK_PodId = @id AND CrK_Bufor = 1
 UNION
 SELECT DISTINCT 750 As TypDok, cdn.OptimaNazwaObiektu(750,0) As TypDokDesc, 0 As Mode, DoN_DoNId As Id, DoN_NumerPelny As NumerDok, DoN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.DokNag JOIN cdn.DokPodmioty ON DoN_DonId = DoP_DoNID WHERE DoP_PodmiotTyp=1 AND DoP_PodmiotID = @id AND DoN_EtapBiezacyLp > 0
 UNION  -- zlecenia
 SELECT DISTINCT 900 As TypDok, cdn.OptimaNazwaObiektu(900,0) As TypDokDesc, 0 As Mode, SrZ_SrZId As Id, SrZ_NumerPelny As NumerDok, SrZ_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.SrsZlecenia WHERE (SrZ_Bufor = 1 OR (SrZ_Bufor = 0 AND SrZ_Stan < 2)) AND ((SrZ_PodmiotTyp = 1 AND SrZ_PodmiotId = @id) OR (SrZ_OdbiorcaTyp=1 AND SrZ_OdbId = @id))
 UNION
 SELECT DISTINCT 1801 As TypDok, cdn.OptimaNazwaObiektu(1801,0) As TypDokDesc, 0 As Mode, RUN_RUNId As Id, N'Naruszenie' As NumerDok, RUN_DataNaruszenia As DataDok, N'' As Opis, 0 As SekcjaId
    FROM cdn.RejestrNaruszen WHERE  RUN_PodmiotTyp = 1 AND RUN_PodId = @id
 UNION -- VAT-UE
 SELECT DISTINCT 30011 As TypDok, cdn.OptimaNazwaObiektu(30011,0) As TypDokDesc, 0 As Mode, DkN_DkNId As Id, LTrim(Str(DkN_RokMiesiac)) As NumerDok, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, cdn.Date(DkN_RokMiesiac/100, DkN_RokMiesiac - (DkN_RokMiesiac/100)*100 ,1) )+1,0)) As DataDok, CASE WHEN DkN_Numer>0 THEN N'korekta' ELSE CASE WHEN DkN_TypDeklar IN(11,22) THEN N'' ELSE N'korekta' END END As Opis, 0 As SekcjaId
    FROM cdn.DeklNag LEFT OUTER JOIN CDN.DeklVUEK ON DkN_DkNID = DVU_DkNID AND DVU_NIP = @nipKnt AND @nipKnt <> N''
 WHERE (DkN_TypDeklar IN(11, 22))  AND DVU_NIP IS NOT NULL AND DkN_RokMiesiac > @thresholdRM
 UNION
 SELECT DISTINCT 30011 As TypDok, cdn.OptimaNazwaObiektu(30011,0) As TypDokDesc, 0 As Mode, DkN_DkNId As Id, LTrim(Str(DkN_RokMiesiac)) As NumerDok, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, cdn.Date(DkN_RokMiesiac/100, DkN_RokMiesiac - (DkN_RokMiesiac/100)*100 ,1) )+1,0)) As DataDok, CASE WHEN DkN_Numer>0 THEN N'korekta' ELSE CASE WHEN DkN_TypDeklar IN(11,22) THEN N'' ELSE N'korekta' END END As Opis, 0 As SekcjaId
    FROM CDN.DeklNag JOIN CDN.DeklElem ON (DkN_DkNID = DkE_DkNID)
 WHERE DkN_TypDeklar IN (11, 22) AND DkN_RokMiesiac > @thresholdRM AND DkE_Opis Like N'Numer VAT kontrahenta%' AND DkE_WartoscTekst = @nipKnt AND @nipKnt <> N''
 UNION
 SELECT DISTINCT 30011 As TypDok, cdn.OptimaNazwaObiektu(30011,0) As TypDokDesc, 0 As Mode, DkN_DkNId As Id, LTrim(Str(DkN_RokMiesiac)) As NumerDok, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, cdn.Date(DkN_RokMiesiac/100, DkN_RokMiesiac - (DkN_RokMiesiac/100)*100 ,1) )+1,0)) As DataDok, CASE WHEN DkN_Numer>0 THEN N'korekta' ELSE CASE WHEN DkN_TypDeklar IN(11,22) THEN N'' ELSE N'korekta' END END As Opis, 0 As SekcjaId
    FROM CDN.DeklNag JOIN CDN.DeklWydr ON (DkN_DkNID = DkW_DkNID)
 WHERE DkN_TypDeklar IN (11, 22) AND DkN_RokMiesiac > @thresholdRM AND DkW_Opis Like N'Numer VAT kontrahenta%' AND DkW_Wartosc = @nipKnt AND @nipKnt <> N''
 UNION -- VAT-27
 SELECT DISTINCT 30033 As TypDok, cdn.OptimaNazwaObiektu(30033,0) As TypDokDesc, 0 As Mode, DkN_DkNId As Id, LTrim(Str(DkN_RokMiesiac)) As NumerDok, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, cdn.Date(DkN_RokMiesiac/100, DkN_RokMiesiac - (DkN_RokMiesiac/100)*100 ,1) )+1,0)) As DataDok,CASE WHEN DkN_Numer>0 THEN N'korekta' ELSE CASE WHEN DkN_TypDeklar IN(11,22) THEN N'' ELSE N'korekta' END END  As Opis, 0 As SekcjaId
    FROM cdn.DeklNag LEFT OUTER JOIN CDN.DeklV27 ON DkN_DkNID = V27_DkNID AND V27_NIP = @nipKnt AND @nipKnt <> N''
 WHERE (DkN_TypDeklar IN(33, 34))  AND V27_NIP IS NOT NULL AND DkN_RokMiesiac > @thresholdRM
 ORDER BY SekcjaId, TypDok, DataDok, Id
END
