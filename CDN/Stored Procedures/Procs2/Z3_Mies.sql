CREATE PROCEDURE CDN.Z3_Mies  @DataOd DATETIME, @DataDo DATETIME, @ZasOd DATETIME, @PrcId INT, @ZasNaDzien DATETIME
AS
SET NOCOUNT ON
DECLARE @MYOd       INT
DECLARE @MYDo       INT
DECLARE @Month      INT
DECLARE @Year       INT
DECLARE @MYCurrent  INT
DECLARE @PracWymiar INT
DECLARE @PreId      INT
DECLARE @Zaszeregowanie DECIMAL(15,2)
DECLARE @RodzajRozliczenia INT
DECLARE @DniN    INT
DECLARE @PracaWpis INT
DECLARE @Dni_Praca INT
DECLARE @Dni_Plan  INT
DECLARE @Dni_PrzyczNiePr NVARCHAR(50)
DECLARE @Dni_SklWykazywane DECIMAL (15,2)
DECLARE @Dni_SklPomniejszane DECIMAL (15,2)
DECLARE @Dni_SklFaktWypl DECIMAL (15,2)
-- [JK] Zgł.144757
DECLARE @Dni_UmowyFaktWypl DECIMAL (15,2)
DECLARE @Dni_UmowyWykazywane DECIMAL (15,2)
DECLARE @Dni_UmowyPomniejszane DECIMAL (15,2)
DECLARE @DataU DATETIME
-- [JK] Zgł.278658, 279636
SET @DataU = CONVERT(DATETIME, CAST(DATEPART(year ,@ZasOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@ZasOd) AS NVARCHAR)+'-01 00:00:00', 120)
--
DECLARE @RodzajZatr INT
DECLARE @RozlNadg INT
DECLARE @Minimalna INT
DECLARE @MinKonf DECIMAL (15,2)
DECLARE @Wynik NVARCHAR(4000)
DECLARE @param INT
DECLARE @NazwaSerwera NVARCHAR (1000)
DECLARE @Serwer NVARCHAR (1000)
DECLARE @BazaK NVARCHAR (1000)
DECLARE @Dni_PodstChor DECIMAL (15,2)
DECLARE @Dni_PodstWyp DECIMAL (15,2)
 -- [JK] Zgł.170684
DECLARE @Dni_UmowySumaSkladek DECIMAL (15,2)
DECLARE @Dni_UmowyPodstChor DECIMAL (15,2)
DECLARE @Dni_UmowyPodstWyp DECIMAL (15,2)
-- [JK] TFS:167959
DECLARE @Dni_PlanZ3a  INT
DECLARE @Dni_PracaZ3a INT
--[JK] TFS:148857
DECLARE @Dni_Plan1Mc  INT
SET  @Dni_Plan1Mc = 0
DECLARE @param1Mc INT
SET @param1Mc = 0
--[JK] TFS:257435
DECLARE @Data1McOd DATETIME
DECLARE @Data1McDo DATETIME
DECLARE @UrlNieWplywaChor INT
SET @UrlNieWplywaChor = (select CFW_Wartosc from CDN.CfgWartosci join CDN.CfgKlucze on CFW_CfkId=CFK_CfkId where CFK_Nazwa='UrlopNieWplywaChorob')
--[JK] TFS:136133
DECLARE @ZasadnNominalneBezUrlopuDoChorob INT
SET @ZasadnNominalneBezUrlopuDoChorob = (select CFW_Wartosc from CDN.CfgWartosci join CDN.CfgKlucze on CFW_CfkId=CFK_CfkId where CFK_Nazwa='ZasadnNominalneBezUrlopuDoChorob')
DECLARE @Urlop INT
DECLARE @NieobDopel INT
DECLARE @Dod_DopDniGodz INT
DECLARE @Dni_SumaSkladek DECIMAL (15,2)
SET @Serwer = (select SYS_Wartosc from CDN.SystemCDN where SYS_ID = 1001)
SET @BazaK = (select SYS_Wartosc from CDN.SystemCDN where SYS_ID = 1002)
IF @DataOd IS NULL OR @DataDo IS NULL
BEGIN
  SET @DataOd = '1899-12-30 00:00:00'
  SET @DataDo = '1899-12-30 00:00:00'
END
ELSE
BEGIN
  SET @DataOd = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataOd) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataOd) AS NVARCHAR)+' 00:00:000', 120)
  SET @DataDo = CONVERT(DATETIME, CAST(DATEPART(year ,@DataDo) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDo) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataDo) AS NVARCHAR)+' 00:00:000', 120)
--[JK] TFS:257435
  SET @Data1McOd = DATEADD (M, -1 , @DataOd)
  SET @Data1McDo = DATEADD (dd, -1 , @DataOd)
END
--[JK] TFS:154587
DECLARE @ZasPoZwol INT
IF @ZasNaDzien > (select PRE_ZatrudnionyDo from cdn.pracetaty where pre_praid = @PrcId and year(pre_datado) = 2999)
BEGIN
  SET @ZasPoZwol = 1
END
ELSE
BEGIN
  SET @ZasPoZwol = 0
END
--[JK] TFS:148857
IF Year(@DataOd) = Year(@DataDo) and Month(@DataOd) = Month(@DataDo) and
--[JK] TFS:257435 Dodano warunek na zatrudnienie w poprzednim miesiącu PRE_ZatrudnionyOd between @Data1McOd and @Data1McDo
(select PRE_PraId from cdn.pracetaty where pre_praid = @PrcId and @DataDo between pre_dataod and pre_datado
  and (PRE_ZatrudnionyOd between @DataOd and @DataDo or PRE_ZatrudnionyOd between @Data1McOd and @Data1McDo)  and PRE_Tymczasowy = 0) is not null
BEGIN
SET  @Dni_Plan1Mc =  (select sum(Norma)/60 from CDN.PracCzasPracyFN (2, @PrcId, @DataOd, @DataDo)
--[JK] TFS:159045
left join cdn.PracNieobec on @PrcId = PNB_PraId and Data between PNB_OkresOd and PNB_OkresOd
left JOIN  cdn.typnieobec on PNB_tnbid = TNB_tnbId
--
where TypDnia = 1 and IsNUll(TNB_typ, 0) <>2
--[JK] TFS:146580
and Norma > 0
)
SET @param1Mc = 1
END
-- Sprawdzam sposob rozliczania pracownika - 2 dla prc wg zestawienia
SET @RodzajRozliczenia = 0
--SET @RodzajRozliczenia = (select isnull(pre_zestczasupracy,99) from cdn.pracetaty where pre_praid=@PrcId and @DataDo between pre_dataod and pre_datado)
SET @RozlNadg = (select KAL_NadgodzOkres from cdn.pracetaty inner join CDN.Kalendarze on PRE_KalId = KAL_KalId where PRE_PraId = @PrcId and @DataDo between pre_dataod and pre_datado)
--Tworze tabele tymczasowa, ktora zwracac bedzie czas pracy pracownika
CREATE TABLE #Z3_Mies (
 Tmp_Rok          INT,
 Tmp_Mc           INT,
 Tmp_Dni_Praca    INT, -- ile dni pracy
 Tmp_Dni_Plan     INT, -- ile dni w planie pracy
 Tmp_PrzyczNiePr  NVARCHAR(50), -- przyczyna nie przepracowania ca3ego miesi1ca
 Tmp_SklWykazywane DECIMAL(15,2), -- sk3adki wykazywane w sta3ej wysokooci
 Tmp_SklPomniejszane DECIMAL(15,2), -- sk3adki pomniejszane  proporcjonalnie
 Tmp_SklFaktWypl DECIMAL(15,2), -- sk3adki faktycznie wyp3acone
 Tmp_PodstChor DECIMAL(15,2), --podstawa chorobowa wymiaru składek
 Tmp_PodstWyp  DECIMAL(15,2), --podstawa wypadkowa wymiaru składek
 Tmp_DniPracaZ3a    INT, -- ile dni pracy na druku Z3a (bez ograniczenia dla etatów)
 Tmp_SumaSkladek DECIMAL(15,2), --suma składek emer, rent i chor. dla pracownika
 Tmp_Dni_PlanZ3a INT -- plan pracy na druku Z3a (bez ograniczenia dla etatów)
 )
--Inicjalizuje wartosci domyslne
SET @MYOd = DATEPART (year,@DataOd)*12+DATEPART(month, @DataOd)
SET @MYDo = DATEPART (year,@DataDo)*12+DATEPART(month, @DataDo)
SET @MYCurrent = @MYOd
WHILE @MYCurrent<=@MYDo
BEGIN
 --Zeruje zmienne
 SET @Dni_SklFaktWypl = 0
 SET @Zaszeregowanie = 0
 SET @DniN = 0
 SET @Dni_Praca = 0
 SET @Dni_Plan = 0
 SET @PracaWpis = 0
 SET @Dni_PrzyczNiePr = 0
 SET @Dni_SklWykazywane = 0
 SET @Dni_SklPomniejszane = 0
 -- [JK] Zgł.144757
 SET @Dni_UmowyFaktWypl = 0
 SET @Dni_UmowyWykazywane = 0
 SET @Dni_UmowyPomniejszane = 0
 --
 SET @Dni_PodstChor = 0
 SET @Dni_PodstWyp = 0
 SET @Dni_PracaZ3a = 0
 -- [JK] TFS:167959
 SET @Dni_PlanZ3a = 0
 SET @Urlop = 0
 SET @NieobDopel = 0
 SET @Dod_DopDniGodz = 0
 SET @Dni_SumaSkladek = 0
 -- [JK] Zgł.170684
 SET @Dni_UmowySumaSkladek = 0
 SET @Dni_UmowyPodstChor = 0
 SET @Dni_UmowyPodstWyp = 0
 --Przerabiam miesiac na daty od i do
 SET @Year   = @MYCurrent/12
 SET @Month  = @MYCurrent - (@Year*12)
 IF @Month = 0
 BEGIN
    SET @Year  = @Year -1
    SET @Month = 12
 END
 SET @DataOd = CONVERT (datetime, CAST(@Year as NVARCHAR)+'-'+CAST(@Month as NVARCHAR)+'-01 00:00:00', 120)
 IF @Month<12
   SET @DataDo = CONVERT (datetime, CAST(@Year as NVARCHAR)+'-'+CAST(@Month+1 as NVARCHAR)+'-01 00:00:00', 120)-1
 ELSE
   SET @DataDo = CONVERT (datetime, CAST(@Year as NVARCHAR)+'-12-31 00:00:00', 120)
SET @RodzajRozliczenia = (select isnull(pre_zestczasupracy,99) from cdn.pracetaty where pre_praid=@PrcId and @DataDo between pre_dataod and pre_datado)
SET @Urlop = (select count(distinct data) from CDN.PracCzasPracyFN (3, @PrcId, @DataOd, @DataDo) left outer JOIN  cdn.typnieobec on TypNieob = TNB_tnbId where TNB_Typ=4)
SET @NieobDopel = (select count(distinct data) from CDN.PracCzasPracyFN (3, @PrcId, @DataOd, @DataDo) left outer JOIN  cdn.typnieobec on TypNieob = TNB_tnbId where  (TNB_Typ=1 or TNB_Typ=8) and TNB_PomnCzasRNA=1)
--wykluczenie z weryfikacji dodatków ze względu na Zgł.201759
SET @Dod_DopDniGodz = @Dod_DopDniGodz + (select isnull(sum(wps_wartosc),0) from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid
  join cdn.wypelementy on wpe_wpeid=wps_wpeid
  join cdn.typwyplata on twp_twpid = wps_twpid
  where twp_wliczchor in (3,4) and WPL_Tryb<>1 and WPL_Tryb<>2
  and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  and WPS_RodzajZrodla <> 4
 )
SET @Dod_DopDniGodz = @Dod_DopDniGodz + (select isnull(sum(wps_wartosc),0) from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid
  join cdn.wypelementy on wpe_wpeid=wps_wpeid
  join cdn.typwyplata on twp_twpid = wps_twpid
  -- [JK] Zgł.201759
  join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
  join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where twp_wliczchor in (3,4) and WPL_Tryb<>1 and WPL_Tryb<>2
  and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
-- [JK] Zgł.201759
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU
  ))
/*
IF @RodzajRozliczenia = 2
   BEGIN
     SET @PracaWpis = (select pze_ilosc from cdn.praczestaw where pze_praid = @PrcId and @DataDo between pze_okresod and pze_okresdo)
     EXEC CDN.IleDniUrlopu @dataod, @datado, @PrcId, @DniN Output
     SET @Dni_Praca =  @PracaWpis + IsNull(@DniN, 0)
   END
ELSE
*/
--Praca
--
 -- [JK] Zgł.144757
 -- umowy faktycznie wypłacone kol.8
 SET @Dni_UmowyFaktWypl =  @Dni_UmowyFaktWypl +(select isnull(sum(wpe_wartosc),0) from
  cdn.wypelementy A where exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.Umowy on WPS_ZrodloId = UMW_UmwId
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and twp_wliczchor = 2
and B.wpe_wpeid=A.wpe_wpeid
-- dodano warunek na UMW_WliczChorZakonczona = 1, TFS:13396
and twp_rodzajzrodla = 8 and (UMW_DataDo > @DataU or UMW_WliczChorZakonczona = 1)
))
IF @Dni_UmowyFaktWypl is null
   SET @Dni_UmowyFaktWypl = 0
-- umowy pomniejszane  proporcjonalnie kol.7
 SET @Dni_UmowyPomniejszane =  @Dni_UmowyPomniejszane +(select isnull(sum(wpe_wartosc),0) from
  cdn.wypelementy A where exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.Umowy on WPS_ZrodloId = UMW_UmwId
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and twp_wliczchor in (3,4)
and B.wpe_wpeid=A.wpe_wpeid
-- dodano warunek na UMW_WliczChorZakonczona = 1, TFS:13396
and twp_rodzajzrodla = 8 and (UMW_DataDo > @DataU or UMW_WliczChorZakonczona = 1)
))
IF @Dni_UmowyPomniejszane is null
   SET @Dni_UmowyPomniejszane = 0
-- umowy wykazywane w stałej wysokości kol.6
 SET @Dni_UmowyWykazywane =  @Dni_UmowyWykazywane +(select isnull(sum(wpe_wartosc),0) from
  cdn.wypelementy A where exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.Umowy on WPS_ZrodloId = UMW_UmwId
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and twp_wliczchor in (5,6)
and B.wpe_wpeid=A.wpe_wpeid
-- dodano warunek na UMW_WliczChorZakonczona = 1, TFS:13396
and twp_rodzajzrodla = 8 and (UMW_DataDo > @DataU or UMW_WliczChorZakonczona = 1)
))
IF @Dni_UmowyWykazywane is null
   SET @Dni_UmowyWykazywane = 0
--
IF @RodzajRozliczenia = 2
   BEGIN
   SET @Dni_Praca = (select count(distinct data) from CDN.PracCzasPracyFN (3, @PrcId, @DataOd, @DataDo) left outer JOIN  cdn.typnieobec on TypNieob = TNB_tnbId
--[JK] TFS:177974
   inner join CDN.PracEtaty on Pre_PRaId=@PrcId and Data between PRE_DataOd and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   where   TypDnia = 1 and IsNUll(TNB_typ, 0)<>2 and IsNull(TNB_PomnCzasRNA, 0)=0)
   END
ELSE
/*
SET @Dni_Praca = (select count(*) from CDN.PracCzasPracyFN (3, @PrcId, @DataOd, @DataDo) left outer JOIN  cdn.typnieobec on TypNieob = TNB_tnbId
   where Praca<>0 and TypDnia = 1 and IsNUll(TNB_typ, 0)<>2 and IsNull(TNB_PomnCzasRNA, 0)=0)
*/
--[JK] TFS:157515
/*
SET @Dni_Praca = (select count(distinct data) from CDN.PracCzasPracyFN (3, @PrcId, @DataOd, @DataDo) left outer JOIN  cdn.typnieobec on TypNieob = TNB_tnbId
   where (Praca<>0 or TNB_PomnCzasRNA=0) and (TypDnia = 1 and IsNUll(TNB_typ, 0)<>2))
*/
SET @Dni_Praca = (select count(distinct A.Data) from CDN.PracCzasPracyFN (3, @PrcId, @DataOd, @DataDo) A left outer JOIN  cdn.typnieobec on A.TypNieob = TNB_tnbId
join CDN.PracCzasPracyFN (2, @PrcId, @DataOd, @DataDo) B on A.Data = B.Data
   where (A.Praca<>0 or TNB_PomnCzasRNA=0) and (B.TypDnia = 1 and IsNUll(TNB_typ, 0)<>2))
--
--Plan
--
--[JK] TFS:155556
SET  @Dni_Plan =  (select count(distinct data) from CDN.PracCzasPracyFN (2, @PrcId, @DataOd, @DataDo)
--[JK] TFS:158965
inner join CDN.PracEtaty on Pre_PRaId=@PrcId and Data between PRE_DataOd and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
--[JK] TFS:159045
left join cdn.PracNieobec on PRE_PraId = PNB_PraId and Data between PNB_OkresOd and PNB_OkresOd
left JOIN  cdn.typnieobec on PNB_tnbid = TNB_tnbId
--
where TypDnia = 1 and IsNUll(TNB_typ, 0) <>2
--[JK] TFS:146580
and Norma > 0
--and DATEDIFF(n,convert(datetime ,GodzOd),GodzDo)<>0
)
--
--
SET @Minimalna = (select pre_etaMinimalna from cdn.pracetaty where pre_praid = @PrcId and @DataDo between pre_dataod and pre_datado
  and ((@DataDo between pre_zatrudnionyod and pre_zatrudnionydo) or (pre_zatrudnionydo between @DataOd and @DataDo)))
IF  @Minimalna = 0
    BEGIN
 select @PracWymiar = pre_etawymiar, @PreId = pre_preid, @Zaszeregowanie = pre_etastawka from cdn.pracetaty where pre_praid = @PrcId and @DataDo between pre_dataod and pre_datado
  and ((@DataDo between pre_zatrudnionyod and pre_zatrudnionydo) or (pre_zatrudnionydo between @DataOd and @DataDo))
    END
ELSE
BEGIN
  SET @RodzajZatr = (select PRE_ETARodzajZatrudnienia from cdn.pracetaty where pre_praid = @PrcId and @DataDo between pre_dataod and pre_datado
  and ((@DataDo between pre_zatrudnionyod and pre_zatrudnionydo) or (pre_zatrudnionydo between @DataOd and @DataDo)))
  IF  @RodzajZatr NOT IN (4,5,6)
      BEGIN
 SET @param  = 0
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @MinKonf =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
 select @PracWymiar = pre_etawymiar, @PreId = pre_preid, @Zaszeregowanie = (@MinKonf*PRE_ETAGwarantProcMin *PRE_ETAEtatL)/(100*PRE_ETAEtatM)  from cdn.pracetaty where pre_praid = @PrcId and @DataDo between pre_dataod and pre_datado
   and ((@DataDo between pre_zatrudnionyod and pre_zatrudnionydo) or (pre_zatrudnionydo between @DataOd and @DataDo))
      END
  IF  @RodzajZatr = 4
      BEGIN
 SET @param  = 1
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @MinKonf =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
 select @PracWymiar = pre_etawymiar, @PreId = pre_preid, @Zaszeregowanie = (@MinKonf*PRE_ETAGwarantProcMin *PRE_ETAEtatL)/(100*PRE_ETAEtatM)  from cdn.pracetaty where pre_praid = @PrcId and @DataDo between pre_dataod and pre_datado
   and ((@DataDo between pre_zatrudnionyod and pre_zatrudnionydo) or (pre_zatrudnionydo between @DataOd and @DataDo))
      END
  IF  @RodzajZatr = 5
      BEGIN
 SET @param  = 2
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @MinKonf =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
 select @PracWymiar = pre_etawymiar, @PreId = pre_preid, @Zaszeregowanie = (@MinKonf*PRE_ETAGwarantProcMin *PRE_ETAEtatL)/(100*PRE_ETAEtatM)  from cdn.pracetaty where pre_praid = @PrcId and @DataDo between pre_dataod and pre_datado
   and ((@DataDo between pre_zatrudnionyod and pre_zatrudnionydo) or (pre_zatrudnionydo between @DataOd and @DataDo))
      END
  IF  @RodzajZatr = 6
      BEGIN
 SET @param  = 3
 SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , @param , @Wynik OutPut'
 execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , @param, @Wynik output
 SET @MinKonf =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
 select @PracWymiar = pre_etawymiar, @PreId = pre_preid, @Zaszeregowanie = (@MinKonf*PRE_ETAGwarantProcMin *PRE_ETAEtatL)/(100*PRE_ETAEtatM)  from cdn.pracetaty where pre_praid = @PrcId and @DataDo between pre_dataod and pre_datado
   and ((@DataDo between pre_zatrudnionyod and pre_zatrudnionydo) or (pre_zatrudnionydo between @DataOd and @DataDo))
      END
END
--[JK] TFS:148857
IF @PracWymiar=1
BEGIN
set @Zaszeregowanie = @Zaszeregowanie
END
ELSE IF @PracWymiar=2
BEGIN
set @Zaszeregowanie = @Zaszeregowanie * @Dni_Plan1Mc
END
 --przyczyna nie przepracowania calego miesiaca
 --
-- SET @Dni_PrzyczNiePr = (select top 1 tnb_akronim from cdn.pracnieobec join cdn.typnieobec on tnb_tnbid=pnb_tnbid where pnb_praid=@PrcId and PNB_Tryb<>1 and pnb_okresod >= @DataOd and pnb_okresdo <= @DataDo and tnb_standardowy not in (100, 101, 315) order by pnb_okresod desc)
-- SET @Dni_PrzyczNiePr = (select top 1 tnb_akronim from cdn.pracnieobec join cdn.typnieobec on tnb_tnbid=pnb_tnbid where pnb_praid=@PrcId and PNB_Tryb<>1 and pnb_okresod >= @DataOd and pnb_okresdo <= @DataDo and TNB_PomnCzasRNA = 1 order by pnb_okresod desc)
 SET @Dni_PrzyczNiePr = (select top 1 tnb_akronim from cdn.pracnieobec join cdn.typnieobec on tnb_tnbid=pnb_tnbid where pnb_praid=@PrcId and PNB_Tryb<>1 and TNB_PomnCzasRNA = 1 and ((pnb_okresod between @DataOd and @DataDo) or (pnb_okresdo between @DataOd and @DataDo)or ((pnb_okresod <= @DataOd) and (pnb_okresdo >= @DataDo)))
 --[JK] TFS:197143
 and PNB_PracaRodzic <> 1
 order by pnb_okresod desc)
 IF @Dni_PrzyczNiePr is null
    SET @Dni_PrzyczNiePr = ' '
 --[JK] TFS:183143
 --ustalenie czy pracownik ma wypłatę dla oddelegowanego
 DECLARE @Oddel INT
 SET @Oddel = (select isnull(count(lpl_lplid),0)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki on wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=wps_wpeid
 where wps_dataod>=@DataOd and wps_datado<=@DataDo and wpl_praid=@PrcId and LPL_Oddelegowani = 1)
 IF @Oddel > 0
 BEGIN
 SET @Dni_SklWykazywane = 0
 SET @Dni_SklPomniejszane = 0
 --elementy wypłaty z listy oddelegowanej
 SET @Dni_SklFaktWypl = isnull((select sum(wpe_wartosc) from
   cdn.wypelementy A where
 exists(select distinct B.wpe_wpeid
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypelementy B on wpe_wplid = wpl_wplid
 join cdn.typwyplata on twp_twpid = wpe_twpid
 join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
 where twp_wliczchor <> 1 and wps_dataod>=@DataOd and wps_datado<=@DataDo
 and WPL_Tryb<>1 and WPL_Tryb<>2 and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
 and LPL_Oddelegowani = 1 and TWP_Standardowy in (15, 16, 20, 21, 22, 23))),0)
 --elementy wypłaty z listy nieoddelegowanej
 SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + isnull((select sum(wpe_wartosc) from
   cdn.wypelementy A where
 exists(select distinct B.wpe_wpeid
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypelementy B on wpe_wplid = wpl_wplid
 join cdn.typwyplata on twp_twpid = wpe_twpid
 join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
 where twp_wliczchor <> 1 and wps_dataod>=@DataOd and wps_datado<=@DataDo
 and WPL_Tryb<>1 and WPL_Tryb<>2 and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
 and LPL_Oddelegowani = 0)),0)
 --[JK] TFS:154587
 IF @ZasPoZwol = 1
 BEGIN
 SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + isnull((select sum(wpe_wartosc) from
   cdn.wypelementy A where
 exists(select distinct B.wpe_wpeid
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypelementy B on wpe_wplid = wpl_wplid
 join cdn.typwyplata on twp_twpid = wpe_twpid
 join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
 where twp_wliczchor = 1 and wps_dataod>=@DataOd and wps_datado<=@DataDo and TWP_SklZUS = 2
 and WPL_Tryb<>1 and WPL_Tryb<>2 and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
 and LPL_Oddelegowani = 0 )),0)
 END
 END
 ELSE
 --skladki wykazywane w stalej wysokosci
 --
--IF @NieobDopel > 0 and @Urlop > 0 and @UrlNieWplywaChor = 0
IF @NieobDopel > 0 and @Urlop > 0 and @UrlNieWplywaChor = 0 and @Dod_DopDniGodz > 0
BEGIN
--[JK] TFS:161688
--IF @PracWymiar=1
 BEGIN
   SET @Dni_SklWykazywane = isnull((select sum(wps_wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki on wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=wps_wpeid
 join cdn.typwyplata on twp_twpid = wps_twpid
 where wps_dataod>=@DataOd and wps_datado<=@DataDo and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_wliczchor=5
  and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla <> 4
  ),0)
    SET @Dni_SklWykazywane = @Dni_SklWykazywane + isnull((select sum(wps_wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki on wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=wps_wpeid
 join cdn.typwyplata on twp_twpid = wps_twpid
  -- [JK] Zgł.201759
 join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
 join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
 where wps_dataod>=@DataOd and wps_datado<=@DataDo and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_wliczchor=5
  and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
  ),0)
 -- [JK] Zgł.205475
 SET @Dni_SklWykazywane = @Dni_SklWykazywane + isnull((select sum(B.WPS_Wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki A on A.wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=A.wps_wpeid
 join cdn.typwyplata on twp_twpid = A.wps_twpid
 --
 left join cdn.wypskladniki B on A.WPS_RodzajZrodla = B.WPS_RodzajZrodla and B.WPS_TwpId = 9 and B.WPS_DataOd>=@DataOd and B.WPS_DataDo<=@DataDo
 join cdn.PracNieobec on B.WPS_PnbId = PNB_PnbId
 join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
 --
  where A.WPS_DataOd>=@DataOd and A.WPS_DataDo<=@DataDo and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_wliczchor=5
  and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and a.WPS_RodzajZrodla <> 4
  and TNB_PdzId = 152
  --
  and a.WPS_ZrodloId = B.WPS_ZrodloId
   ),0)
 SET @Dni_SklWykazywane = @Dni_SklWykazywane + isnull((select sum(B.wps_wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki A on A.wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=A.wps_wpeid
 join cdn.typwyplata on twp_twpid = A.wps_twpid
 --
 left join cdn.wypskladniki B on A.WPS_RodzajZrodla = B.WPS_RodzajZrodla and B.WPS_TwpId = 9 and B.WPS_DataOd>=@DataOd and B.WPS_DataDo<=@DataDo
 join cdn.PracNieobec on B.WPS_PnbId = PNB_PnbId
 join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
 --
 -- [JK] Zgł.201759
 join cdn.Dodatki on A.WPS_ZrodloId = DOD_DodId
 join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
 where A.WPS_DataOd>=@DataOd and A.WPS_DataDo<=@DataDo and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_wliczchor=5
  and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
   -- [JK] Zgł.201759
  and A.WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
  and TNB_PdzId = 152
  --
  and A.WPS_ZrodloId = B.WPS_ZrodloId
   ),0)
 END
 --[JK] TFS:161688
 /*
 ELSE IF @PracWymiar=2
 BEGIN
   SET @Dni_SklWykazywane = (select sum(wps_wartosc)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid
  join cdn.wypelementy on wpe_wpeid=wps_wpeid
  join cdn.typwyplata on twp_twpid = wps_twpid
  where (twp_wliczchor=5
  -- [JK] Zgł.141465 - dodanie zasadnicze godz. oraz mies.
  or TWP_Standardowy in (1,2)
  ) and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8)
--
   SET @Dni_SklWykazywane = @Dni_SklWykazywane + isnull((select sum(wps_wartosc)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid
  join cdn.wypelementy on wpe_wpeid = wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  -- [JK] Zgł.141465 - uwzględnienie NN poprzez dodanie twp_wliczchor in (6)
  and wpl_praid=@PrcId and twp_wliczchor in (5,6)
  and ((exists (select 1
   from cdn.pracnieobec
   join cdn.typnieobec on pnb_tnbid=tnb_tnbid
   where twp_rodzajzrodla <> 22 and PNB_Tryb<>1 and pnb_pnbid=wps_pnbid and tnb_typ=2)))
   -- [JK] Zgł.144757
   and twp_rodzajzrodla <> 8
   ),0)
 END
 */
 IF @Dni_SklWykazywane is null
   SET @Dni_SklWykazywane = 0
 -- skladki pomniejszane  proporcjonalnie
 --
 --[JK] TFS:161688
 --IF @PracWymiar=1
 BEGIN
SET @Dni_SklPomniejszane = isnull((select sum(wpe_wartosc) from
   cdn.wypelementy A where
exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
    where twp_wliczchor in (3,4,6) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla <> 4
 )),0)
 SET @Dni_SklPomniejszane = @Dni_SklPomniejszane + isnull((select sum(wpe_wartosc) from
   cdn.wypelementy A where
exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  -- [JK] Zgł.201759
  join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
  join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
    where twp_wliczchor in (3,4,6) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
 )),0)
  -- [JK] Zgł.172274
/*
-(select sum(CASE When (Wps_TwpId in (4,6) and Wps_TwpId<>Wpe_Twpid) then wps_wartosc Else 0 End)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  where twp_wliczchor in (3,4,6) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22)
*/
 END
 --[JK] TFS:161688
 /*
 ELSE IF @PracWymiar=2
 BEGIN
  SET @Dni_SklPomniejszane = (select
--sum(CASE When (Wps_TwpId in (4,6) and Wps_TwpId<>Wpe_Twpid) then 0 Else wps_wartosc End)
sum(CASE When (Wps_TwpId in (4,6,9,10) and Wps_TwpId<>Wpe_Twpid) then 0 Else wpe_wartosc End)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  where twp_wliczchor in (3,4, 6) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
-- [JK] Zgł.141465 - wyłączone zasadnicze godz. oraz mies.
  and TWP_Standardowy not in (1,2)
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
- (select
sum(CASE When (Wps_TwpId in (4,6) and Wps_TwpId<>Wpe_Twpid) then wps_wartosc Else 0 End)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  where twp_wliczchor in (3,4, 6)
  and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
-- [JK] Zgł.142511 - wyłączonie poniże/powyżej normy od zasadnicze godz. oraz mies.
  and TWP_Standardowy not in (1,2)
  )
-- [JK] Zgł.141465 - dodanie pomniejszenia za urlop
+ isnull((select
sum(CASE When (Wps_TwpId<>Wpe_Twpid) then wps_wartosc Else 0 End)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.PracNieobec on WPS_PnbId = PNB_PnbId
  join cdn.TypNieobec on TNB_TnbId = PNB_TnbId
  where Wps_TwpId in (9) and TNB_Typ = 4 and
   wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
-- [JK] Zgł.142361
  and WPS_RodzajZrodla=1),0)
 END
 */
 IF @Dni_SklPomniejszane is null
    SET @Dni_SklPomniejszane = 0
-- skladki faktycznie wyplacone
 -- [JK] Zgł.171990 - uwzlędniono dodatki jednorazowe. Zmiana polegała na zmianie twp_okreswyplaty in (2,3) na twp_okreswyplaty in (1,2,3)
 --
 --[JK] TFS:161688
 --IF @PracWymiar=1
 BEGIN
 SET @Dni_SklFaktWypl = @Dni_SklFaktWypl +(select isnull(sum(wpe_wartosc),0) from
  cdn.wypelementy A where exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  and twp_rodzajzrodla <> 7 and twp_okreswyplaty in (1,2,3)
  and twp_wliczchor = 2 and twp_standardowy not in (4, 5, 6, 7)
and B.wpe_wpeid=A.wpe_wpeid
-- [JK] Zgł.144757
and twp_rodzajzrodla <> 8
-- [JK] Zgł.180773
-- [JK] Zgł.191714 and twp_algalgorytm <> 7 and twp_algalgorytm <> 8
-- [JK] Zgł.201759
and WPS_RodzajZrodla <> 4
))
 SET @Dni_SklFaktWypl = @Dni_SklFaktWypl +(select isnull(sum(wpe_wartosc),0) from
  cdn.wypelementy A where exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  -- [JK] Zgł.201759
  join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
  join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  and twp_rodzajzrodla <> 7 and twp_okreswyplaty in (1,2,3)
  and twp_wliczchor = 2 and twp_standardowy not in (4, 5, 6, 7)
and B.wpe_wpeid=A.wpe_wpeid
-- [JK] Zgł.144757
and twp_rodzajzrodla <> 8
-- [JK] Zgł.180773
-- [JK] Zgł.191714 and twp_algalgorytm <> 7 and twp_algalgorytm <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
))
--
  SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + ( select isnull(sum(wps_wartosc),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_WpeId = Wps_Wpeid
  join cdn.typwyplata A on A.twp_twpid = wps_twpid
  join cdn.typwyplata B on B.twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and A.twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and A.twp_standardowy in (4, 5)
  -- [JK] Zgł.172274
  and Wps_TwpId not in (4,6)
  and B.twp_wliczchor<>2
  and B.twp_wliczchor<>1
  -- [JK] Zgł.144757
  and A.TWP_RodzajZrodla <> 8
  )
--
-- [JK] Zgł.182755 zmiana sumowania wpe_wartosc zamiast wps_wartosc
   IF @RozlNadg=1
  SET @Dni_SklFaktWypl =  @Dni_SklFaktWypl + (select isnull(sum(wpe_wartosc),0)
  from cdn.wyplaty
  join cdn.wypskladniki on wps_wplid = wpl_wplid
  join cdn.wypelementy on wps_wpeid = wpe_wpeid
  join cdn.typwyplata on twp_twpid = wps_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and  twp_standardowy in (6, 7)
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
 END
 --[JK] TFS:161688
 /*
 ELSE IF @PracWymiar=2
 BEGIN
SET @Dni_SklFaktWypl = (select isnull(sum(CASE When (A.TWP_Standardowy in (4,5) and Wps_TwpId<>Wpe_Twpid and  B.twp_wliczchor<>2
  and B.twp_wliczchor<>1)
then wps_wartosc When A.twp_wliczchor<>2 OR Wps_TwpId<>Wpe_Twpid Then 0 Else wpe_wartosc End),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = wps_wpeid
  join cdn.typwyplata A on A.twp_twpid = wps_twpid
  join cdn.typwyplata B on B.twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and A.twp_rodzajzrodla <> 22
  and A.twp_okreswyplaty in (1,2,3)
and A.twp_wliczchor = 2
and ((@RozlNadg > 1 and A.TWP_Standardowy not in (6,7)) or (@RozlNadg <= 1 and  1=1))
-- [JK] Zgł.144757
and A.TWP_RodzajZrodla <> 8
)
 END
 */
 --[JK] TFS:154587
 IF @ZasPoZwol = 1
 BEGIN
 SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + isnull((select sum(wpe_wartosc) from
   cdn.wypelementy A where
 exists(select distinct B.wpe_wpeid
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypelementy B on wpe_wplid = wpl_wplid
 join cdn.typwyplata on twp_twpid = wpe_twpid
 join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
 where twp_wliczchor = 1 and wps_dataod>=@DataOd and wps_datado<=@DataDo and TWP_SklZUS = 2
 and WPL_Tryb<>1 and WPL_Tryb<>2 and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
 and LPL_Oddelegowani = 0 )),0)
 END
 IF @Dni_SklFaktWypl is null
    SET @Dni_SklFaktWypl = 0
END
ELSE
BEGIN
--[JK] TFS:161688
 --IF @PracWymiar=1
 BEGIN
 --[JK] TFS:148857
 IF @param1Mc = 1
   SET @Dni_SklWykazywane = @Zaszeregowanie +
   isnull((select sum(wps_wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki on wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=wps_wpeid
 join cdn.typwyplata on twp_twpid = wps_twpid
 where wps_dataod>=@DataOd and wps_datado<=@DataDo and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and (twp_wliczchor = 6 or twp_wliczchor=5)
  and (twp_algalgorytm not in (7,8))
  and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla <> 4
  -- [JK] Zgł.148857
  and TWP_Standardowy <> 1 and TWP_Standardowy <> 2
  -- [JK] Zgł.186922
  and ((NOT exists (select 1
  from cdn.pracnieobec
  join cdn.typnieobec on pnb_tnbid=tnb_tnbid
  where WPS_RodzajZrodla = 6 and PNB_Tryb<>1 and pnb_pnbid=WPS_ZrodloId and tnb_typ=4 )))
  ) ,0)
  ELSE
    SET @Dni_SklWykazywane =
   isnull((select sum(wps_wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki on wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=wps_wpeid
 join cdn.typwyplata on twp_twpid = wps_twpid
 where wps_dataod>=@DataOd and wps_datado<=@DataDo and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and (twp_wliczchor = 6 or twp_wliczchor=5)
  and (twp_algalgorytm not in (7,8))
  and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla <> 4
  -- [JK] Zgł.186922
  and ((NOT exists (select 1
  from cdn.pracnieobec
  join cdn.typnieobec on pnb_tnbid=tnb_tnbid
  where WPS_RodzajZrodla = 6 and PNB_Tryb<>1 and pnb_pnbid=WPS_ZrodloId and tnb_typ=4 )))
  ) ,0)
  -- [JK] Zgł.201759 - Dodatki
/* [JK] Zgł.240701
   SET @Dni_SklWykazywane = @Dni_SklWykazywane +
  -- [JK] Zgł.232195 - zmieniono wps_wartosc na wpe_wartosc
   isnull((select sum(wpe_wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki on wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=wps_wpeid
 join cdn.typwyplata on twp_twpid = wps_twpid
 -- [JK] Zgł.201759
 join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
 join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where wps_dataod>=@DataOd and wps_datado<=@DataDo and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_wliczchor = 6
  and (twp_algalgorytm not in (7,8))
  and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
  -- [JK] Zgł.186922
  and ((NOT exists (select 1
  from cdn.pracnieobec
  join cdn.typnieobec on pnb_tnbid=tnb_tnbid
  where WPS_RodzajZrodla = 6 and PNB_Tryb<>1 and pnb_pnbid=WPS_ZrodloId and tnb_typ=4 )))
    ) ,0)
*/
 SET @Dni_SklWykazywane = @Dni_SklWykazywane +
  --[JK] Zgł.240701 wycofano Zgł.232195 - wyodrębnienie dodatków z wliczać
   isnull((select sum(wps_wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki on wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid=wps_wpeid
 join cdn.typwyplata on twp_twpid = wps_twpid
 -- [JK] Zgł.201759
 join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
 join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where wps_dataod>=@DataOd and wps_datado<=@DataDo and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  --[JK] Zgł.240701 and wpl_praid=@PrcId and twp_wliczchor=5
  and wpl_praid=@PrcId and twp_wliczchor in (6, 5)
  and (twp_algalgorytm not in (7,8))
  and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
  -- [JK] Zgł.186922
  and ((NOT exists (select 1
  from cdn.pracnieobec
  join cdn.typnieobec on pnb_tnbid=tnb_tnbid
  where WPS_RodzajZrodla = 6 and PNB_Tryb<>1 and pnb_pnbid=WPS_ZrodloId and tnb_typ=4 )))
    ) ,0)
--
   SET @Dni_SklWykazywane = @Dni_SklWykazywane + isnull((select sum(wps_wartosc)
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypskladniki on wps_wplid = wpl_wplid
 join cdn.wypelementy on wpe_wpeid = wps_wpeid
 join cdn.typwyplata on twp_twpid = wpe_twpid
 where wps_dataod>=@DataOd and wps_datado<=@DataDo
 and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
 and wpl_praid=@PrcId and twp_wliczchor in (6, 5)
 and ((exists (select 1
  from cdn.pracnieobec
  join cdn.typnieobec on pnb_tnbid=tnb_tnbid
  where twp_rodzajzrodla <> 22 and PNB_Tryb<>1 and pnb_pnbid=wps_pnbid and tnb_typ=2)))
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  ),0)
 END
 --[JK] TFS:161688
 /*
 ELSE IF @PracWymiar=2
 BEGIN
   SET @Dni_SklWykazywane = (select sum(wps_wartosc)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid
  join cdn.wypelementy on wpe_wpeid=wps_wpeid
  join cdn.typwyplata on twp_twpid = wps_twpid
  where (twp_wliczchor=5
  -- [JK] Zgł.141465 - dodanie zasadnicze godz. oraz mies.
  or TWP_Standardowy in (1,2)
  ) and
  WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
--
   SET @Dni_SklWykazywane = @Dni_SklWykazywane + isnull((select sum(wps_wartosc)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid
  join cdn.wypelementy on wpe_wpeid = wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  -- [JK] Zgł.141465 - uwzględnienie NN poprzez dodanie twp_wliczchor in (6)
  and wpl_praid=@PrcId and twp_wliczchor in (5,6)
  and ((exists (select 1
   from cdn.pracnieobec
   join cdn.typnieobec on pnb_tnbid=tnb_tnbid
   where twp_rodzajzrodla <> 22 and PNB_Tryb<>1 and pnb_pnbid=wps_pnbid and tnb_typ=2)))
   -- [JK] Zgł.144757
   and twp_rodzajzrodla <> 8
   ),0)
 END
 */
 IF @Dni_SklWykazywane is null
   SET @Dni_SklWykazywane = 0
 --
 -- skladki pomniejszane  proporcjonalnie
 --
 --[JK] TFS:161688
 --IF @PracWymiar=1
 BEGIN
 SET @Dni_SklPomniejszane = @Dni_SklPomniejszane + (select isnull(sum(wpe_wartosc),0) from
   cdn.wypelementy A where
exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
    where twp_wliczchor in (3,4) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla <> 4
 ) )
 -- [JK] Zgł.201759-Dodatki
 SET @Dni_SklPomniejszane = @Dni_SklPomniejszane + (select isnull(sum(wpe_wartosc),0) from
   cdn.wypelementy A where
exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  -- [JK] Zgł.201759
  join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
  join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where twp_wliczchor in (3,4) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  -- [JK] Zgł.201759
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
 ) )
 --[JK] TFS:12775
 /*
-(select sum(CASE When (Wps_TwpId in (4,6) and Wps_TwpId<>Wpe_Twpid) then wps_wartosc Else 0 End)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  where twp_wliczchor in (3,4) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8)
 */
 END
 --[JK] TFS:161688
 /*
 ELSE IF @PracWymiar=2
 BEGIN
 SET @Dni_SklPomniejszane = (select
--sum(CASE When (Wps_TwpId in (4,6) and Wps_TwpId<>Wpe_Twpid) then 0 Else wps_wartosc End)
sum(CASE When (Wps_TwpId in (4,6,9,10) and Wps_TwpId<>Wpe_Twpid) then 0 Else wpe_wartosc End)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  where twp_wliczchor in (3,4, 6) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
-- [JK] Zgł.141465 - wyłączone zasadnicze godz. oraz mies.
  and TWP_Standardowy not in (1,2)
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
--[JK] TFS:12775
/*
- (select
sum(CASE When (Wps_TwpId in (4,6) and Wps_TwpId<>Wpe_Twpid) then wps_wartosc Else 0 End)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  where twp_wliczchor in (3,4, 6)
  and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
-- [JK] Zgł.142511 - wyłączonie poniże/powyżej normy od zasadnicze godz. oraz mies.
  and TWP_Standardowy not in (1,2)
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
*/
-- [JK] Zgł.141465 - dodanie pomniejszenia za urlop
+ isnull((select
sum(CASE When (Wps_TwpId<>Wpe_Twpid) then wps_wartosc Else 0 End)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.PracNieobec on WPS_PnbId = PNB_PnbId
  join cdn.TypNieobec on TNB_TnbId = PNB_TnbId
  where Wps_TwpId in (9) and TNB_Typ = 4 and
   wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
  -- [JK] Zgł.142361
  and WPS_RodzajZrodla=1
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  ),0)
 END
 */
 IF @Dni_SklPomniejszane is null
    SET @Dni_SklPomniejszane = 0
 --
 -- skladki faktycznie wyplacone
 -- [JK] Zgł.171990 - uwzlędniono dodatki jednorazowe. Zmiana polegała na zmianie twp_okreswyplaty in (2,3) na twp_okreswyplaty in (1,2,3)
 --[JK] TFS:161688
 --IF @PracWymiar=1
 BEGIN
 SET @Dni_SklFaktWypl = @Dni_SklFaktWypl +(select isnull(sum(wpe_wartosc),0) from
  cdn.wypelementy A where exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  and twp_rodzajzrodla <> 7 and twp_okreswyplaty in (1,2,3)
  and twp_wliczchor = 2 and twp_standardowy not in (4, 5, 6, 7)
and B.wpe_wpeid=A.wpe_wpeid
-- [JK] Zgł.144757
and twp_rodzajzrodla <> 8
-- [JK] Zgł.201759
and WPS_RodzajZrodla <> 4
-- [JK] Zgł.180773
and twp_algalgorytm <> 7 and twp_algalgorytm <> 8
))
-- [JK] Zgł.201759 - Dodatki
 SET @Dni_SklFaktWypl = @Dni_SklFaktWypl +(select isnull(sum(wpe_wartosc),0) from
  cdn.wypelementy A where exists(select distinct B.wpe_wpeid
  from cdn.wyplaty
  join cdn.wypelementy B on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  -- [JK] Zgł.201759
  join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
  join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  and twp_rodzajzrodla <> 7 and twp_okreswyplaty in (1,2,3)
  and twp_wliczchor = 2 and twp_standardowy not in (4, 5, 6, 7)
and B.wpe_wpeid=A.wpe_wpeid
-- [JK] Zgł.144757
and twp_rodzajzrodla <> 8
-- [JK] Zgł.180773
and twp_algalgorytm <> 7 and twp_algalgorytm <> 8
-- [JK] Zgł.201759
and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
))
--
  SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + ( select isnull(sum(wps_wartosc),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_WpeId = Wps_Wpeid
  join cdn.typwyplata A on A.twp_twpid = wps_twpid
  join cdn.typwyplata B on B.twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and A.twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and A.twp_standardowy in (4, 5)
  and B.twp_wliczchor<>2
  and B.twp_wliczchor<>1
  -- [JK] Zgł.144757
  and A.TWP_RodzajZrodla <> 8
  )
--
  -- [JK] Zgł.136133
IF @NieobDopel > 0 and @Urlop > 0 and @ZasadnNominalneBezUrlopuDoChorob = 1 and @Dod_DopDniGodz = 0
BEGIN
--
   SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + (select isnull(sum(wps_wartosc),0)
  from cdn.wypskladniki
  join cdn.wypelementy on wps_wpeid = wpe_wpeid
  join cdn.wyplaty on wpl_wplid = wpe_wplid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.pracnieobec on wps_pnbid = pnb_pnbid
  join  cdn.typnieobec on pnb_tnbid=tnb_tnbid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo and PNB_Tryb<>1
  and wpl_praid=@PrcId
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  -- [JK] Zgł.162860
  --and wps_rodzajzrodla=1
  and twp_wliczchor = 6
  --
  and twp_rodzajzrodla <> 22
  and pnb_pnbid=wps_pnbid and tnb_PomnCzasRNA=0 and tnb_typ<>4
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
END
ELSE
BEGIN
--
   SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + (select isnull(sum(wpe_wartosc),0)
  from cdn.wypelementy
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wpeid = wpe_wpeid
  join cdn.typwyplata on wps_twpid = twp_twpid
  where wps_rodzajzrodla = 6 and wpl_praid=@PrcId
  and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and twp_rodzajzrodla <> 22 and (twp_algalgorytm = 7 or twp_algalgorytm = 8
  -- [JK] Zgł.186922
  or ((exists (select 1
  from cdn.pracnieobec
  join cdn.typnieobec on pnb_tnbid=tnb_tnbid
  where WPS_RodzajZrodla = 6 and PNB_Tryb<>1 and pnb_pnbid=WPS_ZrodloId and tnb_typ=4 ))
  and twp_wliczchor = 6
  )
  )
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
--
--
   SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + (select isnull(sum(wps_wartosc),0)
  from cdn.wypskladniki
  join cdn.wypelementy on wps_wpeid = wpe_wpeid
  join cdn.wyplaty on wpl_wplid = wpe_wplid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.pracnieobec on wps_pnbid = pnb_pnbid
  join  cdn.typnieobec on pnb_tnbid=tnb_tnbid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo and PNB_Tryb<>1
  and wpl_praid=@PrcId
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  -- [JK] Zgł.162860
  --and wps_rodzajzrodla=1
  and twp_wliczchor = 6
  --
  and twp_rodzajzrodla <> 22
  and pnb_pnbid=wps_pnbid and tnb_PomnCzasRNA=0
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
  END
-- [JK] Zgł.182755 zmiana sumowania wpe_wartosc zamiast wps_wartosc
   IF @RozlNadg=1
  SET @Dni_SklFaktWypl =  @Dni_SklFaktWypl + (select isnull(sum(wpe_wartosc),0)
  from cdn.wyplaty
  join cdn.wypskladniki on wps_wplid = wpl_wplid
  join cdn.wypelementy on wps_wpeid = wpe_wpeid
  join cdn.typwyplata on twp_twpid = wps_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and  twp_standardowy in (6, 7)
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
  --[JK] TFS:12775
  SET @Dni_SklFaktWypl =  @Dni_SklFaktWypl-(select isnull(sum(CASE When (Wps_TwpId in (4,6) and Wps_TwpId<>Wpe_Twpid) then wps_wartosc Else 0 End),0)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  where twp_wliczchor in (3,4) and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8)
 END
 --[JK] TFS:161688
 /*
 ELSE IF @PracWymiar=2
 BEGIN
SET @Dni_SklFaktWypl = (select isnull(sum(CASE When (A.TWP_Standardowy in (4,5) and Wps_TwpId<>Wpe_Twpid and  B.twp_wliczchor<>2
  and B.twp_wliczchor<>1)
then wps_wartosc When A.twp_wliczchor<>2 OR Wps_TwpId<>Wpe_Twpid Then 0 Else wpe_wartosc End),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = wps_wpeid
  join cdn.typwyplata A on A.twp_twpid = wps_twpid
  join cdn.typwyplata B on B.twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  where wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId and A.twp_rodzajzrodla <> 22
  and A.twp_okreswyplaty in (1,2,3)
and A.twp_wliczchor = 2
and ((@RozlNadg > 1 and A.TWP_Standardowy not in (6,7)) or (@RozlNadg <= 1 and  1=1))
-- [JK] Zgł.144757
and A.TWP_RodzajZrodla <> 8
)
--[JK] TFS:12775
SET @Dni_SklFaktWypl = @Dni_SklFaktWypl- (select
isnull(sum(CASE When (Wps_TwpId in (4,6) and Wps_TwpId<>Wpe_Twpid) then wps_wartosc Else 0 End),0)
  from cdn.wyplaty
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  where twp_wliczchor in (3,4, 6)
  and wps_dataod>=@DataOd and wps_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2 and twp_okreswyplaty in (1,2,3)
  and wpl_praid=@PrcId and twp_rodzajzrodla <> 22
-- [JK] Zgł.142511 - wyłączonie poniże/powyżej normy od zasadnicze godz. oraz mies.
  and TWP_Standardowy not in (1,2)
  -- [JK] Zgł.144757
  and twp_rodzajzrodla <> 8
  )
 END
 */
 --[JK] TFS:154587
 IF @ZasPoZwol = 1
 BEGIN
 SET @Dni_SklFaktWypl = @Dni_SklFaktWypl + isnull((select sum(wpe_wartosc) from
   cdn.wypelementy A where
 exists(select distinct B.wpe_wpeid
 from cdn.wyplaty
 join cdn.listyplac on wpl_lplid = lpl_lplid
 join cdn.wypelementy B on wpe_wplid = wpl_wplid
 join cdn.typwyplata on twp_twpid = wpe_twpid
 join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
 where twp_wliczchor = 1 and wps_dataod>=@DataOd and wps_datado<=@DataDo and TWP_SklZUS = 2
 and WPL_Tryb<>1 and WPL_Tryb<>2 and wpl_praid=@PrcId and twp_rodzajzrodla <> 22 and B.wpe_wpeid=A.wpe_wpeid
 and LPL_Oddelegowani = 0 )),0)
 END
 IF @Dni_SklFaktWypl is null
    SET @Dni_SklFaktWypl = 0
END
SET @Dni_PodstChor = (select isnull(sum(WPE_PodstChor),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid and wps_twpid = wpe_twpid
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
   -- [JK] Zgł.170684, 279632 ddoano warunek na twp_rodzajzrodla <> 4, 288372 zminiono twp_rodzajzrodla <> 4 na WPS_RodzajZrodla <> 4
  and twp_rodzajzrodla <> 8 and WPS_RodzajZrodla <> 4
  )
  -- [JK] Zgł.279632
SET @Dni_PodstChor = @Dni_PodstChor + (select isnull(sum(WPE_PodstChor),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid and wps_twpid = wpe_twpid
  join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
  join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
  )
 IF @Dni_PodstChor is null
    SET @Dni_PodstChor = 0
SET @Dni_PodstWyp = (select isnull(sum(WPE_PodstWypad),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid and wps_twpid = wpe_twpid
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
     -- [JK] Zgł.170684, 279632 ddoano warunek na twp_rodzajzrodla <> 4, 288372 zminiono twp_rodzajzrodla <> 4 na WPS_RodzajZrodla <> 4
  and twp_rodzajzrodla <> 8 and WPS_RodzajZrodla <> 4
  )
-- [JK] Zgł.279632
  SET @Dni_PodstWyp = @Dni_PodstWyp + (select isnull(sum(WPE_PodstWypad),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid and wps_twpid = wpe_twpid
  join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
  join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
  )
 IF @Dni_PodstWyp is null
    SET @Dni_PodstWyp = 0
SET @Dni_SumaSkladek = (select isnull(sum(WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid and wps_twpid = wpe_twpid
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
     -- [JK] Zgł.170684, 279632 ddoano warunek na twp_rodzajzrodla <> 4, 288372 zminiono twp_rodzajzrodla <> 4 na WPS_RodzajZrodla <> 4
  and twp_rodzajzrodla <> 8 and WPS_RodzajZrodla <> 4
  )
-- [JK] Zgł.279632
SET @Dni_SumaSkladek = @Dni_SumaSkladek + (select isnull(sum(WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on wps_wplid = wpl_wplid and wps_twpid = wpe_twpid
  join cdn.Dodatki on WPS_ZrodloId = DOD_DodId
  join cdn.DodatkiHist on DOD_DodId = DOH_DodId and @DataU between DOH_OkresOd and DOH_OkresDo
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
     -- [JK] Zgł.170684, 279632 ddoano warunek na twp_rodzajzrodla <> 4
  and WPS_RodzajZrodla = 4 and (DOD_WliczChorWOkresie = 0 or DOD_WliczChorWOkresie = 1 and DOH_WaznyDo > @DataU)
  )
 -- [JK] Zgł.170684
SET @Dni_UmowyPodstChor = (select isnull(sum(WPE_PodstChor),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.Umowy on WPS_ZrodloId = UMW_UmwId
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
  and twp_rodzajzrodla = 8 and (UMW_DataDo > @DataU or UMW_WliczChorZakonczona = 1)
  )
 IF @Dni_UmowyPodstChor is null
    SET @Dni_UmowyPodstChor = 0
SET @Dni_UmowyPodstWyp = (select isnull(sum(WPE_PodstWypad),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.Umowy on WPS_ZrodloId = UMW_UmwId
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
  and twp_rodzajzrodla = 8 and (UMW_DataDo > @DataU or UMW_WliczChorZakonczona = 1)
  )
 IF @Dni_UmowyPodstWyp is null
    SET @Dni_UmowyPodstWyp = 0
SET @Dni_UmowySumaSkladek = (select isnull(sum(WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac),0)
  from cdn.wyplaty
  join cdn.wypelementy on wpe_wplid = wpl_wplid
  join cdn.typwyplata on twp_twpid = wpe_twpid
  join cdn.listyplac on wpl_lplid = lpl_lplid
  join cdn.wypskladniki on Wpe_wpeid = Wps_wpeid
  join cdn.Umowy on WPS_ZrodloId = UMW_UmwId
  where lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and wpl_praid=@PrcId
  and twp_rodzajzrodla = 8 and (UMW_DataDo > @DataU or UMW_WliczChorZakonczona = 1)
  )
 IF @Dni_UmowySumaSkladek is null
    SET @Dni_UmowySumaSkladek = 0
SET @Dni_PracaZ3a = (select count(distinct data) from CDN.PracCzasPracyFN (3, @PrcId, @DataOd, @DataDo) left outer JOIN  cdn.typnieobec on TypNieob = TNB_tnbId
   where
  --186940  TypDnia = 1 and
   IsNUll(TNB_typ, 0)<>2 and IsNull(TNB_PomnCzasRNA, 0)=0 and IsNull(TNB_Standardowy,0) not in (400,401,402,403,404,405,406))
SET @Dni_PlanZ3a =
(select count(distinct data) from CDN.PracCzasPracyFN (2, @PrcId, @DataOd, @DataDo)
--186940 left JOIN  cdn.typnieobec on TypNieob = TNB_tnbId
--
--186940 where TypDnia = 1 and IsNUll(TNB_typ, 0) <>2
--[JK] TFS:146580
--186940 and Norma > 0
--186940 and DATEDIFF(n,convert(datetime ,GodzOd),GodzDo)<>0
)
   insert into #Z3_Mies values (@Year, @Month, @Dni_Praca, @Dni_Plan, @Dni_PrzyczNiePr , @Dni_SklWykazywane+@Dni_UmowyWykazywane,@Dni_SklPomniejszane+@Dni_UmowyPomniejszane,@Dni_SklFaktWypl+@Dni_UmowyFaktWypl,@Dni_PodstChor+@Dni_UmowyPodstChor,@Dni_PodstWyp+@Dni_UmowyPodstWyp,@Dni_PracaZ3a,@Dni_SumaSkladek+@Dni_UmowySumaSkladek,@Dni_PlanZ3a)
 SET @MYCurrent = @MYCurrent + 1
END
SET NOCOUNT OFF
SELECT
 * FROM #Z3_Mies
