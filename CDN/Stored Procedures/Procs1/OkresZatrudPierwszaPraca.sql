--/////////////////////////////////////////////////////////////////////////////////////////////////////
CREATE proc cdn.OkresZatrudPierwszaPraca
@praId int, @dzien datetime
as
begin
SET NOCOUNT ON
declare @datZat as datetime
declare @datZwol as datetime
declare @HistOd as datetime
declare @HistDo as datetime
declare @HistZatrOd as datetime
declare @HistZatrDo as datetime
declare @PierwszaPr as bit
declare @EtatL as int
declare @EtatM as int
declare @znalezione as bit
declare @EtatLPop as int
declare @EtatMPop as int
set @znalezione = 0
DECLARE Historia CURSOR LOCAL FAST_FORWARD
                    FOR
     select
     PRE_DataOd, PRE_DataDo, PRE_ZatrudnionyOd,
     PRE_ZatrudnionyDo,PRE_ABSPierwszyLimit,
     PRE_ETAEtatL, PRE_ETAEtatM
     from cdn.PracEtaty where
     PRE_PraId = @praId
     OPEN Historia
     WHILE 1 = 1
                    BEGIN
                        -- aktualizuj limit
                        FETCH NEXT FROM Historia INTO @HistOd,@HistDo,@HistZatrOd,@HistZatrDo,@PierwszaPr,@EtatL,@EtatM;
                        IF @@fetch_status <> 0
                            BREAK;
     if @znalezione = 0 and @HistOd <= @dzien and @dzien <= @HistDo
      set @znalezione = 1
     if @znalezione = 1 and (@EtatLPop is null or @EtatMPop is null)
     begin
      set @EtatLPop = @EtatL
      set @EtatMPop = @EtatM
     end
     if @znalezione = 1 and (@datZat is NULL or @datZwol is NULL)
     begin
      set @datZat = @HistZatrOd
      if @HistDo < @HistZatrDo
       set @datZwol = @HistDo
      else
       set @datZwol = @HistZatrDo
     end
     if @znalezione = 1 and @datZat = @HistZatrOd
     begin
      if @EtatLPop = @EtatL and @EtatMPop = @EtatM
       begin
        if @HistDo < @HistZatrDo
         set @datZwol = @HistDo
        else
         set @datZwol = @HistZatrDo
       end
      end
     end
select @datZat as 'Zatrudnienie' , @datZwol as 'Zwolnienie'
SET NOCOUNT OFF
end
