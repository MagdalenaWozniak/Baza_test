CREATE PROCEDURE CDN.SymbolWalSys
@WalSys   varchar(3) OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @sqltxt NVARCHAR(512)
  DECLARE @ParamDefinition NVARCHAR(32)
  SET @sqltxt = N'SELECT @symbol = WNa_Symbol FROM ' + CDN.BazaKonfiguracyjna() + '.cdn.WalNazwy WHERE WNa_WNaID=1'
  SET @ParamDefinition = N'@symbol varchar(3) OUTPUT';
  EXEC sp_executeSql @sqltxt, @ParamDefinition, @symbol=@WalSys OUTPUT
  SET NOCOUNT OFF
END
