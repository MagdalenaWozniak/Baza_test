CREATE PROCEDURE CDN.PodajCzasPracyS @data datetime, @odgodz datetime, @dogodz datetime, @normalubczas int, @StrefaId int
AS
declare @czas int
declare @typstrefy int
declare @wliczaj int
SET @czas = 0
select @typstrefy = dst_standardowy, @wliczaj =dst_uwzglczaspracy from cdn.definicjestref where dst_dstid=@StrefaId
IF @typstrefy<>99
BEGIN
 SET @czas = 0
 SET @czas = CDN.Czas (@odgodz, @dogodz)
 IF @wliczaj=0
    SET @czas = 0
END
RETURN @czas
