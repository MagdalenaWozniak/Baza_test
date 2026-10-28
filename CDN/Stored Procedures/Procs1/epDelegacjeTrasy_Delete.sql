CREATE procedure CDN.epDelegacjeTrasy_Delete
@Id int
As
 if @Id is Not Null
 begin
  declare @DelegacjaElementID int;
  select @DelegacjaElementID = DLT_DLEId from CDN.DlgTrasy where DLT_DLTId = @ID
  Declare @sql nvarchar(256)
  Set @sql = 'delete from CDN.DlgTrasy where DLT_DLTId=' + convert(nvarchar, @Id)
  Execute dbo.sp_executesql @sql
  if @@ERROR = 0 exec CDN.epDelegacje_UstawStatusDoPrzeliczenia @DelegacjaElementID;
 end
