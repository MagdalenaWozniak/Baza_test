create PROCEDURE [CDN].[DetalStan_SprawdzKorektyDokumentu] @DSTrnId INT
AS
BEGIN
  SET NOCOUNT ON
    --Deklaracja tabeli pomocniczej, zawierającej informacje o stanie przed korektą
    CREATE TABLE #DetalStanTraElemExt
    (DSTrE_DSTrEIdOrg INT PRIMARY KEY,
    DSTrE_IloscKor NUMERIC(15,4),
 DSTrE_WartoscKor NUMERIC(15,4))
    --
    DECLARE ElementyKorekty CURSOR LOCAL FAST_FORWARD FOR
    SELECT DSTrE_DSTrEId FROM CDN.DetalStanTraElem WHERE DSTrE_DSTrNId = @DSTrnId AND DSTrE_StornoId = 0
    DECLARE @DSTrEIdOrg      INT
    DECLARE @IloscKor      NUMERIC(15,4)
 DECLARE @WartoscKor      NUMERIC(15,4)
    --Przejście po wszystkich elementach faktury i obliczenie dla nich stanu przed korektą
    OPEN ElementyKorekty
    WHILE 1 = 1
      BEGIN
        FETCH NEXT FROM ElementyKorekty INTO @DSTrEIdOrg
        IF @@FETCH_STATUS <> 0 BREAK
        --Pobranie stanu przed korektą
        SELECT
          @IloscKor = IloscKor,
    @WartoscKor = WartoscKor
        FROM CDN.DetalStan_SprawdzKorektyDlaElementu(@DSTrEIdOrg)
        --Jeśli element został zwrócony - nie dodajemy go do korekty
        --IF @DopuscIloscZero=0 AND (@IloscOrg = 0) CONTINUE
        INSERT INTO #DetalStanTraElemExt (DSTrE_DSTrEIdOrg, DSTrE_IloscKor, DSTrE_WartoscKor)
                    VALUES      (@DSTrEIdOrg, @IloscKor, @WartoscKor)
      END
    CLOSE ElementyKorekty
    --Jeśli wszystkie elementy zostały całkowicie zwrócone - nie mozna korygować faktury
      IF NOT EXISTS
      (SELECT * FROM CDN.DetalStanTraElem JOIN #DetalStanTraElemExt ON DSTrE_DSTrEId = DSTrE_DSTrEIdOrg
  WHERE DSTrE_DSTrNId = @DSTrNId and DSTrE_IloscKor > 0.0000)
        BEGIN
          RAISERROR('Dokument został już całkowicie skorygowany (zwrócony).', 16, 1)
          SET NOCOUNT OFF
          RETURN
        END
    SET NOCOUNT OFF
    --Procedura zwraca recordset niezbędny do zainicjalizowania faktury
    SELECT
    DSTrE_DSTrEID,
    DSTrE_DSTrNId,
    DSTrE_StornoId,
    DSTrE_Lp,
    DSTrE_TwrId,
    DSTrE_TwrNazwa,
    DSTrE_TwrEAN,
    DSTrE_TwrKod,
    DSTrE_Stawka,
    DSTrE_Flaga,
    DSTrE_Cena,
    DSTrE_Rabat,
    DSTrE_CenaPoRabacie,
    DSTrE_Kaucja,
    DSTrE_Ilosc,
    DSTrE_Jm,
    DSTrE_JmCalkowite,
    DSTrE_JMPrzelicznikL,
    DSTrE_JMPrzelicznikM,
    DSTrE_Waluta,
    DSTrE_IloscKor,
 DSTrE_WartoscKor
    FROM CDN.DetalStanTraElem JOIN #DetalStanTraElemExt ON DSTrE_DSTrEId = DSTrE_DSTrEIdOrg
    WHERE DSTrE_DSTrNId = @DSTrNId and DSTrE_Kaucja <> 1 AND DSTrE_StornoId = 0
    ORDER BY DSTrE_DSTrNId, DSTrE_Lp
END
