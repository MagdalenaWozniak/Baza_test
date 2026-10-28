create function cdn.DaneOsoboweHistoriaWyksztalcenia(@praid int)
returns @PersonalData table
 (
  Id int,
  Name nvarchar(128),
  Profession nvarchar(128),
  Speciality nvarchar(128),
  Degree nvarchar(128),
  Title nvarchar(128)
 )
as
begin
 insert into @PersonalData
  (Id, Name, Profession, Speciality, Degree, Title)
  select
   @praid,
   A.HWY_Nazwa,
   A.HWY_Zawod,
   A.HWY_Specjalnosc,
   A.HWY_Stopien,
   A.HWY_Tytul
  from cdn.HisWyksztal A
   where A.HWY_PraId = @praid
 return
end
