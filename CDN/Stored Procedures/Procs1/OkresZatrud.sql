--/////////////////////////////////////////////////////////////////////////////////////////////////////
create proc cdn.OkresZatrud
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
declare @znalezione as bit
set @znalezione = 0
DECLARE Historia CURSOR LOCAL FAST_FORWARD
                    FOR
     select
     PRE_DataOd, PRE_DataDo, PRE_ZatrudnionyOd,
     PRE_ZatrudnionyDo
     from cdn.PracEtaty where
     PRE_PraId = @praId
     OPEN Historia
     WHILE 1 = 1
                    BEGIN
                        -- aktualizuj limit
                        FETCH NEXT FROM Historia INTO @HistOd,@HistDo,@HistZatrOd,@HistZatrDo;
                        IF @@fetch_status <> 0
                            BREAK;
     if @znalezione = 0 and @HistOd <= @dzien and @dzien <= @HistDo
      set @znalezione = 1
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
