CREATE PROCEDURE [CDN].[IGaleria_EksportTwrUsuwanie]
AS
DECLARE
     @TSSynchr         nvarchar(254),
     @TSSynchrGrup     nvarchar(254),
     @TSSynchrGrupInt  INT,
     @TSSynchrTwr      nvarchar(254),
     @TSSynchrTwrDate  DATETIME,
     @DateTSSynchr     DATETIME,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT,
     @NrCeny           nvarchar(20),
     @NrCenyInt        INT,
     @EsklepCena0      nvarchar(254),
     @EsklepCena0Int   INT,
  @ESSID            int
 CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
 select  top 1 @ESSID = ESS_ESSID, @TSSynchr = ESS_TS_SynchroPotw,@TSSynchrTwr = ESS_TS_SynchroTwrPotw, @TwGNumerInt = ESS_TwGNumer,
   @NrCenyInt = ESS_NrCeny,@EsklepCena0Int = ESS_EsklepCena0
 from cdn.eSklepStanowiska where ESS_typ = 2
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 SELECT @TSSynchrTwrDate = dateadd( second, CONVERT(INT,@TSSynchrTwr),CONVERT(DATETIME,'1990-01-01',120))
 INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
SELECT  1 AS Tag, NULL AS Parent
  ,TWR.GIDNumer AS [TWR!1!GIDNumer]
FROM
 (
  SELECT DISTINCT
    Twr_TwrId AS GIDNumer
  FROM CDN.TwrGrupy
  JOIN CDN.Towary On TwG_GIDNumer = Twr_TwrId AND TwG_GIDTyp = 16
   LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
   left join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
        WHERE TwG_GIDTyp = 16 AND Twr_GIDFirma = 1 AND TwG_GIDNumer > 0 AND (TwG_CzasModyfikacji > @TSSynchr OR case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end > @TSSynchrTwrDate)
        AND ((ISNULL(Twes_Udostepnij,0) = 0 OR Twr_NieAktywny = 1 OR NOT EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId ))
        OR (
  --1= @EsklepCena0Int AND
  EXISTS (SELECT TwC_TwrId FROM CDN.TwrCeny WHERE TwC_TwrId = Twr_TwrID AND Twes_Udostepnij=1 AND TwC_Wartosc = 0 AND TwC_TwCNumer = @NrCenyInt)
  ))
 ) TWR
 FOR XML EXPLICIT
