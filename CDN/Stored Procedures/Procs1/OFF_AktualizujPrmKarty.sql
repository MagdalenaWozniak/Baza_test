CREATE PROCEDURE CDN.OFF_AktualizujPrmKarty
    @Prm_IdChr               nvarchar(11),
    @Prm_Akronim             nvarchar(200),
    @Prm_DataOdChr           nvarchar(11),
    @Prm_DataDoChr           nvarchar(11),
    @Prm_TypChr              nvarchar(11),
    @Prm_StanChr             nvarchar(11),
    @Prm_AktywnaChr          nvarchar(11),
    @Prm_PriorytetChr        nvarchar(11),
    @Prm_SposobStosowaniaChr nvarchar(5),
    @Prm_PominPozostaleChr   nvarchar(5),
    @Prm_Uwagi               nvarchar(512),
    @Prm_DokumentChr         nvarchar(5),
    @Prm_LastModChr          nvarchar(11),
    @Prm_PriorytetLpChr      nvarchar(11),
    @Prm_CyklicznaChr        nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
    @Prm_Id               INTEGER,
    @Prm_DataOd           INTEGER,
    @Prm_DataDo           INTEGER,
    @Prm_Typ              INTEGER,
    @Prm_Priorytet        INTEGER,
    @Prm_Stan             INTEGER,
    @Prm_Aktywna          INTEGER,
    @Prm_SposobStosowania SMALLINT,
    @Prm_PominPozostale   SMALLINT,
    @Prm_Dokument         SMALLINT,
    @Prm_LastMod          INTEGER,
    @Prm_PriorytetLp      INTEGER,
    @Prm_Cykliczna        INTEGER,
    @Komunikat            nvarchar(255),
    @Prm_IdOld            INTEGER
SELECT
    @Prm_Id               = CONVERT(INT,@Prm_IdChr),
    @Prm_DataOd           = CONVERT(INT,@Prm_DataOdChr),
    @Prm_DataDo           = CONVERT(INT,@Prm_DataDoChr),
    @Prm_Typ              = CONVERT(INT,@Prm_TypChr),
    @Prm_Priorytet        = CONVERT(INT,@Prm_PriorytetChr),
    @Prm_Stan             = CONVERT(INT,@Prm_StanChr),
    @Prm_Aktywna          = CONVERT(INT,@Prm_AktywnaChr),
    @Prm_SposobStosowania = CONVERT(SMALLINT,@Prm_SposobStosowaniaChr),
    @Prm_PominPozostale   = CONVERT(SMALLINT,@Prm_PominPozostaleChr),
    @Prm_Dokument         = CONVERT(SMALLINT,@Prm_DokumentChr),
    @Prm_LastMod          = CONVERT(INT,@Prm_LastModChr),
    @Prm_PriorytetLp      = CONVERT(INT,@Prm_PriorytetLpChr),
    @Prm_Cykliczna        = CONVERT(INT,@Prm_CyklicznaChr)
    if @Prm_Typ = 1
    BEGIN
      SELECT @Prm_IdOld=Prm_Id FROM CDN.PrmKarty
         WHERE Prm_Typ = 1
         IF @Prm_IdOld <1
          BEGIN
               UPDATE CDN.PrmKarty SET PRM_Akronim = @PRM_Akronim+'_a' WHERE  PRM_Id = @Prm_IdOld
               INSERT INTO CDN.PrmKarty(PRM_Id, PRM_Akronim, PRM_DataOd, PRM_DataDo, PRM_Typ, PRM_Priorytet, PRM_Stan, PRM_Aktywna, PRM_SposobStosowania, PRM_PominPozostale, PRM_Uwagi, PRM_Dokument, PRM_LastMod, PRM_PriorytetLp, PRM_Cykliczna)
               VALUES                  (@PRM_Id,@PRM_Akronim,@PRM_DataOd,@PRM_DataDo,@PRM_Typ,@PRM_Priorytet,@PRM_Stan,@PRM_Aktywna,@PRM_SposobStosowania,@PRM_PominPozostale,@PRM_Uwagi,@PRM_Dokument,@PRM_LastMod,@PRM_PriorytetLp,@PRM_Cykliczna)
               UPDATE CDN.KntPromocje SET KPR_PrmId = @PRM_Id WHERE KPR_PrmId=@Prm_IdOld
               UPDATE CDN.PrmHistoria SET PrH_IDPrm = @PRM_Id WHERE PrH_IDPrm=@Prm_IdOld
               DELETE CDN.PrmKarty
               WHERE  PRM_Id = @Prm_IdOld
          END
     END
     set @Prm_IdOld = NULL
     SELECT @Prm_IdOld=Prm_Id FROM CDN.PrmKarty WHERE  Prm_Typ=1
     DELETE FROM CDN.PrmKarty  WHERE  PRM_Id <1 and Prm_Typ<>1
     DELETE FROM CDN.TwrPromocje WHERE TPR_PrmId<1
     DELETE FROM CDN.KntPromocje WHERE KPR_PrmId<1 and KPR_PrmId <>@Prm_IdOld
     DELETE FROM CDN.PltPromocje WHERE PPr_PrmID<1
     DELETE FROM CDN.FrsPromocje WHERE FPR_PrmId<1
 set @Prm_IdOld = NULL
 SELECT @Prm_IdOld=Prm_Id FROM CDN.PrmKarty
  WHERE Prm_Id = @Prm_Id
 IF @Prm_IdOld IS NULL
    BEGIN
          INSERT INTO CDN.PrmKarty(PRM_Id, PRM_Akronim, PRM_DataOd, PRM_DataDo, PRM_Typ, PRM_Priorytet, PRM_Stan, PRM_Aktywna, PRM_SposobStosowania, PRM_PominPozostale, PRM_Uwagi, PRM_Dokument, PRM_LastMod, PRM_PriorytetLp, PRM_Cykliczna)
          VALUES                  (@PRM_Id,@PRM_Akronim,@PRM_DataOd,@PRM_DataDo,@PRM_Typ,@PRM_Priorytet,@PRM_Stan,@PRM_Aktywna,@PRM_SposobStosowania,@PRM_PominPozostale,@PRM_Uwagi,@PRM_Dokument,@PRM_LastMod,@PRM_PriorytetLp,@PRM_Cykliczna)
    END
 ELSE
    BEGIN
 IF CONVERT(INTEGER,@PRM_LastMod) >= ( SELECT isnull(PRM_LastMod,0) FROM CDN.PrmKarty WHERE PRM_Id = @PRM_Id)
          BEGIN
            UPDATE CDN.PrmKarty  SET   PRM_Akronim          = @PRM_Akronim,
                                       PRM_DataOd           = @PRM_DataOd,
                                       PRM_DataDo           = @PRM_DataDo,
                                       PRM_Typ              = @PRM_Typ,
                                       PRM_Priorytet        = @PRM_Priorytet,
                                       PRM_Stan             = @PRM_Stan,
                                       PRM_Aktywna          = @PRM_Aktywna,
                                       PRM_SposobStosowania = @PRM_SposobStosowania,
                                       PRM_PominPozostale   = @PRM_PominPozostale,
                                       PRM_Uwagi            = @PRM_Uwagi,
                                       PRM_Dokument         = @PRM_Dokument,
                                             PRM_LastMod          = @PRM_LastMod,
                                       PRM_PriorytetLp      = @PRM_PriorytetLp,
                                             PRM_Cykliczna        = @PRM_Cykliczna
                                 WHERE PRM_Id               = @PRM_Id
          --kasujemy stare elementy promocji
          IF @PRM_Typ<>1
          BEGIN
           DELETE FROM CDN.TwrPromocje WHERE TPR_PrmId=@PRM_Id
           DELETE FROM CDN.KntPromocje WHERE KPR_PrmId=@PRM_Id AND (KPR_KntTyp<>0 OR KPR_KntTyp<>'')
           DELETE FROM CDN.PltPromocje WHERE PPr_PrmID=@PRM_Id
           DELETE FROM CDN.FrsPromocje WHERE FPR_PrmId=@PRM_Id
          END
         END
    END
  SET NOCOUNT OFF
