CREATE PROCEDURE CDN.AktualizujCenyPoImporcie
AS
BEGIN
 SET NOCOUNT ON ;
   -- wykasuj te ceny, które nie istnieją w konfiguracji
   delete cdn.TwrCeny
   from cdn.TwrCeny left join cdn.DefCeny on TwC_TwCNumer = DfC_Lp
   where DfC_Lp Is NULL
   -- dodaj nowe ceny
   DECLARE @DfcLp INT
   DECLARE CfgCenyIn CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    SELECT DISTINCT Dfc_LP FROM [CDN].[DefCeny] WHERE IsNull(DfC_Nieaktywna,0)=0 ORDER BY Dfc_LP
   OPEN CfgCenyIn
   WHILE 1=1
   BEGIN
    FETCH NEXT FROM CfgCenyIn INTO @DfcLp
    IF @@FETCH_STATUS <> 0 BREAK
    exec cdn.AktualizujCennik @DfcLp,0
   END
   CLOSE  CfgCenyIn
   DEALLOCATE CfgCenyIn
 SET NOCOUNT OFF
END
