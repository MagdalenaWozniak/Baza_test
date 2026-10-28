CREATE PROCEDURE  [CDN].[Mobile_EksportMag]
        @ID    INT
AS
select mag_magid, mag_nazwa,mag_symbol,case when mag_typ = 4 then 1 else 0 end as mag_domyslny, mag_nieaktywny from cdn.magazyny
where (mag_magid = (select dsta_magid from cdn.detalstanowiska where dsta_dstaid = @ID)
or mag_typ = 1) and mag_nieaktywny = 0
