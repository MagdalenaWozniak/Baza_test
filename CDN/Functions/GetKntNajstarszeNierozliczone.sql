CREATE FUNCTION CDN.GetKntNajstarszeNierozliczone(@kntId int, @dokumentId int, @operatorId int)
RETURNS nvarchar(255)
AS
BEGIN
 DECLARE @dokumenty nvarchar(255)
 SELECT @dokumenty =
 (
  SELECT TOP 5 DKB_Numer + ' (' + CDN.FormatDecimalAmount(DKB_Kwota) + ' ' + CASE WHEN DKB_Waluta IS NULL OR LEN(DKB_Waluta) = 0 THEN 'PLN' ELSE DKB_Waluta END + '), '
  FROM CDN.DokumentyKBView
  WHERE DKB_PodmiotTyp = 1
  AND DKB_PodmiotId IN (SELECT Knt_KntId FROM CDN.Kontrahenci WHERE Knt_GlID = @kntId)
  AND DKB_TypDokumentuKB = 1
  AND DKB_Stan > 0
  AND DKB_Rozliczono = 1
  AND DKB_Kierunek = 1
  ORDER BY DKB_Termin, DKB_DokumentID, DKB_DKBID
  FOR XML PATH('')
 )
 RETURN 'Najstarsze nierozliczone dokumenty: ' + CASE WHEN LEN(@dokumenty) > 0 THEN SUBSTRING(@dokumenty, 1, LEN(@dokumenty)-1) ELSE 'Wszystkie dokumenty zostały rozliczone.' END
END
