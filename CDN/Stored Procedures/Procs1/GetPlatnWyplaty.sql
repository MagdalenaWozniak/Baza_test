CREATE  PROCEDURE CDN.GetPlatnWyplaty
@WplID int
AS
BEGIN
  SELECT *
  FROM CDN.BnkZdarzenia
  JOIN CDN.FormyPlatnosci ON FPl_FPlID = BZd_FPlID
  JOIN CDN.DokDefinicje ON DDf_DDfID = BZd_DDfID
  WHERE BZd_DokumentTyp = 8 AND BZd_DokumentID = @WplID
END
