CREATE PROCEDURE CDN.KrdDeleteNoActualItems
AS
BEGIN
 DECLARE @todaySub90 DATETIME
 SET @todaySub90 = DATEADD(DAY, -90, GetDate());
 UPDATE CDN.KRD SET KRD_DataOdczytuStatusu = NULL, KRD_Status = NULL, KRD_RaportId = NULL WHERE KRD_DataOdczytuStatusu < @todaySub90
END
