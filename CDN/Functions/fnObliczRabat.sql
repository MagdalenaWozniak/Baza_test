CREATE FUNCTION CDN.fnObliczRabat (@PodTyp Int, @PodId Int, @TwrId Int)
RETURNS @Rabaty Table( TypRabatu SmallInt, RabatCena Decimal(17,4), TypCenyNB SmallInt, Waluta NVARCHAR(3))
AS
BEGIN
  DECLARE
    @RabKnt          DECIMAL(15,2),   -- rabat procentowy od strony kontrahenta
    @RabTwr          DECIMAL(15,2),   -- rabat procentowy od strony towaru
    @TypKumulacji    INT,             -- typ kumulacji rabatu
    @GruTwrId        INT,             -- grupa do której przynależy towar
    @GruKntId        INT,             -- grupa do której przynależy kontrahent
    @MaxRabTypKnt    INT,             -- maksymalny typ wsrod rabatow kontrahentow
    @MaxRabTypTwr    INT,             -- Maksymalny typ wsror rabatow towarowych
    @TypRabatu       SMALLINT,        -- Typ rabatu: 0-procent, 1-stała cena
    @TypCenyNB       SMALLINT,        -- Typ ceny netto/brutto: 1-netto, 2-brutto (jak w TwrCeny)
    @Wynik           DECIMAL(17,4),   -- rabat skumulowany lub stała cena
    @Waluta          CHAR(3)          -- Symbol waluty dla rabatu typu stała cena
  -- Typ                                     Rab_Typ   Rab_TwrId    Rab_PodmiotTyp   Rab_PodmiotId
  -- Rabaty procentowe - mają nizszy priorytet i sa liczone w drugiej kolejnosci
  -- Grupa kontrahentow - wszystkie towary      1         NULL         1                Gru_GruId
  -- Jeden kontrahent   - wszystkie towary      2         NULL         Pod_PodmiotTyp   Pod_PodId
  -- Grupa kontrahenta  - grupa towarowa        3         Gru_GruId    1                Gru_GruId
  -- Grupa kontrahentow - jeden towar           4         Twr_TwrId    1                Gru_GruId
  -- Jeden kontrahent   - grupa towarowa        5         Gru_GruId    Pod_PodmiotTyp   Pod_PodId
  -- Jeden kontrahent   - jeden towar           6         Twr_TwrId    Pod_PodmiotTyp   Pod_PodId
  -- Grupa towarowa     - wszyscy kontrahenci   7         Gru_GruId    NULL             NULL
  -- Jeden towar        - wszyscy kontrahenci   8         Twr_TwrId    NULL             NULL
  -- Rabaty typu stała cena - maja wyzszy priorytet i sa liczone w pierwszej kolejnosci
  -- Jeden towar        - wszyscy kontrahenci  11         Twr_TwrId    NULL             NULL
  -- Jeden towar        - grupa   kontrahentow 12         Twr_TwrId    1                Gru_GruId
  -- Jeden towar        - jeden   kontrahent   13         Twr_TwrId    Pod_PodmiotTyp   Pod_PodId
  -- grupa kontrahenta, do której przynależy kontrahent
  SET @GruKntId = ( SELECT ISNULL( Gru_GruId, 0 ) FROM cdn.Grupy JOIN cdn.Kontrahenci ON Knt_Grupa = Gru_Nazwa AND Gru_Typ = 31 WHERE Knt_PodmiotTyp IN (0,1) AND Knt_KntId = @PodId )
  IF @PodTyp <>  1
    SET @GruKntId = 0
  -- Rabat typu stała cena - ma wyzszy priorytet i jest liczony w pierwszej kolejnosci
   SELECT TOP 1
    @TypCenyNB = Rab_TypCenyNB,
    @Wynik = Rab_Cena,
    @Waluta = Rab_Waluta
  FROM cdn.Rabaty
  WHERE    ( Rab_TwrId = @TwrId AND  Rab_Typ = 11 AND Rab_PodmiotId IS NULL )
        OR ( Rab_TwrId = @TwrId AND  Rab_Typ = 12 AND Rab_PodmiotId =  @GruKntId )
        OR ( Rab_TwrId = @TwrId AND  Rab_Typ = 13 AND Rab_PodmiotTyp =  @PodTyp AND Rab_PodmiotId =  @PodId )
  ORDER BY Rab_Typ DESC -- sortowanie malejace jest b. istotne; najwyzszy priorytet ma indyidualny kontrahent
  -- Jesli wystepuje jakikolwiek rabat typu stała cena, to nie sa liczone rabaty procentowe
  IF  @TypCEnyNB IS NOT NULL AND @Wynik IS NOT NULL AND @Waluta IS NOT NULL
    BEGIN
      SET @TypRabatu = 1
    END -- rabatu typu stala cena
  -- Rabat procentowy - mają nizszy priorytet i sa liczone w drugiej kolejnosci
  ELSE
    BEGIN
      SET @RabKnt        = 0
      SET @RabTwr        = 0
      SET @Wynik         = 0
      SET @MaxRabTypKnt  = 0
      SET @MaxRabTypTwr  = 0
      -- grupa towarowa do której przynależy towar
      SET @GruTwrId = ( SELECT Twr_TwGGIDNumer FROM cdn.Towary WHERE Twr_TwrId = @TwrId )
      -- najpierw rabat o maksymalnym priorytecie od strony kontrahentowych
      SET @MaxRabTypKnt = ( SELECT ISNULL ( MAX ( Rab_Typ), 0 ) FROM cdn.Rabaty
                              WHERE ( Rab_Typ = 1 AND Rab_TwrId IS NULL     AND Rab_PodmiotTyp = 1        AND Rab_PodmiotId = @GruKntId )
                                 OR ( Rab_Typ = 2 AND Rab_TwrId IS NULL     AND Rab_PodmiotTyp = @PodTyp  AND Rab_PodmiotId = @PodId    )
                                 OR ( Rab_Typ = 3 AND Rab_TwrId = @GruTwrId AND Rab_PodmiotTyp = 1        AND Rab_PodmiotId = @GruKntId )
                                 OR ( Rab_Typ = 4 AND Rab_TwrId = @TwrId    AND Rab_PodmiotTyp = 1        AND Rab_PodmiotId = @GruKntId )
                                 OR ( Rab_Typ = 5 AND Rab_TwrId = @GruTwrId AND Rab_PodmiotTyp = @PodTyp  AND Rab_PodmiotId = @PodId    )
                                 OR ( Rab_Typ = 6 AND Rab_TwrId = @TwrId    AND Rab_PodmiotTyp = @PodTyp  AND Rab_PodmiotId = @PodId    )
                          )
      SET @MaxRabTypTwr = ( SELECT ISNULL ( MAX ( Rab_Typ), 0 ) FROM cdn.Rabaty
                              WHERE ( Rab_Typ = 7 AND Rab_TwrId = @GruTwrId AND Rab_PodmiotTyp IS NULL    AND Rab_PodmiotId IS NULL     )
                                 OR ( Rab_Typ = 8 AND Rab_TwrId = @TwrId    AND Rab_PodmiotTyp IS NULL    AND Rab_PodmiotId IS NULL     )
                          )
      -- grupa rabatów kontrahentowych
      IF @MaxRabTypKnt = 1
        SET @RabKnt = ( SELECT ISNULL(Rab_Rabat,0) FROM cdn.Rabaty WHERE Rab_Typ = @MaxRabTypKnt AND Rab_TwrId IS NULL     AND Rab_PodmiotTyp = 1        AND Rab_PodmiotId = @GruKntId )
      -- jeden kontrahent - wszystkie towary
      IF @MaxRabTypKnt = 2
        SET @RabKnt = ( SELECT ISNULL(Rab_Rabat,0) FROM cdn.Rabaty WHERE Rab_Typ = @MaxRabTypKnt AND Rab_TwrId IS NULL     AND Rab_PodmiotTyp = @PodTyp  AND Rab_PodmiotId = @PodId )
      -- grupa kontrahenta - grupa towarowa
      IF @MaxRabTypKnt = 3
        SET @RabKnt = ( SELECT ISNULL(Rab_Rabat,0) FROM cdn.Rabaty WHERE Rab_Typ = @MaxRabTypKnt AND Rab_TwrId = @GruTwrId AND Rab_PodmiotTyp = 1        AND Rab_PodmiotId = @GruKntId )
      -- grupa kontrahenta - jeden towar
      IF @MaxRabTypKnt = 4
        SET @RabKnt = ( SELECT ISNULL(Rab_Rabat,0) FROM cdn.Rabaty WHERE Rab_Typ = @MaxRabTypKnt AND Rab_TwrId = @TwrId       AND Rab_PodmiotTyp = 1     AND Rab_PodmiotId = @GruKntId )
      -- jeden kontrahent - grupa towarowa
      IF @MaxRabTypKnt = 5
        SET @RabKnt = ( SELECT ISNULL(Rab_Rabat,0) FROM cdn.Rabaty WHERE Rab_Typ = @MaxRabTypKnt AND Rab_TwrId = @GruTwrId AND Rab_PodmiotTyp = @PodTyp  AND Rab_PodmiotId = @PodId )
      -- jeden kontrahent - jeden towar
      IF @MaxRabTypKnt = 6
        SET @RabKnt = ( SELECT ISNULL(Rab_Rabat,0) FROM cdn.Rabaty WHERE Rab_Typ = @MaxRabTypKnt AND Rab_TwrId = @TwrId    AND Rab_PodmiotTyp = @PodTyp  AND Rab_PodmiotId = @PodId )
      -- błędny maksymalny typ rabatu
      IF @MaxRabTypKnt NOT IN ( 1, 2, 3, 4, 5, 6 )
        SET @RabKnt = 0
      -- grupa rabatów towarowych
      -- grupa towarowa - wszyscy kontrahenci
      IF @MaxRabTypTwr = 7
        SET @RabTwr = ( SELECT ISNULL(Rab_Rabat,0) FROM cdn.Rabaty WHERE Rab_Typ = @MaxRabTypTwr AND Rab_TwrId = @GruTwrId    AND Rab_PodmiotTyp IS NULL   AND Rab_PodmiotId IS NULL )
      -- jeden towar - wszyscy kontrahenci
      IF @MaxRabTypTwr = 8
        SET @RabTwr = ( SELECT ISNULL(Rab_Rabat,0) FROM cdn.Rabaty WHERE Rab_Typ = @MaxRabTypTwr AND Rab_TwrId = @TwrId       AND Rab_PodmiotTyp IS NULL   AND Rab_PodmiotId IS NULL )
      -- błędny maksymalny typ rabatu
      IF @MaxRabTypTwr NOT IN ( 7, 8 )
        SET @RabTwr = 0
      -- Kumulacja
      SET @TypKumulacji = ( SELECT ISNULL(Fir_Wartosc,0) FROM CDN.Firma WHERE Fir_Numer = 1484 )
      -- kumulacja addytywna
      IF @TypKumulacji = 1
        SET @Wynik = ISNULL(@RabKnt,0) + ISNULL(@RabTwr,0)
      -- kumulacja multiplikatywna
      IF @TypKumulacji = 2
        SET @Wynik = round(100.00 * ( 1 - ( 1 - ISNULL(@RabKnt,0) / 100.0 ) * ( 1 - ISNULL(@RabTwr,0) / 100.0 ) ),2)
      -- tylko kontrahent
      IF @TypKumulacji = 3
        BEGIN
          SET @Wynik = ISNULL(@RabKnt,0)
          IF @Wynik = 0
            SET @Wynik = ISNULL(@RabTwr,0)
        END
      -- tylko towar
      IF @TypKumulacji = 4
        BEGIN
          SET @Wynik = ISNULL(@RabTwr,0)
          IF @Wynik = 0
            SET @Wynik = ISNULL(@RabKnt,0)
        END
      -- błąd w parametrze - wynik zero
      IF @TypKumulacji NOT IN ( 1, 2, 3, 4 )
        SET @Wynik = 0
      -- gdy > 100.00%, to 100.00%
      IF @Wynik > 100.00
        SET @Wynik = 100.00
      -- reszta zmiennych potrzebna dla returna rabatu typu procentowego
      SET @TypRabatu = 0  -- procent
      SET @TypCenyNB = 0  -- bez znaczenia dla rabatu procentowego
      SET @Waluta    = '' -- bez znaczenia dla rabatu procentowego
    END -- rabatu procentowego
  -- zwracany wynik
  INSERT @Rabaty ( TypRabatu, RabatCena, TypCenyNB, Waluta )
  SELECT TOP 1 @TypRabatu, ISNULL( @Wynik, 0 ), @TypCenyNB, @Waluta
  RETURN
END
