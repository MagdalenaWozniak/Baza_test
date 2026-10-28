CREATE PROCEDURE [CDN].[ZestWgAtrybutowDok]
@DeAID INT, @TypDok TEXT, @PodID INT, @PodTyp INT, @Bufor INT, @MagID INT, @OpeID INT, @AtrWartosc NVARCHAR(102),
@AtrWartoscOd DECIMAL(16,4), @AtrWartoscDo DECIMAL(16,4), @DataOd DATETIME, @DataDo DATETIME, @MmM INT, @zakazDostepuDoCenZakupu TINYINT
AS
BEGIN
 SET NOCOUNT ON
 IF @MmM = 0  --
 BEGIN
  select Pod_Kod, DAt_WartoscTxt, DeA_Kod, DeA_Format, Trn_NumerPelny,
  Trn_NumerString, Trn_NumerNr, TrN_DataOpe, TrN_TrNID,
  CDN.TypDokumentu(TrN_TypDokumentu) as 'TrN_TypDok', TrN_Korekta, TrN_Bufor,
  CASE @zakazDostepuDoCenZakupu WHEN 1 THEN CASE cdn.UkrywajCeneDlaPozycjiDok(TrN_TypDokumentu) WHEN 1 THEN  NULL ELSE TrN_RazemNetto END ELSE TrN_RazemNetto END As TrN_RazemNetto,
  TrN_TypDokumentu, M.Mag_Symbol, TrN_Bufor, TrN_VaNId, TrN_DekId
  from cdn.DokAtrybuty
  join cdn.tranag on dat_trnid = trn_trnid
  JOIN cdn.Magazyny M ON (M.Mag_MagId = TrN_MagZrdId OR M.Mag_MagId = TrN_MagDocId)
  join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid
  join cdn.defatrybuty on dea_deaid = dat_deaid
  where (dat_Wartosctxt LIKE @AtrWartosc OR @AtrWartosc = '')
  AND (DAt_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
  and (dat_DeAID = @DeAID OR @DeAID = 0 )
  and dat_trnid in (select trn_trnid from cdn.tranag
  where Trn_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
  AND (trn_podid IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
  AND (TrN_Bufor = @Bufor OR @Bufor=2)
  AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
  AND (TrN_MagZrdID = @MagID OR TrN_MagDocID = @MagID OR @MagID = 0)
  AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
  AND TrN_Rodzaj not in (302100, 305100, 301100)
  AND TrN_Bufor <> -1)
  order by trn_dataope
 END
    IF @MmM = 1  --Tylko przychód
 BEGIN
  select Pod_Kod, DAt_WartoscTxt, DeA_Kod, DeA_Format, Trn_NumerPelny,
  Trn_NumerString, Trn_NumerNr, TrN_DataOpe, TrN_TrNID,
  CDN.TypDokumentu(TrN_TypDokumentu) as 'TrN_TypDok', TrN_Korekta, TrN_Bufor,
  CASE @zakazDostepuDoCenZakupu WHEN 1 THEN CASE cdn.UkrywajCeneDlaPozycjiDok(TrN_TypDokumentu) WHEN 1 THEN  NULL ELSE TrN_RazemNetto END ELSE TrN_RazemNetto END As TrN_RazemNetto,
  TrN_TypDokumentu, M.Mag_Symbol, TrN_Bufor, TrN_VaNId, TrN_DekId
  from cdn.DokAtrybuty
  join cdn.tranag on dat_trnid = trn_trnid
  JOIN cdn.Magazyny M ON M.Mag_MagId = TrN_MagZrdId
  join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid
  join cdn.defatrybuty on dea_deaid = dat_deaid
  where (dat_Wartosctxt LIKE @AtrWartosc OR @AtrWartosc = '')
  AND (DAt_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
  and (dat_DeAID = @DeAID OR @DeAID = 0 )
  and dat_trnid in (select trn_trnid from cdn.tranag
  where
  Trn_TypDokumentu <> 312 AND Trn_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
  AND (trn_podid IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
  AND (TrN_Bufor = @Bufor OR @Bufor=2)
  AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
  AND (TrN_MagDocID = @MagID OR @MagID = 0)
  AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
  AND TrN_Rodzaj not in (302100, 305100, 301100)
  AND TrN_Bufor <> -1)
  UNION
  SELECT Pod_Kod, DAt_WartoscTxt, DeA_Kod, DeA_Format, Trn_NumerPelny, Trn_NumerString,
  Trn_NumerNr, TrN_DataOpe, TrN_TrNID, CDN.TypDokumentu(TrN_TypDokumentu) as 'TrN_TypDok',
  TrN_Korekta, TrN_Bufor,
  CASE @zakazDostepuDoCenZakupu WHEN 1 THEN CASE cdn.UkrywajCeneDlaPozycjiDok(TrN_TypDokumentu) WHEN 1 THEN  NULL ELSE TrN_RazemNetto END ELSE TrN_RazemNetto END As TrN_RazemNetto,
  TrN_TypDokumentu, M.Mag_Symbol, TrN_Bufor, TrN_VaNId, TrN_DekId
  from cdn.DokAtrybuty
  join cdn.tranag on dat_trnid = trn_trnid
  JOIN cdn.Magazyny M ON M.Mag_MagId = TrN_MagDocId
  join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid
  join cdn.defatrybuty on dea_deaid = dat_deaid
  where (dat_Wartosctxt LIKE @AtrWartosc OR @AtrWartosc = '')
  AND (DAt_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
  and (dat_DeAID = @DeAID OR @DeAID = 0 )
  and dat_trnid in (select trn_trnid from cdn.tranag
  where
  Trn_TypDokumentu = 312
  AND (trn_podid IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
  AND (TrN_Bufor = @Bufor OR @Bufor=2)
  AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
  AND (TrN_MagDocID = @MagID OR @MagID = 0)
  AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
  AND TrN_Rodzaj not in (302100, 305100, 301100)
  AND TrN_Bufor <> -1)
  order by trn_dataope
 END
 IF @MmM = 2  --Tylko rozchód
 BEGIN
  select Pod_Kod, DAt_WartoscTxt, DeA_Kod, DeA_Format, Trn_NumerPelny, Trn_NumerString,
  Trn_NumerNr, TrN_DataOpe, TrN_TrNID, CDN.TypDokumentu(TrN_TypDokumentu) as 'TrN_TypDok',
  TrN_Korekta, TrN_Bufor,
  CASE @zakazDostepuDoCenZakupu WHEN 1 THEN CASE cdn.UkrywajCeneDlaPozycjiDok(TrN_TypDokumentu) WHEN 1 THEN  NULL ELSE TrN_RazemNetto END ELSE TrN_RazemNetto END As TrN_RazemNetto,
  TrN_TypDokumentu, M.Mag_Symbol, TrN_Bufor, TrN_VaNId, TrN_DekId
  from cdn.DokAtrybuty
  join cdn.tranag on dat_trnid = trn_trnid
  JOIN cdn.Magazyny M ON M.Mag_MagId = TrN_MagZrdId
  join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid
  join cdn.defatrybuty on dea_deaid = dat_deaid
  where (dat_Wartosctxt LIKE @AtrWartosc OR @AtrWartosc = '')
  AND (DAt_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
  and (dat_DeAID = @DeAID OR @DeAID = 0 )
  and dat_trnid in (select trn_trnid from cdn.tranag
  where Trn_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
  AND (trn_podid IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
  AND (TrN_Bufor = @Bufor OR @Bufor=2)
  AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
  AND (TrN_MagZrdID = @MagID OR @MagID = 0)
  AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
  AND TrN_Rodzaj not in (302100, 305100, 301100)
  AND TrN_Bufor <> -1)
  order by trn_dataope
  GOTO KONIEC
 END
KONIEC:
 RETURN
END
