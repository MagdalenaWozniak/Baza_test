CREATE PROCEDURE CDN.ImportWNo
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@WNa_Symbol nvarchar(3),
@WKu_Symbol nvarchar(5),
@WNo_TStamp nvarchar(10),
@WNo_KursL decimal(15,4),
@WNo_KursM decimal(5,0),
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
 DECLARE @WNa_Id int,
  @WKu_Id int,
  @WNatxt nvarchar (1000),
  @WKutxt nvarchar (1000),
  @TStamptxt nvarchar (1000),
  @inserttxt nvarchar(1000),
  @updatetxt nvarchar(1000)
 SET @WNatxt =
 'SELECT WNa_WNaId
 FROM ['  + @ServerName + '].[' + @ConfigDBName + '].CDN.WalNazwy
 WHERE WNa_Symbol = ''' + @WNa_Symbol + ''''
 CREATE TABLE #WNaTbl (WNa_Id int)
 INSERT INTO #WNaTbl(WNa_Id)
 EXEC sp_executesql @WNatxt
 SELECT @Wna_Id = WNa_Id FROM #WNaTbl
 IF(@WNa_Id is NULL)
  RAISERROR('##OPT33090##', 16, 1) --RAISERROR('Brak wymaganej waluty.', 16, 1)
 SET @WKutxt =
 'SELECT WKu_WKuId
 FROM ['  + @ServerName + '].[' + @ConfigDBName + '].CDN.WalKursy
 WHERE WKu_Symbol = ''' + @WKu_Symbol + ''''
 CREATE TABLE #WKuTbl (WKu_Id int)
 INSERT INTO #WKuTbl(WKu_Id)
 EXEC sp_executesql @WKutxt
 SELECT @WKu_Id = WKu_Id FROM #WKuTbl
 IF(@WKu_Id is NULL)
  RAISERROR('##OPT33091##', 16, 1) --RAISERROR('Brak wymaganego kursu waluty.', 16, 1)
 SET @TStamptxt =
 'SELECT WNo_TStamp
 FROM ['  + @ServerName + '].[' + @ConfigDBName + '].CDN.WalNotowania
 WHERE WNo_WNaId = ' + convert(nvarchar(10), @WNa_Id) + ' and WNo_WKuId = ' + convert(nvarchar(10), @WKu_Id)
 CREATE TABLE #TSTbl (WNo_TS datetime)
 INSERT INTO #TSTbl(WNo_TS)
 EXEC sp_executesql @TStamptxt
 IF(convert(datetime, @WNo_TStamp, 120) not in (SELECT WNo_TS FROM #TSTbl))
 BEGIN
  SELECT 1
  Set @inserttxt =
  'INSERT INTO [' + @ServerName + '].[' + @ConfigDBName + '].CDN.WalNotowania
  (
  WNo_WNaID,
  WNo_WKuID,
  WNo_TStamp,
  WNo_KursL,
  WNo_KursM,
  WNo_TS_Zal,
  WNo_TS_Mod,
  WNo_OpeModId,
  WNo_OpeModKod,
  WNo_OpeModNazwisko,
  WNo_OpeZalId,
  WNo_OpeZalKod,
  WNo_OpeZalNazwisko,
  WNo_TS_Export
  )
  VALUES
  (' +
  convert(nvarchar(20), @WNa_Id) + ',' +
  convert(nvarchar(20), @WKu_Id) +
  ',convert(datetime, ''' + @WNo_TStamp + ''', 120),' +
  convert(nvarchar(20), @WNo_KursL) + ',' +
  convert(nvarchar(20), @WNo_KursM) + ',
  GETDATE(),
  GETDATE(), '+
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
 END
 ELSE IF(@OnlyNew <> 1)
 BEGIN
  DECLARE @getIDSqlTxt nvarchar (1000)
  SET @getIDSqlTxt =
   'SELECT WNo_WNoID
   FROM ['  + @ServerName + '].[' + @ConfigDBName + '].CDN.WalNotowania
    WHERE WNo_WNaID = ' +  convert(nvarchar(10), @WNa_Id) + '
     and WNo_WKuID = ' + convert(nvarchar(20), @WKu_Id) +
     'and WNo_TStamp = convert(datetime, ''' + @WNo_TStamp + ''', 120)'
   CREATE TABLE #WNo(WNoID int)
   INSERT INTO #WNo(WNoID)
   EXEC sp_executesql @getIDSqlTxt
   SELECT @SlowID = WNoID FROM #WNo
   DROP TABLE #WNo
  Set @updatetxt = 'UPDATE [' + @ServerName + '].[' + @ConfigDBName + '].CDN.WalNotowania
  SET
  WNo_KursL = ' + convert(nvarchar(20), @WNo_KursL) + ',
  WNo_KursM = ' + convert(nvarchar(20), @WNo_KursM) + ',
  WNo_TS_Mod = GETDATE(),
  WNo_OpeModId = ' + convert(nvarchar, @OpeId) + ',
  WNo_OpeModKod = ''' + @OpeModKod +  ''',
  WNo_OpeModNazwisko = ''' + @OpeModNazwisko +  '''
  WHERE WNo_WNoID = ' + convert(nvarchar(10), @SlowID)
  EXEC sp_executesql @updatetxt
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
 END
 ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
 BEGIN
  DECLARE @sqlTxt nvarchar (1000)
  SET @sqlTxt =
   'EXEC ['  + @ServerName + '].[' + @ConfigDBName + '].[CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 4007,
    @ObiektSubTyp = 0,
    @ObiektID = ' + convert(nvarchar, @SlowID) + ',
    @ObiektNazwa = ''' + @WNa_Symbol + '/' + @WKu_Symbol + '/' + @WNo_TStamp + ''',
    @OperacjaTyp = ' + convert(nvarchar, @OperationType) + ',
    @Opis = '''''
  EXEC sp_executesql @sqlTxt
 END
END
