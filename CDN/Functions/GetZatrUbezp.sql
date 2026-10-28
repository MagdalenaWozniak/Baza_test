create function [CDN].[GetZatrUbezp] (@PraId int, @DateIn DateTime)
returns @Zatrudnienie table
(
 Zatrudnienie int,
    Ubezpieczenie int,
 PrawoER int,
 StNiepel int
)
as
begin
 declare @ZatrOd datetime
 declare @Zatr int, @Ubezp int, @PrawoER int, @StNiepel int
 set @Zatr = 0
 set @Ubezp = 0
 set @PrawoER = 0
 set @StNiepel = 0
 select top 1 @ZatrOd = PRE_ZatrudnionyOd, @Ubezp = PRE_UBZTyuId, @PrawoER = PRE_PrawoER, @StNiepel = PRE_StNiepelnosp from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataOd <= @DateIn and PRE_DataDo >= @DateIn
 if @ZatrOd is not null
  set @Zatr = 1
 insert into @Zatrudnienie (Zatrudnienie, Ubezpieczenie, PrawoER, StNiepel) select @Zatr, @Ubezp, @PrawoER, @StNiepel
 return
end
