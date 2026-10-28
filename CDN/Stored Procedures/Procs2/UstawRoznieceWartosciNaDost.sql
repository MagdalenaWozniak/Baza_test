CREATE PROCEDURE [CDN].[UstawRoznieceWartosciNaDost] @TrN_TrNId INT
AS
declare
@Roznica  DECIMAL(15,2),
@TrS_TrEId  INT
if exists(select trs_treid,max(tre_wartoscnetto)-sum(trs_wartosc) from cdn.traelem
join cdn.traselem on tre_treid = trs_treid
join cdn.tranag on tre_trnid = trn_trnid
where tre_trnid = @TrN_TrNId and  trs_typ = 1
group by trs_treid
HAVING max(tre_wartoscnetto)-sum(trs_wartosc) <> 0)
BEGIN
      DECLARE N CURSOR LOCAL FAST_FORWARD FOR
        SELECT trs_treid , roznica =max(tre_wartoscnetto)-sum(trs_wartosc) FROM cdn.traelem
          JOIN cdn.traselem on tre_treid = trs_treid
          JOIN cdn.tranag on tre_trnid = trn_trnid
         where tre_trnid = @TrN_TrNId and  trs_typ = 1
         group by trs_treid
         HAVING max(tre_wartoscnetto)-sum(trs_wartosc) <> 0
            OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO @TrS_TrEId,@Roznica
                  IF @@FETCH_STATUS <> 0 BREAK
                    update cdn.traselem set trs_wartosc = trs_wartosc +@Roznica
                     where trs_trsid = (select top 1 trs_trsid from cdn.traselem
                                        join cdn.TwrZasoby on TwZ_TrSIdDost = TrS_TrSIdDost and TwZ_MagId = trs_magid
                                        where trs_treid = @TrS_TrEId
                                        ORDER BY trs_trsid desc)
                END
            CLOSE N
            DEALLOCATE N
      END
