Create Procedure [CDN].[Mobile_EksportPtw]
@ID    INT,    -- ID stanowiska
@Typ   TINYINT = 0 -- Typ potwierdzenia: 0 - dokumenty, raporty, rozliczenia, 1 - towary, 2 - kontrahenci, 3 - potwierdzenia
AS
BEGIN
 DECLARE @DSta_TS_SynchroPotw DateTime
 SELECT @DSta_TS_SynchroPotw=DSta_TS_SynchroPotw
 FROM CDN.DetalStanowiska WHERE DSta_DStaID = @ID
IF @Typ = 255
 BEGIN
  /***** Dokumenty handlowe *****/
  DELETE FROM CDN.DetalTraElem
  WHERE DTre_DSTrNID IN (
  SELECT DTrN_DSTrNID FROM CDN.DetalTraNag
  WHERE DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2
      )
  AND DTrE_StanDetalID = @ID
   /***** Zapisy K/B *****/
  IF EXISTS (SELECT * FROM CDN.DetalZapisyKB WHERE DZKB_StanDetalID = @ID AND DZKB_StanSynchronizacji = 2 and DZKB_TypDokumentu = 1 and DZKB_DSZKBID > 0)
  BEGIN
  DELETE FROM CDN.DetalZapisyKB  WHERE DZKB_StanDetalID = @ID AND  DZKB_StanSynchronizacji=2 and DZKB_TypDokumentu = 1 and DZKB_DSZKBID < 0
  UPDATE CDN.DetalZapisyKB SET DZKB_DSZKBID = -1 WHERE DZKB_StanDetalID = @ID AND DZKB_StanSynchronizacji = 2 and DZKB_TypDokumentu = 1 and DZKB_NumerNr = (
  SELECT MAX(isnull(DZKB_NumerNr,0)) FROM CDN.DetalZapisyKB WHERE DZKB_StanDetalID = @ID AND  DZKB_StanSynchronizacji=2 and DZKB_TypDokumentu = 1)
  DELETE FROM CDN.DetalZapisyKB  WHERE DZKB_StanDetalID = @ID AND  DZKB_StanSynchronizacji=2 and DZKB_TypDokumentu = 1 and DZKB_DSZKBID > 0
  END
  IF EXISTS (SELECT * FROM CDN.DetalZapisyKB WHERE DZKB_StanDetalID = @ID AND DZKB_StanSynchronizacji = 2 and DZKB_TypDokumentu = 2 and DZKB_DSZKBID > 0)
  BEGIN
  DELETE FROM CDN.DetalZapisyKB  WHERE DZKB_StanDetalID = @ID AND  DZKB_StanSynchronizacji=2 and DZKB_TypDokumentu = 2 and DZKB_DSZKBID < 0
  UPDATE CDN.DetalZapisyKB SET DZKB_DSZKBID = -1 WHERE DZKB_StanDetalID = @ID AND DZKB_StanSynchronizacji = 2 and DZKB_TypDokumentu = 2 and DZKB_NumerNr = (
  SELECT MAX(isnull(DZKB_NumerNr,0)) FROM CDN.DetalZapisyKB WHERE DZKB_StanDetalID = @ID AND  DZKB_StanSynchronizacji=2 and DZKB_TypDokumentu = 2)
  DELETE FROM CDN.DetalZapisyKB  WHERE DZKB_StanDetalID = @ID AND  DZKB_StanSynchronizacji=2 and DZKB_TypDokumentu = 2 and DZKB_DSZKBID > 0
  END
  /***** Rozliczenia *****/
  DELETE CDN.DetalPlatnosciDokumentu  WHERE  DPlD_StanDetalID = @ID  AND DPlD_StanSynchronizacji=2
  /***** Raporty *****/
  DELETE CDN.DetalRaporty  WHERE DRap_DStaId = @ID
  /***** Numery dokumentów *****/
  if exists (SELECT * FROM CDN.detalTraNag where DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 302 and DTrN_DSTrNID > 0)
  BEGIN
  DELETE FROM CDN.detalTraNag where DTrN_DSTrNID < 0 AND DTrN_StanDetalID = @ID and DTrN_TypDokumentu = 302
  UPDATE CDN.detalTraNag set DTrN_DSTrNID = -302  WHERE  DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 302 and DTrN_NumerNr = (
    SELECT  max(isnull(dtrn_numernr,0)) FROM  CDN.detalTraNag   WHERE  DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 302)
  END
  if exists (SELECT * FROM CDN.detalTraNag where DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 305 and DTrN_DSTrNID > 0)
  BEGIN
  DELETE FROM CDN.detalTraNag where DTrN_DSTrNID < 0 AND DTrN_StanDetalID = @ID and DTrN_TypDokumentu = 305
  UPDATE CDN.detalTraNag set DTrN_DSTrNID = -305  WHERE  DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 305 and DTrN_NumerNr = (
     SELECT  max(isnull(dtrn_numernr,0)) FROM  CDN.detalTraNag   WHERE  DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 305)
  END
  if exists (SELECT * FROM CDN.detalTraNag where DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 308 and DTrN_DSTrNID > 0)
  BEGIN
  DELETE FROM CDN.detalTraNag where DTrN_DSTrNID < 0 AND DTrN_StanDetalID = @ID and DTrN_TypDokumentu = 308
  UPDATE CDN.detalTraNag set DTrN_DSTrNID = -308  WHERE  DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 308 and DTrN_NumerNr = (
     SELECT  max(isnull(dtrn_numernr,0)) FROM  CDN.detalTraNag   WHERE  DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 308)
  END
  if exists (SELECT * FROM CDN.detalTraNag where DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 312 and DTrN_DSTrNID > 0)
  BEGIN
  DELETE FROM CDN.detalTraNag where DTrN_DSTrNID < 0 AND DTrN_StanDetalID = @ID and DTrN_TypDokumentu = 312
  UPDATE CDN.detalTraNag set DTrN_DSTrNID = -312  WHERE  DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 312 and DTrN_NumerNr = (
     SELECT  max(isnull(dtrn_numernr,0)) FROM  CDN.detalTraNag   WHERE  DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2 and DTrN_TypDokumentu = 312)
  END
  DELETE FROM CDN.detalTraNag where DTrN_DSTrNID > 0 AND DTrN_StanDetalID = @ID AND DTrN_StanSynchronizacji=2
     Return
 END
IF @Typ > 0
  UPDATE CDN.DetalStanowiska SET DSta_TS_SynchroPotw = (CASE WHEN @Typ = 1 THEN DSta_TS_Synchro     ELSE DSta_TS_SynchroPotw    END),
                            DSta_TS_SynchroTwrPotw   = (CASE WHEN @Typ = 2 THEN DSta_TS_SynchroTwr  ELSE DSta_TS_SynchroTwrPotw  END),
                            DSta_TS_SynchroKntPotw   = (CASE WHEN @Typ = 3 THEN DSta_TS_SynchroKnt  ELSE DSta_TS_SynchroKntPotw  END),
                            DSta_TS_SynchroGrupPotw  = (CASE WHEN @Typ = 4 THEN DSta_TS_SynchroGrup ELSE DSta_TS_SynchroGrupPotw END)--,
                            --PcK_TSSynchrPrmPtw  = (CASE WHEN @Typ = 5 THEN PcK_TSSynchrPrm  ELSE PcK_TSSynchrPrmPtw  END)
  WHERE DSta_DStaID = @ID
 ELSE
    BEGIN
  /***** Dokumenty handlowe *****/
  SELECT 2033 AS ObiTyp, DTrN_OptimaId AS ObiNumer, DTrN_DSTrNID AS ZewnetrznyId
  FROM   CDN.DetalTraNag
   WHERE  DTrN_StanDetalID = @ID AND DTrN_TypDokumentu = 302 AND DTrN_TS_Export > @DSta_TS_SynchroPotw AND DTrN_StanSynchronizacji=2
  UNION ALL
  SELECT 2034 AS ObiTyp, DTrN_OptimaId AS ObiNumer, DTrN_DSTrNID AS ZewnetrznyId
  FROM   CDN.DetalTraNag
   WHERE  DTrN_StanDetalID = @ID AND DTrN_TypDokumentu = 305 AND DTrN_TS_Export > @DSta_TS_SynchroPotw AND DTrN_StanSynchronizacji=2
  UNION ALL
  SELECT 9472 AS ObiTyp, DTrN_OptimaId AS ObiNumer, DTrN_DSTrNID AS ZewnetrznyId
  FROM   CDN.DetalTraNag
        Join CDN.TraNag on DTrN_OptimaId = TrN_TrNId
   WHERE  DTrN_StanDetalID = @ID AND DTrN_TypDokumentu = 308 AND DTrN_TS_Export > @DSta_TS_SynchroPotw AND DTrN_StanSynchronizacji=2
    UNION ALL
  SELECT 1603 AS ObiTyp, DTrN_OptimaId AS ObiNumer, DTrN_DSTrNID AS ZewnetrznyId
  FROM   CDN.DetalTraNag
        Join CDN.TraNag on DTrN_OptimaId = TrN_TrNId
   WHERE  DTrN_StanDetalID = @ID AND DTrN_TypDokumentu = 312 AND DTrN_TS_Export > @DSta_TS_SynchroPotw AND DTrN_StanSynchronizacji=2
  UNION ALL
  SELECT 784 AS ObiTyp, DZKB_OptimaId AS ObiNumer, DZKB_DSZKBID AS ZewnetrznyId
  FROM   CDN.DetalZapisyKB
        Join CDN.BnkZapisy on DZKB_OptimaId = BZp_BzpId
   WHERE  DZKB_StanDetalID = @ID AND  DZKB_TS_Export > @DSta_TS_SynchroPotw AND DZKB_StanSynchronizacji=2
     UNION ALL
  /***** Rozliczenia *****/
  SELECT 433AS ObiTyp, DPlD_DPlDId AS ObiNumer, DPlD_DSPlDId AS ZewnetrznyId
  FROM CDN.DetalPlatnosciDokumentu
   WHERE  DPlD_StanDetalID = @ID  AND DPlD_TS_Export > @DSta_TS_SynchroPotw AND DPlD_StanSynchronizacji=2
        UNION ALL
 /***** Raporty *****/ --800
  SELECT 800AS ObiTyp, DRap_DRapId AS ObiNumer, DRap_DSRapID AS ZewnetrznyId
  FROM CDN.DetalRaporty
  WHERE DRap_DStaId = @ID AND DRap_TS_Export > @DSta_TS_SynchroPotw
  UNION All
  /***** Kontrahenci *****/
  SELECT 32 as ObiTyp, DKnt_OptimaId as ObiNumer, DKnt_DSKntId as ZewnetrznyId
  FROM CDN.DetalKontrahenci
  WHERE DKnt_StanDetalID = @ID AND DKnt_TS_Mod > @DSta_TS_SynchroPotw
 END
END
