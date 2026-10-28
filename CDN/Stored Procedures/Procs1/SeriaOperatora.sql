CREATE PROCEDURE CDN.SeriaOperatora
  @ServerCfgString  NVARCHAR(200),
  @BazaCfgString    NVARCHAR(200),
  @OpeId            INT,
  @Seria            NVARCHAR(5) OUTPUT,
  @Rejestr          NVARCHAR(20) OUTPUT
AS
BEGIN
 SET NOCOUNT ON
  DECLARE
        @FullKnfName sysname,
        @SelectString NVARCHAR(200)
        IF @ServerCfgString <> @@ServerName
          SET @FullKnfName = '[' +   @ServerCfgString    + '].[' +   @BazaCfgString  + '].'
        ELSE
          SET @FullKnfName = '[' + @BazaCfgString  + '].'
          SET @SelectString = ' SELECT TOP 1 Ope_SymbolDlaNumeracji, Ope_Kasa FROM ' + @FullKnfName + 'CDN.Operatorzy WHERE Ope_OpeId = ' + CONVERT(NVARCHAR(20), @OpeId)
        -- przerzucenie wyniku do zmiennej poprzez tabelę tymczasową
        CREATE TABLE #Ope (OpeString NVARCHAR(5), OpeRejestr NVARCHAR(20))
        INSERT #Ope EXEC sp_executeSQL @SelectString
        SELECT TOP 1
          @Seria   = OpeString,
          @Rejestr = OpeRejestr
        FROM #Ope
        DROP TABLE #Ope
 SET NOCOUNT OFF
END
