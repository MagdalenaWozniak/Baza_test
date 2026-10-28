CREATE PROCEDURE CDN.ObrotySaldaObroty @RokMiesOd INT, @RokMiesDo INT, @Bufor SMALLINT, @OObId INT, @AccId INT, @BO SMALLINT, @PelnyOkres SMALLINT, @MaAnalityke SMALLINT, @Waluta NVARCHAR(3)
AS
SET NOCOUNT ON
-- Obroty dla konta analitycznego
IF @AccId <> 0 AND @MaAnalityke = 0  AND @BO = 0
BEGIN
  IF @Waluta Is Null Or Exists (Select * From CDN.Konta Where Acc_AccId = @AccId And Acc_Waluta = @Waluta)
    BEGIN
 INSERT INTO #Obroty (
  Tmp_AccId,
  Tmp_BoWn,
  Tmp_BoMa,
  Tmp_ObrotyWn,
  Tmp_ObrotyMa,
  Tmp_ObrotyTotWn,
  Tmp_ObrotyTotMa,
  Tmp_SaldoWn,
  Tmp_SaldoMa,
  Tmp_PrevSaldoWn,
  Tmp_PrevSaldoMa
  )
 SELECT
  Obr_AccId,
  SUM(CASE WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 0                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 1                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END),
  SUM(CASE WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 0                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 1                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END),
  SUM(CASE WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END ),
  0,
  0,
  0,
  0
 FROM CDN.Obroty
 WHERE
  Obr_AccId = @AccId AND
  (Obr_RokMies <= @RokMiesDo OR Obr_RokMies IS NULL)
 GROUP BY Obr_AccId
    END
END
-- Obroty dla konta synetycznego
IF @AccId <> 0 AND @MaAnalityke = 1  AND @BO = 0
BEGIN
 INSERT INTO #Obroty (
  Tmp_AccId,
  Tmp_BoWn,
  Tmp_BoMa,
  Tmp_ObrotyWn,
  Tmp_ObrotyMa,
  Tmp_ObrotyTotWn,
  Tmp_ObrotyTotMa,
  Tmp_SaldoWn,
  Tmp_SaldoMa,
  Tmp_PrevSaldoWn,
  Tmp_PrevSaldoMa
  )
 SELECT
  Acc_AccId,
  SUM(CASE WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 0                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 1                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END),
  SUM(CASE WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 0                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 1                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END),
  SUM(CASE WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END ),
  0,
  0,
  0,
  0
 FROM CDN.Obroty JOIN CDN.Konta ON Obr_AccId = Acc_AccId
 WHERE
  Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1)) AND
  (Obr_RokMies <= @RokMiesDo OR Obr_RokMies IS NULL) AND
  (@Waluta Is Null Or @Waluta=Acc_Waluta)
 GROUP BY Acc_AccId
END
-- Obroty dla wszystkich kont
IF @AccId = 0 AND @BO = 0
BEGIN
 INSERT INTO #Obroty (
  Tmp_AccId,
  Tmp_BoWn,
  Tmp_BoMa,
  Tmp_ObrotyWn,
  Tmp_ObrotyMa,
  Tmp_ObrotyTotWn,
  Tmp_ObrotyTotMa,
  Tmp_SaldoWn,
  Tmp_SaldoMa,
  Tmp_PrevSaldoWn,
  Tmp_PrevSaldoMa
  )
 SELECT
  Acc_AccId,
  SUM(CASE WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 0                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 1                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END),
  SUM(CASE WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 0                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 1                                                                    THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END),
  SUM(CASE WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN (Obr_RokMies >= @RokMiesOd AND Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END ),
  SUM(CASE WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 0                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN (Obr_Typ = 0 OR Obr_RokMies IS NULL AND Obr_Typ = 2 AND @PelnyOkres = 1) AND @Bufor = 1                               THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END ),
  0,
  0,
  0,
  0
 FROM CDN.Konta JOIN CDN.Obroty ON Acc_AccId = Obr_AccId
 WHERE
  Acc_OObId = @OObId AND Acc_Analityka = 1 AND
  (Obr_RokMies <= @RokMiesDo OR Obr_RokMies IS NULL) AND
  (@Waluta Is Null Or @Waluta=Acc_Waluta)
 GROUP BY Acc_AccId
END
-- Bilans otwarcia
IF @BO = 1
BEGIN
 INSERT INTO #Obroty (
  Tmp_AccId,
  Tmp_BoWn,
  Tmp_BoMa,
  Tmp_ObrotyWn,
  Tmp_ObrotyMa,
  Tmp_ObrotyTotWn,
  Tmp_ObrotyTotMa,
  Tmp_SaldoWn,
  Tmp_SaldoMa,
  Tmp_PrevSaldoWn,
  Tmp_PrevSaldoMa
  )
 SELECT
  Acc_AccId,
  SUM(CASE WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 0 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWn ELSE Obr_ObrotyWnWal END) WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 1 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyWnBufor ELSE Obr_ObrotyWnBuforWal END) ELSE 0 END),
  SUM(CASE WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 0 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMa ELSE Obr_ObrotyMaWal END) WHEN Obr_RokMies IS NULL AND Obr_Typ = 1 AND @Bufor = 1 THEN (CASE WHEN @Waluta Is Null THEN Obr_ObrotyMaBufor ELSE Obr_ObrotyMaBuforWal END) ELSE 0 END),
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0
 FROM CDN.Konta JOIN CDN.Obroty ON Acc_AccId = Obr_AccId
 WHERE
  Acc_OObId = @OObId AND
  Acc_Analityka = 1 AND
  Obr_RokMies IS NULL AND Obr_Typ = 1 AND
  (@Waluta Is Null Or @Waluta=Acc_Waluta)
 GROUP BY Acc_AccId
END
