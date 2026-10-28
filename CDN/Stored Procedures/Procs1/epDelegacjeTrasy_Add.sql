CREATE procedure [CDN].[epDelegacjeTrasy_Add]
@DelegacjaElementId  int,
@MiejsceOdjazdu   nvarchar(127),
@DataOdjazdu   DateTime,
@GodzinaOdjazdu   DateTime,
@MiejscePrzyjazdu  nvarchar(127),
@DataPrzyjazdu   DateTime,
@GodzinaPrzyjazdu  DateTime,
@SrodekLokomocji  nvarchar(50)
As
 Set NOCOUNT ON
 if IsNull(@DelegacjaElementId, 0) = 0
 BEGIN
  RAISERROR('epDelegacjeTrasy_Add. Parametr DelegacjaElementId jest wymagany.', 16, 1)
  SET NOCOUNT OFF
  RETURN
 END
 if @MiejsceOdjazdu is Null Set @MiejsceOdjazdu = ''
 if @MiejscePrzyjazdu is Null Set @MiejscePrzyjazdu = ''
 if @DataOdjazdu is Null set @DataOdjazdu = GETDATE();
 if @DataPrzyjazdu is Null set @DataPrzyjazdu = @DataOdjazdu + 1;
 if @GodzinaOdjazdu is Null set @GodzinaOdjazdu = convert(DateTime, '1899-12-30 00:00:00.000', 120);
 if @GodzinaPrzyjazdu is Null set @GodzinaPrzyjazdu = convert(DateTime, '1899-12-30 00:00:00.000', 120);
 set @GodzinaOdjazdu = DateAdd(Year, (1899-Year(@GodzinaOdjazdu)) , DateAdd(Month, (12-Month(@GodzinaOdjazdu)) , DateAdd(Day, (30-Day(@GodzinaOdjazdu)) , @GodzinaOdjazdu)))
 set @GodzinaPrzyjazdu = DateAdd(Year, (1899-Year(@GodzinaPrzyjazdu)) , DateAdd(Month, (12-Month(@GodzinaPrzyjazdu)) , DateAdd(Day, (30-Day(@GodzinaPrzyjazdu)) , @GodzinaPrzyjazdu)))
 if @SrodekLokomocji is Null set @SrodekLokomocji = '';
 declare @sql nvarchar(2048)
 set @sql = 'declare @DataOdjazdu DateTime; Set @DataOdjazdu = ' + CDN.Date2String(@DataOdjazdu, 120, 0) + ';'
   + 'declare @GodzinaOdjazdu DateTime; Set @GodzinaOdjazdu = ' + CDN.Date2String(@GodzinaOdjazdu, 120, 0) + ';'
   + 'declare @DataPrzyjazdu DateTime; Set @DataPrzyjazdu = ' + CDN.Date2String(@DataPrzyjazdu, 120, 0) + ';'
   + 'declare @GodzinaPrzyjazdu DateTime; Set @GodzinaPrzyjazdu = ' + CDN.Date2String(@GodzinaPrzyjazdu, 120, 0) + ';'
   + 'exec CDN.epDelegacjeTrasy_Insert ' +  convert(nvarchar, @DelegacjaElementId)  + ','
   + ''''+REPLACE(@MiejsceOdjazdu, '''', '''''''''')+''','
   + '@DataOdjazdu,'
   + '@GodzinaOdjazdu,'
   + ''''+REPLACE(@MiejscePrzyjazdu, '''', '''''''''')+''','
   + '@DataPrzyjazdu,'
   + '@GodzinaPrzyjazdu,'
   + ''''+REPLACE(@SrodekLokomocji, '''', '''''''''')+''''
 Execute dbo.sp_executesql @sql
 if @@ERROR = 0 exec CDN.epDelegacje_UstawStatusDoPrzeliczenia @DelegacjaElementId;
 declare @DelagacjaTrasaId int; set @DelagacjaTrasaId = 0;
 if @@ERROR = 0 set @DelagacjaTrasaId = IsNull(IDENT_CURRENT('CDN.DlgTrasy'), 0);
 SET NOCOUNT OFF
 set @sql = 'select ' + convert(nvarchar, @DelagacjaTrasaId) + ' as DelagacjaTrasaId'
 Execute dbo.sp_executesql @sql
