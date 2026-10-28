CREATE PROCEDURE CDN.GetPlatnTaxFree  @DokId int, @Rodzaj nvarchar(10)
AS
BEGIN
 IF(@Rodzaj = 302090 OR @Rodzaj = 301090)
 Select BZd_ImportRowId='', BZd_Termin, FPl_Nazwa, FPl_ImportRowId, BZd_Kwota, BZd_Kierunek, BZd_Rozliczono = 0, BZd_KontoPrzeciwstawne, BZd_NieNaliczajOdsetek, BZd_PrzelewSEPA,
  BZd_Waluta, BZd_KursNumer, BZd_KursL, BZd_KursM, BZd_KwotaSys, BZd_DataKur, BZd_WalutaDok, BZd_PodmiotTyp, BZd_PodmiotID, BZd_PodmiotRachunekLp, BZd_KatID, BZd_ElixirO1, BZd_ElixirO2, BZd_ElixirO3, BZd_ElixirO4,
  BZd_SplitPay, BZd_SplitPayKwotaVAT, BZd_SplitPayNipE, BZd_SplitPayNrDok,
  FAzPA = 0, VaN_FA_z_PA = 0
  From CDN.TraNag FA
  Join CDN.TraNag WKA On FA.TrN_TrNId = WKA.TrN_FaId And FA.TrN_Rodzaj = @Rodzaj And WKA.TrN_TypDokumentu = case @Rodzaj when 302090 then 314 when 301090 then 313 end
  Join CDN.BnkZdarzenia On BZd_DokumentTyp = 1 And BZd_DokumentId = WKA.TrN_TrNId
  left outer join CDN.FormyPlatnosci On (FPl_FPlId=BZd_FPlId)
  Where FA.TrN_TrNId = @DokId
 UNION ALL
 Select BZd_ImportRowId, BZd_Termin, FPl_Nazwa, FPl_ImportRowId, BZd_Kwota, BZd_Kierunek, BZd_Rozliczono, BZd_KontoPrzeciwstawne, BZd_NieNaliczajOdsetek, BZd_PrzelewSEPA,
  BZd_Waluta, BZd_KursNumer, BZd_KursL, BZd_KursM, BZd_KwotaSys, BZd_Datakur, BZd_WalutaDok, BZd_PodmiotTyp, BZd_PodmiotID, BZd_PodmiotRachunekLp, BZd_KatID, BZd_ElixirO1, BZd_ElixirO2, BZd_ElixirO3, BZd_ElixirO4,
  BZd_SplitPay, BZd_SplitPayKwotaVAT, BZd_SplitPayNipE, BZd_SplitPayNrDok,
  FAzPA = 0, VaN_FA_z_PA = 0
  From CDN.TraNag FA
  Join CDN.BnkZdarzenia On BZd_DokumentTyp = 1 And BZd_DokumentId = FA.TrN_TrNId
  left outer join CDN.FormyPlatnosci On (FPl_FPlId=BZd_FPlId)
  Where FA.TrN_TrNId = @DokId
 ELSE
 Select BZd_ImportRowId, BZd_Termin, FPl_Nazwa, FPl_ImportRowId, BZd_Kwota, BZd_Kierunek, BZd_Rozliczono, BZd_KontoPrzeciwstawne, BZd_NieNaliczajOdsetek, BZd_PrzelewSEPA,
  BZd_Waluta, BZd_KursNumer, BZd_KursL, BZd_KursM, BZd_KwotaSys, BZd_DataKur, BZd_WalutaDok, BZd_PodmiotTyp, BZd_PodmiotID, BZd_PodmiotRachunekLp, BZd_KatID, BZd_ElixirO1, BZd_ElixirO2, BZd_ElixirO3, BZd_ElixirO4,
  BZd_SplitPay, BZd_SplitPayKwotaVAT, BZd_SplitPayNipE, BZd_SplitPayNrDok,
  FAzPA = 0, VaN_FA_z_PA = 0
        From CDN.BnkZdarzenia
        left outer join CDN.FormyPlatnosci On (FPl_FPlId=BZd_FPlId)
        Where BZd_DokumentTyp=1 And BZd_DokumentID IN (SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_Korekta <> 8 AND TrN_TrNID = @DokId)
 UNION ALL
 Select TOP 1 BZd_ImportRowId, BZd_Termin, FPl_Nazwa, FPl_ImportRowId, BZd_Kwota, BZd_Kierunek, BZd_Rozliczono, BZd_KontoPrzeciwstawne, BZd_NieNaliczajOdsetek, BZd_PrzelewSEPA,
  BZd_Waluta, BZd_KursNumer, BZd_KursL, BZd_KursM, BZd_KwotaSys, BZd_DataKur, BZd_WalutaDok, BZd_PodmiotTyp, BZd_PodmiotID, BZd_PodmiotRachunekLp, BZd_KatID, BZd_ElixirO1, BZd_ElixirO2, BZd_ElixirO3, BZd_ElixirO4,
  BZd_SplitPay, BZd_SplitPayKwotaVAT, BZd_SplitPayNipE, BZd_SplitPayNrDok,
  FAzPA = 0, VaN_FA_z_PA = 0
        From CDN.BnkZdarzenia
        left outer join CDN.FormyPlatnosci On (FPl_FPlId=BZd_FPlId)
        Where BZd_DokumentTyp=1 And BZd_DokumentID IN (SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_Korekta = 8 AND TrN_ZwrId = @DokId)
 UNION ALL
 Select BZd_ImportRowId, BZd_Termin, FPl_Nazwa, FPl_ImportRowId, BZd_Kwota, BZd_Kierunek, BZd_Rozliczono, BZd_KontoPrzeciwstawne, BZd_NieNaliczajOdsetek, BZd_PrzelewSEPA,
  BZd_Waluta, BZd_KursNumer, BZd_KursL, BZd_KursM, BZd_KwotaSys, BZd_DataKur, BZd_WalutaDok, BZd_PodmiotTyp, BZd_PodmiotID, BZd_PodmiotRachunekLp, BZd_KatID, BZd_ElixirO1, BZd_ElixirO2, BZd_ElixirO3, BZd_ElixirO4,
  BZd_SplitPay, BZd_SplitPayKwotaVAT, BZd_SplitPayNipE, BZd_SplitPayNrDok,
  FAzPA = CASE
 WHEN A.TrN_DataOpe < CONVERT(DATETIME, '2020-10-01', 120) THEN (CASE WHEN EXISTS(select C.TrN_TS_Export from cdn.TraNag C where C.Trn_TrnID IN (Select TRR_TRNID from cdn.TraNagRelacje join CDN.TraNag on (TrR_TrNId = C.TrN_TrNID) where TrR_FaId = @DokID and trr_trntyp = 305 and trr_fatyp=302 and C.TrN_TS_Export is Not Null)) THEN 1 ELSE 0 END)
 ELSE (CASE WHEN EXISTS(Select TRR_TRNID from cdn.TraNagRelacje join CDN.TraNag on (TrR_TrNId = A.TrN_TrNID) where TrR_FaId = @DokID and trr_trntyp = 305 and trr_fatyp=302) THEN 1 ELSE 0 END)
 END,
  VaN_FA_z_PA = 0
  From CDN.BnkZdarzenia
  LEFT OUTER JOIN cdn.TraNag A ON A.TrN_TrNID = BZd_DokumentID
  left outer join CDN.FormyPlatnosci On (FPl_FPlId=BZd_FPlId)
  Where BZd_DokumentTyp=1 And BZd_DokumentID IN (select TrR_FaId from cdn.TraNagRelacje LEFT OUTER JOIN cdn.TraNag TN ON TN.TrN_TrNID = TrR_TrNID where trr_trnID = @DokId and TrR_TrNTyp=302 and TrR_FaTyp = 305 AND TrN_PAFACzesciowe = 0)
 UNION ALL
 Select TOP 1 BZd_ImportRowId, BZd_Termin, FPl_Nazwa, FPl_ImportRowId, TR1.TrN_RazemBruttoWal, BZd_Kierunek, 0, BZd_KontoPrzeciwstawne, BZd_NieNaliczajOdsetek, BZd_PrzelewSEPA,
  BZd_Waluta, BZd_KursNumer, BZd_KursL, BZd_KursM, TR1.TrN_RazemBrutto, BZd_DataKur, BZd_WalutaDok, BZd_PodmiotTyp, BZd_PodmiotID, BZd_PodmiotRachunekLp, BZd_KatID, '', '', '', '',
  BZd_SplitPay, BZd_SplitPayKwotaVAT, BZd_SplitPayNipE, BZd_SplitPayNrDok,
  FAzPA = CASE
  WHEN A.TrN_DataOpe < CONVERT(DATETIME, '2020-10-01', 120) THEN (CASE WHEN EXISTS(select C.TrN_TS_Export from cdn.TraNag C where C.Trn_TrnID IN (Select TRR_TRNID from cdn.TraNagRelacje join CDN.TraNag on (TrR_TrNId = C.TrN_TrNID) where TrR_FaId = @DokID and trr_trntyp = 305 and trr_fatyp=302 and C.TrN_TS_Export is Not Null)) THEN 1 ELSE 0 END)
  ELSE (CASE WHEN EXISTS(Select TRR_TRNID from cdn.TraNagRelacje join CDN.TraNag on (TrR_TrNId = A.TrN_TrNID) where TrR_FaId = @DokID and trr_trntyp = 305 and trr_fatyp=302) THEN 1 ELSE 0 END)
  END,
  VaN_FA_z_PA = 0
  From CDN.BnkZdarzenia LEFT OUTER JOIN cdn.TraNag TR1 ON TR1.TrN_TrNID = @DokId
  LEFT OUTER JOIN cdn.TraNag A ON A.TrN_TrNID = BZd_DokumentID
  left outer join CDN.FormyPlatnosci On (FPl_FPlId=BZd_FPlId)
  Where BZd_DokumentTyp=1 And BZd_DokumentID IN (select TrR_FaId from cdn.TraNagRelacje LEFT OUTER JOIN cdn.TraNag TN2 ON TN2.TrN_TrNID = TrR_TrNID where trr_trnID = @DokId and TrR_TrNTyp=302 and TrR_FaTyp = 305 AND TN2.TrN_PAFACzesciowe <> 0)
END
