CREATE PROCEDURE [CDN].[ESKLEP_EksportCrosSeling_ver2]
@ID int,
@TypExp INT=1
as
begin
declare
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @WalutaKoncowa    nvarchar(3),
     @sqltxt           NVARCHAR (1000),
     @TmpSrvName       SYSNAME,
     @ServerCfgString  nvarchar(512),
     @BazaCfgString    nvarchar(512),
     @WalOstrzegaj     nvarchar(3),
     @KursLWalutaKoncowa                DECIMAL(15,4),
     @KursMWalutaKoncowa                DECIMAL(5,0),
     @DataDokChar  nvarchar(25),      -- Typ eksportu (0 - różnicowy, 1 - pełny)
  @EsklepCena0Int int,
     @NrCenyInt int,
  @ZaokraglenieCen smallint
CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta nvarchar(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
set @ZaokraglenieCen = 2
select  @TSSynchr = ESS_TS_SynchroTwrPotw, @WalutaKoncowa = ESS_DomyslnaWaluta
       ,@EsklepCena0Int = ESS_EsklepCena0, @NrCenyInt = ESS_NrCeny
   from cdn.eSklepStanowiska where ESS_IdISklep = @ID
     SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 --pobranie notowania
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  SELECT @DataDokChar    = CONVERT(nvarchar(25), GETDATE(), 102)
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
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.PobierzNotowania '''', 2,'''+ @DataDokChar+''','+ @WalOstrzegaj+''
  INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
  EXEC sp_executesql @sqltxt
  IF @WalutaKoncowa = ''
 SELECT @KursLWalutaKoncowa = 1,@KursMWalutaKoncowa =1
  ELSE
 SELECT @KursLWalutaKoncowa = KursL,@KursMWalutaKoncowa =KursM FROM #Notowania WHERE Waluta = @WalutaKoncowa
select
[@ID] = ZTw_ZTwId   ,
[@Kod] = ZTw_Kod,
[@Nazwa] = ZTw_Nazwa,
[@DataOd] = case when ZTw_CzyOgraniczacCzas =1 or ZTw_CzyOgraniczacDaty =1 then
    CONVERT(nvarchar(10), ZTw_DataOd  , 120) + ' ' +
    case when ZTw_CzyOgraniczacCzas =1 then
     CONVERT(nvarchar(5), ZTw_GodzinaOd  , 108) else '00:00' end
   else null end,
[@DataDo] = case when ZTw_CzyOgraniczacCzas =1 or ZTw_CzyOgraniczacDaty =1 then
 CONVERT(nvarchar(10), ZTw_DataDo  , 120) +' '+
    case when ZTw_CzyOgraniczacCzas =1 then
    CONVERT(nvarchar(5), ZTw_GodzinaDo  , 108)  else '23:59' end
   else null end,
[@Godziny] = case when ZTw_CzyOgraniczacCzas =1 or ZTw_CzyOgraniczacDaty =1 then
 case when ZTw_CzyOgraniczacCzas =1 and ZTw_CzyOgraniczacDaty =0 then 1 else 0 end
 else null end
,
(
select *,ROW_NUMBER() OVER (PARTITION BY  [@ID] order by (SELECT 1)) as [@Lp] from
(
select
[@ID] =ZTw_ZTwId ,
[@EID] =-1,
[@TwrID] =ZTw_TwrId   ,
[@Domyslny] =1,
[@RabatTyp] =ZTw_TypRabatu + 1 ,
[@CenaNetto] =
case when ZTw_TypRabatu = 1 then
convert ( DECIMAL(17,4),
 CDN.CenaBruttoPrecyzja( ZTw_Wartosc ,2,rssT.Twr_Stawka ,
  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END,
  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when rssT.Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end) )
else null end
,
[@CenaBrutto] =
case when ZTw_TypRabatu = 1 then
convert ( DECIMAL(17,4),
 CDN.CenaBruttoPrecyzja( ZTw_Wartosc ,1,rssT.Twr_Stawka ,
  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END,
  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when rssT.Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end) )
 else null end
 ,
[@Rabat] = case when ZTw_TypRabatu = 1 then null else ZTw_Wartosc  end ,
[@Prog] =0,
[@IdJM] = 0,
[@Ilosc]= 1
union all
select
[@ID] =ZTw_ZTwId  ,
[@EID] =ZTS_ZTSId,
[@TwrID] =ZTS_TwrId,
[@Domyslny] =0,
[@RabatTyp] =ZTS_TypRabatu + 1 ,
[@CenaNetto] =
case when ZTS_TypRabatu = 1 then
convert ( DECIMAL(17,4),
CDN.CenaBruttoPrecyzja( ZTS_Wartosc ,2,riT.Twr_Stawka ,
 CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END,
 CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when riT.Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end) )
 else null end
 ,
[@CenaBrutto] =
case when ZTS_TypRabatu in ( 1,2) then
convert ( DECIMAL(17,4),
CDN.CenaBruttoPrecyzja( ZTS_Wartosc ,1 ,riT.Twr_Stawka ,
 CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END,
 CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when riT.Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end) )
 else null end ,
[@Rabat] = case when ZTS_TypRabatu in (1,2) then null else ZTS_Wartosc end ,
[@Prog] =0,
[@IdJM] = case when riT.Twr_JM = ZTS_Jm then 0 else riJMGrupy.Gru_GruID end,
[@Ilosc]= ZTS_Ilosc
 from cdn.ZestawyTwrSkladniki
 join cdn.Towary as riT on riT.twr_twrid = ZTs_TwrId
 left outer join #Notowania as ri on  ri.Waluta = ZTS_Waluta
 left outer join CDN.Grupy as riJMGrupy on ZTS_Jm = riJMGrupy.Gru_Nazwa and riJMGrupy.Gru_Typ = 32
 where ZTS_TypRabatu not in (2,3) and ZTw_ZTwId = ZTS_ZTwId
  ) as elementy
  for xml  PATH('CSRI'),TYPE
)
  ,(
  select
[@ID]=ZTS_ZTwId   ,
[@EID] =ZTS_ZTSId,
[@Typ]=case when ZTS_TypRabatu =3  then 1 else 0 end ,
[@TwrID]=ZTS_TwrId   ,
[@RabatTyp]=ZTS_TypRabatu  ,
[@CenaNetto] =
case when ZTS_TypRabatu in(1, 2) then
convert ( DECIMAL(17,4),
CDN.CenaBruttoPrecyzja( ZTS_Wartosc ,2,triT.Twr_Stawka ,
 CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END,
 CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa, case when triT.Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end) )
 else null end
 ,
[@CenaBrutto] =
case when ZTS_TypRabatu in(1, 2) then
convert ( DECIMAL(17,4),
CDN.CenaBruttoPrecyzja( ZTS_Wartosc ,1 ,triT.Twr_Stawka ,
 CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END,
 CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa, case when triT.Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end) )
 else null end,
[@Ilosc]=ZTS_Ilosc    ,
[@IdJM] = case when triT.Twr_JM = ZTS_Jm then 0 else riJMGrupy.Gru_GruID end,
[@Rabat]=case when ZTS_TypRabatu =3  then ZTS_Wartosc else null end
  from cdn.ZestawyTwrSkladniki
  join cdn.Towary as triT on triT.twr_twrid = ZTs_TwrId
 left outer join #Notowania as tri on  tri.Waluta = ZTS_Waluta
 left outer join CDN.Grupy as riJMGrupy on ZTS_Jm = riJMGrupy.Gru_Nazwa and riJMGrupy.Gru_Typ = 32
  where ZTS_TypRabatu in ( 2,3 ) and ZTw_ZTwId = ZTS_ZTwId
  for xml  PATH('GTRI') ,root ('GTR'),TYPE)
    , ( select [@ID]=ZTw_ZTwId , [@KntID] = 0 for xml  PATH('CKN') ,root ('CKNT'),TYPE )
from cdn.ZestawyTwr
join cdn.Towary as rssT on rssT.twr_twrid = ZTw_TwrId
left outer join #Notowania as rss on  rss.Waluta = ZTw_Waluta
where ZTw_ESklep = 1 and
ztw_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
and  GETDATE() < case when  ZTw_CzyOgraniczacDaty =1 and @TypExp=1 then   ZTw_DataDo +1 else GETDATE()+1 end
and cdn.ESKLEP_EksportCrosSelingZestawNieEksportowalny( ztw_ZTwId , @TypExp, @DateTSSynchr, @NrCenyInt, @EsklepCena0Int) = 0
for xml  PATH('CSRS'),type
drop table #Notowania
end
