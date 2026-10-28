create procedure CDN.sp_PracDodajWejscia
  @prac int,      -- id pracownika
  @data varchar(10),  -- data
  @zal datetime = null, -- ts_zal
  @mod datetime = null, -- ts_mod
  @baza datetime = null, -- baza
  @godzOd1 int = null, -- od godz 1
  @godzDo1 int = null, -- do godz 1
  @strefa1 int = null, -- strefa 1
  @dzial1 int = null, -- dzial 1
  @projekt1 int = null, -- projekt 1
  @godzOd2 int = null, -- od godz 2
  @godzDo2 int = null, -- do godz 2
  @strefa2 int = null, -- strefa 2
  @dzial2 int = null, -- dzial 2
  @projekt2 int = null, -- projekt 2
  @godzOd3 int = null, -- od godz 3
  @godzDo3 int = null, -- do godz 3
  @strefa3 int = null, -- strefa 3
  @dzial3 int = null, -- dzial 3
  @projekt3 int = null, -- projekt 3
  @godzOd4 int = null, -- od godz 4
  @godzDo4 int = null, -- do godz 4
  @strefa4 int = null, -- strefa 4
  @dzial4 int = null, -- dzial 4
  @projekt4 int = null, -- projekt 4
  @godzOd5 int = null, -- od godz 5
  @godzDo5 int = null, -- do godz 5
  @strefa5 int = null, -- strefa 5
  @dzial5 int = null, -- dzial 5
  @projekt5 int = null, -- projekt 5
  @godzOd6 int = null, -- od godz 6
  @godzDo6 int = null, -- do godz 6
  @strefa6 int = null, -- strefa 6
  @dzial6 int = null, -- dzial 6
  @projekt6 int = null -- projekt 6
as
  set nocount on;
  declare @id int;
  begin tran
  insert into CDN.PracPracaDni (PPR_PraId,PPR_Data,PPR_TS_Zal,PPR_TS_Mod,PPR_Zrodlo)
  values (@prac,CONVERT(datetime,@data,120),@zal,@mod,0);
  set @id = scope_identity();
  if (@strefa1 = 1 and @strefa2 = 1 and @strefa3 = 1 and @strefa4 = 1 and @strefa5 = 1 and @strefa6 = 1)
      begin
      insert into CDN.PracPracaDniGodz (PGR_PprId,PGR_Lp,PGR_OdGodziny,PGR_DoGodziny,PGR_Strefa,PGR_DzlId,PGR_PrjId,PGR_OdbNadg,PGR_Uwagi)
      values (@id, 1, DATEADD(minute,0,@baza), DATEADD(minute,0,@baza),1,@dzial1,@projekt1,1,'');
    end
  else
      begin
          if (@strefa1 is not null) and (@strefa1 > 1)
        begin
          insert into CDN.PracPracaDniGodz (PGR_PprId,PGR_Lp,PGR_OdGodziny,PGR_DoGodziny,PGR_Strefa,PGR_DzlId,PGR_PrjId,PGR_OdbNadg,PGR_Uwagi)
          values (@id, 1, DATEADD(minute,@godzOd1,@baza), DATEADD(minute,@godzDo1,@baza),@strefa1,@dzial1,@projekt1,1,'');
        end
      if (@strefa2 is not null) and (@strefa2 > 1)
        begin
          insert into CDN.PracPracaDniGodz (PGR_PprId,PGR_Lp,PGR_OdGodziny,PGR_DoGodziny,PGR_Strefa,PGR_DzlId,PGR_PrjId,PGR_OdbNadg,PGR_Uwagi)
          values (@id, 2, DATEADD(minute,@godzOd2,@baza), DATEADD(minute,@godzDo2,@baza),@strefa2,@dzial2,@projekt2,1,'');
        end
      if (@strefa3 is not null) and (@strefa3 > 1)
        begin
          insert into CDN.PracPracaDniGodz (PGR_PprId,PGR_Lp,PGR_OdGodziny,PGR_DoGodziny,PGR_Strefa,PGR_DzlId,PGR_PrjId,PGR_OdbNadg,PGR_Uwagi)
          values (@id, 3, DATEADD(minute,@godzOd3,@baza), DATEADD(minute,@godzDo3,@baza),@strefa3,@dzial3,@projekt3,1,'');
        end
      if (@strefa4 is not null) and (@strefa4 > 1)
        begin
          insert into CDN.PracPracaDniGodz (PGR_PprId,PGR_Lp,PGR_OdGodziny,PGR_DoGodziny,PGR_Strefa,PGR_DzlId,PGR_PrjId,PGR_OdbNadg,PGR_Uwagi)
          values (@id, 4, DATEADD(minute,@godzOd4,@baza), DATEADD(minute,@godzDo4,@baza),@strefa4,@dzial4,@projekt4,1,'');
        end
      if (@strefa5 is not null) and (@strefa5 > 1)
        begin
          insert into CDN.PracPracaDniGodz (PGR_PprId,PGR_Lp,PGR_OdGodziny,PGR_DoGodziny,PGR_Strefa,PGR_DzlId,PGR_PrjId,PGR_OdbNadg,PGR_Uwagi)
          values (@id, 5, DATEADD(minute,@godzOd5,@baza), DATEADD(minute,@godzDo5,@baza),@strefa5,@dzial5,@projekt5,1,'');
        end
      if (@strefa6 is not null) and (@strefa6 > 1)
        begin
          insert into CDN.PracPracaDniGodz (PGR_PprId,PGR_Lp,PGR_OdGodziny,PGR_DoGodziny,PGR_Strefa,PGR_DzlId,PGR_PrjId,PGR_OdbNadg,PGR_Uwagi)
          values (@id, 6, DATEADD(minute,@godzOd6,@baza), DATEADD(minute,@godzDo6,@baza),@strefa6,@dzial6,@projekt6,1,'');
        end
      end
  commit tran
  set nocount off;
