CREATE  PROCEDURE [CDN].[IGaleria_EksportTwrAtrybuty]
 @TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT,
  @ESSID            int
 CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
 select  top 1 @ESSID = ESS_ESSID, @TSSynchr = ESS_TS_SynchroTwrPotw,@TwGNumerInt = ESS_TwGNumer
   from cdn.eSklepStanowiska where ESS_typ = 2
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900
 --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
 SELECT DISTINCT
IGAW_TwrId as GIDNumer,
IGAW_IGAid as ID,
IGAW_Wartosc as Wartosc
from cdn.iGaleriaAtrWartosci as ATRP
Join CDN.Towary on IGAW_TwrId = Twr_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
left join cdn.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
 WHERE Twes_Udostepnij = 1 AND Twr_NieAktywny = 0 AND case when TwTS_TS_ModESklep is not null and  TwTS_TS_ModESklep > Twr_TS_Mod then TwTS_TS_ModESklep else Twr_TS_Mod end > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
    AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
FOR XML AUTO
END
