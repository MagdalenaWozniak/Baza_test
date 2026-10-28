CREATE PROCEDURE CDN.StruktZatrCalc @DataOd DATETIME, @DataDo DATETIME
AS
SET NOCOUNT ON
-- Deklaracja zmiennych pomocniczych
declare @dzien DATETIME
--
-- Dodaję najpierw wszystkich z etetu
 SET @dzien = @DataOd
 WHILE @dzien<=@DataDo
 BEGIN
--DECLARE @TmpData DATETIME
DECLARE @Tmp_OS_P INT
DECLARE @Tmp_OS_W INT
DECLARE @Tmp_OS_U1 INT
DECLARE @Tmp_OS_U2 INT
DECLARE @Tmp_OS_U3 INT
DECLARE @Tmp_OS_PL_K INT
DECLARE @Tmp_OS_PL_M INT
DECLARE @Tmp_ET_P DECIMAL(15,2)
DECLARE @Tmp_ET_W DECIMAL(15,2)
DECLARE @Tmp_ET_U DECIMAL(15,2)
--SET @TmpData = 0
SET @Tmp_OS_P = 0
SET @Tmp_OS_W = 0
SET @Tmp_OS_U1 = 0
SET @Tmp_OS_U2 = 0
SET @Tmp_OS_U3 = 0
SET @Tmp_OS_PL_K = 0
SET @Tmp_OS_PL_M = 0
SET @Tmp_ET_P = 0
SET @Tmp_ET_W = 0
SET @Tmp_ET_U = 0
SET @Tmp_OS_P = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where ((pre_ubztyuid>=110 and pre_ubztyuid<=200 and
      (pre_ubztyuid<>120 and pre_ubztyuid<>121 and pre_ubztyuid<>122 and pre_ubztyuid<>123)) or pre_ubztyuid=80000)
  and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien)
  and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--
SET @Tmp_OS_W = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (pre_ubztyuid>=510 and pre_ubztyuid<=600)
  and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien)
  and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--
SET @Tmp_OS_U1 = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_ETARODZAJZATRUDNIENIA in (4,7))
  and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien)
  and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--
SET @Tmp_OS_U2 = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_ETARODZAJZATRUDNIENIA = 5)
  and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien)
  and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--
SET @Tmp_OS_U3 = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_ETARODZAJZATRUDNIENIA = 6)
  and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien)
  and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--
SET @Tmp_OS_PL_K = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (pre_plec='K' and ((pre_ubztyuid>=110 and pre_ubztyuid<=200 ) or (pre_ubztyuid>=510 and pre_ubztyuid<=600)))
  and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien)
  and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--
SET @Tmp_OS_PL_M = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (pre_plec='M' and ((pre_ubztyuid>=110 and pre_ubztyuid<=200 ) or (pre_ubztyuid>=510 and pre_ubztyuid<=600)))
  and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien)
  and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--Etaty--
SET @Tmp_ET_P = (select SUM(CAST (case when ((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid=80000)
  and (PRE_ETARODZAJZATRUDNIENIA not in (4,5,6,7) )
               then pre_etaetatl else 0 end as decimal)/
      cast(case when ((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid=80000)
  and (PRE_ETARODZAJZATRUDNIENIA not in (4,5,6,7) )
               then pre_etaetatm else 1 end as decimal))
from cdn.pracetaty
join cdn.prackod on pra_praid=pre_praid
where
     PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien) and
     PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--
SET @Tmp_ET_W = (select SUM(CAST (case when pre_ubztyuid>=510 and pre_ubztyuid<=600
               then 1 else 0 end as decimal)/
      cast(case when pre_ubztyuid>=510 and pre_ubztyuid<=600
               then 1 else 1 end as decimal))
from cdn.pracetaty
join cdn.prackod on pra_praid=pre_praid
where
     PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien) and
     PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
--
SET @Tmp_ET_U = (select SUM(CAST (case when PRE_ETARODZAJZATRUDNIENIA in (4,5,6,7)
               then pre_etaetatl else 0 end as decimal)/
      cast(case when PRE_ETARODZAJZATRUDNIENIA in (4,5,6,7)
               then pre_etaetatm else 1 end as decimal))
from cdn.pracetaty
join cdn.prackod on pra_praid=pre_praid
where
     PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien) and
     PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien))
INSERT INTO #StrukturaZatr
select
@dzien,
@Tmp_OS_P,
@Tmp_OS_W,
@Tmp_OS_U1,
@Tmp_OS_U2,
@Tmp_OS_U3,
@Tmp_OS_PL_K,
@Tmp_OS_PL_M,
@Tmp_ET_P,
@Tmp_ET_W,
@Tmp_ET_U
SET @dzien = @dzien + 1
END
