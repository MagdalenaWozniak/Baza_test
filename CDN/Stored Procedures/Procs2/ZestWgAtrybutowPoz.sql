CREATE PROCEDURE [CDN].[ZestWgAtrybutowPoz]
@DeAID INT, @TypDok TEXT, @PodID INT, @PodTyp INT, @Bufor INT, @MagID INT, @OpeID INT, @TwrID INT, @AtrWartosc NVARCHAR(102), @AtrWartoscOd DECIMAL(16,4), @AtrWartoscDo DECIMAL(16,4), @DataOd DATETIME, @DataDo DATETIME, @MmM INT, @zakazDostepuDoCenZakupu TINYINT
AS
BEGIN
 SET NOCOUNT ON
 IF @MmM = 0  --
 BEGIN
  SELECT
  T.TrN_TrnId,T.TrN_DataOpe,T.Trn_NumerPelny, T.Trn_NumerString, T.Trn_NumerNr, T.TrN_TypDokumentu,CDN.TypDokumentu(T.TrN_TypDokumentu) As 'TypDok',T.TrN_Korekta,
  P.Pod_Kod, M.Mag_Symbol,
  A.TrE_TwrKod, A.TrE_TwrNazwa, A.TrE_JM, A.TrE_IloscJM,
  CASE @zakazDostepuDoCenZakupu WHEN 1 THEN CASE cdn.UkrywajCeneDlaPozycjiDok(T.TrN_TypDokumentu) WHEN 1 THEN  NULL ELSE A.TrE_WartoscNetto END ELSE A.TrE_WartoscNetto END As TrE_WartoscNetto,
  A.TrA_TrEId, A.TrA_DeaId, A.TrA_Kod, A.TrA_Wartosc,A.Tre_TwrID,
  D.DeA_Format
  FROM cdn.TrEAtrybutyView A
  JOIN cdn.TraNag T on A.TrE_TrnId = T.TrN_TrNId
  JOIN cdn.PodmiotyView P ON P.Pod_PodmiotTyp = T.TrN_PodmiotTyp AND P.Pod_PodId = T.TrN_PodId
  JOIN cdn.Magazyny M ON M.Mag_MagId = T.TrN_MagZrdId OR M.Mag_MagId = T.TrN_MagDocId
  JOIN CDN.DefAtrybuty D on A.Tra_DeAId = D.DeA_DeAId
  WHERE 1=1
  AND (A.TrA_Wartosc LIKE @AtrWartosc OR @AtrWartosc = '')
  AND (A.TrA_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
  AND (TrA_DeAID = @DeAID OR @DeAID = 0)
  AND (TrE_TwrID = @TwrID OR @TwrID = 0)
  AND  TrN_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
  AND ((TrN_PodId IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND TrN_PodmiotTyp = @PodTyp) OR @PodTyp = 0)
  AND (TrN_Bufor = @Bufor OR @Bufor=2)
  AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
  AND (TrN_MagZrdID = @MagID OR TrN_MagDocID = @MagID OR @MagID = 0)
  AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
  AND TrN_Rodzaj not in (302100, 305100, 301100, 302200, 302202)
  AND TrN_Bufor <> -1
  ORDER by 3, 1, 9
 END
    IF @MmM = 1  --Tylko przychód
 BEGIN
  SELECT
  T.TrN_TrnId,T.TrN_DataOpe, T.Trn_NumerPelny, T.Trn_NumerString, T.Trn_NumerNr, T.TrN_TypDokumentu,CDN.TypDokumentu(T.TrN_TypDokumentu) As 'TypDok',T.TrN_Korekta,
  P.Pod_Kod, M.Mag_Symbol,
  A.TrE_TwrKod, A.TrE_TwrNazwa, A.TrE_JM, A.TrE_IloscJM,
  CASE @zakazDostepuDoCenZakupu WHEN 1 THEN CASE cdn.UkrywajCeneDlaPozycjiDok(T.TrN_TypDokumentu) WHEN 1 THEN  NULL ELSE A.TrE_WartoscNetto END ELSE A.TrE_WartoscNetto END As TrE_WartoscNetto,
  A.TrA_TrEId, A.TrA_DeaId, A.TrA_Kod, A.TrA_Wartosc,A.Tre_TwrID,
  D.DeA_Format
  FROM cdn.TrEAtrybutyView A
  JOIN cdn.TraNag T on A.TrE_TrnId = T.TrN_TrNId
  JOIN cdn.PodmiotyView P ON P.Pod_PodmiotTyp = T.TrN_PodmiotTyp AND P.Pod_PodId = T.TrN_PodId
  JOIN cdn.Magazyny M ON M.Mag_MagId = T.TrN_MagZrdId
  JOIN CDN.DefAtrybuty D on A.Tra_DeAId = D.DeA_DeAId
  WHERE 1=1
  AND (A.TrA_Wartosc LIKE @AtrWartosc OR @AtrWartosc = '')
  AND (A.TrA_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
  AND (TrA_DeAID = @DeAID OR @DeAID = 0)
  AND (TrE_TwrID = @TwrID OR @TwrID = 0)
  AND  Trn_TypDokumentu <> 312 AND Trn_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
  AND ((TrN_PodId IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND TrN_PodmiotTyp = @PodTyp) OR @PodTyp = 0)
  AND (TrN_Bufor = @Bufor OR @Bufor=2)
  AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
  AND (TrN_MagDocID = @MagID OR @MagID = 0)
  AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
  AND TrN_Rodzaj not in (302100, 305100, 301100, 302200, 302202)
  AND TrN_Bufor <> -1
  UNION
  SELECT
  T.TrN_TrnId,T.TrN_DataOpe,T.Trn_NumerPelny, T.Trn_NumerString, T.Trn_NumerNr, T.TrN_TypDokumentu,CDN.TypDokumentu(T.TrN_TypDokumentu) As 'TypDok',T.TrN_Korekta,
  P.Pod_Kod, M.Mag_Symbol,
  A.TrE_TwrKod, A.TrE_TwrNazwa, A.TrE_JM, A.TrE_IloscJM,
  CASE @zakazDostepuDoCenZakupu WHEN 1 THEN CASE cdn.UkrywajCeneDlaPozycjiDok(T.TrN_TypDokumentu) WHEN 1 THEN  NULL ELSE A.TrE_WartoscNetto END ELSE A.TrE_WartoscNetto END As TrE_WartoscNetto,
  A.TrA_TrEId, A.TrA_DeaId, A.TrA_Kod, A.TrA_Wartosc,A.Tre_TwrID,
  D.DeA_Format
  FROM cdn.TrEAtrybutyView A
  JOIN cdn.TraNag T on A.TrE_TrnId = T.TrN_TrNId
  JOIN cdn.PodmiotyView P ON P.Pod_PodmiotTyp = T.TrN_PodmiotTyp AND P.Pod_PodId = T.TrN_PodId
  JOIN cdn.Magazyny M ON M.Mag_MagId = T.TrN_MagDocId
  JOIN CDN.DefAtrybuty D on A.Tra_DeAId = D.DeA_DeAId
  WHERE 1=1
  AND (A.TrA_Wartosc LIKE @AtrWartosc OR @AtrWartosc = '')
  AND (A.TrA_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
  AND (TrA_DeAID = @DeAID OR @DeAID = 0)
  AND (TrE_TwrID = @TwrID OR @TwrID = 0)
  AND  TrN_TypDokumentu = 312
  AND ((TrN_PodId IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND TrN_PodmiotTyp = @PodTyp) OR @PodTyp = 0)
  AND (TrN_Bufor = @Bufor OR @Bufor=2)
  AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
  AND (TrN_MagDocID = @MagID OR @MagID = 0)
  AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
  AND TrN_Rodzaj not in (302100, 305100, 301100, 302200, 302202)
  AND TrN_Bufor <> -1
  ORDER by 3, 1, 9
 END
 IF @MmM = 2  --Tylko rozchód
 BEGIN
  SELECT
  T.TrN_TrnId,T.TrN_DataOpe, T.Trn_NumerPelny, T.Trn_NumerString, T.Trn_NumerNr, T.TrN_TypDokumentu,CDN.TypDokumentu(T.TrN_TypDokumentu) As 'TypDok',T.TrN_Korekta,
  P.Pod_Kod, M.Mag_Symbol,
  A.TrE_TwrKod, A.TrE_TwrNazwa, A.TrE_JM, A.TrE_IloscJM,
  CASE @zakazDostepuDoCenZakupu WHEN 1 THEN CASE cdn.UkrywajCeneDlaPozycjiDok(T.TrN_TypDokumentu) WHEN 1 THEN  NULL ELSE A.TrE_WartoscNetto END ELSE A.TrE_WartoscNetto END As TrE_WartoscNetto,
  A.TrA_TrEId, A.TrA_DeaId, A.TrA_Kod, A.TrA_Wartosc,A.Tre_TwrID,
  D.DeA_Format
  FROM cdn.TrEAtrybutyView A
  JOIN cdn.TraNag T on A.TrE_TrnId = T.TrN_TrNId
  JOIN cdn.PodmiotyView P ON P.Pod_PodmiotTyp = T.TrN_PodmiotTyp AND P.Pod_PodId = T.TrN_PodId
  JOIN cdn.Magazyny M ON M.Mag_MagId = TrN_MagZrdId
  JOIN CDN.DefAtrybuty D on A.Tra_DeAId = D.DeA_DeAId
  WHERE 1=1
  AND (A.TrA_Wartosc LIKE @AtrWartosc OR @AtrWartosc = '')
  AND (A.TrA_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
  AND (TrA_DeAID = @DeAID OR @DeAID = 0)
  AND (TrE_TwrID = @TwrID OR @TwrID = 0)
  AND  TrN_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
  AND ((TrN_PodId IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND TrN_PodmiotTyp = @PodTyp) OR @PodTyp = 0)
  AND (TrN_Bufor = @Bufor OR @Bufor=2)
  AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
  AND (TrN_MagZrdID = @MagID OR @MagID = 0)
  AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
  AND TrN_Rodzaj not in (302100, 305100, 301100, 302200, 302202)
  AND TrN_Bufor <> -1
  ORDER by 3, 1, 9
 END
KONIEC:
 RETURN
END
