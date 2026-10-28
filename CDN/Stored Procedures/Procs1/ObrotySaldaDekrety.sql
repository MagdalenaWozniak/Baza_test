CREATE PROCEDURE CDN.ObrotySaldaDekrety @DataOd DATETIME, @DataDo DATETIME, @Bufor SMALLINT, @OObId INT, @AccId INT, @BO SMALLINT, @PelnyOkres SMALLINT, @MaAnalityke SMALLINT, @Waluta NVARCHAR(3)
AS
SET NOCOUNT ON
-- Tworzenie tabeli tymczasowej do obrotów
CREATE TABLE #Obroty1 (
 Tmp1_AccId   INT,
 Tmp1_ObrotyWn  NUMERIC(15,2),
 Tmp1_ObrotyMa  NUMERIC(15,2),
 Tmp1_ObrotyTotWn NUMERIC(15,2),
 Tmp1_ObrotyTotMa NUMERIC(15,2)
 )
CREATE UNIQUE INDEX Tmp1Id ON #Obroty1(Tmp1_AccId)
-- Tworzenie tabeli tymczasowej do bilansu otwarcia
CREATE TABLE #Obroty2 (
 Tmp2_AccId INT,
 Tmp2_BoWn NUMERIC(15,2),
 Tmp2_BoMa NUMERIC(15,2)
 )
CREATE UNIQUE INDEX Tmp2Id ON #Obroty2(Tmp2_AccId)
-- Tworzenie tabeli tymczasowej do korekty bilansu zamknięcia
CREATE TABLE #Obroty3 (
 Tmp3_AccId  INT,
 Tmp3_ObrotyWn NUMERIC(15,2),
 Tmp3_ObrotyMa NUMERIC(15,2)
 )
CREATE UNIQUE INDEX Tmp3Id ON #Obroty3(Tmp3_AccId)
-- Obroty dla konta analitycznego
IF @AccId <> 0 AND @MaAnalityke = 0
BEGIN
  IF @Waluta Is Null Or Exists (Select * From CDN.Konta Where Acc_AccId = @AccId And Acc_Waluta = @Waluta)
    BEGIN
 -- Obroty
 IF @BO = 0
  INSERT INTO #Obroty1 (
   Tmp1_AccId,
   Tmp1_ObrotyWn,
   Tmp1_ObrotyMa,
   Tmp1_ObrotyTotWn,
   Tmp1_ObrotyTotMa
   )
  SELECT
   @AccId,
   SUM(CASE WHEN DeK_DataDok >= @DataOd AND DeK_Strona = 1 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END ),
   SUM(CASE WHEN DeK_DataDok >= @DataOd AND DeK_Strona = 2 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END ),
   SUM(CASE WHEN DeK_Strona = 1 THEN CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END ELSE 0 END ),
   SUM(CASE WHEN DeK_Strona = 2 THEN CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END ELSE 0 END )
  FROM CDN.DekretyKonta
  WHERE
   DeK_AccId   =  @AccId  AND
   DeK_DataDok <= @DataDo AND
   DeK_Bufor   <= @Bufor
 -- Bilans otwarcia
 INSERT INTO #Obroty2 (
  Tmp2_AccId,
  Tmp2_BOWn,
  Tmp2_BOMa
  )
 SELECT
  @AccId,
  SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaWn ELSE BOE_KwotaWnWal END),
  SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaMa ELSE BOE_KwotaMaWal END)
 FROM CDN.BOElem JOIN CDN.BONag ON BOE_BONId = BON_BONId
 WHERE
  BOE_AccId =  @AccId AND
  BON_Bufor <= @Bufor
 -- Korekta bilansu zamknięcia
 IF @PelnyOkres = 1
  INSERT INTO #Obroty3 (
   Tmp3_AccId,
   Tmp3_ObrotyWn,
   Tmp3_ObrotyMa
   )
  SELECT
   @AccId,
  SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaWn ELSE BOE_KwotaWnWal END),
  SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaMa ELSE BOE_KwotaMaWal END)
  FROM CDN.BOElem
  JOIN CDN.BONag ON BON_BONId = BOE_BONId
  WHERE
   BOE_AccPrevId =  @AccId AND
   BON_Bufor <= @Bufor AND
   BON_BilansZamkniecia = 1
    END
END
-- Obroty dla konta synetycznego
IF @AccId <> 0 AND @MaAnalityke = 1
BEGIN
 -- Obroty
 IF @BO = 0
  INSERT INTO #Obroty1 (
   Tmp1_AccId,
   Tmp1_ObrotyWn,
   Tmp1_ObrotyMa,
   Tmp1_ObrotyTotWn,
   Tmp1_ObrotyTotMa
   )
  SELECT
   Acc_AccId,
   SUM(CASE WHEN DeK_DataDok >= @DataOd AND DeK_Strona = 1 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END ),
   SUM(CASE WHEN DeK_DataDok >= @DataOd AND DeK_Strona = 2 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END ),
   SUM(CASE WHEN DeK_Strona = 1 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END ),
   SUM(CASE WHEN DeK_Strona = 2 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END )
  FROM CDN.DekretyKonta JOIN CDN.Konta ON DeK_AccId = Acc_AccId
  WHERE
   DeK_DataDok <= @DataDo AND
   DeK_Bufor <= @Bufor AND
   Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1)) AND
   (@Waluta Is Null Or @Waluta=Acc_Waluta)
  GROUP BY Acc_AccId
 -- Bilans otwarcia
 INSERT INTO #Obroty2 (
  Tmp2_AccId,
  Tmp2_BOWn,
  Tmp2_BOMa
  )
 SELECT
  Acc_AccId,
  SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaWn ELSE BOE_KwotaWnWal END),
  SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaMa ELSE BOE_KwotaMaWal END)
 FROM CDN.BOElem
  JOIN CDN.BONag ON BOE_BONId = BON_BONId
  JOIN CDN.Konta ON BOE_AccId = Acc_AccId
 WHERE
  BON_Bufor <= @Bufor AND
  Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1)) AND
  (@Waluta Is Null Or @Waluta=Acc_Waluta)
 GROUP BY Acc_AccId
 -- Korekta bilansu zamknięcia
 IF @PelnyOkres = 1
  INSERT INTO #Obroty3 (
   Tmp3_AccId,
   Tmp3_ObrotyWn,
   Tmp3_ObrotyMa
   )
  SELECT
   Acc_AccId,
   SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaWn ELSE BOE_KwotaWnWal END),
   SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaMa ELSE BOE_KwotaMaWal END)
  FROM CDN.BOElem
   JOIN CDN.BONag ON BON_BONId = BOE_BONId
   JOIN CDN.Konta ON BOE_AccId = Acc_AccId
  WHERE
   BON_Bufor <= @Bufor AND
   BON_BilansZamkniecia =  1 AND
   Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1)) AND
   (@Waluta Is Null Or @Waluta=Acc_Waluta)
  GROUP BY Acc_AccId
END
-- Obroty dla wszystkich kont
IF @AccId = 0
BEGIN
 -- Obroty
 IF @BO = 0
  INSERT INTO #Obroty1 (
   Tmp1_AccId,
   Tmp1_ObrotyWn,
   Tmp1_ObrotyMa,
   Tmp1_ObrotyTotWn,
   Tmp1_ObrotyTotMa
   )
  SELECT
   Acc_AccId,
   SUM(CASE WHEN DeK_DataDok >= @DataOd AND DeK_Strona = 1 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END ),
   SUM(CASE WHEN DeK_DataDok >= @DataOd AND DeK_Strona = 2 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END ),
   SUM(CASE WHEN DeK_Strona = 1 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END ),
   SUM(CASE WHEN DeK_Strona = 2 THEN (CASE WHEN @Waluta Is Null THEN DeK_Kwota ELSE DeK_KwotaWal END) ELSE 0 END )
  FROM CDN.Konta JOIN CDN.DekretyKonta ON Acc_AccId = DeK_AccId
  WHERE
   Acc_OObId   =  @OObId  AND
   DeK_DataDok <= @DataDo AND
   DeK_Bufor   <= @Bufor AND
   (@Waluta Is Null Or @Waluta=Acc_Waluta)
  GROUP BY Acc_AccId
 -- Bilans otwarcia
 INSERT INTO #Obroty2 (
  Tmp2_AccId,
  Tmp2_BOWn,
  Tmp2_BOMa
  )
 SELECT
  Acc_AccId,
  SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaWn ELSE BOE_KwotaWnWal END),
  SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaMa ELSE BOE_KwotaMaWal END)
 FROM CDN.Konta
  JOIN CDN.BOElem ON BOE_AccId = Acc_AccId
  JOIN CDN.BONag  ON BOE_BONId = BON_BONId
 WHERE
  Acc_OObId   =  @OObId  AND
  BON_Bufor   <= @Bufor AND
  (@Waluta Is Null Or @Waluta=Acc_Waluta)
 GROUP BY Acc_AccId
 -- Korekta bilansu zamknięcia
 IF @PelnyOkres = 1
  INSERT INTO #Obroty3 (
   Tmp3_AccId,
   Tmp3_ObrotyWn,
   Tmp3_ObrotyMa
   )
  SELECT
   Acc_AccId,
   SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaWn ELSE BOE_KwotaWnWal END),
   SUM(CASE WHEN @Waluta Is Null THEN BOE_KwotaMa ELSE BOE_KwotaMaWal END)
  FROM CDN.Konta
   JOIN CDN.BOElem ON Acc_AccId = BOE_AccPrevId
   JOIN CDN.BONag  ON BON_BONId = BOE_BONId
  WHERE
   Acc_OObId =  @OObId  AND
   BON_Bufor <= @Bufor  AND
   BON_BilansZamkniecia =  1 AND
   (@Waluta Is Null Or @Waluta=Acc_Waluta)
  GROUP BY Acc_AccId
END
-- Łączenie tabel
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
 CASE WHEN Tmp1_AccId IS NOT NULL THEN Tmp1_AccId ELSE Tmp4_AccId END,
 IsNull(Tmp4_BoWn,0),
 IsNull(Tmp4_BoMa,0),
 IsNull(Tmp1_ObrotyWn,0) + IsNull(Tmp4_ObrotyWn,0),
 IsNull(Tmp1_ObrotyMa,0) + IsNull(Tmp4_ObrotyMa,0),
 IsNull(Tmp1_ObrotyTotWn,0) + IsNull(Tmp4_ObrotyWn,0),
 IsNull(Tmp1_ObrotyTotMa,0) + IsNull(Tmp4_ObrotyMa,0),
 0,
 0,
 0,
 0
FROM #Obroty1 FULL OUTER JOIN
 (SELECT
  CASE WHEN Tmp2_AccId IS NOT NULL THEN Tmp2_AccId ELSE Tmp3_AccId END As Tmp4_AccId,
  Tmp2_BoWn     As Tmp4_BoWn,
  Tmp2_BoMa     As Tmp4_BoMa,
  Tmp3_ObrotyWn As Tmp4_ObrotyWn,
  Tmp3_ObrotyMa As Tmp4_ObrotyMa
  FROM #Obroty2 FULL OUTER JOIN #Obroty3 ON Tmp2_AccId = Tmp3_AccId) As Obroty4
 ON Tmp1_AccId = Tmp4_AccId
