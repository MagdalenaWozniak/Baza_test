Create Function CDN.BazaKonfiguracyjna()
RETURNS nVARCHAR(300)
AS
BEGIN
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
Return @fulldbname
END
