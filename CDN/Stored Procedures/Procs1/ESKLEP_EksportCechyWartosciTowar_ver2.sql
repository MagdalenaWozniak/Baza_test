CREATE PROCEDURE [CDN].[ESKLEP_EksportCechyWartosciTowar_ver2]
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @TwGNumerInt      INT,
  @ESSID            int,
     @CechyPartii      INT
 CREATE TABLE #TwrGrupy (TwGID INT, Kod VARCHAR(50), Nazwa VARCHAR(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
      select @ESSID = ESS_ESSID,@TSSynchr =  ESS_TS_SynchroTwrPotw,@TwGNumerInt = ESS_TwGNumer,@CechyPartii =  ESS_WyslijCechyPartii from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
INSERT INTO  #TwrGrupy
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
  delete from #TwrGrupy where GrONumer = @TwGNumerInt and GIDTyp = 16
if  @CechyPartii = 1
select distinct TwA_TwrId AS '@TwrID', DeA_DeAId AS '@CechaID',1 AS '@Lp'
from cdn.twratrybuty
join cdn.towary on TwA_TwrId = Twr_TwrId
join cdn.DefAtrybuty on TwA_DeAId = DeA_DeAId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
left join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
where TwA_CzyPrzenosicNaDostawy = 1 and DeA_Format = 3 and Twa_ESklep = 1
 and Twes_Udostepnij =1 AND  Twr_NieAktywny = 0
 AND (case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end
 > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END)
 AND EXISTS(SELECT GrONumer FROM #TwrGrupy WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
FOR XML PATH('CET'), type
END
