CREATE PROCEDURE CDN.AktualizujTraSElem
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
  @TrS_Cena       DECIMAL(17,4),
  @TrS_Termin     DATETIME,
  @TrE_ZwrId      INT,
  @TrN_TrNId      INT,
  @TrN_MagDocId   INT,
  @TrN_Bufor      INT
  AS
  SET NOCOUNT ON
  -- dostawa, korekta do dostawy ilościowa "na plus"
  IF @TrS_Typ = 1 AND @TrS_Ilosc > 0
    BEGIN
      SET IDENTITY_INSERT cdn.TraSElem ON
      INSERT INTO cdn.TraSElem (  TrS_TrSId,  TrS_TrEId,  TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,  TrS_Ilosc,  TrS_Wartosc,  TrS_Cena )
        VALUES                 ( @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena )
      SET IDENTITY_INSERT cdn.TraSElem OFF
    END
  -- korekta do dostawy: ilościowa "na minus", wartościowa
  IF  @TrS_Typ = 1 AND @TrS_Ilosc <= 0
    EXEC cdn.OddajZasoby @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor
  -- wydanie, korekta do wydania "na plus"
  IF @TrS_Typ = 2 AND @TrS_Ilosc > 0
    EXEC cdn.OddajZasoby @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor
  -- korekta do wydań: ilościowa "na minus" dla FIFO i LIFO
  IF  @TrS_Typ = 2 AND @TrS_Ilosc < 0 AND @TrS_Metoda IN ( 1, 2 )
    EXEC cdn.OddajZasoby @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor
  -- korekta ilościowa do wydań dla AVCO i QUAN
  IF @TrS_Typ = 2 AND @TrS_Ilosc < 0 AND @TrS_Metoda IN ( 3, 4 )
    EXEC cdn.KlonujTraSElem 2, @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId,     306001,       2, @TrS_Metoda, @TrS_DataOpe,   @TrS_Ilosc,   @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor
  -- Rezerwacje i Zamówienia
  IF @TrS_Typ IN ( 3, 4, 13, 14)
    BEGIN
      SET IDENTITY_INSERT cdn.TraSElem ON
      INSERT INTO cdn.TraSElem (   TrS_TrSId,  TrS_TrEId, TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,    TrS_Ilosc,   TrS_Wartosc,  TrS_Cena )
        VALUES                 (  @TrS_TrSId, @TrS_TrEId,          NULL, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe,   @TrS_Ilosc,  @TrS_Wartosc, @TrS_Cena )
      SET IDENTITY_INSERT cdn.TraSElem OFF
      -- drugi subelement dla rezerwacji z terminem
      IF @TrS_Typ = 3 AND @TrS_Termin IS NOT NULL
        INSERT INTO cdn.TraSElem (             TrS_TrEId, TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,    TrS_Ilosc,   TrS_Wartosc,  TrS_Cena )
          VALUES                 (            @TrS_TrEId,          NULL, @TrS_TrSId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_Termin+1, -@TrS_Ilosc, -@TrS_Wartosc, @TrS_Cena )
    END
  -- Rezerwacje i Zamówienia jeszcze ustawiamy dla niektorych rodzajow
    IF  @TrS_Rodzaj IN ( 307010, 302008, 305008, 306008,  301011 , 306004, 307004,302009, 306010,304000,304008,312008,312100)
    BEGIN
  EXEC [CDN].[UstawRezerwacje] @TrS_TrEId,0,0
    END
  SET NOCOUNT OFF
