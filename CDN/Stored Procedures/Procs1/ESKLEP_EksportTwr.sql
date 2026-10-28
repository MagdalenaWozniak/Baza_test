CREATE PROCEDURE [CDN].[ESKLEP_EksportTwr]
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu cennika (0 - różnicowy, 1 - pełny)
 , @ExpCen int = 0 -- Export tylko cen ( 0 - nie, 1 - tak )
AS
SET NOCOUNT ON
 DECLARE
     @ESSID            int,
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT,
     @NrCeny           nvarchar(254),
     @NrCenyInt        INT,
     @NrCenyPop        nvarchar(254),
     @NrCenyPopInt     INT,
     @EsklepCena0        nvarchar(254),
     @EsklepCena0Int     INT,
     @WalutaKoncowa    nvarchar(3),
     @sqltxt           NVARCHAR (1000),
     @TmpSrvName       SYSNAME,
     @ServerCfgString  nvarchar(512),
     @BazaCfgString    nvarchar(512),
     @WalOstrzegaj     nvarchar(3),
     @TrN_DataDokChar  nvarchar(25),
     @TrE_Cena0WD      DECIMAL(18,4),
     @KursLWalutaKoncowa    DECIMAL(15,4),
     @KursMWalutaKoncowa    DECIMAL(5,0),
     @ZaokraglenieCen       smallint
     CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
     CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta nvarchar(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
  create Table #towary (Twr_TwrId INT,Twr_Stawka decimal(5,2),Twr_CenaZCzteremaMiejscami tinyint,Twr_Kod nvarchar(50), Twr_Nazwa nvarchar(255), Twr_Opis nvarchar(MAX) Primary key (Twr_twrid))
  --atr bin pierwszy
     CREATE TABLE #tmpRecordSet2(
           /* Zalaczniki */ DBLId INT, DBLTwrId INT,DBLTyp SMALLINT,  DBLJezykID Smallint,DBLDABID INT, DBLTagLink nvarchar(100),DBLTagAlt nvarchar(500),DBLTagRel TINYINT,DBLTagtitle nvarchar(500), DBLLp INT
     )
     --atr bin  - druga tab
     CREATE TABLE #tmpRecordSet3(
           /* Zalaczniki */ DBLId INT, DBLTwrId INT,DBLTyp SMALLINT,  DBLJezykID Smallint,DBLDABID INT, DBLTagLink nvarchar(100),DBLTagAlt nvarchar(500),DBLTagRel TINYINT,DBLTagtitle nvarchar(500), DBLLp INT
  )
     CREATE TABLE #tmpRecordSet4(
           /* Nazwy */ TwrId INT, TwrKod nvarchar(50), TwrNazwa nvarchar(255), TwrNazwa1 nvarchar(255), TwrOpis nvarchar(MAX), TwrNazwaHTML nvarchar(255), TwrOpisHTML nvarchar(MAX),JezykID smallint,
        TwrJ_OpisKrotki nvarchar(500),TwrJ_MetaTytul nvarchar(100),TwrJ_MetaSlowaKluczowe nvarchar(500),TwrJ_MetaOpis nvarchar(320),TwrJ_Link nvarchar(50),TwrJ_Szukaj nvarchar(512)
     )
  CREATE TABLE #tmpRecordSet41(
           /* Nazwy */ TwrId INT, TwrKod nvarchar(50), TwrNazwa nvarchar(255), TwrNazwa1 nvarchar(255), TwrOpis nvarchar(MAX), TwrNazwaHTML nvarchar(255), TwrOpisHTML nvarchar(MAX),JezykID smallint,
        TwrJ_OpisKrotki nvarchar(500),TwrJ_MetaTytul nvarchar(100),TwrJ_MetaSlowaKluczowe nvarchar(500),TwrJ_MetaOpis nvarchar(320),TwrJ_Link nvarchar(50),TwrJ_Szukaj nvarchar(512)
     )
     CREATE TABLE #tmpRecordSet5(
           JMZ_Id INT,JMZ_GIDNumer INT,JMZ_JezykID INT,JMZ_JM nvarchar(20),JMZ_JML decimal(15,2),JMZ_JMM decimal(7,0),JMZ_Lok int,Domyslny int,JMZLp int,Wys smallint, Szer smallint, Dlug smallint
     )
  CREATE TABLE #tmpRecordSet51(
           JMZ_Id INT,JMZ_GIDNumer INT,JMZ_JezykID INT,JMZ_JM nvarchar(20),JMZ_JML decimal(15,2),JMZ_JMM decimal(7,0),JMZ_Lok int,Domyslny int,JMZLp int
     )
     CREATE TABLE #tmpRecordSet6(
           IGAW_TwrId INT,IGAW_IGAId INT,IGAW_Wartosc nvarchar(100),IGAW_IGDWID INT
     )
   CREATE TABLE #tmpRecordSet61(
           IGAW_TwrId INT,IGAW_IGAId INT,IGAW_Wartosc nvarchar(100),IGAW_IGDWID INT
     )
     CREATE TABLE #tmpRecordSet7(
           TwC_Id INT,TwC_GIDNumer INT,TwC_CenaN DECIMAL(18,4),TwC_CenaB DECIMAL(18,4),TwC_VAT DECIMAL(18,2),TwC_Punkty INT, Precyzja INT
     )
     CREATE TABLE #tmpRecordSet71(
           TwC_Id INT,TwC_GIDNumer INT,TwC_CenaN DECIMAL(18,4),TwC_CenaB DECIMAL(18,4),TwC_VAT DECIMAL(18,2)
     )
     CREATE TABLE #tmpRecordSet8(
           JMZP_Id INT,JMZP_GIDNumer INT,JMZP_JezykID INT,JMZP_JM nvarchar(20),JMZP_JML decimal(15,2),JMZP_JMM decimal(7,0)
     )
  CREATE TABLE #tmpRecordSet81(
           JMZP_Id INT,JMZP_GIDNumer INT,JMZP_JezykID INT,JMZP_JM nvarchar(20),JMZP_JML decimal(15,2),JMZP_JMM decimal(7,0)
     )
     CREATE TABLE #tmpRecordSet(
           /*   Towary */  TwrGIDNumer INT, Twr_Kod nvarchar(50),TwrKod nvarchar(50),TwrJezykID smallint, Twr_Nazwa nvarchar(255),TwrNazwa nvarchar(255),TwrNazwaHTML nvarchar(255),Twr_Nazwa1 nvarchar(255),  TwrNazwa1 nvarchar(255),TwrNazwa1HTML nvarchar(255),
                           TwrKatalog nvarchar(40),JMCalkowite smallint, TwrJm nvarchar(20),  TwrJMPom nvarchar(20),  TwrJML DECIMAL(15,4),  TwrJMM DECIMAL(15,4),JMDomyslna TINYINT, TwrURL nvarchar(255), ProducentID INT,ProducentKod nvarchar(50), MarkaID INT, TwrOkresGwarancji INT, TwrWagaBrutto DECIMAL(15,4), TwrWJm nvarchar(20),
                           Twr_Opis nvarchar(MAX),TwrOpis nvarchar(MAX), TwrOpisHTML nvarchar(MAX),TwrKGO DECIMAL(15,2),TwrTwGGidnumer INT,Twr_ESklepBezRabatu smallint,Twr_ESklepStatus smallint, Twr_ESklepDataDostepnosci int,Twr_ESklepDostepnosc smallint,KontrolaStanow smallint,ZapytajOCene smallint,iGaleria24Grupa int ,Twr_EAN varchar(40)
         ,Twr_MPP int,Twr_CN nvarchar(50), Twr_OpiekunID int,Twr_JMWysCm smallint, Twr_JMSzerCm smallint, Twr_JMDlugCm smallint,
                           Twr_ESklepKalkulacjaDostaw tinyint, Twr_ESklepKalkulacjaDostawWartosc DECIMAL(15,2),Flagi int, Nadrzedny int
         ,TwrJ_OpisKrotki nvarchar(500),TwrJ_MetaTytul nvarchar(100),TwrJ_MetaSlowaKluczowe nvarchar(500),TwrJ_MetaOpis nvarchar(320),TwrJ_Link nvarchar(50),TwrJ_Szukaj nvarchar(512)
           /*     Ceny */ ,TwCTwrLp SMALLINT, TwCWartosc DECIMAL(18,2),TwCWartoscNetto DECIMAL(18,2),TwCStawka DECIMAL(18,2), TwCWaluta nvarchar(3)
           --/* Atrybuty */ ,AtrId INT, DeAId INT,AtKTyp SMALLINT,AtKJezykID smallint, AtKNazwa nvarchar(40), AtrWartosc nvarchar(100), DABID INT, Format Int,Grupuj INT, Lp INT,LpWal INT,Edyt INT
           /* Atr def*/   ,IGAW_TwrId INT,IGAW_IGAId INT,IGAW_Wartosc nvarchar(100),IGAW_IGDWID INT
     /*jednostki*/  ,JMZ_Id INT,JMZ_GIDNumer INT,JMZ_JezykID INT,JMZ_JM nvarchar(20),JMZ_JML decimal(15,2),JMZ_JMM decimal(7,0),JMZ_Lok int,Domyslny int,JMZLp int
     /*ceny*/,TwC_Id INT,TwC_GIDNumer INT,TwC_CenaN DECIMAL(18,4),TwC_CenaB DECIMAL(18,4),TwC_VAT DECIMAL(18,2)
      /*jednostki przelicz*/  ,JMZP_Id INT,JMZP_GIDNumer INT,JMZP_JezykID INT,JMZP_JM nvarchar(20),JMZP_JML decimal(15,2),JMZP_JMM decimal(7,0)
      /* Zalaczniki */ ,DBLId INT, DBLTwrId INT,DBLTyp SMALLINT,  DBLJezykID Smallint,DBLDABID INT, DBLTagLink nvarchar(100),DBLTagAlt nvarchar(500),DBLTagRel TINYINT,DBLTagtitle nvarchar(500), DBLLp INT
     )
     --4 miejsca czy 2
     set @ZaokraglenieCen = 2
     select  @ESSID = ESS_ESSID, @TSSynchr = ESS_TS_SynchroTwrPotw, @TwGNumerInt = ESS_TwGNumer,  @NrCenyInt = ESS_NrCeny,
             @NrCenyPopInt = ESS_NrCenyDomyslnej, @EsklepCena0Int = ESS_EsklepCena0, @WalutaKoncowa = ESS_DomyslnaWaluta
     from cdn.eSklepStanowiska where ESS_IdISklep = @ID
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
     SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837
     --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833) SELECT @NrCeny = 0 ELSE SELECT @NrCeny = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833
     --SELECT @NrCenyInt = CONVERT(INT,@NrCeny)
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1834) SELECT @NrCenyPop = 0 ELSE SELECT @NrCenyPop = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1834
     --SELECT @NrCenyPopInt = CONVERT(INT,@NrCenyPop)
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1889) SELECT @EsklepCena0= 0 ELSE SELECT @EsklepCena0 = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1889
     --SELECT @EsklepCena0Int = CONVERT(INT,@EsklepCena0)
     INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
  delete from #TwrGrupyESklep where GrONumer = @TwGNumerInt and GIDTyp = 16
 --pobranie notowania
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  SELECT @TrN_DataDokChar    = CONVERT(nvarchar(25), GETDATE(), 102)
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
  INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
  EXEC sp_executesql @sqltxt
  --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849) SELECT @WalutaKoncowa = '' ELSE SELECT @WalutaKoncowa = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849
  IF @WalutaKoncowa = ''
 SELECT @KursLWalutaKoncowa = 1,@KursMWalutaKoncowa =1
  ELSE
 SELECT @KursLWalutaKoncowa = KursL,@KursMWalutaKoncowa =KursM FROM #Notowania WHERE Waluta = @WalutaKoncowa
  insert into #towary(Twr_Twrid,Twr_Stawka,Twr_CenaZCzteremaMiejscami,Twr_Kod, Twr_Nazwa, Twr_Opis)
   select distinct twr_twrid,Twr_Stawka,Twr_CenaZCzteremaMiejscami,Twr_Kod, Twr_Nazwa, Twr_Opis from cdn.Towary
  join cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
   left join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
   WHERE  Twes_eSklepID = @ESSID and Twes_Udostepnij = 1 AND Twr_NieAktywny = 0 AND
   case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end
   > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
   AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
IF @ExpCen = 0
BEGIN
  insert into #tmpRecordSet2(DBLId, DBLTwrId, DBLTyp, DBLJezykID, DBLDABID, DBLTagLink, DBLTagAlt, DBLTagRel, DBLTagtitle, DBLLp)
  SELECT distinct DBL_DBLId,DBL_TwrID,0,0,DBL_DABID, DBL_TagLink, DBL_TagAlt, DBL_TagRel, DBL_Tagtitle,DBL_Lp  FROM CDN.DaneBinarneLinki
    JOIN (SELECT MIN(DBL_LP)AS DBLLP, DBL_TwrId as TwrId FROM CDN.DaneBinarneLinki
       join cdn.danebinarne on  DBL_DaBId = DaB_DaBId
  WHERE DBL_DaBId IS NOT NULL  and substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
  in ('jpg','gif','png','jpe','jpeg') and DBL_ESklep =1
  GROUP BY DBL_TwrId) AS ATRBIN ON TwrId = DBL_TwrID and DBL_Lp = DBLLP
     WHERE DBL_ESklep =1 AND DBL_DabId IS NOT NULL
  insert into #tmpRecordSet3(DBLId, DBLTwrId, DBLTyp, DBLJezykID, DBLDABID, DBLTagLink, DBLTagAlt, DBLTagRel, DBLTagtitle, DblLp  )
  SELECT distinct DBL_DBLId,DBL_TwrID,
  case
  when DBL_Typ = 4 then 1
  when DBL_Typ = 5 then 2
  when DBL_Typ = 6 then 3
  when DBL_Typ = 7 then 4
  when DBL_Typ = 3 then 5
  when DBL_Typ = 1 then 6
  when DBL_Typ = 2 then 7
  when DBL_Typ = 8 then 8
  when DBL_Typ = 9 then 9
  else DBL_Typ end
  ,DBL_JezykID,DBL_DABID, DBL_TagLink, DBL_TagAlt, DBL_TagRel, DBL_Tagtitle, DBL_Lp FROM CDN.DaneBinarneLinki
  WHERE DBL_ESklep =1 AND DBL_DaBId IS NOT NULL
  AND DBL_DBLId not in (select DBLId FROM #tmpRecordSet2)
  --13.1 END
  insert into #tmpRecordSet4(TwrId, TwrKod, TwrNazwa, TwrNazwa1, TwrOpis,TwrNazwaHTML, TwrOpisHTML,JezykID,TwrJ_OpisKrotki,TwrJ_MetaTytul,TwrJ_MetaSlowaKluczowe,TwrJ_MetaOpis,TwrJ_Link,TwrJ_Szukaj)
  select
  Twr_TwrId, Twr_Kod,
  case when isnull(JezES.twrj_NazwaHtml,'') = '' then   Twr_Nazwa else JezES.twrj_NazwaHtml end  as Twr_Nazwa,
  '',
  case when isnull(JezES.twrj_opisHtml,'') = '' then   Twr_Opis else JezES.twrj_opisHtml end  as Twr_Opis,
  case when isnull(JezES.twrj_Nazwahtml,'') = '' then  case when isnull(Jez.twrj_Nazwa,'') = '' then Twr_Nazwa else Jez.twrj_Nazwa end else JezES.twrj_Nazwahtml end as Twr_NazwaHTML,
  case when isnull(JezES.twrj_opishtml,'') = '' then  case when isnull(Jez.twrj_opis,'') = '' then Twr_Opis else Jez.twrj_opis end else JezES.twrj_opishtml end as Twr_OpisHTML,
  1,
  isnull(JezES.TwrJ_OpisKrotki,''),isnull(JezES.TwrJ_MetaTytul,''),isnull(JezES.TwrJ_MetaSlowaKluczowe,''),isnull(JezES.TwrJ_MetaOpis,''),isnull(JezES.TwrJ_Link,''),isnull(JezES.TwrJ_Szukaj,'')
   from #towary
  LEFT OUTER JOIN cdn.twrjezykobcy JezES ON JezES.TwrJ_TwrId = Twr_TwrId and  JezES.TwrJ_JezykID = 1 and JezES.TwrJ_eSklepID = @ESSID
  LEFT OUTER JOIN cdn.twrjezykobcy Jez ON Jez.TwrJ_TwrId = Twr_TwrId and  Jez.TwrJ_JezykID = 1 and  Jez.TwrJ_eSklepID = 0
   union
  select
  Twr_TwrId, Twr_Kod,
  case when isnull(JezES.twrj_NazwaHtml,'') = '' then   Twr_Nazwa else JezES.twrj_NazwaHtml end  as Twr_Nazwa,
  '',
  case when isnull(JezES.twrj_opisHtml,'') = '' then   Twr_Opis else JezES.twrj_opisHtml end  as Twr_Opis,
  case when isnull(JezES.twrj_Nazwahtml,'') = '' then  case when isnull(Jez.twrj_Nazwa,'') = '' then Twr_Nazwa else Jez.twrj_Nazwa end else JezES.twrj_Nazwahtml end as Twr_NazwaHTML,
  case when isnull(JezES.twrj_opishtml,'') = '' then  case when isnull(Jez.twrj_opis,'') = '' then Twr_Opis else Jez.twrj_opis end else JezES.twrj_opishtml end as Twr_OpisHTML,
  JezES.TwrJ_JezykID,
  isnull(JezES.TwrJ_OpisKrotki,''),isnull(JezES.TwrJ_MetaTytul,''),isnull(JezES.TwrJ_MetaSlowaKluczowe,''),isnull(JezES.TwrJ_MetaOpis,''),isnull(JezES.TwrJ_Link,''),isnull(JezES.TwrJ_Szukaj,'')
   from #towary
  JOIN cdn.twrjezykobcy JezES ON TwrJ_TwrId = Twr_TwrId and  JezES.TwrJ_JezykID <> 1 and JezES.TwrJ_eSklepID = @ESSID
  left JOIN cdn.twrjezykobcy Jez ON Jez.TwrJ_TwrId = Twr_TwrId and  Jez.TwrJ_JezykID = JezES.TwrJ_JezykID and  Jez.TwrJ_eSklepID = 0
   union
     select
  Twr_TwrId, Twr_Kod,
  Twr_Nazwa,
  '',
  Twr_Opis,
  case when isnull(Jez.twrj_Nazwa,'') = '' then Twr_Nazwa else Jez.twrj_Nazwa end  as Twr_NazwaHTML,
  case when isnull(Jez.twrj_opis,'') = '' then Twr_Opis else Jez.twrj_opis end  as Twr_OpisHTML,
  Jez.TwrJ_JezykID,
  '','','','','',''
   from #towary
  left JOIN cdn.twrjezykobcy Jez ON Jez.TwrJ_TwrId = Twr_TwrId and  Jez.TwrJ_JezykID <> 1 and  Jez.TwrJ_eSklepID = 0
  where  not exists (select * from cdn.twrjezykobcy a where a.TwrJ_JezykID = Jez.TwrJ_JezykID and a.TwrJ_eSklepID = @ESSID) and  Jez.TwrJ_eSklepID = 0
   insert into #tmpRecordSet5(  JMZ_Id ,JMZ_GIDNumer ,JMZ_JezykID ,JMZ_JM ,JMZ_JML ,JMZ_JMM ,JMZ_Lok,Domyslny, JMZLp, Wys, Szer, Dlug )
      select Gru_GruID,A.TwJZ_TwrID,1,A.TwJZ_JM,B.TwJZ_JMPrzelicznikL,B.TwJZ_JMPrzelicznikM,1,A.TwJZ_eSklepDomyslna,A.TwJZ_Lp,B.TwJZ_WysCm,B.TwJZ_SzerCm,B.TwJZ_DlugCm from CDN.TwrJMZ A
    join cdn.TwrJMZ B on  A.TwJZ_TwrID = B.TwJZ_TwrID AND A.TwJZ_JM = B.TwJZ_JM AND B.TwJZ_eSklepID = 0
    join CDN.Grupy on Gru_Nazwa = A.TwJZ_JM and Gru_Typ = 32
 join #towary on Twr_TwrId = A.TwJZ_TwrID
 WHERE A.TwJZ_eSklepID = @ESSID
    insert into #tmpRecordSet8(  JMZP_Id ,JMZP_GIDNumer ,JMZP_JezykID ,JMZP_JM ,JMZP_JML ,JMZP_JMM  )
      select Gru_GruID,A.TwJZ_TwrID,1,A.TwJZ_JM,A.TwJZ_JMPrzelicznikL,A.TwJZ_JMPrzelicznikM from CDN.TwrJMZ A
    join CDN.Grupy on Gru_Nazwa = A.TwJZ_JM and Gru_Typ = 32
join #towary on Twr_TwrId = A.TwJZ_TwrID
   where Twjz_CenaJednostkowa = 1
  INSERT INTO #tmpRecordSet
   SELECT  T.Twr_TwrId, T.Twr_Kod,Nazwy.TwrKod,Nazwy.JezykID, T.Twr_Nazwa,Nazwy.TwrNazwa ,Nazwy.TwrNazwaHTML ,'','','',T.Twr_NumerKat,T.Twr_JMCalkowite,T.Twr_JM,''/*Twr_JMZ*/,1/*Twr_JMPrzelicznikL*/,1/* Twr_JMPrzelicznikM*/,0,T.Twr_Url,ISNULL(T.Twr_PrdID,0),REPLACE (LTRIM(RTRIM(T.Twr_ProducentKod)),' ', ''),ISNULL(T.Twr_MrkID,0),0,T.Twr_WagaKG,'',T.Twr_Opis,Nazwy.TwrOpis,Nazwy.TwrOpisHTML,T.Twr_KosztKGO,
   case when Twes_TwGGidnumer = -1 then -2 else Twes_TwGGidnumer end,
  ISNULL(Twes_ESklepBezRabatu,0),ISNULL(Twes_ESklepStatus,0),case when Twes_ESklepStatus = 0 and Twes_ESklepDostepnyOd = 1   then datediff(d,convert(datetime,'1990-01-01',120),Twes_ESklepDataDostepnosci) else 0 end,
  ISNULL(Twes_ESklepDostepnosc,0),case when Twes_ESklepNieKontrolujStanow = 1 then 0 else T.Twr_Typ end ,ISNULL(Twes_ESklepZapytajOCene,0),T.Twr_IGaleriaKatId,T.Twr_EAN,Twr_SplitPay,
  KCN_Kod ,case when isnull(Twr_OpiekunTyp,0) = 8 then Twr_OpiekunId else null end,Twr_JMWysCm, Twr_JMSzerCm, Twr_JMDlugCm,
  Twes_ESklepKalkulacjaDostaw,case when Twes_ESklepKalkulacjaDostaw = 2 then Twes_ESklepKalkulacjaDostawWartosc else 0 end,
  Twes_ESklepFlaga_Nowosc*2+Twes_ESklepFlaga_Promocja*4+Twes_ESklepFlaga_ProduktzGazetki*8 +Twes_ESklepFlaga_ProduktPolecany*16
  +Twes_ESklepFlaga_Wyprzedaz*32+Twes_ESklepFlaga_SuperJakosc*64+Twes_ESklepFlaga_SuperCena*128+Twes_ESklepFlaga_NajlepiejOceniany*256+Twes_ESklepFlaga_RekomendacjaSprzedawcy*512+ Twes_ESklepFlaga_Nagroda*1024 as Flagi,case when T.Twr_ESklepFantomID IS null OR T.Twr_ESklepFantomID = T.Twr_twrid  then -1 else T.Twr_ESklepFantomID end,
  Nazwy.TwrJ_OpisKrotki,Nazwy.TwrJ_MetaTytul,Nazwy.TwrJ_MetaSlowaKluczowe,Nazwy.TwrJ_MetaOpis,Nazwy.TwrJ_Link,Nazwy.TwrJ_Szukaj,
    case when TwC_TwCNumer = @NrCenyInt then 1 else 2 end, CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,T.Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when T.Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
    CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ+2,T.Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when T.Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
    T.Twr_Stawka, @WalutaKoncowa,
    --AtrId,DeAId,AtKTyp/*1-text,2-zdjecie,3-zdjecie dod*/,AtKJezykID,AtKNazwa, AtrWartosc,DaBId,Format,Grupuj,Lp,LpWal,Edyt,
    IGAW_TwrId ,IGAW_IGAId ,IGAW_Wartosc,IGAW_IGDWID,
    JMZ_Id ,JMZ_GIDNumer ,JMZ_JezykID ,JMZ_JM ,JMZ_JML ,JMZ_JMM ,JMZ_Lok,Domyslny,JMZLp,
     TwC_Id ,TwC_GIDNumer ,TwC_CenaN ,TwC_CenaB ,TwC_VAT,
     JMZP_Id,JMZP_GIDNumer,JMZP_JezykID,JMZP_JM,JMZP_JML,JMZP_JMM,
     DBLId, DBLTwrId, DBLTyp, DBLJezykID, DBLDABID, DBLTagLink, DBLTagAlt, DBLTagRel, DBLTagtitle, DbLLp
    FROM #Towary A
 join cdn.towary T on T.Twr_TwrId = A.Twr_TwrId
    JOIN cdn.TwrESklep on T.Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
    LEFT OUTER JOIN CDN.TwrCeny ON T.Twr_TwrId = TwC_TwrID  AND (TwC_TwCNumer = @NrCenyInt or TwC_TwCNumer = @NrCenyPopInt)
 LEFT OUTER JOIN CDN.KodyCN on Twr_KCNId = KCN_KCNId
    LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
    LEFT OUTER JOIN
    (
    select * from #tmpRecordSet41
    )
    Nazwy ON Nazwy.TwrID = T.Twr_TwrId
    LEFT OUTER JOIN
    (
    select * from #tmpRecordSet61
    )
    IGaleriaAtr ON IGaleriaAtr.IGAW_TwrId = T.Twr_TwrId
    LEFT OUTER JOIN
    (
    select * from #tmpRecordSet71
    )
    Ceny ON Ceny.TwC_GIDNumer = T.Twr_TwrId
    LEFT OUTER JOIN
    (
    select * from #tmpRecordSet51
    )
    JM ON JM.JMZ_GIDNumer = T.Twr_TwrId
    LEFT OUTER JOIN
    (
    select * from #tmpRecordSet81
    )
    JMPrzelicz ON JMPrzelicz.JMZP_GIDNumer = T.Twr_TwrId
    LEFT OUTER JOIN
    (
    select * from #tmpRecordSet2
    union all
    select * from #tmpRecordSet3
    )Zalaczniki on Zalaczniki.DBLTwrId = T.Twr_TwrId
    insert into #tmpRecordSet7( TwC_Id ,TwC_GIDNumer ,TwC_CenaN ,TwC_CenaB ,TwC_VAT,TwC_Punkty, Precyzja )
    select twc_twcnumer,TwC_TwrID,
    case when  TwC_Typ+2 < 3
    then
        ROUND((TwC_Wartosc*(1+ + CASE WHEN TwC_Typ+2 = 1 THEN 1 ELSE 0 END *Twr_Stawka/100.00))*(  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END / CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
    ELSE
        ROUND((TwC_Wartosc-CASE WHEN TwC_Typ+2 = 4 THEN 1 ELSE 0 END*TwC_Wartosc*Twr_Stawka/(100.0+Twr_Stawka))*(  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END / CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
    end ,
    case when  TwC_Typ < 3
    then
        ROUND((TwC_Wartosc*(1+ + CASE WHEN TwC_Typ = 1 THEN 1 ELSE 0 END *Twr_Stawka/100.00))*(  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END / CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
    ELSE
        ROUND((TwC_Wartosc-CASE WHEN TwC_Typ = 4 THEN 1 ELSE 0 END*TwC_Wartosc*Twr_Stawka/(100.0+Twr_Stawka))*(  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END / CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
    end ,
--CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ+2,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
--CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
    twr_stawka,TwC_Punkty,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end
    from cdn.twrceny
 join #towary on Twr_TwrId = Twc_twrid
    LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
    where twc_twcnumer > 1
     if @EsklepCena0Int = 1
     delete from #tmpRecordSet where TwrGIDNumer in( select TwrGIDNumer from #tmpRecordSet  where TwCWartosc = 0  and TwCTwrLp = 1)
  SELECT DISTINCT  1 AS Tag, NULL AS Parent  /* Towary  <TWR> */
    ,TwrGIDNumer AS [TWR!1!GIDNumer], TwrKatalog AS [TWR!1!Symbol],
    TwrJm AS [TWR!1!JM],JMCalkowite AS [TWR!1!JMCalkowite], /*TwrJMPom AS [TWR!1!JMPom],  TwrJML AS [TWR!1!JML],  TwrJMM AS [TWR!1!JMM],JMDomyslna AS [TWR!1!JMDomyslna],*/
    TwrURL AS [TWR!1!URL], ProducentID AS [TWR!1!ProducentID],ProducentKod AS [TWR!1!ProducentKod],MarkaID AS [TWR!1!MarkaID], TwrOkresGwarancji AS [TWR!1!OkresGwarancji],
  TwrWagaBrutto AS [TWR!1!WagaBrutto], TwrWJm AS [TWR!1!WagaJm]
    , TwrKgo AS [TWR!1!Kgo],TwrTwGGidnumer AS [TWR!1!GrupaID]
  ,Twr_ESklepBezRabatu AS [TWR!1!CzyRabat],Twr_ESklepStatus AS [TWR!1!Status], Twr_ESklepDataDostepnosci AS [TWR!1!StatusData],
  Twr_ESklepDostepnosc AS [TWR!1!Dostepnosc],KontrolaStanow AS [TWR!1!KontrolaStanow],ZapytajOCene AS [TWR!1!Zap],
  iGaleria24Grupa AS [TWR!1!iGaleria24Grupa] ,Twr_EAN AS [TWR!1!EAN],Twr_MPP AS[TWR!1!Mpp],Twr_CN AS[TWR!1!Cn], Twr_OpiekunID AS[TWR!1!OpiekunID],Twr_JMWysCm AS[TWR!1!Wys], Twr_JMSzerCm AS[TWR!1!Szer], Twr_JMDlugCm AS[TWR!1!Dlug],
   Twr_ESklepKalkulacjaDostaw AS [TWR!1!KalkulacjaDostaw],Twr_ESklepKalkulacjaDostawWartosc AS [TWR!1!KalkulacjaDostawWartosc],
   Flagi AS [TWR!1!Flagi],Nadrzedny AS [TWR!1!Nadrzedny]
    ,NULL AS [TWRJI!2]
    ,NULL AS [TWRJ!3!GIDNumer], NULL AS [TWRJ!3!JezykID], NULL AS [TWRJ!3!Kod], NULL AS [TWRJ!3!Nazwa], /*NULL AS [TWRJ!3!NazwaHTML],*/ NULL AS [TWRJ!3!Nazwa1], /*NULL AS [TWRJ!3!Nazwa1HTML],*/ NULL AS [TWRJ!3!Opis], /*NULL AS [TWRJ!3!OpisHTML],*/ NULL AS [TWRJ!3!JM] /*NULL AS [TWRJ!3!WagaJM]*/
    ,NULL AS [TWRJ!3!JMPom],NULL AS [TWRJ!3!OpisKrotki],NULL AS [TWRJ!3!PSTitle],NULL AS [TWRJ!3!PSKluczowe],NULL AS [TWRJ!3!POpis],NULL AS [TWRJ!3!URLTitle],NULL AS [TWRJ!3!Szukaj]
    ,NULL AS [TWRJMI!4]
    ,NULL AS [TWRJM!5!ID],NULL AS [TWRJM!5!GIDNumer], NULL AS [TWRJM!5!JezykID], NULL AS [TWRJM!5!JM], NULL AS [TWRJM!5!JML], NULL AS [TWRJM!5!JMM], NULL AS [TWRJM!5!Lok], NULL AS [TWRJM!5!Domyslny], NULL AS [TWRJM!5!Lp], NULL AS [TWRJM!5!Wys], NULL AS [TWRJM!5!Szer], NULL AS [TWRJM!5!Dlug]
    ,NULL AS [CNYI!6]
    ,NULL AS [CNY!7!ID],NULL AS [CNY!7!GIDNumer], NULL AS [CNY!7!CenaN], NULL AS [CNY!7!CenaB], NULL AS [CNY!7!VAT], NULL AS [CNY!7!Punkty], NULL AS [CNY!7!Precyzja]
    ,NULL AS [TWMI!8]
    ,NULL AS [TWM!9!ID],NULL AS [TWM!9!GIDNumer],NULL AS [TWM!9!JezykID],NULL AS [TWM!9!JML],NULL AS [TWM!9!JMM],NULL AS [TWM!9!JM]
    ,NULL AS [ZALI!10]
    ,NULL AS [ZAL!11!ID],NULL AS [ZAL!11!GIDNumer],NULL AS [ZAL!11!Typ], NULL AS [ZAL!11!Lp]
    ,NULL AS [ZALIJ!12]
    ,NULL AS [ZAJ!13!ID],NULL AS [ZAJ!13!JezykID],NULL AS [ZAJ!13!DabID],NULL AS [ZAJ!13!TagLink],NULL AS [ZAJ!13!TagAlt],NULL AS [ZAJ!13!TagRel],NULL AS [ZAJ!13!TagTitle]
  FROM  #tmpRecordSet
   UNION ALL
  SELECT DISTINCT  2 AS Tag, 1 AS Parent       /* Nazwy <TWRJI> */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
    --,NULL
    --,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
    ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL, NULL
    ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
  FROM  #tmpRecordSet
  UNION ALL
  SELECT DISTINCT  3 AS Tag, 2 AS Parent    /* Nazwy <TWRJ> */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
   , NULL
    ,Nazwy.TwrID,Nazwy.JezykID,Nazwy.TwrKod,Nazwy.TwrNazwaHTML,Nazwy.TwrNazwa1,Nazwy.TwrOpisHTML,TwrJm,TwrJmPom,Nazwy.TwrJ_OpisKrotki,Nazwy.TwrJ_MetaTytul,Nazwy.TwrJ_MetaSlowaKluczowe,Nazwy.TwrJ_MetaOpis,Nazwy.TwrJ_Link,Nazwy.TwrJ_Szukaj
 --,NULL
    --,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL, NULL
    ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
  FROM  #tmpRecordSet
  LEFT OUTER JOIN
    (
    select * from #tmpRecordSet4
    )
    Nazwy ON Nazwy.TwrID = TwrGIDNumer
  UNION ALL
  SELECT DISTINCT   4 AS Tag, 1 AS Parent  /* Atrybuty <ATRI> */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
    --,NULL
    --,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL, NULL
 ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
  FROM  #tmpRecordSet
  UNION ALL
  SELECT DISTINCT  5 AS Tag, 4 AS Parent /* Atrybuty IGaleria <ATRP> */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
    --,NULL
    --,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
    ,JM.JMZ_Id ,JM.JMZ_GIDNumer ,JM.JMZ_JezykID ,JM.JMZ_JM ,JM.JMZ_JML ,JM.JMZ_JMM ,JM.JMZ_Lok,JM.Domyslny, JM.JMZLp, JM.Wys, JM.Szer, JM.Dlug
        ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL, NULL
 ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
  FROM  #tmpRecordSet
   LEFT OUTER JOIN
    (
    select * from #tmpRecordSet5
    )
    JM ON JM.JMZ_GIDNumer = TwrGIDNumer
  WHERE JM.JMZ_JM IS NOT NULL
  UNION ALL
  SELECT DISTINCT   6 AS Tag, 1 AS Parent  /* ceny */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
    --,NULL
    --,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL, NULL
 ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
  FROM  #tmpRecordSet
  UNION ALL
  SELECT DISTINCT  7 AS Tag, 6 AS Parent /* ceny */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
    --,NULL
    --,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
   , Ceny.TwC_Id ,Ceny.TwC_GIDNumer ,Ceny.TwC_CenaN ,Ceny.TwC_CenaB ,Ceny.TwC_VAT,Ceny.TwC_Punkty,Precyzja
 ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
  FROM  #tmpRecordSet
  LEFT OUTER JOIN
    (
    select * from #tmpRecordSet7
    )
    Ceny ON Ceny.TwC_GIDNumer = TwrGIDNumer
  WHERE Ceny.TwC_Id IS NOT NULL
  union all
   SELECT DISTINCT   8 AS Tag, 1 AS Parent  /* ceny */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
    --,NULL
    --,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL, NULL
 ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
    FROM  #tmpRecordSet
      UNION ALL
  SELECT DISTINCT  9 AS Tag, 8 AS Parent /* ceny */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
    --,NULL
    --,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
   , NULL ,NULL , NULL , NULL , NULL, NULL, NULL
     ,NULL
    ,JMPrzelicz.JMZP_Id,JMPrzelicz.JMZP_GIDNumer,JMPrzelicz.JMZP_JezykID,JMPrzelicz.JMZP_JML,JMPrzelicz.JMZP_JMM,JMPrzelicz.JMZP_JM
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
    FROM  #tmpRecordSet
 LEFT OUTER JOIN
    (
    select * from #tmpRecordSet8
    )
    JMPrzelicz ON JMPrzelicz.JMZP_GIDNumer = TwrGIDNumer
 WHERE JMPrzelicz.JMZP_Id IS NOT NULL
   union all
   SELECT DISTINCT   10 AS Tag, 1 AS Parent  /* ceny */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL, NULL
 ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
    FROM  #tmpRecordSet
      UNION ALL
  SELECT DISTINCT  11 AS Tag, 10 AS Parent /* zalaczniki */
    ,DBLTwrId, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
   , NULL ,NULL , NULL , NULL , NULL, NULL, NULL
   ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,DBLId, DBLTwrId, DBLTyp, DblLp
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
    FROM  #tmpRecordSet WHERE DBLId IS NOT NULL
    union all
   SELECT DISTINCT   12 AS Tag, 11 AS Parent  /* zalaczniki */
    ,DBLTwrId, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL, NULL
 ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,DBLId ,NULL ,NULL, NULL
    ,NULL
    ,NULL ,NULL ,NULL , NULL , NULL , NULL , NULL
    FROM  #tmpRecordSet WHERE DBLId IS NOT NULL
        UNION ALL
  SELECT DISTINCT  13 AS Tag, 12 AS Parent /* zalaczniki */
    ,DBLTwrId, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
     ,NULL
    ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL
     ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL, NULL, NULL, NULL, NULL
        ,NULL
   , NULL ,NULL , NULL , NULL , NULL, NULL, NULL
   ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,DBLId ,NULL , NULL, NULL
    ,NULL
    ,DBLId ,DBLJezykID, DBLDABID, DBLTagLink, DBLTagAlt, DBLTagRel, DBLTagtitle
    FROM  #tmpRecordSet WHERE DBLId IS NOT NULL
  ORDER BY [TWR!1!GIDNumer],[ZAl!11!ID],1,[TWRJ!3!JezykID]
  --8,9,10,11,12,13,14,15,16, [ZAL!17!Typ] --[ATR!5!ID!Hide], [ATR!5!Typ]
  FOR XML EXPLICIT,  BINARY BASE64
  -- po wyslaniu towaru ustawiamy flage Twr_Oddzialowy (informacja o wysłaniu do e-sklepu jest zapisywana na drugim bicie)
  UPDATE CDN.Towary SET Twr_GidFirma = 1 WHERE Twr_TwrId IN (SELECT DISTINCT TwrGIDNumer FROM  #tmpRecordSet )
END
 ELSE
BEGIN
select
 (
 select
 [@GIDNumer] = TwC_TwrID
,[@ID]= TwC_TwCNumer
,[@CenaN]      = case when  TwC_Typ+2 < 3
then
  ROUND((TwC_Wartosc*(1+ + CASE WHEN TwC_Typ+2 = 1 THEN 1 ELSE 0 END *Twr_Stawka/100.00))*(  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END / CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
ELSE
  ROUND((TwC_Wartosc-CASE WHEN TwC_Typ+2 = 4 THEN 1 ELSE 0 END*TwC_Wartosc*Twr_Stawka/(100.0+Twr_Stawka))*(  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END / CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
end
,[@CenaB] = case when  TwC_Typ < 3
then
  ROUND((TwC_Wartosc*(1+ + CASE WHEN TwC_Typ = 1 THEN 1 ELSE 0 END *Twr_Stawka/100.00))*(  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END / CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
ELSE
  ROUND((TwC_Wartosc-CASE WHEN TwC_Typ = 4 THEN 1 ELSE 0 END*TwC_Wartosc*Twr_Stawka/(100.0+Twr_Stawka))*(  CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END / CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
end
--,[@CenaN]      = CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ+2,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
--,[@CenaB] = CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ  ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
,[@VAT] = Twr_Stawka
,[@Punkty] = Twc_Punkty
,[@Precyzja] = case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end
 from TwrCeny
  LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
  where T.Twr_TWRID = TwC_TwrID and TwC_TwCNumer > 1
 for xml PATH('CNY'),TYPE
 ) CNYI
 FROM CDN.Towary T
  LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
  WHERE  Twes_Udostepnij =1 AND Twr_NieAktywny = 0
  AND EXISTS(
     SELECT GrONumer FROM #TwrGrupyESklep  WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
 for xml PATH('TWR')
END
DROP TABLE #tmpRecordSet
--DROP TABLE #tmpRecordSet1
DROP TABLE #tmpRecordSet2
DROP TABLE #tmpRecordSet3
DROP TABLE #tmpRecordSet4
DROP TABLE #tmpRecordSet5
DROP TABLE #tmpRecordSet6
DROP TABLE #tmpRecordSet8
DROP TABLE #Notowania
