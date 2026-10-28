CREATE PROCEDURE [CDN].[Detal_EksportOpakElem]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
 DECLARE
   -- zmienne dla kursora
  @DSONId int,
 @Lp int,
 @TwrOptimaId int,
 @Ilosc decimal(15, 4)
-- Grupa,Cena dla stanowiska detalu
if @CzyTaSamaBaza = 1
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
 SELECT
 SOE_SONId,
 SOE_Lp,
 SOE_TwrId,
 SOE_Ilosc
  FROM CDN.SchematyOpakNag
join CDN.SchematyOpakElem on SON_SONId = SOE_SONId
WHERE SON_TS_Mod >  @DateTSSynchr
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @DSONId,
          @Lp,
          @TwrOptimaId,
          @Ilosc
          IF @@FETCH_STATUS <> 0 BREAK
          exec CDN.Detal_EksportTwr
          @ID ,
          @DateTSSynchr ,
          @CzyTaSamaBaza,
          @TwrOptimaId
          exec CDN.DetalStan_AktualizujOpakElem
          @ID,
        @DSONId,
       @Lp,
       @TwrOptimaId,
       @Ilosc
END
   -- po udanym update towarow ustawiamy date
    CLOSE Dodawane
    DEALLOCATE Dodawane
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
 SELECT
 SOE_SONId,
 SOE_Lp,
 SOE_TwrId,
 SOE_Ilosc
  FROM CDN.SchematyOpakNag
join CDN.SchematyOpakElem on SON_SONId = SOE_SONId
join cdn.towary on SOE_TwrId = Twr_TwrId
WHERE Twr_TS_Mod >  @DateTSSynchr
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @DSONId,
          @Lp,
          @TwrOptimaId,
          @Ilosc
          IF @@FETCH_STATUS <> 0 BREAK
          exec CDN.Detal_EksportTwr
          @ID ,
          @DateTSSynchr ,
          @CzyTaSamaBaza,
          @TwrOptimaId
END
   -- po udanym update towarow ustawiamy date
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
 SELECT
 SOE_SONId,
 SOE_Lp,
 SOE_TwrId,
 SOE_Ilosc
  FROM CDN.SchematyOpakNag
join CDN.SchematyOpakElem on SON_SONId = SOE_SONId
WHERE SON_TS_Mod >  @DateTSSynchr
SET NOCOUNT OFF
