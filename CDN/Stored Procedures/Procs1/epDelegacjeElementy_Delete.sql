CREATE procedure CDN.epDelegacjeElementy_Delete
@Id int
As
 if @Id is Not Null
 begin
  Declare @sql nvarchar(256)
  Set @sql = 'delete from CDN.DlgElem where DLE_DLEId=' + convert(nvarchar, @Id)
  Execute dbo.sp_executesql @sql
 end
