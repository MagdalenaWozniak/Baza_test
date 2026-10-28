create function cdn.ESKLEP_EksportCrosSelingZestawNieEksportowalny( @ZTwId int , @TypExp int , @DateTSSynchr datetime , @NrCenyInt int , @EsklepCena0Int int )
   returns int
   as
   begin
   return ( select
    sum( case when ( N.TwC_Wartosc > 0 or @EsklepCena0Int <> 1 ) then 0 else 1 end)
   + sum(case when ( E.TwC_Wartosc > 0 or @EsklepCena0Int <> 1 ) then 0 else 1 end)
   from cdn.ZestawyTwr    join cdn.ZestawyTwrSkladniki on ZTw_ZTwId = ZTS_ZTwId
   join cdn.twrceny as N on ZTw_TwrId = N.TwC_TwrID and N.TwC_TwCNumer = @NrCenyInt
   join cdn.twrceny as E on ZTS_TwrId = E.TwC_TwrID and E.TwC_TwCNumer = @NrCenyInt
  where ZTw_ZTwId = @ZTwId
and ZTw_ESklep = 1 and
ztw_TS_Mod > (CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END)
)
end
