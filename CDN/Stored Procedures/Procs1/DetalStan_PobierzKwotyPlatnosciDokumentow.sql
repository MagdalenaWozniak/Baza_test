CREATE PROCEDURE [CDN].[DetalStan_PobierzKwotyPlatnosciDokumentow]
@PosId int,
@DateFrom datetime,
@DateTo datetime,
@WhichDocuments tinyint,-- 0 PA, 1 KP/KW, 2 All
@OpeId int
AS
BEGIN
SET NOCOUNT ON
CREATE TABLE #Platnosci (IdPlatnosci INT, NazwaPlatnosci NVARCHAR(20), Nieaktywna tinyint)
INSERT INTO #Platnosci (IdPlatnosci, NazwaPlatnosci, Nieaktywna)
exec [CDN].[DetalStan_FormyPlatnosciZestawienie] @PosId
CREATE TABLE #TmpTable
(
 flpid int,
 FPl NVARCHAR(20),
 TypDok NVARCHAR(3),
 Kwota decimal(15, 2),
 Data datetime,
 OpeId int,
 nieaktywna tinyint
)
-- tylko dla PA
IF @WhichDocuments = 0
BEGIN
 INSERT INTO #TmpTable SELECT d.Idplatnosci,
         d.NazwaPlatnosci,
         CASE WHEN a.DSTrN_TypDokumentu = 305 OR a.DSTrN_TypDokumentu = 302 THEN 'DOK' ELSE 'PKA' END,
         CASE WHEN a.DSTrN_TypDokumentu = 305 AND a.DSTrN_Korekta IS NULL THEN b.DSPlD_Kwota ELSE -b.DSPlD_Kwota END,
         b.DSPlD_DataPlatnosci,
         a.DSTrN_OpeID,
         d.Nieaktywna
       FROM CDN.DetalStanTraNag a
      INNER JOIN CDN.DetalStanPlatnosciDokumentu b
       ON b.DSPlD_DSTrNID = a.DSTrN_DSTrNID
       JOIN #platnosci d
       ON d.Idplatnosci =  b.DSPlD_DSFPlId
       WHERE (a.DSTrN_TypDokumentu = 305 OR
    a.DSTrN_TypDokumentu = 313 OR
    a.DSTrN_TypDokumentu = 302 AND a.DSTrN_Korekta = 1) AND
         a.DSTrN_Bufor = 0 AND
         a.DSTrN_StanDetalID = @PosId AND
         b.DSPlD_DataPlatnosci BETWEEN @DateFrom AND @DateTo AND
         ((a.DSTrN_OpeID = @OpeId AND 0 <> ISNULL(@OpeId,0)) OR (0=ISNULL(@OpeId,0)))
END
-- tylko dla KP/KW
ELSE IF @WhichDocuments = 1
BEGIN
 INSERT INTO #TmpTable SELECT d.Idplatnosci,
         d.NazwaPlatnosci,
        CASE WHEN DSZKB_TypDokumentu = 1 THEN 'KP' ELSE 'KW' END,
        CASE WHEN DSZKB_TypDokumentu = 1 THEN DSZKB_RazemBrutto ELSE -DSZKB_RazemBrutto END,
           a.DSZKB_DataDok,
           a.DSZKB_OpeID,
           d.Nieaktywna
      FROM CDN.DetalStanZapisyKB a
       JOIN #platnosci d ON d.Idplatnosci =  a.DSZKB_DSFPlId
       WHERE DSZKB_StanDetalID = @PosId AND
         DSZKB_Bufor = 0 AND
         a.DSZKB_DataDok BETWEEN @DateFrom AND @DateTo AND
         ((a.DSZKB_OpeID = @OpeId AND 0 <> ISNULL(@OpeId,0)) OR (0=ISNULL(@OpeId,0)))
END
-- razem dla PA/KP/KW
ELSE IF @WhichDocuments = 2
BEGIN
 INSERT INTO #TmpTable SELECT d.Idplatnosci,
         d.NazwaPlatnosci,
         CASE WHEN a.DSTrN_TypDokumentu = 305 OR a.DSTrN_TypDokumentu = 302 THEN 'DOK' ELSE 'PKA' END,
         CASE WHEN a.DSTrN_TypDokumentu = 305 AND a.DSTrN_Korekta IS NULL THEN b.DSPlD_Kwota ELSE -b.DSPlD_Kwota END,
         b.DSPlD_DataPlatnosci,
         a.DSTrN_OpeID,
         d.Nieaktywna
       FROM CDN.DetalStanTraNag a
      INNER JOIN CDN.DetalStanPlatnosciDokumentu b
       ON b.DSPlD_DSTrNID = a.DSTrN_DSTrNID
       JOIN #platnosci d
       ON d.Idplatnosci =  b.DSPlD_DSFPlId
       WHERE (a.DSTrN_TypDokumentu = 305 OR
    a.DSTrN_TypDokumentu = 313 OR
    a.DSTrN_TypDokumentu = 302 AND a.DSTrN_Korekta = 1) AND
         a.DSTrN_Bufor = 0 AND
         a.DSTrN_StanDetalID = @PosId AND
         b.DSPlD_DataPlatnosci BETWEEN @DateFrom AND @DateTo AND
         ((a.DSTrN_OpeID = @OpeId AND 0 <> ISNULL(@OpeId,0)) OR (0=ISNULL(@OpeId,0)))
 INSERT INTO #TmpTable SELECT d.Idplatnosci,
         d.NazwaPlatnosci,
        CASE WHEN DSZKB_TypDokumentu = 1 THEN 'KP' ELSE 'KW' END,
        CASE WHEN DSZKB_TypDokumentu = 1 THEN DSZKB_RazemBrutto ELSE -DSZKB_RazemBrutto END,
           a.DSZKB_DataDok,
           a.DSZKB_OpeID,
           d.Nieaktywna
      FROM CDN.DetalStanZapisyKB a
       JOIN #platnosci d ON d.Idplatnosci =  a.DSZKB_DSFPlId
       WHERE DSZKB_StanDetalID = @PosId AND
         DSZKB_Bufor = 0 AND
         a.DSZKB_DataDok BETWEEN @DateFrom AND @DateTo AND
         ((a.DSZKB_OpeID = @OpeId AND 0 <> ISNULL(@OpeId,0)) OR (0=ISNULL(@OpeId,0)))
END
--usunięcie nieaktywnych z 0zł
DELETE FROM #tmptable WHERE flpid IN (SELECT flpid FROM #tmptable WHERE nieaktywna = 1
 GROUP BY flpid HAVING isnull(sum(kwota),convert(decimal(15,2),0)) = 0.0)
SELECT DSFPl_Nazwa AS FPl, isnull(sum(Kwota),convert(decimal(15,2),0)) AS Kwota FROM cdn.detalstanformyplatnosci
left join #TmpTable ON flpid= DSFPl_DSFPlId
GROUP BY DSFPl_DSFPlId, DSFPl_Nazwa, DSFPl_Nieaktywny, DSFPl_StanDetalID
HAVING (isnull(sum(Kwota),convert(decimal(15,2),0)) <> 0.0 AND DSFPl_Nieaktywny = 1 OR
DSFPl_Nieaktywny = 0) AND DSFPl_StanDetalID = @PosId
SET NOCOUNT OFF
END
