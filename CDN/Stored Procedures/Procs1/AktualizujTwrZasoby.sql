CREATE   PROCEDURE CDN.AktualizujTwrZasoby
  @InsDel   INT, -- 1-INSERT lub 2-DELETE
  @TrS_TrSId      INT,
  @TrS_TrEId      INT,
  @TrS_TrSIdDost  INT,
  @TrS_ZwrId      INT,
  @TrS_TwrId      INT,
  @TrS_MagId      INT,
  @TrS_Rodzaj     INT,
  @TrS_Typ        INT,
  @TrS_Metoda     INT,
  @TrS_DataOpe    DATETIME,
  @TrS_Ilosc      DECIMAL(15,4),
  @TrS_Wartosc    DECIMAL(15,2),
  @TrS_Cena       DECIMAL(17,4)
AS
  SET NOCOUNT ON
  DECLARE
    -- dla identyfikacji zasobu
    @TwZ_TwZId           INT,
    @TwZ_TrSIdDost       INT,
    @TwZ_TwrId           INT,
    @TwZ_MagId           INT,
    @TwZ_Data            DATETIME,
    @TwZ_Ilosc           DECIMAL(15,4),
    @TwZ_Quan            DECIMAL(15,4),
    @TwZ_Wartosc         DECIMAL(15,2),
    @TwZ_Cena            DECIMAL(17,4)
  -- inicjowanie wspolnych pol dla TwrZasoby
  SELECT
    @TwZ_TrSIdDost   = @TrS_TrSIdDost,
    @TwZ_TwrId       = @TrS_TwrId,
    @TwZ_MagId       = @TrS_MagId,
    @TwZ_Data        = ( SELECT TOP 1 TrS_DataOpe FROM cdn.TraSElem WHERE TrS_TrSId = CASE WHEN @TrS_Rodzaj in (312000,312008) THEN @TrS_TrSId ELSE  @TrS_TrSIdDost END)
  IF @TwZ_Data  IS NULL
    SELECT @TwZ_Data        =  (SELECT TOP 1 TrS_DataOpe FROM cdn.TraSElem WHERE TrS_TrSId = @TrS_TrSIdDost)
  -- AVCO
  IF @TrS_Metoda = 3
    SELECT
      @TwZ_TrSIdDost = NULL,
      @TwZ_Data      = @TrS_DataOpe
  -- QUAN
  IF @TrS_Metoda = 4
    SELECT
      @TwZ_TrSIdDost = NULL,
      @TwZ_Data      = NULL,
      @TwZ_Cena      = 0,
      @TrS_Wartosc   = 0
  -- aktualizacja TwrIlosci
  EXECUTE CDN.AktualizujTwrIlosci @InsDel, @TrS_TwrId, @TrS_MagId, @TrS_Typ, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc
  -- Obsluga tylko DOSTAWY lub KOSZTU - rezerwacje i zamowienia nie sa obslugiwane
  IF @TrS_Typ NOT IN ( 1, 2 ) RETURN
  -- TwZ_TwZId dla FIFO, LIFO
  IF @TrS_Metoda IN ( 1, 2 )
    SELECT
      @TwZ_TwZId   = TwZ_TwZId,
      @TwZ_Data    = TwZ_Data,
      @TwZ_Ilosc   = TwZ_Ilosc,
      @TwZ_Quan    = TwZ_Quan,
      @TwZ_Wartosc = TwZ_Wartosc,
      @TwZ_Cena    = TwZ_Cena
    FROM cdn.TwrZasoby WITH (INDEX = TwZTowar)
    WHERE TwZ_TwrId = @TwZ_TwrId AND TwZ_MagId = @TwZ_MagId AND TwZ_TrSIdDost = @TwZ_TrSIdDost
  -- TwZ_TwZId dla AVCO, QUAN
  IF @TrS_Metoda IN ( 3, 4 )
    SELECT
      @TwZ_TwZId   = TwZ_TwZId,
      @TwZ_Data    = TwZ_Data,
      @TwZ_Ilosc   = TwZ_Ilosc,
      @TwZ_Quan    = TwZ_Quan,
      @TwZ_Wartosc = TwZ_Wartosc,
      @TwZ_Cena    = TwZ_Cena
    FROM cdn.TwrZasoby WITH (INDEX = TwZTowar)
    WHERE TwZ_TwrId = @TwZ_TwrId AND TwZ_MagId = @TwZ_MagId AND TwZ_TrSIdDost IS NULL
  -- Zakladanie zasobu jesli nie istnieje
  IF @TwZ_TwZId IS NULL
    BEGIN
      INSERT INTO cdn.TwrZasoby (   TwZ_TwrId,  TwZ_MagId,  TwZ_TrSIdDost,  TwZ_Data,           TwZ_Ilosc,               TwZ_Quan,               TwZ_Wartosc,               TwZ_Cena     )
        VALUES                  (  @TwZ_TwrId, @TwZ_MagId, @TwZ_TrSIdDost, @TwZ_Data, ISNULL( @TwZ_Ilosc, 0 ), ISNULL( @TwZ_Quan, 0 ), ISNULL( @TwZ_Wartosc, 0 ), ISNULL( @TwZ_Cena, 0 ) )
      SELECT @TwZ_TwZId = @@IDENTITY
    END
  -- inicjowanie
  SELECT
    @TwZ_Data    = TwZ_Data,
    @TwZ_Ilosc   = TwZ_Ilosc,
    @TwZ_Quan    = TwZ_Quan,
    @TwZ_Wartosc = TwZ_Wartosc,
    @TwZ_Cena    = TwZ_Cena
  FROM cdn.TwrZasoby
  WHERE TwZ_TwZId = @TwZ_TwZId
  -- Jeśli kasowanie dostawy lub dodawanie kosztu, to ilości i wartości zmieniają znak
  IF ( @InsDel = 2 AND @TrS_Typ = 1 ) OR ( @InsDel = 1 AND @TrS_Typ = 2 )
    SELECT
      @TrS_Ilosc   = - @TrS_Ilosc,
      @TrS_Wartosc = - @TrS_Wartosc
  -- QUAN
  IF @TrS_Metoda=4
    SET  @TwZ_Quan = @TwZ_Quan + @TrS_Ilosc
  -- ilosc/wartosc FIFO, LIFO, AVCO
  ELSE IF @TrS_Metoda IN ( 1, 2, 3 )
    BEGIN
      SET @TwZ_Ilosc   = @TwZ_Ilosc   + @TrS_Ilosc
      SET @TwZ_Wartosc = @TwZ_Wartosc + @TrS_Wartosc
    END
  -- cena jako wspolczynnik dla ogolnego przypadku ( korekty wartosciowe, AVCO, zwykla dostawa )
  IF @TwZ_Ilosc <> 0
    SET @TwZ_Cena  = @TwZ_Wartosc / @TwZ_Ilosc
  -- modyfikacja daty zasobu dla AVCO i QUAN
  IF @TrS_Metoda IN ( 3, 4 )
    IF @InsDel = 1
      SET @TwZ_Data = @TrS_DataOpe
    ELSE IF @InsDel = 2
      BEGIN
        SELECT @TwZ_Data = MAX(TrS_DataOpe) FROM cdn.TraSElem WHERE TrS_Typ IN (1,2) AND TrS_TwrId = @TrS_TwrId  AND TrS_MagId = @TrS_MagId
        IF @TwZ_Data IS NULL
          SET @TwZ_Data = @TrS_DataOpe
      END
  -- kasowanie, gdy po modyfikacjach zasób zerowy; w przeciwnym wypadku update
  IF @TwZ_Ilosc = 0 AND @TwZ_Quan = 0 AND @TwZ_Wartosc = 0
    DELETE FROM cdn.TwrZasoby WHERE TwZ_TwZId = @TwZ_TwZId
  ELSE
    UPDATE cdn.TwrZasoby SET
      TwZ_Data    = @TwZ_Data,
      TwZ_Ilosc   = @TwZ_Ilosc,
      TwZ_Quan    = @TwZ_Quan,
      TwZ_Wartosc = @TwZ_Wartosc,
      TwZ_Cena    = @TwZ_Cena
    WHERE TwZ_TwZId = @TwZ_TwZId
  -- kasowanie zasobu, gdy po zapisie Ilosc = 0 i Quan = 0 i Wartosc = 0
  SET NOCOUNT OFF
