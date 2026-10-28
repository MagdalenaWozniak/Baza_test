CREATE PROCEDURE CDN.IleDniPlanuPracy @DataOd datetime, @DataDo datetime, @PrcId INT, @Praca INT
AS
SET NOCOUNT ON
declare @DzienPraca INT
declare @DzienPracaSUM INT
declare @DzienWolny INT
-- Deklaracja zmiennych pomocniczych
declare @dzien      DATETIME
declare @olddzien   DATETIME
declare @KalendId   INT
declare @Nieobec    INT
declare @RodzajRozliczenia   INT
--
-- Inicjalizacja zmiennych
SET @DzienPracaSUM = 0
--Jeżeli parametr @Praca jest 1 to liczę przepracowane dni
--Jeżeli @Praca jest 0 to liczę tylko plan pracy
SET @dzien      = @DataOd
SET @olddzien   = @dzien
-- Sprawdzenie, czy podano @AccId lub OObId
IF @DataOd IS NULL OR @DataDo IS NULL
 BEGIN
  SET @DataOd = '1899-12-30 00:00:00'
  SET @DataDo = '1899-12-30 00:00:00'
 END
-- Sprawdzenie, czy podano @AccId lub OObId
IF @PrcId IS NULL
 BEGIN
  SET @PrcId = 0
 END
SET @RodzajRozliczenia = (select isnull(pre_zestczasupracy,99) from cdn.pracetaty where pre_praid=@PrcId and @DataDo between pre_dataod and pre_datado)
IF @RodzajRozliczenia=2 and @Praca=1
BEGIN
 SET @DzienPracaSUM = (select pze_ilosc from cdn.praczestaw where pze_praid = @PrcId and @DataDo between pze_okresod and pze_okresdo)
 return @DzienPracaSUM
END
--Sprawdzam kolejne dni w poszukiwaniu planu i pracy
 WHILE @dzien<=@DataDo
 BEGIN
   SET @DzienPraca = 0
   SET @dzien = CONVERT (DATETIME,  @dzien, 120)
    -- szukam kalendarza obowiązującego na dany dzień
    SET @KalendId                    = (select pre_kalid from CDN.PracKod join cdn.pracetaty on pre_praid=pra_praid where pra_praid=@PrcId and @dzien between pre_dataod and pre_datado and @dzien between pre_zatrudnionyod and pre_zatrudnionydo)
    IF @KalendId is not null
    BEGIN
     exec @DzienWolny = CDN.CzyDzienWolny @dzien
     IF @Praca=1
        SET @DzienPraca = (SELECT 1 from cdn.PracPracaDni where ppr_praid=@PrcId and ppr_data=@dzien)
     IF @Praca=0 or (@Praca=1 and (@DzienPraca=0 or @DzienPraca is null ))
     BEGIN
        -- sprawdzam czy w planie pracy był dzień pracy
        SET @DzienPraca = (SELECT 1 from cdn.PracPlanDni where ppl_praid=@PrcId and ppl_data=@dzien)
        IF @DzienPraca=0 or @DzienPraca is null
        BEGIN
          SET @DzienPraca=(SELECT 1 from cdn.kalenddni where kad_kalid=@KalendId and kad_data=@dzien)
          IF @DzienPraca=0 or @DzienPraca is null
          BEGIN
              IF @DzienWolny=0 -- poza dniami wolnymi oraz poza sobotą i nedzielą
              BEGIN
                 SET @DzienPracaSUM = @DzienPracaSUM + 1
                 SET @DzienPraca = 1
              END
          END
          ELSE
                    IF @DzienWolny=0
                  SET @DzienPracaSUM = @DzienPracaSUM + 1
        END
        ELSE
                 IF @DzienWolny=0
             SET @DzienPracaSUM = @DzienPracaSUM + 1
     END
     ELSE
     BEGIN
               IF @DzienWolny=0
            IF @DzienPraca=1 and @Praca=1
            SET @DzienPracaSUM = @DzienPracaSUM + 1
     END
     --Szukam nieobecności w danym dniu
     IF @Praca=1
     BEGIN
        SET @Nieobec = (select 1 from cdn.pracnieobec join cdn.typnieobec on pnb_tnbid=tnb_tnbid where pnb_praid=@PrcId and (@dzien between pnb_okresod and pnb_okresdo) and tnb_standardowy not in (100,101) and tnb_PomnCzasRNA<>0)
        --IF @DzienPraca and @Nieobec is not null
        IF @Nieobec is not null and @DzienWolny=0
          SET @DzienPracaSUM = @DzienPracaSUM - 1
     END
     ELSE
     BEGIN
        SET @Nieobec = (select 1 from cdn.pracnieobec join cdn.typnieobec on pnb_tnbid=tnb_tnbid where pnb_praid=@PrcId and (@dzien between pnb_okresod and pnb_okresdo) and tnb_standardowy in (315))
        --IF @DzienPraca and @Nieobec is not null
        IF @Nieobec is not null and @DzienWolny=0
          SET @DzienPracaSUM = @DzienPracaSUM - 1
     END
    END
    SET @dzien = @dzien  + 1
    SET @olddzien = @dzien
 END
 return @DzienPracaSUM
