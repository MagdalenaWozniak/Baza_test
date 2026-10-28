CREATE  PROCEDURE Cdn.OFF_Ex_Raporty
  AS
  SET NOCOUNT ON
  declare
   @BRp_BRpId  INT,
   @BRp_DDfId  INT,
   @BRp_BRaId  INT,
   @BRp_NumerString nvarchar(31)
     CREATE TABLE #TmpReszta( BRpId  INT,Rok nvarchar(5), Seria nvarchar(10))
     SELECT *, (SELECT
               count(bzp_BrpId)
                 FROM cdn.BnkZapisy
                 left outer JOIN cdn.BnkRozRelacje ON (BzP_BzPId = BrR_ZDokId AND BrR_ZDokTyp = 2)
                 left outer JOIN cdn.BnkZdarzenia ON (BzD_BzDId = BrR_DDokId AND BrR_DDokTyp = 1)
                 left outer JOIN cdn.Kontrahenci ON Knt_KntId = BzP_PodmiotId
                 left outer JOIN cdn.FormyPlatnosci ON Fpl_FplId = BzD_FPLId
                 left outer JOIN cdn.Tranag ON  Trn_TrnId = BzD_DokumentId
                 WHERE bzp_BrpId=BRp_BRpId)AS Wartosc
       INTO #TmpRaporty FROM Cdn.BnkRaporty
       WHERE BRp_Zamkniety = 1 AND BRp_GidNumer is NULL
 DECLARE N CURSOR LOCAL FAST_FORWARD FOR
   SELECT BRp_BRpId,BRp_BRaId,BRp_NumerString,BRp_DDfId FROM #TmpRaporty
             OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N  INTO @BRp_BRpId,@BRp_BRaId,@BRp_NumerString,@BRp_DDfId
                    IF @@FETCH_STATUS <> 0 BREAK
                    -- czy ma niezamkniete wczesniejsze raporty
                    IF exists (SELECT brp_brpid from cdn.bnkraporty
                       where Brp_zamkniety=0 AND Brp_BrpId<@BRp_BRpId AND Brp_Braid = @Brp_Braid)
                             delete  #TmpRaporty WHERE BRp_BRpId=@BRp_BRpId
                    ELSE
                             INSERT  INTO #TmpReszta
                             SELECT @BRp_BRpId,Rok,Seria
                             FROM Cdn.RozbijNumer(@BRp_DDfId,@BRp_NumerString)
                 END
              CLOSE N
            DEALLOCATE N
  SET NOCOUNT OFF
  SELECT * FROM #TmpRaporty
     left JOIN #TmpReszta on BRp_BRpId = BRpId
  DROP TABLE #TmpRaporty
  DROP TABLE #TmpReszta
