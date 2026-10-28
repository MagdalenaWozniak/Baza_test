CREATE PROCEDURE [CDN].[SerieDlaDetaluXL]
  AS
  SET NOCOUNT ON
Declare @gru_nazwa nvarchar(5)
CREATE TABLE  #SERIE(Seria nvarchar(5))
insert into #SERIE
select gru_nazwa from cdn.grupy where gru_typ in (302,305)
group by gru_nazwa having count(*) > 1
  DECLARE N CURSOR LOCAL FAST_FORWARD FOR
   select * from #SERIE
             OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO @gru_nazwa
                    IF @@FETCH_STATUS <> 0 BREAK
                if exists( select * from cdn.tranag where trn_numerpelny like '%/'+@gru_nazwa)
                or exists( select * from cdn.tranag where trn_numerpelny like '%/'+@gru_nazwa+'/%')
                or exists( select * from cdn.tranag where trn_numerpelny like @gru_nazwa+'/%')
     delete from #SERIE where Seria = @gru_nazwa
            if exists( select * from cdn.firma where  fir_wartosc = @gru_nazwa)
     delete from #SERIE where Seria = @gru_nazwa
   if exists(select Bra_Symbol from cdn.BnkRachunki where Bra_Symbol = @gru_nazwa)
     delete from #SERIE where Seria = @gru_nazwa
             END
              CLOSE N
            DEALLOCATE N
SET NOCOUNT OFF
select * from #SERIE
  DROP TABLE #SERIE
