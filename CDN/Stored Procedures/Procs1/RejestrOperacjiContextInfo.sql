CREATE PROCEDURE [CDN].[RejestrOperacjiContextInfo]
@OpeId   INTEGER
AS
SET NOCOUNT ON
DECLARE @OpeIdStr nvarchar(10)
SET @OpeIdStr = CAST(@OpeId as nvarchar(10))
DECLARE @SerwerKnf nvarchar(max)
DECLARE @BazaKnf nvarchar(max)
SELECT @SerwerKnf= SYS_Wartosc FROM cdn.systemcdn where sys_id = 1001
SELECT @BazaKnf = SYS_Wartosc FROM cdn.systemcdn where sys_id = 1002
DECLARE @Log nvarchar(max)
DECLARE @sqlQuery nvarchar(max)
set @sqlQuery = N'select @Log=Kon_Wartosc FROM [' + @SerwerKnf + '].['+@BazaKnf +'].[CDN].[Konfig] WHERE Kon_Numer = 2273'
exec sp_executesql @sqlQuery, N'@Log nvarchar(max) output', @Log output;
if @Log = NULL
 SET @Log = '1'
if @Log ='1'
BEGIN
 DECLARE @OpeNazwisko nvarchar(50)
 DECLARE @OpeKod nvarchar(50)
 DECLARE @OpeNazwiskoLen nvarchar(2)
 set @sqlQuery =N'select @OpeNazwisko=Ope_Nazwisko FROM [' + @SerwerKnf +'].['+@BazaKnf +'].[CDN].[Operatorzy] WHERE Ope_OpeId = '+ @OpeIdStr
 exec sp_executesql @sqlQuery,  N'@OpeNazwisko nvarchar(50) output', @OpeNazwisko output;
 set @sqlQuery = N'select @OpeKod =Ope_Kod FROM [' + @SerwerKnf +'].['+@BazaKnf +'].[CDN].[Operatorzy] WHERE Ope_OpeId = ' + @OpeIdStr
 exec sp_executesql @sqlQuery, N'@OpeKod  nvarchar(50) output', @OpeKod output;
 IF @OpeNazwisko IS NULL
  SET @OpeNazwisko = @OpeKod
 IF LEN(@OpeNazwisko)=0
  SET @OpeNazwisko = @OpeKod
 SET @OpeNazwiskoLen = CAST(LEN(@OpeNazwisko) as nvarchar(2))
 SET @OpeNazwisko = REPLACE(@OpeNazwisko, '''', '''''' )
 DECLARE @BinVar varbinary(128)
 set @sqlQuery ='SET @BinVar=CAST( '+@Log+' AS VARBINARY(4))+CAST('+@OpeNazwiskoLen+' AS VARBINARY(4))+CAST(N'''+@OpeNazwisko+''' AS VARBINARY(100))'
 exec sp_executesql @sqlQuery, N'@BinVar varbinary(128) output', @BinVar output;
 SET CONTEXT_INFO @BinVar
end
SET NOCOUNT OFF
