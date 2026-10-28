CREATE PROCEDURE CDN.ObrotySaldaMiesiecznie @AccId INT, @Bufor SMALLINT, @Narastajaco SMALLINT, @Waluta NVARCHAR(3) = NULL
AS
SET NOCOUNT ON
DECLARE @OObId     INT
DECLARE @Analityka SMALLINT
DECLARE @NumerIdx  NVARCHAR(50)
DECLARE @DataOd    DATETIME
DECLARE @DataDo    DATETIME
DECLARE @MiesiacDo INT
DECLARE @SaldoRozw SMALLINT
IF NOT EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @AccId)
  BEGIN
    exec CDN.RiseOptimaException 32531
    SET NOCOUNT OFF
    RETURN
  END
if @Waluta = ''
 set @Waluta = NULL
If @Waluta Is Not Null And Exists (Select * From CDN.Firma Where Fir_Numer=3 And Fir_Wartosc=@Waluta)
 Set @Waluta = ''
SELECT
  @NumerIdx = Acc_NumerIdx,
  @OObId = Acc_OObId,
  @Analityka = Acc_Analityka,
  @SaldoRozw = CASE WHEN Acc_Rozrachunkowe = 1 OR Acc_TypKonta = 3 THEN 1 ELSE 0 END
 FROM CDN.Konta WHERE Acc_AccId = @AccId
IF @NumerIdx IS NULL OR @OObId IS NULL OR @Analityka IS NULL
  BEGIN
    exec CDN.RiseOptimaException 32532
    SET NOCOUNT OFF
    RETURN
  END
SELECT @DataOd = OOb_DataOtw,
  @DataDo = OOb_DataKoncowa
 FROM CDN.OkresyObrach WHERE OOb_OObId = @OObId
SET @MiesiacDo = 100*YEAR(@DataDo)+MONTH(@DataDo)
CREATE TABLE #Miesiace (Mc_RokMies INT)
WHILE 100*YEAR(@DataOd)+MONTH(@DataOd) <= @MiesiacDo
BEGIN
 INSERT INTO #Miesiace(Mc_RokMies) VALUES(100*YEAR(@DataOd)+MONTH(@DataOd))
 SET @DataOd = DATEADD(month, 1, @DataOd)
END
CREATE TABLE #Obroty (O_RokMies INT, O_AccId INT, O_Saldo NUMERIC(15,2), O_ObrotyWn NUMERIC(15,2), O_ObrotyMa NUMERIC(15,2))
CREATE UNIQUE INDEX OROkMiesKonto ON #Obroty(O_RokMies, O_AccId)
CREATE UNIQUE INDEX OKontoROkMies ON #Obroty(O_AccId, O_RokMies)
IF @Narastajaco = 1 -- Liczenie sald narastająco w roku z uwzględnieniem B.O.
BEGIN
  IF @Analityka = 1
    INSERT INTO #Obroty
    SELECT
     Mc_RokMies,
     Obr_AccId,
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies IS NOT NULL)  OR Obr_Typ = 1 OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnBuforWal - Obr_ObrotyMaBuforWal
              ELSE Obr_ObrotyWnBufor - Obr_ObrotyMaBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnWal - Obr_ObrotyMaWal
              ELSE Obr_ObrotyWn - Obr_ObrotyMa
              END)
           END)
        ELSE 0
        END),
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnBuforWal
              ELSE Obr_ObrotyWnBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnWal
              ELSE Obr_ObrotyWn
              END)
           END)
        ELSE 0
        END),
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyMaBuforWal
              ELSE Obr_ObrotyMaBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyMaWal
              ELSE Obr_ObrotyMa
              END)
           END)
        ELSE 0
        END)
    FROM #Miesiace
    JOIN CDN.Obroty ON Mc_RokMies >= Obr_RokMies OR Obr_RokMies IS NULL
    JOIN CDN.Konta ON Acc_AccId = Obr_AccId
    WHERE Obr_AccId = @AccId
      AND (@Waluta Is Null Or @Waluta = Acc_Waluta)
    GROUP BY Mc_RokMies, Obr_AccId
  ELSE
    INSERT INTO #Obroty
    SELECT
     Mc_RokMies,
     Obr_AccId,
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies IS NOT NULL) OR Obr_Typ = 1 OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnBuforWal - Obr_ObrotyMaBuforWal
              ELSE Obr_ObrotyWnBufor - Obr_ObrotyMaBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnWal - Obr_ObrotyMaWal
              ELSE Obr_ObrotyWn - Obr_ObrotyMa
              END)
           END)
        ELSE 0
        END),
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnBuforWal
              ELSE Obr_ObrotyWnBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnWal
              ELSE Obr_ObrotyWn
              END)
           END)
        ELSE 0
        END),
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyMaBuforWal
              ELSE Obr_ObrotyMaBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyMaWal
              ELSE Obr_ObrotyMa
              END)
           END)
        ELSE 0
        END)
    FROM #Miesiace
    JOIN CDN.Obroty ON Mc_RokMies >= Obr_RokMies OR Obr_RokMies IS NULL
    JOIN CDN.Konta ON Acc_AccId = Obr_AccId
    WHERE Acc_OObId = @OObId AND Acc_Analityka = 1 AND Acc_NumerIdx LIKE @NumerIdx + '.%'
      AND (@Waluta Is Null Or @Waluta = Acc_Waluta)
    GROUP BY Mc_RokMies, Obr_AccId
END
ELSE  -- Liczenie sald dla poszczególnych miesięcy
BEGIN
  IF @Analityka = 1
    INSERT INTO #Obroty
    SELECT
     Mc_RokMies,
     Obr_AccId,
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnBuforWal - Obr_ObrotyMaBuforWal
              ELSE Obr_ObrotyWnBufor - Obr_ObrotyMaBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnWal - Obr_ObrotyMaWal
              ELSE Obr_ObrotyWn - Obr_ObrotyMa
              END)
           END)
        ELSE 0
        END),
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnBuforWal
              ELSE Obr_ObrotyWnBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnWal
              ELSE Obr_ObrotyWn
              END)
           END)
        ELSE 0
        END),
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyMaBuforWal
              ELSE Obr_ObrotyMaBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyMaWal
              ELSE Obr_ObrotyMa
              END)
           END)
        ELSE 0
        END)
    FROM #Miesiace
    JOIN CDN.Obroty ON Mc_RokMies = Obr_RokMies OR Obr_RokMies IS NULL
    JOIN CDN.Konta ON Acc_AccId = Obr_AccId
    WHERE Obr_AccId = @AccId
      AND (@Waluta Is Null Or @Waluta = Acc_Waluta)
    GROUP BY Mc_RokMies, Obr_AccId
  ELSE
    INSERT INTO #Obroty
    SELECT
     Mc_RokMies,
     Obr_AccId,
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnBuforWal - Obr_ObrotyMaBuforWal
              ELSE Obr_ObrotyWnBufor - Obr_ObrotyMaBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnWal - Obr_ObrotyMaWal
              ELSE Obr_ObrotyWn - Obr_ObrotyMa
              END)
           END)
        ELSE 0
        END),
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnBuforWal
              ELSE Obr_ObrotyWnBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyWnWal
              ELSE Obr_ObrotyWn
              END)
           END)
        ELSE 0
        END),
     SUM
       (CASE WHEN (Obr_Typ = 0 AND Obr_RokMies = Mc_RokMies) OR (Obr_Typ = 2 AND Mc_RokMies = @MiesiacDo)
        THEN
          (CASE @Bufor WHEN 1
           THEN
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyMaBuforWal
              ELSE Obr_ObrotyMaBufor
              END)
           ELSE
             (CASE WHEN @Waluta Is Not Null
              THEN Obr_ObrotyMaWal
              ELSE Obr_ObrotyMa
              END)
           END)
        ELSE 0
        END)
    FROM #Miesiace
    JOIN CDN.Obroty ON Mc_RokMies = Obr_RokMies OR Obr_RokMies IS NULL
    JOIN CDN.Konta ON Acc_AccId = Obr_AccId
    WHERE Acc_OObId = @OObId AND Acc_Analityka = 1 AND Acc_NumerIdx LIKE @NumerIdx + '.%'
      AND (@Waluta Is Null Or @Waluta = Acc_Waluta)
    GROUP BY Mc_RokMies, Obr_AccId
END
SET NOCOUNT OFF
IF @SaldoRozw = 1
 SELECT
  Mc_RokMies,
  SUM(CASE WHEN O_ObrotyWn IS NOT NULL THEN O_ObrotyWn ELSE 0 END) As O_ObrotyWn,
  SUM(CASE WHEN O_ObrotyMa IS NOT NULL THEN O_ObrotyMa ELSE 0 END) As O_ObrotyMa,
  SUM(CASE WHEN O_Saldo > 0 THEN O_Saldo ELSE 0 END) As O_SaldoWn,
  SUM(CASE WHEN O_Saldo < 0 THEN 0-O_Saldo ELSE 0 END) As O_SaldoMa
 FROM #Miesiace LEFT OUTER JOIN #Obroty ON Mc_RokMies = O_RokMies
 GROUP BY Mc_RokMies
 ORDER BY Mc_RokMies
ELSE
 SELECT
  Mc_RokMies,
  SUM(CASE WHEN O_ObrotyWn IS NOT NULL THEN O_ObrotyWn ELSE 0 END) As O_ObrotyWn,
  SUM(CASE WHEN O_ObrotyMa IS NOT NULL THEN O_ObrotyMa ELSE 0 END) As O_ObrotyMa,
  CASE WHEN SUM(IsNull(O_Saldo,0)) > 0 THEN SUM(IsNull(O_Saldo,0))  ELSE 0 END As O_SaldoWn,
  CASE WHEN SUM(IsNull(O_Saldo,0)) < 0 THEN 0-SUM(IsNull(O_Saldo,0))  ELSE 0 END As O_SaldoMa
 FROM #Miesiace LEFT OUTER JOIN #Obroty ON Mc_RokMies = O_RokMies
 GROUP BY Mc_RokMies
 ORDER BY Mc_RokMies
