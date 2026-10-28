CREATE PROCEDURE CDN.ImportWKu
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@WKu_Symbol nvarchar(5),
@WKu_Nazwa nvarchar(40),
@WKu_URL nvarchar(254),
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @OperationType INT
 SET @OperationType = 0
 DECLARE @sqltxt NVARCHAR (1000),
   @inserttxt nvarchar(1000),
   @updatetxt nvarchar(1000),
   @TmpSrvName SYSNAME,
   @Count int
 SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
 IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
 SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
 SET @sqltxt = 'SELECT count(*) as licz FROM ['
 IF @ServerName <> @TmpSrvName
         SET @sqltxt = @sqltxt + @ServerName + '].['
        SET @sqltxt = @sqltxt + @ConfigDBName + ']' + '.[CDN].[WalKursy] WHERE WkU_Symbol ='''+ @Wku_Symbol + ''''
 CREATE TABLE #Licznik (licz INT)
 INSERT INTO #Licznik (licz)
 EXEC sp_executesql @sqltxt
 SELECT @Count = licz FROM #Licznik
 DROP TABLE #Licznik
 IF(@Count = 0)
 BEGIN
  SET @inserttxt =
  'INSERT INTO [' + @ServerName + '].[' + @ConfigDBName + '].[CDN].[WalKursy]
  (
  WKu_Symbol,
  WKu_Nazwa,
  WKu_URL,
  WKu_TS_Zal,
  WKu_TS_Mod,
  WKu_OpeModId,
  WKu_OpeModKod,
  WKu_OpeModNazwisko,
  WKu_OpeZalId,
  WKu_OpeZalKod,
  WKu_OpeZalNazwisko,
  WKu_TS_Export,
  WkU_NieAktywny
  )
  VALUES
  ('''
  + @WKu_Symbol + ''',''' +
  + @WKu_Nazwa + ''',''' +
  + @WKu_URL + ''',' +
  'GETDATE(),
  GETDATE(), ' +
  convert(nvarchar, @OpeId) + ',' +
  '''' + @OpeModKod + ''',' +
  '''' + @OpeModNazwisko + ''',' +
  convert(nvarchar, @OpeId) + ','+
  '''' + @OpeModKod + ''',' +
  '''' + @OpeModNazwisko + ''',' +
  'GETDATE(),
  0
  )'
  EXEC sp_executesql @inserttxt
  SET @SlowId = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
 END
 ELSE IF(@OnlyNew <> 1)
 BEGIN
  DECLARE @getIDSqlTxt nvarchar (1000)
  SET @getIDSqlTxt =
   'SELECT WKu_WKuID
   FROM ['  + @ServerName + '].[' + @ConfigDBName + '].CDN.WalKursy
   WHERE WKu_Symbol = ''' + @WKu_Symbol + ''''
   CREATE TABLE #WKu(WKuID int)
   INSERT INTO #WKu(WKuID)
   EXEC sp_executesql @getIDSqlTxt
   SELECT @SlowID = WKuID FROM #WKu
   DROP TABLE #WKu
  SET @updatetxt =
  'UPDATE [' + @ServerName + '].[' + @ConfigDBName + '].[CDN].[WalKursy]
  SET
  WKu_Nazwa = ''' + @WKu_Nazwa + ''',
  WKu_URL = ''' + @WKu_URL + ''',
  WKu_TS_Zal = GETDATE(),
  WKu_TS_Mod = GETDATE(),
  WKU_OpeModId = ' + convert(nvarchar, @OpeId) + ',
  WKU_OpeModKod = ''' + @OpeModKod + ''',
  WKU_OpeModNazwisko = ''' + @OpeModNazwisko + '''
  WHERE WKu_WKuID = ' + convert(nvarchar, @SlowID)
  EXEC sp_executesql @updatetxt
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
 END
 ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
 BEGIN
  SET @sqlTxt =
   'EXEC ['  + @ServerName + '].[' + @ConfigDBName + '].[CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 4006,
    @ObiektSubTyp = 0,
    @ObiektID = ' + convert(nvarchar, @SlowID) + ',
    @ObiektNazwa = ''' + @WKu_Symbol + ''',
    @OperacjaTyp = ' + convert(nvarchar, @OperationType) + ',
    @Opis = '''''
  EXEC sp_executesql @sqlTxt
 END
END
