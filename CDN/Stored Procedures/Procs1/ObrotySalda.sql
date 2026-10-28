CREATE PROCEDURE CDN.ObrotySalda
 @DataOd     DATETIME,
 @DataDo     DATETIME,
 @Bufor     SMALLINT,
 @OObId     INT,
 @AccId     INT,
 @BO      SMALLINT,
 @OperatorID    INT = 0,
 @Filtr     NVARCHAR(1000) = '',
 @Maska     NVARCHAR(50)   = '',
 @NegacjaMaski   TINYINT = 0 ,
 @Waluta     NVARCHAR(3) = NULL,
 @UkryjZeroweSalda  TINYINT = 0,
 @UkryjZeroweObroty  TINYINT = 0
AS
SET NOCOUNT ON
-- Deklaracja zmiennych pomocniczych
DECLARE @PoczatekOkresu DATETIME
DECLARE @KoniecOkresu   DATETIME
DECLARE @PelnyOkres     SMALLINT
DECLARE @MaAnalityke    SMALLINT
DECLARE @RokMiesOd      INT
DECLARE @RokMiesDo      INT
DECLARE @SqlRetStm      NVARCHAR(2000)
-- Sprawdzenie, czy podano @AccId lub OObId
SET @OObId     = IsNull(@OObId,    0)
SET @AccId     = IsNull(@AccId,    0)
-- UWAGA! dotyczy to tylko wersji testowej, nie może się to znaleźć w wersji produkcyjnej
 if CHARINDEX( 'ZakazDoKonta', @Filtr) <> 0
  begin
   exec CDN.RiseOptimaException 32529
   SET NOCOUNT OFF
   RETURN
  end
If @Waluta Is Not Null And Exists (Select * From CDN.Firma Where Fir_Numer=3 And Fir_Wartosc=@Waluta)
 Set @Waluta = ''
IF @OObId = 0 AND @AccId = 0
 BEGIN
  exec CDN.RiseOptimaException 32530
  SET NOCOUNT OFF
  RETURN
 END
-- Inicjalizacja zmiennych pomocniczych
SET @Bufor       = IsNull(@Bufor,    0)
SET @BO          = IsNull(@BO,       0)
SET @PelnyOkres  = 0
SET @MaAnalityke = 0
SET @Maska       = LTrim(RTrim(IsNull(@Maska,'')))
IF IsNull(@NegacjaMaski,0)=0
  SET @NegacjaMaski = 0
ELSE
  SET @NegacjaMaski = 1
SET @Filtr       = LTrim(RTrim(IsNull(@Filtr,'')))
-- Pobranie OObId i parametrów konta, jeśli obliczamy dla konta
IF @AccId <> 0
BEGIN
 IF NOT EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @AccId)
  BEGIN
   exec CDN.RiseOptimaException 32471
   SET NOCOUNT OFF
   RETURN
  END
 SELECT @OObId = Acc_OObId FROM CDN.Konta WHERE Acc_AccId = @AccId
 IF EXISTS (SELECT * FROM CDN.Konta WHERE Acc_ParId = @AccId) SET @MaAnalityke = 1
END
-- Sprawdzanie zależności czasowych
SELECT
 @PoczatekOkresu = OOb_DataOtw,
 @KoniecOkresu = OOb_DataKoncowa
FROM CDN.OkresyObrach
WHERE OOb_OObId = @OObId
IF @BO = 1
 BEGIN
  SET @DataOd = @PoczatekOkresu
  SET @DataDo = @KoniecOkresu
 END
IF @DataOd IS NULL SET @DataOd = @PoczatekOkresu
IF @DataDo IS NULL SET @DataDo = @KoniecOkresu
IF (@DataOd NOT BETWEEN @PoczatekOkresu AND @KoniecOkresu) AND (@DataDo NOT BETWEEN @PoczatekOkresu AND @KoniecOkresu)
 BEGIN
  exec CDN.RiseOptimaException 32472
  SET NOCOUNT OFF
  RETURN
 END
IF @DataOd = @PoczatekOkresu
  SET @RokMiesOd = 100 * YEAR(@DataOd) + MONTH(@DataOd)
ELSE
 BEGIN
  IF DAY(@DataOd) = 1
   SET @RokMiesOd = 100 * YEAR(@DataOd) + MONTH(@DataOd)
  ELSE
   SET @RokMiesOd = 0
 END
IF @DataDo = @KoniecOkresu
 BEGIN
  SET @RokMiesDo = 100 * YEAR(@DataDo) + MONTH(@DataDo)
  SET @PelnyOkres = 1
 END
ELSE
 BEGIN
  IF DAY(DATEADD(day, 1, @DataDo)) = 1
   SET @RokMiesDo = 100 * YEAR(@DataDo) + MONTH(@DataDo)
  ELSE
   SET @RokMiesDo = 0
 END
CREATE TABLE #Obroty (
 Tmp_AccId  INT,
 Tmp_BoWn  NUMERIC(15,2),
 Tmp_BoMa  NUMERIC(15,2),
 Tmp_ObrotyWn NUMERIC(15,2),
 Tmp_ObrotyMa NUMERIC(15,2),
 Tmp_ObrotyTotWn NUMERIC(15,2),
 Tmp_ObrotyTotMa NUMERIC(15,2),
 Tmp_SaldoWn  NUMERIC(15,2),
 Tmp_SaldoMa  NUMERIC(15,2),
 Tmp_PrevSaldoWn NUMERIC(15,2),
 Tmp_PrevSaldoMa NUMERIC(15,2)
 )
CREATE UNIQUE INDEX TmpId ON #Obroty(Tmp_AccId)
IF @RokMiesOd <> 0 AND @RokMiesDo <> 0
 exec CDN.ObrotySaldaObroty  @RokMiesOd, @RokMiesDo, @Bufor, @OObId, @AccId, @BO, @PelnyOkres, @MaAnalityke, @Waluta
ELSE
 exec CDN.ObrotySaldaDekrety @DataOd,    @DataDo,    @Bufor, @OObId, @AccId, @BO, @PelnyOkres, @MaAnalityke, @Waluta
-- Aktualizacja sald i obrotów oraz BO na kontach analitycznych
UPDATE #Obroty
SET
 Tmp_SaldoWn = CASE WHEN Tmp_BOWn + Tmp_ObrotyTotWn - (Tmp_BOMa + Tmp_ObrotyTotMa) > 0 THEN Tmp_BOWn + Tmp_ObrotyTotWn - (Tmp_BOMa + Tmp_ObrotyTotMa) ELSE 0 END,
 Tmp_SaldoMa = CASE WHEN Tmp_BOMa + Tmp_ObrotyTotMa - (Tmp_BOWn + Tmp_ObrotyTotWn) > 0 THEN Tmp_BOMa + Tmp_ObrotyTotMa - (Tmp_BOWn + Tmp_ObrotyTotWn) ELSE 0 END,
 Tmp_PrevSaldoWn = CASE WHEN Tmp_BOWn + Tmp_ObrotyTotWn - Tmp_ObrotyWn - (Tmp_BOMa + Tmp_ObrotyTotMa - Tmp_ObrotyMa) > 0 THEN Tmp_BOWn + Tmp_ObrotyTotWn - Tmp_ObrotyWn - (Tmp_BOMa + Tmp_ObrotyTotMa - Tmp_ObrotyMa) ELSE 0 END,
 Tmp_PrevSaldoMa = CASE WHEN Tmp_BOMa + Tmp_ObrotyTotMa - Tmp_ObrotyMa - (Tmp_BOWn + Tmp_ObrotyTotWn - Tmp_ObrotyWn) > 0 THEN Tmp_BOMa + Tmp_ObrotyTotMa - Tmp_ObrotyMa - (Tmp_BOWn + Tmp_ObrotyTotWn - Tmp_ObrotyWn) ELSE 0 END
 --Tmp_BOWn = CASE WHEN Tmp_BOWn - Tmp_BOMa > 0 THEN Tmp_BOWn - Tmp_BOMa ELSE 0 END,
 --Tmp_BOMa = CASE WHEN Tmp_BOMa - Tmp_BOWn > 0 THEN Tmp_BOMa - Tmp_BOWn ELSE 0 END
IF IsNull(@UkryjZeroweSalda,0) <> 0
  DELETE FROM #Obroty WHERE Tmp_SaldoWn  = 0 AND Tmp_SaldoMa  = 0
--IF IsNull(@UkryjZeroweObroty,0) <> 0
--  DELETE FROM #Obroty WHERE Tmp_ObrotyWn  = 0 AND Tmp_ObrotyMa  = 0
IF @AccId = 0 OR @MaAnalityke = 1 OR @BO = 1
BEGIN
 DECLARE @SynId INT
 DECLARE @SaldoR SMALLINT
 DECLARE @AccRozrachunkowe SMALLINT
 DECLARE @Tmp_BoWn NUMERIC(15,2)
 DECLARE @Tmp_BoMa NUMERIC(15,2)
 DECLARE @Tmp_ObrotyWn NUMERIC(15,2)
 DECLARE @Tmp_ObrotyMa NUMERIC(15,2)
 DECLARE @Tmp_ObrotyTotWn NUMERIC(15,2)
 DECLARE @Tmp_ObrotyTotMa NUMERIC(15,2)
 DECLARE @Tmp_SaldoWn NUMERIC(15,2)
 DECLARE @Tmp_SaldoMa NUMERIC(15,2)
 DECLARE @Tmp_PrevSaldoWn NUMERIC(15,2)
 DECLARE @Tmp_PrevSaldoMa NUMERIC(15,2)
 IF (@AccId = 0 OR @BO = 1) AND (@Maska <> '' Or @Waluta Is Not Null)
 BEGIN
  Declare @L Int, @InRegEx TinyInt, @MaskaTmp NVARCHAR(50), @Znak Char(1)
  Set @MaskaTmp = ''
  Set @InRegEx = 0
  Set @L = 1
  While @L<=Len(@Maska)
  Begin
   Set @Znak = SubString(@Maska, @L, 1)
   If @Znak = '[' Set @InRegEx = @InRegEx+1
   If @Znak = ']' Set @InRegEx = @InRegEx-1
   If @InRegEx=0
   Begin
    If @Znak='-' Set @Znak='.'
    If @Znak='*' Set @Znak='%'
    If @Znak='?' Set @Znak='_'
   End
   Set @MaskaTmp = @MaskaTmp + @Znak
   Set @L=@L+1
  End
  Set @Maska = @MaskaTmp
  Create Table #Konta (Acx_AccId Int, Acx_NumerIdx NVARCHAR(50), Acx_ParId Int, Acx_Rozwin Int, Acx_Analityka Int, Acx_Poziom Int, Acx_SubAnalityka Int, Acx_Rozrachunkowe int)
  Insert InTo #Konta (
   Acx_AccId,
   Acx_NumerIdx,
   Acx_ParId,
   Acx_Rozwin,
   Acx_Analityka,
   Acx_Poziom,
   Acx_SubAnalityka,
   Acx_Rozrachunkowe
   )
  Select
   Acc_AccId,
   Acc_NumerIdx,
   Acc_ParId,
   CASE WHEN Acc_Rozrachunkowe = 1 OR Acc_TypKonta = 3 THEN 1 ELSE 0 END,
   Acc_Analityka,
   Acc_Poziom,
   CASE WHEN
                          @NegacjaMaski = 0 And Acc_NumerIdx Like @Maska + '.%' AND Acc_NumerIdx Not Like @Maska
                         THEN 1
                         ELSE 0
                        END,
   Acc_Rozrachunkowe
  From CDN.Konta
  Where Acc_OObId = @OObId And
                     (@NegacjaMaski = 0 And (Acc_NumerIdx Like @Maska OR Acc_NumerIdx Like @Maska + '.%')
                      Or @NegacjaMaski = 1 And Acc_NumerIdx Not Like @Maska + '%'
                      Or @Maska='' And @Waluta Is Not Null
                      ) And
                      (@Waluta Is Null Or @Waluta=Acc_Waluta And (Acc_Analityka=1 Or @Waluta <> ''))
  Declare @AcxId Int, @AcxNumerIdx NVARCHAR(50), @AcxParId Int, @AcxRozwin Int, @AcxAnalityka Int, @AcxPoziom Int, @AcxSubAnalityka Int, @AcxRozrachunkowe int
  Declare ListaKont Cursor Local Fast_Forward For
  Select Acx_ParId From #Konta
  Open ListaKont
   While 1=1
   Begin
    Fetch Next From ListaKont InTo @AcxId
    If @@Fetch_Status<> 0 Break
    While @AcxId Is Not Null
    Begin
     Select
      @AcxParId = Acc_ParId,
      @AcxNumerIdx = Acc_NumerIdx,
      @AcxRozwin = CASE WHEN Acc_Rozrachunkowe = 1 OR Acc_TypKonta = 3 THEN 1 ELSE 0 END,
      @AcxAnalityka = Acc_Analityka,
      @AcxPoziom = Acc_Poziom,
      @AcxSubAnalityka = CASE WHEN @NegacjaMaski = 0 And Acc_NumerIdx Like @Maska + '.%' AND Acc_NumerIdx Not Like @Maska THEN 1 ELSE 0 END,
      @AcxRozrachunkowe = Acc_Rozrachunkowe
     From CDN.Konta Where Acc_AccId = @AcxId
     If Not Exists (Select * From #Konta Where Acx_AccId = @AcxId)
      Insert Into #Konta (
       Acx_AccId,
       Acx_NumerIdx,
       Acx_ParId,
       Acx_Rozwin,
       Acx_Analityka,
       Acx_Poziom,
       Acx_SubAnalityka,
       Acx_Rozrachunkowe
       )
      Values (
       @AcxId,
       @AcxNumerIdx,
       @AcxParId,
       @AcxRozwin,
       @AcxAnalityka,
       @AcxPoziom,
       @AcxSubAnalityka,
       @AcxRozrachunkowe
       )
     Set @AcxId = @AcxParId
    End
   End
  Close ListaKont
 END
 IF @AccId = 0 OR @BO = 1 -- Sumujemy wszystkie konta
 BEGIN
  IF @Maska = '' And @Waluta Is Null
   DECLARE KontaSyntetyczne CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT Acc_AccId, CASE WHEN Acc_Rozrachunkowe = 1 OR Acc_TypKonta = 3 THEN 1 ELSE 0 END AS Acc_SaldoR, Acc_Rozrachunkowe
   FROM CDN.Konta
   WHERE Acc_OObId = @OObId AND Acc_Analityka = 0
   ORDER BY Acc_Poziom DESC
  ELSE
   DECLARE KontaSyntetyczne CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT Acx_AccId, Acx_Rozwin, Acx_Rozrachunkowe
   FROM #Konta
   WHERE Acx_Analityka = 0
   ORDER BY Acx_Poziom DESC
 END
 ELSE -- Sumujemy tylko konta należące do syntetyki
  DECLARE KontaSyntetyczne CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT Acc_AccId, CASE WHEN Acc_Rozrachunkowe = 1 OR Acc_TypKonta = 3 THEN 1 ELSE 0 END AS Acc_SaldoR, Acc_Rozrachunkowe
  FROM CDN.Konta
  WHERE
   Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1)) AND
   Acc_Analityka = 0
  ORDER BY Acc_Poziom DESC
 OPEN KontaSyntetyczne
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM KontaSyntetyczne INTO @SynId, @SaldoR, @AccRozrachunkowe
  IF @@FETCH_STATUS <> 0 BREAK
  IF @AccId <> 0 OR (@Maska = '' And @Waluta Is Null)
   SELECT
   @Tmp_BOWn = IsNull(SUM(Tmp_BoWn),0),
   @Tmp_BOMa = IsNull(SUM(Tmp_BoMa),0),
   @Tmp_ObrotyWn = IsNull(SUM(Tmp_ObrotyWn),0),
   @Tmp_ObrotyMa = IsNull(SUM(Tmp_ObrotyMa),0),
   @Tmp_ObrotyTotWn = IsNull(SUM(Tmp_ObrotyTotWn),0),
   @Tmp_ObrotyTotMa = IsNull(SUM(Tmp_ObrotyTotMa),0),
   @Tmp_SaldoWn = IsNull(SUM(Tmp_SaldoWn),0),
   @Tmp_SaldoMa = IsNull(SUM(Tmp_SaldoMa),0),
   @Tmp_PrevSaldoWn = IsNull(SUM(Tmp_PrevSaldoWn),0),
   @Tmp_PrevSaldoMa = IsNull(SUM(Tmp_PrevSaldoMa),0)
   FROM #Obroty JOIN CDN.Konta ON ACC_ACCId = Tmp_AccId WHERE Acc_ParId = @SynId
  ELSE
   SELECT
   @Tmp_BOWn = IsNull(SUM(Tmp_BoWn),0),
   @Tmp_BOMa = IsNull(SUM(Tmp_BoMa),0),
   @Tmp_ObrotyWn = IsNull(SUM(Tmp_ObrotyWn),0),
   @Tmp_ObrotyMa = IsNull(SUM(Tmp_ObrotyMa),0),
   @Tmp_ObrotyTotWn = IsNull(SUM(Tmp_ObrotyTotWn),0),
   @Tmp_ObrotyTotMa = IsNull(SUM(Tmp_ObrotyTotMa),0),
   @Tmp_SaldoWn = IsNull(SUM(Tmp_SaldoWn),0),
   @Tmp_SaldoMa = IsNull(SUM(Tmp_SaldoMa),0),
   @Tmp_PrevSaldoWn = IsNull(SUM(Tmp_PrevSaldoWn),0),
   @Tmp_PrevSaldoMa = IsNull(SUM(Tmp_PrevSaldoMa),0)
   FROM #Obroty JOIN #Konta ON Acx_ACCId = Tmp_AccId WHERE Acx_ParId = @SynId
  if @AccRozrachunkowe <> 0 or @SaldoR <> 0
  begin
   SET @Tmp_BOWn = @Tmp_BOWn -- NOP
   SET @Tmp_BOMa = @Tmp_BOMa -- NOP
  end
  else
  begin
   IF @Tmp_BOWn > @Tmp_BOMa
   BEGIN
    SET @Tmp_BOWn = @Tmp_BOWn - @Tmp_BOMa
    SET @Tmp_BOMa = 0
   END
   ELSE
   BEGIN
    SET @Tmp_BOMa = @Tmp_BOMa - @Tmp_BOWn
    SET @Tmp_BOWn = 0
   END
  end
  IF @SaldoR = 0
   BEGIN
    /*
    IF @Tmp_BOWn > @Tmp_BOMa
     BEGIN
     SET @Tmp_BOWn = @Tmp_BOWn -- NOP
     SET @Tmp_BOMa = @Tmp_BOMa -- NOP
      --SET @Tmp_BOWn = @Tmp_BOWn - @Tmp_BOMa
      --SET @Tmp_BOMa = 0
     END
    ELSE
     BEGIN
      SET @Tmp_BOWn = @Tmp_BOWn -- NOP
      SET @Tmp_BOMa = @Tmp_BOMa -- NOP
      --SET @Tmp_BOMa = @Tmp_BOMa - @Tmp_BOWn
      --SET @Tmp_BOWn = 0
     END
    */
    IF @Tmp_SaldoWn > @Tmp_SaldoMa
     BEGIN
      SET @Tmp_SaldoWn = @Tmp_SaldoWn - @Tmp_SaldoMa
      SET @Tmp_SaldoMa = 0
     END
    ELSE
     BEGIN
      SET @Tmp_SaldoMa = @Tmp_SaldoMa - @Tmp_SaldoWn
      SET @Tmp_SaldoWn = 0
     END
    IF @Tmp_PrevSaldoWn > @Tmp_PrevSaldoMa
     BEGIN
      SET @Tmp_PrevSaldoWn = @Tmp_PrevSaldoWn - @Tmp_PrevSaldoMa
      SET @Tmp_PrevSaldoMa = 0
     END
    ELSE
     BEGIN
      SET @Tmp_PrevSaldoMa = @Tmp_PrevSaldoMa - @Tmp_PrevSaldoWn
      SET @Tmp_PrevSaldoWn = 0
     END
   END
  INSERT INTO #Obroty (
   Tmp_AccId ,
   Tmp_BoWn        ,
   Tmp_BoMa        ,
   Tmp_ObrotyWn    ,
   Tmp_ObrotyMa    ,
   Tmp_ObrotyTotWn ,
   Tmp_ObrotyTotMa ,
   Tmp_SaldoWn     ,
   Tmp_SaldoMa     ,
   Tmp_PrevSaldoWn ,
   Tmp_PrevSaldoMa
   )
  VALUES (
   @SynId ,
   @Tmp_BoWn        ,
   @Tmp_BoMa        ,
   @Tmp_ObrotyWn    ,
   @Tmp_ObrotyMa    ,
   @Tmp_ObrotyTotWn ,
   @Tmp_ObrotyTotMa ,
   @Tmp_SaldoWn     ,
   @Tmp_SaldoMa     ,
   @Tmp_PrevSaldoWn ,
   @Tmp_PrevSaldoMa
   )
 END
END
-- SELECT
-- Acc_AccId       As AccId,
-- Tmp_ObrotyWn    As ObrotyWn,
-- Tmp_ObrotyMa    As ObrotyMa,
-- Tmp_ObrotyTotWn As ObrotyTotWn,
-- Tmp_ObrotyTotMa As ObrotyTotMa,
-- Acc_Analityka As Analityka
-- into #temp_obroty from
-- CDN.Konta LEFT OUTER JOIN #Obroty ON Acc_AccId = Tmp_AccId
--
--
-- if @UkryjZeroweObroty <> 0
-- begin
--
--  declare @toDeleteAccId int
--
--  Declare toDeleteZerowe Cursor Local Fast_Forward For
--  select AccId from #temp_obroty
--  where Analityka = 0 and ObrotyWn = 0 AND ObrotyMa  = 0
--
--  Open toDeleteZerowe
--  While 1=1
--  Begin
--   Fetch Next From toDeleteZerowe InTo @toDeleteAccId
--   If @@Fetch_Status<> 0 Break
--
--   delete from #temp_obroty where AccId in (Select Anl_AccId From CDN.KontaAnalityczne (@toDeleteAccId, 1))
--
--  End
--  Close toDeleteZerowe
--  Deallocate toDeleteZerowe
-- END
SET NOCOUNT OFF
SET @SqlRetStm = N'
SELECT
 Acc_AccId     As Tmp_AccId,
 Acc_NumerIdx  As Tmp_NumerIdx,
 Tmp_BoWn        ,
 Tmp_BoMa        ,
 Tmp_ObrotyWn    ,
 Tmp_ObrotyMa    ,
 Tmp_ObrotyTotWn ,
 Tmp_ObrotyTotMa ,
 Tmp_SaldoWn     ,
 Tmp_SaldoMa     ,
 Tmp_SaldoWn - Tmp_PrevSaldoWn As Tmp_PrstSaldaWn,
 Tmp_SaldoMa - Tmp_PrevSaldoMa As Tmp_PrstSaldaMa,
 Acc_Numer     As Tmp_Numer,
 Acc_Nazwa     As Tmp_Nazwa,
 Acc_Nazwa2    As Tmp_Nazwa2,
 Acc_Poziom    As Tmp_Poziom,
 Acc_ParId     As Tmp_ParId,
 Acc_Analityka As Tmp_Analityka
FROM CDN.Konta LEFT OUTER JOIN #Obroty ON Acc_AccId = Tmp_AccId'
--FROM #temp_obroty join CDN.Konta on (Acc_AccId = AccId) LEFT OUTER JOIN #Obroty ON Acc_AccId = Tmp_AccId'
if IsNull(@OperatorID, 0) <> 0
begin
 SET @SqlRetStm = @SqlRetStm + ' left outer join CDN.KontaZakazy on (AcZ_OpeId='+Str(@OperatorID)+'and AcZ_AccId=Acc_AccId)'
 IF @Filtr <> ''
  SET @Filtr     = @Filtr     + ' and AcZ_AccId is NULL'
 ELSE
  SET @Filtr     = @Filtr     + 'AcZ_AccId is NULL'
end
IF @AccId = 0 OR @BO = 1
BEGIN
 IF @Maska = '' And @Waluta Is Null
  SET @SqlRetStm = @SqlRetStm + ' WHERE Acc_OObId='+ STR(@OObId)
 ELSE
  SET @SqlRetStm = @SqlRetStm + ' JOIN #Konta ON Acx_AccId = Acc_AccId WHERE Acc_OObId='+ STR(@OObId) + ' AND Acx_SubAnalityka = 0'
 IF @Filtr <> ''
  SET @SqlRetStm = @SqlRetStm + ' AND ' + @Filtr
END
ELSE
  SET @SqlRetStm = @SqlRetStm + ' WHERE Acc_AccId = ' + STR(@AccId)
SET @SqlRetStm = @SqlRetStm + ' ORDER BY Acc_OObId, Acc_NumerIdx'
EXECUTE sp_executesql @SqlRetStm
IF (@AccId = 0 OR @BO = 1) AND (@Maska <> '' Or @Waluta Is Not Null)
 DROP TABLE #Konta
DROP TABLE #Obroty
--DROP TABLE #temp_obroty
