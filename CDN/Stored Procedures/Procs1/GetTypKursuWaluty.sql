CREATE PROCEDURE CDN.GetTypKursuWaluty @Wku_Symbol nvarchar(5), @ConfigDBName nvarchar(50), @ServerName nvarchar(50)
AS
BEGIN
 DECLARE @sqltxt NVARCHAR (1000), @WkuID int;
 IF(ISNULL(@Wku_Symbol, '') = '') -- pobieramy domyślny typ kursu waluty
 BEGIN
  SET @sqltxt = 'SELECT @WKu_SymbolOUT=IsNull(WkU_Symbol, ''<-->'') FROM ['+@ServerName+'].['+@ConfigDBName+'].CDN.WalKursy INNER JOIN ['+@ServerName+'].['+@ConfigDBName+'].CDN.Konfig ON Kon_Wartosc=WKu_WKuID WHERE Kon_Numer=260'
  EXEC sp_executesql @sqltxt, N'@WKu_SymbolOUT nvarchar(5) OUTPUT', @WKu_SymbolOUT=@WKu_Symbol OUTPUT
 END
 ELSE
 BEGIN
  IF(@Wku_Symbol = '--' OR @Wku_Symbol = 'NIE')
   SET @Wku_Symbol = '<' + @Wku_Symbol + '>'
 END
    SET @sqltxt = 'select @WkuID_OUT=Wku_WkuID FROM ['+@ServerName+'].[' + @ConfigDBName + ']' +
   '.[CDN].[WalKursy] WHERE WkU_Symbol =' + ''''+ @Wku_Symbol + ''''
 EXEC sp_executesql @sqltxt, N'@WkuID_OUT INT OUTPUT', @WkuID_OUT=@WKuID OUTPUT
 RETURN @WkuID
END
