CREATE PROCEDURE CDN.StanRobotCalc  @PrcId INT, @Ozn Char(1), @Osoba NVARCHAR(71),@Akronim NVARCHAR(20),@DataOd DATETIME, @DataDo DATETIME
AS
SET NOCOUNT ON
DECLARE @Kod INT
DECLARE @IleRec INT
DECLARE @CzyRob INT
DECLARE @PoprzCzyRob INT
DECLARE @Licz INT
DECLARE @Nazwa NVARCHAR(127)
DECLARE @OznEta Char(1)
DECLARE @PoprzNazwa NVARCHAR(127)
DECLARE @Prac NVARCHAR(71)
DECLARE @Od DATETIME
DECLARE @Do DATETIME
DECLARE @poprzOd DATETIME
DECLARE @poprzDo DATETIME
DECLARE @Data1 DATETIME
DECLARE @Data2 DATETIME
DECLARE @PrcAkr NVARCHAR(20)
SET @Licz = 1
SET @Prac = @Osoba
SET @OznEta = @Ozn
SET @Kod = @PrcId
SET @PrcAkr = @Akronim
SET @Data1 = CONVERT ( DATETIME, '1900-01-01 00:00:00' , 120 )
SET @Data2 = CONVERT ( DATETIME, '2999-12-31 00:00:00' , 120 )
SET @IleRec = (SELECT count(*) FROM CDN.PracEtaty
join CDN.DaneKadMod on PRE_ETADkmIdStanowisko = DKM_DkmId
WHERE (PRE_ZatrudnionyDo >= @DataOd and PRE_ZatrudnionyOd <= @DataDo and DKM_Rodzaj = 1)
and PRE_PraId = @PrcId)
DECLARE Tmp_StanR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
 @PrcId,
 @Ozn,
 @Osoba,
 @Akronim,
 Case When @Data1 = PRE_DataOd Then PRE_ZatrudnionyOd Else PRE_DataOd End,
 Case When @Data2 = PRE_DataDo Then PRE_ZatrudnionyDo Else (Case When PRE_ZatrudnionyDo < PRE_DataDo then PRE_ZatrudnionyDo Else PRE_DataDo End) End,
 DKM_Nazwa,
 DKM_Robotnicze
  FROM CDN.PracEtaty join CDN.DaneKadMod on PRE_ETADkmIdStanowisko = DKM_DkmId
  WHERE PRE_PraId = @PrcId and DKM_Rodzaj = 1
  and PRE_ZatrudnionyDo >= @DataOd and PRE_ZatrudnionyOd <= @DataDo
  order by PRE_DataOd
  OPEN Tmp_StanR
  WHILE 1=1
BEGIN
  IF @IleRec = 0 BREAK
  IF @IleRec = 1
    BEGIN
      FETCH NEXT FROM Tmp_StanR INTO @Kod, @OznEta, @Prac,@PrcAkr, @Od, @Do, @Nazwa, @CzyRob
      IF @@FETCH_STATUS <> 0 BREAK
      INSERT INTO #Stan values (@Kod, @OznEta, @Prac,@PrcAkr, @Od, @Do, @Nazwa, @CzyRob)
     END
  ELSE
  BEGIN
   IF @IleRec = 2
   BEGIN
      FETCH NEXT FROM Tmp_StanR INTO  @Kod, @OznEta, @Prac, @PrcAkr,@Od, @Do, @Nazwa, @CzyRob
      IF @@FETCH_STATUS <> 0 BREAK
      IF @Licz = 1
         BEGIN
           SET @poprzOd = @Od
           SET @poprzDo = @Do
           SET @poprzNazwa = @Nazwa
           SET @poprzCzyRob = @CzyRob
           SET @Licz = @Licz + 1
         END
       ELSE
         BEGIN
           IF @poprzNazwa = @Nazwa and @PoprzDo = @Od-1
              INSERT INTO #Stan values (@Kod, @OznEta, @Prac, @PrcAkr,@poprzOd, @Do, @Nazwa, @CzyRob)
           ELSE
              BEGIN
                INSERT INTO #Stan values (@Kod, @OznEta, @Prac,@PrcAkr, @poprzOd, @PoprzDo, @poprzNazwa, @poprzCzyRob)
                INSERT INTO #Stan values (@Kod, @OznEta, @Prac, @PrcAkr,@Od, @Do, @Nazwa, @CzyRob)
              END
         END
   END
 ELSE
   BEGIN
    IF @IleRec > 2
      BEGIN
  FETCH NEXT FROM Tmp_StanR INTO @Kod, @OznEta, @Prac,@PrcAkr, @Od, @Do, @Nazwa, @CzyRob
  IF @@FETCH_STATUS <> 0 BREAK
   BEGIN
      IF @Licz = 1
        BEGIN
    SET @poprzOd = @Od
    SET @poprzDo = @Do
    SET @poprzNazwa = @Nazwa
    SET @poprzCzyRob = @CzyRob
    SET @Licz = @Licz + 1
        END
      ELSE
        BEGIN
     IF @poprzNazwa = @Nazwa
      BEGIN
      SET @Licz = @Licz + 1
      SET @poprzDo = @do
             IF (@Licz > @IleRec)
              INSERT INTO #Stan values (@Kod, @OznEta, @Prac,@PrcAkr, @poprzOd, @Do, @Nazwa, @CzyRob)
    END
             ELSE
        BEGIN
      INSERT INTO #Stan values (@Kod, @OznEta, @Prac,@PrcAkr, @poprzOd, @poprzDo, @poprzNazwa, @poprzCzyRob)
             SET @poprzNazwa = @Nazwa
      SET @poprzCzyRob = @CzyRob
             SET @poprzOd = @Od
      SET @poprzDo = @Do
                 IF @Licz = @IleRec
               INSERT INTO #Stan values (@Kod, @OznEta, @Prac,@PrcAkr, @poprzOd, @Do, @Nazwa, @CzyRob)
                 IF @Licz <> @IleRec
               SET @Licz = @Licz + 1
            END
          END
     END
   END
  END
 END
END
 CLOSE Tmp_StanR
 DEALLOCATE Tmp_StanR
 SET NOCOUNT OFF
