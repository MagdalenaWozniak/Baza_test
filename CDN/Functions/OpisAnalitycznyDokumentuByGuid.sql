CREATE FUNCTION CDN.OpisAnalitycznyDokumentuByGuid(@Guid varchar(255))
RETURNS nvarchar(max)
AS
BEGIN
 declare @Result nvarchar(max) = null;
 declare @Values TABLE(  Pozycja NVARCHAR(4000), Wartosc NVARCHAR(max), Kwota decimal(15,4), Procent decimal(15,4), DokumentTyp int, DokumentId int, Guid nvarchar(255));
 with
  r_guid (Id, WyW_ID, Wartosc, Kwota, Procet, DokumentTyp, DokumentId, Guid)
  as (
   SELECT ROW_NUMBER() OVER( PARTITION BY WyW_GUID ORDER BY WyW_WyWID ), WyW_WyWID, CAST(WyW_Wartosc as NVARCHAR(4000)), WyW_Kwota, WyW_Procent, WyW_DokumentTyp, WyW_DokumentId, WyW_GUID from CDN.WymiaryWartosci
   where WyW_GUID = @Guid
  ),
  rr_guid (Id, WyW_ID, Wartosc, Kwota, Procet, DokumentTyp, DokumentId, Guid)
  as (
   SELECT Id, WyW_ID, Wartosc, Kwota, Procet, DokumentTyp, DokumentId, Guid from r_guid where Id=1
  ),
  recur_guid (Id, WyW_ID, Wartosc, Kwota, Procet, DokumentTyp, DokumentId, Guid)
  as (
   SELECT Id, WyW_ID, Wartosc, Kwota, Procet, DokumentTyp, DokumentId, Guid from rr_guid
   union all
   SELECT r_guid.Id, r_guid.WyW_ID, recur_guid.Wartosc+ '><' + r_guid.Wartosc,  r_guid.Kwota, r_guid.Procet, r_guid.DokumentTyp, r_guid.DokumentId, r_guid.Guid from r_guid inner join recur_guid on (r_guid.Guid=recur_guid.Guid and r_guid.Id=recur_guid.Id+1)
  )
  insert into @Values(Wartosc, Kwota, Procent, DokumentTyp, DokumentId, guid)
  select '<'+Wartosc+'>', Kwota, Procet, DokumentTyp, DokumentId, guid from recur_guid
  where WyW_ID in (select i.WyW_ID from recur_guid i where i.Guid = Guid and i.Id=(select MAX(m.id) from recur_guid m where i.Guid=m.Guid))
  update @Values Set Pozycja = WyW_Wartosc from @Values R join CDN.WymiaryWartosci WW on (R.Guid = WW.WyW_GUID) where WyW_WyyId = 0
 select top 1 @Result = Wartosc from @Values;
 return @Result;
END
