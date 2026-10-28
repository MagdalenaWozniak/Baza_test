CREATE FUNCTION CDN.TwrIlosciErr (
  @InsDel         INT,
  @TrS_Typ        INT,
  @TrS_TwrId      INT,
  @TrS_MagId      INT,
  @TrS_DataOpe    DATETIME,
  @TrS_Ilosc      DECIMAL(15,4),
  @CzyPrzeksztRO  INT
  )
  RETURNS     NVarchar(250)
  AS
  BEGIN
    -- zmienne pomocnicze
    DECLARE
      @TwI_Ilosc       DECIMAL(15,4),
      @TwI_Rezerwacje  DECIMAL(15,4),
      @TwI_Braki       DECIMAL(15,4),
      @TwI_Data        DATETIME,
      -- zmienne pomocnicze
      @ZawszeBraki     SMALLINT,
      -- zmienne dla komunikatow
      @Kom_Twr_Kod     NVarchar(50),
      @Kom_Twr_Nazwa   NVarchar(255),
      @Kom_Twr_Jm      NVarchar(20),
      @Kom_Mag_Symbol  NVarchar(20),
      @Kom_Data        NVarchar(10),
      @Kom_Braki       NVarchar(21),
      @Kom_Ilosc       NVarchar(21),
      @Komunikat       NVarchar(350)
    -- odczytanie parametru decydującego o kontroli
    SELECT @ZawszeBraki = ISNULL(MAX(Fir_Wartosc),0)
      FROM cdn.Firma WHERE Fir_Numer = 1536
    -- jesli 2 to sytuacja wlaczony parametr pobieraj ilosc dostepna na WZ i przeksztalcenie RO->WZ
    IF @CzyPrzeksztRO = 2
 SELECT @ZawszeBraki = 0,@CzyPrzeksztRO=1
    IF @CzyPrzeksztRO = 3
    SELECT @ZawszeBraki = 0,@CzyPrzeksztRO=0
    -- ustawienie @Komunikat
    SET @Komunikat = ''
    IF NOT
    (
       ( @InsDel = 1 AND ( ( @TrS_Typ = 1 AND @TrS_Ilosc < 0 ) OR ( @TrS_Typ = 2 AND @TrS_Ilosc > 0 ) ) )
       OR
       ( @InsDel = 2 AND ( ( @TrS_Typ = 1 AND @TrS_Ilosc > 0 ) OR ( @TrS_Typ = 2 AND @TrS_Ilosc < 0 ) ) )
     )
    RETURN @Komunikat
    DECLARE @TwrIlosci TABLE ( TwI_Ilosc DECIMAL(15,4), TwI_Rezerwacje DECIMAL(15,4), TwI_Braki DECIMAL(15,4), TwI_Data DATETIME)
    SELECT TOP 1
      @TwI_Ilosc       = TwI_Ilosc,
      @TwI_Rezerwacje  = TwI_Rezerwacje,
      @TwI_Braki       = TwI_Braki,
      @TwI_Data        = TwI_Data
    FROM cdn.TwrIlosci WITH (INDEX = TwITowar)
    WHERE TwI_TwrId = @TrS_TwrId
      AND TwI_MagId = @TrS_MagId
      AND TwI_Data  = (
                        SELECT MAX(TwI_Data)
                          FROM cdn.TwrIlosci WITH (INDEX = TwITowar)
                          WHERE TwI_TwrId = @TrS_TwrId
                            AND TwI_MagId = @TrS_MagId
                            AND TwI_Data <= @TrS_DataOpe
                       )
    INSERT INTO @TwrIlosci (        TwI_Ilosc,    TwI_Rezerwacje,    TwI_Braki, TwI_Data )
                VALUES     ( ISNULL(@TwI_Ilosc,0),  ISNULL(@TwI_Rezerwacje,0),  ISNULL(@TwI_Braki,0), @TrS_DataOpe )
    INSERT INTO @TwrIlosci (        TwI_Ilosc,     TwI_Rezerwacje,          TwI_Braki, TwI_Data )
      SELECT                        TwI_Ilosc,      TwI_Rezerwacje,         TwI_Braki, TwI_Data
        FROM cdn.TwrIlosci WITH (INDEX = TwITowar)
        WHERE TwI_TwrId = @TrS_TwrId
          AND TwI_MagId = @TrS_MagId
          AND TwI_Data  > @TrS_DataOpe
    -- Kontrola tabeli TwrIlosci po zaktualizowaniu subelemntow przypietych do danego elementu
    -- przy dodawaniu kosztu lub kasowaniu dostawy ma być ujemna ilość
    IF ( @InsDel = 1 AND  @TrS_Typ = 2 )  OR ( @InsDel = 2 AND  @TrS_Typ = 1 )
      SET @TrS_Ilosc = - @TrS_Ilosc
   IF @CzyPrzeksztRO = 1 and @ZawszeBraki = 1
     UPDATE @TwrIlosci  SET
       TwI_Ilosc = TwI_Ilosc + @TrS_Ilosc,
       TwI_Braki = CASE WHEN TwI_Rezerwacje - ( TwI_Ilosc  ) < 0 THEN 0 ELSE TwI_Rezerwacje - ( TwI_Ilosc  ) END
   ELSE
     UPDATE @TwrIlosci  SET
       TwI_Ilosc = TwI_Ilosc + @TrS_Ilosc,
       TwI_Braki = CASE WHEN TwI_Rezerwacje - ( TwI_Ilosc + @TrS_Ilosc ) < 0 THEN 0 ELSE TwI_Rezerwacje - ( TwI_Ilosc + @TrS_Ilosc ) END
    SELECT TOP 1
      @TwI_Data    = TwI_Data,
      @TwI_Ilosc   = TwI_Ilosc,
      @TwI_Braki   = TwI_Braki
    FROM @TwrIlosci
      WHERE ( @ZawszeBraki = 0 AND TwI_Ilosc < 0 ) OR ( @ZawszeBraki = 1 AND TwI_Braki > 0 )
    IF @TwI_Ilosc IS NOT NULL
      BEGIN
        SET @Kom_Data       =   CONVERT(NVarchar(10), @TwI_Data, 120)
        -- ustawienie zmiennych dla komunikatow
        SELECT
          @Kom_Twr_Kod = Twr_Kod,
          @Kom_Twr_Nazwa = Twr_Nazwa,
          @Kom_Twr_Jm  = Twr_Jm
        FROM cdn.Towary
        WHERE Twr_TwrId = @TrS_TwrId
        SELECT
          @Kom_Mag_Symbol = Mag_Symbol
        FROM cdn.Magazyny
        WHERE Mag_MagId = @TrS_MagId
        SET @Kom_Braki = CONVERT( NVarchar(30),   @TwI_Braki )
        SET @Kom_Ilosc = CONVERT( NVarchar(30), - @TwI_Ilosc )
        -- decyzja o sposobie kontroli i komunikacie w zależności od parametru
        -- tylko gdy przekroczymy ilość ujemną ( @ZawszeBraki = 0 )
        IF @ZawszeBraki = 0 AND @TwI_Ilosc < 0
          SET @Komunikat = '##OPT34574##%%s1%%=' + REPLACE(@Kom_Twr_Kod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@Kom_Twr_Nazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Kom_Mag_Symbol
    +'%%s4%%='+@Kom_Data
    +'%%s5%%='+@Kom_Ilosc
    +'%%s6%%='+@Kom_Twr_Jm
    +'%%s7%%='+@Kom_Braki
    +'%%s8%%='+@Kom_Twr_Jm
    + '##'
    --SET @Komunikat = 'Zapis niemożliwy! Dla towaru  ' + @Kom_Twr_Kod +' ['+REPLACE(substring(@Kom_Twr_Nazwa,0,30),Char(13) + Char(10),' ') + ']  na magazynie  ' + @Kom_Mag_Symbol + ' w dniu  ' + @Kom_Data + ' przekroczono stan o ' + @Kom_Ilosc + ' ' + @Kom_Twr_Jm + '. Łącznie z innymi rezerwacjami brakuje  ' + @Kom_Braki + ' ' + @Kom_Twr_Jm + '. Zmniejsz ilość lub zwiększ datę. '
        -- gdy występują inne rezerwacje ( @ZawszeBraki = 1 )
        ELSE IF @ZawszeBraki = 1 AND @TwI_Braki > 0
  SET @Komunikat = '##OPT34575##%%s1%%=' + REPLACE(@Kom_Twr_Kod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@Kom_Twr_Nazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Kom_Mag_Symbol
    +'%%s4%%='+@Kom_Data
    +'%%s5%%='+@Kom_Braki
    +'%%s6%%='+@Kom_Twr_Jm
    + '##'
          --SET @Komunikat = 'Zapis niemożliwy! Dla towaru  ' + @Kom_Twr_Kod +' ['+REPLACE(substring(@Kom_Twr_Nazwa,0,30),Char(13) + Char(10),' ') + ']  na magazynie  ' + @Kom_Mag_Symbol + ' w dniu  ' + @Kom_Data + ' występują braki ! '  + ' Brakuje ' + @Kom_Braki + ' ' + @Kom_Twr_Jm + '. Zmniejsz ilość lub zwiększ datę. '
      END
      RETURN @Komunikat
  END
