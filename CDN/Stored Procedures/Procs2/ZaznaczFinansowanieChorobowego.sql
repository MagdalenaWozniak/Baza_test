--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure [CDN].[ZaznaczFinansowanieChorobowego] @iPreId int, @sDataUr varchar(10)
as
set nocount on
 declare @dDataUr datetime, @DataUstalona datetime
 if @sDataUr is not null
 begin
  select @dDataUr = convert(datetime, @sDataUr, 120)
  declare @DataChor datetime
  declare @DataStr varchar(4)
  set @DataChor = dateadd(year, 51, @dDataUr)
  set @DataStr = cast(year(@DataChor) as varchar)
  set @DataChor = convert(datetime, @DataStr, 120)
  set @DataUstalona = convert(datetime, '2009-01-01', 120)
  if @DataChor < @DataUstalona
   set @DataChor = @DataUstalona
  update cdn.PracEtaty
   set PRE_ABSFinansowanePracodawca = 1, PRE_ABSFinansowanePracodawcaDni = 14, PRE_ABSFinansowanePracodawcaOd = @DataChor
   where PRE_PreId = @iPreId
 end
set nocount off
