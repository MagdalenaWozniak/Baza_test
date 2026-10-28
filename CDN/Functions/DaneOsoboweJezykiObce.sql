create function cdn.DaneOsoboweJezykiObce(@praid int)
returns @PersonalData table
 (
  Id int,
  Name nvarchar(128),
  KnownledgeInSpeech nvarchar(128),
  KnownledgeInWriting nvarchar(128)
 )
as
begin
 insert into @PersonalData
  (Id, Name, KnownledgeInSpeech, KnownledgeInWriting)
  select
   @praid,
   Name = A.UPR_Nazwa,
   KnownledgeInSpeech = cdn.StopienUprawnieniaEng(UPR_StMowa),
   KnownledgeInWriting = cdn.StopienUprawnieniaEng(UPR_StPismo)
   from cdn.Uprawnienia A
    where A.UPR_Rodzaj = 2 and A.UPR_PraId = @praid
 return
end
