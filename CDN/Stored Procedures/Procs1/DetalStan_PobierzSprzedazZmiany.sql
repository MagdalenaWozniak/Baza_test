CREATE PROCEDURE [CDN].[DetalStan_PobierzSprzedazZmiany]
@ShiftId int,
@PosId int,
@UserId int
AS
BEGIN
SET NOCOUNT ON
CREATE TABLE #TmpTable
(
 flpid int,
 FPlNazwa NVARCHAR(20),
 TypDok NVARCHAR(3),
 Kwota decimal(15, 2),
 nieaktywna tinyint
)
IF @UserId = 0
BEGIN
 INSERT INTO #TmpTable SELECT a.DSFPl_DSFPlId,
   a.DSFPl_Nazwa,
   CASE WHEN c.DSTrN_TypDokumentu = 305 THEN 'PA' ELSE 'PKA' END,
   CASE WHEN c.DSTrN_TypDokumentu = 305 AND
     ISNULL(c.DSTrN_Korekta,0) = 0 THEN b.DSPlD_Kwota ELSE  -b.DSPlD_Kwota END,
   a.DSFPl_Nieaktywny
 FROM CDN.DetalStanFormyPlatnosci a
  inner join CDN.DetalStanPlatnosciDokumentu b ON b.DSPlD_DSFPlId = a.DSFPl_DSFPlId
  inner join CDN.DetalStanTraNag c ON b.DSPlD_DSTrNId = c.DSTrN_DSTrNID
 WHERE (c.DSTrN_TypDokumentu = 305 OR c.DSTrN_TypDokumentu = 313
   OR c.DSTrN_TypDokumentu = 302 AND ISNULL(c.DSTrN_Korekta,0) = 1) AND
   c.DSTrN_Bufor = 0 AND c.DSTrN_ZmianaId = @ShiftId
-- INSERT INTO #TmpTable SELECT b.DSFPl_DSFPlId,
--   b.DSFPl_Nazwa,
--        CASE WHEN a.DSZKB_TypDokumentu = 1 THEN 'KP' ELSE 'KW' END,
--       CASE WHEN a.DSZKB_TypDokumentu = 1 THEN a.DSZKB_RazemBrutto ELSE -a.DSZKB_RazemBrutto END,
--          b.DSFPl_Nieaktywny
--      FROM CDN.DetalStanZapisyKB a
--       inner join CDN.DetalStanFormyPlatnosci b ON b.DSFPl_DSFPlId =  a.DSZKB_DSFPlId
--       WHERE a.DSZKB_ZmianaId = @ShiftId AND a.DSZKB_Bufor = 0
SELECT DSFPl_Nazwa AS FPl,
  isnull(sum(Kwota),convert(decimal(15,2),0)) AS Kwota,
  DSFPl_TypGotowka AS Gotowka,
  DSFPl_DFNr AS DFNr,
  DSFPl_Nieaktywny AS Nieaktywny
 FROM cdn.DetalStanFormyPlatnosci
  left join #TmpTable ON flpid= DSFPl_DSFPlId
 GROUP BY DSFPl_DSFPlId, DSFPl_Nazwa, DSFPl_Nieaktywny, DSFPl_TypGotowka, DSFPl_DFNr, DSFPl_StanDetalID
 HAVING (isnull(sum(Kwota),convert(decimal(15,2),0)) <> 0.0 AND DSFPl_Nieaktywny = 1 OR
 DSFPl_Nieaktywny = 0) AND DSFPl_StanDetalID = @PosId
END
ELSE
BEGIN
 INSERT INTO #TmpTable SELECT a.DSFPl_DSFPlId,
   a.DSFPl_Nazwa,
   CASE WHEN c.DSTrN_TypDokumentu = 305 THEN 'PA' ELSE 'PKA' END,
   CASE WHEN c.DSTrN_TypDokumentu = 305 AND
     ISNULL(c.DSTrN_Korekta,0) = 0 THEN b.DSPlD_Kwota ELSE  -b.DSPlD_Kwota END,
   a.DSFPl_Nieaktywny
 FROM CDN.DetalStanFormyPlatnosci a
 inner join CDN.DetalStanPlatnosciDokumentu b ON b.DSPlD_DSFPlId = a.DSFPl_DSFPlId
 inner join CDN.DetalStanTraNag c ON b.DSPlD_DSTrNId = c.DSTrN_DSTrNID
 WHERE (c.DSTrN_TypDokumentu = 305 OR c.DSTrN_TypDokumentu = 313 OR
 c.DSTrN_TypDokumentu = 302 AND ISNULL(c.DSTrN_Korekta,0) = 1)AND
   c.DSTrN_ZmianaId = @ShiftId AND c.DSTrN_Bufor = 0 AND DSTrN_OpeID = @UserId
-- INSERT INTO #TmpTable SELECT b.DSFPl_DSFPlId,
--   b.DSFPl_Nazwa,
--        CASE WHEN DSZKB_TypDokumentu = 1 THEN 'KP' ELSE 'KW' END,
--        CASE WHEN DSZKB_TypDokumentu = 1 THEN DSZKB_RazemBrutto ELSE -DSZKB_RazemBrutto END,
--           b.DSFPl_Nieaktywny
--      FROM CDN.DetalStanZapisyKB a
--       inner join CDN.DetalStanFormyPlatnosci b ON b.DSFPl_DSFPlId =  a.DSZKB_DSFPlId
--       WHERE a.DSZKB_ZmianaId = @ShiftId AND a.DSZKB_Bufor = 0 AND DSZKB_OpeID = @UserId
    SELECT  DSFPl_Nazwa AS FPl,
   isnull(sum(Kwota),convert(decimal(15,2),0)) AS Kwota,
   DSFPl_TypGotowka AS Gotowka,
   DSFPl_DFNr AS DFNr,
   DSFPl_Nieaktywny AS Nieaktywny
 FROM cdn.DetalStanFormyPlatnosci
  left join #TmpTable ON flpid= DSFPl_DSFPlId
 GROUP BY DSFPl_DSFPlId, DSFPl_Nazwa, DSFPl_Nieaktywny, DSFPl_TypGotowka, DSFPl_DFNr, DSFPl_StanDetalID
 HAVING (isnull(sum(Kwota),convert(decimal(15,2),0)) <> 0.0 AND DSFPl_Nieaktywny = 1
 OR DSFPl_Nieaktywny = 0) AND DSFPl_StanDetalID = @PosId
END
SET NOCOUNT OFF
END
