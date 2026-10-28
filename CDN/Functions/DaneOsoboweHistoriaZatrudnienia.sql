create function cdn.DaneOsoboweHistoriaZatrudnienia(@praid int)
returns @PersonalData table
 (
  Id int,
  Name nvarchar(128),
  DateFrom nvarchar(10),
  DateTo nvarchar(10)
 )
as
begin
 insert into @PersonalData
  (Id, Name, DateFrom, DateTo)
  select
   @praid,
   A.HZT_Nazwa,
   case when year(A.HZT_OkresOd) < 1901 then null else convert(nvarchar(10), A.HZT_OkresOd, 111) end,
   case when year(A.HZT_OkresDo) > 2900 then null else convert(nvarchar(10), A.HZT_OkresDo, 111) end
  from cdn.HisZatrud A
   where A.HZT_PraId = @praid
 return
end
