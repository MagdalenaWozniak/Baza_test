CREATE procedure [CDN].[epDelegacjeTrasy_Edit]
@ID      int,
@MiejsceOdjazdu   nvarchar(127),
@DataOdjazdu   DateTime,
@GodzinaOdjazdu   DateTime,
@MiejscePrzyjazdu  nvarchar(127),
@DataPrzyjazdu   DateTime,
@GodzinaPrzyjazdu  DateTime,
@SrodekLokomocji  nvarchar(50)
As
 Set NOCOUNT ON
 if IsNull(@ID, 0) = 0
 BEGIN
  RAISERROR('CDN.epDelegacjeTrasy_Edit. Nie podano ID rekordu do zmiany.', 16, 1)
  SET NOCOUNT OFF
  RETURN
 END
 declare @sql nvarchar(2048); set @sql = '';
 declare @upd nvarchar(2048); set @upd = '';
 if @MiejsceOdjazdu is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLT_MiejsceOdjazdu=''' + REPLACE(@MiejsceOdjazdu, '''', '''''') + ''''
 end
 if @DataOdjazdu is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLT_DataOdjazdu = ' + CDN.Date2String(@DataOdjazdu, 120, 0)  -- Convert(DateTime, ''' + convert(nvarchar, @DataOdjazdu, 120) + ''',120)'
 end
 if @GodzinaOdjazdu is Not Null
 begin
  --set @GodzinaOdjazdu = DateAdd(Year, (1899-Year(@GodzinaOdjazdu)) , DateAdd(Month, (12-Month(@GodzinaOdjazdu)) , DateAdd(Day, (30-Day(@GodzinaOdjazdu)) , @GodzinaOdjazdu)))
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLT_GodzinaOdjazdu = ' + CDN.Date2String(@GodzinaOdjazdu, 120, 0)  -- Convert(DateTime, ''' + convert(nvarchar, @GodzinaOdjazdu, 108) + ''',108)'
 end
 if @MiejscePrzyjazdu is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLT_MiejscePrzyjazdu=''' + REPLACE(@MiejscePrzyjazdu, '''', '''''')  + ''''
 end
 if @DataPrzyjazdu is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLT_DataPrzyjazdu = ' + CDN.Date2String(@DataPrzyjazdu, 120, 0)  -- Convert(DateTime, ''' + convert(nvarchar, @DataPrzyjazdu, 120) + ''',120)'
 end
 if @GodzinaPrzyjazdu is Not Null
 begin
  --set @GodzinaPrzyjazdu = DateAdd(Year, (1899-Year(@GodzinaPrzyjazdu)) , DateAdd(Month, (12-Month(@GodzinaPrzyjazdu)) , DateAdd(Day, (30-Day(@GodzinaPrzyjazdu)) , @GodzinaPrzyjazdu)))
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLT_GodzinaPrzyjazdu = ' + CDN.Date2String(@GodzinaPrzyjazdu, 120, 0)  -- Convert(DateTime, ''' + convert(nvarchar, @GodzinaPrzyjazdu, 108) + ''',108)'
 end
 if @SrodekLokomocji is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLT_SrodekLokomocji=''' + REPLACE(@SrodekLokomocji, '''', '''''') + ''''
 end
 if len(@upd) > 0
 begin
  set @sql = 'update CDN.DlgTrasy Set '
     + @upd
     + ' where DLT_DLTId = ' + convert(nvarchar, @ID)
  Execute dbo.sp_executesql @sql
  if @@ERROR = 0
  begin
   declare @DelegacjaElementID int;
   select @DelegacjaElementID = DLT_DLEId from CDN.DlgTrasy where DLT_DLTId = @ID
   exec CDN.epDelegacje_UstawStatusDoPrzeliczenia @DelegacjaElementId;
  end
 end
 SET NOCOUNT OFF
