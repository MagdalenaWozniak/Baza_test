CREATE FUNCTION CDN.KorektyKPR(@Data DateTime, @KPRID Int)
RETURNS @Result TABLE( BzdId Int )
AS
BEGIN
INSERT INTO @Result
SELECT BZd_BZdID
FROM CDN.BnkZdarzenia
  JOIN CDN.VatNag  ON (VaN_VaNID = BZd_DokumentID AND BZd_DokumentTyp = 2)
  JOIN CDN.ZapisyKPR ON VaN_KpRID = KPR_KPRID
WHERE KPR_DataOpe BETWEEN CONVERT(datetime, '2013-01-01', 120) AND @Data
   AND (BZd_Rozliczono = 1
   --OR (BZd_Rozliczono2 = 2 AND BZd_Rozliczono = 1)
   OR BZd_DataRoz > @Data
   OR (SELECT TOP 1 DPD_Rozliczono FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID AND DPD_KPRID <> @KPRID ORDER BY DPD_Rozliczono DESC) = 0
   )
UNION
SELECT BZd_BZdID
FROM CDN.BnkZdarzenia
  JOIN CDN.EwidDodNag  ON (EDN_EDNID = BZd_DokumentID AND BZd_DokumentTyp = 12)
  JOIN CDN.ZapisyKPR ON EDN_KPRId = KPR_KPRID
WHERE KPR_DataOpe BETWEEN CONVERT(datetime, '2013-01-01', 120) AND @Data
   AND (BZd_Rozliczono = 1
   --OR (BZd_Rozliczono2 = 2 AND BZd_Rozliczono = 1)
   OR BZd_DataRoz > @Data
   OR (SELECT TOP 1 DPD_Rozliczono FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID AND DPD_KPRID <> @KPRID ORDER BY DPD_Rozliczono DESC) = 0
   )
UNION
SELECT BZd_BZdID
FROM CDN.BnkZdarzenia
  JOIN CDN.TraNag ON (TrN_TrNId = BZd_DokumentID AND BZd_DokumentTyp = 1)
  JOIN CDN.VatNag ON TrN_VaNId = VaN_VaNID
  JOIN CDN.ZapisyKPR ON VaN_KpRID = KPR_KPRID
WHERE KPR_DataOpe BETWEEN CONVERT(datetime, '2013-01-01', 120) AND @Data
   AND (BZd_Rozliczono = 1
   --OR (BZd_Rozliczono2 = 2 AND BZd_Rozliczono = 1)
   OR BZd_DataRoz > @Data
   OR (SELECT TOP 1 DPD_Rozliczono FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID AND DPD_KPRID <> @KPRID ORDER BY DPD_Rozliczono DESC) = 0
   )
   AND TrN_TypDokumentu IN (301, 313)
RETURN
END
