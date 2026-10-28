CREATE FUNCTION CDN.TwrZasobyErr (
    @TrE_TrEId      INT,
    @TrE_TwrId      INT,
    @TrE_TwrKod     NVarchar(50),
    @TrE_TwrNazwa   NVarchar(255),
    @TrE_DataOpe    DATETIME
    )
  RETURNS     NVarchar(250)
 AS
  BEGIN
  -- zmienne pomocnicze
  DECLARE
    -- TwrIlosci
    @TwI_MagId          INT,
    @TwI_Data           DATETIME,
    @TwI_Ilosc          DECIMAL(15,4),
    @TwI_Wartosc        DECIMAL(15,2),
    @TwI_Rezerwacje     DECIMAL(15,4),
    @TwI_Braki          DECIMAL(15,4),
    @TwI_Zamowienia     DECIMAL(15,4),
    -- Magazyn
    @Mag_Symbol         NVarchar(20),
    -- TwrZasoby
    @TwZ_Ilosc          DECIMAL(15,4),
    @TwZ_Quan           DECIMAL(15,4),
    @TwZ_Wartosc        DECIMAL(15,2),
    @TwZ_MagId          INT,
    -- TraSElem
    @TrS_Metoda         SMALLINT,
    -- dla kontroli subelementów
    @Data_Trans         DATETIME,
    @Data_Dost          DATETIME,
    -- zmienne dla komunikatow
    @Kom_Data           NVarchar(10),
    @Kom_Data_Trans     NVarchar(10),
    @Kom_Data_Dost      NVarchar(10),
    @Komunikat          NVarchar(512)
  -- ustawienie zmiennych dla komunikatow
  SET @Komunikat      = ''
  -- Kontrola tabeli TwrIlosci dla danego towaru, dla wszystkich magazynów ( takze NULL )
  SELECT TOP 1
    @TwI_Data       = TwI_Data,
    @TwI_Ilosc      = TwI_Ilosc,
    @TwI_Wartosc    = TwI_Wartosc,
    @TwI_Rezerwacje = TwI_Rezerwacje,
    @TwI_Braki      = TwI_Braki,
    @TwI_Zamowienia = TwI_Zamowienia,
    @TwI_MagId      = TwI_MagId
  FROM cdn.TwrIlosci WITH (INDEX = TwITowar)
  WHERE TwI_TwrId = @TrE_TwrId AND TwI_Data >= @TrE_DataOpe
    AND ( TwI_Ilosc < 0 OR TwI_Wartosc < 0 OR TwI_Rezerwacje < 0 OR TwI_Braki < 0 OR TwI_Zamowienia < 0 )
  IF @TwI_Data IS NOT NULL
    BEGIN
      SET @Kom_Data       = CONVERT(NVarchar(10), @TwI_Data, 120)
      SELECT @Mag_Symbol  = Mag_Symbol
        FROM cdn.Magazyny
        WHERE Mag_MagId = @TwI_MagId
     IF @Mag_Symbol IS NULL
       SET  @Mag_Symbol ='<wszystkie>'
      -- ujemna ilosc
      IF @TwI_Ilosc < 0
        BEGIN
          SET @Komunikat = '##OPT34576##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    +'%%s4%%='+@Kom_Data
    + '##'
    --SET @Komunikat = ' Zapis niemożliwy! Ilość towaru  ' + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] na magazynie ' + @Mag_Symbol + ' w dniu  ' + @Kom_Data + '  jest ujemna ! Zapisz dokument z datą późniejszą lub zmniejsz ilość lub wartość. '
          RETURN @Komunikat
        END
      -- ujemna wartosc
      ELSE IF @TwI_Wartosc < 0
        BEGIN
          SET @Komunikat = '##OPT34577##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    +'%%s4%%='+@Kom_Data
    + '##'
    --SET @Komunikat = ' Zapis niemożliwy! Wartość towaru  ' + @TrE_TwrKod + ' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] na magazynie ' + @Mag_Symbol + ' w dniu  ' + @Kom_Data + '  jest ujemna ! Zapisz dokument z datą późniejszą lub zmniejsz ilość lub wartość. '
          RETURN @Komunikat
        END
      -- ujemne rezerwacje
      ELSE IF @TwI_Rezerwacje < 0
        BEGIN
          SET @Komunikat = '##OPT34578##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    +'%%s4%%='+@Kom_Data
    + '##'
    --SET @Komunikat = ' Zapis niemożliwy! Rezerwacje towaru  ' + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] na magazynie ' + @Mag_Symbol + ' w dniu  ' + @Kom_Data + '  są ujemne ! Zapisz dokument z datą późniejszą lub zmniejsz ilość lub wartość. '
          RETURN @Komunikat
        END
      -- ujemne braki
      ELSE IF @TwI_Braki < 0
        BEGIN
          SET @Komunikat = '##OPT34579##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    +'%%s4%%='+@Kom_Data
    + '##'
    --SSET @Komunikat = ' Zapis niemożliwy! Braki towaru  ' + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') +  '] na magazynie ' + @Mag_Symbol + ' w dniu  ' + @Kom_Data + '  są ujemne ! Zapisz dokument z datą późniejszą lub zmniejsz ilość lub wartość. '
          RETURN @Komunikat
        END
      -- ujemne zamowienia
      ELSE IF @TwI_Zamowienia < 0
        BEGIN
           SET @Komunikat = '##OPT34580##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    +'%%s4%%='+@Kom_Data
    + '##'
    --SET @Komunikat = ' Zapis niemożliwy! Zamówienia towaru  ' + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] na magazynie ' + @Mag_Symbol + ' w dniu  ' + @Kom_Data + '  są ujemne ! Zapisz dokument z datą późniejszą lub zmniejsz ilość lub wartość. '
          RETURN @Komunikat
        END
    END
  -- Kontrola tabeli TwrZasoby dla danego towaru
  SELECT TOP 1
    @TwZ_Ilosc   = TwZ_Ilosc,
    @TwZ_Quan    = TwZ_Quan,
    @TwZ_Wartosc = TwZ_Wartosc,
    @TwZ_MagId   = TwZ_MagId
  FROM cdn.TwrZasoby WITH (INDEX = TwZTowar)
  WHERE TwZ_TwrId = @TrE_TwrId
    AND ( TwZ_QUAN < 0 OR TwZ_Ilosc < 0 OR TwZ_Wartosc < 0 OR (TwZ_Ilosc + TwZ_QUAN = 0 AND TwZ_Wartosc <> 0 ) )
  IF @TwZ_Ilosc IS NOT NULL
    BEGIN
      SELECT @Mag_Symbol  = Mag_Symbol
        FROM cdn.Magazyny
        WHERE Mag_MagId = @TwZ_MagId
      -- QUAN niezerowy - sprawdzamy sumy dla towaru w ramach magazynu
      IF @TwZ_QUAN < 0
        IF  ( SELECT SUM(TwZ_Ilosc + TwZ_Quan) FROM cdn.TwrZasoby WITH (INDEX = TwZTowar) WHERE TwZ_TwrId = @TrE_TwrId AND TwZ_MagId = @TwZ_MagId ) < 0
          BEGIN
             SET @Komunikat = '##OPT34581##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    + '##'
    --SET @Komunikat = 'Zapis niemożliwy! Zasób dla towaru  '  + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] na magazynie ' + @Mag_Symbol + ' posiada ujemną ilość! Zapisz dokument z datą późniejszą lub zmniejsz ilość. '
            RETURN @Komunikat
          END
      -- ujemna ilosc
      IF @TwZ_Ilosc < 0
        BEGIN
          SET @Komunikat = '##OPT34581##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    + '##'
    --SET @Komunikat = 'Zapis niemożliwy! Zasób dla towaru  '  + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] na magazynie ' + @Mag_Symbol + ' posiada ujemną ilość! Zapisz dokument z datą późniejszą lub zmniejsz ilość. '
          RETURN @Komunikat
        END
      -- ujemna wartosc
      IF @TwZ_Wartosc < 0
        BEGIN
          SET @Komunikat = '##OPT34582##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    + '##'
    --SET @Komunikat = 'Zapis niemożliwy! Zasób dla towaru  '  + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] na magazynie ' + @Mag_Symbol + ' posiada ujemną wartość! Zapisz dokument z datą późniejszą lub zmniejsz wartość. '
          RETURN @Komunikat
        END
      -- zerowa ilosc, wartosc > 0
      IF ( @TwZ_Ilosc + @TwZ_Quan ) = 0 AND @TwZ_Wartosc <> 0
        BEGIN
           SET @Komunikat = '##OPT34583##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Mag_Symbol
    + '##'
    --SET @Komunikat = 'Zapis niemożliwy! Zasób dla towaru  '  + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] na magazynie ' + @Mag_Symbol + ' posiada zerową ilość przy niezerowej wartości ! Zapisz dokument z datą późniejszą lub zmniejsz wartość. '
          RETURN @Komunikat
        END
    END
  -- Metoda z sublementu
  SELECT TOP 1 @TrS_Metoda = ISNULL( Fir_Wartosc,1 ) FROM cdn.Firma WHERE Fir_Numer = 1352
  SELECT
    @Data_Trans = NULL,
    @Data_Dost  = NULL
  -- Kontrola dat dostaw na subelementach
  IF @TrS_Metoda IN ( 1, 2 )
    SELECT TOP 1
      @Data_Trans = A.TrS_DataOpe,
      @Data_Dost  = B.TrS_DataOpe
    FROM
      ( SELECT TrS_TrSIdDost, TrS_DataOpe
        FROM cdn.TraSElem WITH ( INDEX = TrSTraElem )
        WHERE TrS_TrEId = @TrE_TrEId AND TrS_Typ IN ( 1, 2 )
      ) AS A
    LEFT OUTER JOIN cdn.TraSElem B ON A.TrS_TrSIdDost = B.TrS_TrSId
    WHERE A.TrS_DataOpe < B.TrS_DataOpe
  IF @TrS_Metoda IN ( 3 )
    SELECT TOP 1
      @Data_Trans = A.TrS_DataOpe,
      @Data_Dost  = TwZ_Data
    FROM
      ( SELECT TrS_DataOpe, TrS_TwrId, TrS_MagId
        FROM cdn.TraSElem WITH ( INDEX = TrSTraElem )
        WHERE TrS_TrEId = @TrE_TrEId AND TrS_Typ IN ( 1, 2 )
      ) AS A
      LEFT OUTER JOIN cdn.TwrZasoby WITH (INDEX = TwZTowar) ON TwZ_TwrId = @TrE_TwrId AND A.TrS_MagId = TwZ_MagId
    WHERE A.TrS_DataOpe < TwZ_Data
  IF @Data_Trans IS NOT NULL AND @Data_Dost IS NOT NULL
    BEGIN
      SET @Kom_Data_Trans =   CONVERT( NVarchar(10), @Data_Trans, 120 )
      SET @Kom_Data_Dost  =   CONVERT( NVarchar(10), @Data_Dost, 120 )
      -- FIFO, LIFO
      IF @TrS_Metoda IN ( 1, 2 )
        SET @Komunikat = '##OPT34584##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Kom_Data_Dost
    +'%%s4%%='+@Kom_Data_Trans
    + '##'
    --SET @Komunikat = ' Zapis niemożliwy !  Dla towaru ' + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] data dostawy ( ' + @Kom_Data_Dost + ' ) jest późniejsza niż data transakcji ( ' + @Kom_Data_Trans + ' ). Zapisz dokument z datą późniejszą ! '
      -- AVCO
      IF @TrS_Metoda IN ( 3 )
        BEGIN
          -- jeśli kontrola daty ostatniej modyfiakcji zasobu zaznaczona
          IF ( SELECT TOP 1 ISNULL(MAX(SUBSTRING(Fir_Wartosc,1,1)),0) FROM cdn.Firma WHERE Fir_Numer = 1688 ) = 0
            SET @Komunikat = '##OPT34585##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@TrE_TwrNazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    +'%%s3%%='+@Kom_Data_Dost
    +'%%s4%%='+@Kom_Data_Trans
    + '##'
    --SET @Komunikat = ' Zapis niemożliwy !  Dla towaru ' + @TrE_TwrKod +' ['+REPLACE(substring(@TrE_TwrNazwa,0,30),Char(13) + Char(10),' ') + '] data ostatniej modyfikacji zasobu ( ' + @Kom_Data_Dost + ' ) jest późniejsza niż data transakcji ( ' + @Kom_Data_Trans + ' ). Zapisz dokument z datą późniejszą ! '
        END
    END
  RETURN @Komunikat
END
