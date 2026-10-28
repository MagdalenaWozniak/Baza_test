CREATE PROCEDURE CDN.ESKLEP_EksportTwrAtrybuty_ver2
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT,
     @NrCeny           nvarchar(254),
     @NrCenyInt        INT,
     @EsklepCena0      nvarchar(254),
     @EsklepCena0Int   INT,
  @ESSID            int
     CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
  CREATE TABLE #TwrId (TwrID INT)
      select  @ESSID = ESS_ESSID,@TSSynchr = ESS_TS_SynchroTwrPotw, @TwGNumerInt = ESS_TwGNumer,  @NrCenyInt = ESS_NrCeny,
              @EsklepCena0Int = ESS_EsklepCena0
   from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
   INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
   delete from #TwrGrupyESklep where GrONumer = @TwGNumerInt and GIDTyp = 16
   INSERT INTO  #TwrId
    SELECT DISTINCT
twr_twrid
 from CDN.Towary T WITH(NOLOCK)
LEFT OUTER JOIN CDN.TwrCeny TC ON TC.Twc_TwrId = T.Twr_TwrID  AND (TC.TwC_TwCNumer = @NrCenyInt)
LEFT OUTER JOIN cdn.TwrESklep TE on T.Twr_TwrId = TE.Twes_TwrID and TE.Twes_eSklepID = @ESSID
left join cdn.TwrTSModEsklep TTS on TTS.TwTS_TwrId = T.Twr_TwrId
 WHERE  TE.Twes_Udostepnij  = 1   AND T.Twr_NieAktywny = 0
 AND case when TTS.TwTS_TS_ModESklep is not null and  TTS.TwTS_TS_ModESklep > T.Twr_TS_Mod then TTS.TwTS_TS_ModESklep else T.Twr_TS_Mod end
 > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
 AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = T.Twr_TwrId )
AND ((@EsklepCena0Int = 1 AND TC.TwC_Wartosc <> 0) or @EsklepCena0Int <> 1)
CREATE TABLE #tmpRecordSet1(AtrId INT, DeAId INT,AtKJezykID Smallint,WarId int,  AtrWartosc nvarchar(100), TwrId INT,Grupuj INT, Lp INT, Edyt INT, Format INT  )
insert into #tmpRecordSet1(AtrId ,DeAId ,AtKJezykID , WarId,  AtrWartosc ,  TwrId, Grupuj, Lp, Edyt, Format )
SELECT distinct TwA_TwAId,DeA_DeaId, TwA_JezykID,case when DeA_Format != 3  then 0 else case when isnull(DAE_DAEId,0) = 0 then -1 else DAE_DAEId end end,
case
when DeA_Format = 4 AND LTRIM(RTRIM(TwA_WartoscTxt)) <> '' then CONVERT(nvarchar(30),dateadd( day, CAST(TwA_WartoscTxt AS INT) ,CONVERT(DATETIME,'1800-12-28',120))    ,120)
when DeA_Format = 3 AND LTRIM(RTRIM(TwA_WartoscTxt)) = '' then DAE_Wartosc
else TwA_WartoscTxt end as TwA_WartoscTxt,
TwA_TwrID,TwA_AtrybutGrupujacyFantom,TwA_Lp,
DeA_PozwalajNaEdycjeESklep, DeA_Format
FROM CDN.DefAtrybuty
JOIN CDN.TwrAtrybuty ON DeA_DeAId = TwA_DeaId
left JOIN cdn.DefAtrElem on DeA_DeAId = DAE_DeAId and DAE_Wartosc = TwA_WartoscTxt
where TwA_ESklep =1 and TwA_DaBId IS NULL and LTRIM(RTRIM(TwA_WartoscTxt)) = '' and DeA_Format = 3
and TwA_TwrID in (select TwrID from #TwrId)
union all
SELECT distinct TwA_TwAId,DeA_DeaId, TwA_JezykID,case when DeA_Format != 3  then 0 else case when isnull(DAE_DAEId,0) = 0 then -1 else DAE_DAEId end end,
case
when DeA_Format = 4 AND LTRIM(RTRIM(TwA_WartoscTxt)) <> '' then CONVERT(nvarchar(30),dateadd( day, CAST(TwA_WartoscTxt AS INT) ,CONVERT(DATETIME,'1800-12-28',120))    ,120)
when DeA_Format = 3 AND LTRIM(RTRIM(TwA_WartoscTxt)) = '' then DAE_Wartosc
else TwA_WartoscTxt end as TwA_WartoscTxt,
TwA_TwrID,TwA_AtrybutGrupujacyFantom,TwA_Lp,DeA_PozwalajNaEdycjeESklep, DeA_Format
FROM CDN.DefAtrybuty
JOIN CDN.TwrAtrybuty ON DeA_DeAId = TwA_DeaId
left outer join cdn.DefAtrElem on DeA_DeAId = DAE_DeAId and DAE_Wartosc = TwA_WartoscTxt
where TwA_ESklep =1 and TwA_DaBId IS NULL and (LTRIM(RTRIM(TwA_WartoscTxt)) != '' OR DeA_PozwalajNaEdycjeESklep = 1)
and TwA_TwrID in (select TwrID from #TwrId)
and (DeA_Format != 3 or (DeA_Format = 3 and isnull(DAE_DAEId,0) != 0))
update #tmpRecordSet1 set AtrWartosc = '' where Edyt = 1
SELECT
[@GIDNumer] = TwrId,
[@AtrDefID] = DeAId,
[@Lp] = min(Lp),
[@WartoscID] = WarID,
[@Grupujacy] = Grupuj,
[@Edycja] = case when Grupuj = 0 and Edyt = 1 then 1 else 0 end,
(select  [@JezykID] = AtKJezykID , [@Wartosc] = AtrWartosc from #tmpRecordSet1 B where A.Twrid = B.TwrId and  B.DeaId = A.deaId and Edyt = 0 and Format != 3
 for xml  PATH('TWRATRWJ') ,root ('TWRATRWJI'),TYPE )
from #tmpRecordSet1 A
group by TwrId,DeAId,WarID,Grupuj,Edyt
FOR XML PATH('TWRATR') ,type
END
