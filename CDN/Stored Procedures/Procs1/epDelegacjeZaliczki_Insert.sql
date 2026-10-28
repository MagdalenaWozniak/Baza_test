CREATE procedure CDN.epDelegacjeZaliczki_Insert
@ElementId int,
@FormaPlatnosciId int,
@Opis nvarchar(255),
@Data DateTime,
@Waluta nvarchar(3),
@KursNumer int,
@KursL decimal(15,4),
@KursM decimal(5,0),
@KwotaSys decimal(15,2),
@KwotaWal decimal(15,2)
As
 declare @Typ int
 Set @Typ = 1 -- reczna zaliczka
 declare @bzpId int
 Set @bzpId = NULL
 declare @sql nvarchar(2048)
 Set @sql = 'insert into CDN.DlgZaliczki(DLZ_DLEId, DLZ_Zrodlo, DLZ_Typ, DLZ_FPlID, DLZ_Dokument, DLZ_Data, DLZ_Waluta, DLZ_KursNumer, DLZ_KursL, DLZ_KursM, DLZ_KwotaSys, DLZ_KwotaWal, DLZ_KwotaRozliczenia)'
   + ' values('
   + convert(nvarchar, @ElementId) + ','
   + '10'  + ','
   + convert(nvarchar, @Typ) + ','
   + convert(nvarchar, @FormaPlatnosciId) + ','
   + '''' + @Opis + ''','
   + CDN.Date2String(@Data, 120, 0) + ',' -- +   '''' + convert(nvarchar, @Data, 120) + ''','
   + '''' + @Waluta + ''','
   + convert(nvarchar, @KursNumer) + ','
   + convert(nvarchar, @KursL) + ','
   + convert(nvarchar, @KursM) + ','
   + convert(nvarchar, @KwotaSys) + ','
   + convert(nvarchar, @KwotaWal) + ','
   + convert(nvarchar, @KwotaWal)
   + ')'
 Execute dbo.sp_executesql @sql
