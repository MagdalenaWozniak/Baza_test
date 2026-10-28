CREATE FUNCTION CDN.KorektyKH(@Data DateTime, @Okres Int)
RETURNS @Result TABLE( BzdId Int )
AS
BEGIN
DECLARE @DataOtwarcia DateTime
DECLARE @DataKoncowa DateTime
SET @DataOtwarcia = (SELECT OOb_DataOtw FROM CDN.OkresyObrach WHERE OOb_OObID = @Okres)
SET @DataKoncowa = (SELECT OOb_DataKoncowa FROM CDN.OkresyObrach WHERE OOb_OObID = @Okres)
IF @DataOtwarcia >= CONVERT(datetime, '2013-01-01', 120)
INSERT INTO @Result
SELECT BZd_BZdID
FROM CDN.BnkZdarzenia
  JOIN CDN.VatNag  ON (VaN_VaNID = BZd_DokumentID AND BZd_DokumentTyp = 2)
  JOIN CDN.DekretyNag  ON VaN_DekID = DeN_DeNId
WHERE DeN_DataDok BETWEEN CONVERT(datetime, '2013-01-01', 120) AND @Data
   AND (BZd_Rozliczono = 1
   --OR (BZd_Rozliczono2 = 2 AND BZd_Rozliczono = 1)
   OR BZd_DataRoz > @Data
   OR (SELECT TOP 1 DPD_Rozliczono FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID ORDER BY DPD_Rozliczono DESC) = 0
   )
   --AND DeN_DataDok BETWEEN @DataOtwarcia AND @DataKoncowa
   AND ((DeN_DataDok >= @DataOtwarcia AND @DataOtwarcia <= CONVERT(datetime, '2013-12-31', 120)) OR @DataOtwarcia >= CONVERT(datetime, '2014-01-01', 120))
   AND exists(select * from CDN.DekretyKonta join CDN.Konta on (Acc_KorektaKosztow <> 0 and Acc_AccId = DeK_AccID) where DeK_DeNId = DeN_DeNId)
UNION
SELECT BZd_BZdID
FROM CDN.BnkZdarzenia
  JOIN CDN.EwidDodNag  ON (EDN_EDNID = BZd_DokumentID AND BZd_DokumentTyp = 12)
  JOIN CDN.DekretyNag ON EDN_DekID = DeN_DeNId
WHERE DeN_DataDok BETWEEN CONVERT(datetime, '2013-01-01', 120) AND @Data
   AND (BZd_Rozliczono = 1
   --OR (BZd_Rozliczono2 = 2 AND BZd_Rozliczono = 1)
   OR BZd_DataRoz > @Data
   OR (SELECT TOP 1 DPD_Rozliczono FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID ORDER BY DPD_Rozliczono DESC) = 0
   )
   --AND DeN_DataDok BETWEEN @DataOtwarcia AND @DataKoncowa
   AND ((DeN_DataDok >= @DataOtwarcia AND @DataOtwarcia <= CONVERT(datetime, '2013-12-31', 120)) OR @DataOtwarcia >= CONVERT(datetime, '2014-01-01', 120))
   AND exists(select * from CDN.DekretyKonta join CDN.Konta on (Acc_KorektaKosztow <> 0 and Acc_AccId = DeK_AccID) where DeK_DeNId = DeN_DeNId)
UNION
SELECT BZd_BZdID
FROM CDN.BnkZdarzenia
  JOIN CDN.TraNag  ON (TrN_TrNID = BZd_DokumentID AND BZd_DokumentTyp = 1)
  JOIN CDN.DekretyNag ON TrN_DekId = DeN_DeNId
WHERE DeN_DataDok BETWEEN CONVERT(datetime, '2013-01-01', 120) AND @Data
   AND (BZd_Rozliczono = 1
   --OR (BZd_Rozliczono2 = 2 AND BZd_Rozliczono = 1)
   OR BZd_DataRoz > @Data
   OR (SELECT TOP 1 DPD_Rozliczono FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID ORDER BY DPD_Rozliczono DESC) = 0
   )
   AND TrN_TypDokumentu IN (301, 313)
   --AND DeN_DataDok BETWEEN @DataOtwarcia AND @DataKoncowa
   AND ((DeN_DataDok >= @DataOtwarcia AND @DataOtwarcia <= CONVERT(datetime, '2013-12-31', 120)) OR @DataOtwarcia >= CONVERT(datetime, '2014-01-01', 120))
   AND exists(select * from CDN.DekretyKonta join CDN.Konta on (Acc_KorektaKosztow <> 0 and Acc_AccId = DeK_AccID) where DeK_DeNId = DeN_DeNId)
RETURN
END
