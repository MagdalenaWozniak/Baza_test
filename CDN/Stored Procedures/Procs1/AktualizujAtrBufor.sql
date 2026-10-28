Create Procedure CDN.AktualizujAtrBufor
 @Rok Int, @Miesiac Int, @OpeId Int, @BazGUID UNIQUEIDENTIFIER, @SQL NVARCHAR(MAX), @Wynik NVARCHAR(100) OutPut
As
Set NoCount On
Declare @NSQL NVarChar(MAX), @NParam NVarChar(4000)
If @SQL<>''
 Begin
  Set @NSQL   = N'Set @Wynik = LTrim(Cast ((' + @SQL + ') As NVARCHAR(100)))'
  Set @NParam = N'@Rok Int, @Miesiac Int, @OpeId Int, @BazGUID UNIQUEIDENTIFIER, @Wynik NVARCHAR(100) OutPut'
  execute sp_executesql @NSQL, @NParam, @Rok, @Miesiac, @OpeId, @BazGUID, @Wynik OutPut
 End
Set NoCount Off
