CREATE procedure CDN.epDelegacje_Delete
@Id int
As
 if @Id is Not Null
 begin
  Declare @sql nvarchar(256)
  Set @sql = 'delete from CDN.DlgNag where DLN_DLNId=' + convert(nvarchar, @Id)
  Execute dbo.sp_executesql @sql
  exec CDN.eDelegacje_RejestrOperacjiDodaj @Id, 3, 0;
 end
