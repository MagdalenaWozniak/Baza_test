CREATE PROCEDURE CDN.Med_EksportTowary
  @ID INT      -- ID Stanowiska
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
  @KursMWalutaKoncowa                DECIMAL(5,0)
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
SELECT @TwGNumer =dsta_twggidnumer,@NrCeny=dsta_twcnumer from cdn.detalstanowiska where dsta_dstaid = @ID
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
 CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ+2,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2)as Twr_CenaNetto,
 CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2) as Twr_CenaBrutto,
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
WHERE TwC_TwCNumer = @NrCeny
AND EXISTS(SELECT GrONumer FROM CDN.TwrGrupyESklep (@TwGNumer) WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
SET NOCOUNT OFF
