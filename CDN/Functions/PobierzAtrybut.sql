CREATE FUNCTION CDN.PobierzAtrybut (@PodTyp Int, @PodId Int, @TwrId Int)
Returns NVARCHAR(1025)
AS
BEGIN
DECLARE @Wynik NVARCHAR(1025)
DECLARE @Wartosc NVARCHAR(1025)
DECLARE @Kod   NVARCHAR(20)
DECLARE @KodTemp   NVARCHAR(200)
DECLARE @CzyKod smallint
DECLARE @Format smallint
DECLARE TWRATR CURSOR FAST_FORWARD FOR
SELECT DeA_Kod, DeA_Format, TwA_Wartosctxt, TwA_CzyKod FROM cdn.Twratrybuty JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
  WHERE TwA_CzyKopiowac = 1 AND TwA_TwrID = @TwrID AND TwA_Zalezny = 0
UNION
 SELECT DeA_Kod, DeA_Format, TKA_Wartosctxt, TwA_CzyKod FROM cdn.twratrybuty JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
  JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID
  WHERE TwA_CzyKopiowac = 1 AND TwA_Zalezny = 1 AND TwA_TwrID = @TwrID AND TKA_PodmiotTyp = @PodTyp AND TKA_PodmiotID = @PodID
  ORDER BY DeA_Kod, TwA_CzyKod desc
DECLARE KNTATR CURSOR FAST_FORWARD FOR
  SELECT DeA_Kod, DeA_Format, KnA_Wartosctxt, KnA_CzyKod FROM cdn.kntatrybuty JOIN cdn.defatrybuty ON KnA_DeAID = DeA_DeAID
  WHERE KnA_CzyKopiowac = 1 AND KnA_PodmiotID = @PodID AND KnA_PodmiotTyp = @PodTyp
  ORDER BY DeA_Kod, KnA_CzyKod desc
   SET @Wynik = ''
   SET @KodTemp = ''
  IF @TwrID <> 0
  BEGIN
    OPEN TWRATR
    WHILE 1 = 1
    BEGIN
      FETCH NEXT FROM TWRATR INTO @Kod, @Format, @Wartosc, @CzyKod
      IF @@FETCH_STATUS <> 0 BREAK
      if @CzyKod = 0 --or @KodTemp like '%'+@Kod+'%'
        SET @Kod = ''
      ELSE
       SET @Kod = @Kod + ' '
      IF @Format = 4 AND @Wartosc<>''
        SET @Wartosc = convert( NVARCHAR(10), convert(datetime, dateadd(day,CAST(@Wartosc as integer),'18001228'), 120), 120 )
      IF len(@Kod + @Wartosc) > 0
        SET @Wynik =  @Wynik + @Kod + @Wartosc + ' '
      SET @KodTemp = @KodTemp + ' '+ @Kod + ' '
    END
    CLOSE TWRATR
    SET @Wartosc = ''
    SELECT @Wartosc = Twr_Opis FROM CDN.Towary WHERE Twr_TwrID = @TwrID AND Twr_KopiujOpis = 1
    IF @Wartosc = ''
        SET @Wynik = @Wartosc + @Wynik
    ELSE
        IF @Wynik =''
           SET @Wynik = @Wartosc
        ELSE
            SET @Wynik = @Wartosc + Char(13) + Char(10) + @Wynik
  END
  ELSE
  BEGIN
    OPEN KNTATR
    WHILE 1 = 1
    BEGIN
      FETCH NEXT FROM KNTATR INTO @Kod, @Format, @Wartosc, @CzyKod
      IF @@FETCH_STATUS <> 0 BREAK
      IF @CzyKod = 0 --or @KodTemp like '%'+@Kod+'%'
        SET @Kod = ''
      ELSE
       SET @Kod = @Kod + ' '
      IF @Format = 4 AND @Wartosc<>''
       SET @Wartosc = convert( NVARCHAR(10), convert(datetime, dateadd(day,CAST(@Wartosc as integer),'18001228'), 120), 120 )
      IF len(@Kod + @Wartosc) > 0
       SET @Wynik =  @Wynik + @Kod + @Wartosc + ' '
      SET @KodTemp = @KodTemp + ' '+ @Kod + ' '
    END
    CLOSE KNTATR
  END
  RETURN @Wynik
END
