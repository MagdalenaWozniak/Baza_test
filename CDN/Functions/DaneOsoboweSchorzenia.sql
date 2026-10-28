create function cdn.DaneOsoboweSchorzenia(@praid int)
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
   Name = B.DKM_Nazwa,
   DateFrom = case when year(A.PRS_DataOd) < 1901 then null else convert(nvarchar(10), A.PRS_DataOd, 111) end,
   DateTo = case when year(A.PRS_DataDo) < 2900 then null else convert(nvarchar(10), A.PRS_DataDo, 111) end
   from cdn.PracSchorzenia A join cdn.DaneKadMod B on A.PRS_DkmId = B.DKM_DkmId
    where B.DKM_Rodzaj = 5 and A.PRS_PraId = @praid
 return
end
