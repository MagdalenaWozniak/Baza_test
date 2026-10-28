CREATE PROCEDURE [CDN].[ESKLEP_EksportGrup]
 @ID INT      -- ID e-sklep
 ,@TypExp INT  -- Typ eksportu grup (0 - różnicowy, 1 - pełny)
AS
  DECLARE
     @ESSID            int,
     @Typ_Twr          SMALLINT,
     @Typ_GrT          SMALLINT,
     @TSSynchr         nvarchar(254),
     @TSSynchrInt      INT,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT
CREATE TABLE #tmpRecordSet(
           /*   grupy */  GIDTyp int, GIDNumer int, GrOTyp int, GrONumer int, Kod nvarchar(50), Nazwa nvarchar(255)
           /*     nazwy */ ,JezykID smallint, NazwaJezyk nvarchar(255),Opis nvarchar(MAX)/*nvarchar(3000)*/,OpisKrotki nvarchar(500),
PSTitle nvarchar(100),PSKluczowe nvarchar(500),POpis nvarchar(320),Link nvarchar(50),Szukaj nVARCHAR(512),NazwaNag NVARCHAR(250), eSklepLp int
           /* Atrybuty */ ,AtrId INT,DeAId INT, AtKTyp SMALLINT,AtKJezykID smallint, AtKNazwa nvarchar(40), AtrWartosc nvarchar(100), DABID INT, Format Int
)
CREATE TABLE #tmpRecordSet1(
           /* Nazwy */ TwgId INT, TwgKod nvarchar(50), TwgNazwa nvarchar(255), Opis nvarchar(MAX)/*nvarchar(3000)*/,OpisKrotki nvarchar(500),
PSTitle nvarchar(100),PSKluczowe nvarchar(500),POpis nvarchar(320),Link nvarchar(50),Szukaj nVARCHAR(512),NazwaNag NVARCHAR(250),JezykID smallint
     )
     --atr nie binarne
     CREATE TABLE #tmpRecordSet2(
           /* Atrybuty */ AtrId INT, DeAId INT, AtKTyp SMALLINT default 1,AtKJezykID Smallint, AtKNazwa nvarchar(40), AtrWartosc nvarchar(100), DABID INT, TwGId INT,Format Int
     )
     --atr bin pierwszy
     CREATE TABLE #tmpRecordSet3(
           /* Atrybuty */ AtrId INT, DeAId INT, AtKTyp SMALLINT default 2,AtKJezykID Smallint, AtKNazwa nvarchar(40), AtrWartosc nvarchar(100), DABID INT, TwGId INT,Format Int
     )
     --atr bin  - druga tab
     CREATE TABLE #tmpRecordSet4(
           /* Atrybuty */ AtrId INT, DeAId INT, AtKTyp SMALLINT default 3,AtKJezykID Smallint, AtKNazwa nvarchar(40), AtrWartosc nvarchar(100), DABID INT, TwGId INT,Format Int
     )
CREATE TABLE #table ( GIDTyp int, GIDNumer int, GrOTyp int, GrONumer int, Kod nvarchar(50), Nazwa nvarchar(255),eSklepLp int)
  SET @Typ_GrT = -16
  SET @Typ_Twr = 16
  select @ESSID = ESS_ESSID, @TSSynchr =  ESS_TS_SynchroGrupPotw,@TwGNumerInt = ESS_TwGNumer from cdn.eSklepStanowiska where ESS_IdISklep = @ID
  --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841
  IF @TypExp=1
      SELECT @TSSynchrInt = 0
  ELSE
      SELECT @TSSynchrInt = CONVERT(INT,@TSSynchr)
  --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837
  --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
insert into #table( GIDTyp , GIDNumer , GrOTyp, GrONumer , Kod , Nazwa , eSklepLp)
SELECT
 GIDTyp,
 GIDNumer,
 GrOTyp,
 GrONumer,
 TWG.Kod,
 Nazwa,
 eSklepLp
   FROM CDN.TwrGrupyESklep (@TwGNumerInt) AS TWG
RIGHT OUTER JOIN cdn.towary on GIDNumer = Twr_GidNumer and GidTyp = 16  and twr_nieaktywny = 0
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
WHERE Twes_Udostepnij =1 and CzasModyfikacji > @TSSynchrInt
delete from #table where GrONumer = @TwGNumerInt and GIDTyp = 16
insert into #tmpRecordSet1(TwgId, TwgKod, TwgNazwa,Opis ,OpisKrotki,PSTitle ,PSKluczowe ,POpis,Link,Szukaj,NazwaNag,JezykID)
select
Twg_TwgId, Twg_Kod,
case when isnull(twgj_Nazwa,'') = '' then    case when isnull(twg_Nazwa,'') = '' then Twg_Kod else Twg_Nazwa end else twgj_Nazwa end  as Twg_Nazwa,
case when isnull(twgj_OpisHTML,'') = '' then   '' else twgj_OpisHTML end  as twgj_OpisHTML,
case when isnull(twgj_OpisKrotki,'') = '' then   '' else twgj_OpisKrotki end  as twgj_OpisKrotki,
case when isnull(twgj_MetaTytul,'') = '' then   '' else twgj_MetaTytul end  as twgj_MetaTytul,
case when isnull(twgj_MetaSlowaKluczowe,'') = '' then   Twg_Nazwa else twgj_MetaSlowaKluczowe end  as twgj_MetaSlowaKluczowe,
case when isnull(twgj_MetaOpis,'') = '' then   '' else twgj_MetaOpis end  as twgj_MetaOpis,
isnull(twgj_Link,''),
isnull(TwGJ_Szukaj,''),
isnull(TwGJ_NazwaNag,''),
1 as TwgJ_JezykID
 from cdn.twrgrupy
LEFT OUTER JOIN  CDN.TwrGrupyJezykObcy ON TwgJ_TwgId = Twg_TwgId and  TwgJ_JezykID = 1
where TwG_GIDTyp = -16
union
select
Twg_TwgId, Twg_Kod,
case when isnull(twgj_Nazwa,'') = '' then    case when isnull(twg_Nazwa,'') = '' then Twg_Kod else Twg_Nazwa end else twgj_Nazwa end  as Twg_Nazwa,
case when isnull(twgj_OpisHTML,'') = '' then   '' else twgj_OpisHTML end  as twgj_OpisHTML,
case when isnull(twgj_OpisKrotki,'') = '' then   '' else twgj_OpisKrotki end  as twgj_OpisKrotki,
case when isnull(twgj_MetaTytul,'') = '' then   '' else twgj_MetaTytul end  as twgj_MetaTytul,
case when isnull(twgj_MetaSlowaKluczowe,'') = '' then   Twg_Nazwa else twgj_MetaSlowaKluczowe end  as twgj_MetaSlowaKluczowe,
case when isnull(twgj_MetaOpis,'') = '' then   '' else twgj_MetaOpis end  as twgj_MetaOpis,
isnull(twgj_Link,''),
isnull(TwGJ_Szukaj,''),
isnull(TwGJ_NazwaNag,''),
TwgJ_JezykID
 from cdn.twrgrupy
LEFT OUTER JOIN  CDN.TwrGrupyJezykObcy ON TwgJ_TwgId = Twg_TwgId
where TwG_GIDTyp = -16 and   ISNULL(TwgJ_JezykID,1) <> 1
insert into #tmpRecordSet2(AtrId ,DeAId , AtKJezykID ,  AtKNazwa , AtrWartosc , DABID, TwGId, Format )
SELECT  TwGA_TwGAId, DeA_DeaId, TwGA_JezykID,case when dea_nazwa = '' then DeA_Kod else dea_nazwa end as DeA_Nazwa,  case when DeA_Format = 4 AND LTRIM(RTRIM(TwGA_WartoscTxt)) <> ''
then CONVERT(nvarchar(10),datediff(day,convert(DATETIME,'1990-01-01',120),dateadd( day, CAST(TwGA_WartoscTxt AS INT) ,CONVERT(DATETIME,'1800-12-28',120)))    ,120)
else TwGA_WartoscTxt end,   TwGA_DaBId ,TwGA_TWGID,DeA_Format FROM CDN.DefAtrybuty JOIN CDN.TwrGrupyAtrybuty
 ON DeA_DeAId = TwGA_DeaId where  TwGA_DaBId IS NULL
insert into #tmpRecordSet3(AtrId ,DeAId ,AtKJezykID ,  AtKNazwa , AtrWartosc , DABID, TwGId, Format  )
SELECT  TwGA_TwGAId,DeA_DeaId, 0,case when dea_nazwa = '' then DeA_Kod else dea_nazwa end as DeA_Nazwa, TwGA_WartoscTxt,  TwGA_DaBId , TwGA_TwGID,DeA_Format FROM CDN.DefAtrybuty JOIN CDN.TwrGrupyAtrybuty
 ON DeA_DeAId = TwGA_DeaId
        JOIN (SELECT MIN(TwGA_TwGAId)AS TwGAId FROM CDN.TwrGrupyAtrybuty
              join cdn.danebinarne on  TwGA_DaBId = DaB_DaBId
WHERE TwGA_DaBId IS NOT NULL  and substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
in ('jpg','gif','png','jpe','jpeg')
GROUP BY TwGA_TwGId) AS ATRBIN ON TwGaId = TwGa_TwGaId
         WHERE  TwGA_DaBId IS NOT NULL
insert into #tmpRecordSet4(AtrId , DeAId , AtKJezykID,AtKNazwa , AtrWartosc , DABID, TwGId, Format  )
SELECT  TwGA_TwGAId,DeA_DeaId, TwGA_JezykID,case when dea_nazwa = '' then DeA_Kod else dea_nazwa end as DeA_Nazwa, TwGA_WartoscTxt,  TwGA_DaBId , TwGA_TwGID,DeA_Format FROM CDN.DefAtrybuty
JOIN CDN.TwrGrupyAtrybuty ON DeA_DeAId = TwGA_DeaId
WHERE TwGA_DaBId IS NOT NULL
AND TwGA_TwGAId not in (select AtrId FROM #tmpRecordSet3)
insert into #tmpRecordSet(GIDTyp , GIDNumer , GrOTyp , GrONumer , Kod , Nazwa
            , NazwaJezyk,JezykID,Opis ,OpisKrotki,PSTitle,PSKluczowe,POpis,Link,Szukaj,NazwaNag,
eSklepLp,AtrId , DeAId, AtKTyp ,AtKJezykID , AtKNazwa , AtrWartosc , DABID , Format )
 SELECT DISTINCT
 GIDTyp,
 GIDNumer,
 GrOTyp,
 GrONumer,
 Kod,
 Nazwa,
 Twgnazwa,
 JezykID,
Opis ,OpisKrotki,PSTitle,PSKluczowe,POpis,Link,Szukaj,NazwaNag,
 eSklepLp,
AtrId,DeAId,AtKTyp/*1-text,2-zdjecie,3-zdjecie dod*/,AtKJezykID,AtKNazwa, AtrWartosc,DaBId,Format
   FROM CDN.TwrGrupyESklep (0) AS TWG
LEFT OUTER JOIN
  (
  select * from #tmpRecordSet1
  )
  Nazwy ON Nazwy.TwgID = TWG.twgid
 LEFT OUTER JOIN
  (
  select * from #tmpRecordSet2
  union all
  select * from #tmpRecordSet3
  union all
  select * from #tmpRecordSet4
  )
  Atrybuty ON Atrybuty.TwGID = TWG.twgid
WHERE GIDTyp = -16 AND (exists(
  SELECT DISTINCT
 twgid
   FROM CDN.TwrGrupyESklep (0) AS TWG WHERE GIDTyp = -16 AND CzasModyfikacji > @TSSynchrInt
 ))
 UNION
 SELECT
 GIDTyp,
 GIDNumer,
 GrOTyp,
 GrONumer,
 Kod,
 Nazwa,
 '',
 0,
'' ,'','','','','','','',
 eSklepLp,
0,0,0,0,'', '',0,0
   from #table AS TWG
group by GIDTyp,
 GIDNumer,
 GrOTyp,
 GrONumer,
 Kod,
 Nazwa,
 eSklepLp
--FOR XML AUTO
SELECT DISTINCT  1 AS Tag, NULL AS Parent  /* Towary  <TWG> */
  ,GIDTyp AS [TWG!1!GIDTyp], GIDNumer AS [TWG!1!GIDNumer], GrOTyp AS [TWG!1!GrOTyp],GrONumer AS [TWG!1!GrONumer]
  ,NULL AS [TWGJI!2]
  ,NULL AS [TWGJ!3!GIDTyp], NULL AS [TWGJ!3!GIDNumer], NULL AS [TWGJ!3!JezykID], NULL AS [TWGJ!3!Kod], NULL AS [TWGJ!3!Nazwa], NULL AS [TWGJ!3!Lp],NULL AS [TWGJ!3!Opis],NULL AS [TWGJ!3!OpisKrotki],NULL AS [TWGJ!3!PSTitle],NULL AS [TWGJ!3!PSKluczowe],NULL AS [TWGJ!3!POpis],NULL AS [TWGJ!3!URLTitle]
  ,NULL AS [TWGJ!3!Szukaj],NULL AS [TWGJ!3!NazwaNag]
  ,NULL AS [TWGAI!4]
  ,NULL AS [TWGA!5!GIDTyp],NULL AS [TWGA!5!GIDNumer],NULL AS [TWGA!5!ID],NULL AS [TWGA!5!DefID], NULL AS [TWGA!5!Typ],NULL AS [TWGA!5!JezykID], NULL AS [TWGA!5!Nazwa], NULL AS [TWGA!5!Wartosc], NULL AS [TWGA!5!Wartosc], NULL AS [TWGA!5!Format]
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  2 AS Tag, 1 AS Parent       /* Nazwy <TWGJI> */
        ,GIDTyp, GIDNumer, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL
      ,NULL
  ,NULL,NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM  #tmpRecordSet
UNION ALL
SELECT DISTINCT  3 AS Tag, 2 AS Parent    /* Nazwy <TWGJ> */
  ,GIDTyp, GIDNumer, NULL, NULL
   ,NULL
  ,GIDTyp, GIDNumer,JezykID,Kod,NazwaJezyk,ISNULL(eSklepLp,0),Opis,OpisKrotki,PSTitle ,PSKluczowe ,POpis,Link,Szukaj,NazwaNag
      ,NULL
  ,NULL,NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM  #tmpRecordSet WHERE GIDTyp = -16
UNION ALL
SELECT DISTINCT   4 AS Tag, 1 AS Parent  /* Atrybuty <ATRI> */
         ,GIDTyp, GIDNumer, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL
        ,NULL
  ,NULL,NULL,NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL
FROM  #tmpRecordSet WHERE GIDTyp = -16
UNION ALL
SELECT DISTINCT  5 AS Tag, 4 AS Parent /* Atrybuty <ATR> */
      ,GIDTyp, GIDNumer, NULL, NULL
   ,NULL
  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, NULL
      ,NULL
  ,GIDTyp,GIDNumer,AtrId,DeAId, AtKTyp,AtKJezykID, AtKNazwa, CASE WHEN DABID IS NULL THEN AtrWartosc ELSE NULL END, DABID,Format
FROM  #tmpRecordSet WHERE GIDTyp = -16 and  AtrId IS NOT NULL
ORDER BY [TWG!1!GIDTyp],[TWG!1!GIDNumer],1,[TWGJ!3!JezykID] --[ATR!5!ID!Hide], [ATR!5!Typ]
FOR XML EXPLICIT,  BINARY BASE64
DROP TABLE #tmpRecordSet
DROP TABLE #tmpRecordSet1
DROP TABLE #tmpRecordSet2
DROP TABLE #tmpRecordSet3
DROP TABLE #tmpRecordSet4
DROP TABLE #table
