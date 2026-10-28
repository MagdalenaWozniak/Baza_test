CREATE PROCEDURE [CDN].[RO_GetPaymentTable]
 @Identyfikator int = 0
AS
BEGIN
SELECT
   CAST(FPl_Nazwa as varchar(64)) [Plt_Nazwa],
   CAST(CONVERT(date,TrN_Termin,120) as varchar(10)) [Plt_Termin]
 FROM CDN.TRANAG
 JOIN CDN.FormyPlatnosci ON TrN_FPlId = FPl_FPlId
 WHERE TRN_TRNID = @Identyfikator
 OPTION (RECOMPILE)
 RETURN 1;
END
