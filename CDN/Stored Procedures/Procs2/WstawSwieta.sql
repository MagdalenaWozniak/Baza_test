CREATE PROCEDURE CDN.WstawSwieta @DataOd datetime, @DataDo datetime, @KalId int
AS
declare @dzien      datetime
declare @DzienWolny int
set @dzien          = @DataOd
declare @StrefaPodstawowa int
declare @StrefaUndefined int
set @StrefaPodstawowa = (select Dst_DstId from Cdn.DefinicjeStref where Dst_Standardowy=1)
set @StrefaUndefined = (select Dst_DstId from Cdn.DefinicjeStref where Dst_Standardowy=99)
declare @OdwId int
set @OdwId = (select ODW_OdwId from cdn.OpisyDniWolne where ODW_Standardowy = 2)
declare @KadId int, @select int
while @dzien <= @DataDo
 begin
  set @dzien = convert(datetime,  @dzien, 120)
  --DSi2019.0 [blad konwersji po automatycznym dodaniu swiat]
  select @select = KAD_KadId from CDN.KalendDni where KAD_Data = @dzien and KAD_KalId = @KalId
  exec @DzienWolny = CDN.CzyDzienWolny @dzien
  --if @DzienWolny = 3
  if @DzienWolny = 3 and isnull(@select, -1) = -1
   begin
    insert into cdn.kalenddni (KAD_KalId,KAD_Data,KAD_TypDnia, KAD_OdwId,KAD_TS_Zal,KAD_TS_Mod)
  values (@KalId,@dzien, @DzienWolny, @OdwId, GETDATE(), GETDATE())
    select @KadId = MAX(kad_kadid) from cdn.KalendDni
    --WiNi insert into cdn.kalenddnigodz (KDG_KadId,kdg_lp,KDG_OdGodziny,KDG_DoGodziny,KDG_Strefa,kdg_dzlid,kdg_prjid,KDG_TS_Zal,KDG_TS_Mod) values (@KadId,1, CONVERT(DATETIME, '1899-12-30',120), CONVERT(DATETIME, '1899-12-30',120),@StrefaUndefined,1,1,GetDate(), GetDate())
    insert into cdn.kalenddnigodz (KDG_KadId,kdg_lp,KDG_OdGodziny,KDG_DoGodziny,KDG_Strefa) values (@KadId,1, CONVERT(DATETIME, '1899-12-30',120), CONVERT(DATETIME, '1899-12-30',120),@StrefaUndefined)
   end
   set @dzien = @dzien  + 1
 end
