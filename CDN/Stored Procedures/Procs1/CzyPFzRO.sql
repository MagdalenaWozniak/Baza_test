-- CzyPFzRO
CREATE PROCEDURE [CDN].[CzyPFzRO]
@ID INT
  AS
  SET NOCOUNT ON
declare @PFzRO int, @PFzROPrzeksztalconymDalej int, @Zamknieta int
select @PFzROPrzeksztalconymDalej = 0,@PFzRO = 0,@Zamknieta = 0
select  top 1 @PFzRO = a.Trr_TrNId,@Zamknieta = isnull(TrN_ZwroconoCalaIlosc,0)  from cdn.tranagrelacje a
left join cdn.tranag on a.Trr_TrNId = TrN_TrNId
where a.TrR_FaId =@ID AND a.Trr_TrNTyp =308 and trn_bufor != -1
order by TrN_ZwroconoCalaIlosc
select @PFzROPrzeksztalconymDalej = count(a.Trr_TrNId) from cdn.tranagrelacje a
join  cdn.tranagrelacje b on a.trr_trnid=b.trr_trnid and b.trr_fatyp in (302,306,305,312,304)
where a.TrR_FaId =@ID AND a.Trr_TrNTyp =308
and b.Trr_faId not in (select  Trr_TrNId from cdn.tranagrelacje  where TrR_FaId =@ID)
if @PFzROPrzeksztalconymDalej > 0 set @PFzROPrzeksztalconymDalej = 1
if @Zamknieta < 4
 set @Zamknieta = 0
select @PFzRO, @PFzROPrzeksztalconymDalej,@Zamknieta
SET NOCOUNT OFF
