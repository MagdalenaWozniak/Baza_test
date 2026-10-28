CREATE PROCEDURE CDN.AktualizujTwrIlosci
  @InsDel INT, -- 1-INSERT lub 2-DELETE
  @TrS_TwrId INT,
  @TrS_MagId INT,
  @TrS_Typ INT,
  @TrS_DataOpe DATETIME,
  @TrS_Ilosc DECIMAL(15,4),
  @TrS_Wartosc DECIMAL(15,2)
AS
  SET NOCOUNT ON
  DECLARE
    @TwI_TwIId      INT,
    @TwI_Data      DATETIME,
    @TwI_Ilosc      DECIMAL(15,4),
    @TwI_Wartosc    DECIMAL(15,2),
    @TwI_Rezerwacje DECIMAL(15,4),
    @TwI_Braki      DECIMAL(15,4),
    @TwI_Zamowienia DECIMAL(15,4)
  DECLARE @toUpdate TABLE(
 TwIId      INT,
    Ilosc      DECIMAL(15,4),
    Wartosc    DECIMAL(15,2),
    Rezerwacje DECIMAL(15,4),
    Braki      DECIMAL(15,4),
    Zamowienia DECIMAL(15,4) UNIQUE CLUSTERED (TwIId) )
  -- dwa przebiegi - jeden dla konkretnego magazynu, a drugi dla wszystkich magazynów
  WHILE 1=1
    BEGIN
      -- inicjowanie poprzednich wartosci startowych dla daty początkowej osobno dla konkretnego magazynu i dla wszystkich
      SELECT
        @TwI_TwIId       = NULL,
        @TwI_Data        = NULL,
        @TwI_Ilosc       = 0,
        @TwI_Wartosc     = 0,
        @TwI_Rezerwacje  = 0,
        @TwI_Braki       = 0,
        @TwI_Zamowienia  = 0
      IF @TrS_MagId IS NOT NULL
        BEGIN
          SELECT
            @TwI_TwIId       = TwI_TwIId,
            @TwI_Data        = TwI_Data,
            @TwI_Ilosc       = TwI_Ilosc,
            @TwI_Wartosc     = TwI_Wartosc,
            @TwI_Rezerwacje  = TwI_Rezerwacje,
            @TwI_Braki       = TwI_Braki,
            @TwI_Zamowienia  = TwI_Zamowienia
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
         END
      ELSE
        BEGIN
          SELECT
            @TwI_TwIId       = TwI_TwIId,
            @TwI_Data        = TwI_Data,
            @TwI_Ilosc       = TwI_Ilosc,
            @TwI_Wartosc     = TwI_Wartosc,
            @TwI_Rezerwacje  = TwI_Rezerwacje,
            @TwI_Braki       = TwI_Braki,
            @TwI_Zamowienia  = TwI_Zamowienia
          FROM cdn.TwrIlosci WITH (INDEX = TwITowar)
          WHERE TwI_TwrId = @TrS_TwrId
            AND TwI_MagId IS NULL
            AND TwI_Data  = (
                              SELECT MAX(TwI_Data)
                                FROM cdn.TwrIlosci WITH (INDEX = TwITowar)
                                WHERE TwI_TwrId = @TrS_TwrId
                                  AND TwI_MagId IS NULL
                                  AND TwI_Data <= @TrS_DataOpe
                             )
        END
        IF @InsDel = 1 AND ( @TwI_TwIId IS NULL OR @TwI_Data <> @TrS_DataOpe )
            BEGIN
              INSERT INTO cdn.TwrIlosci (  TwI_TwrId,  TwI_MagId,     TwI_Data,         TwI_Ilosc,            TwI_Wartosc,            TwI_Braki,            TwI_Rezerwacje,            TwI_Zamowienia    )
                VALUES                  ( @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, ISNULL(@TwI_Ilosc,0), ISNULL(@TwI_Wartosc,0), ISNULL(@TwI_Braki,0), ISNULL(@TwI_Rezerwacje,0), ISNULL(@TwI_Zamowienia,0) )
              SELECT @TwI_TwIId = @@IDENTITY
            END
      -- poprawa ilosci/wartosci dla @TrS_Data i dla wszystkich nastepnych dni
      IF @TrS_MagId IS NOT NULL
        DECLARE Historia CURSOR LOCAL FAST_FORWARD FOR
          SELECT TwI_TwIId,  TwI_Data,  TwI_Ilosc,  TwI_Wartosc,  TwI_Rezerwacje,  TwI_Braki,  TwI_Zamowienia
          FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
          WHERE TwI_TwrId = @TrS_TwrId
            AND TwI_MagId = @TrS_MagId
            AND TwI_Data >= @TrS_DataOpe
      ELSE
        DECLARE Historia CURSOR LOCAL FAST_FORWARD FOR
          SELECT TwI_TwIId,  TwI_Data,  TwI_Ilosc,  TwI_Wartosc,  TwI_Rezerwacje,  TwI_Braki,  TwI_Zamowienia
          FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
          WHERE TwI_TwrId = @TrS_TwrId
            AND TwI_MagId IS NULL
            AND TwI_Data >= @TrS_DataOpe
        OPEN Historia
          WHILE 1 = 1
            BEGIN
              FETCH NEXT FROM Historia INTO @TwI_TwIId, @TwI_Data, @TwI_Ilosc, @TwI_Wartosc, @TwI_Rezerwacje, @TwI_Braki, @TwI_Zamowienia
              IF @@FETCH_STATUS <> 0 BREAK
              -- ( insert i dostawa ) lub ( delete i koszt )
              IF ( @InsDel=1 AND @TrS_Typ=1 ) OR ( @InsDel=2 AND @TrS_Typ=2 )
                BEGIN
                  SET @TwI_Ilosc   = @TwI_Ilosc   + @TrS_Ilosc
                  SET @TwI_Wartosc = @TwI_Wartosc + @TrS_Wartosc
                END
              -- ( insert i koszt ) lub ( delete i dostawa )
              IF ( @InsDel = 1 AND @TrS_Typ = 2 ) OR ( @InsDel = 2 AND @TrS_Typ = 1 )
                BEGIN
                  SET @TwI_Ilosc   = @TwI_Ilosc   - @TrS_Ilosc
                  SET @TwI_Wartosc = @TwI_Wartosc - @TrS_Wartosc
                END
              -- rezerwacja i ( insert i data ) lub ( delete i termin )
              IF @InsDel = 1 AND @TrS_Typ = 3
                SET @TwI_Rezerwacje = @TwI_Rezerwacje + @TrS_Ilosc
              -- rezerwacja i ( delete i data ) lub ( insert i termin )
              IF @InsDel = 2 AND @TrS_Typ = 3
                SET @TwI_Rezerwacje = @TwI_Rezerwacje - @TrS_Ilosc
              -- aktualizacja braków
              SET @TwI_Braki = @TwI_Rezerwacje - @TwI_Ilosc
              IF  @TwI_Braki < 0
                SET @TwI_Braki = 0
              -- insert i zamowienie
              IF ( @InsDel = 1 AND @TrS_Typ = 4 )
                SET @TwI_Zamowienia = @TwI_Zamowienia + @TrS_Ilosc
              -- delete i zamowienie
              IF ( @InsDel = 2 AND @TrS_Typ = 4 )
                SET @TwI_Zamowienia   = @TwI_Zamowienia - @TrS_Ilosc
     INSERT INTO @toUpdate ( TwIId      ,
           Ilosc    ,
           Wartosc   ,
           Rezerwacje ,
           Braki      ,
           Zamowienia)
         values (@TwI_TwIId,@TwI_Ilosc    ,
           @TwI_Wartosc   ,
           @TwI_Rezerwacje ,
           @TwI_Braki      ,
           @TwI_Zamowienia)
                /*UPDATE cdn.TwrIlosci  SET
                  TwI_Ilosc       = @TwI_Ilosc,
                  TwI_Wartosc     = @TwI_Wartosc,
                  TwI_Rezerwacje  = @TwI_Rezerwacje,
                  TwI_Braki       = @TwI_Braki,
                  TwI_Zamowienia  = @TwI_Zamowienia
                WHERE TwI_TwIId = @TwI_TwIId */
              END
          CLOSE Historia
      DEALLOCATE Historia
      IF @TrS_MagId IS NULL BREAK
      ELSE SET @TrS_MagId = NULL
    END  -- End dla magazynu
  UPDATE cdn.TwrIlosci
 SET TwI_Ilosc       = Ilosc,
    TwI_Wartosc     = Wartosc,
    TwI_Rezerwacje  = Rezerwacje,
    TwI_Braki       = Braki,
    TwI_Zamowienia  = Zamowienia
  FROM @toUpdate WHERE TwI_TwIId=TwIId
  SET NOCOUNT OFF
