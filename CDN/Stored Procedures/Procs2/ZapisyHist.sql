CREATE Procedure  [CDN].[ZapisyHist]
 @PrcId INT
,@DniDo INT
,@MiesDo INT
,@LataDo INT
,@UrlBezp INT
,@Wynik DATETIME OUTPUT
AS
BEGIN
DECLARE @ZatrOd1 DATETIME
DECLARE @ZatrOd2 DATETIME
DECLARE @ZatrDo1 DATETIME
DECLARE @ZatrDo2 DATETIME
DECLARE @Licznik INT
DECLARE @IleZap  INT
DECLARE @PlusDni INT
DECLARE @PlusMies INT
DECLARE @PlusLata INT
CREATE TABLE
#Zapisy (
Tmp_ZatrOd DATETIME,
Tmp_ZatrDo DATETIME
)
SET @ZatrOd1 = CONVERT(DATETIME, '2999-12-31', 120)
SET @ZatrOd2 = CONVERT(DATETIME, '2999-12-31', 120)
SET @ZatrDo1 = CONVERT(DATETIME, '2999-12-31', 120)
SET @ZatrDo2 = CONVERT(DATETIME, '2999-12-31', 120)
SET @Licznik = 0
SET @IleZap = 0
SET @PlusDni = @dnido
SET @PlusMies = @miesdo
SET @PlusLata = @latado
SET @IleZap = (SELECT COUNT(*)FROM CDN.PracEtaty
  WHERE PRE_PraId = @PrcId and
  (IsNull(PRE_ZatrudnionyOd, 0) <> 0
  OR IsNull(PRE_ZatrudnionyDo, 0) <> 0))
DECLARE Tmp_Zapisy CURSOR
LOCAL FAST_FORWARD READ_ONLY FOR
SELECT PRE_ZatrudnionyOd, PRE_ZatrudnionyDo
FROM CDN.PracEtaty
WHERE PRE_PraId = @PrcId and
  (IsNull(PRE_ZatrudnionyOd, 0) <> 0
  OR IsNull(PRE_ZatrudnionyDo, 0) <> 0)
ORDER BY PRE_DataDo
OPEN Tmp_Zapisy
WHILE 1=1
BEGIN
FETCH NEXT FROM Tmp_Zapisy INTO  @ZatrOd1, @ZatrDo1
IF @@FETCH_STATUS <> 0 BREAK
BEGIN
IF @Licznik = 0
BEGIN
SET @ZatrOd2 = @ZatrOd1
SET @ZatrDo2 = @ZatrDo1
END
IF @Licznik <> 0
BEGIN
IF (@ZatrOd1<>@ZatrOd2 OR  @ZatrDo1<>@ZatrDo2)
BEGIN
IF (@ZatrOd1=@ZatrOd2) AND @ZatrDo1<>@ZatrDo2
UPDATE #Zapisy
SET Tmp_ZatrDo = @ZatrOd1
WHERE Tmp_ZatrOd = @ZatrOd1
IF (@ZatrOd1<>@ZatrOd2)
BEGIN
INSERT INTO #Zapisy values (@ZatrOd2, @ZatrDo2)
END
SET @ZatrOd2 = @ZatrOd1
SET @ZatrDo2 = @ZatrDo1
END
END
SET @Licznik = @Licznik + 1
END
IF (@Licznik=1) AND (@IleZap=1)
INSERT INTO #Zapisy values (@ZatrOd2, @ZatrDo2)
IF (@Licznik<>1) AND (@IleZap=@Licznik)
INSERT INTO #Zapisy values (@ZatrOd2, @ZatrDo2)
END
DECLARE @ZatrOd DATETIME
DECLARE @ZatrDo DATETIME
DECLARE @Koniec INT
DECLARE @DataCheck DATETIME
DECLARE @Lata INT
DECLARE @Mies INT
DECLARE @Dni INT
DECLARE @NLata INT
DECLARE @NMies INT
DECLARE @NDni INT
SET @Koniec = 0
SET @DataCheck = CONVERT(DATETIME, '2999-12-31', 120)
DECLARE Tmp_Daty CURSOR
LOCAL FAST_FORWARD READ_ONLY FOR
SELECT DISTINCT Tmp_ZatrOd, Tmp_ZatrDo
from #Zapisy
OPEN Tmp_Daty
WHILE 1=1
BEGIN
 FETCH NEXT FROM Tmp_Daty INTO  @ZatrOd, @ZatrDo
 IF @@FETCH_STATUS <> 0 BREAK
 IF @Koniec = 1 BREAK
BEGIN
 SET @Lata = 0
 SET @Mies = 0
 SET @Dni = 0
 SET @NLata = 0
 SET @NMies = 0
 SET @NDni = 0
 SET @DataCheck = DATEADD(d, @DniDo, @ZatrOd)
 SET @DataCheck = DATEADD(m, @MiesDo, @DataCheck)
 SET @DataCheck = DATEADD(yy, @LataDo, @DataCheck)
 IF @DataCheck between @ZatrOd and @ZatrDo
 BEGIN
 IF @UrlBezp = 1
  BEGIN
  exec [CDN].[UrlopBezpN] @PrcId, @ZatrOd, @ZatrDo, @Nlata output, @Nmies  output,  @Ndni output
 SET @DniDo = @DniDo + @Ndni
 SET @MiesDo = @MiesDo + @Nmies
 SET @LataDo = @LataDo + @NLata
 SET @MiesDo = @MiesDo + @DniDo/30
 SET @DniDo = @DniDo%30
 SET @LataDo = @LataDo + @MiesDo/12
 SET @MiesDo = @MiesDo%12
 SET @DataCheck = DATEADD(d, @DniDo, @ZatrOd)
 SET @DataCheck = DATEADD(m, @MiesDo, @DataCheck)
 SET @DataCheck = DATEADD(yy, @LataDo, @DataCheck)
   END
 SET @Wynik = @DataCheck
 SET @Koniec = 1
 END
 IF @DataCheck > @ZatrDo
  BEGIN
   exec CDN.StazCalc @ZatrOd, @ZatrDo, @Lata output, @Mies output, @Dni output
   IF @UrlBezp = 1
   BEGIN
    exec [CDN].[UrlopBezpN] @PrcId, @ZatrOd, @ZatrDo, @Nlata output, @Nmies  output,  @Ndni output
    IF @Dni >= @NDni
      SET @Dni = @Dni - @NDni
    ELSE
    BEGIN
     SET @Dni = (@Dni+30) - @NDni
     IF @Mies>=1
      SET @Mies = @Mies - 1
     ELSE
     BEGIN
      SET @Mies = (@Mies + 12) - 1
      SET @Lata = @Lata -1
     END
    END
    IF @Mies >= @NMies
     SET @Mies = @Mies - @NMies
    ELSE
    BEGIN
     SET @Mies = (@Mies + 12) - @NMies
     SET @Lata = @Lata -1
    END
    SET @Lata = @Lata - @NLata
   END
   SET @DataCheck  = CONVERT(DATETIME, '2999-12-31', 120)
   IF @DniDo >= @Dni
     SET @DniDo = @DniDo - @Dni
   ELSE
   BEGIN
    SET @DniDo = (@DniDo+30) - @Dni
    IF @MiesDo>=1
     SET @MiesDo = @MiesDo - 1
    ELSE
    BEGIN
     SET @MiesDo = (@MiesDo + 12) - 1
     SET @LataDo = @LataDo -1
    END
   END
   IF @MiesDo >= @Mies
    SET @MiesDo = @MiesDo - @Mies
   ELSE
   BEGIN
    SET @MiesDo = (@MiesDo + 12) - @Mies
    SET @LataDo = @LataDo -1
   END
   SET @LataDo = @LataDo - @Lata
  END
END
END
SET @Wynik = @Wynik-1
CLOSE  Tmp_Daty
DEALLOCATE  Tmp_Daty
CLOSE  Tmp_Zapisy
DEALLOCATE  Tmp_Zapisy
END
