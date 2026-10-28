CREATE PROCEDURE [CDN].[ESLKEP_ImportKntZgodyPDFLinki]
  @JezykID         int,
  @IDEsklep        int,
  @KntIDEsklep     int,
  @LoginESklepID   int,
  @VerIDZgodyChr   nvarchar(50),
  @VerIDChr        nvarchar(50)
AS
  SET NOCOUNT ON
  DECLARE
  @Knt_KntId             INT,
  @PrzedstawicielID      INT,
  @ESSID                 INT,
  @VerIDZgody            UNIQUEIDENTIFIER,
  @VerID                 UNIQUEIDENTIFIER,
  @TrescZgodyId          INT,
  @ZgodaId               INT
  SELECT @ESSID = ESS_ESSID from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
 SELECT @Knt_KntId = ESK_KntOptimaID
    FROM Cdn.eSklepKntRelacje
    WHERE ESK_KnteSklepID =  @KntIDEsklep AND ESK_eSklepID = @ESSID
 select @PrzedstawicielID = KESP_PrzedstawicielID from CDN.KntESklepyPrzedstawiciele
 left join CDN.KntOsoby on KESP_PrzedstawicielID = KnO_KnOId
 left join CDN.Kontrahenci on KESP_KntID = Knt_KntId
  where KESP_KntID = @Knt_KntId and KESP_PrzedstawicieleSklepID = @LoginESklepID
 select
 @VerID             = CONVERT(UNIQUEIDENTIFIER,@VerIDChr),
 @VerIDZgody        = CONVERT(UNIQUEIDENTIFIER,@VerIDZgodyChr)
 SELECT @TrescZgodyId = RZT_RZTID
    FROM Cdn.RejestracjaZgodTresc
    WHERE RZT_GuidVer = @VerIDZgody
 set @ZgodaId =0
    select @ZgodaId = PRZ_PRZID
 from CDN.PodmiotRejestracjaZgod where PRZ_PrzedstawicielId = @PrzedstawicielID and  PRZ_TrescZgodyId = @TrescZgodyId
 if @ZgodaId = 0
  return
if not exists (select * from CDN.DaneBinarneLinki where DBL_eSklepZalVerID = @VerID and  DBL_DokumentId = @ZgodaId)
 begin
    if exists (select DAB_DABID from cdn.DaneBinarne where DAB_eSklepZalVerID = @VerId and DAB_eSklepJezykID = @JezykID and DAB_eSklepID = @ESSID)
     INSERT INTO CDN.DaneBinarneLinki
         (DBL_TwrID,DBL_Lp,DBL_Typ,DBL_NazwaPliku,DBL_Sciezka,DBL_WBazie,DBL_DabId,DBL_FileMode,
         DBL_ESklep,DBL_JezykId,DBL_TagLink,DBL_TagAlt,DBL_TagRel,DBL_TagTitle,DBL_DokumentTyp,DBL_DokumentId,DBL_eSklepZalVerID,DBL_eSklepJezykID)
     select 0,0,9,DAB_NazwaPliku,'',1,DAB_DABID,2,0,1,'','',0,'',1119,@ZgodaId, @VerID,@JezykID
  from cdn.DaneBinarne where DAB_eSklepZalVerID = @VerId and DAB_eSklepJezykID = @JezykID and DAB_eSklepID = @ESSID
 else
     if exists (select DAB_DABID from cdn.DaneBinarne where DAB_eSklepZalVerID = @VerId and DAB_eSklepJezykID = 1 and DAB_eSklepID = @ESSID)
        INSERT INTO CDN.DaneBinarneLinki
         (DBL_TwrID,DBL_Lp,DBL_Typ,DBL_NazwaPliku,DBL_Sciezka,DBL_WBazie,DBL_DabId,DBL_FileMode,
         DBL_ESklep,DBL_JezykId,DBL_TagLink,DBL_TagAlt,DBL_TagRel,DBL_TagTitle,DBL_DokumentTyp,DBL_DokumentId,DBL_eSklepZalVerID,DBL_eSklepJezykID)
     select 0,0,9,DAB_NazwaPliku,'',1,DAB_DABID,2,0,1,'','',0,'',1119,@ZgodaId, @VerID,@JezykID
  from cdn.DaneBinarne where DAB_eSklepZalVerID = @VerId and DAB_eSklepJezykID = 1 and DAB_eSklepID = @ESSID
     else
   INSERT INTO CDN.DaneBinarneLinki
         (DBL_TwrID,DBL_Lp,DBL_Typ,DBL_NazwaPliku,DBL_Sciezka,DBL_WBazie,DBL_DabId,DBL_FileMode,
         DBL_ESklep,DBL_JezykId,DBL_TagLink,DBL_TagAlt,DBL_TagRel,DBL_TagTitle,DBL_DokumentTyp,DBL_DokumentId,DBL_eSklepZalVerID,DBL_eSklepJezykID)
     select 0,0,9,'','',1,NULL,2,0,1,'','',0,'',1119,@ZgodaId, @VerID,@JezykID
    UPDATE DaneBinarneLinki
    SET DBL_Lp = Lp
    FROM (
     SELECT x.DBL_Lp, ROW_NUMBER() OVER(PARTITION BY x.DBL_DokumentId ORDER BY x.DBL_DBLID) AS Lp
     FROM CDN.DaneBinarneLinki x where DBL_DokumentId = @ZgodaId
    ) AS DaneBinarneLinki
end
SET NOCOUNT OFF
