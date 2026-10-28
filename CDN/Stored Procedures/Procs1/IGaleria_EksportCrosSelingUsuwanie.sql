CREATE PROCEDURE [CDN].[IGaleria_EksportCrosSelingUsuwanie]
@TypExp INT=1
as
begin
declare
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @EsklepCena0Int int,
     @NrCenyInt int
select  top 1 @TSSynchr = ESS_TS_SynchroTwrPotw
       ,@EsklepCena0Int = ESS_EsklepCena0, @NrCenyInt = ESS_NrCeny
   from cdn.eSklepStanowiska where ESS_typ = 2
     SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
select
[@ID] = ZTw_ZTwId
from cdn.ZestawyTwr
where (ZTw_ESklep = 0
OR cdn.ESKLEP_EksportCrosSelingZestawNieEksportowalny( ztw_ZTwId , @TypExp, @DateTSSynchr, @NrCenyInt, @EsklepCena0Int) <> 0)
and (ztw_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END)
for xml  PATH('CSRS'),root('CSRSD')
end
