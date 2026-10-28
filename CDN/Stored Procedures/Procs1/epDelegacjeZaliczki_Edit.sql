CREATE procedure CDN.epDelegacjeZaliczki_Edit
@ID      int,
@KwotaSys    decimal(15,2),
@KwotaWal    decimal(15,2),
@Opis     nvarchar(255),
@Data     DateTime,
@FormaPlatnosciId  int,
@Waluta     nvarchar(3),
@KursNumer    int,
@KursL     decimal(15,4),
@KursM     decimal(5,0)
As
 Set NOCOUNT ON
 if IsNull(@ID, 0) = 0
 BEGIN
  RAISERROR('CDN.epDelegacjeZaliczki_Edit. Nie podano ID rekordu do zmiany.', 16, 1)
  SET NOCOUNT OFF
  RETURN
 END
 if @KwotaSys is Null and @KwotaWal is Not Null Set @KwotaSys = @KwotaWal;
 if @KwotaWal is Null and @KwotaSys is Not Null Set @KwotaWal = @KwotaSys;
 declare @sql nvarchar(2048); set @sql = '';
 declare @upd nvarchar(2048); set @upd = '';
 if @FormaPlatnosciId is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_FPlID=' + Convert(nvarchar, @FormaPlatnosciId)
 end
 if @Opis is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_Dokument=''' + @Opis + ''''
 end
 if @Data is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_Data = ' + CDN.Date2String(@Data, 120, 0)  -- Convert(DateTime, ''' + convert(nvarchar, @Data, 120) + ''',120)'
 end
 if @Waluta is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_Waluta=''' + @Waluta + ''''
 end
 if @KursNumer is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_KursNumer=' + Convert(nvarchar, @KursNumer)
 end
 if @KursL is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_KursL=' + Convert(nvarchar, @KursL)
 end
 if @KursM is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_KursM=' + Convert(nvarchar, @KursM)
 end
 if @KwotaSys is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_KwotaSys=' + Convert(nvarchar, @KwotaSys)
 end
 if @KwotaWal is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_KwotaWal=' + Convert(nvarchar, @KwotaWal)
 end
 if @KwotaWal is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLZ_KwotaRozliczenia=' + Convert(nvarchar, @KwotaWal)
 end
 if len(@upd) > 0
 begin
  set @sql = 'update CDN.DlgZaliczki Set '
     + @upd
     + ' where DLZ_DLZId = ' + convert(nvarchar, @ID)
  Execute dbo.sp_executesql @sql
  if @@ERROR = 0
  begin
   declare @DelegacjaElementID int;
   select @DelegacjaElementID = DLZ_DLEId from CDN.DlgZaliczki where DLZ_DLZId = @ID
   update CDN.DlgElem Set DLE_RazemZaliczka = (Select sum(IsNull(DLZ_KwotaSys,0)) from CDN.DlgZaliczki where DLZ_DLEId=@DelegacjaElementID)
   where DLE_DLEId = @DelegacjaElementID
  end
  if @@ERROR = 0 exec CDN.epDelegacje_UstawStatusDoPrzeliczenia @DelegacjaElementId;
 end
 SET NOCOUNT OFF
