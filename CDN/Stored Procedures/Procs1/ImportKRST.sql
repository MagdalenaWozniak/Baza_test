CREATE PROCEDURE CDN.ImportKRST
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@KRST_Standardowa tinyint,
@KRST_Symbol nvarchar(5),
@KRST_Nazwa nvarchar(1024),
@KRST_Pozycja varchar(2),
@KRST_Stawka DECIMAL(5,2),
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
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
        SET @sqltxt = @sqltxt + @ConfigDBName + ']' + '.[CDN].[KRST] WHERE KRST_StaraWersja = '''' AND KRST_Standardowa = ' + convert(nvarchar, @KRST_Standardowa) + ' AND KRST_Symbol = '''+ @KRST_Symbol + ''' AND KRST_Nazwa = ''' + @KRST_Nazwa + ''''
 CREATE TABLE #Licznik (licz INT)
 INSERT INTO #Licznik (licz)
 EXEC sp_executesql @sqltxt
 SELECT @Count = licz FROM #Licznik
 DROP TABLE #Licznik
 IF(@Count = 0)
 BEGIN
  SET @inserttxt =
  'INSERT INTO [' + @ServerName + '].[' + @ConfigDBName + '].[CDN].[KRST]
  (
  KRST_Standardowa,
  KRST_Symbol,
  KRST_Nazwa,
  KRST_Pozycja,
  KRST_Stawka,
  KRST_StaraWersja
  )
  VALUES
  (' +
  convert(nvarchar, @KRST_Standardowa) + ',' +
  '''' + @KRST_Symbol + ''',''' +
  + @KRST_Nazwa + ''',''' +
  + @KRST_Pozycja + ''',' +
  convert(nvarchar, @KRST_Stawka) + ',' +
  '''''' + '
  )'
  EXEC sp_executesql @inserttxt
  SET @SlowId = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
 END
 ELSE IF(@OnlyNew <> 1)
 BEGIN
  DECLARE @getIDSqlTxt nvarchar (1000)
  SET @getIDSqlTxt =
   'SELECT KRST_KRSTID
   FROM ['  + @ServerName + '].[' + @ConfigDBName + '].CDN.KRST
   WHERE KRST_StaraWersja = '''' AND KRST_Standardowa = ' + convert(nvarchar, @KRST_Standardowa) + ' AND KRST_Symbol = ''' + @KRST_Symbol + ''' AND KRST_Nazwa = ''' + @KRST_Nazwa + ''''
   CREATE TABLE #KRST(KRSTID int)
   INSERT INTO #KRST(KRSTID)
   EXEC sp_executesql @getIDSqlTxt
   SELECT @SlowID = KRSTID FROM #KRST
   DROP TABLE #KRST
  SET @updatetxt =
  'UPDATE [' + @ServerName + '].[' + @ConfigDBName + '].[CDN].[KRST]
  SET
  KRST_Pozycja = ''' + @KRST_Pozycja + ''',
  KRST_Stawka = ' + convert(nvarchar, @KRST_Stawka) + '
  WHERE KRST_KRSTID = ' + convert(nvarchar, @SlowID)
  EXEC sp_executesql @updatetxt
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
 END
 ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
 BEGIN
  SET @sqlTxt =
   'EXEC ['  + @ServerName + '].[' + @ConfigDBName + '].[CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1200,
    @ObiektSubTyp = 0,
    @ObiektID = ' + convert(nvarchar, @SlowID) + ',
    @ObiektNazwa = ''' + @KRST_Symbol + ''',
    @OperacjaTyp = ' + convert(nvarchar, @OperationType) + ',
    @Opis = '''''
  EXEC sp_executesql @sqlTxt
 END
END
