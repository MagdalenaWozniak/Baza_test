create procedure CDN.KopiujOpisAnalityczny @dDataAkt NVARCHAR(10), @idPrac int, @iUmowy smallint, @iDodatki smallint, @iAkordy smallint
as
set nocount on
 declare @idZRODLO int,
   @idHistoria int
 if @iDodatki > 0
 begin
  declare DODATKIHIST cursor local fast_forward for
   select distinct DOH_DohId, PRE_PreId from cdn.DodatkiHist
             join cdn.Dodatki on DOH_DodId = DOD_DodId
             join cdn.PracEtaty on DOD_PraId = PRE_PraId
             where PRE_PraId = @idPrac and PRE_DataDo >= convert(datetime, '2999-12-31', 120)
             and (convert(datetime, @dDataAkt, 120) between DOH_WaznyOd and DOH_WaznyDo)
             and (convert(datetime, @dDataAkt, 120) between DOH_OkresOd and DOH_OkresDo)
  open DODATKIHIST
  while (1=1)
   begin
    fetch next from DODATKIHIST into @idZRODLO, @idHistoria
    if @@fetch_status <> 0
     break
     delete from cdn.OpisKadry where opk_rodzajzrodla = 17 and opk_zrodloid = @idZRODLO
     insert into cdn.OpisKadry
      select 17, @idZRODLO, @idPrac, opk_dzlid, opk_prjid, opk_procent from cdn.opiskadry
       where opk_rodzajzrodla = 16 and opk_zrodloid = @idHistoria and opk_praid = @idPrac
   end
  close DODATKIHIST
  deallocate DODATKIHIST
 end
 if @iAkordy > 0
 begin
  declare AKORDYHIST cursor local fast_forward for
   select distinct AKH_AkhId, PRE_PreId from cdn.AkordyHist
           join cdn.Akordy on AKH_AkrId = AKR_AkrId
           join cdn.PracEtaty on AKR_PraId = PRE_PraId
           where PRE_PraId = @idPrac and PRE_DataDo >= convert(datetime, '2999-12-31', 120)
           and (convert(datetime, @dDataAkt, 120) between AKR_WaznyOd and AKR_WaznyDo)
           and (convert(datetime, @dDataAkt, 120) between AKH_OkresOd and AKH_OkresDo)
 open AKORDYHIST
  while (1=1)
   begin
    fetch next from AKORDYHIST into @idZRODLO, @idHistoria
    if @@fetch_status <> 0
     break
     delete from cdn.OpisKadry where opk_rodzajzrodla = 19 and opk_zrodloid = @idZRODLO
     insert into cdn.OpisKadry
      select 19, @idZRODLO, @idPrac, opk_dzlid, opk_prjid, opk_procent from cdn.opiskadry
       where opk_rodzajzrodla = 16 and opk_zrodloid = @idHistoria and opk_praid = @idPrac
   end
  close AKORDYHIST
  deallocate AKORDYHIST
 end
 if @iUmowy > 0
 begin
  declare UMOWY cursor local fast_forward for
   select distinct UMW_UmwId, PRE_PreId from cdn.Umowy
           join cdn.PracEtaty on UMW_PraId = PRE_PraId
           where PRE_PraId = @idPrac and PRE_DataDo >= convert(datetime, '2999-12-31', 120)
           and (convert(datetime, @dDataAkt, 120) between UMW_DataOd and UMW_DataDo)
  open UMOWY
   while (1=1)
    begin
     fetch next from UMOWY into @idZRODLO, @idHistoria
     if @@fetch_status <> 0
      break
      delete from cdn.OpisKadry where opk_rodzajzrodla = 8 and opk_zrodloid = @idZRODLO
      insert into cdn.OpisKadry
       select 8, @idZRODLO, @idPrac, opk_dzlid, opk_prjid, opk_procent from cdn.opiskadry
        where opk_rodzajzrodla = 16 and opk_zrodloid = @idHistoria and opk_praid = @idPrac
    end
  close UMOWY
  deallocate UMOWY
 end
