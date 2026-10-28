create function cdn.DaneOsoboweSchematPlatnosci(@praid int)
returns @PersonalData table
 (
  Id int,
  Bank nvarchar(128),
  AccountNumber nvarchar(128)
 )
as
begin
  insert into @PersonalData
   (Id, Bank, AccountNumber)
   select
    @praid,
    case when isnull(rtrim(BNA_Nazwa1 + ' ' + BNA_Nazwa2), '') = '' then null else BNA_Nazwa1 + ' ' + BNA_Nazwa2 end as [@bank],
    case when isnull(SPL_RachunekNr, '') = '' then null else SPL_RachunekNr end as [@accountnumber]
   from cdn.SchematPlatnosci join cdn.BnkNazwy on BNA_BnaId = SPL_BnaId
      where SPL_PodmiotTyp = 3 and SPL_PodmiotID = @praid
 return
end
