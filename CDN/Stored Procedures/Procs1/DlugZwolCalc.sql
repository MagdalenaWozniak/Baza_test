CREATE PROCEDURE CDN.DlugZwolCalc  @IdPrac INT, @Ozn Char(1), @Osoba NVarChar(71),@Kod NVarChar(22), @Okres_Od DATETIME, @Okres_Do DATETIME
AS
SET NOCOUNT ON
DECLARE @IleRec INT
DECLARE @CzyKont INT
DECLARE @PoprzCzyKont INT
DECLARE @Licz INT
DECLARE @OznEta Char(1)
DECLARE @Od DATETIME
DECLARE @Do DATETIME
DECLARE @poprzOd DATETIME
DECLARE @poprzDo DATETIME
DECLARE @DniZwol INT
SET @Licz = 1
SET @IleRec = (SELECT count(*)+1 FROM CDN.PracIdx join CDN.PracNieobec on PRI_PraId = PNB_PraId join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
WHERE PRI_Typ = 1 and TNB_PdzId = 331 and (PNB_Tryb = 0 or PNB_Tryb = 2) and PRI_PraId = @IdPrac and Pnb_OkresOd < @Okres_Od)
DECLARE Tmp_DlugZwol CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
 @IdPrac,
 @Ozn,
 @Osoba,
 @Kod,
 Pnb_OkresOd,
 Pnb_OkresDo,
 IsNull(PNB_KontynuacjaOZ,0),
 datediff(day,Pnb_OkresOd,Pnb_OkresDo)+1
 FROM CDN.PracIdx join CDN.PracNieobec on PRI_PraId = PNB_PraId join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 WHERE PRI_Typ = 1 and TNB_PdzId = 331 and (PNB_Tryb = 0 or PNB_Tryb = 2) and PRI_PraId = @IdPrac and Pnb_OkresOd <= @Okres_Od
  order by PNB_OkresOd desc
  OPEN Tmp_DlugZwol
  WHILE 1=1
 BEGIN
 IF @IleRec = 0 BREAK
 IF @IleRec = 1
    BEGIN
      FETCH NEXT FROM Tmp_DlugZwol INTO @IdPrac, @Ozn, @Osoba,@Kod, @Od, @Do, @CzyKont, @DniZwol
      IF @@FETCH_STATUS <> 0 BREAK
      INSERT INTO #DlugZwol values (@IdPrac, @Ozn, @Osoba,@Kod, @Od, @Do,@CzyKont, @DniZwol)
    END
 ELSE
 IF @IleRec > 1
    BEGIN
      SET @poprzOd = @Od
      SET @poprzDo = @Do
      SET @PoprzCzyKont = @CzyKont
    END
    BEGIN
      FETCH NEXT FROM Tmp_DlugZwol INTO @IdPrac, @Ozn, @Osoba,@Kod, @Od, @Do, @CzyKont, @DniZwol
      IF @@FETCH_STATUS <> 0 BREAK
      IF @Licz = 1
      BEGIN
      INSERT INTO #DlugZwol values (@IdPrac, @Ozn, @Osoba,@Kod, @Od, @Do,@CzyKont, @DniZwol)
      END
      ELSE
      IF @PoprzCzyKont=1 OR @Do=@poprzOd-1
         BEGIN
         INSERT INTO #DlugZwol values (@IdPrac, @Ozn, @Osoba,@Kod, @Od, @Do,@CzyKont, @DniZwol)
         END
      ELSE
      BREAK
    END
    BEGIN
      SET @Licz = @Licz + 1
    END
 END
 CLOSE Tmp_DlugZwol
 DEALLOCATE Tmp_DlugZwol
 SET NOCOUNT OFF
DECLARE @IleRec2 INT
DECLARE @Licz2 INT
SET @Licz2 = 1
SET @IleRec2 = (SELECT count(*) FROM CDN.PracIdx join CDN.PracNieobec on PRI_PraId = PNB_PraId join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
WHERE PRI_Typ = 1 and TNB_PdzId = 331 and (PNB_Tryb = 0 or PNB_Tryb = 2) and PRI_PraId = @IdPrac and Pnb_OkresOd > @Okres_Do)
DECLARE Tmp_DlugZwol2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
 @IdPrac,
 @Ozn,
 @Osoba,
 @Kod,
 Pnb_OkresOd,
 Pnb_OkresDo,
 IsNull(PNB_KontynuacjaOZ,0),
 datediff(day,Pnb_OkresOd,Pnb_OkresDo)+1
 FROM CDN.PracIdx join CDN.PracNieobec on PRI_PraId = PNB_PraId join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 WHERE PRI_Typ = 1 and TNB_PdzId = 331 and (PNB_Tryb = 0 or PNB_Tryb = 2) and PRI_PraId = @IdPrac and Pnb_OkresOd > @Okres_Do
  order by PNB_OkresOd
  OPEN Tmp_DlugZwol2
  WHILE 1=1
 BEGIN
 IF @IleRec2 = 0 BREAK
 IF @IleRec2 = 1
     BEGIN
      FETCH NEXT FROM Tmp_DlugZwol2 INTO @IdPrac, @Ozn, @Osoba,@Kod,@Od, @Do, @CzyKont, @DniZwol
      IF @@FETCH_STATUS <> 0 BREAK
      IF @CzyKont=1 OR @Od=@Okres_Do+1
         BEGIN
         INSERT INTO #DlugZwol values (@IdPrac, @Ozn, @Osoba,@Kod,@Od, @Do,@CzyKont, @DniZwol)
         END
      END
 ELSE
 IF @IleRec2 > 1
    BEGIN
      SET @poprzOd = @Od
      SET @poprzDo = @Do
    END
    BEGIN
      FETCH NEXT FROM Tmp_DlugZwol2 INTO @IdPrac, @Ozn, @Osoba,@Kod, @Od, @Do, @CzyKont, @DniZwol
      IF @@FETCH_STATUS <> 0 BREAK
      --IF @Licz2 = 1
      --   BEGIN
      --   INSERT INTO #DlugZwol values (@IdPrac, @Ozn, @Osoba, @Od, @Do,@CzyKont, @DniZwol)
      --  END
      --ELSE
      IF @CzyKont=1 OR @Od=@poprzDo+1
         BEGIN
         INSERT INTO #DlugZwol values (@IdPrac, @Ozn, @Osoba,@Kod,@Od, @Do,@CzyKont, @DniZwol)
         END
      ELSE
      BREAK
    END
    BEGIN
      SET @Licz2 = @Licz2 + 1
    END
 END
 CLOSE Tmp_DlugZwol2
 DEALLOCATE Tmp_DlugZwol2
