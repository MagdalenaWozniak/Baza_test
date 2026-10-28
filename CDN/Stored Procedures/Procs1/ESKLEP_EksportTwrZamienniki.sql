CREATE PROCEDURE [CDN].[ESKLEP_EksportTwrZamienniki]
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
      select  @ESSID = ESS_ESSID,@TSSynchr = ESS_TS_SynchroTwrPotw, @TwGNumerInt = ESS_TwGNumer,  @NrCenyInt = ESS_NrCeny,
              @EsklepCena0Int = ESS_EsklepCena0
   from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837
 --SELECT  @TwGNumerInt = CONVERT(INT,@TwGNumer)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1889) SELECT @EsklepCena0= 0 ELSE SELECT @EsklepCena0 = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1889
 --SELECT @EsklepCena0Int = CONVERT(INT,@EsklepCena0)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833) SELECT @NrCeny = 0 ELSE SELECT @NrCeny = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833
 --SELECT @NrCenyInt = CONVERT(INT,@NrCeny)
   INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
   delete from #TwrGrupyESklep where GrONumer = @TwGNumerInt and GIDTyp = 16
 SELECT DISTINCT
 1 AS [@Typ]
 ,ZAM_TwrID AS  [@TwrID]
 ,ZAM_ZamTwrID AS [@TwrID2]
    ,ZAM_Lp AS [@Lp]
 FROM CDN.Zamienniki AS ZMN
 JOIN CDN.Towary T WITH(NOLOCK) ON ZAM_TwrID = T.Twr_TwrID
 JOIN CDN.Towary Z WITH(NOLOCK) ON ZAM_ZamTwrID = Z.Twr_TwrID
LEFT OUTER JOIN CDN.TwrCeny TC ON TC.Twc_TwrId = T.Twr_TwrID  AND (TC.TwC_TwCNumer = @NrCenyInt)
LEFT OUTER JOIN CDN.TwrCeny TCZ ON TCZ.Twc_TwrId = Z.Twr_TwrID  AND (TCZ.TwC_TwCNumer = @NrCenyInt)
LEFT OUTER JOIN cdn.TwrESklep TE on T.Twr_TwrId = TE.Twes_TwrID and TE.Twes_eSklepID = @ESSID
LEFT OUTER JOIN cdn.TwrESklep ZE on Z.Twr_TwrId = ZE.Twes_TwrID and ZE.Twes_eSklepID = @ESSID
left join cdn.TwrTSModEsklep TTS on TTS.TwTS_TwrId = T.Twr_TwrId
left join cdn.TwrTSModEsklep ZTS on ZTS.TwTS_TwrId = Z.Twr_TwrId
 WHERE  TE.Twes_Udostepnij  = 1 AND ZE.Twes_Udostepnij  = 1  AND T.Twr_NieAktywny = 0  AND Z.Twr_NieAktywny = 0
 AND (case when TTS.TwTS_TS_ModESklep is not null and  TTS.TwTS_TS_ModESklep > T.Twr_TS_Mod then TTS.TwTS_TS_ModESklep else T.Twr_TS_Mod end
 > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END OR case when ZTS.TwTS_TS_ModESklep is not null and  ZTS.TwTS_TS_ModESklep > Z.Twr_TS_Mod then ZTS.TwTS_TS_ModESklep else Z.Twr_TS_Mod end
 > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END )
 AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = T.Twr_TwrId )
 AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Z.Twr_TwrId )
AND ((@EsklepCena0Int = 1 AND TC.TwC_Wartosc <> 0 AND TCZ.TwC_Wartosc <> 0) or @EsklepCena0Int <> 1)
FOR XML PATH('TWP'), ROOT('TWPI')
END
