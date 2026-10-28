CREATE PROCEDURE CDN.Detal_EksportOpakNag
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
 DECLARE
   -- zmienne dla kursora
  @OptimaId int,
  @Nieaktywny tinyint,
  @Kod NVARCHAR(20),
  @Nazwa NVARCHAR(50),
  @DateTSSynchrNew DATETIME,
  @CzyAktualizowac INT
-- Grupa,Cena dla stanowiska detalu
SELECT @DateTSSynchrNew = GetDate()
if @CzyTaSamaBaza = 1
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
 SELECT SON_SONId as SON_OptimaId
      ,SON_Nieaktywny
      ,SON_Kod
      ,SON_Nazwa
  FROM CDN.SchematyOpakNag
WHERE SON_TS_Mod >  @DateTSSynchr
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
           @OptimaId,
           @Nieaktywny ,
           @Kod,
           @Nazwa
          IF @@FETCH_STATUS <> 0 BREAK
          exec CDN.DetalStan_AktualizujOpakNag
           @ID,
           @OptimaId,
           @Nieaktywny ,
           @Kod,
           @Nazwa,
           @DateTSSynchrNew
  SET @CzyAktualizowac =  1
END
   -- po udanym update towarow ustawiamy date
    if @CzyAktualizowac = 1
    BEGIN
    -- po udanym update towarow ustawiamy date
     UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroOpak = @DateTSSynchrNew WHERE DSKnf_StanDetalID = @ID
      UPDATE CDN.DetalStanowiska SET DSta_TS_SynchroOpak = @DateTSSynchrNew WHERE DSta_DStaId = @ID
    END
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
 SELECT SON_SONId as SON_OptimaId
      ,SON_Nieaktywny
      ,SON_Kod
      ,SON_Nazwa
      ,@DateTSSynchr
      ,@DateTSSynchrNew
  FROM CDN.SchematyOpakNag
WHERE SON_TS_Mod >  @DateTSSynchr
SET NOCOUNT OFF
