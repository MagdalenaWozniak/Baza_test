CREATE PROCEDURE CDN.Anonimizacja_PlatKasaBank_Stare_Nierozliczone(@id INT, @thresholdDate  DATE)
AS
BEGIN
 SELECT DISTINCT 1001  As TypDok, cdn.OptimaNazwaObiektu(1001, BZd_Kierunek) As TypDokDesc, 0 As Mode, BzD_BZDId As Id,
    CASE WHEN BZd_NumerObcy<>'' THEN BZd_NumerObcy ELSE CASE WHEN BZd_NumerPelny<>'' THEN BZd_NumerPelny ELSE CASE WHEN BZd_Opis <>'' THEN CAST(BZd_Opis As VARCHAR(30)) ELSE STR(BZD_BZDID) END END END As NumerDok,
 BZd_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
    FROM CDN.BnkZdarzenia
 WHERE BZd_DokumentTyp <> 8 AND BZd_Rozliczono > 0 AND (BZd_Rozliczono <> 2 OR BZd_Rozliczono2 <> 2) AND (BZd_PodmiotTyp = 1 AND BZd_PodmiotId = @id)
      AND BZd_DataDok <= @thresholdDate
 ORDER BY SekcjaId, TypDok, DataDok, Id
END
