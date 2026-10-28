CREATE PROCEDURE [CDN].[Z3_MacierzynskieCalc]  @IdPrac INT, @Okres_Od DATETIME, @Okres_Do DATETIME
AS
SET NOCOUNT ON
DECLARE @IleRec INT
DECLARE @CzyKont INT
DECLARE @PoprzCzyKont INT
DECLARE @Licz INT
DECLARE @Od DATETIME
DECLARE @Do DATETIME
DECLARE @poprzOd DATETIME
DECLARE @poprzDo DATETIME
DECLARE @Nazwa NVarChar(40)
SET @Licz = 1
SET @IleRec = (SELECT count(*)+1 FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
WHERE PNB_PraId = @IdPrac and TNB_PdzId in (311, 319, 325, 327) and (PNB_Tryb = 0 or PNB_Tryb = 2) and Pnb_OkresOd < @Okres_Od)
DECLARE Tmp_Macierz CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 IsNull(PNB_KontynuacjaOZ,0),
 TNB_Nazwa
 FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 WHERE TNB_PdzId in (311, 319, 325, 327) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId = @IdPrac and Pnb_OkresOd <= @Okres_Od
  order by PNB_OkresOd desc
  OPEN Tmp_Macierz
  WHILE 1=1
 BEGIN
 IF @IleRec = 0 BREAK
 IF @IleRec = 1
    BEGIN
      FETCH NEXT FROM Tmp_Macierz INTO @IdPrac, @Od, @Do, @CzyKont, @Nazwa
      IF @@FETCH_STATUS <> 0 BREAK
      INSERT INTO #Macierz values (@IdPrac,@Od, @Do,@CzyKont, @Nazwa)
    END
 ELSE
 IF @IleRec > 1
    BEGIN
      SET @poprzOd = @Od
      SET @poprzDo = @Do
      SET @PoprzCzyKont = @CzyKont
    END
    BEGIN
      FETCH NEXT FROM Tmp_Macierz INTO @IdPrac,@Od, @Do, @CzyKont, @Nazwa
      IF @@FETCH_STATUS <> 0 BREAK
      IF @Licz = 1
      BEGIN
      INSERT INTO #Macierz values (@IdPrac, @Od, @Do,@CzyKont, @Nazwa)
      END
      ELSE
      IF @PoprzCzyKont=1 OR @Do=@poprzOd-1
         BEGIN
         INSERT INTO #Macierz values (@IdPrac, @Od, @Do,@CzyKont, @Nazwa)
         END
      ELSE
      BREAK
    END
    BEGIN
      SET @Licz = @Licz + 1
    END
 END
 CLOSE Tmp_Macierz
 DEALLOCATE Tmp_Macierz
 SET NOCOUNT OFF
DECLARE @IleRec2 INT
DECLARE @Licz2 INT
SET @poprzDo = @Okres_Do
SET @Licz2 = 1
SET @IleRec2 = (SELECT count(*) FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
WHERE TNB_PdzId in (311, 319, 325, 327) and (PNB_Tryb = 0 or PNB_Tryb = 2) and Pnb_PraId = @IdPrac and Pnb_OkresOd > @Okres_Do)
DECLARE Tmp_Macierz2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 IsNull(PNB_KontynuacjaOZ,0),
 TNB_Nazwa
 FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 WHERE TNB_PdzId in (311, 319, 325, 327) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId = @IdPrac and Pnb_OkresOd > @Okres_Do
  order by PNB_OkresOd
  OPEN Tmp_Macierz2
  WHILE 1=1
 BEGIN
 IF @IleRec2 = 0 BREAK
 IF @IleRec2 = 1
     BEGIN
      FETCH NEXT FROM Tmp_Macierz2 INTO @IdPrac, @Od, @Do, @CzyKont, @Nazwa
      IF @@FETCH_STATUS <> 0 BREAK
      IF @CzyKont=1 OR @Od=@Okres_Do+1
         BEGIN
         INSERT INTO #Macierz values (@IdPrac,@Od, @Do,@CzyKont, @Nazwa)
         END
      END
 ELSE
 IF @IleRec2 > 1
/*
    BEGIN
      SET @poprzOd = @Od
      SET @poprzDo = @Do
    END
*/
    BEGIN
      FETCH NEXT FROM Tmp_Macierz2 INTO @IdPrac,  @Od, @Do, @CzyKont, @Nazwa
      IF @@FETCH_STATUS <> 0 BREAK
      --IF @Licz2 = 1
      --   BEGIN
      --   INSERT INTO #Macierz values (@IdPrac, @Ozn, @Osoba, @Od, @Do,@CzyKont, @Nazwa)
      --  END
      --ELSE
      IF @CzyKont=1 OR @Od=@poprzDo+1
         BEGIN
         INSERT INTO #Macierz values (@IdPrac, @Od, @Do,@CzyKont, @Nazwa)
         END
      ELSE
      BREAK
    END
    BEGIN
      SET @Licz2 = @Licz2 + 1
      SET @poprzOd = @Od
      SET @poprzDo = @Do
    END
 END
 CLOSE Tmp_Macierz2
 DEALLOCATE Tmp_Macierz2
