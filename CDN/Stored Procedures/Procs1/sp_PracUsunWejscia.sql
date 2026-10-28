create procedure CDN.sp_PracUsunWejscia
    @prac int,   -- id pracownika
 @data varchar(10), -- data
 @baza datetime = null, -- baza
 @orgGodzOd1 int = null, -- org od godz 1
 @orgGodzDo1 int = null, -- org do godz 1
 @orgStrefa1 int = null, -- org strefa 1
 @orgDzial1 int = null, -- org dzial 1
 @orgProjekt1 int = null, -- org projekt 1
 @orgGodzOd2 int = null, -- org od godz 2
 @orgGodzDo2 int = null, -- org do godz 2
 @orgStrefa2 int = null, -- org strefa 2
 @orgDzial2 int = null, -- org dzial 2
 @orgProjekt2 int = null, -- org projekt 2
 @orgGodzOd3 int = null, -- org od godz 3
 @orgGodzDo3 int = null, -- org do godz 3
 @orgStrefa3 int = null, -- org strefa 3
 @orgDzial3 int = null, -- org dzial 3
 @orgProjekt3 int = null, -- org projekt 3
 @orgGodzOd4 int = null, -- org od godz 4
 @orgGodzDo4 int = null, -- org do godz 4
 @orgStrefa4 int = null, -- org strefa 4
 @orgDzial4 int = null, -- org dzial 4
 @orgProjekt4 int = null, -- org projekt 4
 @orgGodzOd5 int = null, -- org od godz 5
 @orgGodzDo5 int = null, -- org do godz 5
 @orgStrefa5 int = null, -- org strefa 5
 @orgDzial5 int = null, -- org dzial 5
 @orgProjekt5 int = null, -- org projekt 5
 @orgGodzOd6 int = null, -- org od godz 6
 @orgGodzDo6 int = null, -- org do godz 6
 @orgStrefa6 int = null, -- org strefa 6
 @orgDzial6 int = null, -- org dzial 6
 @orgProjekt6 int = null -- org projekt 6
as
 set nocount on;
 begin tran
 declare @id int
    declare PWCursor cursor fast_forward for
        select PPR_PprId from CDN.PracPracaDni
  where PPR_PraId=@prac and
  PPR_Data=CONVERT(datetime,@data,120)
    open PWCursor
 fetch next from PWCursor into @id
 while @@fetch_status = 0
 begin
  exec CDN.sp_PracUsunWejsciaLp @id,1,@baza,@orgGodzOd1,@orgGodzDo1,@orgStrefa1,@orgDzial1,@orgProjekt1
  exec CDN.sp_PracUsunWejsciaLp @id,2,@baza,@orgGodzOd2,@orgGodzDo2,@orgStrefa2,@orgDzial2,@orgProjekt2
  exec CDN.sp_PracUsunWejsciaLp @id,3,@baza,@orgGodzOd3,@orgGodzDo3,@orgStrefa3,@orgDzial3,@orgProjekt3
  exec CDN.sp_PracUsunWejsciaLp @id,4,@baza,@orgGodzOd4,@orgGodzDo4,@orgStrefa4,@orgDzial4,@orgProjekt4
  exec CDN.sp_PracUsunWejsciaLp @id,5,@baza,@orgGodzOd5,@orgGodzDo5,@orgStrefa5,@orgDzial5,@orgProjekt5
  exec CDN.sp_PracUsunWejsciaLp @id,6,@baza,@orgGodzOd6,@orgGodzDo6,@orgStrefa6,@orgDzial6,@orgProjekt6
  fetch next from PWCursor into @id
 end
 close PWCursor
 deallocate PWCursor
 delete from CDN.PracPracaDni
  where PPR_PraId=@prac and
  PPR_Data=CONVERT(datetime,@data,120)
 commit tran
 set nocount off;
