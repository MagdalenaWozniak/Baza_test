CREATE PROCEDURE CDN.UWDParametr
 @Key  nvarchar(255),
 @Wartosc nvarchar(20) OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @sqltxt NVARCHAR(1024), @ParamDefinition NVARCHAR(512)
  --select ktx_value as UWDID from cdn.konfigtext where ktx_key = 'ADE.CurrentAccount.Login'
  --select ktx_value as UWDOddzial from cdn.konfigtext where ktx_key = 'ADE.CurrentDivision.Symbol'
  --  SET @Key = 'ADE.CurrentAccount.Login'
  --  SET @Key = 'ADE.CurrentDivision.Symbol'
  SET @ParamDefinition = N'@ADEKey nvarchar(128), @Wartosc nvarchar(20) OUTPUT';
  SET @sqltxt = 'SELECT @Wartosc = CAST(IsNull(KtX_Value, '''') As nvarchar(20)) FROM ' + CDN.BazaKonfiguracyjna() + '.CDN.KonfigText WHERE KtX_Key = @ADEKey;'
  EXEC sp_executesql @sqltxt, @ParamDefinition, @ADEKey=@Key ,@Wartosc=@Wartosc OUTPUT
  IF @Wartosc IS NULL
   SET @Wartosc = ''
  SET NOCOUNT OFF
END
