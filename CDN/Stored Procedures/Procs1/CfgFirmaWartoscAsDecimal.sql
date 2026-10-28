CREATE PROCEDURE CDN.CfgFirmaWartoscAsDecimal
@Date DateTime,
@KeyName nvarchar(255),
@Result decimal(15,4) OUTPUT
AS
 set @KeyName = '''' + @KeyName + ''''
 declare @fulldbname nvarchar(300); set @fulldbname = '';--CDN.BazaKonfiguracyjna()
 declare @Warosc nvarchar(3000);
 declare @sql nvarchar(1024);
 set @sql = 'select @Warosc = CFW_Wartosc from '+@fulldbname+'.CDN.CfgKlucze join '+@fulldbname+'.CDN.CfgWartosci on (CFK_CfkId = CFW_CfkId)'
   + ' where CFK_OkresOd <= ' + CDN.Date2String(@Date, 120,0)
   + ' and CFK_OkresDo >= ' + CDN.Date2String(@Date, 120,0) + ' and CFK_Nazwa = ' + @KeyName + ';'
 EXEC sp_executesql @sql, N'@Warosc nvarchar(3000) OUTPUT', @Warosc=@Warosc OUTPUT
 set @Warosc = replace(@Warosc, ',', '.')
 set @Result = cast(@Warosc as decimal(15,4))
 return
