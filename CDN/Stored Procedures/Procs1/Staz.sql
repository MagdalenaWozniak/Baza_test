CREATE Procedure [CDN].[Staz] @PrcId Int, @Data DateTime, @Param INT
AS
  SET NOCOUNT ON
  DECLARE @Lata Int
  DECLARE @Mies Int
  DECLARE @Dni Int
  DECLARE @DniNieob INT
  DECLARE @Baza datetime
  DECLARE @ZatrOd datetime
  DECLARE @ZatrDo datetime
  SET @Data = CONVERT(DATETIME, CONVERT(NVARCHAR(10),@Data,120)+' 00:00:000', 120)
  SET @Lata = 0
  SET @MIes = 0
  SET @Dni = 0
  SET @Baza = CONVERT(DATETIME,'1900-01-01',120)
  SET @ZatrOd = DATEADD(day,1,@Data)
  SET @ZatrDo = @Data
  DECLARE HistPracCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT Pre_ZatrudnionyOd, Pre_ZatrudnionyDo
  FROM CDN.PracEtaty
  WHERE Pre_PraId=@PrcId and Pre_ZatrudnionyOd <= @Data
  ORDER BY Pre_ZatrudnionyOd
  OPEN HistPracCursor
  DECLARE @Od datetime
  DECLARE @Do datetime
  WHILE 1=1
BEGIN
    FETCH NEXT FROM HistPracCursor INTO @Od, @Do
    IF @@FETCH_STATUS <> 0 BREAK
    IF @Od=@Baza CONTINUE
    IF DATEADD(day,1,@ZatrDo)=@Od
  set @Od=@ZatrOd
    ELSE
 IF @Od>@ZatrDo
  BEGIN
   exec CDN.StazCalc @ZatrOd, @ZatrDo, @Lata output, @Mies output, @Dni output
   set @ZatrOd = @Od
  END
 ELSE
  IF @Od<@ZatrOd set @ZatrOd=@Od
  IF @Do<=@Data set @ZatrDo=@Do
  ELSE   set @ZatrDo=@Data
END
 CLOSE HistPracCursor
 DEALLOCATE HistPracCursor
IF @Param = 0
 BEGIN
   exec CDN.StazCalc @ZatrOd, @ZatrDo,  @Lata output, @Mies output, @Dni output
   set @ZatrOd = @Od
    END
ELSE
    BEGIN
  DECLARE @Ndni INT
  DECLARE @Nmies INT
  DECLARE @Nlata INT
        exec CDN.StazCalc @ZatrOd, @ZatrDo,  @Lata output, @Mies output, @Dni output
        exec [CDN].[UrlopBezp] @PrcId, @Data,  @Nlata output, @Nmies  output,  @Ndni output
        IF  @Nlata<>0 or @Nmies<>0 or @Ndni<>0
        BEGIN
    SET @Lata = @Lata - @Nlata
    IF @Mies>=@Nmies
     SET @Mies = @Mies - @Nmies
    ELSE
     IF @Mies<@Nmies
      BEGIN
       SET @Lata = @Lata-1
       SET @Mies = (@Mies+12)- @Nmies
      END
    IF @Dni>=@Ndni
     SET @Dni = @Dni - @Ndni
    ELSE
    IF @Dni<@Ndni and @Mies>0
     BEGIN
      SET @Mies = @Mies - 1
      SET @Dni = (@Dni+30) - @Ndni
     END
    ELSE
    IF @Dni<@Ndni and @Mies=0
     BEGIN
      SET @Lata = @Lata-1
      SET @Mies = 11
      SET @Dni = (@Dni+30) - @Ndni
     END
  END
 SET @ZatrOd = @Od
    END
SELECT @Lata As Lata, @Mies As Mies, @Dni As Dni
