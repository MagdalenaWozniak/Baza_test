CREATE  PROCEDURE [CDN].[KartaCzasuPracyCalc] @DataOd datetime, @DataDo datetime, @PrcId INT, @TylkoPodsum INT
AS
SET NOCOUNT ON
-- Deklaracja zmiennych pomocniczych
declare @TempInt  INT
declare @dzien      DATETIME
declare @olddzien   DATETIME
declare @KalendId   INT
declare @Data0      DATETIME
declare @DzienWolny INT
declare @DataZatrOd DATETIME
declare @DataZatrDo DATETIME
declare @NormaTyg   DECIMAL(15,2)
declare @NormaDob   DECIMAL(15,2)
declare @NormaDobSUM   DECIMAL(15,2)
declare @NormaDobMonth DECIMAL(15,2)
declare @NocneSUM      DECIMAL(15,2)
declare @PracaSUM      DECIMAL(15,2)
declare @Nadgodz50     DECIMAL(15,2)
declare @Nadgodz100    DECIMAL(15,2)
declare @NadgodzDSW    DECIMAL(15,2)
declare @Nadgodz50SUM  DECIMAL(15,2)
declare @Nadgodz100SUM DECIMAL(15,2)
declare @NadgodzDSWSUM DECIMAL(15,2)
declare @PracaNadgodz  DECIMAL(15,2)
declare @PracaNocna    DECIMAL(15,2)
declare @PracaNocNadg  DECIMAL(15,2)
declare @RZ            INT
declare @Praca         DECIMAL(15,2)
declare @PracaPlan     DECIMAL(15,2)
declare @PracaOd       INT
declare @PracaDoN      INT
declare @Polnoc        INT
declare @PracaOdPlan   INT
declare @Mode          INT
declare @RozliczanyWg  INT
declare @UwzglWymiarEtatu        INT
declare @RozliczajNadgodziny     INT
declare @NormaWgKalendarza       INT
declare @AlgorytmBilNadgodzin    INT
declare @AlgNalNadgodzinDniWolne INT
declare @DobowyLimitNG50         INT
declare @etatl decimal(15,2)
declare @etatm decimal(15,2)
declare @Nadg_NSW100  int
declare @Nadg_Noc100  int
declare @Nadg_DWOL100 int
declare @Nadg_DOLim50 int
declare @NocOd      INT
declare @NocDo      INT
declare @NocCzas    INT
declare @NocLimit   INT
declare @temp   NVARCHAR(5)
declare @PracRodzajRozliczenia INT
declare @nadgodzinywNocy INT
declare @NormyMiesieczne table(miesiac INT, norma INT)
declare @TnbPomnCzasPracy INT
declare @strefastandard int
declare @godzinyNb int
declare @godzinyNbSum int
declare @datemin datetime
set @datemin = CONVERT(datetime,'1899.12.30',102)
--
-- Inicjalizacja zmiennych
SET @Polnoc     = 24*60
SET @Data0      = CONVERT ( DATETIME, '1899-12-30 00:00:00' , 120 )
SET @dzien      = @DataOd
SET @olddzien   = @dzien
SET @Nadgodz50  = 0
SET @Nadgodz100 = 0
SET @NadgodzDSW = 0
SET @Nadgodz50SUM  = 0
SET @Nadgodz100SUM = 0
SET @NadgodzDSWSUM = 0
SET @PracaNocna    = 0
SET @PracaNocNadg  = 0
SET @NormaDobSUM   = 0
SET @NormaDobMonth = 0
SET @godzinyNbSum  = 0
SELECT @AlgorytmBilNadgodzin     =CAST ((select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Bilansowanie' and cfw_typ=3) as INT)
SET @AlgorytmBilNadgodzin = isnull(@AlgorytmBilNadgodzin, 0)
SELECT @AlgNalNadgodzinDniWolne  =CAST ((select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Rozliczanie' and cfw_typ=3) as INT)
SET @AlgNalNadgodzinDniWolne = isnull(@AlgNalNadgodzinDniWolne, 1)
SET @temp                  =(select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Limit50' and cfw_typ=7)
SELECT @DobowyLimitNG50    =CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) *60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET @DobowyLimitNG50 = isnull (@DobowyLimitNG50, 120)
SET @temp                  = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc od')
SELECT @NocOd              =CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) *60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET @NocOd = isnull (@NocOd, 1260)
--Spiechu zapisuje datę do jako 24+godzina do któej ma być godzina nocna
SET @temp                  = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc do')
SELECT @NocDo              =CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) * 60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET @NocDo = isnull (@NocDo, 1860)
SET @temp                  = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc limit')
SELECT @NocLimit           =CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) *60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET @NocLimit = isnull (@NocLimit, 480)
SET @NocCzas = @NocDo - @NocOd
SET @Nadg_NSW100      =CAST ((select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='NiedzSwZawsze100' and cfw_typ=11) as INT)
SET @Nadg_NSW100 = isnull (@Nadg_NSW100,1)
SET @Nadg_Noc100      =CAST ((select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='NadgodzNocneZawsze100' and cfw_typ=11) as INT)
SET @Nadg_Noc100 = isnull (@Nadg_Noc100,1)
SET @Nadg_DWOL100          =CAST ((select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='DodDniWolneZawsze100' and cfw_typ=11) as INT)
SET @Nadg_DWOL100 = isnull (@Nadg_DWOL100,1)
SET @Nadg_DOLim50          =CAST ((select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='DniPrPoPrzekrLimitu50Zawsze100' and cfw_typ=11) as INT)
SET @Nadg_DOLim50 = isnull (@Nadg_DOLim50,0)
SET @PracRodzajRozliczenia      =isnull ((select pre_zestczasupracy from cdn.pracetaty where pre_praid=@PrcId and pre_dataod<=@DataOd and pre_datado>=@DataOd ),99)
SET @strefastandard = (select dst_dstid from cdn.definicjestref where dst_standardowy=1)
--
-- Sprawdzenie, czy podano @AccId lub OObId
IF @DataOd IS NULL OR @DataDo IS NULL
 BEGIN
  SET @DataOd = '1899-12-30 00:00:00'
  SET @DataDo = '1899-12-30 00:00:00'
  --RAISERROR('Wymagany parametr @PrcId, @DataOd oraz @DataDo ', 16, 1)
  --SET NOCOUNT OFF
  --RETURN
 END
--
-- Sprawdzenie, czy podano @AccId lub OObId
IF @PrcId IS NULL
 BEGIN
  SET @PrcId = 0
  --RAISERROR('Wymagany parametr @PrcId', 16, 1)
  --SET NOCOUNT OFF
  --RETURN
 END
--
-- Dodaje nieobecnosci
 WHILE @dzien<=@DataDo
 BEGIN
   SET @DzienWolny = 0
   SET @dzien = CONVERT (DATETIME,  @dzien, 120)
   SET @etatl = (select (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end)  from cdn.pracetaty where pre_praid = @PrcId and pre_dataod<=@dzien and pre_datado>=@dzien)
   SET @etatm = (select (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end)  from cdn.pracetaty where pre_praid = @PrcId and pre_dataod<=@dzien and pre_datado>=@dzien)
   IF @etatm=0 OR @etatm is null SET @etatm=1
   SET @KalendId                    =(select (case PRE_PRMPracaRodzic when 1 then PRE_PRMKalId else PRE_KalId end) from CDN.PracKod join cdn.pracetaty on pre_praid=pra_praid where pra_praid=@PrcId and @dzien between pre_dataod and pre_datado)
   SET @DataZatrOd                  =CONVERT (DATETIME,  (select pre_ZatrudnionyOd from CDN.PracKod join cdn.pracetaty on pre_praid=pra_praid where pra_praid=@PrcId and pre_dataod<=@dzien and pre_datado>=@dzien),120)
   SET @DataZatrDo                  =CONVERT (DATETIME,  (select pre_ZatrudnionyDo from CDN.PracKod join cdn.pracetaty on pre_praid=pra_praid where pra_praid=@PrcId and pre_dataod<=@dzien and pre_datado>=@dzien),120)
   SET @RozliczanyWg                =(select pre_ZestCzasuPracy from CDN.PracKod join cdn.pracetaty on pre_praid=pra_praid where pra_praid=@PrcId and pre_dataod<=@dzien and pre_datado>=@dzien)
   SELECT @UwzglWymiarEtatu         =(select kal_uwzglWymiarEtatu from cdn.kalendarze where kal_kalid=@KalendId)
   SELECT @RozliczajNadgodziny      =(select kal_nadgodzrozlicz from cdn.kalendarze where kal_kalid=@KalendId)
   SELECT @NormaWgKalendarza        =(select kal_normakalendarz from cdn.kalendarze where kal_kalid=@KalendId)
   select @godzinyNb = SUM(DATEDIFF(minute, @datemin,PNB_Godz)) from  CDN.PracNieobec join CDN.TypNieobec on PnB_TnBId = TnB_TnBId where PNB_PraId=@PrcId and @dzien between PNB_OkresOd and PNB_OkresDo and Pnb_Tryb<>1 and PnB_Calodzienna = 0 and tnb_pomnczaspracy = 1
   IF isnull(@godzinyNb,0) = 0
  SET @godzinyNb = 0
   SET @godzinyNbSum = @godzinyNbSum + @godzinyNb
   INSERT INTO #CzasPracy
       SELECT 1, @PrcId,
              YEAR(@dzien),
              MONTH(@dzien),
              DAY(@dzien),
              @dzien,
              Pnb_PnbId,
              0,DATEDIFF(minute,@datemin,PNB_Godz),0,0,0,0,0,0,0,0,0,
              -- Zwolnienie lekarskie
              CASE
                 WHEN  TNB_TnkId = 1 THEN 1
                        ELSE 0
              END as Tmp_NBZwolLek,
              -- Urlop macierzyński
              CASE
                 WHEN TNB_TnkId = 2 THEN 1
                 ELSE 0
              END as Tmp_NBUrlMac,
              -- Urlop rehabilitacyjny
              CASE
                 WHEN TNB_TnkId = 3 THEN 1
                 ELSE 0
              END as Tmp_NBUrlReh,
              -- Urlop okolicznociowy
              CASE
                 WHEN (TNB_TnkId = 4 OR TNB_TnkId = 21)  THEN 1 -- SB 2021 [12263] --
                 ELSE 0
              END Tmp_NBUrlopyOk,
              -- Nieobecność nieusprawiedliwion
              CASE
                 WHEN TNB_TnkId = 5 THEN 1
                 ELSE 0
              END as Tmp_NBNN,
              -- Zwolnienie opieka
              CASE
                 WHEN TNB_TnkId = 6 THEN 1
                 ELSE 0
              END as Tmp_NBZwolOpieka,
              -- Urlop wychowawczy
              CASE
                 WHEN TNB_TnkId = 7 THEN 1
                 ELSE 0
              END as Tmp_NBUrlWych,
              -- Urlop bezpłatny
              CASE
                 WHEN TNB_TnkId = 8 THEN 1
                 ELSE 0
              END as Tmp_NBUrlBezp,
              -- Nieobecności inne
              CASE
                 WHEN TNB_TnkId = 9 THEN 1
                 ELSE 0
              END as Tmp_NBInne,
              -- Sluzba wojskowa
              CASE
                 WHEN TNB_TnkId = 10 THEN 1
                 ELSE 0
              END as Tmp_NBSW,
              -- Urlop wypoczynkowy
              CASE
                 WHEN TNB_TnkId = 11 THEN 1
                 ELSE 0
              END as Tmp_NBUrlopyWyp,
              -- Niepomniejszajaca czasu pracy
              CASE
                 WHEN TNB_TnkId = 12 THEN 1
                 ELSE 0
              END as Tmp_NBNiePomn,
              -- Nieobecnosc wlasna 1
              CASE
                 WHEN TNB_TnkId = 13 THEN 1
                 ELSE 0
              END as Tmp_NBWlasna1,
              -- Nieobecnosc wlasna 2
              CASE
                 WHEN TNB_TnkId = 14 THEN 1
                 ELSE 0
              END as Tmp_NBWlasna2,
              -- Nieobecnosc wlasna 3
              CASE
                 WHEN TNB_TnkId = 15 THEN 1
                 ELSE 0
              END as Tmp_NBWlasna3,
              -- Nieobecnosc wlasna 4
              CASE
                 WHEN TNB_TnkId = 16 THEN 1
                 ELSE 0
              END as Tmp_NBWlasna4,
              -- Nieobecnosc wlasna 5
              CASE
                 WHEN TNB_TnkId = 17 THEN 1
                 ELSE 0
              END as Tmp_NBWlasna5,
              -- Nieobecnosc wlasna 6
              CASE
                 WHEN TNB_TnkId = 18 THEN 1
                 ELSE 0
              END as Tmp_NBWlasna6,
              -- Nieobecnosc wlasna 7
              CASE
                 WHEN TNB_TnkId = 19 THEN 1
                 ELSE 0
              END as Tmp_NBWlasna7,
              -- Nieobecnosc wlasna 8
              CASE
                 WHEN TNB_TnkId = 20 THEN 1
                 ELSE 0
              END as Tmp_NBWlasna8,
     -- Urlop opiekunczy -- SB 2021 [12263] --
              CASE
                 WHEN TNB_TnkId = 21 THEN 1
                 ELSE 0
              END as Tmp_NBUrlOp,
     TNK_TNKID,TNK_Nazwa,0
            FROM CDN.PracNieobec JOIN CDN.TypNieobec ON Pnb_TnbId = Tnb_TnbId
  JOIN CDN.TypNieobecKartaPracy ON TNB_TnkId = TNK_TnkId
            WHERE pnb_praid=@PrcId and PNB_Tryb<>1 and @dzien>= pnb_okresod AND @dzien<=pnb_okresdo
   and PNB_PracaRodzic <> 1
    --Sprawdzam, czy w danym dniu jest nieobecność a jeżeli tak to czy zaliczać ją do czasu pracy
    SET @TnbPomnCzasPracy = (
        select tnb_pomnczaspracy from cdn.typnieobec
        where tnb_tnbid=
              (
                   select isnull(pnb_tnbid,0) from cdn.pracnieobec
                    where PNB_Tryb<>1 and pnb_calodzienna = 1 and  PNB_PracaRodzic <> 1 and pnb_pnbid = (select max(TMP_PNBID) from #CzasPracy where Tmp_Data = @Dzien And Tmp_Typ=1)
              )
     )
            set @Praca = 0
            set @PracaOd = 0
            --Norma tygodniowa i dobowa
            SELECT @NormaDob=0
            SELECT @NormaTyg=0
            IF @DataZatrOd<=@dzien AND @DataZatrDo>=@dzien
            BEGIN
                IF EXISTS (SELECT 1 from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where ppl_praid=@PrcId and ppl_data=@dzien)
                BEGIN
                    EXEC @NormaDob=CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 2, 0, 1, 1
                END
                ELSE
                BEGIN
                    IF NOT EXISTS (SELECT 1 from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId where kad_kalid=@KalendId and kad_data=@dzien)
                    BEGIN
                        exec @DzienWolny = CDN.CzyDzienWolny @dzien
                        IF @DzienWolny=0  -- poza dniami wolnymi oraz poza sobotą i nedzielą
                        BEGIN
                               SELECT @NormaDob=DATEDIFF(minute, @Data0, CONVERT(DATETIME, (SELECT kal_normadobowa from cdn.kalendarze where kal_kalid=@KalendId),120))
                               SELECT @NormaTyg=DATEDIFF(minute, @Data0, CONVERT(DATETIME, (SELECT kal_normatygodniowa from cdn.kalendarze where kal_kalid=@KalendId ),120))
                               IF @NormaWgKalendarza=1 OR @RozliczajNadgodziny=0
                               BEGIN
                                  SET @NormaDob = 480
                                  SET @NormaTyg = 2460
                               END
                        END
                        IF @UwzglWymiarEtatu=1 BEGIN
                               SET @NormaDob = CEILING ((@NormaDob * CONVERT(real,@etatl))/@Etatm)
                               SET @NormaTyg = CEILING ((@NormaTyg * CONVERT(real,@etatl))/@Etatm)
                        END
                        SET @NormaDob = @NormaDob - @godzinyNb
                        --
                        -- Dodaję podstawową strefę, której może nie być w pozycjach kalendarzy ale musi być na wydruku jako podstawowa - przynajmniej jedna
                        --
                        IF NOT EXISTS (SELECT 1 FROM #CzasPracy WHERE Tmp_Typ=3 AND Tmp_DstId=@strefastandard and Tmp_Data=@dzien)
       IF @RozliczanyWg = 1
                         BEGIN
                         INSERT INTO #CzasPracy values (
                              3, @PrcId,null,null,null,@dzien,null,0,@NormaDob,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,@strefastandard)-- SB 2021 [12263] --
                         END
          ELSE
                         BEGIN
        SET @TempInt = @NormaDob - @godzinyNb
                          IF @TnbPomnCzasPracy = 1 or @TempInt < 0
                             SET @TempInt = 0
                          INSERT INTO #CzasPracy values (
                              3, @PrcId,null,null,null,@dzien,null,0,@NormaDob,0,0,0,0,@TempInt,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,@strefastandard)-- SB 2021 [12263] --
                         END
                        --
                    END
                    ELSE
                    BEGIN
--[JK] TFS:148837         SET @DzienWolny = (SELECT kad_typdnia from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId where kad_kalid=@KalendId and kad_data=@dzien)-1
                          SET @DzienWolny = (SELECT kad_typdnia from cdn.KalendDni where kad_kalid=@KalendId and kad_data=@dzien)-1
                          IF @UwzglWymiarEtatu=1
                              EXEC @NormaDob = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 1, 0, @etatl, @etatm
                          ELSE
                              EXEC @NormaDob = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 1, 0, 1, 1
                          SELECT @NormaTyg=DATEDIFF(minute, @Data0, CONVERT(DATETIME, (SELECT kal_normatygodniowa from cdn.kalendarze where kal_kalid=@KalendId ),120))
                          SET @NormaDob = ISNULL(@NormaDob, 0)
                          SET @NormaTyg = ISNULL(@NormaTyg, 0)
                          IF @UwzglWymiarEtatu=1 BEGIN
                            SET @NormaTyg = CEILING ((@NormaTyg *  CONVERT(real,@etatl))/@Etatm)
                          END
                    END
                END
    END
   SET @NormaDobSUM    = @NormaDobSUM + @NormaDob
   SET @NormaDobMonth  = @NormaDobMonth + @NormaDob
   --******************
   --Plan pracy
   --******************
   SET @PracaPlan = 0
   IF @dzien >=@DataZatrOd and @dzien <=@DataZatrDo
   BEGIN
    --Ponieważ okres od którego liczymy nie koniecznie musi pokrywać się z okresem zatrudnienia
    --należy w pierwszym dniu zatrudnienia sprawdzić rodzaj rozliczenia
         if @PracRodzajRozliczenia=99
            SET @PracRodzajRozliczenia      = (select pre_zestczasupracy from cdn.pracetaty where pre_praid=@PrcId and pre_dataod<=@dzien and pre_datado>=@DataOd and pre_zatrudnionyod<=@dzien and (pre_zatrudnionydo is null or pre_zatrudnionydo>=@DataOd))
         IF EXISTS (SELECT 1 from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where ppl_praid=@PrcId and ppl_data=@dzien )
         BEGIN
             EXEC @PracaPlan = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 2, 0, 1, 1
             SET @NormaDob = @PracaPlan
             select @PracaOd=DATEDIFF(minute, @Data0, CONVERT(DATETIME, PGL_OdGodziny,120)) from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where ppl_praid=@PrcId and ppl_data=@dzien
             SET @PracaOdPlan=@PracaOd
         END
         ELSE
         BEGIN
             IF @DzienWolny=0 AND NOT EXISTS
                    (SELECT 1 from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId where kad_kalid=@KalendId and
                         kad_data=@dzien  and kad_typdnia =1)
             BEGIN
                SELECT @PracaOd=DATEDIFF(minute, @Data0, CONVERT (DATETIME,  '1899-12-30 07:00:000',120))
                select @PracaOdPlan=@PracaOd
                if @UwzglWymiarEtatu=1
                   SET @PracaPlan = CEILING ((@PracaPlan *  CONVERT(real,@Etatl))/@Etatm)
                IF @NormaWgKalendarza=1
                BEGIN
                 SET @PracaPlan = @NormaDob
                END
             END ELSE BEGIN
               IF @UwzglWymiarEtatu=1
                   EXEC @PracaPlan = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 1, 0, @etatl, @etatm
               ELSE
                   EXEC @PracaPlan = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 1, 0, 1, 1
--[JK] TFS:148837  SELECT @PracaOd=DATEDIFF(minute, @Data0, CONVERT (DATETIME,  (SELECT KDG_OdGodziny from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId where kad_kalid=@KalendId and kad_data=@dzien),120))
               SELECT @PracaOd=DATEDIFF(minute, @Data0, CONVERT (DATETIME,  (SELECT min(KDG_OdGodziny) from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId where kad_kalid=@KalendId and kad_data=@dzien),120))
               if @UwzglWymiarEtatu=1
                   SET @PracaPlan = CEILING ((@PracaPlan *  CONVERT(real,@Etatl))/@Etatm)
             END
             select @PracaOdPlan=@PracaOd
         END
         IF @RozliczanyWg=0  -- Rozliczanie wg. kalendarza
         BEGIN
            IF EXISTS (SELECT 1 from cdn.PracPracaDni join cdn.pracpracadnigodz on PPR_PprId = PGR_PprId where ppr_praid=@PrcId and ppr_data=@dzien)
            BEGIN
               EXEC @Praca = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 3, 0, 1, 1
 select @PracaOd=DATEDIFF(minute, @Data0, CONVERT(DATETIME, PGR_OdGodziny,120)) from cdn.PracPracaDni join cdn.pracpracadnigodz on PPR_PprId = PGR_PprId where ppr_praid=@PrcId and ppr_data=@dzien
            END
            ELSE
            BEGIN
               IF EXISTS (SELECT 1 from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where ppl_praid=@PrcId and ppl_data=@dzien )
               BEGIN
                  EXEC @Praca = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 2, 0, 1, 1
      --set  @Praca =  @NormaDob - @godzinyNb
                  select @PracaOd=DATEDIFF(minute, @Data0, CONVERT(DATETIME, PGL_OdGodziny,120)) from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where ppl_praid=@PrcId and ppl_data=@dzien
               END
               ELSE
               BEGIN
                 IF @DzienWolny=0 AND NOT EXISTS (SELECT 1 from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId where kad_kalid=@KalendId and kad_data=@dzien  and kad_typdnia in (2,3))
                 BEGIN
                    select @Praca=DATEDIFF(minute, @Data0, CONVERT (DATETIME,  (SELECT kal_normadobowa from cdn.kalendarze where kal_kalid=@KalendId),120))
                    if @UwzglWymiarEtatu=1
                      SET @Praca = CEILING ((@Praca *CONVERT(real,@Etatl))/@Etatm)
                    IF @NormaWgKalendarza=1 OR @RozliczajNadgodziny=0
                    BEGIN
                       SET @Praca = @NormaDob
                    END
-- KB rozliczenie przy wylaczonym checku "Norma wg kalendarza"
                    IF @NormaWgKalendarza=0
--[JK] TFS: 11393
     and EXISTS (SELECT 1 from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId where kad_kalid=@KalendId and kad_data=@dzien and kad_typdnia =1)
                    BEGIN
                     IF @UwzglWymiarEtatu=1
                        EXEC @Praca = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 1, 0, @etatl, @etatm
                     ELSE
                        EXEC @Praca = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 1, 0, 1, 1
                    END
-- KB
    -- set  @Praca =    @NormaDob - @godzinyNb
                    IF @TnbPomnCzasPracy=1
                       SET @Praca = 0
                 END
                 ELSE
                 BEGIN
                     IF @UwzglWymiarEtatu=1
                        EXEC @Praca = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 1, 0, @etatl, @etatm
                     ELSE
                        EXEC @Praca = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 1, 0, 1, 1
      END
              END
           END
         END
         ELSE IF @RozliczanyWg=1  -- Rozliczanie wg. obecności
         BEGIN
           IF EXISTS (SELECT 1 from cdn.PracPracaDni join cdn.pracpracadnigodz on PPR_PprId = PGR_PprId where ppr_praid=@PrcId and ppr_data=@dzien)
           BEGIN
             EXEC @Praca = CDN.PodajCzasPracyDzien @dzien, @KalendId, @PrcId, 3, 0, 1, 1
             select @PracaOd=DATEDIFF(minute, @Data0, CONVERT(DATETIME, PGR_OdGodziny,120)) from cdn.PracPracaDni join cdn.pracpracadnigodz on PPR_PprId = PGR_PprId where ppr_praid=@PrcId and ppr_data=@dzien
           END
         END
            -- Praca nocna
         SET @PracaNocna = 0
         SET @PracaNocNadg = 0
-- KB
 If not exists (select * FROM CDN.PracNieobec JOIN CDN.TypNieobec ON Pnb_TnbId = Tnb_TnbId
   JOIN CDN.TypNieobecKartaPracy ON TNB_TnkId = TNK_TnkId WHERE PNB_Tryb<>1 and pnb_praid=@PrcId and @dzien>= pnb_okresod AND @dzien<=pnb_okresdo)
         IF @PracaOd>=@NocOd
         BEGIN
            IF @PracaOd+@Praca>=@NocOd and @PracaOd+@Praca<=@NocDo
               SET @PracaNocna = @Praca
              ELSE
               SET @PracaNocna=@NocDo-@PracaOd
         END
         ELSE
         BEGIN
               --Przypadek kiedy zaczyna pracę wcześniej ale zachodzi na godziny nocne
            IF @PracaOd<@NocOd and @PracaOd+@Praca > @NocOd
            BEGIN
              IF  @PracaOd+@Praca<=@NocDo
                 SET @PracaNocna = (@PracaOd+@Praca)-@NocOd
              ELSE
                 SET @PracaNocna = @NocDo-@NocOd
            END
            ELSE
            BEGIN
              IF @PracaOd<=(@NocDo-@Polnoc)and @Praca>0
                 SET @PracaNocna=(@NocDo-@Polnoc)-@PracaOd
              IF @PracaNocna>@Praca
                 SET @PracaNocna = @Praca
            END
         END
         SET @PracaPlan = ISNULL(@PracaPlan,0)
         SET @Praca     = ISNULL(@Praca,0)
   END
   IF @RozliczajNadgodziny=1
   BEGIN
        -- Obliczam nadgodziny na dzień
        IF @DzienWolny is null
           exec @DzienWolny = CDN.CzyDzienWolny @dzien
        set @Nadgodz50  = 0
        set @Nadgodz100 = 0
        set @NadgodzDSW = 0
 -- wyjątek w kalendarzu pracownika - ustawiony dzień jako święto
 BEGIN
         IF EXISTS (SELECT 1 from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where ppl_praid=@PrcId and ppl_data=@dzien)
  BEGIN
--[JK] TFS:148837 If (SELECT ppl_typDnia from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where ppl_praid=@PrcId and ppl_data=@dzien) = 3
                 If (SELECT ppl_typDnia from cdn.PracPlanDni where ppl_praid=@PrcId and ppl_data=@dzien) = 3
   SET @DzienWolny = 3
  END
 END
        IF @Praca>@PracaPlan
        BEGIN
             SET @PracaNadgodz = @Praca-@NormaDob
             --Obliczam ile jest nadgodzin nocnych
             IF @PracaOd+@NormaDob>=@NocOd AND @PracaOd+@Praca<=@NocDo
                SET @PracaNocNadg = (@PracaOd+@Praca)-(@PracaOd+@NormaDob)
             ELSE IF @PracaOd+@NormaDob>=@NocOd AND @PracaOd+@Praca>=@NocDo
                SET @PracaNocNadg = @NocDo-(@PracaOd+@NormaDob)
             ELSE IF @PracaOd+@NormaDob<=@NocOd AND @PracaOd+@Praca>=@NocDo
                SET @PracaNocNadg = @NocCzas
             ELSE IF @PracaOd+@NormaDob<=@NocOd AND @PracaOd+@Praca>=@NocOd
                SET @PracaNocNadg = @PracaOd+@Praca-@NocOd
             IF @PracaNocNadg > @NocLimit
                SET @PracaNocNadg = @NocLimit
             --IF @PracaOd<=@NocOd AND @PracaOd+@Praca>@NocOd
                IF @DzienWolny=0
                BEGIN
                   IF @PracaNadgodz>@DobowyLimitNG50 AND @Nadg_DOLim50=1
                   BEGIN
                     SET @Nadgodz50  = @DobowyLimitNG50
                     IF @PracaNadgodz>@DobowyLimitNG50
                        SET @Nadgodz100 = @PracaNadgodz-@DobowyLimitNG50
                     ELSE
                       SET @Nadgodz100 = @DobowyLimitNG50-@PracaNadgodz
                   END
                   ELSE
                   BEGIN
                       SET @Nadgodz50  = @PracaNadgodz
                       IF @PracaNocNadg>0  --Nadgodziny w nocy
                       BEGIN
                         if @Nadg_Noc100=1
                         BEGIN
                            SET @Nadgodz50 = @Nadgodz50 - @PracaNocNadg
                            SET @Nadgodz100 = @Nadgodz100 + @PracaNocNadg
                         END
                       END
                   END
                END
                ELSE
                BEGIN
                   IF @DzienWolny=1
                   BEGIN
                     IF @Nadg_DWOL100=1 --Dodatkowe dni wolne
                       SET @Nadgodz100 = @PracaNadgodz
                     ELSE
                       IF @PracaNadgodz>@DobowyLimitNG50 AND @Nadg_DOLim50=1
                       BEGIN
                          SET @Nadgodz50  = @DobowyLimitNG50
                          IF @PracaNadgodz>@DobowyLimitNG50
                             SET @Nadgodz100 = @PracaNadgodz-@DobowyLimitNG50
                          ELSE
                             SET @Nadgodz100 = @DobowyLimitNG50-@PracaNadgodz
                       END
                       ELSE
                       BEGIN
                          SET @Nadgodz50  = @PracaNadgodz
                          IF @PracaNocNadg>0  --Nadgodziny w nocy
                          BEGIN
                            if @Nadg_Noc100=1
                            BEGIN
                               SET @Nadgodz50 = @Nadgodz50 - @PracaNocNadg
                               SET @Nadgodz100 = @Nadgodz100 + @PracaNocNadg
                            END
                          END
                       END
                   END
                   ELSE
                   BEGIN
                                    --Niedziele i święta
                      IF @Nadg_NSW100=1
                         SET @Nadgodz100 = @PracaNadgodz
                      ELSE
                         SET @Nadgodz50 = @PracaNadgodz
                      --SET @NadgodzDSW = @PracaNadgodz
                   END
               END
             END
             SET @Nadgodz50SUM = @Nadgodz50SUM + @Nadgodz50
             SET @Nadgodz100SUM = @Nadgodz100SUM + @Nadgodz100
             SET @NadgodzDSWSUM = @NadgodzDSWSUM + @NadgodzDSW
        END
        if @PracRodzajRozliczenia<>2 AND @PracRodzajRozliczenia<>99   --Nie według zestawienia
        BEGIN
          --
          -- Jeśli jest już rekord to albo obecność albo nieobecność to nie idę dalej
          SET @Mode  = 1  --Insert do #CzasPracy
          IF NOT EXISTS (SELECT 1 from #CzasPracy where Tmp_Data=@dzien and Tmp_Typ=1) or EXISTS (SELECT 1 from #CzasPracy join CDN.PracNieobec on PNB_PnBId = TMP_PNBID where Tmp_Data=@dzien and PNB_Calodzienna = 0 )
          BEGIN
           IF @Mode=1
            INSERT INTO #CzasPracy
              SELECT 1, @PrcId,
                     YEAR(@dzien),
                     MONTH(@dzien),
                     DAY(@dzien),
                     @dzien,
                     NULL,
                     @NormaTyg,
                     @NormaDob,
                     @Nadgodz50,@Nadgodz100,@NadgodzDSW,@PracaNocna,@Praca,0,@PracaPlan,@PracaOd,
                     @PracaOdPlan,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,0 -- SB 2021 [12263] --
          END
          ELSE
          BEGIN
            if @TnbPomnCzasPracy=0
            BEGIN
             UPDATE #CzasPracy
               SET Tmp_NormaTyg   = @NormaTyg,
                   Tmp_NormaDob   = @NormaDob,
                   Tmp_Nadgodz50  = @Nadgodz50,
                   Tmp_Nadgodz100 = @Nadgodz100,
                   Tmp_NadgodzDS  = @NadgodzDSW,
                   Tmp_GodzNocne  = @PracaNocna,
                   Tmp_Praca      = @Praca,
                   Tmp_OdGodz     = @PracaOd,
                   Tmp_PracaPlan  = @PracaPlan,
                   Tmp_OdGodzPlan = @PracaOdPlan
               WHERE Tmp_Data = @dzien And Tmp_Typ=1
            END
            ELSE
            BEGIN
             UPDATE #CzasPracy
               SET Tmp_NormaTyg   = @NormaTyg,
                   Tmp_NormaDob   = @NormaDob,
                   Tmp_Nadgodz50  = @Nadgodz50,
                   Tmp_Nadgodz100 = @Nadgodz100,
                   Tmp_NadgodzDS  = @NadgodzDSW,
                   Tmp_GodzNocne  = @PracaNocna
               WHERE Tmp_Data = @dzien And Tmp_Typ=1
            END
          END
   END
   IF @RozliczanyWg=2 and @TnbPomnCzasPracy = 1 -- Rozliczanie wg.zestawienia
       BEGIN
          UPDATE #CzasPracy
               SET
                 Tmp_NormaDob   = @NormaDob
                 WHERE Tmp_Data = @dzien And Tmp_Typ= 1
       END
   SET @dzien = @dzien  + 1
   IF DATEPART (month, @olddzien) <> DATEPART (month, @dzien)
   BEGIN
      insert into @NormyMiesieczne values (DATEPART (month, @olddzien), @NormaDobMonth )
      SET @NormaDobMonth = 0
   END
   SET @olddzien = @dzien
 END
--***********************************************************************************
--***********************************************************************************
 IF @PracRodzajRozliczenia<>2
 BEGIN
  DECLARE @S1  INT
  DECLARE @S2  INT
  DECLARE @S3  INT
  DECLARE @S4  INT
  DECLARE @S5  INT
  DECLARE @S6  INT
  DECLARE @S7  INT
  DECLARE @S8  INT
  DECLARE @S9  INT
  DECLARE @S10 INT
  DECLARE @S11 INT
  DECLARE @S12 INT
  DECLARE @S13 INT
  DECLARE @S14 INT
  DECLARE @S15 INT
  DECLARE @S16 INT
  DECLARE @S17 INT
  DECLARE @S18 INT
  DECLARE @S19 INT
  DECLARE @S20 INT
  DECLARE @S21 INT -- SB 2021 [12263] --
  DECLARE @Snazwa NVARCHAR(400)
 -- Jeden przebieg po tabeli w celu zbilansowania nadgodzin
  declare @stannadgodzin INT
  declare @PNBID         INT
  SET @Nadgodz50  = 0
  SET @Nadgodz100 = 0
  SET @NadgodzDSW = 0
  SET @stannadgodzin = 0
  DECLARE Tmp_SumaGN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  Tmp_NormaDob, Tmp_Praca, Tmp_Data, Tmp_PNBID
  FROM #CzasPracy WHERE Tmp_Typ = 1
  OPEN Tmp_SumaGN
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_SumaGN INTO @NormaDob ,@Praca, @dzien, @PNBID
      IF @@FETCH_STATUS <> 0 BREAK
       SET @PNBID = ISNULL(@PNBID, 0)
      IF @PNBID=0 AND @Praca-@NormaDob<0
         SET @stannadgodzin = @stannadgodzin + @Praca-@NormaDob
      IF @PNBID=0 AND @stannadgodzin<0  BEGIN
        -- @AlgorytmBilNadgodzin
        -- 0-brak , 1-100,SW,50 , 2-100,50
        IF @AlgorytmBilNadgodzin=2 BEGIN
           IF @Nadgodz100SUM>=ABS(@stannadgodzin) BEGIN
             SET @Nadgodz100SUM = @Nadgodz100SUM-ABS(@stannadgodzin)
             SET @stannadgodzin = 0
           END ELSE BEGIN
             SET @stannadgodzin = @stannadgodzin+ABS(@Nadgodz100SUM)
      SET @Nadgodz100SUM    = 0
           END
           IF @stannadgodzin<0
           BEGIN
            IF @Nadgodz50SUM>=ABS(@stannadgodzin) BEGIN
              SET @Nadgodz50SUM = @Nadgodz50SUM-ABS(@stannadgodzin)
              SET @stannadgodzin = 0
            END ELSE BEGIN
                     SET @stannadgodzin = @stannadgodzin+ABS(@Nadgodz50SUM)
       SET @Nadgodz50SUM  = 0
            END
           END
        END ELSE IF @AlgorytmBilNadgodzin=1 BEGIN
           IF @Nadgodz100SUM>=ABS(@stannadgodzin) BEGIN
             SET @Nadgodz100SUM = @Nadgodz100SUM-ABS(@stannadgodzin)
             SET @stannadgodzin = 0
           END ELSE BEGIN
             SET @stannadgodzin = @stannadgodzin+ABS(@Nadgodz100SUM)
      SET @Nadgodz100SUM    = 0
           END
           IF @stannadgodzin<0
           BEGIN
            IF @NadgodzDSWSUM>=ABS(@stannadgodzin) BEGIN
              SET @NadgodzDSWSUM = @NadgodzDSWSUM-ABS(@stannadgodzin)
              SET @stannadgodzin = 0
            END ELSE BEGIN
              SET @stannadgodzin = @stannadgodzin+ABS(@NadgodzDSWSUM)
       SET @NadgodzDSWSUM    = 0
            END
           END
           IF @stannadgodzin<0
           BEGIN
            IF @Nadgodz50SUM>=ABS(@stannadgodzin) BEGIN
              SET @Nadgodz50SUM = @Nadgodz50SUM-ABS(@stannadgodzin)
              SET @stannadgodzin = 0
            END ELSE BEGIN
              SET @stannadgodzin = @stannadgodzin+ABS(@Nadgodz50SUM)
       SET @Nadgodz50SUM    = 0
            END
           END
        END
      END
  END
  CLOSE Tmp_SumaGN
  DEALLOCATE Tmp_SumaGN
 END
 ELSE IF @PracRodzajRozliczenia=2
 BEGIN
    SET @dzien = @dzien - 1
    SET @TylkoPodsum=1
    INSERT INTO #CzasPracy
       SELECT 1, @PrcId,
              YEAR(@dzien),
              MONTH(@dzien),
              DAY(@dzien),
              @dzien,
              null,
              0,
--             (select norma from @NormyMiesieczne where
--                   miesiac=DATEPART(month, pze_okresod)),
              0,
              0,
              0,
              0,
              DATEDIFF(minute, @Data0, CONVERT(DATETIME, pzd_czasnoc, 120)),
 Case When DST_UwzglCzasPracy=1 Then DATEDIFF(minute, @Data0, CONVERT(DATETIME, pzd_czas, 120)) Else DATEDIFF(minute, @Data0, @Data0) End,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,pzd_DstId -- SB 2021 [12263] --
       FROM CDN.PracZestawElem
 join cdn.praczestaw on pze_pzeid = pzd_pzeid
 join cdn.definicjestref on pzd_dstId = dst_dstid
       WHERE pze_praid=@PrcId and PZE_Tryb<>1 and @DataOd<= pze_okresod AND @DataDo>=pze_okresdo
    SET @Nadgodz50SUM=(SELECT SUM(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_nadgodziny50, 120))) from CDN.PracZestaw WHERE pze_praid=@PrcId and PZE_Tryb<>1 and @DataOd<= pze_okresod AND @DataDo>=pze_okresdo )
    SET @Nadgodz100SUM=(SELECT SUM(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_nadgodziny100, 120))) from CDN.PracZestaw WHERE pze_praid=@PrcId and PZE_Tryb<>1 and @DataOd<= pze_okresod AND @DataDo>=pze_okresdo)
    SET @NadgodzDSWSUM=(SELECT SUM(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_nadgodzinysw, 120))) from CDN.PracZestaw WHERE pze_praid=@PrcId and PZE_Tryb<>1 and @DataOd<= pze_okresod AND @DataDo>=pze_okresdo)
 END
--***********************************************************************************
--***********************************************************************************
  --Obliczam sumę nieobecności jako suma z tabelki tymczasowej
 IF @PracRodzajRozliczenia<>2
 BEGIN
  DECLARE Tmp_SumaNB CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
        SUM (Tmp_NormaDob),
        SUM (Tmp_GodzNocne),
        SUM (Tmp_Praca),
        SUM (Tmp_NBZwolLek),
  SUM (Tmp_NBUrlMac),
     SUM (Tmp_NBUrlReh),
     SUM (Tmp_NBUrlopyOk),
        SUM (Tmp_NBNN),
        SUM (Tmp_NBZwolOpieka),
        SUM (Tmp_NBUrlWych),
        SUM (Tmp_NBUrlBezp),
        SUM (Tmp_NBInne),
        SUM (Tmp_NBSW),
        SUM (Tmp_NBUrlopyWyp),
        SUM (Tmp_NBNiePomn),
        SUM (Tmp_NBWlasna1),
        SUM (Tmp_NBWlasna2),
        SUM (Tmp_NBWlasna3),
        SUM (Tmp_NBWlasna4),
        SUM (Tmp_NBWlasna5),
        SUM (Tmp_NBWlasna6),
        SUM (Tmp_NBWlasna7),
        SUM (Tmp_NBWlasna8),
  SUM (Tmp_NBUrlOp) -- SB 2021 [12263] --
   FROM #CzasPracy where Tmp_DstId = 0
   --GROUP BY Tmp_DstId
  OPEN Tmp_SumaNB
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_SumaNB INTO @NormaDobSUM, @NocneSUM, @PracaSUM,@S1, @S2, @S3, @S4, @S5, @S6, @S7, @S8, @S9, @S10, @S11, @S12, @S13, @S14, @S15, @S16, @S17, @S18, @S19, @S20, @S21 -- SB 2021 [12263] --
      IF @@FETCH_STATUS <> 0 BREAK
  END
  CLOSE Tmp_SumaNB
  DEALLOCATE Tmp_SumaNB
  END
  ELSE IF @PracRodzajRozliczenia=2
  BEGIN
         DELETE FROM #CzasPracy where Tmp_Typ=3
  DECLARE Tmp_SumaCP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
          SUM (Tmp_Praca), SUM (Tmp_GodzNocne)
   FROM #CzasPracy where Tmp_DstId <> 0 and Tmp_Typ=1
  OPEN Tmp_SumaCP
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_SumaCP INTO @PracaSUM, @NocneSUM
      IF @@FETCH_STATUS <> 0 BREAK
  END
  CLOSE Tmp_SumaCP
  DEALLOCATE Tmp_SumaCP
  DECLARE Tmp_SumaZwolnien CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  SUM (Tmp_NBZwolLek),
 SUM (Tmp_NBUrlMac),
 SUM (Tmp_NBUrlReh),
 SUM (Tmp_NBUrlopyOk),
        SUM (Tmp_NBNN),
 SUM (Tmp_NBZwolOpieka),
 SUM (Tmp_NBUrlWych),
 SUM (Tmp_NBUrlBezp),
        SUM (Tmp_NBInne),
 SUM (Tmp_NBSW),
 SUM (Tmp_NBUrlopyWyp),
        SUM (Tmp_NBNiePomn),
        SUM (Tmp_NBWlasna1),
        SUM (Tmp_NBWlasna2),
        SUM (Tmp_NBWlasna3),
        SUM (Tmp_NBWlasna4),
        SUM (Tmp_NBWlasna5),
        SUM (Tmp_NBWlasna6),
        SUM (Tmp_NBWlasna7),
        SUM (Tmp_NBWlasna8),
  SUM (Tmp_NBUrlOp) -- SB --
   FROM #CzasPracy where Tmp_DstId = 0 and Tmp_Typ=1
  OPEN Tmp_SumaZwolnien
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_SumaZwolnien INTO @S1, @S2, @S3, @S4, @S5, @S6, @S7, @S8, @S9, @S10, @S11, @S12, @S13, @S14, @S15, @S16, @S17, @S18, @S19, @S20, @S21 -- SB 2021 [12263] --
      IF @@FETCH_STATUS <> 0 BREAK
  END
  CLOSE Tmp_SumaZwolnien
  DEALLOCATE Tmp_SumaZwolnien
       --PK 169310  UPDATE #CzasPracy SET Tmp_Typ=3 where Tmp_Typ=1
  END
  SET @Snazwa = cdn.NieobName()
  INSERT INTO #CzasPracy
    SELECT 2, @PrcId,
       null,
       null,
       null,
       null,
       null,
       null,
       @NormaDobSUM + CASE WHEN @PracRodzajRozliczenia = 2 THEN @godzinyNbSum ELSE 0 END,
       @Nadgodz50SUM,@Nadgodz100SUM,@NadgodzDSWSUM,@NocneSUM,@PracaSUM,0,0,0,0,
       @S1, @S2, @S3, @S4, @S5, @S6, @S7, @S8, @S9, @S10, @S11, @S12, @S13, @S14, @S15, @S16, @S17, @S18, @S19, @S20, @S21, NULL, @Snazwa, 0 -- SB 2021 [12263] --
