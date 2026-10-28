CREATE PROCEDURE CDN.AnonimizacjaDokKnt( @id INT )
AS
BEGIN
 DECLARE @nipKnt NVARCHAR(20)
 SELECT TOP 1 @nipKnt = Knt_Nip FROM cdn.Kontrahenci WHERE Knt_KntId = @id
 IF @nipKnt IS NULL SET @nipKnt = N''
 SELECT DISTINCT 100 As TypDok, cdn.OptimaNazwaObiektu(100,0) As TypDokDesc, 0 As Mode, IsN_IsNId As Id, RTRIM(LTRIM(STR(IsN_Numer))) As NumerDok, IsN_DataWypelnienia As DataDok, N'' As Opis, 2 As SekcjaId
 FROM   [CDN].[IntrastatNag] WHERE  [IsN_ZglTyp] = 1 AND [IsN_ZglId] = @id
 UNION
 SELECT DISTINCT 227 As TypDok, cdn.OptimaNazwaObiektu(227, 0) As TypDokDesc, 0 As Mode, KrO_KrOId As Id, KrO_Dokument  As NumerDok, KrO_DataDokumentu As DataDok, N'' As Opis, 2 As SekcjaId
 FROM CDN.KsiRozrachunki WHERE KRo_DeEId in (SELECT DeE_DeEId from CDN.Konta join CDN.DekretyElem on (DeE_AccWnId = Acc_AccId)  where Acc_SlownikTyp = 1 AND Acc_SlownikId = @id)
 UNION
 SELECT DISTINCT 227 As TypDok, cdn.OptimaNazwaObiektu(227, 0) As TypDokDesc, 0 As Mode, KrO_KrOId As Id, KrO_Dokument  As NumerDok, KrO_DataDokumentu As DataDok, N'' As Opis, 2 As SekcjaId
 FROM CDN.KsiRozrachunki WHERE KRo_DeEId in (SELECT DeE_DeEId from CDN.Konta join CDN.DekretyElem on (DeE_AccMaId = Acc_AccId) where Acc_SlownikTyp = 1 and Acc_SlownikId = @id)
 UNION
 SELECT DISTINCT 227 As TypDok, cdn.OptimaNazwaObiektu(227, 0) As TypDokDesc, 0 As Mode, KrO_KrOId As Id, KrO_Dokument  As NumerDok, KrO_DataDokumentu As DataDok, N'' As Opis, 2 As SekcjaId
 FROM CDN.KsiRozrachunki WHERE KRo_BoEId in (select BoE_BoEId from CDN.Konta join CDN.BOElem on (BOE_AccId = Acc_AccId) where Acc_SlownikTyp =1 and Acc_SlownikId = @id)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 1 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, CASE WHEN TrN_Bufor=-1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE Trn_Bufor > -1 AND TrN_TypDokumentu IN (301,302,303,304,305,306,307,313,314,320,321,322,345,350) AND (TrN_PodmiotTyp = 1 AND TrN_PodId = @id)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 1 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, CASE WHEN TrN_Bufor=-1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE TrN_Bufor = -1 AND TrN_TypDokumentu IN (301,302,303,304,305,306,307,313,314,320,321,322,345,350) AND (TrN_PodmiotTyp = 1 AND TrN_PodId = @id)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 1 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, CASE WHEN TrN_Bufor=-1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE Trn_Bufor > -1 AND TrN_TypDokumentu IN (301,302,305,306,307,313,314) AND (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 1 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, CASE WHEN TrN_Bufor=-1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE TrN_Bufor = -1 AND TrN_TypDokumentu IN (301,302,305,306,307,313,314) AND (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 1 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE Trn_Bufor > -1 AND TrN_TypDokumentu IN (301,302,305,313,314,350) AND ((TrN_PlatnikTyp = 1 AND TrN_PlatnikId = @id) OR (TrN_PodmiotZalTyp=1 AND TrN_PodZalId = @id))
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 1 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'Dokument anulowany' As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE Trn_Bufor = -1 AND TrN_TypDokumentu IN (301,302,305,313,314,350)  AND ((TrN_PlatnikTyp = 1 AND TrN_PlatnikId = @id) OR (TrN_PodmiotZalTyp=1 AND TrN_PodZalId = @id))
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 1 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE TrN_Bufor > -1 AND TrN_TypDokumentu IN (301,302,305,350)
 AND   (TrN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
     OR TrN_TrNId IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=1 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)))
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 1 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'Dokument anulowany' As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE Trn_Bufor = -1 AND TrN_TypDokumentu IN (301,302,305,350) AND TrN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
 UNION
 SELECT DISTINCT 308 As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, CASE WHEN TrN_Bufor=-1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE  TrN_Bufor > -1 AND TrN_TypDokumentu = 308  AND TrN_RezerwacjaWew = 0 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @id) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id))
 UNION
 SELECT DISTINCT 308 As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, CASE WHEN TrN_Bufor=-1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE TrN_Bufor = -1 AND TrN_TypDokumentu = 308  AND TrN_RezerwacjaWew = 0 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @id) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id))
 UNION
 SELECT DISTINCT 309 As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, CASE WHEN TrN_Bufor=-1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE  TrN_Bufor > -1 AND TrN_TypDokumentu = 309 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @id) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id))
 UNION
 SELECT DISTINCT 309 As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, CASE WHEN TrN_Bufor=-1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId
    FROM cdn.TraNag WHERE  TrN_Bufor = -1 AND TrN_TypDokumentu = 309 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @id) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @id))
 UNION
 SELECT DISTINCT 370 As TypDok, cdn.OptimaNazwaObiektu(370,0) As TypDokDesc, 0 As Mode, SzL_SZLId As Id, SZL_NumerPelny As NumerDok, SzL_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.SenditZleceniePrzesylki WHERE SZL_OdbiorcaTyp=1 AND SZL_OdbID = @id
 UNION
 SELECT DISTINCT 800 As TypDok, cdn.OptimaNazwaObiektu(800,0) As TypDokDesc, 0 As Mode, OfD_OfDId As Id, OfD_NumerPelny As NumerDok, OfD_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.OfertyKnt JOIN cdn.OfertyDok ON OfK_OfDId = OfD_OfDId WHERE OfK_PodmiotTyp=1 AND OfK_PodID = @id
 UNION
 SELECT DISTINCT 999 As TypDok, cdn.OptimaNazwaObiektu(999, VaN_Typ) As TypDokDesc, 0 As Mode, VaN_VaNId As Id, VaN_Dokument As NumerDok, VaN_DataWys As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.VatNag WHERE ((VaN_PodmiotTyp=1 AND VaN_PodID = @id) OR (VaN_PlatnikTyp=1 AND VaN_PlatnikID = @id) OR (VaN_PodmiotZalTyp=1 AND VaN_PodZalId = @id))
 UNION
 SELECT DISTINCT 999 As TypDok, cdn.OptimaNazwaObiektu(999,VaN_Typ) As TypDokDesc, 0 As Mode, VaN_VaNId As Id, VaN_Dokument As NumerDok, VaN_DataWys As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.VatNag WHERE (VaN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
   OR  (VaN_VaNID IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=2 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id))))
 UNION
 SELECT DISTINCT 1000  As TypDok, cdn.OptimaNazwaObiektu(1000, BZP_Kierunek) As TypDokDesc, 0 As Mode, BzP_BZPId As Id, BzP_NumerPelny As NumerDok, BzP_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.BnkZapisy WHERE BzP_PodmiotTyp=1 AND BzP_PodmiotID = @id
 UNION
 SELECT DISTINCT 1001  As TypDok, cdn.OptimaNazwaObiektu(1001, BZd_Kierunek) As TypDokDesc, 0 As Mode, BzD_BZDId As Id,
    CASE WHEN BZd_NumerObcy<>'' THEN BZd_NumerObcy ELSE CASE WHEN BZd_NumerPelny<>'' THEN BZd_NumerPelny ELSE CASE WHEN BZd_Opis <>'' THEN CAST(BZd_Opis As VARCHAR(30)) ELSE STR(BZD_BZDID) END END END As NumerDok,
 BZd_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
    FROM CDN.BnkZdarzenia WHERE (BZd_PodmiotTyp = 1 AND BZd_PodmiotId = @id)
 UNION
 SELECT DISTINCT 1003 As TypDok, cdn.OptimaNazwaObiektu(1003,EDN_Typ), 1 As Mode, EdN_EdNId As Id, EdN_NumerPelny As NumerDok, EDN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.EwidDodNag
 WHERE  (EdN_PodmiotTyp=1 AND EdN_PodID = @id)
     OR (EdN_PlatnikTyp=1 AND EdN_PlatnikID = @id)
     OR (EdN_PodmiotZalTyp=1 AND EdN_PodZalId = @id)
  OR (EdN_FplID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id)
  OR (EdN_EdNID IN (SELECT Bzd_DokumentId FROM cdn.BnkZdarzenia WHERE BZd_DokumentTyp=12 AND BzD_FPLID IN (SELECT FpL_FplId  FROM cdn.FormyPlatnosci WHERE  FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @id))))
 UNION
 SELECT DISTINCT BDN_Typ  As TypDok, cdn.OptimaNazwaObiektu(BDN_Typ,0) As TypDokDesc, 0 As Mode, BdN_BdNId As Id, BdN_NumerPelny As NumerDok, BDN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.BnkDokNag WHERE BDN_PodmiotTyp=1 AND BDN_PodmiotID = @id
 UNION
 SELECT DISTINCT 500  As TypDok, cdn.OptimaNazwaObiektu(500, 0) As TypDokDesc, 0 As Mode, BoE_BoEId As Id, CASE WHEN LEN(LTRIM(RTRIM(BoE_Dokument))) > 0  THEN BoE_Dokument ELSE BON_NumerPelny END As NumerDok, BoE_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.BONag JOIN cdn.BOElem ON BON_BONId = BOE_BONId JOIN cdn.Konta ON   BoE_AccId = Acc_AccId
 WHERE Acc_SlownikTyp = 1 AND Acc_SlownikID = @id
 UNION
 SELECT DISTINCT 1006  As TypDok, cdn.OptimaNazwaObiektu(1006, 0) As TypDokDesc, 0 As Mode, DeE_DeEId As Id, DeE_Dokument As NumerDok, DeE_DataOpe As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.DekretyNag JOIN cdn.DekretyElem ON DeN_DeNId = DeE_DeNId JOIN cdn.Konta ON   DeE_AccMaId = Acc_AccId  OR DeE_AccWnId = Acc_AccId
 WHERE Acc_SlownikTyp = 1 AND Acc_SlownikID = @id
 UNION
 SELECT DISTINCT 1008 As TypDok, cdn.OptimaNazwaObiektu(1008,0) As TypDokDesc, 0 As Mode, KPR_KpRId As Id, KPR_Dokument As NumerDok, KPR_DataOpe As DataDok, CASE WHEN KPR_Skreslony=1 THEN N'Dokument anulowany' ELSE N'' END As Opis, 2 As SekcjaId FROM cdn.ZapisyKPR WHERE KPR_PodmiotTyp=1 AND KPR_PodID = @id
 UNION
 SELECT DISTINCT KDN_Typ As TypDok, cdn.OptimaNazwaObiektu(KDN_Typ, 0) As TypDokDesc, 0 As Mode, KDN_KDNId As Id, KDN_NumerPelny As NumerDok, KDN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.KsiDokNag JOIN CDN.Konta ON (KDN_AccID = Acc_AccId) WHERE Acc_SlownikTyp = 1 AND Acc_SlownikId = @id
 UNION
 SELECT DISTINCT 1130 As TypDok, cdn.OptimaNazwaObiektu(1130, 0) As TypDokDesc, 0 As Mode, NON_NONId As Id, NON_NumerPelny As NumerDok, NON_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.NotyOdsNag WHERE NON_PodmiotTyp = 1 AND NON_PodmiotID = @id
 UNION
 SELECT DISTINCT 1145 As TypDok, cdn.OptimaNazwaObiektu(1145, 0) As TypDokDesc, 0 As Mode, KPN_KPNId As Id, KPN_NumerPelny As NumerDok, KPN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.KompensatyNag WHERE KPN_PodmiotTyp = 1 AND KPN_PodmiotID = @id
 UNION
 SELECT DISTINCT BDN_Typ  As TypDok, cdn.OptimaNazwaObiektu(BDN_Typ,0) As TypDokDesc, 0 As Mode, BdN_BdNId As Id, BdN_NumerPelny As NumerDok, BDN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.BnkDokNag WHERE BDN_PodmiotTyp=1 AND BDN_PodmiotID = @id
 UNION
 SELECT DISTINCT 351 As TypDok, cdn.OptimaNazwaObiektu(351,0) As TypDokDesc, 0 As Mode, Sent_SentID As Id, Sent_NumerPelny As NumerDok, Sent_DataDok As DataDok, N'' As Opis, 3 As SekcjaId  FROM cdn.SentZgloszenia WHERE Sent_PodmiotTyp=1 AND Sent_PodID = @id
 UNION
 SELECT DISTINCT 700 As TypDok, cdn.OptimaNazwaObiektu(700,0) As TypDokDesc, 0 As Mode, CrK_CrKId As Id, CrK_NumerPelny As NumerDok, CrK_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.CrmKontakty WHERE CRK_PodmiotTyp=1 AND CRK_PodID=@id
 UNION
 SELECT DISTINCT 702  As TypDok, cdn.OptimaNazwaObiektu(702,0) As TypDokDesc, 0 As Mode, FcN_FcNId As Id, FcN_Kod As NumerDok, FcN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.FaCyklNag JOIN cdn.FaCyklKnt  ON FCN_FcNID = FCK_FcNID WHERE (FCK_PodmiotTyp=1 AND FCK_PodmiotID=@id) OR (FCK_OdbiorcaTyp=1 AND FCK_OdbiorcaID=@id)
 UNION
 SELECT DISTINCT 710 As TypDok, cdn.OptimaNazwaObiektu(710,0) As TypDokDesc, 0 As Mode, AnkAnN_AnkAnNId As Id, AnkAnN_NumerPelny As NumerDok, AnkAnN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.AnkAnkietyNag WHERE AnkAnN_PodmiotTyp = 1 AND AnkAnN_PodId = @id
 UNION
 SELECT DISTINCT 714 As TypDok, cdn.OptimaNazwaObiektu(714,0) As TypDokDesc, 0 As Mode, AnkWaN_AnkWaNId As Id, AnkWaN_Kod As NumerDok, AnkWaN_TS_Zal As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.AnkWzorzecAnkietyNag JOIN cdn.AnkWzorzecAnkietyAnkietowani ON AnkWaN_AnkWaNId = AnkWaA_AnkWaNId WHERE AnkWaA_PodmiotTyp = 1 AND AnkWaA_PodId = @id
 UNION
 SELECT DISTINCT 750 As TypDok, cdn.OptimaNazwaObiektu(750,0) As TypDokDesc, 0 As Mode, DoN_DoNId As Id, DoN_NumerPelny As NumerDok, DoN_DataDok As DataDok, N'' As Opis, 3 As SekcjaId
 FROM cdn.DokNag JOIN cdn.DokPodmioty ON DoN_DonId = DoP_DoNID WHERE DoP_PodmiotTyp=1 AND DoP_PodmiotID = @id
 UNION
 SELECT DISTINCT 752 As TypDok, cdn.OptimaNazwaObiektu(752,0) As TypDokDesc, 0 As Mode, WdKE_WdKEId As Id, CAST(WdKE_ObjName AS  NVARCHAR(30)) As NumerDok, WdKE_PrnDate As DataDok, N'' As Opis, 1 As SekcjaId
 FROM cdn.WdrKopieElektroniczne WHERE WdKE_ObjSubjectType=1 AND WdKE_ObjSubjectId=@id
 UNION
 SELECT DISTINCT 900 As TypDok, cdn.OptimaNazwaObiektu(900,0) As TypDokDesc, 0 As Mode, SrZ_SrZId As Id, SrZ_NumerPelny As NumerDok, SrZ_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.SrsZlecenia WHERE ((SrZ_PodmiotTyp = 1 AND SrZ_PodmiotId = @id) OR (SrZ_OdbiorcaTyp=1 AND SrZ_OdbId = @id))
 UNION
 SELECT DISTINCT 906 As TypDok, cdn.OptimaNazwaObiektu(906,0) As TypDokDesc, 0 As Mode, SrW_SrWId As Id, SrW_Kod As NumerDok, SrW_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.SrsCyklNag WHERE ((SrW_PodmiotTyp = 1 AND SrW_PodmiotId = @id) OR (SrW_OdbiorcaTyp=1 AND SrW_OdbId = @id))
 UNION -- VAT-UE
 SELECT DISTINCT 30011 As TypDok, cdn.OptimaNazwaObiektu(30011,0) As TypDokDesc, 0 As Mode, DkN_DkNId As Id, LTrim(Str(DkN_RokMiesiac)) As NumerDok, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, cdn.Date(DkN_RokMiesiac/100, DkN_RokMiesiac - (DkN_RokMiesiac/100)*100 ,1) )+1,0)) As DataDok, CASE WHEN DkN_Numer>0 THEN N'korekta' ELSE CASE WHEN DkN_TypDeklar IN(11,22) THEN N'' ELSE N'korekta' END END As Opis, 2 As SekcjaId
    FROM cdn.DeklNag LEFT OUTER JOIN CDN.DeklVUEK ON DkN_DkNID = DVU_DkNID AND DVU_NIP = @nipKnt AND @nipKnt <> N''
 WHERE (DkN_TypDeklar IN(11, 22))  AND DVU_NIP IS NOT NULL
 UNION
 SELECT DISTINCT 30011 As TypDok, cdn.OptimaNazwaObiektu(30011,0) As TypDokDesc, 0 As Mode, DkN_DkNId As Id, LTrim(Str(DkN_RokMiesiac)) As NumerDok, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, cdn.Date(DkN_RokMiesiac/100, DkN_RokMiesiac - (DkN_RokMiesiac/100)*100 ,1) )+1,0)) As DataDok, CASE WHEN DkN_Numer>0 THEN N'korekta' ELSE CASE WHEN DkN_TypDeklar IN(11,22) THEN N'' ELSE N'korekta' END END As Opis, 2 As SekcjaId
    FROM CDN.DeklNag JOIN CDN.DeklElem ON (DkN_DkNID = DkE_DkNID)
 WHERE DkN_TypDeklar IN (11, 22) AND DkE_Opis Like N'Numer VAT kontrahenta%' AND DkE_WartoscTekst = @nipKnt AND @nipKnt <> N''
 UNION
 SELECT DISTINCT 30011 As TypDok, cdn.OptimaNazwaObiektu(30011,0) As TypDokDesc, 0 As Mode, DkN_DkNId As Id, LTrim(Str(DkN_RokMiesiac)) As NumerDok, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, cdn.Date(DkN_RokMiesiac/100, DkN_RokMiesiac - (DkN_RokMiesiac/100)*100 ,1) )+1,0)) As DataDok, CASE WHEN DkN_Numer>0 THEN N'korekta' ELSE CASE WHEN DkN_TypDeklar IN(11,22) THEN N'' ELSE N'korekta' END END As Opis, 2 As SekcjaId
    FROM CDN.DeklNag JOIN CDN.DeklWydr ON (DkN_DkNID = DkW_DkNID)
 WHERE DkN_TypDeklar IN (11, 22) AND DkW_Opis Like N'Numer VAT kontrahenta%' AND DkW_Wartosc = @nipKnt  AND @nipKnt <> N''
 UNION -- VAT-27
 SELECT DISTINCT 30033 As TypDok, cdn.OptimaNazwaObiektu(30033,0) As TypDokDesc, 0 As Mode, DkN_DkNId As Id, LTrim(Str(DkN_RokMiesiac)) As NumerDok, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, cdn.Date(DkN_RokMiesiac/100, DkN_RokMiesiac - (DkN_RokMiesiac/100)*100 ,1) )+1,0)) As DataDok, CASE WHEN DkN_Numer>0 THEN N'korekta' ELSE CASE WHEN DkN_TypDeklar IN(11,22) THEN N'' ELSE N'korekta' END END As Opis, 2 As SekcjaId
    FROM cdn.DeklNag LEFT OUTER JOIN CDN.DeklV27 ON DkN_DkNID = V27_DkNID AND V27_NIP = @nipKnt AND @nipKnt <> N''
    WHERE (DkN_TypDeklar IN(33, 34))  AND V27_NIP IS NOT NULL
 UNION
 SELECT DISTINCT 2000 As TypDok, cdn.OptimaNazwaObiektu(2000,0) As TypDokDesc, 0 As Mode, JPK_JPKID As Id,N'plik JPK' As NumerDok, JPK_DataUtworzenia As DataDok, N'' As Opis, 3 As SekcjaId
    FROM cdn.PlikiJPK WHERE JPK_JPKScaID IS NULL
 ORDER BY SekcjaId, TypDok, DataDok, Id
END
