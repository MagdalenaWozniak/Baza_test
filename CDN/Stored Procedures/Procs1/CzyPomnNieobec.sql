--/////////////////////////////////////////////////////////////////////////////////////////////////////
create proc [CDN].[CzyPomnNieobec] @NieobId int, @rok int
AS
BEGIN
SET NOCOUNT ON
DECLARE @dataOd AS DATETIME
DECLARE @dataDo AS DATETIME
DECLARE @firstDayOfYear AS DATETIME
DECLARE @lastDayOfYear AS DATETIME
DECLARE @czyLiczyc as INT
DECLARE @czyliczycPomn as INT
DECLARE @pracId as INT
SET @pracId = (SELECT PNB_PraId from cdn.PracNieobec where PNB_PnbId = @NieobId)
SET  @czyLiczyc = ( SELECT COUNT(*) FROM CDN.PracNieobec where PNB_PnbId = @NieobId and PNB_TyuId >= 1210 and PNB_TyuId <= 1230 )
if @czyLiczyc = 0
begin
SET  @czyliczycPomn = ( SELECT COUNT(*) FROM CDN.PracNieobec join cdn.TypNieobec on cdn.PracNieobec.PNB_TnbId = cdn.TypNieobec.TNB_TnbId where PNB_PnbId = @NieobId and TNB_PomnLimitUrlopu = 1 )
if @czyliczycPomn = 0
begin
 select 0 as liczba
 return
end
else
SELECT @dataOd = pnb_okresOd, @dataDo = pnb_okresDo from cdn.PracNieobec where PNB_PnbId = @NieobId
select @firstDayOfYear = CONVERT(datetime,'01-'+right('0'+convert(char(2),1),2)+'-'+convert(char(4),@rok),120)
select @lastDayOfYear =  CONVERT(datetime,'12-'+right('0'+convert(char(2),31),2)+'-'+convert(char(4),@rok),120)
IF YEAR(@dataOd) != @rok
 Set @dataOd = @firstDayOfYear
IF YEAR(@dataDo) != @rok
 Set @dataDo = @lastDayOfYear
WHILE 1=1
BEGIN
 IF EXISTS (SELECT * FROM CDN.PracNieobec join cdn.TypNieobec on cdn.PracNieobec.PNB_TnbId = cdn.TypNieobec.TNB_TnbId where PNB_praid = @pracId and PNB_OkresDo = dateadd(day,-1, @dataOd) and TNB_PomnLimitUrlopu = 1 and year(pnb_OkresOd) = @rok)
  SELECT @dataOd = pnb_okresOd from CDN.PracNieobec join cdn.TypNieobec on cdn.PracNieobec.PNB_TnbId = cdn.TypNieobec.TNB_TnbId where  PNB_praid = @pracId and PNB_OkresDo = dateadd(day,-1, @dataOd) and TNB_PomnLimitUrlopu = 1
 ELSE
  break
END
WHILE 1=1
BEGIN
 IF EXISTS (SELECT * FROM CDN.PracNieobec join cdn.TypNieobec on cdn.PracNieobec.PNB_TnbId = cdn.TypNieobec.TNB_TnbId where  PNB_praid = @pracId and PNB_OkresOd = dateadd(day,1, @dataDo) and TNB_PomnLimitUrlopu = 1 and year(pnb_OkresOd) = @rok)
  SELECT @dataDo = pnb_okresDo from CDN.PracNieobec join cdn.TypNieobec on cdn.PracNieobec.PNB_TnbId = cdn.TypNieobec.TNB_TnbId where  PNB_praid = @pracId and PNB_OkresOd = dateadd(day,1, @dataDo) and TNB_PomnLimitUrlopu = 1
 ELSE
  break
END
IF (@dataOd = @firstDayOfYear and @dataDo = @lastDayOfYear)
 SELECT 3 AS Liczba
ELSE IF (@dataOd > @firstDayOfYear and @dataDo = @lastDayOfYear)
 SELECT 2 AS Liczba
else
 select 0 as liczba
return
end
SELECT @dataOd = pnb_okresOd, @dataDo = pnb_okresDo from cdn.PracNieobec where PNB_PnbId = @NieobId
select @firstDayOfYear = CONVERT(datetime,'01-'+right('0'+convert(char(2),1),2)+'-'+convert(char(4),@rok),120)
select @lastDayOfYear =  CONVERT(datetime,'12-'+right('0'+convert(char(2),31),2)+'-'+convert(char(4),@rok),120)
IF YEAR(@dataOd) != @rok
 Set @dataOd = @firstDayOfYear
IF YEAR(@dataDo) != @rok
 Set @dataDo = @lastDayOfYear
WHILE 1=1
BEGIN
 IF EXISTS (SELECT * FROM CDN.PracNieobec where  PNB_praid = @pracId and PNB_OkresDo = dateadd(day,-1, @dataOd) and PNB_TyuId >= 1210 and PNB_TyuId <= 1230   and year(pnb_OkresOd) = @rok)
  SELECT @dataOd = pnb_okresOd from CDN.PracNieobec where  PNB_praid = @pracId and PNB_OkresDo = dateadd(day,-1, @dataOd) and  PNB_TyuId >= 1210 and PNB_TyuId <= 1230
 ELSE
  break
END
WHILE 1=1
BEGIN
 IF EXISTS (SELECT * FROM CDN.PracNieobec where  PNB_praid = @pracId and PNB_OkresOd = dateadd(day,1, @dataDo) and PNB_TyuId >= 1210 and PNB_TyuId <= 1230 and year(pnb_OkresOd) = @rok)
  SELECT @dataDo = pnb_okresDo from CDN.PracNieobec where  PNB_praid = @pracId and PNB_OkresOd = dateadd(day,1, @dataDo) and PNB_TyuId >= 1210 and PNB_TyuId <= 1230
 ELSE
  break
END
if @Rok = 2013
begin
 IF @dataOd = CONVERT(datetime,'2013-01-01',120) and @dataDo = CONVERT(datetime,'2013-12-31',120)
 SELECT 3 AS liczba
 else IF (@dataOd <= CONVERT(datetime,'2013-01-01',120)
  or (@dataOd > CONVERT(datetime,'2013-01-01',120) and @dataDo < CONVERT(datetime,'2013-09-30',120)))
  --select 'Pomniejszamy Proporcjonalnie',@dataOd, @dataDo
  select 1 as liczba
 else if @dataOd > CONVERT(datetime,'2013-01-01',120) and @dataDo >= CONVERT(datetime,'2013-09-30',120)
  --select 'Nie Pomniejszamy Proporcjonalnie',@dataOd, @dataDo
  select 2 as liczba
 else
  --select 'Cały Rok',@dataOd, @dataDo
  select 3 as liczba
end
else if @Rok > 2013
begin
declare @dataZwonl datetime
 set @dataZwonl = (select max(pre_zatrudnionyDo) from cdn.PracEtaty where pre_praid = @pracId and PRE_ZatrudnionyDo < CONVERT(datetime,'2999-12-31',120 ))
 if (@dataZwonl is not null and @dataOd = @firstDayOfYear and @dataDo = @dataZwonl)
  select  5 as liczba
 else
if @dataOd = @firstDayOfYear and @dataDo < @lastDayOfYear
 -- select 'Nie Pomniejszamy Proporcjonalnie',@dataOd, @dataDo
  select 0 as liczba
 else if @dataOd <> @firstDayOfYear and @dataDo <= @lastDayOfYear
 select 2 as liczba
 else if @dataOd = @firstDayOfYear and @dataDo = @lastDayOfYear
  --select 'Cały Rok',@dataOd, @dataDo
  select 3 as liczba
end
else
begin
 --select 'OldMethod',@dataOd, @dataDo
 select 0 as liczba
end
END
SET NOCOUNT OFF
