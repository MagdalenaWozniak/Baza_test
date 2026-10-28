CREATE     PROCEDURE CDN.Budzet
 @OObId     INT,
 @RokMiesiacOd  INT,
 @RokMiesiacDo  INT,
 @Bufor     SMALLINT,
 @PlanRoczny   INT,
 @Maska     NVARCHAR(50),
 @NegacjaMaski  TINYINT,
 @KontoOd    NVARCHAR(50),  -- filtr
 @KontoDo    NVARCHAR(50),  -- filtr
 @Poziom     INT,      -- filtr
 @OperatorID INT
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
-- start defaulty PB!
DECLARE  @DataOd     DATETIME
DECLARE  @DataDo     DATETIME
DECLARE  @AccId      INT
DECLARE  @BO         SMALLINT
DECLARE  @Filtr      NVARCHAR(1000)
DECLARE  @Waluta     NVARCHAR(3)
DECLARE  @UkryjZerowe  TINYINT
Set @DataOd    = Convert(DateTime, Str(@RokMiesiacOd/100)+'-'+Str(@RokMiesiacOd%100)+'-'+'1', 120)
Set @DataDo    = Convert(DateTime, Str(@RokMiesiacDo/100)+'-'+Str(@RokMiesiacDo%100)+'-'+'1', 120)
Set @DataDo    = DateAdd(Day,-1,DateAdd(Month,1,@DataDo))
Set @AccId    = 0
Set @BO      = 0
Set @Filtr     = ''
Set @Waluta    = ''
Set @UkryjZerowe = 0
-- stop defaulty PB!
-- Sprawdzenie, czy podano @AccId lub OObId
SET @OObId     = IsNull(@OObId,    0)
SET @AccId     = IsNull(@AccId,    0)
If @Waluta Is Not Null And Exists (Select * From CDN.Firma Where Fir_Numer=3 And Fir_Wartosc=@Waluta)
 Set @Waluta = ''
IF @OObId = 0 AND @AccId = 0
 BEGIN
  exec CDN.RiseOptimaException 32474
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
 exec CDN.BudzetObrotySaldaObroty  @RokMiesOd, @RokMiesDo, @Bufor, @OObId, @AccId, @BO, @PelnyOkres, @MaAnalityke, @Waluta
ELSE
 exec CDN.ObrotySaldaDekrety @DataOd,    @DataDo,    @Bufor, @OObId, @AccId, @BO, @PelnyOkres, @MaAnalityke, @Waluta
-- Aktualizacja sald i obrotów oraz BO na kontach analitycznych
UPDATE #Obroty
SET
 Tmp_SaldoWn = CASE WHEN Tmp_BOWn + Tmp_ObrotyTotWn - (Tmp_BOMa + Tmp_ObrotyTotMa) > 0 THEN Tmp_BOWn + Tmp_ObrotyTotWn - (Tmp_BOMa + Tmp_ObrotyTotMa) ELSE 0 END,
 Tmp_SaldoMa = CASE WHEN Tmp_BOMa + Tmp_ObrotyTotMa - (Tmp_BOWn + Tmp_ObrotyTotWn) > 0 THEN Tmp_BOMa + Tmp_ObrotyTotMa - (Tmp_BOWn + Tmp_ObrotyTotWn) ELSE 0 END,
 Tmp_PrevSaldoWn = CASE WHEN Tmp_BOWn + Tmp_ObrotyTotWn - Tmp_ObrotyWn - (Tmp_BOMa + Tmp_ObrotyTotMa - Tmp_ObrotyMa) > 0 THEN Tmp_BOWn + Tmp_ObrotyTotWn - Tmp_ObrotyWn - (Tmp_BOMa + Tmp_ObrotyTotMa - Tmp_ObrotyMa) ELSE 0 END,
 Tmp_PrevSaldoMa = CASE WHEN Tmp_BOMa + Tmp_ObrotyTotMa - Tmp_ObrotyMa - (Tmp_BOWn + Tmp_ObrotyTotWn - Tmp_ObrotyWn) > 0 THEN Tmp_BOMa + Tmp_ObrotyTotMa - Tmp_ObrotyMa - (Tmp_BOWn + Tmp_ObrotyTotWn - Tmp_ObrotyWn) ELSE 0 END,
 Tmp_BOWn = CASE WHEN Tmp_BOWn - Tmp_BOMa > 0 THEN Tmp_BOWn - Tmp_BOMa ELSE 0 END,
 Tmp_BOMa = CASE WHEN Tmp_BOMa - Tmp_BOWn > 0 THEN Tmp_BOMa - Tmp_BOWn ELSE 0 END
IF IsNull(@UkryjZerowe,0) <> 0
  DELETE FROM #Obroty WHERE Tmp_SaldoWn  = 0 AND Tmp_SaldoMa  = 0
IF @AccId = 0 OR @MaAnalityke = 1 OR @BO = 1
BEGIN
 DECLARE @SynId INT, @SaldoR SMALLINT
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
  Create Table #Konta (Acx_AccId Int, Acx_NumerIdx NVARCHAR(50), Acx_ParId Int, Acx_Rozwin Int, Acx_Analityka Int, Acx_Poziom Int, Acx_SubAnalityka Int)
  Insert InTo #Konta (
   Acx_AccId,
   Acx_NumerIdx,
   Acx_ParId,
   Acx_Rozwin,
   Acx_Analityka,
   Acx_Poziom,
   Acx_SubAnalityka
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
                        END
  From CDN.Konta
  Where Acc_OObId = @OObId And Acc_KontrolaBudzetu <> 0 and
                     (@NegacjaMaski = 0 And (Acc_NumerIdx Like @Maska OR Acc_NumerIdx Like @Maska + '.%')
                      Or @NegacjaMaski = 1 And Acc_NumerIdx Not Like @Maska + '%'
                      Or @Maska='' And @Waluta Is Not Null
                      ) And
                      (@Waluta Is Null Or @Waluta=Acc_Waluta And (Acc_Analityka=1 Or @Waluta <> ''))
  Declare @AcxId Int, @AcxNumerIdx NVARCHAR(50), @AcxParId Int, @AcxRozwin Int, @AcxAnalityka Int, @AcxPoziom Int, @AcxSubAnalityka Int
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
      @AcxSubAnalityka = CASE WHEN @NegacjaMaski = 0 And Acc_NumerIdx Like @Maska + '.%' AND Acc_NumerIdx Not Like @Maska THEN 1 ELSE 0 END
     From CDN.Konta Where Acc_AccId = @AcxId
     If Not Exists (Select * From #Konta Where Acx_AccId = @AcxId)
      Insert Into #Konta (
       Acx_AccId,
       Acx_NumerIdx,
       Acx_ParId,
       Acx_Rozwin,
       Acx_Analityka,
       Acx_Poziom,
       Acx_SubAnalityka
       )
      Values (
       @AcxId,
       @AcxNumerIdx,
       @AcxParId,
       @AcxRozwin,
       @AcxAnalityka,
       @AcxPoziom,
       @AcxSubAnalityka
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
   SELECT Acc_AccId, CASE WHEN Acc_Rozrachunkowe = 1 OR Acc_TypKonta = 3 THEN 1 ELSE 0 END AS Acc_SaldoR
   FROM CDN.Konta
   WHERE Acc_OObId = @OObId AND Acc_Analityka = 0
   ORDER BY Acc_Poziom DESC
  ELSE
   DECLARE KontaSyntetyczne CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT Acx_AccId, Acx_Rozwin
   FROM #Konta
   WHERE Acx_Analityka = 0
   ORDER BY Acx_Poziom DESC
 END
 ELSE -- Sumujemy tylko konta należące do syntetyki
  DECLARE KontaSyntetyczne CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT Acc_AccId, CASE WHEN Acc_Rozrachunkowe = 1 OR Acc_TypKonta = 3 THEN 1 ELSE 0 END AS Acc_SaldoR
  FROM CDN.Konta
  WHERE
   Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1)) AND
   Acc_Analityka = 0
  ORDER BY Acc_Poziom DESC
 OPEN KontaSyntetyczne
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM KontaSyntetyczne INTO @SynId, @SaldoR
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
  IF @SaldoR = 0
   BEGIN
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
 if @PlanRoczny = 1
 begin
  Set @RokMiesiacOd = 100 * Year(@PoczatekOkresu) + Month(@PoczatekOkresu)
  Set @RokMiesiacDo = 100 * Year(@KoniecOkresu)   + Month(@KoniecOkresu)
 end
create table #budzet (
Tmp_AccId     int,
Tmp_OObId     int,
Tmp_NumerIdx   NVARCHAR(50),
Tmp_BoWn     NUMERIC(15,2),
Tmp_BoMa     NUMERIC(15,2),
Tmp_ObrotyWn   NUMERIC(15,2),
Tmp_ObrotyMa   NUMERIC(15,2),
Tmp_ObrotyTotWn  NUMERIC(15,2),
Tmp_ObrotyTotMa  NUMERIC(15,2),
Tmp_SaldoWn    NUMERIC(15,2),
Tmp_SaldoMa    NUMERIC(15,2),
Tmp_PrstSaldaWn  NUMERIC(15,2),
Tmp_PrstSaldaMa  NUMERIC(15,2),
Tmp_Numer     NVARCHAR(50),
Tmp_Nazwa     NVARCHAR(50),
Tmp_Poziom     int,
Tmp_ParId      int,
Tmp_Analityka    int,
Tmp_BuNId      int,
Tmp_KontrolaBudzetu int,
Tmp_PlanKwotaWn   NUMERIC(15,2),
Tmp_PlanKwotaMa   NUMERIC(15,2),
Tmp_PrzekKwotaWn  NUMERIC(15,2),
Tmp_PrzekKwotaMa  NUMERIC(15,2))
CREATE UNIQUE INDEX budzet_numer ON #budzet(Tmp_Numer)
SET @SqlRetStm = N'
Insert #budzet
SELECT
 Acc_AccId,'
+Str(@OObId)+','+
N'Acc_NumerIdx,
 Tmp_BoWn,
 Tmp_BoMa,
 Tmp_ObrotyWn,
 Tmp_ObrotyMa,
 Tmp_ObrotyTotWn,
 Tmp_ObrotyTotMa,
 Tmp_SaldoWn,
 Tmp_SaldoMa,
 Tmp_SaldoWn - Tmp_PrevSaldoWn,
 Tmp_SaldoMa - Tmp_PrevSaldoMa,
 Acc_Numer,
 Acc_Nazwa,
 Acc_Poziom,
 Acc_ParId,
 Acc_Analityka,
 BuN_BuNID,
 IsNull(Acc_KontrolaBudzetu, 0),
 0.00,
 0.00,
 case IsNull(Acc_KontrolaBudzetu, 0.00) when 1 then IsNull(Tmp_ObrotyWn, 0.00) else 0.00 end,
 case IsNull(Acc_KontrolaBudzetu, 0.00) when 2 then IsNull(Tmp_ObrotyMa, 0.00) else 0.00 end
FROM
CDN.Konta
LEFT OUTER JOIN #Obroty ON Acc_AccId = Tmp_AccId
left OUTER JOIN CDN.BudzetNag on (Acc_KontrolaBudzetu<>0 and Acc_AccID=BuN_AccID and BuN_Finalny=1)
left outer join CDN.KontaZakazy on (AcZ_OpeId='+Str(@OperatorID)+'and (AcZ_AccId = Acc_ParId or AcZ_AccId=Acc_AccId))'
 Set @Filtr =   'Acc_OObId='+Str(@OObID) + ' and AcZ_AccId is NULL'
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
declare @tmp_PlanKwotaWn    NUMERIC(15,2)
declare @tmp_PlanKwotaMa    NUMERIC(15,2)
declare @tmp_PrzekKwotaWn    NUMERIC(15,2)
declare @tmp_PrzekKwotaMa    NUMERIC(15,2)
declare @tmp_numer        NVARCHAR(50)
declare @tmp_oobid       int
declare @tmp_accid       int
declare @tmp_Analityka     int
declare @acc_kontrolaWn        int
declare @acc_kontrolaMa        int
Declare Budzet Cursor Local Fast_Forward For
select  tmp_Accid, tmp_OObId, Tmp_Numer, Tmp_Analityka
from #budzet order by tmp_OObId, Tmp_Numer
--from #budzet where Tmp_Analityka=1 order by tmp_OObId, Tmp_Numer
Open Budzet
While 1=1
Begin
 Fetch Next From Budzet InTo @tmp_Accid, @tmp_OObId, @tmp_numer, @tmp_Analityka
 If @@Fetch_Status<> 0 Break
  Begin
   select   @acc_kontrolaWn  = Sum(case Acc_KontrolaBudzetu when 1 then 1 else 0 end),
        @acc_kontrolaMa  = Sum(case Acc_KontrolaBudzetu when 2 then 1 else 0 end),
        @tmp_PlanKwotaWn = Sum(case IsNull(Acc_KontrolaBudzetu,0) when 1 then IsNull(BuE_Kwota, 0.00) else 0.00 end),
              @tmp_PlanKwotaMa = Sum(case IsNull(Acc_KontrolaBudzetu,0) when 2 then IsNull(BuE_Kwota, 0.00) else 0.00 end)
   from
   CDN.Konta
   left outer join CDN.BudzetNag   on (Acc_KontrolaBudzetu is not null and Acc_KontrolaBudzetu<>0 and Acc_AccID  = BuN_AccId and BuN_Finalny=1)
   left outer join CDN.BudzetElem  on (BuN_BuNId  = BuE_BuNId AND BuE_Miesiac between + Str(@RokMiesiacOd)  and  Str(@RokMiesiacDo) )
   left outer join CDN.KontaZakazy on (AcZ_OpeId=@OperatorID and (AcZ_AccId = Acc_ParId or AcZ_AccId=Acc_AccId))
   where (Acc_OObID = @tmp_OObId and AcZ_AccId is NULL and (CHARINDEX(RTRIM(@tmp_numer)+'-', Acc_Numer)=1 or @tmp_numer = Acc_Numer)) and
        (@NegacjaMaski = 0 And (Acc_NumerIdx Like @Maska OR Acc_NumerIdx Like @Maska + '.%')
     Or @NegacjaMaski = 1 And Acc_NumerIdx Not Like @Maska + '%' Or @Maska='' And @Waluta Is Not Null)
   set @tmp_PlanKwotaWn = IsNull(@tmp_PlanKwotaWn, 0)
   set @tmp_PlanKwotaMa = IsNull(@tmp_PlanKwotaMa, 0)
    update #budzet set  Tmp_PlanKwotaWn = @tmp_PlanKwotaWn,
                     Tmp_PlanKwotaMa = @tmp_PlanKwotaMa,
                     Tmp_PrzekKwotaWn=  case Tmp_KontrolaBudzetu
                                 when 0 then case @acc_kontrolaWn
                                            when 0 then 0.00
                                            else IsNull(Tmp_ObrotyWn,0) - @tmp_PlanKwotaWn
                                          end
                                          when 1 then IsNull(Tmp_ObrotyWn,0) - @tmp_PlanKwotaWn
                                          else 0
                                     end,
                    Tmp_PrzekKwotaMa= case Tmp_KontrolaBudzetu
                                when 0 then case @acc_kontrolaMa
                                           when 0 then 0.00
                                           else IsNull(Tmp_ObrotyMa,0) - @tmp_PlanKwotaMa
                                         end
                                         when 2 then IsNull(Tmp_ObrotyMa,0) - @tmp_PlanKwotaMa
                                         else 0
                                    end
    where tmp_AccID = @tmp_Accid
  End
End
Close Budzet
--tu sumujemy analityki do syntetyk
DEALLOCATE Budzet
Declare Budzet Cursor Local Fast_Forward For
select  tmp_Accid, tmp_OObId, Tmp_Numer
from #budzet where Tmp_Analityka=0 order by tmp_OObId, Tmp_Numer
Open Budzet
While 1=1
Begin
 Fetch Next From Budzet InTo @tmp_Accid, @tmp_OObId, @tmp_numer
 If @@Fetch_Status<> 0 Break
  Begin
   select  @tmp_PrzekKwotaWn  = Sum(IsNull(Tmp_PrzekKwotaWn, 0.00)),
           @tmp_PrzekKwotaMa  = Sum(IsNull(Tmp_PrzekKwotaMa, 0.00)),
       @tmp_PlanKwotaWn   = Sum(IsNull(Tmp_PlanKwotaWn,  0.00)),
       @tmp_PlanKwotaMa   = Sum(IsNull(Tmp_PlanKwotaMa,  0.00))
   from
   #budzet
   where (tmp_OObId = @tmp_OObId and Tmp_Analityka=1 and (CHARINDEX(RTRIM(@tmp_numer)+'-', Tmp_Numer)=1 or @tmp_numer=Tmp_Numer))
--  select @tmp_numer,@tmp_PrzekKwotaWn, @tmp_PrzekKwotaMa
   if  @tmp_PrzekKwotaWn <> 0
   or @tmp_PrzekKwotaMa <> 0
   or @tmp_PlanKwotaWn  <> 0
   or @tmp_PlanKwotaMa  <> 0
    update #budzet set  Tmp_PrzekKwotaWn = @tmp_PrzekKwotaWn,
                         Tmp_PrzekKwotaMa = @tmp_PrzekKwotaMa,
              Tmp_PlanKwotaWn  = @tmp_PlanKwotaWn,
              Tmp_PlanKwotaMa  = @tmp_PlanKwotaMa
    where tmp_AccID = @tmp_Accid
  End
End
Close Budzet
SET NOCOUNT OFF
Set @Filtr = '1=1'
if Len(LTrim(RTrim(@KontoDo))) = 0
  Set @KontoDo = @KontoOd
if Len(LTrim(RTrim(@KontoOd))) <> 0
 Set @Filtr = @Filtr + ' AND (Tmp_NumerIdx Between '''+ @KontoOd +''' AND '''+@KontoDo+''' OR Tmp_NumerIdx Like '''+@KontoOd+'.%'' OR Tmp_NumerIdx Like '''+@KontoDo+'.%'' )'
if @Poziom > 0
  set @Filtr = @Filtr + N' AND tmp_Poziom <= ' + Str(@Poziom)
set @SqlRetStm = N'select * from #budzet where ' + @Filtr + ' order by Tmp_NumerIdx'
EXECUTE sp_executesql @SqlRetStm
IF (@AccId = 0 OR @BO = 1) AND (@Maska <> '' Or @Waluta Is Not Null)
 DROP TABLE #Konta
DROP TABLE #Obroty
DROP TABLE #budzet
