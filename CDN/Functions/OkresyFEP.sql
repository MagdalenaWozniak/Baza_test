create function [CDN].[OkresyFEP] (@PraId int, @OkresOd datetime, @OkresDo datetime)
returns @RESULT table
(
 Dni int,
 DniFEP int
)
as
begin
 declare
 @DataOd datetime, @DataDo datetime,
 @FEPOd datetime, @FEPDo datetime,
 @KodFEP int, @Dni int, @DniFEP int
 declare @FEP table
(
 Id int,
 FEPOd datetime,
 FEPDo datetime,
 FEPKod int,
 DataOd datetime,
 DataDo datetime,
 ZatrudnionyOd datetime,
 ZatrudnionyDo datetime
)
declare @Miesiac table
(
 Dzien datetime,
 ZliczonyDzienFEP int,
 ZliczonyDzien int
)
declare @Okresy table
(
 Id int,
 DataOd datetime,
 DataDo datetime,
 ZatrudnionyOd datetime,
 ZatrudnionyDo datetime
)
insert into @Okresy
 select PRE_PreId, PRE_DataOd, PRE_DataDo, PRE_ZatrudnionyOd, PRE_ZatrudnionyDo
 from cdn.PracEtaty
 where pre_praid = @PraId and (PRE_DataOd <= @OkresDo and PRE_DataDo >= @OkresOd)
insert into @FEP
 select
  pre_preid,
  case when PRE_FEPOd < PRE_DataOd then
   case when PRE_DataOd < @OkresOd then @OkresOd else PRE_DataOd end
  when (PRE_FEPOd is null or PRE_FEPOd < convert(datetime, '1900-01-02', 120)) then
   @OkresOd
  else
   isnull(PRE_FEPOd, PRE_DataOd)
  end,
  case when PRE_FEPDo > PRE_DataDo then
   case when PRE_DataDo > @OkresDo then @OkresDo else PRE_DataDo end
  when (PRE_FEPDo is null or PRE_FEPDo > convert(datetime, '2999-12-30', 120) or PRE_FEPDo < convert(datetime, '1900-01-02', 120)) then
   case when PRE_DataDo > @OkresDo then @OkresDo else PRE_DataDo end
  else
   isnull(PRE_FEPDo, PRE_DataDo)
  end,
  PRE_KodFEP,
  @OkresOd,
  @OkresDo,
  PRE_ZatrudnionyOd,
  PRE_ZatrudnionyDo
 from cdn.PracEtaty
 where pre_praid = @PraId and PRE_KodFEP > 0 and (PRE_DataOd <= @OkresDo and PRE_DataDo >= @OkresOd)
 update @FEP set FEPOd = @OkresOd where FEPOd < @OkresOd
 update @FEP set FEPDo = @OkresDo where FEPDo > @OkresDo
 update @FEP set FEPOd = ZatrudnionyOd where FEPOd < ZatrudnionyOd
 update @FEP set FEPDo = ZatrudnionyDo where FEPDo > ZatrudnionyDo
 update @FEP set DataOd = ZatrudnionyOd where DataOd < ZatrudnionyOd
 update @FEP set DataDo = ZatrudnionyDo where DataDo > ZatrudnionyDo
 update @FEP set DataOd = @OkresOd where DataOd < @OkresOd
 update @FEP set DataDo = @OkresDo where DataDo > @OkresDo
 declare @DOd datetime, @DDo datetime, @ZOd datetime, @ZDo datetime, @IdTemp int
 declare @ZDoTemp datetime
 update @Okresy set DataOd = @OkresOd where DataOd < @OkresOd
 update @Okresy set DataDo = @OkresDo where DataDo > @OkresDo
 update @Okresy set DataOd = ZatrudnionyOd where DataOd < ZatrudnionyOd
 update @Okresy set DataDo = ZatrudnionyDo where DataDo > ZatrudnionyDo and ZatrudnionyDo >= @OkresOd
 delete from @Okresy where DataOd > ZatrudnionyDo
 declare @DniOkresyZatr int
 set @DniOkresyZatr = 0
declare DATY0 cursor local fast_forward for
 select Id, DataOd, DataDo, ZatrudnionyOd, ZatrudnionyDo from @Okresy order by DataDo
  open DATY0
   while (1=1)
   begin
    fetch next from DATY0 into @IdTemp, @DOd, @DDo, @ZOd, @ZDo
    if @@fetch_status <> 0 break
    set @DniOkresyZatr = @DniOkresyZatr + DATEDIFF(dd, @DOd, @DDo) + 1
   end
  close DATY0
 deallocate DATY0
 declare
  @FEPOd2 datetime,
  @FEPDo2 datetime,
  @DataOd2 datetime,
  @DataDo2 datetime
  declare @DniOkresy int, @DniOkresyFEP int
  set @DniOkresy = @DniOkresyZatr
  set @DniOkresyFEP = 0
  declare @MaxOd datetime, @MaxDo datetime
  select @MaxOd = max(DataOd) from @FEP
  select @MaxDo = max(DataDo) from @FEP
  declare @DataIdx0 datetime
  set @DataIdx0 = @MaxOd
  while(@DataIdx0 < @MaxDo + 1)
  begin
     insert into @Miesiac (Dzien, ZliczonyDzien, ZliczonyDzienFEP) values (@DataIdx0, 0, 0)
  set @DataIdx0 = DATEADD(d, 1, @DataIdx0)
  end
declare DATY cursor local fast_forward for
 select DataOd, DataDo from @FEP group by DataOd, DataDo
  open DATY
   while (1=1)
   begin
    fetch next from DATY into @DataOd2, @DataDo2
    if @@fetch_status <> 0 break
    declare @DataIdx datetime
    set @DataIdx = @DataOd2 - 1
    while(@DataIdx < @DataDo2 + 1)
    begin
     if(select FEPOd from @FEP where @DataIdx >= FEPOd and @DataIdx <= FEPDo) is not null
     begin
      if(select ZliczonyDzienFEP from @Miesiac where Dzien = @DataIdx) = 1
      begin
       set @DniOkresyFEP = @DniOkresyFEP
      end
      else
      begin
       set @DniOkresyFEP = @DniOkresyFEP + 1
       update @Miesiac set ZliczonyDzienFEP = 1 where Dzien = @DataIdx
      end
     end
     set @DataIdx = DATEADD(d, 1, @DataIdx)
    end
   end
  close DATY
 deallocate DATY
 select @DniFEP = @DniOkresyFEP
 select @Dni = @DniOkresy
 insert into @RESULT values (@Dni, @DniFEP)
 return
end
