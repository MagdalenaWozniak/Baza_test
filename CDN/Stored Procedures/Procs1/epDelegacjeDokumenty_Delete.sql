CREATE procedure CDN.epDelegacjeDokumenty_Delete
@Id int
As
 if @Id is Not Null
 begin
  Declare @sql nvarchar(256)
  Set @sql = 'delete from CDN.DlgDokumenty where DLD_DLDId=' + convert(nvarchar, @Id)
  Execute dbo.sp_executesql @sql
 end
