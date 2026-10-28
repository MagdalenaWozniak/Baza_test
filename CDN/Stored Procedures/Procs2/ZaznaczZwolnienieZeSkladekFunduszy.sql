--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure [CDN].[ZaznaczZwolnienieZeSkladekFunduszy] @iPreId int, @sDataUr varchar(10), @sPlec varchar(1), @sDataZatr varchar(10)
as
set nocount on
 declare @dDataUr datetime, @dDataZatr datetime
 declare @DataOd datetime, @DataDo datetime, @DataUstalona datetime
 declare @MiesiacUr int, @DzienUr int
 declare @IloscLat int
 declare @Przestepny tinyint
 declare @DzienPrzestepny int
 if @sDataUr is not null
 begin
  select @dDataUr = convert(datetime, @sDataUr, 120)
  select @dDataZatr = convert(datetime, @sDataZatr, 120)
  set @MiesiacUr = month(@dDataUr)
  set @DzienUr = day(@dDataUr)
  set @Przestepny = 0
  if @MiesiacUr = 2 and @DzienUr = 29
   set @Przestepny = 1
  if @sPlec like 'K'
   set @IloscLat = 55
  else
   set @IloscLat = 60
  set @DataDo = convert(datetime, '2999-12-31 00:00:00.000', 120)
  set @DataOd = dateadd(year, @IloscLat, @dDataUr)
  set @DataOd = dateadd(day, -@DzienUr + 1, @DataOd)
  --set @DataUstalona = cast('20090701' as datetime)
  set @DataUstalona = convert(datetime, '2009-07-01', 120)
  if @DzienUr > 1
   set @DataOd = dateadd(month, 1, @DataOd)
  if @Przestepny > 0
   begin
    set @DzienPrzestepny = day(@DataOd)
    if @DzienPrzestepny <> @DzienUr
     begin
      if @sPlec like 'K'
       set @DataOd = dateadd(day, 0, @DataOd + 1)
      else
       set @DataOd = dateadd(day, 0, @DataOd)
     end
   end
  if @DataOd < @DataUstalona
   set @DataOd = @DataUstalona
  declare @DataOd2 datetime
  set @DataOd2 = @DataOd
  if @dDataZatr > convert(datetime, '1900-01-01', 120)
  begin
   select @dDataZatr = dateadd(dd, -(day(@dDataZatr)-1), @dDataZatr)
   set @DataOd2 = @dDataZatr
  end
  update cdn.PracEtaty
   set PRE_NieNaliczacFP = 1, PRE_NieNaliczacFGSP = 1, PRE_FPOd = @DataOd, PRE_FPDo = @DataDo, PRE_FGSPOd = @DataOd2, PRE_FGSPDo = @DataDo
   where PRE_PreId = @iPreId
 end
set nocount off
