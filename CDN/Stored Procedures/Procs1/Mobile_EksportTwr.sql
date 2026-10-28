CREATE PROCEDURE [CDN].[Mobile_EksportTwr]
@ID           INT,
@TypEksportu  INT, -- Typ eksportu (0 - ró?nicowy, 1 - pe3ny)
@PackageSize   INT, -- Rozmiar paczki
@PackageNumber INT -- Numer paczki
AS
BEGIN
create table #StawkiVat(
Id int,
Stawka decimal(15,2),
Flaga smallint,
Nazwa NVARCHAR(254))
 declare @dodatkoweTwr table (twrid int)
 DECLARE
  -- zmienne dla notowania
  @TwGNumer            INT,
  @NrCeny              INT,
  @WalutaKoncowa       NVARCHAR(3),
  @sqltxt              NVARCHAR (1000),
  @TmpSrvName          SYSNAME,
  @ServerCfgString     NVARCHAR(512),
  @BazaCfgString       NVARCHAR(512),
  @WalOstrzegaj        NVARCHAR(3),
  @TrN_DataDokChar     NVARCHAR(25),
  @KursLWalutaKoncowa  DECIMAL(15,4),
  @KursMWalutaKoncowa  DECIMAL(5,0),
  @DSta_TS_SynchroTwr  DATETIME
  select @DSta_TS_SynchroTwr = DSta_TS_SynchroTwrPotw FROM CDN.DetalStanowiska  WHERE DSta_DStaId = @ID
  update  CDN.DetalStanowiska set DSta_TS_SynchroTwr = GETDATE() WHERE DSta_DStaId = @ID
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
   --RAISERROR('Nie znaleziono Stanowiska w konfiguracji Optimy ', 16, 1)
   EXEC CDN.RaiseOptimaException 34166
   rollback
   SET NOCOUNT OFF
   RETURN
 END
SELECT @TwGNumer =dsta_twggidnumer,@NrCeny=dsta_twcnumer from cdn.detalstanowiska where dsta_dstaid = @ID
insert into #StawkiVat
exec [CDN].[Mobile_EksportStawkiVat]
--RT jeszcze towary z MM :) --
insert into @dodatkoweTwr
select tre_twrid from cdn.detalstanowiska
join cdn.tranag on TrN_MagDocId = DSta_MagId and ISNULL(TrN_GIDNumer,0) = 0
join cdn.traelem on tre_trnid = trn_trnid
where dsta_dstaid = @ID and trn_magdocid = DSta_MagId and TrN_TypDokumentu = 312 and TrN_Bufor = 0
SELECT DISTINCT identity(int,1,1) AS Rank, * INTO #TempMobile FROM
 (
select twr_twrid,
case when Twr_Typ = 0 then 4 else 1 end as Twr_Typ,
Twr_Kod,
Twr_Nazwa,
Twr_Ean,
Twr_NumerKat,
case when Twr_typMinimum = 1 then Twr_MinCenaMarza else 0 end as Twr_MarzaMin,
id as Twr_StawkaVAT,
Gru_GruId as Twr_JmId,
Twr_JM,
Twr_JMCalkowite,
0 as Twr_PartiaDataW,
0 as Twr_TerminW
from cdn.towary
join #StawkiVat on stawka = twr_stawka and flaga = twr_flaga
join cdn.grupy on twr_jm = Gru_Nazwa and Gru_typ = 32
WHERE Twr_TS_Mod >  CASE WHEN @TypEksportu=0 THEN @DSta_TS_SynchroTwr ELSE 0 END AND Twr_NieAktywny = 0
AND EXISTS(SELECT GrONumer FROM CDN.TwrGrupyESklep (@TwGNumer) WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
UNION ALL
select twr_twrid,
case when Twr_Typ = 0 then 4 else 1 end as Twr_Typ ,
Twr_Kod,
Twr_Nazwa,
Twr_Ean,
Twr_NumerKat,
Twr_MarzaMin,
id as Twr_StawkaVAT,
Gru_GruId as Twr_JmId,
Twr_JM,
Twr_JMCalkowite,
0 as Twr_PartiaDataW,
0 as Twr_TerminW
from cdn.towary
join #StawkiVat on stawka = twr_stawka and flaga = twr_flaga
join cdn.grupy on twr_jm = Gru_Nazwa and Gru_typ = 32
WHERE twr_twrid  in (select * from @dodatkoweTwr)
--ORDER BY Twr_TwrId
 ) TableTmp
 DELETE FROM #TempMobile
 WHERE Rank <= @packageSize * (@packageNumber - 1) OR
   Rank > @packageSize * @packageNumber
 SELECT * FROM #TempMobile
CREATE TABLE #TwrJm(
 [TwJ_TwrNumer] [int] NOT NULL,
 [TwJ_TwrLp] [smallint] NOT NULL,
 [TwJ_EAN] [NVARCHAR](40) NULL,
 [TwJ_JednostkaLog] [int],
    [TwJ_DomyslnaSpr] [tinyint],
    [TwJ_DomyslnaZak] [tinyint],
    [TwJ_JmID] [int],
 [TwJ_PrzeliczM] [decimal](15, 0) NULL,
 [TwJ_PrzeliczL] [decimal](15, 0) NULL,
 [TwJ_Waga] [decimal](7, 3) NULL,
 [TwJ_WJm] [NVARCHAR](5) NULL)
/*Jednostki pomocnicze*/
 SELECT  *
 FROM #TwrJm
/*Jednostki pomocnicze koniec*/
--select distinct * from  @Towary
     declare @typycen table (ErpId int, Nazwa NVARCHAR(20), NB NVARCHAR(1), Widoczna bit, DomyslnaCentrum bit)
     insert into @typycen
      select case when DfC_DfCId = 1 then 0 else DfC_DfCId end as ErpId,DFC_Nazwa as Nazwa,DfC_Typ,1 as Widoczna,1 from  cdn.defceny
      where DfC_lp > 0
    --insert into @typycen (erpid,nazwa,widoczna,domyslnacentrum,nb) values(0,'Zakupu',1,0,'N')
    select distinct ErpId, Nazwa, Widoczna from @typycen
drop table #StawkiVat
select 1 as Wan_Id,1 as Wan_Systemowa ,
CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ+2,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2)as Netto,
CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2) as Brutto,
Twc_TwrId,
Case when TwC_TwCNumer = 1 then 0 else  TwC_TwCNumer end as Twc_TwrLp,
case when TwC_TwCNumer = Twr_TwcNumer then 1 else 0 end as DomyslnaTwr,
case when TwC_TwCNumer = Twr_TwcNumer then -1 else 0 end as domyslna
from cdn.twrceny
JOIN cdn.towary on twr_twrid = twc_twrid
LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
JOIN @typycen on erpid= (Case when TwC_TwCNumer = 1 then 0 else  TwC_TwCNumer end )
where twc_twrid in (select twr_twrid from #TempMobile)
ORDER BY Twr_TwrId,domyslna ,DomyslnaCentrum desc, TwC_TwCNumer
DROP TABLE #TempMobile
END
