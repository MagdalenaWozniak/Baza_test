create procedure CDN.sp_PracModyfikujWejscia
    @prac int,      -- id pracownika
  @data varchar(10),  -- data
  @mod datetime = null, -- ts_mod
  @baza datetime = null, -- baza
  @godzOd1 int = null, -- od godz 1
  @godzDo1 int = null, -- do godz 1
  @strefa1 int = null, -- strefa 1
  @dzial1 int = null, -- dzial 1
  @projekt1 int = null, -- projekt 1
  @orgGodzOd1 int = null, -- org od godz 1
  @orgGodzDo1 int = null, -- org do godz 1
  @orgStrefa1 int = null, -- org strefa 1
  @orgDzial1 int = null, -- org dzial 1
  @orgProjekt1 int = null, -- org projekt 1
  @godzOd2 int = null, -- od godz 2
  @godzDo2 int = null, -- do godz 2
  @strefa2 int = null, -- strefa 2
  @dzial2 int = null, -- dzial 2
  @projekt2 int = null, -- projekt 2
  @orgGodzOd2 int = null, -- org od godz 2
  @orgGodzDo2 int = null, -- org do godz 2
  @orgStrefa2 int = null, -- org strefa 2
  @orgDzial2 int = null, -- org dzial 2
  @orgProjekt2 int = null, -- org projekt 2
  @godzOd3 int = null, -- od godz 3
  @godzDo3 int = null, -- do godz 3
  @strefa3 int = null, -- strefa 3
  @dzial3 int = null, -- dzial 3
  @projekt3 int = null, -- projekt 3
  @orgGodzOd3 int = null, -- org od godz 3
  @orgGodzDo3 int = null, -- org do godz 3
  @orgStrefa3 int = null, -- org strefa 3
  @orgDzial3 int = null, -- org dzial 3
  @orgProjekt3 int = null, -- org projekt 3
  @godzOd4 int = null, -- od godz 4
  @godzDo4 int = null, -- do godz 4
  @strefa4 int = null, -- strefa 4
  @dzial4 int = null, -- dzial 4
  @projekt4 int = null, -- projekt 4
  @orgGodzOd4 int = null, -- org od godz 4
  @orgGodzDo4 int = null, -- org do godz 4
  @orgStrefa4 int = null, -- org strefa 4
  @orgDzial4 int = null, -- org dzial 4
  @orgProjekt4 int = null, -- org projekt 4
  @godzOd5 int = null, -- od godz 5
  @godzDo5 int = null, -- do godz 5
  @strefa5 int = null, -- strefa 5
  @dzial5 int = null, -- dzial 5
  @projekt5 int = null, -- projekt 5
  @orgGodzOd5 int = null, -- org od godz 5
  @orgGodzDo5 int = null, -- org do godz 5
  @orgStrefa5 int = null, -- org strefa 5
  @orgDzial5 int = null, -- org dzial 5
  @orgProjekt5 int = null, -- org projekt 5
  @godzOd6 int = null, -- od godz 6
  @godzDo6 int = null, -- do godz 6
  @strefa6 int = null, -- strefa 6
  @dzial6 int = null, -- dzial 6
  @projekt6 int = null, -- projekt 6
  @orgGodzOd6 int = null, -- org od godz 6
  @orgGodzDo6 int = null, -- org do godz 6
  @orgStrefa6 int = null, -- org strefa 6
  @orgDzial6 int = null, -- org dzial 6
  @orgProjekt6 int = null -- org projekt 6
as
  set nocount on;
  begin tran
  update CDN.PracPracaDni
    set PPR_TS_Mod=@mod
  where PPR_PraId=@prac and
    PPR_Data=CONVERT(datetime,@data,120)
  declare @id int
    declare PWCursor cursor fast_forward for
        select PPR_PprId from CDN.PracPracaDni
    where PPR_PraId=@prac and
    PPR_Data=CONVERT(datetime,@data,120)
    open PWCursor
  fetch next from PWCursor into @id
  while @@fetch_status = 0
  begin
      exec CDN.sp_PracModyfikujWejscie @id,1,@baza,@godzOd1,@godzDo1,@strefa1,@dzial1,@projekt1,@orgGodzOd1,@orgGodzDo1,@orgStrefa1,@orgDzial1,@orgProjekt1
    exec CDN.sp_PracModyfikujWejscie @id,2,@baza,@godzOd2,@godzDo2,@strefa2,@dzial2,@projekt2,@orgGodzOd2,@orgGodzDo2,@orgStrefa2,@orgDzial2,@orgProjekt2
    exec CDN.sp_PracModyfikujWejscie @id,3,@baza,@godzOd3,@godzDo3,@strefa3,@dzial3,@projekt3,@orgGodzOd3,@orgGodzDo3,@orgStrefa3,@orgDzial3,@orgProjekt3
    exec CDN.sp_PracModyfikujWejscie @id,4,@baza,@godzOd4,@godzDo4,@strefa4,@dzial4,@projekt4,@orgGodzOd4,@orgGodzDo4,@orgStrefa4,@orgDzial4,@orgProjekt4
    exec CDN.sp_PracModyfikujWejscie @id,5,@baza,@godzOd5,@godzDo5,@strefa5,@dzial5,@projekt5,@orgGodzOd5,@orgGodzDo5,@orgStrefa5,@orgDzial5,@orgProjekt5
    exec CDN.sp_PracModyfikujWejscie @id,6,@baza,@godzOd6,@godzDo6,@strefa6,@dzial6,@projekt6,@orgGodzOd6,@orgGodzDo6,@orgStrefa6,@orgDzial6,@orgProjekt6
    fetch next from PWCursor into @id
  end
  close PWCursor
  deallocate PWCursor
  commit tran
  set nocount off;
