CREATE  PROCEDURE CDN.DG1 @DataOd DATETIME, @DataDo DATETIME
AS
BEGIN
SET NOCOUNT ON
IF @DataOd IS NULL OR @DataDo IS NULL
BEGIN
  SET @DataOd = '1899-12-30 00:00:00'
  SET @DataDo = '1899-12-30 00:00:00'
END
ELSE
BEGIN
  SET @DataOd = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataOd) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataOd) AS NVARCHAR)+' 00:00:000', 120)
  SET @DataDo = CONVERT(DATETIME, CAST(DATEPART(year ,@DataDo) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDo) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataDo) AS NVARCHAR)+' 00:00:000', 120)
END
DECLARE @P1 DECIMAL(15,2)
DECLARE @P2 DECIMAL(15,2)
DECLARE @P3 DECIMAL(15,2)
DECLARE @P4 DECIMAL(15,2)
DECLARE @P5 DECIMAL(15,2)
DECLARE @P6 DECIMAL(15,2)
DECLARE @P7 DECIMAL(15,2)
DECLARE @P8 DECIMAL(15,2)
DECLARE @P9 DECIMAL(15,2)
DECLARE @P10 DECIMAL(15,2)
DECLARE @DataOst DATETIME  -- ostatni dzieÄąâ€ž miesiĂ„â€¦ca z parametru
DECLARE @DataOd1 DATETIME  -- pierwszy dzieÄąâ€ž roku z parametru
SET @DataOd1 = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-01-01'+' 00:00:000', 120)
SET @DataOst = @DataDo
SET @P1 = 0
SET @P2 = 0
SET @P3 = 0
SET @P4 = 0
SET @P5 = 0
SET @P6 = 0
SET @P7 = 0
SET @P8 = 0
SET @P9 = 0
SET @P10 = 0
--
BEGIN
DECLARE @ZatrPrac INT
DECLARE @WlascWsp INT
SET @ZatrPrac = 0
SET @WlascWsp = 0
-- pracownicy
SET @ZatrPrac =
(select count(T.ID) from (select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
(isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111,112, 121, 122)
--[JK] TFS:216787
--or (TNB_PdzId in (321,322) and a.PNB_Przyczyna<>5)
or TNB_Standardowy=312)
   and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataDo and max(grp) >= @DataDo) -- aby zmieniĂ„â€ˇ na nieobecnoÄąâ€şci w okresie miesiĂ„â€¦ca a nie na jego koniec naleÄąÄ˝y zminiĂ„â€ˇ warunek z @DataOst ba @dataOd
,0) <91
and
--[JK] TFS:216787
not exists
       (select * from CDN.PracNieobec as d inner join CDN.TypNieobec on TNB_TnbId = d.PNB_TnbId where d.PNB_PraId = PRE_PraId and
    TNB_PdzId in (321,322) and @DataDo between PNB_OkresOd and PNB_OkresDo
))
and
(
(PRE_UbzTyuID<>120 and (pre_ubztyuid>=110 and pre_ubztyuid<=200) and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
or PRE_UbzTyuID=20000 or PRE_UbzTyuID = 800
or (pre_ubztyuid>=310 and pre_ubztyuid<=320)
or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140
)
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ) T)
-- wÄąâ€šaÄąâ€şciciele i osoby wspÄ‚Ĺ‚Äąâ€špracujĂ„â€¦ce
SET @WlascWsp = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end)from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where  Left(PRE_UbzTyuID,1)=5 and Len(PRE_UbzTyuID)=3 and PRE_HDKGUSGlowneMiejscePracy=1 and
@DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo)
--
--
END
-- wyliczenie przeciĂ„â„˘tnej liczby zatrudnionych
DECLARE @dzien DATETIME
DECLARE @Tmp_ET DECIMAL(15,2)
DECLARE @Tmp_ET_P DECIMAL(15,2)
DECLARE @Tmp_DniMC INTEGER
SET @Tmp_ET = 0
SET @Tmp_DniMC = 0
SET @dzien = @DataOd
WHILE @dzien<=@DataDo
BEGIN
--[JK] TFS:152918 usuniĂ„â„˘to "=" z warunku pre_ubztyuid<=200
--[JK] TFS:195767 - dodanie warunku na pobieranie PRE_ETAEtatL i PRE_ETAEtatM (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end) i (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end)
SET @Tmp_ET_P = (select IsNull(SUM(CAST (case when ((pre_ubztyuid>=110 and pre_ubztyuid<200) or (pre_ubztyuid>=510 and pre_ubztyuid<=600) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800)
--[JK] TFS:152289
and (Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_ETARODZAJZATRUDNIENIA not in (4,5,6,7) )
               then (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end) else 0 end as decimal)/
--[JK] TFS:152918 usuniĂ„â„˘to "=" z warunku pre_ubztyuid<=200
      cast(case when ((pre_ubztyuid>=110 and pre_ubztyuid<200) or (pre_ubztyuid>=510 and pre_ubztyuid<=600) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800)
--[JK] TFS:152289
and (Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_ETARODZAJZATRUDNIENIA not in (4,5,6,7) )
               then (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) else 1 end as decimal)),0)
from cdn.pracetaty
join cdn.prackod on pra_praid=pre_praid
where
     PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien) and
     PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--[JK] TFS:152916
     and PRE_Oddelegowany =0
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in
--[JK] TFS:152271
(111,112,121,122,311,312,319,325,327)
and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1
--[JK] TFS:195767
and PNB_PracaRodzic <> 1
)
--[JK] TFS:152271 wykluczony zasiÄąâ€šek chorobowy
and not exists(select 1 from cdn.WypSkladniki
LEFT OUTER JOIN CDN.TypWYplata on WPS_TwpId = TWP_TWPId
--[JK] TFS:152904 dodano kod 314 do warunku na TWP_PdzId
LEFT OUTER JOIN CDN.Wyplaty on WPS_WplId = WPL_WplId where WPL_Tryb<>1 and WPL_Tryb<>2 and WPS_PraId = PRE_PraId and TWP_PdzId in (313,314)
and @dzien between WPS_DataOd and WPS_DataDo
)
)
SET @dzien = @dzien+1
SET @Tmp_DniMC = @Tmp_DniMC + 1
set @Tmp_ET = @Tmp_ET + @Tmp_ET_P
END
DECLARE @Petla  INT
DECLARE @n  INT
DECLARE @Dni  INT
DECLARE @Data1  DATETIME
DECLARE @Data2  DATETIME
DECLARE @Tmp_ET_MC DECIMAL(15,2)
DECLARE @Tmp_ET_P_MC DECIMAL(15,2)
DECLARE @Tmp_ET_OKR DECIMAL(15,2)
--
SET @Petla = 0
SET @n = month(@DataDo)
SET @Dni = 1
SET @Data1 = @DataOd1
SET @Data2 = DATEADD(m, 1, @Data1)-1
SET @Tmp_ET_OKR = 0
--
-- POCZATEK PĂ„ÂTLI x n
WHILE @Petla < @n
BEGIN
SET @Petla = @Petla + 1
SET @Dni = DATEDIFF(d, @data1, @Data2)+1
SET @Tmp_ET_MC = 0
SET @dzien = @Data1
WHILE @dzien<=@Data2
BEGIN
--[JK] TFS:152918 usuniĂ„â„˘to "=" z warunku pre_ubztyuid<=200
--[JK] TFS:195767 - dodanie warunku na pobieranie PRE_ETAEtatL i PRE_ETAEtatM (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end) i (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end)
SET @Tmp_ET_P_MC = (select IsNull(SUM(CAST (case when ((pre_ubztyuid>=110 and pre_ubztyuid<200) or (pre_ubztyuid>=510 and pre_ubztyuid<=600) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800)
--[JK] TFS:152289
and (Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
  and (PRE_ETARODZAJZATRUDNIENIA not in (4,5,6,7) )
               then (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end) else 0 end as decimal)/
--[JK] TFS:152918 usuniĂ„â„˘to "=" z warunku pre_ubztyuid<=200
      cast(case when ((pre_ubztyuid>=110 and pre_ubztyuid<200) or (pre_ubztyuid>=510 and pre_ubztyuid<=600) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800)
--[JK] TFS:152289
and (Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
  and (PRE_ETARODZAJZATRUDNIENIA not in (4,5,6,7) )
               then (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) else 1 end as decimal)),0)
from cdn.pracetaty
join cdn.prackod on pra_praid=pre_praid
where
     PRE_DataOd<=@dzien and (PRE_DataDo is null or PRE_DataDo>=@dzien) and
     PRE_ZatrudnionyOd<=@dzien and (PRE_ZatrudnionyDo is null or PRE_ZatrudnionyDo>=@dzien)
--[JK] TFS:152916
     and PRE_Oddelegowany =0
and not exists (select 1 from CDN.PracNieobec
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
where (PNB_PraId = PRE_PraId) and TNB_PdzId in
--[JK] TFS:152271
(111,112,121,122,311,312,319,325,327)
and @dzien between PNB_OkresOd and PNB_OkresDo and PNB_Tryb <> 1
--[JK] TFS:195767
and PNB_PracaRodzic <> 1
)
--[JK] TFS:152271 wykluczony zasiÄąâ€šek chorobowy
and not exists(select 1 from cdn.WypSkladniki
LEFT OUTER JOIN CDN.TypWYplata on WPS_TwpId = TWP_TWPId
--[JK] TFS:152904 dodano kod 314 do warunku na TWP_PdzId
LEFT OUTER JOIN CDN.Wyplaty on WPS_WplId = WPL_WplId where WPL_Tryb<>1 and WPL_Tryb<>2 and WPS_PraId = PRE_PraId and TWP_PdzId in (313,314)
and @dzien between WPS_DataOd and WPS_DataDo
)
)
SET @dzien = @dzien+1
set @Tmp_ET_MC = @Tmp_ET_MC + @Tmp_ET_P_MC
END
-- Wyliczenie przeciĂ„â„˘tnej liczby zatr. od poczĂ„â€¦tku roku [DG-1 07.2]
SET @Data1 = @Data2+1
SET @Data2 = DATEADD(m, 1, @Data1)-1
SET @Tmp_ET_OKR = @Tmp_ET_OKR + @Tmp_ET_MC/@Dni
END
--Wynagrodzenia miesiĂ„â€¦c,
DECLARE @WynagrMc DECIMAL(15,2)
DECLARE @SklMc DECIMAL(15,2)
SET @WynagrMc = 0
SET @SklMc = 0
BEGIN
SELECT @WynagrMc = IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
join CDN.pracEtaty on wpl_praid = pre_praid
WHERE
LPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus<>0 and
LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (Left(WPE_TyUb,2)=11 OR LEFT(WPE_TyUb, 3) = 800 or (LEFT(WPE_TyUb, 3)  = 300 and ((pre_ubztyuid>=110 and pre_ubztyuid<=200 and PRE_UbzTyuID<>120) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800))or (LEFT(WPE_TyUb, 3)>=310 and LEFT(WPE_TyUb, 3)<=320) and LEFT(WPE_TyUb, 4)<>1135 and LEFT(WPE_TyUb, 4)<>1150 and LEFT(WPE_TyUb, 4)<>1153 )
and LPL_DataDo Between @DataOd and @DataDo
and (TWP_Standardowy < 15 or TWP_Standardowy > 18) and TWP_Standardowy <> 20 and TWP_Standardowy <> 21 and TWP_Standardowy <> 22 and TWP_Standardowy <> 23
--[JK] TFS:152973
and LPL_Oddelegowani =0
SELECT @SklMc = IsNull(sum(WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
join CDN.pracEtaty on wpl_praid = pre_praid
WHERE
LPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus<>0 and
LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (Left(WPE_TyUb,2)=11 OR LEFT(WPE_TyUb, 3) = 800 or (LEFT(WPE_TyUb, 3)  = 300 and ((pre_ubztyuid>=110 and pre_ubztyuid<=200 and PRE_UbzTyuID<>120) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800))or (LEFT(WPE_TyUb, 3)>=310 and LEFT(WPE_TyUb, 3)<=320) and LEFT(WPE_TyUb, 4)<>1135 and LEFT(WPE_TyUb, 4)<>1150 and LEFT(WPE_TyUb, 4)<>1153 )
and LPL_DataDo Between @DataOd and @DataDo
--[JK] TFS:152973
and LPL_Oddelegowani =0
END
--Wynagrodzenia ogolem
DECLARE @Wynagr DECIMAL(15,2)
DECLARE @Skl DECIMAL(15,2)
SET @Wynagr = 0
SET @Skl = 0
BEGIN
SELECT @Wynagr = IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
join CDN.pracEtaty on wpl_praid = pre_praid
WHERE
LPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus<>0 and
LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (Left(WPE_TyUb,2)=11 OR LEFT(WPE_TyUb, 3) = 800 or (LEFT(WPE_TyUb, 3)  = 300 and ((pre_ubztyuid>=110 and pre_ubztyuid<=200 and PRE_UbzTyuID<>120) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800)) or (LEFT(WPE_TyUb, 3)>=310 and LEFT(WPE_TyUb, 3)<=320) and LEFT(WPE_TyUb, 4)<>1135 and LEFT(WPE_TyUb, 4)<>1150 and LEFT(WPE_TyUb, 4)<>1153 )
and LPL_DataDo Between @DataOd1 and @DataDo
and (TWP_Standardowy < 15 or TWP_Standardowy > 18) and TWP_Standardowy <> 20  and TWP_Standardowy <> 21 and TWP_Standardowy <> 22 and TWP_Standardowy <> 23
--[JK] TFS:152973
and LPL_Oddelegowani =0
SELECT @Skl = IsNull(sum(WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
join CDN.pracEtaty on wpl_praid = pre_praid
WHERE
LPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus<>0 and
LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (Left(WPE_TyUb,2)=11 OR LEFT(WPE_TyUb, 3) = 800 or (LEFT(WPE_TyUb, 3)  = 300 and ((pre_ubztyuid>=110 and pre_ubztyuid<=200 and PRE_UbzTyuID<>120) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800)) or (LEFT(WPE_TyUb, 3)>=310 and LEFT(WPE_TyUb, 3)<=320) and LEFT(WPE_TyUb, 4)<>1135 and LEFT(WPE_TyUb, 4)<>1150 and LEFT(WPE_TyUb, 4)<>1153 )
and LPL_DataDo Between @DataOd1 and @DataDo
--[JK] TFS:152973
and LPL_Oddelegowani =0
END
DECLARE @CzasPracyOg  INT
DECLARE @Data0 DATETIME
DECLARE @PrcId INT
SET @Data0    = CONVERT(DATETIME, '1899-12-30 00:00:00' , 120)
SET @CzasPracyOg =  0
BEGIN
   DECLARE Tmp_Czas CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT distinct PRE_PraId
   FROM CDN.PracEtaty
   WHERE (@DataOd1 between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
  or @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
  or  PRE_ZatrudnionyOd between @DataOd1 and @DataDo)
  OPEN Tmp_Czas
  WHILE 1=1
BEGIN
FETCH NEXT FROM Tmp_Czas INTO @PrcId
IF @@FETCH_STATUS <> 0 BREAK
-- kalendarz
   select  @CzasPracyOg = @CzasPracyOg + IsNull(sum(praca), 0)
   from  CDN.PracCzasPracyFN (3,@PrcId, @DataOd1, @DataDo)
   inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
   and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
--[JK] TFS:152964
   and PRE_Oddelegowany =0
   and
--[JK] TFS:152964 usuniĂ„â„˘to "=" z warunku pre_ubztyuid<=200
((pre_ubztyuid>=110 and pre_ubztyuid<200 and PRE_UbzTyuID<>120) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800)
LEFT OUTER JOIN CDN.DaneKadMod on PRE_ETADkmIdStanowisko = DKM_DkmId
   LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
   LEFT OUTER JOIN CDN.PracNieobec on Pre_PraId = PNB_praid and PNB_Tryb<>1 and Data between PNB_OkresOd and PNB_OkresDo
-- zestawienie
   select @CzasPracyOg = @CzasPracyOg + (select  IsNull(sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_czas, 120))),0)
   FROM cdn.praczestaw INNER join CDN.PracEtaty on  Pre_PraId = PZE_PraId and @DataDo between PRE_DataOd and PRE_DataDo --and Year(PRE_DataDo) = 2999
   WHERE @DataOd1<= pze_okresod AND @DataDo>=pze_okresdo and @PrcId = PRE_PraId
   and PZE_Tryb<>1 and PRE_ZestCzasuPracy = 2 AND (PRE_DataOd between  @DataOd1 and @DataDo or PRE_DataDo  between  @DataOd1 and @DataDo
   or @DataOd1 between PRE_DataOd and PRE_DataDo))
--
--
END
--Zysk miesiĂ„â€¦c,
DECLARE @ZyskMc DECIMAL(15,2)
SET @ZyskMc = 0
BEGIN
SELECT @ZyskMc = IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
join CDN.pracEtaty on wpl_praid = pre_praid
WHERE
LPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus = 6 and
LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (Left(WPE_TyUb,2)=11 OR LEFT(WPE_TyUb, 3) = 800 or (LEFT(WPE_TyUb, 3)  = 300 and ((pre_ubztyuid>=110 and pre_ubztyuid<=200 and PRE_UbzTyuID<>120) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800))or (LEFT(WPE_TyUb, 3)>=310 and LEFT(WPE_TyUb, 3)<=320) and LEFT(WPE_TyUb, 4)<>1135 and LEFT(WPE_TyUb, 4)<>1150 and LEFT(WPE_TyUb, 4)<>1153 )
and LPL_DataDo Between @DataOd and @DataDo
and (TWP_Standardowy < 15 or TWP_Standardowy > 18) and TWP_Standardowy <> 20 and TWP_Standardowy <> 21 and TWP_Standardowy <> 22 and TWP_Standardowy <> 23
--[JK] TFS:152973
and LPL_Oddelegowani =0
END
--Wynagrodzenia ogolem
DECLARE @Zysk DECIMAL(15,2)
SET @Zysk = 0
BEGIN
SELECT @Zysk = IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
join CDN.pracEtaty on wpl_praid = pre_praid
WHERE
LPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus = 6 and
LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (Left(WPE_TyUb,2)=11 OR LEFT(WPE_TyUb, 3) = 800 or (LEFT(WPE_TyUb, 3)  = 300 and ((pre_ubztyuid>=110 and pre_ubztyuid<=200 and PRE_UbzTyuID<>120) or (pre_ubztyuid>=310 and pre_ubztyuid<=320) or (pre_ubztyuid>=1110 and pre_ubztyuid<=1134) or pre_ubztyuid=1140 or pre_ubztyuid=800)) or (LEFT(WPE_TyUb, 3)>=310 and LEFT(WPE_TyUb, 3)<=320) and LEFT(WPE_TyUb, 4)<>1135 and LEFT(WPE_TyUb, 4)<>1150 and LEFT(WPE_TyUb, 4)<>1153 )
and LPL_DataDo Between @DataOd1 and @DataDo
and (TWP_Standardowy < 15 or TWP_Standardowy > 18) and TWP_Standardowy <> 20  and TWP_Standardowy <> 21 and TWP_Standardowy <> 22 and TWP_Standardowy <> 23
--[JK] TFS:152973
and LPL_Oddelegowani =0
END
CLOSE Tmp_Czas
DEALLOCATE Tmp_Czas
END
SET @P1 = @ZatrPrac + @WlascWsp
SET @P2 = @Tmp_ET/@Tmp_DniMC
SET @P3 = @Tmp_ET_OKR/@n
SET @P4 = @CzasPracyOg/60
SET @P5 = @WynagrMC
SET @P6 = @Wynagr
SET @P7 = @SklMC
SET @P8 = @Skl
SET @P9 = @ZyskMC
SET @P10 = @Zysk
-- sprawdzenie procedury select @P1+@P2 DG1_06_1, @dzien-1 dzien, @Tmp_ET 'suma_za_msc' , @Tmp_DniMC 'Dni_w_MSC', @Tmp_ET/@Tmp_DniMC 'DG1_07_1', @Tmp_ET_OKR/@n 'DG1_07_2',  @WynagrMC 'DG1_09_1', @SklMC 'DG1_11_1', @Wynagr 'DG1_09_2', @Skl 'DG1_11_2'
select @P1 P1, @P2 P2, @P3 P3, @P4 P4, @P5 P5, @P6 P6, @P7 P7, @P8 P8, @P9 P9, @P10 P10
SET NOCOUNT OFF
END
