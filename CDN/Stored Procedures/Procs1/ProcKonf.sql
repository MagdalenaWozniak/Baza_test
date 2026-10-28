CREATE PROCEDURE CDN.ProcKonf @DataDo DATETIME, @Param INT
AS
SET NOCOUNT ON
DECLARE @NazwaSerwera NVARCHAR (1000)
DECLARE @Serwer NVARCHAR (1000)
DECLARE @BazaK NVARCHAR (1000)
DECLARE @Proc DECIMAL (15,2)
DECLARE @Wynik NVARCHAR(4000)
SET @Serwer = (select SYS_Wartosc from CDN.SystemCDN where SYS_ID = 1001)
SET @BazaK = (select SYS_Wartosc from CDN.SystemCDN where SYS_ID = 1002)
If @param  = 4
BEGIN
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @Proc =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
END
If @param  = 5
BEGIN
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @Proc =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
END
If @param  = 6
BEGIN
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @Proc =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
END
If @param  = 0
BEGIN
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @Proc =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
END
If @param  = 1
BEGIN
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @Proc =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
END
If @param  = 2
BEGIN
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @Proc =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
END
If @param  = 3
BEGIN
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @Proc =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
END
If @param  = 7
BEGIN
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @Proc =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
END
select @wynik
