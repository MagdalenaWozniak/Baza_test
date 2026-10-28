CREATE FUNCTION cdn.CrmNieobecnoscwTerminieZadania (
@OpiekunTyp INT,
@OpiekunId  INT,
@DataOd  DATETIME,
@DataDo  DATETIME
)
  RETURNS     INT
  AS
  BEGIN
    -- funkcja sprawdza, czy operator ma urlop w zadanym czasie
    IF @OpiekunTyp < 3 OR @OpiekunTyp > 4 RETURN 0
 DECLARE @DataDo1 DATETIME
 SET @DataDo1 = DATEADD(day, -1, @DataDo)
 IF EXISTS( SELECT * FROM cdn.PracNieobec
       WHERE
      PNB_PraId = @OpiekunId
      AND (PNB_Tryb=0 OR PNB_Tryb=2)
       AND (PNB_OkresOd < @DataDo AND PNB_OkresDo > @DataOd)
   )
  RETURN 1
KONIEC:
    RETURN  0
  END
