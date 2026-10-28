CREATE procedure CDN.epDelegacjeTrasy_Insert
@ElementId int,
@MiejsceOdjazdu nvarchar(127),
@DataOdjazdu DateTime,
@GodzinaOdjazdu DateTime,
@MiejscePrzyjazdu nvarchar(127),
@DataPrzyjazdu DateTime,
@GodzinaPrzyjazdu DateTime,
@SrodekLokomocji nvarchar(50)
As
 declare @sql nvarchar(2048)
 Set @sql = 'insert into CDN.DlgTrasy(DLT_DLEId, DLT_Zrodlo, DLT_MiejsceOdjazdu, DLT_DataOdjazdu, DLT_GodzinaOdjazdu, DLT_MiejscePrzyjazdu, DLT_DataPrzyjazdu, DLT_GodzinaPrzyjazdu, DLT_SrodekLokomocji)'
   + ' values('
   + convert(nvarchar, @ElementId) + ','
   + '10'  + ','
   + '''' + @MiejsceOdjazdu + ''','
   + CDN.Date2String(@DataOdjazdu, 120, 0) + ',' -- +   '''' + convert(nvarchar, @DataOdjazdu, 120) + ''','
   + CDN.Date2String(@GodzinaOdjazdu, 120, 0) + ',' -- +   '''' + convert(nvarchar, @GodzinaOdjazdu, 108) + ''','
   + '''' + @MiejscePrzyjazdu + ''','
   + CDN.Date2String(@DataPrzyjazdu, 120, 0) + ',' -- +   '''' + convert(nvarchar, @DataPrzyjazdu, 120) + ''','
   + CDN.Date2String(@GodzinaPrzyjazdu, 120, 0) + ',' -- +   '''' + convert(nvarchar, @GodzinaPrzyjazdu, 108) + ''','
   + '''' + @SrodekLokomocji + ''''
   + ')'
 Execute dbo.sp_executesql @sql
