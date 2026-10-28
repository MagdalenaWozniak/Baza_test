CREATE PROCEDURE CDN.ESLKEP_ImportKntZgodyPDFLinkiKontrola
@VerID                 UNIQUEIDENTIFIER
AS
SET NOCOUNT ON
if exists (select * from CDN.DaneBinarneLinki where DBL_eSklepZalVerID = @VerID and DBL_DabId is null)
begin
 INSERT INTO CDN.DaneBinarneLinki
 (DBL_TwrID,DBL_Lp,DBL_Typ,DBL_NazwaPliku,DBL_Sciezka,DBL_WBazie,DBL_DabId,DBL_FileMode,
 DBL_ESklep,DBL_JezykId,DBL_TagLink,DBL_TagAlt,DBL_TagRel,DBL_TagTitle,DBL_DokumentTyp,DBL_DokumentId,DBL_eSklepZalVerID,DBL_eSklepJezykID)
 select 0,0,9,DAB_NazwaPliku,'',1,DAB_DABID,2,0,1,'','',0,'',1119,DBL_DokumentId, @VerID,DAB_eSklepJezykID
 from cdn.DaneBinarnelinki BB
 join CDN.DaneBinarne on DAB_eSklepZalVerID = DBL_eSklepZalVerID and DAB_eSklepJezykID  = DBL_eSklepJezykID
 where DBL_eSklepZalVerID = @VerId  and DBL_DabId is null
 and not exists (select * from CDN.DaneBinarneLinki A where A.DBL_eSklepZalVerID = @VerID and A.DBL_DabId is not null
 and A.DBL_DokumentTyp = 1119 and A.DBL_DokumentId = BB.DBL_DokumentId)
end
if exists (select * from CDN.DaneBinarneLinki where DBL_eSklepZalVerID = @VerID and DBL_DabId is null)
begin
 INSERT INTO CDN.DaneBinarneLinki
 (DBL_TwrID,DBL_Lp,DBL_Typ,DBL_NazwaPliku,DBL_Sciezka,DBL_WBazie,DBL_DabId,DBL_FileMode,
 DBL_ESklep,DBL_JezykId,DBL_TagLink,DBL_TagAlt,DBL_TagRel,DBL_TagTitle,DBL_DokumentTyp,DBL_DokumentId,DBL_eSklepZalVerID,DBL_eSklepJezykID)
 select 0,0,9,DAB_NazwaPliku,'',1,DAB_DABID,2,0,1,'','',0,'',1119,DBL_DokumentId, @VerID,DAB_eSklepJezykID
 from cdn.DaneBinarnelinki BB
 join CDN.DaneBinarne on DAB_eSklepZalVerID = DBL_eSklepZalVerID and DAB_eSklepJezykID  = 1
 where DBL_eSklepZalVerID = @VerId  and DBL_DabId is null
 and not exists (select * from CDN.DaneBinarneLinki A where A.DBL_eSklepZalVerID = @VerID and A.DBL_DabId is not null
 and A.DBL_DokumentTyp = 1119 and A.DBL_DokumentId = BB.DBL_DokumentId)
end
delete from CDN.DaneBinarneLinki where DBL_eSklepZalVerID = @VerID and DBL_DabId is null
 UPDATE DaneBinarneLinki
 SET DBL_Lp = Lp
 FROM (
 SELECT x.DBL_Lp, ROW_NUMBER() OVER(PARTITION BY x.DBL_DokumentId ORDER BY x.DBL_DBLID) AS Lp
 FROM CDN.DaneBinarneLinki x where DBL_eSklepZalVerID = @VerId
 ) AS DaneBinarneLinki
SET NOCOUNT OFF
