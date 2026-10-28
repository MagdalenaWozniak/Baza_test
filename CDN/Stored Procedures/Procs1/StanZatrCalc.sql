CREATE PROCEDURE CDN.StanZatrCalc @Data DATETIME
AS
SET NOCOUNT ON
-- Deklaracja zmiennych pomocniczych
declare @dzien DATETIME
--
-- Dodaję najpierw wszystkich z etetu
 SET @dzien = @Data
   INSERT INTO #StanZatr
    select
      @dzien,
--OS_OG
     sum(case when  ((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000) and
              PRE_ETARodzajZatrudnienia <> 4 and PRE_ETARodzajZatrudnienia <> 5 and
 PRE_ETARodzajZatrudnienia <> 6 and PRE_ETARodzajZatrudnienia <> 7
               then 1 else 0 end),
--OS_K
      sum(case when pre_plec='K' and ((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000) and
              PRE_ETARodzajZatrudnienia <> 4 and PRE_ETARodzajZatrudnienia <> 5 and
 PRE_ETARodzajZatrudnienia <> 6 and PRE_ETARodzajZatrudnienia <> 7
               then 1 else 0 end),
--P_OG
      sum(case when  ((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000) and
              PRE_ETARodzajZatrudnienia <> 4 and PRE_ETARodzajZatrudnienia <> 5 and
 PRE_ETARodzajZatrudnienia <> 6 and PRE_ETARodzajZatrudnienia <> 7 and (PRE_ETAEtatL/PRE_ETAEtatM = 1)
               then 1 else 0 end),
--P_K
      sum(case when  pre_plec='K' and ((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000) and
              PRE_ETARodzajZatrudnienia <> 4 and PRE_ETARodzajZatrudnienia <> 5 and
 PRE_ETARodzajZatrudnienia <> 6 and PRE_ETARodzajZatrudnienia <> 7 and (PRE_ETAEtatL/PRE_ETAEtatM = 1)
               then 1 else 0 end),
--N_OG
      sum(case when  ((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000) and
              PRE_ETARodzajZatrudnienia <> 4 and PRE_ETARodzajZatrudnienia <> 5 and
 PRE_ETARodzajZatrudnienia <> 6 and PRE_ETARodzajZatrudnienia <> 7 and (PRE_ETAEtatL/PRE_ETAEtatM <> 1)
               then 1 else 0 end),
--N_K
      sum(case when  pre_plec='K' and  ((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000) and
              PRE_ETARodzajZatrudnienia <> 4 and PRE_ETARodzajZatrudnienia <> 5 and
 PRE_ETARodzajZatrudnienia <> 6 and PRE_ETARodzajZatrudnienia <> 7 and (PRE_ETAEtatL/PRE_ETAEtatM <> 1)
               then 1 else 0 end),
--W_OG
      sum(case when pre_ubztyuid>=510 and pre_ubztyuid<=600 then 1 else 0 end),
--W_K
      sum(case when pre_plec='K' and pre_ubztyuid>=510 and pre_ubztyuid<=600 then 1 else 0 end)
 from cdn.pracetaty
 where pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien ) and
        pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112, 121, 122)
and @dzien between PNB_OkresOd and PNB_OkresDo
and (PNB_OkresDo - PNB_OkresOd +1) > 90 )
