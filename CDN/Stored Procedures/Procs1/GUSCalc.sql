CREATE PROCEDURE CDN.GUSCalc @DataOd DATETIME, @DataDo DATETIME
AS
SET NOCOUNT ON
-- Deklaracja zmiennych pomocniczych
declare @dzien DATETIME
declare @PrzLZatr         DECIMAL(15,2) -- Przeciętna liczba zatrudnionych
declare @LPrwOs           DECIMAL(15,2) -- Liczba pracowników w osobach
declare @PrzLZnsR   DECIMAL(15,2) -- Przeciętna liczba zatr. na st. robotniczych
declare @PrzLZnsNR   DECIMAL(15,2) -- Przeciętna liczba zatr. na st. nierobotniczych
declare @PrzLZUczn   DECIMAL(15,2) -- Przeciętna liczba zatr. uczniów
declare @CzPrzOg   DECIMAL(15,2)           -- Czas przepracowany ogółem
declare @CzPrzGN          DECIMAL(15,2)           -- Czas przepracowany w godzinahc nadliczbowych - w minutach
declare @CzPrzOgBDN       DECIMAL(15,2)           -- Czas przepracowany ogółem bez dni wolnych
declare @CzNPOplac        DECIMAL(15,2)           -- Czas nieprzepracowany - opłacony
declare @CzNPUrlWyp       DECIMAL(15,2)           -- Czas nieprzepracowany - urlop wypoczynkowy
declare @CzNPChor         DECIMAL(15,2)           -- Czas nieprzepracowany - Chorob.(bez godzin opłaconych przez ZUS)
declare @WPSRZ            DECIMAL(15,2)
declare @WPSCZAS          DECIMAL(15,2)   -- w minutach
declare @Data0            DATETIME
SET @Data0 = CAST ( '1899-12-30 00:00:000' AS datetime )
declare @IleDni    DECIMAL(15,2)
declare @l1               DECIMAL(15,2) -- licznik
declare @m1           DECIMAL(15,2) -- mianownik
declare @c1    DECIMAL(15,2)
-- Inicjalizacja wartości
SET @PrzLZatr     = 0
SET @PrzLZUczn    = 0
SET @IleDni       = 0
SET @PrzLZnsR     = 0
SET @PrzLZnsNR    = 0
SET @CzPrzGN      = 0
SET @CzNPOplac    = 0
--
-- Obliczam średnie na każdy dzień i sumuje do zmiennych totale
 SET @dzien = @DataOd
 WHILE @dzien<=@DataDo
 BEGIN
      SET @IleDni = @IleDni + 1
   -- Obliczenia główna pętla - część 1
      DECLARE HC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      select
      sum(case when pre_ubztyuid>=110 and pre_ubztyuid<200 and
               (pre_ubztyuid<>120 and pre_ubztyuid<>121 and pre_ubztyuid<>122 )
               then pre_etaetatl else 0 end),
      sum(case when pre_ubztyuid>=110 and pre_ubztyuid<200 and
               (pre_ubztyuid<>120 and pre_ubztyuid<>121 and pre_ubztyuid<>122 )
               then pre_etaetatm else 0 end),
      sum(case  when pre_ubztyuid=120 or pre_ubztyuid=121 or pre_ubztyuid=122 then 1 else 0 end)
      from cdn.pracidx join cdn.pracetaty on pri_praid = pre_praid
      where pri_typ = 10 and pri_dataod<@dzien and pri_datado>=@dzien
      OPEN HC
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM HC INTO @l1, @m1, @c1
      IF @@FETCH_STATUS <> 0 BREAK
             IF @m1>0
               SET @PrzLZatr = @PrzLZatr + (@l1/@m1)
             SET @PrzLZUczn = @PrzLZUczn + @c1
  END
      CLOSE HC
      DEALLOCATE HC
   -- Obliczenia główna pętla - część 2 - STanowiska robotnicze i nierobotnicze
      DECLARE HCC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      select
       sum (
            case
              when dkm_robotnicze=1 then 1 else 0
            end
           ),
       sum (
            case
              when dkm_robotnicze=1 then 0 else 1
            end
           )
      from cdn.pracidx join cdn.pracetaty on pre_praid = pri_praid left outer join cdn.danekadmod on dkm_dkmid=pre_etadkmidstanowisko
      where pri_typ = 10 and pri_dataod<@dzien and pri_datado>=@dzien and
      dkm_rodzaj=1 and pre_ubztyuid>=110 and pre_ubztyuid<200 and (pre_ubztyuid<>120 and pre_ubztyuid<>121 and pre_ubztyuid<>122)
      OPEN HCC
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM HCC INTO @l1, @m1
      IF @@FETCH_STATUS <> 0 BREAK
             SET @l1 =ISNULL(@l1, 0)
             SET @m1 =ISNULL(@m1, 0)
             SET @PrzLZnsR  = @PrzLZnsR + @l1
             SET @PrzLZnsNR = @PrzLZnsNR + @m1
  END
      CLOSE HCC
      DEALLOCATE HCC
   SET @dzien = @dzien  + 1
 END
  DECLARE Tmp_Nadgodziny CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT Wps_RodzajZrodla, DATEDIFF (minute, @Data0, Wps_OkresCzas) FROM CDN.WypSkladniki JOIN CDN.Wyplaty ON Wps_Wplid = Wpl_WplId
    WHERE Wps_RodzajZrodla in (10,11,12) and wpl_dataod>=@DataOd AND wpl_datado <=@DataDo
  OPEN Tmp_Nadgodziny
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_Nadgodziny INTO @WPSRZ, @WPSCZAS
      IF @@FETCH_STATUS <> 0 BREAK
             SET @CzPrzGN   =  @CzPrzGN + @WPSCZAS
   END
      CLOSE Tmp_Nadgodziny
      DEALLOCATE Tmp_Nadgodziny
  DECLARE Tmp_Nieobecnosci CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  DATEDIFF (minute, @Data0, Wps_OkresCzas)
           FROM CDN.WypSkladniki JOIN CDN.Wyplaty ON Wps_Wplid = Wpl_WplId join cdn.pracnieobec on Wps_PnbId = Pnb_PnbId join cdn.typnieobec on pnb_tnbid=tnb_tnbid
    WHERE wpl_dataod>=@DataOd AND wpl_datado <=@DataDo
  OPEN Tmp_Nieobecnosci
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_Nieobecnosci INTO @WPSCZAS
      IF @@FETCH_STATUS <> 0 BREAK
             SET @CzNPOplac   =  @CzNPOplac + @WPSCZAS
   END
      CLOSE Tmp_Nieobecnosci
      DEALLOCATE Tmp_Nieobecnosci
-- Obliczanie średnich z sumy
 SET @PrzLZatr  = @PrzLZatr / @IleDni
 SET @PrzLZUczn = @PrzLZUczn / @IleDni
 SET @PrzLZnsR  = @PrzLZnsR / @IleDni
 SET @PrzLZnsNR = @PrzLZnsNR / @IleDni
--SET @CzPrzGN   = @CzPrzGN / @IleDni
-- SET @CzNPOplac = @CzNPOplac / @IleDni
INSERT INTO #tblGUS
 (Tmp_PrzLZatr, Tmp_LPrwOs, Tmp_PrzLZnsR, Tmp_PrzLZnsNR, Tmp_PrzLZUczn, Tmp_CzPrzOg, Tmp_CzPrzGN, Tmp_CzPrzOgBDN, Tmp_CzNPOplac, Tmp_CzNPUrlWyp, Tmp_CzNPChor)
 VALUES (@PrzLZatr, @LPrwOs, @PrzLZnsR, @PrzLZnsNR, @PrzLZUczn, @CzPrzOg, @CzPrzGN, @CzPrzOgBDN, @CzNPOplac, @CzNPUrlWyp, @CzNPChor)
