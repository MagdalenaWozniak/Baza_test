CREATE PROCEDURE CDN.OFF_MozliwoscAnulowania @TrN_TrNId INT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE
    @TrS_TwrId      INT,
    @TrS_MagId      INT,
    @TrS_Typ        INT,
    @TrS_DataOpe    DATETIME,
    @TrS_Ilosc      DECIMAL(15,4),
    @Komunikat      NVARCHAR(350)
  DECLARE S CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrS_Typ, TrS_TwrId, TrS_MagId, TrS_DataOpe, SUM(TrS_Ilosc)
      FROM CDN.TraSElem
        JOIN cdn.TraElem ON TrS_TrEId = TrE_TrEId
      WHERE TrE_TrNId = @TrN_TrNId
        AND (    ( TrS_Typ = 1 AND ( TrS_Ilosc > 0 OR TrS_Wartosc > 0) )
              OR ( TrS_Typ = 2 AND ( TrS_Ilosc < 0 OR TrS_Wartosc < 0) ) )
      GROUP BY TrS_Typ, TrS_TwrId, TrS_MagId, TrS_DataOpe
      OPEN S
        WHILE 1=1
          BEGIN
            FETCH NEXT FROM S INTO @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc
            IF @@FETCH_STATUS <> 0 BREAK
            SET @Komunikat = CDN.TwrIlosciErr
              (
                  2              ,
                  @TrS_Typ       ,
                  @TrS_TwrId     ,
                  @TrS_MagId     ,
                  @TrS_DataOpe   ,
                  @TrS_Ilosc     ,
                  0
              )
             IF ISNULL(@Komunikat,'') <> ''
               BEGIN
                 SET @Komunikat =  @Komunikat
                 GOTO KOMUNIKAT
               END
          END
      CLOSE S
  DEALLOCATE S
  -- kontrola ilości/wartości po dostawach (TwrZasoby)
  DECLARE @T INT, @I DECIMAL(20,4), @W DECIMAL(20,2)
  SELECT TOP 1 @T=Z.TwZ_TwrId, @I=Z.SumI - T.SumI, @W=Z.SumW - T.SumW FROM
  -- dostawy z zasobów
  ( SELECT SumI=SUM(TwZ_Ilosc), SumW=SUM(TwZ_Wartosc), TwZ_TwrId, TwZ_MagId, TwZ_TrSIdDost
     FROM cdn.TwrZasoby
       JOIN cdn.TraSElem ON TrS_TwrId = TwZ_TwrId
       JOIN cdn.TraElem ON TrE_TrEId = TrS_TrEId
       JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
     WHERE TrE_TrNId = @TrN_TrNId AND TrS_Typ IN (1,2)
     GROUP BY TwZ_TwrId, TwZ_MagId, TwZ_TrSIdDost
  ) AS Z JOIN
    -- dostawy z dokumentu
  ( SELECT SumI=SUM(CASE TrS_Typ WHEN 1 THEN TrS_Ilosc  WHEN 2 THEN -TrS_Ilosc ELSE 0 END ), SumW=SUM(CASE TrS_Typ WHEN 1 THEN TrS_Wartosc WHEN 2 THEN -TrS_Wartosc ELSE 0 END ), TrS_TwrId, TrS_MagId, TrS_TrSIdDost
     FROM cdn.TraSElem
       JOIN cdn.TraElem ON TrS_TrEId = TrE_TrEId
       JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
     WHERE TrN_TrNId = @TrN_TrNId AND TrS_Typ IN (1,2)
     GROUP BY TrS_TwrId, TrS_MagId, TrS_TrSIdDost
  ) AS T ON Z.TwZ_TwrId = T.TrS_TwrId AND Z.TwZ_MagId = T.TrS_MagId AND Z.TwZ_TrSIdDost = T.TrS_TrSIdDost
  WHERE Z.SumI - T.SumI < 0 OR Z.SumW - T.SumW < 0
  IF @I < 0 OR @W < 0
    BEGIN
      DECLARE @Twr_Kod NVARCHAR(50)
      SELECT  @Twr_Kod = Twr_Kod FROM cdn.Towary WHERE Twr_TwrId = @T
      --SET @Komunikat = 'Anulowanie niemożliwe! Dla towaru '+ @Twr_Kod +' brak zasobów do pobrania ! '
   SET @Komunikat = '##OPT34457##%%s1%%='+ @Twr_Kod +'##'
      GOTO KOMUNIKAT
    END
 -- Wyswietlenie komunikatu i rollback całej transakcji
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
END
