CREATE PROCEDURE [CDN].[IGaleria_EksportTwr]
 @TypExp INT  -- Typ eksportu cennika (0 - różnicowy, 1 - pełny)
 ,@ExpTylkoCeny INT --eksport tylko cen
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
     @EsklepCena0      nvarchar(254),
     @EsklepCena0Int   INT,
     @WalutaKoncowa    nvarchar(3),
     @sqltxt           NVARCHAR (1000),
     @TmpSrvName       SYSNAME,
     @ServerCfgString  nvarchar(512),
     @BazaCfgString    nvarchar(512),
     @WalOstrzegaj     nvarchar(3),
     @TrN_DataDokChar  nvarchar(25),
     @TrE_Cena0WD      DECIMAL(17,4),
     @KursLWalutaKoncowa                DECIMAL(15,4),
     @KursMWalutaKoncowa                DECIMAL(5,0)
     CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
     CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta nvarchar(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
     --13.1
     --atr nie binarne
     CREATE TABLE #tmpRecordSet1(
           /* Atrybuty */ AtrId INT, DeAId INT,AtKTyp SMALLINT default 1,AtKJezykID Smallint, AtKNazwa nvarchar(40), AtrWartosc nvarchar(100), DABID INT, TwrId INT,Format Int
     )
     --CREATE TABLE #tmpRecordSet2(
     --      /* Atrybuty */ AtrId INT, DeAId INT,AtKTyp SMALLINT default 2,AtKJezykID Smallint, AtKNazwa nvarchar(40), AtrWartosc nvarchar(100), DABID INT, TwrId INT,Format Int,ZdjecieID int
     --)
     --atr bin pierwszy
       --atr bin pierwszy
     CREATE TABLE #tmpRecordSet2(
           /* Zalaczniki */ DBLId INT, DBLTwrId INT,DBLTyp SMALLINT,  DBLJezykID Smallint,DBLDABID INT, DBLTagLink nvarchar(100),DBLTagAlt nvarchar(500),DBLTagRel TINYINT,DBLTagtitle nvarchar(500), DBLLp INT
     )
     --atr bin  - druga tab
     CREATE TABLE #tmpRecordSet3(
           /* Zalaczniki */ DBLId INT, DBLTwrId INT,DBLTyp SMALLINT,  DBLJezykID Smallint,DBLDABID INT, DBLTagLink nvarchar(100),DBLTagAlt nvarchar(500),DBLTagRel TINYINT,DBLTagtitle nvarchar(500), DBLLp INT
)
  /*
     CREATE TABLE #tmpRecordSet5(
           /* Atrybuty */  TwrId INT,ZdjecieID int
     )
     -- zdjecia
     CREATE TABLE #tmpRecordSet3(
            ZdTwrId INT,ZdjeciaID Int
     )
     */
     CREATE TABLE #tmpRecordSet6(
           IGAW_TwrId INT,IGAW_IGAId INT,IGAW_Wartosc nvarchar(100),IGAW_IGDWID INT
     )
     /*CREATE TABLE #tmpRecordSet7(
           DokTwrId INT,DokBinId INT,DokTyp INT,DokNazwa nvarchar(128), DokRozsz nvarchar(10)
     )*/
     CREATE TABLE #tmpRecordSet4(
           /* Nazwy */ TwrId INT, TwrKod nvarchar(50), TwrNazwa nvarchar(255), TwrNazwa1 nvarchar(255), TwrOpis nvarchar(MAX), TwrNazwaHTML nvarchar(255), TwrOpisHTML nvarchar(MAX),JezykID smallint,
        TwrJ_OpisKrotki nvarchar(500),TwrJ_MetaTytul nvarchar(100),TwrJ_MetaSlowaKluczowe nvarchar(500),TwrJ_MetaOpis nvarchar(200),TwrJ_Link nvarchar(50),TwrJ_Szukaj nvarchar(512)
     )
  CREATE TABLE #tmpRecordSet8(
           JMZ_Id INT,JMZ_GIDNumer INT,JMZ_JezykID INT,JMZ_JM nvarchar(20),JMZ_JML decimal(15,2),JMZ_JMM decimal(7,0),JMZ_Lok int,Domyslny int
     )
  CREATE TABLE #tmpRecordSet9(
           JMZP_Id INT,JMZP_GIDNumer INT,JMZP_JezykID INT,JMZP_JM nvarchar(20),JMZP_JML decimal(15,2),JMZP_JMM decimal(7,0)
     )
     CREATE TABLE #tmpRecordSet(
           /*   Towary */  TwrGIDNumer INT, Twr_Kod nvarchar(50),TwrKod nvarchar(50),TwrJezykID smallint, Twr_Nazwa nvarchar(255),TwrNazwa nvarchar(255),TwrNazwaHTML nvarchar(255),Twr_Nazwa1 nvarchar(255),  TwrNazwa1 nvarchar(255),TwrNazwa1HTML nvarchar(255),
                           TwrKatalog nvarchar(40),JMCalkowite smallint, TwrJm nvarchar(20), TwrURL nvarchar(255), ProducentID INT,ProducentKod nvarchar(50), MarkaID INT, TwrOkresGwarancji INT, TwrWagaBrutto DECIMAL(15,4), TwrWJm nvarchar(20),
                           Twr_Opis nvarchar(MAX),TwrOpis nvarchar(MAX), TwrOpisHTML nvarchar(MAX),TwrKGO DECIMAL(15,2),TwrTwGGidnumer INT,Twr_ESklepBezRabatu smallint,Twr_ESklepStatus smallint,Twr_ESklepDostepnosc smallint,KontrolaStanow smallint,Twr_EAN varchar(40)
         ,TwrJ_OpisKrotki nvarchar(500),TwrJ_MetaTytul nvarchar(100),TwrJ_MetaSlowaKluczowe nvarchar(500),TwrJ_MetaOpis nvarchar(200),TwrJ_Link nvarchar(50),TwrJ_Szukaj nvarchar(512)
           /*     Ceny */ ,TwCTwrLp SMALLINT, TwCWartosc DECIMAL(18,2),TwCWartoscNetto DECIMAL(18,2),TwCStawka DECIMAL(18,2), TwCWaluta nvarchar(3)
           /* Atrybuty */ ,AtrId INT, DeAId INT,AtKTyp SMALLINT,AtKJezykID smallint, AtKNazwa nvarchar(40), AtrWartosc nvarchar(100), DABID INT, Format Int
           /* Atr def*/   ,IGAW_TwrId INT,IGAW_IGAId INT,IGAW_Wartosc nvarchar(100), IGAW_IGDWID INT
          -- /* zdjecia*/   ,ZdTwrId INT, ZdjeciaId INT
          -- /* dokumenty*/ ,DokTwrId INT,DokBinId INT,DokTyp INT,DokNazwa nvarchar(128)
     /*jednostki*/  ,JMZ_Id INT,JMZ_GIDNumer INT,JMZ_JezykID INT,JMZ_JM nvarchar(20),JMZ_JML decimal(15,2),JMZ_JMM decimal(7,0),JMZ_Lok int,Domyslny int
  /*jednostki przelicz*/  ,JMZP_Id INT,JMZP_GIDNumer INT,JMZP_JezykID INT,JMZP_JM nvarchar(20),JMZP_JML decimal(15,2),JMZP_JMM decimal(7,0)
  /* Zalaczniki */ ,DBLId INT, DBLTwrId INT,DBLTyp SMALLINT,  DBLJezykID Smallint,DBLDABID INT, DBLTagLink nvarchar(100),DBLTagAlt nvarchar(500),DBLTagRel TINYINT,DBLTagtitle nvarchar(500), DBLLp INT
     )
   select  top 1 @ESSID = ESS_ESSID,@TSSynchr = ESS_TS_SynchroTwrPotw, @TwGNumerInt = ESS_TwGNumer,@WalutaKoncowa = ESS_DomyslnaWaluta,
   @NrCenyInt = ESS_NrCeny,@NrCenyPopInt = ESS_NrCenyDomyslnej, @EsklepCena0Int = ESS_EsklepCena0
   from cdn.eSklepStanowiska where ESS_typ = 2
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934
     SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900
     --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1904) SELECT @NrCeny = 0 ELSE SELECT @NrCeny = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1904
     --SELECT @NrCenyInt = CONVERT(INT,@NrCeny)
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1935) SELECT @NrCenyPop = 0 ELSE SELECT @NrCenyPop = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1935
     --SELECT @NrCenyPopInt = CONVERT(INT,@NrCenyPop)
     --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1905) SELECT @EsklepCena0= 0 ELSE SELECT @EsklepCena0 = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1905
     --SELECT @EsklepCena0Int = CONVERT(INT,@EsklepCena0)
     INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
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
insert into #tmpRecordSet1(AtrId ,DeAId ,AtKJezykID ,  AtKNazwa , AtrWartosc , DABID, TwrId, Format )
SELECT distinct TwA_TwAId,DeA_DeaId, TwA_JezykID,case when dea_nazwa = '' then DeA_Kod else dea_nazwa end as DeA_Nazwa,
case
when DeA_Format = 4 AND LTRIM(RTRIM(TwA_WartoscTxt)) <> '' then CONVERT(nvarchar(10),datediff(day,convert(DATETIME,'1990-01-01',120),dateadd( day, CAST(TwA_WartoscTxt AS INT) ,CONVERT(DATETIME,'1800-12-28',120)))    ,120)
when DeA_Format = 3 AND LTRIM(RTRIM(TwA_WartoscTxt)) = '' then DAE_Wartosc
else TwA_WartoscTxt end as TwA_WartoscTxt,
TwA_DaBId ,TwA_TwrID,DeA_Format
FROM CDN.DefAtrybuty
JOIN CDN.TwrAtrybuty ON DeA_DeAId = TwA_DeaId
left outer join cdn.DefAtrElem on DeA_DeAId = DAE_DeAId
where TwA_ESklep =1 and TwA_DaBId IS NULL
 insert into #tmpRecordSet2(DBLId, DBLTwrId, DBLTyp, DBLJezykID, DBLDABID, DBLTagLink, DBLTagAlt, DBLTagRel, DBLTagtitle, DBLLp)
  SELECT distinct DBL_DBLId,DBL_TwrID,0,0,DBL_DABID, DBL_TagLink, DBL_TagAlt, DBL_TagRel, DBL_Tagtitle,DBL_Lp  FROM CDN.DaneBinarneLinki
    JOIN (SELECT MIN(DBL_LP)AS DBLLP, DBL_TwrId as TwrId FROM CDN.DaneBinarneLinki
       join cdn.danebinarne on  DBL_DaBId = DaB_DaBId
  WHERE DBL_DaBId IS NOT NULL  and substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
  in ('jpg','gif','png','bmp') and DBL_ESklep =1 and DBL_JezykId in (0,1)
  GROUP BY DBL_TwrId) AS ATRBIN ON TwrId = DBL_TwrID and DBL_Lp = DBLLP
     WHERE DBL_ESklep =1 AND DBL_DabId IS NOT NULL and DBL_JezykId in (0,1)
/*
insert into #tmpRecordSet3(  ZdTwrId,ZdjeciaID)
SELECT TwA_TwrID ,  TwA_DaBId  FROM CDN.DefAtrybuty
JOIN CDN.TwrAtrybuty ON DeA_DeAId = TwA_DeaId
JOIN CDN.DaneBinarne ON TwA_DABId = DAB_DABId
WHERE TwA_ESklep =1 AND TwA_DaBId IS NOT NULL
and TwA_DaBId IS NOT NULL  and substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
in ('jpg','png')
*/
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
  JOIN CDN.DaneBinarne ON DBL_DABId = DAB_DABId
  WHERE DBL_ESklep =1 AND DBL_DaBId IS NOT NULL
  AND DBL_DBLId not in (select DBLId FROM #tmpRecordSet2)
  and substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
in ('jpg','png','pdf','doc','xls','docx','xlsx') and DBL_JezykId in (0,1)
insert into #tmpRecordSet6(IGAW_TwrId ,IGAW_IGAId ,IGAW_Wartosc, IGAW_IGDWID    )
SELECT DISTINCT
IGAW_TwrId as GIDNumer,
IGAW_IGAid as ID,
IGAW_Wartosc as Wartosc,
IGAW_IGDWID as IDWartosc
from cdn.iGaleriaAtrWartosci as ATRP
Join CDN.Towary on IGAW_TwrId = Twr_TwrId
left outer join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
 LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
 WHERE Twes_Udostepnij = 1 AND Twr_NieAktywny = 0 AND
 case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end
 > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
    AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
   /*
insert into #tmpRecordSet7(DokTwrId,DokBinId,DokNazwa,DokRozsz)
SELECT DISTINCT
TwA_TwrId,
TwA_DaBId,
DAB_Nazwa,
substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
FROM CDN.DefAtrybuty
JOIN CDN.TwrAtrybuty ON DeA_DeAId = TwA_DeaId
JOIN CDN.DaneBinarne ON TwA_DABId = DAB_DABId
WHERE TwA_ESklep =1 AND TwA_DaBId IS NOT NULL
and substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
in ('pdf','doc','xls')
union all
SELECT DISTINCT
TwA_TwrId,
TwA_DaBId,
DAB_Nazwa,
substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
FROM CDN.DefAtrybuty
JOIN CDN.TwrAtrybuty ON DeA_DeAId = TwA_DeaId
JOIN CDN.DaneBinarne ON TwA_DABId = DAB_DABId
WHERE TwA_ESklep =1 AND TwA_DaBId IS NOT NULL
and substring (right(dab_nazwapliku,5), convert(int,patindex('%.%',right(dab_nazwapliku,5)))+1,5)
in ('docx','xlsx')
update #tmpRecordSet7 set   DokTyp =
case
when DokRozsz IN ('doc','docx') then 1
when DokRozsz IN ('xls','xlsx') then 3
when DokRozsz IN ('pdf') then 2
end
*/
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
isnull(JezES.TwrJ_OpisKrotki,''),isnull(JezES.TwrJ_MetaTytul,''),isnull(JezES.TwrJ_MetaSlowaKluczowe,''),SUBSTRING(isnull(JezES.TwrJ_MetaOpis,''), 0, 199),isnull(JezES.TwrJ_Link,''),isnull(JezES.TwrJ_Szukaj,'')
 from cdn.towary
  LEFT OUTER JOIN cdn.twrjezykobcy JezES ON JezES.TwrJ_TwrId = Twr_TwrId and  JezES.TwrJ_JezykID = 1 and JezES.TwrJ_eSklepID = @ESSID
  LEFT OUTER JOIN cdn.twrjezykobcy Jez ON Jez.TwrJ_TwrId = Twr_TwrId and  Jez.TwrJ_JezykID = 1 and  Jez.TwrJ_eSklepID = 0
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
 where Twes_Udostepnij =1
union
select
Twr_TwrId, Twr_Kod,
case when isnull(twrj_NazwaHtml,'') = '' then   Twr_Nazwa else twrj_NazwaHtml end  as Twr_Nazwa,
'',
case when isnull(twrj_opisHtml,'') = '' then   Twr_Opis else twrj_opisHtml end  as Twr_Opis,
case when isnull(twrj_Nazwahtml,'') = '' then  case when isnull(twrj_Nazwa,'') = '' then Twr_Nazwa else twrj_Nazwa end else twrj_Nazwahtml end as Twr_NazwaHTML,
case when isnull(twrj_opishtml,'') = '' then  case when isnull(twrj_opis,'') = '' then Twr_Opis else twrj_opis end else twrj_opishtml end as Twr_OpisHTML,
TwrJ_JezykID,
isnull(TwrJ_OpisKrotki,''),isnull(TwrJ_MetaTytul,''),isnull(TwrJ_MetaSlowaKluczowe,''),SUBSTRING(isnull(TwrJ_MetaOpis,''), 0, 199),isnull(TwrJ_Link,''),isnull(TwrJ_Szukaj,'')
 from cdn.towary
JOIN cdn.twrjezykobcy ON TwrJ_TwrId = Twr_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
 where Twes_Udostepnij =1 and   ISNULL(TwrJ_JezykID,1) <> 1
  insert into #tmpRecordSet8(  JMZ_Id ,JMZ_GIDNumer ,JMZ_JezykID ,JMZ_JM ,JMZ_JML ,JMZ_JMM ,JMZ_Lok,Domyslny )
      select Gru_GruID,A.TwJZ_TwrID,1,A.TwJZ_JM,B.TwJZ_JMPrzelicznikL,B.TwJZ_JMPrzelicznikM,1,A.TwJZ_eSklepDomyslna from CDN.TwrJMZ A
    join cdn.TwrJMZ B on  A.TwJZ_TwrID = B.TwJZ_TwrID AND A.TwJZ_JM = B.TwJZ_JM AND B.TwJZ_eSklepID = 0
    join CDN.Grupy on Gru_Nazwa = A.TwJZ_JM and Gru_Typ = 32
    join CDN.Towary on A.TwJZ_TwrID = Twr_TwrId
 left join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
    join cdn.TwrESklep on Twr_TwrId = Twes_TwrID
   WHERE A.TwJZ_eSklepID = @ESSID  and Twes_eSklepID = @ESSID and Twes_Udostepnij = 1 AND Twr_NieAktywny = 0 AND  case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
   AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
 insert into #tmpRecordSet9(  JMZP_Id ,JMZP_GIDNumer ,JMZP_JezykID ,JMZP_JM ,JMZP_JML ,JMZP_JMM  )
      select Gru_GruID,A.TwJZ_TwrID,1,A.TwJZ_JM,A.TwJZ_JMPrzelicznikL,A.TwJZ_JMPrzelicznikM from CDN.TwrJMZ A
    join CDN.Grupy on Gru_Nazwa = A.TwJZ_JM and Gru_Typ = 32
    join CDN.Towary on A.TwJZ_TwrID = Twr_TwrId
    join cdn.TwrESklep on Twr_TwrId = Twes_TwrID
 left join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
   WHERE  Twes_eSklepID = @ESSID and Twes_Udostepnij = 1 AND Twr_NieAktywny = 0 AND case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
   AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
   AND Twjz_CenaJednostkowa = 1
INSERT INTO #tmpRecordSet
 SELECT  Twr_TwrId, Twr_Kod,Nazwy.TwrKod,Nazwy.JezykID, Twr_Nazwa,Nazwy.TwrNazwa ,Nazwy.TwrNazwaHTML ,'','','',Twr_NumerKat,Twr_JMCalkowite,Twr_JM,Twr_Url,ISNULL(Twr_PrdID,0),REPLACE (LTRIM(RTRIM(Twr_ProducentKod)),' ', ''),ISNULL(Twr_MrkID,0),0,Twr_WagaKG,'',Twr_Opis,Nazwy.TwrOpis,Nazwy.TwrOpisHTML,Twr_KosztKGO,Twr_IGaleriaKatId,
ISNULL(Twes_ESklepBezRabatu,0),ISNULL(Twes_ESklepStatus,0),ISNULL(Twes_ESklepDostepnosc,0),Twr_Typ,Twr_EAN,
Nazwy.TwrJ_OpisKrotki,Nazwy.TwrJ_MetaTytul,Nazwy.TwrJ_MetaSlowaKluczowe,Nazwy.TwrJ_MetaOpis,Nazwy.TwrJ_Link,Nazwy.TwrJ_Szukaj,
  case when TwC_TwCNumer = @NrCenyInt then 1 else 2 end, CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2),
     CDN.CenaBruttoPrecyzja(TwC_Wartosc,TwC_Typ+2,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,2),
     Twr_Stawka, @WalutaKoncowa,
     AtrId,DeAId,AtKTyp/*1-text,2-zdjecie,3-zdjecie dod*/,AtKJezykID,AtKNazwa, AtrWartosc,DaBId,Format,
     IGAW_TwrId ,IGAW_IGAId ,IGAW_Wartosc,IGAW_IGDWID,
     --ZdTwrId, ZdjeciaId,DokTwrId,DokBinId,DokTyp,DokNazwa,
     JMZ_Id ,JMZ_GIDNumer ,JMZ_JezykID ,JMZ_JM ,JMZ_JML ,JMZ_JMM ,JMZ_Lok,Domyslny,
     JMZP_Id,JMZP_GIDNumer,JMZP_JezykID,JMZP_JM,JMZP_JML,JMZP_JMM,
     DBLId, DBLTwrId, DBLTyp, DBLJezykID, DBLDABID, DBLTagLink, DBLTagAlt, DBLTagRel, DBLTagtitle, DbLLp
     FROM CDN.Towary
     LEFT OUTER JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrID  AND (TwC_TwCNumer = @NrCenyInt or TwC_TwCNumer = @NrCenyPopInt)
     LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
     LEFT OUTER JOIN
  (
  select * from #tmpRecordSet4
  )
  Nazwy ON Nazwy.TwrID = Twr_TwrId
 LEFT OUTER JOIN
  (
  select * from #tmpRecordSet1
  --union all
  --select * from #tmpRecordSet2
  --union all
  --select * from #tmpRecordSet3
  )
  Atrybuty ON Atrybuty.TwrID = Twr_TwrId
  LEFT OUTER JOIN
  (
  select * from #tmpRecordSet6
  )
  IGaleriaAtr ON IGaleriaAtr.IGAW_TwrId = Twr_TwrId
  /*LEFT OUTER JOIN
  (
  select * from #tmpRecordSet3
  )
  IGaleriaZd ON IGaleriaZd.ZdTwrId = Twr_TwrId
  LEFT OUTER JOIN
  (
  select * from #tmpRecordSet7
  )
  IGaleriaDok ON IGaleriaDok.DokTwrId = Twr_TwrId*/
  LEFT OUTER JOIN
    (
    select * from #tmpRecordSet8
    )
    JM ON JM.JMZ_GIDNumer = Twr_TwrId
  LEFT OUTER JOIN
    (
    select * from #tmpRecordSet9
    )
    JMPrzelicz ON JMPrzelicz.JMZP_GIDNumer = Twr_TwrId
    LEFT OUTER JOIN
    (
    select * from #tmpRecordSet2
    union all
    select * from #tmpRecordSet3
    )Zalaczniki on Zalaczniki.DBLTwrId = Twr_TwrId
   LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
   left join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
     WHERE  Twes_Udostepnij = 1 AND Twr_NieAktywny = 0 AND case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
     AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep  WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
     --AND ((@EsklepCena0Int = 1 AND TwC_Wartosc <> 0) or @EsklepCena0Int <> 1)
   delete from #tmpRecordSet where TwrGIDNumer in( select TwrGIDNumer from #tmpRecordSet  where TwCWartosc = 0  and TwCTwrLp = 1)
IF @ExpTylkoCeny =1
BEGIN
SELECT DISTINCT  1 AS Tag, NULL AS Parent       /* Ceny <TWCI> */
  ,NULL AS [TWCI!1]
  ,NULL AS [TWC!2!GIDNumer],NULL AS [TWC!2!ID], NULL AS [TWC!2!Wartosc], NULL AS [TWC!2!WartoscBrutto], NULL AS [TWC!2!Podatek]/*, NULL AS [TWC!5!Waluta]*/
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  2 AS Tag, 1 AS Parent    /* Ceny <TWC> */
  ,NULL
  ,TwrGIDNumer,TwCTwrLp,TwCWartoscNetto, TwCWartosc,TwCStawka
FROM  #tmpRecordSet
FOR XML EXPLICIT,  BINARY BASE64
END
ELSE
BEGIN
SELECT DISTINCT  1 AS Tag, NULL AS Parent  /* Towary  <TWR> */
  ,TwrGIDNumer AS [TWR!1!GIDNumer], /*Twr_Kod AS [TWR!1!Kod], Twr_Nazwa AS [TWR!1!Nazwa], Twr_Nazwa1 AS [TWR!1!Nazwa1],*/ TwrKatalog AS [TWR!1!Symbol], TwrJm AS [TWR!1!JM],JMCalkowite AS [TWR!1!JMCalkowite], TwrURL AS [TWR!1!URL], ProducentID AS [TWR!1!ProducentID],ProducentKod AS [TWR!1!ProducentKod],MarkaID AS [TWR!1!MarkaID], TwrOkresGwarancji AS [TWR!1!OkresGwarancji],
TwrWagaBrutto AS [TWR!1!WagaBrutto]/*, TwrWJm AS [TWR!1!WagaJm]*/
  ,  /*Twr_Opis AS [TWR!1!Opis],*/TwrKgo AS [TWR!1!Kgo],TwrTwGGidnumer AS [TWR!1!iGaleria24Grupa]
,Twr_ESklepBezRabatu AS [TWR!1!CzyRabat],Twr_ESklepStatus AS [TWR!1!Status],Twr_ESklepDostepnosc AS [TWR!1!Dostepnosc]/*,KontrolaStanow AS [TWR!1!KontrolaStanow]*/,Twr_EAN AS [TWR!1!EAN]
  ,NULL AS [TWRJI!2]
  ,NULL AS [TWRJ!3!GIDNumer], NULL AS [TWRJ!3!JezykID], NULL AS [TWRJ!3!Kod], NULL AS [TWRJ!3!Nazwa], /*NULL AS [TWRJ!3!NazwaHTML],*/ NULL AS [TWRJ!3!Nazwa1], /*NULL AS [TWRJ!3!Nazwa1HTML],*/ NULL AS [TWRJ!3!Opis], /*NULL AS [TWRJ!3!OpisHTML],*/ NULL AS [TWRJ!3!JM] /*NULL AS [TWRJ!3!WagaJM]*/
  ,NULL AS [TWRJ!3!OpisKrotki],NULL AS [TWRJ!3!PSTitle],NULL AS [TWRJ!3!PSKluczowe],NULL AS [TWRJ!3!POpis],NULL AS [TWRJ!3!URLTitle],NULL AS [TWRJ!3!Szukaj]
  ,NULL AS [TWCI!4]
  ,NULL AS [TWC!5!GIDNumer],NULL AS [TWC!5!ID], NULL AS [TWC!5!Wartosc], NULL AS [TWC!5!WartoscBrutto], NULL AS [TWC!5!Podatek]/*, NULL AS [TWC!5!Waluta]*/
  ,NULL AS [ATRI!6]
  ,NULL AS [ATR!7!GIDNumer],NULL AS [ATR!7!ID],/*NULL AS [ATR!7!DefID], NULL AS [ATR!7!Typ],NULL AS [ATR!7!JezykID],*/ NULL AS [ATR!7!Nazwa], /*NULL AS [ATR!7!Wartosc],*/ NULL AS [ATR!7!Wartosc], NULL AS [ATR!7!Format]
  ,NULL AS [ATRPI!8]
  ,NULL AS [ATRP!9!GIDNumer],NULL AS [ATRP!9!ID], NULL AS [ATRP!9!Wartosc], NULL AS [ATRP!9!IDWartosc]
  --,NULL AS [TWRZI!10]
  --,NULL AS [TWRZ!11!GIDNumer],NULL AS [TWRZ!11!ZdjecieID]
  --,NULL AS [DOKI!12]
  --,NULL AS [DOK!13!GIDNumer],NULL AS [DOK!13!ID],NULL AS [DOK!13!Typ],NULL AS [DOK!13!Nazwa]
  ,NULL AS [TWRJMI!10]
  ,NULL AS [TWRJM!11!ID],NULL AS [TWRJM!11!GIDNumer], NULL AS [TWRJM!11!JezykID], NULL AS [TWRJM!11!JM], NULL AS [TWRJM!11!JML], NULL AS [TWRJM!11!JMM], NULL AS [TWRJM!11!Lok], NULL AS [TWRJM!11!Domyslny]
  ,NULL AS [TWMI!12]
  ,NULL AS [TWM!13!ID],NULL AS [TWM!13!GIDNumer],NULL AS [TWM!13!JezykID],NULL AS [TWM!13!JML],NULL AS [TWM!13!JMM],NULL AS [TWM!13!JM]
    ,NULL AS [ZALI!14]
    ,NULL AS [ZAL!15!ID],NULL AS [ZAL!15!GIDNumer],NULL AS [ZAL!15!Typ], NULL AS [ZAL!15!Lp]
    ,NULL AS [ZALIJ!16]
    ,NULL AS [ZAJ!17!ID],NULL AS [ZAJ!17!JezykID],NULL AS [ZAJ!17!DabID],NULL AS [ZAJ!17!TagLink],NULL AS [ZAJ!17!TagAlt],NULL AS [ZAJ!17!TagRel],NULL AS [ZAJ!17!TagTitle]
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  2 AS Tag, 1 AS Parent       /* Nazwy <TWRJI> */
        ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  3 AS Tag, 2 AS Parent    /* Nazwy <TWRJ> */
  ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
 , NULL
  ,TwrGIDNumer,TwrJezykID,TwrKod,TwrNazwaHTML,TwrNazwa1,TwrOpisHTML,TwrJm,TwrJ_OpisKrotki,TwrJ_MetaTytul,TwrJ_MetaSlowaKluczowe,TwrJ_MetaOpis,TwrJ_Link,TwrJ_Szukaj
  ,NULL
  ,NULL,NULL, NULL, NULL ,NULL
  ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
     ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet where TwrJezykID = 1
UNION ALL
SELECT DISTINCT  4 AS Tag, 1 AS Parent       /* Ceny <TWCI> */
        ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
       ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  5 AS Tag, 4 AS Parent    /* Ceny <TWC> */
  ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
   ,NULL
  ,TwrGIDNumer,TwCTwrLp,TwCWartoscNetto, TwCWartosc,TwCStawka
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
      ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT   6 AS Tag, 1 AS Parent  /* Atrybuty <ATRI> */
        ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
    ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
       ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  7 AS Tag, 6 AS Parent /* Atrybuty <ATR> */
        ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,TwrGIDNumer,AtrId,  AtKNazwa, CASE WHEN DABID IS NULL THEN AtrWartosc ELSE NULL END,/* DABID,*/Format
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
      ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet WHERE AtrId IS NOT NULL
UNION ALL
SELECT DISTINCT   8 AS Tag, 1 AS Parent  /* Atrybuty <ATRI> */
        ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
      ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  9 AS Tag, 8 AS Parent /* Atrybuty IGaleria <ATRP> */
        ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,IGAW_TwrId,IGAW_IGAid,IGAW_Wartosc, IGAW_IGDWID
  ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
      ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet WHERE IGAW_Wartosc IS NOT NULL
UNION ALL
  SELECT DISTINCT   10 AS Tag, 1 AS Parent  /* Atrybuty <ATRI> */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
  FROM  #tmpRecordSet
  UNION ALL
  SELECT DISTINCT  11 AS Tag, 10 AS Parent /* Atrybuty IGaleria <ATRP> */
      ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL,NULL,NULL, NULL
  ,NULL
  ,JMZ_Id ,JMZ_GIDNumer ,JMZ_JezykID ,JMZ_JM ,JMZ_JML ,JMZ_JMM ,JMZ_Lok,Domyslny
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
  FROM  #tmpRecordSet WHERE JMZ_JM IS NOT NULL
  UNION ALL
  SELECT DISTINCT   12 AS Tag, 1 AS Parent  /*  Jednostka przeliczeniowa */
    ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
  FROM  #tmpRecordSet
  UNION ALL
  SELECT DISTINCT  13 AS Tag, 12 AS Parent /* Jednostka przeliczeniowa */
      ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL,NULL,NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL,NULL
  ,NULL
   ,JMZP_Id,JMZP_GIDNumer,JMZP_JezykID,JMZP_JML,JMZP_JMM,JMZP_JM
   ,NULL
  ,NULL ,NULL, NULL, NULL
  ,NULL
  ,NULL,NULL,NULL,NULL, NULL , NULL, NULL
  FROM  #tmpRecordSet WHERE JMZP_Id IS NOT NULL
  UNION ALL
SELECT DISTINCT   14 AS Tag, 1 AS Parent  /* Zdjecia <TWRZI> */
        ,TwrGIDNumer, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
      ,NULL
  ,NULL,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  15 AS Tag, 14 AS Parent /* Atrybuty IGaleria <ATRP> */
        ,DBLTwrId, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL,NULL,NULL, NULL
  ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
  ,DBLId, DBLTwrId, DBLTyp, DblLp
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
  FROM  #tmpRecordSet WHERE DBLId IS NOT NULL
  UNION ALL
SELECT DISTINCT   16 AS Tag, 15 AS Parent  /* Dokumenty <DOKI> */
        ,DBLTwrId, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
    ,NULL
  ,DBLId,NULL, NULL, NULL
  ,NULL
  ,NULL ,NULL ,NULL ,NULL, NULL , NULL, NULL
FROM  #tmpRecordSet WHERE DBLId IS NOT NULL
UNION ALL
SELECT DISTINCT  17 AS Tag, 16 AS Parent /* Dokumenty <DOK> */
        ,DBLTwrId, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL,NULL,NULL
        ,NULL
  ,NULL,NULL, NULL, NULL, NULL
  ,NULL
  ,NULL,NULL,NULL, NULL
    ,NULL
  ,NULL ,NULL , NULL , NULL , NULL , NULL , NULL, NULL
  ,NULL
    ,NULL ,NULL , NULL , NULL , NULL, NULL
  ,NULL
  ,DBLId ,NULL, NULL, NULL
  ,NULL
  ,DBLId ,DBLJezykID, DBLDABID, DBLTagLink, DBLTagAlt, DBLTagRel, DBLTagtitle
FROM  #tmpRecordSet WHERE DBLId IS NOT NULL
ORDER BY [TWR!1!GIDNumer],[ZAL!15!ID],1,[TWRJ!3!JezykID],[TWC!5!ID]--, [ATR!7!Typ] [ATR!5!ID!Hide], [ATR!5!Typ]
FOR XML EXPLICIT,  BINARY BASE64
-- po wyslaniu towaru ustawiamy flage Twr_Oddzialowy (informacja o wysłaniu do e-sklepu jest zapisywana na drugim bicie)
UPDATE CDN.Towary SET Twr_GidFirma = 1 WHERE Twr_TwrId IN (SELECT DISTINCT TwrGIDNumer FROM  #tmpRecordSet )
END
DROP TABLE #tmpRecordSet
DROP TABLE #tmpRecordSet1
DROP TABLE #tmpRecordSet2
DROP TABLE #tmpRecordSet3
DROP TABLE #tmpRecordSet4
DROP TABLE #tmpRecordSet6
DROP TABLE #tmpRecordSet8
DROP TABLE #Notowania
