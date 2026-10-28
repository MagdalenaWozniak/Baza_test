-- TrnStatusInt
CREATE  FUNCTION [CDN].[TrnStatusInt] (@TrNId INT,@TrNTyp INT,@TrNIdSkoj INT,@TrNTypSkoj INT, @Typ INT)
RETURNS INT
AS
BEGIN
 DECLARE
 @Wynik        INT,
 @StatusInt    INT,
 @RodzajSkoj   INT,
 @Rodzaj       INT,
 @Wart1        INT,
 @Wart2        INT,
 @Wart3        INT,
 @Wart4        INT
Select @StatusInt = Trn_StatusInt from cdn.tranag where Trn_TrNId = @TrNId
set  @Wynik = @StatusInt
IF @Typ = 1  --Dodawanie
BEGIN
 IF @TrNTyp = 320
 BEGIN
   SELECT   @Wart1   =  @StatusInt & 1
           ,@Wart2   = (@StatusInt & 2) / 2
           ,@Wart3   = (@StatusInt & 4) / 4
           ,@Wart4   = (@StatusInt & 8) / 8
 IF @TrNTypSkoj = 302
    BEGIN
       Select @RodzajSkoj = Trn_Rodzaj from cdn.tranag where Trn_TrNId = @TrNIdSkoj
       IF @RodzajSkoj in (302200,302202)
       BEGIN
           if @Wart1 = 0
             SET @Wynik = @Wynik+1
       END
       ELSE
           IF @Wart2 = 0
              SET @Wynik = @Wynik+2
    END
 IF @TrNTypSkoj = 306
    BEGIN
        IF @Wart3 = 0
              SET @Wynik = @Wynik+4
    END
 END
 ELSE
 BEGIN
   SELECT   @Wart1   =  @StatusInt & 1
           ,@Wart2   = (@StatusInt & 2) / 2
           ,@Wart3   = (@StatusInt & 4) / 4
           ,@Wart4   = (@StatusInt & 8) / 8
  Select @RodzajSkoj = Trn_Rodzaj from cdn.tranag where Trn_TrNId = @TrNIdSkoj
  IF @Wart1 = 0 AND (@TrNTypSkoj = 321 OR @TrNTypSkoj = 322 OR @TrNTypSkoj = 345)
        SET @Wynik = @Wynik+1
  IF @Wart3 = 0 AND @TrNTypSkoj = 306 AND @RodzajSkoj<>306071 AND @RodzajSkoj<>306072
          SET @Wynik = @Wynik + 4
  IF @Wart1 = 0 AND @TrNTypSkoj = 320
  BEGIN
        Select @Rodzaj = Trn_Rodzaj from cdn.tranag where Trn_TrNId = @TrNId
        IF @Rodzaj not in (302200,302202)
    SET @Wynik = @Wynik+1
  END
  IF @Wart2 = 0 AND @TrNTypSkoj = 302
  BEGIN
        Select @Rodzaj = Trn_Rodzaj from cdn.tranag where Trn_TrNId = @TrNId
        IF @Rodzaj <> 306061 and @TrNTyp != 301
        SET @Wynik = @Wynik+2
  END
  IF @Wart4 = 0 AND @TrNTypSkoj = 304
 SET @Wynik = @Wynik + 8
 END
END
ELSE --kasowanie
BEGIN
IF @TrNTyp = 320
 BEGIN
   SELECT   @Wart1   =  @StatusInt & 1
           ,@Wart2   = (@StatusInt & 2) / 2
           ,@Wart3   = (@StatusInt & 4) / 4
           ,@Wart4   = (@StatusInt & 8) / 8
 IF @TrNTypSkoj = 302
    BEGIN
       IF @Wart1 = 1 AND NOT EXISTS (SELECT TrR_TrRId FROM CDN.TraNagRelacje JOIN CDN.TraNag ON TrR_FAID = TrN_TrNID WHERE TrR_TrNId = @TrNId AND TrR_FATyp = @TrNTypSkoj AND TrN_Rodzaj = 302200)
           SET @Wynik = @Wynik-1
       IF @Wart2 = 1 AND NOT EXISTS (SELECT TrR_TrRId FROM CDN.TraNagRelacje JOIN CDN.TraNag ON TrR_FAID = TrN_TrNID WHERE TrR_TrNId = @TrNId AND TrR_FATyp = @TrNTypSkoj AND TrN_Rodzaj not in( 302200,302202))
              SET @Wynik = @Wynik-2
    END
 IF @TrNTypSkoj = 306
    BEGIN
        IF @Wart3 = 1 AND NOT EXISTS (SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp = @TrNTypSkoj)
              SET @Wynik = @Wynik-4
    END
 END
 ELSE
 BEGIN
  SELECT   @Wart1   =  @StatusInt & 1
           ,@Wart2   = (@StatusInt & 2) / 2
           ,@Wart3   = (@StatusInt & 4) / 4
           ,@Wart4   = (@StatusInt & 8) / 8
  IF @Wart1 = 1 AND (@TrNTypSkoj = 321 OR @TrNTypSkoj = 322 OR @TrNTypSkoj = 345)  AND NOT EXISTS (SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp in(321,322,345))
        SET @Wynik = @Wynik-1
  IF @Wart3 = 1 AND @TrNTypSkoj = 306 AND NOT EXISTS (SELECT TrR_TrRId FROM CDN.TraNagRelacje JOIN CDN.TraNag ON TrR_FAID = TrN_TrNID WHERE TrR_TrNId = @TrNId AND TrR_FATyp = 306 AND TrN_Rodzaj not in( 306071,306072))
          SET @Wynik = @Wynik - 4
  IF @Wart1 = 1 AND @TrNTypSkoj = 320 AND NOT EXISTS (SELECT TrR_TrRId FROM CDN.TraNagRelacje JOIN CDN.TraNag ON TrR_TrNID = TrN_TrNID WHERE TrR_TrNId = @TrNId AND TrR_FATyp = 320 AND TrN_Rodzaj <> 302200)
    SET @Wynik = @Wynik- 1
  IF @Wart2 = 1 AND @TrNTypSkoj = 302 AND NOT EXISTS (SELECT TrR_TrRId FROM CDN.TraNagRelacje JOIN CDN.TraNag ON TrR_TrNID = TrN_TrNID WHERE TrR_TrNId = @TrNId AND TrR_FATyp = 302 AND TrN_Rodzaj <> 306061)
        SET @Wynik = @Wynik-2
  IF @Wart4 = 1 AND @TrNTypSkoj = 304
 SET @Wynik = @Wynik - 8
 END
END
 RETURN @Wynik
END
