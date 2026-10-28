CREATE procedure CDN.epDelegacjeZaliczki_Delete
@Id int
As
 if @Id is Not Null
 begin
  declare @DelegacjaElementID int;
  select @DelegacjaElementID = DLZ_DLEId from CDN.DlgZaliczki where DLZ_DLZId = @ID
  Declare @sql nvarchar(256)
  Set @sql = 'delete from CDN.DlgZaliczki where DLZ_DLZId=' + convert(nvarchar, @Id)
  Execute dbo.sp_executesql @sql
  if @@ERROR = 0
  begin
   SET NOCOUNT ON
   update CDN.DlgElem Set DLE_RazemZaliczka = (Select sum(IsNull(DLZ_KwotaSys,0)) from CDN.DlgZaliczki where DLZ_DLEId=@DelegacjaElementID)
   where DLE_DLEId = @DelegacjaElementID
   SET NOCOUNT OFF
  end
  if @@ERROR = 0 exec CDN.epDelegacje_UstawStatusDoPrzeliczenia @DelegacjaElementID;
 end
