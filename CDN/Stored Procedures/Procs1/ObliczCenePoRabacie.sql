CREATE PROCEDURE CDN.ObliczCenePoRabacie
 @PodmiotTyp   INT
,@PodmiotId    INT
,@Twr_Id    INT
,@Twr_NumerCeny   INT
,@Twr_Stawka   DECIMAL(5,2)
,@cenaPoRabacie   DECIMAL(17,4) OUTPUT
,@wartoscRabatu   DECIMAL(17,4) OUTPUT
,@komunikat    NVARCHAR(200) OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE
     @Wynik                   NVARCHAR(218)
    ,@WalSys                  NVARCHAR(3)
    ,@WalOstrzegaj            NVARCHAR(3)
    ,@TypRabatu               SMALLINT
    ,@TwC_Typ                 TINYINT
    ,@TwC_Waluta              NVARCHAR(3)
    ,@TwC_Wartosc             DECIMAL(17,4)
    ,@KursL                   DECIMAL(15,4)
    ,@KursM                   DECIMAL(5,0)
    ,@Brak                    INT
    ,@ServerCfgString         NVARCHAR(512)   -- np. 'Z-GAJEWSKI'
    ,@BazaCfgString           NVARCHAR(512)   -- np. 'CDN_Konfiguracja65'
  DECLARE @NumerCeny  INT
  IF @Twr_NumerCeny Is Null OR @Twr_NumerCeny = 0
    SELECT @NumerCeny = Twr_TwcNumer FROM cdn.Towary WHERE Twr_TwrId = @Twr_Id
  ELSE
    SET @NumerCeny = @Twr_NumerCeny
   DECLARE @ZaokraglajDo  SMALLINT
   IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=3048 )
    SELECT @ZaokraglajDo=case when Fir_Wartosc = 1 then 4 else 2 end FROM Cdn.Firma WHERE Fir_Numer=3048
  ELSE
    SELECT @ZaokraglajDo=2
  -- Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)
  IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 ) SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 ELSE SELECT @WalOstrzegaj=1
  SELECT @ServerCfgString = SYS_Wartosc FROM cdn.SystemCdn Where SYS_ID = 1001
  SELECT @BazaCfgString   = SYS_Wartosc FROM cdn.SystemCdn Where SYS_ID = 1002
  -- skeszowanie notowań wszystkich walut z konfiguracji
  declare @sqltxt nvarchar(1000),@TmpSrvName sysname
  set @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS sysname)
  if CAST ( SERVERPROPERTY ('InstanceName') AS sysname ) <> ''
    set @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS sysname)
  set @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
    set @sqltxt = @sqltxt + @ServerCfgString +'].['
  set @sqltxt = @sqltxt + @BazaCfgString+'].CDN.PobierzNotowania '''', 2,'''+ CONVERT(CHAR(10),getdate(),120) +''','+ @WalOstrzegaj+''
  CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
  INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
  exec sp_executesql @sqltxt
  --jaka waluta systemowa
  select @WalSys = Waluta from #Notowania where Systemowa=1
  -- parametry ceny
  SELECT TOP 1
    @Brak        = Brak,
    @TwC_Typ     = TwC_Typ,
    @TwC_Wartosc = TwC_Wartosc,
    @TwC_Waluta  = TwC_Waluta,
    @KursL   = CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END,
    @KursM   = CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END,
 @ZaokraglajDo = case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end
  FROM cdn.TwrCeny
     JOIN cdn.Towary ON Twr_TwrId = TwC_TwrId
      AND TwC_TwrId = @Twr_Id
      AND TwC_TwCNumer = @NumerCeny
      LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
  SET @Komunikat=''
  IF @Brak = 1
    BEGIN
      SET @Komunikat = '##OPT25003##%%Opis%%=' + @TwC_Waluta+ '##'--'Błąd ustalania kursu waluty '+ @TwC_Waluta+' dla ceny towaru.'
    END
  -- określenie rabatu
  SELECT TOP 1
    @TypRabatu      = TypRabatu,
    @WartoscRabatu  = RabatCena,
    @TwC_Typ        = CASE WHEN TypRabatu = 1 THEN TypCenyNB ELSE @TwC_Typ END,
    @TwC_Waluta     = CASE WHEN TypRabatu = 1 THEN Waluta    ELSE @TwC_Waluta END
  FROM CDN.fnObliczRabat ( @PodmiotTyp, @PodmiotId, @Twr_Id )
  IF @TypRabatu = 0  -- rabat procentowy
    SET  @CenaPoRabacie  = round(@TwC_Wartosc * (100 - @WartoscRabatu) / 100,@ZaokraglajDo)
  ELSE              -- rabat "stała cena"
    SELECT
        @CenaPoRabacie  = @WartoscRabatu,
        @WartoscRabatu  = 0
   -- jeśli waluta inna niż systemowa, to pobierz kurs
  IF @TwC_Waluta <> @WalSys AND ISNULL(@TwC_Waluta,'') <> ''
    SELECT
      @KursL = KursL,
      @KursM = KursM
    FROM #Notowania  WHERE Waluta = @TwC_Waluta
  ELSE -- jeśli jest systemowa, to wpisz symbol waluty systemowej i kurs 1:1
    SELECT
      @KursL  = 1,
      @KursM  = 1
  SET @CenaPoRabacie = round(@CenaPoRabacie *( @KursL / @KursM ),@ZaokraglajDo)
  IF @TwC_Typ = 2 -- cena brutto, to przelicz na netto
    SET @CenaPoRabacie = round(@CenaPoRabacie -  ( @CenaPoRabacie * ( @Twr_Stawka / ( 100 + @Twr_Stawka ) ) ),@ZaokraglajDo)
  -- kill kesza z notowaniami
  DROP TABLE #Notowania
END
