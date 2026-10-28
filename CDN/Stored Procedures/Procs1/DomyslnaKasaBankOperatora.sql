CREATE PROCEDURE [CDN].[DomyslnaKasaBankOperatora]
  @ServerCfgString  NVARCHAR(200),
  @BazaCfgString    NVARCHAR(200),
  @OpeId            INT,
  @DomyslnaKasa     NVARCHAR(20) OUTPUT,
  @DomyslnyBank     NVARCHAR(20) OUTPUT
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
  SET @SelectString = 'SELECT TOP 1 @Kasa = Ope_Kasa, @Bank = Ope_Bank FROM ' + @FullKnfName + 'CDN.Operatorzy WHERE Ope_OpeId = @ID'
        EXEC sp_executesql @SelectString, N'@ID INT, @Kasa NVARCHAR(20) OUT, @Bank NVARCHAR(20) OUT', @ID = @OpeID, @Kasa = @DomyslnaKasa OUTPUT, @Bank = @DomyslnyBank OUTPUT
 SET NOCOUNT OFF
END
