CREATE PROCEDURE CDN.ImportWNa
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@WNa_Symbol nvarchar(3),
@WNa_Nazwa nvarchar(40),
@WNa_Kraj nvarchar(40),
@WNa_Slownie1 nvarchar(40),
@WNa_Slownie2 nvarchar(40),
@WNa_Nieaktualizowana int,
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
 DECLARE  @sqltxt NVARCHAR (1000),
   @inserttxt nvarchar(1000),
   @updatetxt nvarchar(1000),
   @TmpSrvName SYSNAME,
   @Count int
 SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
 IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
 SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
 SET @sqltxt = 'SELECT count(*) as licz FROM ['
 IF @ServerName <> @TmpSrvName
         SET @sqltxt = @sqltxt + @ConfigDBName + '].['
        SET @sqltxt = @sqltxt + @ConfigDBName + ']' + '.[CDN].[WalNazwy] WHERE WNa_Symbol ='''+ @WNa_Symbol + ''''
 CREATE TABLE #Licznik (licz INT)
 INSERT INTO #Licznik (licz)
 EXEC sp_executesql @sqltxt
 SELECT @Count = licz FROM #Licznik
 DROP TABLE #Licznik
 IF(@Count = 0)
 BEGIN
  SET @inserttxt =
  'INSERT INTO [' + @ServerName + '].[' + @ConfigDBName + '].CDN.WalNazwy
  (
   WNa_Symbol,
   WNa_Nazwa,
   WNa_Kraj,
   WNa_Slownie1,
   WNa_Slownie2,
   WNa_Nieaktualizowana,
   WNa_Parytet,
   WNa_KontoWn,
   WNa_KontoMa,
   WNa_TS_Zal,
   WNa_TS_Mod,
   WNa_OpeModID,
   WNa_OpeModKod,
   WNa_OpeModNazwisko,
   WNa_OpeZalID,
   WNa_OpeZalKod,
   WNa_OpeZalNazwisko,
   WNa_TS_Export
  )
  VALUES
  (
   ''' + @WNa_Symbol + ''',
   ''' + @WNa_Nazwa + ''',
   ''' + @WNa_Kraj + ''',
   ''' + @WNa_Slownie1 + ''',
   ''' + @WNa_Slownie2 + ''',
   ''' + convert(nvarchar,@WNa_Nieaktualizowana) + ''',
   0,
   '''',
   '''',
   GETDATE(),
   GETDATE(), ' +
   convert(nvarchar, @OpeId) + ',' +
   '''' + @OpeModKod + ''',' +
   '''' + @OpeModNazwisko + ''',' +
   convert(nvarchar, @OpeId) + ','+
   '''' + @OpeModKod + ''',' +
   '''' + @OpeModNazwisko + ''',' +
   'GETDATE()
  )'
  EXEC sp_executesql @inserttxt
  SET @SlowId = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
 END ELSE IF (@OnlyNew <> 1)
 BEGIN
  DECLARE @getIDSqlTxt nvarchar (1000)
  SET @getIDSqlTxt =
   'SELECT WNa_WNaID
   FROM ['  + @ServerName + '].[' + @ConfigDBName + '].CDN.WalNazwy
    WHERE WNa_Symbol = ''' + @WNa_Symbol + ''''
  CREATE TABLE #WNa(WNaID int)
  INSERT INTO #WNa(WNaID)
  EXEC sp_executesql @getIDSqlTxt
  SELECT @SlowID = WNaID FROM #WNa
  DROP TABLE #WNa
  SET @updatetxt =
  'UPDATE [' + @ServerName + '].[' + @ConfigDBName + '].CDN.WalNazwy
  SET
  WNa_Nazwa =''' + @WNa_Nazwa + ''',
  WNa_Kraj =''' + @WNa_Kraj + ''',
  WNa_Slownie1 =''' + @WNa_Slownie1 + ''',
  WNa_Slownie2 =''' + @WNa_Slownie2 + ''',
  WNa_Nieaktualizowana =''' + convert(nvarchar,@WNa_Nieaktualizowana) + ''',
  WNa_TS_Mod = GETDATE(),
  WNa_OpeModID = ' + convert(nvarchar, @OpeId) + ',
  WNa_OpeModKod = ''' + @OpeModKod + ''',
  WNa_OpeModNazwisko = ''' + @OpeModNazwisko + '''
  WHERE WNa_WNaID = ' + convert(nvarchar(10), @SlowID)
  EXEC sp_executesql @updatetxt
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
 END
 ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
 BEGIN
  --DECLARE @sqlTxt nvarchar (1000)
  SET @sqlTxt =
   'EXEC ['  + @ServerName + '].[' + @ConfigDBName + '].[CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 4005,
    @ObiektSubTyp = 0,
    @ObiektID = ' + convert(nvarchar, @SlowID) + ',
    @ObiektNazwa = ''' + @WNa_Symbol + ''',
    @OperacjaTyp = ' + convert(nvarchar, @OperationType) + ',
    @Opis = '''''
  EXEC sp_executesql @sqlTxt
 END
END
