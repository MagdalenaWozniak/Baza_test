CREATE  PROCEDURE [CDN].[Detal_EksportTwr]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
 ,@TwrId int
AS
SET NOCOUNT ON
 DECLARE
  -- zmienne dla notowania
  @TwGNumer      INT,
  @NrCeny        INT,
  @WalutaKoncowa    NVARCHAR(3),
  @sqltxt           NVARCHAR (1000),
  @TmpSrvName       SYSNAME,
  @ServerCfgString  NVARCHAR(512),
  @BazaCfgString    NVARCHAR(512),
  @WalOstrzegaj     NVARCHAR(3),
  @TrN_DataDokChar  NVARCHAR(25),
  @KursLWalutaKoncowa                DECIMAL(15,4),
  @KursMWalutaKoncowa                DECIMAL(5,0),
  -- zmienne dla kursora
  @OptimaId int,
  @Kod nvarchar(50),
  @NumerKat nvarchar(40),
  @SWW nvarchar(20),
  @EAN nvarchar(40),
  @Nazwa nvarchar(255),
  @Opis nvarchar(254),
  @JM nvarchar(20),
  @JMCalkowite tinyint,
  @Kaucja tinyint,
  @Cena decimal(17, 4),
  @Waluta nvarchar(3),
  @SONId int,
  @Stawka decimal(5, 2),
  @Flaga smallint,
  @KntId int,
  @NieAktywny tinyint,
  @DateTSSynchrNew DATETIME,
  @DSta_TS_SynchroTwr DATETIME,
  @CzyAktualizowac INT,
  @Typ TinyInt
  SET @CzyAktualizowac =  0
  select @DSta_TS_SynchroTwr = DSta_TS_SynchroTwr FROM CDN.DetalStanowiska  WHERE DSta_DStaId = @ID
 if @DSta_TS_SynchroTwr < @DateTSSynchr
    set @DateTSSynchr  = @DSta_TS_SynchroTwr
 --pobranie notowania
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  SELECT @TrN_DataDokChar    = CONVERT(NVARCHAR(25), GETDATE(), 102)
  -- 1 = "Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)"
  IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 )
    SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540
  ELSE
    SELECT @WalOstrzegaj=1
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
    SET @sqltxt = @sqltxt + @ServerCfgString +'].['
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.PobierzNotowania '''', 2,'''+ @TrN_DataDokChar+''','+ @WalOstrzegaj+''
  CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
  INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
  EXEC sp_executesql @sqltxt
    IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849) SELECT @WalutaKoncowa = '' ELSE SELECT @WalutaKoncowa = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849
  IF @WalutaKoncowa = ''
 SELECT @KursLWalutaKoncowa = 1,@KursMWalutaKoncowa =1
  ELSE
 SELECT @KursLWalutaKoncowa = KursL,@KursMWalutaKoncowa =KursM FROM #Notowania WHERE Waluta = @WalutaKoncowa
 IF NOT EXISTS (select dsta_dstaid from cdn.detalstanowiska where dsta_dstaid = @ID)
 BEGIN
   RAISERROR('Nie znaleziono Stanowiska w konfiguracji Optimy ', 16, 1)
   rollback
   SET NOCOUNT OFF
   RETURN
 END
-- Grupa,Cena dla stanowiska detalu
SELECT @TwGNumer =dsta_twggidnumer,@NrCeny=dsta_twcnumer,@DateTSSynchrNew = GetDate() from cdn.detalstanowiska where dsta_dstaid = @ID
if @CzyTaSamaBaza = 1
BEGIN
 if @DateTSSynchr = convert(datetime,0,120) and @TwrId = 0
   update CDN.DetalStanTowary SET DSTwr_NieAktywny = 1 WHERE DSTwr_NieAktywny = 0 AND DSTwr_StanDetalID = @ID
if @TwrId = 0
if  ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1470 ) <> 4
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
SELECT
 Twr_TwrId AS Twr_OptimaId,
 Twr_Kod,
 Twr_NumerKat,
 Twr_SWW,
 Twr_EAN,
 Twr_Nazwa,
 Twr_Opis,
 Twr_JM,
 Twr_JMCalkowite,
 Twr_Kaucja,
 CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2) as Twr_Cena,
 @WalutaKoncowa as Twr_Waluta,
 ISNULL(Twr_SONId, 0) as Twr_SONId,  -- opakowanie zwrotne id schematu opak
 Twr_Stawka,
 Twr_Flaga, --jak 0% to moze byc 0 NP lub ZW
 Twr_KntId,
 Twr_NieAktywny,
 Twr_Typ
FROM CDN.Towary
INNER JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrID
LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
WHERE Twr_TS_Mod >  @DateTSSynchr AND TwC_TwCNumer = @NrCeny
AND EXISTS(SELECT GrONumer FROM CDN.TwrGrupyESklep (@TwGNumer) WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
else
DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
SELECT
 Twr_TwrId AS Twr_OptimaId,
 Twr_Kod,
 Twr_NumerKat,
 Twr_SWW,
 Twr_EAN,
 Twr_Nazwa,
 Twr_Opis,
 Twr_JM,
 Twr_JMCalkowite,
 Twr_Kaucja,
 CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2) as Twr_Cena,
 @WalutaKoncowa as Twr_Waluta,
 ISNULL(Twr_SONId, 0) as Twr_SONId,  -- opakowanie zwrotne id schematu opak
 Twr_Stawka,
 Twr_Flaga, --jak 0% to moze byc 0 NP lub ZW
 Twr_KntId,
 Twr_NieAktywny,
 Twr_Typ
FROM CDN.Towary
INNER JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrID
LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
WHERE Twr_TS_Mod >  @DateTSSynchr AND TwC_TwCNumer = @NrCeny
AND EXISTS(SELECT GrONumer FROM CDN.TwrGrupyESklep (@TwGNumer) WHERE GIDTyp = 16 AND GIDNumer = Twr_GIDNumer )
else
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
SELECT
 Twr_TwrId AS Twr_OptimaId,
 Twr_Kod,
 Twr_NumerKat,
 Twr_SWW,
 Twr_EAN,
 Twr_Nazwa,
 Twr_Opis,
 Twr_JM,
 Twr_JMCalkowite,
 Twr_Kaucja,
 CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2) as Twr_Cena,
 @WalutaKoncowa as Twr_Waluta,
 ISNULL(Twr_SONId, 0) as Twr_SONId,  -- opakowanie zwrotne id schematu opak
 Twr_Stawka,
 Twr_Flaga, --jak 0% to moze byc 0 NP lub ZW
 Twr_KntId,
 Twr_NieAktywny,
 Twr_Typ
FROM CDN.Towary
INNER JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrID
LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
where twr_twrid = @TwrId AND TwC_TwCNumer = @NrCeny
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO  @OptimaId,
 @Kod,
 @NumerKat,
 @SWW,
 @EAN,
 @Nazwa,
 @Opis,
 @JM,
 @JMCalkowite,
 @Kaucja,
 @Cena,
 @Waluta,
 @SONId,
 @Stawka,
    @Flaga,
    @KntId,
    @NieAktywny,
    @Typ
          IF @@FETCH_STATUS <> 0 BREAK
exec [CDN].[DetalStan_AktualizujTowary]
    @ID,
 @OptimaId,
 @Kod,
 @NumerKat,
 @SWW,
 @EAN,
 @Nazwa,
 @Opis,
 @JM,
 @JMCalkowite,
 @Kaucja,
 @Cena,
 @Waluta,
 @SONId,
 @Stawka,
    @Flaga,
    @KntId,
    @NieAktywny,
    @Typ,
    @DateTSSynchr,
    @DateTSSynchrNew
  UPDATE CDN.Towary SET Twr_GidFirma = 2 WHERE Twr_TwrId = @OptimaId AND ISNULL(Twr_GidFirma,0) = 0
  SET @CzyAktualizowac =  1
END
   -- po udanym update towarow ustawiamy date
    if @CzyAktualizowac = 1
    BEGIN
    -- po udanym update towarow ustawiamy date
     UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroTwr = @DateTSSynchrNew WHERE DSKnf_StanDetalID = @ID
      UPDATE CDN.DetalStanowiska SET DSta_TS_SynchroTwr = @DateTSSynchrNew WHERE DSta_DStaId = @ID
    END
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
SELECT
 Twr_TwrId AS Twr_OptimaId,
 Twr_Kod,
 Twr_NumerKat,
 Twr_SWW,
 Twr_EAN,
 Twr_Nazwa,
 Twr_Opis,
 Twr_JM,
 Twr_JMCalkowite,
 Twr_Kaucja,
 CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2) as Twr_Cena,
 @WalutaKoncowa as Twr_Waluta,
 Twr_SONId,  -- opakowanie zwrotne id schematu opak
 Twr_Stawka,
 Twr_Flaga, --jak 0% to moze byc 0 NP lub ZW
 Twr_NieAktywny,
 Twr_Typ,
 @DateTSSynchr,
 @DateTSSynchrNew
FROM CDN.Towary
INNER JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrID
LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
WHERE Twr_TS_Mod >  @DateTSSynchr AND TwC_TwCNumer = @NrCeny
AND EXISTS(SELECT GrONumer FROM CDN.TwrGrupyESklep (@TwGNumer) WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
SET NOCOUNT OFF
