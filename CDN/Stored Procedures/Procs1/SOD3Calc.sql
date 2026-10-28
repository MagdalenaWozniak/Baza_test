create PROCEDURE CDN.SOD3Calc @DataOd DATETIME, @DataDo DATETIME, @Typ INT
AS
SET NOCOUNT ON
-- Deklaracja zmiennych pomocniczych
declare @dzien DATETIME
declare @Data0 DATETIME
declare @Data1 DATETIME
declare @V1 DECIMAL (15,7)
declare @V2 DECIMAL (15,7)
declare @Z1 DECIMAL (15,7)
declare @Z2 DECIMAL (15,7)
declare @Z3 DECIMAL (15,7)
declare @X1 DECIMAL (15,7)
--declare Tmp_Data   DATETIME
declare @Tmp_OS_P   INT
declare @Tmp_OS_N   INT
declare @Tmp_OS_L   INT
declare @Tmp_OS_U   INT
declare @Tmp_OS_Z   INT
--declare @Tmp_ET_P   DECIMAL(15,7)
--declare @Tmp_ET_PP  DECIMAL(15,7)
--declare @Tmp_ET_N   DECIMAL(15,7)
--declare @Tmp_ET_L   DECIMAL(15,7)
--declare @Tmp_ET_U   DECIMAL(15,7)
--declare @Tmp_ET_US  DECIMAL(15,7)
--declare @Tmp_ET_Z   DECIMAL(15,7)
--declare @Tmp_ET_ZS  DECIMAL(15,7)
SET @Tmp_OS_P = 0
SET @Tmp_OS_N = 0
SET @Tmp_OS_L = 0
SET @Tmp_OS_U = 0
SET @Tmp_OS_Z = 0
--SET @Tmp_ET_P = 0
--SET @Tmp_ET_PP = 0
--SET @Tmp_ET_N = 0
--SET @Tmp_ET_L = 0
--SET @Tmp_ET_U = 0
--SET @Tmp_ET_US = 0
--SET @Tmp_ET_Z = 0
--SET @Tmp_ET_ZS = 0
 SET @dzien = @DataOd
 SET @Data0 = CONVERT ( DATETIME, '1899-12-30 00:00:00' , 120 )
 SET @Data1 = CONVERT ( DATETIME, '1900-01-01 00:00:00' , 120 )
If @Typ = 1
 WHILE @dzien<=@DataDo
 BEGIN
-- Pracownicy niepelnosprawni - umiarkowy stopien - ze schorzeniami szczegolnymi (etaty)
-- Tmp_ET_US
select @V1 =  cast(isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
and exists (select 1 from cdn.pracschorzenia join cdn.danekadmod on dkm_dkmid = prs_dkmid where prs_praid = pre_praid  and dkm_rodzaj=5 and dkm_robotnicze=1 and (prs_dataod=@Data0 or prs_dataod<=@dzien) and (prs_datado=@Data0 or prs_datado>=@dzien))
-- Pracownicy niepelnosprawni - znaczny stopien - ze schorzeniami szczegolnymi (etaty)
-- Tmp_ET_ZS
select @V2 = cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
and exists (select 1 from cdn.pracschorzenia join cdn.danekadmod on dkm_dkmid = prs_dkmid where prs_praid = pre_praid  and dkm_rodzaj=5 and dkm_robotnicze=1 and (prs_dataod=@Data0 or prs_dataod<=@dzien) and (prs_datado=@Data0 or prs_datado>=@dzien))
-- Pracownicy niepelnosprawni pozostali
-- Pracownicy niepelnosprawni - lekki stopien (etaty)
-- Tmp_ET_L
select @Z1 = isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy niepelnosprawni - umiarkowany stopien (etaty)
-- Tmp_ET_U
select @Z2 = cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))-@V1
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy niepelnosprawni - znaczny stopien (etaty)
-- Tmp_ET_Z
select @Z3 =  cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))-@V2
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy pelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_PP
select @X1 = cast (isnull(Sum(CAST (case when PRE_PRMPracaRodzic=0 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and
not exists (select 1 from CDN.PracNieobec left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and (tnb_pdzid in (112, 121, 122, 321, 322, 350) or TNB_Standardowy=218) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy pelnosprawni (osoby)
-- Tmp_OS_P
SET @Tmp_OS_P = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123))
                   or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and (TNB_PdzId in (112, 121, 122, 321, 322, 350) or TNB_Standardowy=218) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni (osoby)
-- Tmp_OS_N
SET @Tmp_OS_N = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where ((PRE_StNiepelnosp=1 or PRE_StNiepelnosp=2 or PRE_StNiepelnosp=3) and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien)
                    and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - lekki stopien (osoby)
-- Tmp_OS_L
SET @Tmp_OS_L = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - umiarkowany stopien (osoby)
-- Tmp_OS_U
SET @Tmp_OS_U = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - znaczny stopien (osoby)
-- Tmp_OS_Z
SET @Tmp_OS_Z = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
   INSERT INTO #SOD
    select
 @dzien,
 @Tmp_OS_P,
 @Tmp_OS_N,
 @Tmp_OS_L,
 @Tmp_OS_U,
 @Tmp_OS_Z,
-- Pracownicy ogolem (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_P
 @X1+@Z1+@Z2+@V1+@Z3+@V2,
-- Pracownicy pelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_PP
 @X1,
-- Pracownicy niepelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_N
 @Z1+@Z2+@V1+@Z3+@V2,
-- Tmp_ET_L
 isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_etaetatl
                when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_prmetatl
                else 0 end as decimal)/
                cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_etaetatm
                when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_prmetatm
                else 1 end as decimal)),0),
-- Tmp_ET_U
 cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))-@V1,
-- Tmp_ET_US
 @V1,
-- Tmp_ET_Z
 cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))-@V2,
-- Tmp_ET_ZS
 @V2
from CDN.PracEtaty
join PracKod on PRA_PraId = PRE_PraId
where PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and @dzien >= CONVERT(DATETIME, '2011-01-01', 120) and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
SET @dzien = @dzien + 1
END
If @Typ = 2
 WHILE @dzien<=@DataDo
 BEGIN
-- Pracownicy niepelnosprawni - umiarkowy stopien - ze schorzeniami szczegolnymi (etaty)
-- Tmp_ET_US
select @V1 =  cast(isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
and exists (select 1 from cdn.pracschorzenia join cdn.danekadmod on dkm_dkmid = prs_dkmid where prs_praid = pre_praid  and dkm_rodzaj=5 and dkm_robotnicze=1 and (prs_dataod=@Data0 or prs_dataod<=@dzien) and (prs_datado=@Data0 or prs_datado>=@dzien))
-- Pracownicy niepelnosprawni - znaczny stopien - ze schorzeniami szczegolnymi (etaty)
-- Tmp_ET_ZS
select @V2 = cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
and exists (select 1 from cdn.pracschorzenia join cdn.danekadmod on dkm_dkmid = prs_dkmid where prs_praid = pre_praid  and dkm_rodzaj=5 and dkm_robotnicze=1 and (prs_dataod=@Data0 or prs_dataod<=@dzien) and (prs_datado=@Data0 or prs_datado>=@dzien))
-- Pracownicy niepelnosprawni pozostali
-- Pracownicy niepelnosprawni - lekki stopien (etaty)
-- Tmp_ET_L
select @Z1 = isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy niepelnosprawni - umiarkowany stopien (etaty)
-- Tmp_ET_U
select @Z2 = cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))-@V1
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy niepelnosprawni - znaczny stopien (etaty)
-- Tmp_ET_Z
select @Z3 =  cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))-@V2
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy pelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_PP
select @X1 = cast (isnull(Sum(CAST (case when PRE_PRMPracaRodzic=0 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and (tnb_pdzid in (112, 121, 122, 321, 322, 350) or TNB_Standardowy = 218) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy pelnosprawni (osoby)
-- Tmp_OS_P
SET @Tmp_OS_P = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123))
                   or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and (TNB_PdzId in (112, 121, 122, 321, 322, 350) or TNB_Standardowy=218) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni (osoby)
-- Tmp_OS_N
SET @Tmp_OS_N = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where ((PRE_StNiepelnosp=1 or PRE_StNiepelnosp=2 or PRE_StNiepelnosp=3) and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien)
                    and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - lekki stopien (osoby)
-- Tmp_OS_L
SET @Tmp_OS_L = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - umiarkowany stopien (osoby)
-- Tmp_OS_U
SET @Tmp_OS_U = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - znaczny stopien (osoby)
-- Tmp_OS_Z
SET @Tmp_OS_Z = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
   INSERT INTO #SOD
    select
 @dzien,
 @Tmp_OS_P,
 @Tmp_OS_N,
 @Tmp_OS_L,
 @Tmp_OS_U,
 @Tmp_OS_Z,
-- Pracownicy ogolem (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_P
 @X1+@Z1+@Z2+@V1+@Z3+@V2,
-- Pracownicy pelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_PP
 @X1,
-- Pracownicy niepelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_N
 @Z1+@Z2+@V1+@Z3+@V2,
-- Tmp_ET_L
 isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_etaetatl
                when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_prmetatl
                else 0 end as decimal)/
                cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_etaetatm
                when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_prmetatm
                else 1 end as decimal)),0),
-- Tmp_ET_U
 cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))-@V1,
-- Tmp_ET_US
 @V1,
-- Tmp_ET_Z
 cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))-@V2,
-- Tmp_ET_ZS
 @V2
from CDN.PracEtaty
join PracKod on PRA_PraId = PRE_PraId
where PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (111, 112) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )
or PRE_StNiepelnosp = 0 and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
SET @dzien = @dzien + 1
END
If @Typ = 3
 WHILE @dzien<=@DataDo
 BEGIN
-- Pracownicy niepelnosprawni - umiarkowy stopien - ze schorzeniami szczegolnymi (etaty)
-- Tmp_ET_US
select @V1 =   cast(isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
and exists (select 1 from cdn.pracschorzenia join cdn.danekadmod on dkm_dkmid = prs_dkmid where prs_praid = pre_praid  and dkm_rodzaj=5 and dkm_robotnicze=1 and (prs_dataod=@Data0 or prs_dataod<=@dzien) and (prs_datado=@Data0 or prs_datado>=@dzien))
-- Pracownicy niepelnosprawni - znaczny stopien - ze schorzeniami szczegolnymi (etaty)
-- Tmp_ET_ZS
select @V2 = cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
and exists (select 1 from cdn.pracschorzenia join cdn.danekadmod on dkm_dkmid = prs_dkmid where prs_praid = pre_praid  and dkm_rodzaj=5 and dkm_robotnicze=1 and (prs_dataod=@Data0 or prs_dataod<=@dzien) and (prs_datado=@Data0 or prs_datado>=@dzien))
-- Pracownicy niepelnosprawni pozostali
-- Pracownicy niepelnosprawni - lekki stopien (etaty)
-- Tmp_ET_L
select @Z1 = isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy niepelnosprawni - umiarkowany stopien (etaty)
-- Tmp_ET_U
select @Z2 = cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))-@V1
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy niepelnosprawni - znaczny stopien (etaty)
-- Tmp_ET_Z
select @Z3 =  cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0)  as decimal(15,7))-@V2
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and tnb_pdzid in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy pelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_PP
select @X1 = cast (isnull(Sum(CAST (case when PRE_PRMPracaRodzic=0 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and (((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123)) and PRE_StNiepelnosp=0
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))
from cdn.pracetaty
where  pre_dataod<=@dzien and (pre_datado is null or pre_datado >=@dzien )
and pre_zatrudnionyod<=@dzien and (pre_zatrudnionyDo is null or pre_zatrudnionydo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
where (PNB_PraID = PRE_PRaID) and (tnb_pdzid in (112, 121, 122, 321, 322, 350) or TNB_Standardowy = 218) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
-- Pracownicy pelnosprawni (osoby)
-- Tmp_OS_P
SET @Tmp_OS_P = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                   and pre_ubztyuid not in (120, 121, 122, 123))
                   or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and (TNB_PdzId in (112, 121, 122, 321, 322, 350) or TNB_Standardowy = 218) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni (osoby)
-- Tmp_OS_N
SET @Tmp_OS_N = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where ((PRE_StNiepelnosp=1 or PRE_StNiepelnosp=2 or PRE_StNiepelnosp=3) and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien)
                    and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - lekki stopien (osoby)
-- Tmp_OS_L
SET @Tmp_OS_L = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - umiarkowany stopien (osoby)
-- Tmp_OS_U
SET @Tmp_OS_U = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
-- Pracownicy niepelnosprawni - znaczny stopien (osoby)
-- Tmp_OS_Z
SET @Tmp_OS_Z = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end) from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where (PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien )
                    and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                    and pre_ubztyuid not in (120, 121, 122, 123))
                    or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0)))
and PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 )))
   INSERT INTO #SOD
    select
 @dzien,
 @Tmp_OS_P,
 @Tmp_OS_N,
 @Tmp_OS_L,
 @Tmp_OS_U,
 @Tmp_OS_Z,
-- Pracownicy ogolem (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_P
 @X1+@Z1+@Z2+@V1+@Z3+@V2,
-- Pracownicy pelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_PP
 @X1,
-- Pracownicy niepelnosprawni (etaty) --w przeliczeniu na pelny wymiar etatu
-- Tmp_ET_N
 @Z1+@Z2+@V1+@Z3+@V2,
-- Tmp_ET_L
 isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_etaetatl
                when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_prmetatl
                else 0 end as decimal)/
                cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_etaetatm
                when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=1 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
                and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
                and pre_ubztyuid not in (120, 121, 122, 123))
                or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
                then pre_prmetatm
                else 1 end as decimal)),0),
-- Tmp_ET_U
 cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=2 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))-@V1,
-- Tmp_ET_US
 @V1,
-- Tmp_ET_Z
 cast (isnull(sum(CAST (case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatl
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatl
               else 0 end as decimal)/
               cast(case when PRE_PRMPracaRodzic=0 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_etaetatm
               when PRE_PRMPracaRodzic=1 and PRE_StNiepelnosp=3 and (PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<= @dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien)
               and ((((pre_ubztyuid>=110 and pre_ubztyuid<=200) or pre_ubztyuid = 20000 )
               and pre_ubztyuid not in (120, 121, 122, 123))
               or  ((pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 or pre_ubztyuid=123)and PRE_StNiepelnosp <> 0))
               then pre_prmetatm
               else 1 end as decimal)),0) as decimal(15,7))-@V2,
-- Tmp_ET_ZS
 @V2
from CDN.PracEtaty
join PracKod on PRA_PraId = PRE_PraId
where PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien )
and PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--and ((@dzien between PRE_NiepelnospOd and PRE_NiepelnospDo) and (PRE_StNiepelnosp<>0)
and ((PRE_NiepelnospOd is null or PRE_NiepelnospOd  IN (@Data0, @Data1) or PRE_NiepelnospOd<=@dzien) and (PRE_NiepelnospDo is null or PRE_NiepelnospDo IN (@Data0, @Data1) or PRE_NiepelnospDo>=@dzien) and (PRE_StNiepelnosp<>0)
or not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in (112, 121, 122, 321, 322, 350) and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1 and PNB_PracaRodzic <> 1 ))
SET @dzien = @dzien + 1
END
