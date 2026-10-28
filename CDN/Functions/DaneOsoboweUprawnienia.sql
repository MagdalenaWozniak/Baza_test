create function cdn.DaneOsoboweUprawnienia(@praid int)
returns @PersonalData table
 (
  Id int,
  Name nvarchar(128),
  ValidTo nvarchar(10)
 )
as
begin
 insert into @PersonalData
  (Id, Name, ValidTo)
  select
   @praid,
   Name = B.DKM_Nazwa,
   ValidTo = case when year(A.UPR_KursTermin) < 1901 then null else convert(nvarchar(10), A.UPR_KursTermin, 111) end
   from cdn.Uprawnienia A join cdn.DaneKadMod B on A.UPR_DkmId = B.DKM_DkmId
    where A.UPR_Rodzaj = 1 and A.UPR_PraId = @praid
 return
end
