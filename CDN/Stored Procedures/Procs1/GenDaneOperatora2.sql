create Procedure CDN.GenDaneOperatora2
@ID int
as
Set NoCount on
DECLARE @dbn nvarchar(300)
DECLARE @srv nvarchar(300)
select @dbn = sys_wartosc from cdn.systemcdn where sys_id = 1002
select @srv = sys_wartosc from cdn.systemcdn where sys_id = 1001
DECLARE @fulldbname nVARCHAR(300)
If  @srv = CONVERT(sysname, SERVERPROPERTY('servername'))
 Or IsNull (CONVERT(sysname, SERVERPROPERTY('servername')), '') = ''
  Set @srv = ''
  If  @srv = ''
   Set @fulldbname = '[' + @dbn + ']'
  Else
   Set @fulldbname = '[' + @srv + '].[' + @dbn + ']'
declare @Query1  nvarchar(2000)
set @Query1 =
N'select Ope_Kod AS Kod,Ope_Nazwisko AS Nazwisko,Ope_OpeID,Ope_Telefon
from ' + @fulldbname +N'.CDN.Operatorzy where Ope_OpeID='
+ convert(nvarchar(20),@ID)
Set NoCount Off
Execute dbo.sp_executesql @Query1
