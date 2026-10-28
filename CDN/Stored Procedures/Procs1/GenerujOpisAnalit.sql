CREATE  PROCEDURE CDN.GenerujOpisAnalit
AS
SET NOCOUNT ON
declare @idZRODLO int, @idPRC int, @idDZL int
declare PRACETATY cursor local fast_forward for
  select PRE_PreId, PRE_PraId, PRE_DzlId from cdn.PracEtaty
open PRACETATY
while (1=1)
 begin
  fetch next from PRACETATY into @idZRODLO, @idPRC, @idDZL
  if @@fetch_status <> 0
   break
  if ((select count(OPK_OpkId) from cdn.OpisKadry
    where OPK_RodzajZrodla = 16
     and OPK_ZrodloId = @idZRODLO) = 0)
  begin
   insert into cdn.OpisKadry
    (OPK_RodzajZrodla, OPK_ZrodloId, OPK_PraId, OPK_DzlId, OPK_PrjId, OPK_Procent)
    values
    (16, @idZRODLO, @idPRC, @idDZL, 1, 100)
  end
 end
close PRACETATY
deallocate PRACETATY
declare DODATKIHIST cursor local fast_forward for
  select distinct DOH_DohId, DOD_PraId, PRE_DzlId from cdn.DodatkiHist
           join cdn.Dodatki on DOH_DodId = DOD_DodId
           join cdn.PracEtaty on DOD_PraId = PRE_PraId
           where PRE_DataDo >= convert(datetime, '2999-12-31', 120)
open DODATKIHIST
while (1=1)
 begin
  fetch next from DODATKIHIST into @idZRODLO, @idPRC, @idDZL
  if @@fetch_status <> 0
   break
  if ((select count(OPK_OpkId) from cdn.OpisKadry
    where OPK_RodzajZrodla = 17
     and OPK_ZrodloId = @idZRODLO) = 0)
  begin
   insert into cdn.OpisKadry
    (OPK_RodzajZrodla, OPK_ZrodloId, OPK_PraId, OPK_DzlId, OPK_PrjId, OPK_Procent)
    values
    (17, @idZRODLO, @idPRC, @idDZL, 1, 100)
  end
 end
close DODATKIHIST
deallocate DODATKIHIST
declare UMOWY cursor local fast_forward for
  select distinct UMW_UmwId, PRE_PraId, PRE_DzlId from cdn.Umowy
           join cdn.PracEtaty on UMW_PraId = PRE_PraId
           where PRE_DataDo >= convert(datetime, '2999-12-31', 120)
open UMOWY
while (1=1)
 begin
  fetch next from UMOWY into @idZRODLO, @idPRC, @idDZL
  if @@fetch_status <> 0
   break
  if ((select count(OPK_OpkId) from cdn.OpisKadry
    where OPK_RodzajZrodla = 8
     and OPK_ZrodloId = @idZRODLO) = 0)
  begin
   insert into cdn.OpisKadry
    (OPK_RodzajZrodla, OPK_ZrodloId, OPK_PraId, OPK_DzlId, OPK_PrjId, OPK_Procent)
    values
    (8, @idZRODLO, @idPRC, @idDZL, 1, 100)
  end
 end
close UMOWY
deallocate UMOWY
declare AKORDYHIST cursor local fast_forward for
  select distinct AKH_AkhId, AKR_PraId, PRE_DzlId from cdn.AkordyHist
           join cdn.Akordy on AKH_AkrId = AKR_AkrId
           join cdn.PracEtaty on AKR_PraId = PRE_PraId
           where PRE_DataDo >= convert(datetime, '2999-12-31', 120)
open AKORDYHIST
while (1=1)
 begin
  fetch next from AKORDYHIST into @idZRODLO, @idPRC, @idDZL
  if @@fetch_status <> 0
   break
  if ((select count(OPK_OpkId) from cdn.OpisKadry
    where OPK_RodzajZrodla = 19
     and OPK_ZrodloId = @idZRODLO) = 0)
  begin
   insert into cdn.OpisKadry
    (OPK_RodzajZrodla, OPK_ZrodloId, OPK_PraId, OPK_DzlId, OPK_PrjId, OPK_Procent)
    values
    (19, @idZRODLO, @idPRC, @idDZL, 1, 100)
  end
 end
close AKORDYHIST
deallocate AKORDYHIST
SET NOCOUNT OFF
