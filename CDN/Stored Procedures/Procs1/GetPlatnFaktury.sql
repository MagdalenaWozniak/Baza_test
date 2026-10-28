CREATE PROCEDURE CDN.GetPlatnFaktury
@VaNTyp int,
@VaNID int,
@VaN_FA_z_PA int
AS
BEGIN
 IF (SELECT VaN_Wewnetrzna FROM CDN.VatNag WHERE VaN_VaNId = @VaNID) = 1
 BEGIN
  SELECT *, FAzPA = 0, VaN_FA_z_PA = 0 FROM CDN.BnkZdarzenia WHERE 0 = 1
  RETURN
 END
 DECLARE @TrNId int,
 @PaId int,
 @FaId int,
 @VaN_DataOpe DATETIME
 SELECT @VaN_DataOpe = VaN_DataOpe FROM CDN.VatNag WHERE VaN_VaNId = @VaNID
 IF  (@VaNTyp = 2)
 BEGIN
  SELECT @TrNId = VaN_TrNId FROM CDN.VatNag WHERE VaN_VaNId = @VaNID
  IF(@TrNId) is NULL
  BEGIN
   SELECT *, FAzPA = 0, VaN_FA_z_PA = CASE WHEN @VaN_DataOpe >= CONVERT(DATETIME, '2020-10-01', 120) THEN @VaN_FA_z_PA ELSE (CASE WHEN EXISTS( SELECT VaN_VaNID FROM CDN.VatNag WHERE VaN_VanOrgId = @VaNID AND VaN_Rodzaj = 8) THEN 1 ELSE 0 END) END
   FROM CDN.BnkZdarzenia
   JOIN CDN.FormyPlatnosci On BZd_FPlId=FPl_FPlId
   WHERE BZd_DokumentTyp=2 And BZd_DokumentID = @VaNID
  END
  ELSE IF(@TrNId = -1)
  BEGIN
   SELECT *, FAzPA = 0, VaN_FA_z_PA = CASE WHEN @VaN_DataOpe >= CONVERT(DATETIME, '2020-10-01', 120) THEN @VaN_FA_z_PA ELSE (CASE WHEN EXISTS( SELECT VaN_VaNID FROM CDN.VatNag WHERE VaN_VanOrgId = @VaNID AND VaN_Rodzaj = 8) THEN 1 ELSE 0 END) END
   FROM CDN.BnkZdarzenia
   JOIN CDN.FormyPlatnosci ON BZd_FplId = FPl_FPlId
   WHERE BZd_DokumentTyp = 1 AND BZd_DokumentID in (SELECT TrN_TrNId
   FROM CDN.TraNag
   WHERE TrN_TypDokumentu = 305 and TrN_VaNId = @VaNID)
  END
  ELSE
  BEGIN
   SELECT @FaId = TrN_FaId
   FROM CDN.TraNag WHERE TrN_TrNId = @TrNId AND TrN_Rodzaj not in(321022, 322021, 302200, 302202, 345000, 301051, 301052, 301053)
   IF(@FaId is NULL)
    SELECT *, FAzPA = 0, VaN_FA_z_PA = CASE WHEN @VaN_DataOpe >= CONVERT(DATETIME, '2020-10-01', 120) THEN @VaN_FA_z_PA ELSE (CASE WHEN EXISTS( SELECT VaN_VaNID FROM CDN.VatNag WHERE VaN_VanOrgId = @VaNID AND VaN_Rodzaj = 8) THEN 1 ELSE 0 END) END
    FROM CDN.BnkZdarzenia
    JOIN CDN.FormyPlatnosci On BZd_FPlId=FPl_FPlId
    WHERE BZd_DokumentTyp=1 And (BZd_DokumentID IN (@TrNId, (SELECT TrN_TrNID FROM cdn.TraNag WHERE TrN_ZwrID = @TrNId AND TrN_Korekta = 8 AND TrN_Bufor = 0)))
   ELSE
    SELECT BZd_ImportRowId, BZd_Termin, FPl_Nazwa, FPl_ImportRowId, BZd_Kwota, BZd_Kierunek, BZd_Rozliczono, BZd_KontoPrzeciwstawne, BZd_NieNaliczajOdsetek, BZd_PrzelewSEPA,
    BZd_Waluta, BZd_KursNumer, BZd_KursL, BZd_KursM, BZd_KwotaSys, BZd_DataKur, BZd_WalutaDok, BZd_PodmiotTyp, BZd_PodmiotID, BZd_PodmiotRachunekLp, BZd_KatID, BZd_ElixirO1, BZd_ElixirO2, BZd_ElixirO3, BZd_ElixirO4,
    BZd_SplitPay, BZd_SplitPayKwotaVAT, BZd_SplitPayNipE, BZd_SplitPayNrDok,
    FAzPA = 0, VaN_FA_z_PA = CASE WHEN @VaN_DataOpe >= CONVERT(DATETIME, '2020-10-01', 120) THEN @VaN_FA_z_PA ELSE (CASE WHEN EXISTS( SELECT VaN_VaNID FROM CDN.VatNag WHERE VaN_VanOrgId = @VaNID AND VaN_Rodzaj = 8) THEN 1 ELSE 0 END) END
    FROM CDN.BnkZdarzenia LEFT OUTER JOIN cdn.TraNag TR1 ON TR1.TrN_TrNID = @TrNId
    JOIN CDN.FormyPlatnosci On BZd_FPlId=FPl_FPlId
    WHERE BZd_DokumentTyp=1 And BZd_DokumentID in (select trr_faid FROM CDN.TraNagRelacje left join cdn.TraNag on trr_faid = trn_trnid  WHERE Trr_TrNId = @TrNId AND TrN_Rodzaj not in(321022, 322021, 302200, 302202, 345000, 301051, 301052, 301053) AND TR1.TrN_PAFACzesciowe = 0)
    UNION ALL
    SELECT TOP 1 BZd_ImportRowId, BZd_Termin, FPl_Nazwa, FPl_ImportRowId, TR1.TrN_RazemBruttoWal, BZd_Kierunek, 0, BZd_KontoPrzeciwstawne, BZd_NieNaliczajOdsetek, BZd_PrzelewSEPA,
    BZd_Waluta, BZd_KursNumer, BZd_KursL, BZd_KursM, TR1.TrN_RazemBrutto, BZd_DataKur, BZd_WalutaDok, BZd_PodmiotTyp, BZd_PodmiotID, BZd_PodmiotRachunekLp, BZd_KatID, '', '', '', '',
    BZd_SplitPay, BZd_SplitPayKwotaVAT, BZd_SplitPayNipE, BZd_SplitPayNrDok,
    FAzPA = 0, VaN_FA_z_PA = CASE WHEN @VaN_DataOpe >= CONVERT(DATETIME, '2020-10-01', 120) THEN @VaN_FA_z_PA ELSE (CASE WHEN EXISTS( SELECT VaN_VaNID FROM CDN.VatNag WHERE VaN_VanOrgId = @VaNID AND VaN_Rodzaj = 8) THEN 1 ELSE 0 END) END
    FROM CDN.BnkZdarzenia LEFT OUTER JOIN cdn.TraNag TR1 ON TR1.TrN_TrNID = @TrNId
    JOIN CDN.FormyPlatnosci On BZd_FPlId=FPl_FPlId
    WHERE BZd_DokumentTyp=1 And BZd_DokumentID in
    (select trr_faid FROM CDN.TraNagRelacje left join cdn.TraNag on trr_faid = trn_trnid  WHERE Trr_TrNId = @TrNId AND TrN_Rodzaj not in(321022, 322021, 302200, 302202, 345000, 301051, 301052, 301053) AND TR1.TrN_PAFACzesciowe <> 0)
  END
 END
 IF(@VaNTyp = 1)
  SELECT *, FAzPA = 0, VaN_FA_z_PA = CASE WHEN @VaN_DataOpe >= CONVERT(DATETIME, '2020-10-01', 120) THEN @VaN_FA_z_PA ELSE (CASE WHEN EXISTS( SELECT VaN_VaNID FROM CDN.VatNag WHERE VaN_VanOrgId = @VaNID AND VaN_Rodzaj = 8) THEN 1 ELSE 0 END) END
  FROM CDN.BnkZdarzenia
  JOIN CDN.FormyPlatnosci ON BZd_FPlId=FPl_FPlId
  WHERE BZd_DokumentTyp=1
  AND BZd_DokumentID = @VaNID /*(SELECT TrN_TrNId
  FROM CDN.TraNag
  WHERE TrN_VaNId = @VaNId)*/
END
