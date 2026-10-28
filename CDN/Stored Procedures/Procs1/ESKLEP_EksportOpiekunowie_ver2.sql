CREATE  PROCEDURE [CDN].[ESKLEP_EksportOpiekunowie_ver2]
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
 ,@ExpKontrahenci INT
 ,@ExpTwr INT
 AS
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @TSSynchrKnt      nvarchar(254),
     @DateTSSynchrKnt  DATETIME,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT,
     @NrCeny           nvarchar(254),
     @NrCenyInt        INT,
     @EsklepCena0      nvarchar(254),
     @EsklepCena0Int   INT,
  @ESSID            int
     CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
  CREATE TABLE #OpiekunID (OpiekunID INT)
     SELECT  @ESSID = ESS_ESSID,@TSSynchr = ESS_TS_SynchroTwrPotw, @TSSynchrKnt = ESS_TS_SynchroKntPotw, @TwGNumerInt = ESS_TwGNumer,  @NrCenyInt = ESS_NrCeny,
              @EsklepCena0Int = ESS_EsklepCena0
     FROM cdn.eSklepStanowiska where ESS_IdISklep = @ID
     SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120)), @DateTSSynchrKnt =dateadd( second, CONVERT(INT,@TSSynchrKnt),CONVERT(DATETIME,'1990-01-01',120))
     INSERT INTO  #TwrGrupyESklep
          SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
     delete from #TwrGrupyESklep where GrONumer = @TwGNumerInt and GIDTyp = 16
     if(@ExpTwr = 1)
  INSERT INTO  #OpiekunID
  SELECT DISTINCT
          twr_opiekunid
  from CDN.Towary T WITH(NOLOCK)
  LEFT OUTER JOIN CDN.TwrCeny TC ON TC.Twc_TwrId = T.Twr_TwrID  AND (TC.TwC_TwCNumer = @NrCenyInt)
  LEFT OUTER JOIN cdn.TwrESklep TE on T.Twr_TwrId = TE.Twes_TwrID and TE.Twes_eSklepID = @ESSID
  LEFT OUTER JOIN cdn.TwrTSModEsklep TTS on TTS.TwTS_TwrId = T.Twr_TwrId
  WHERE  TE.Twes_Udostepnij  = 1   AND T.Twr_NieAktywny = 0
  AND case when TTS.TwTS_TS_ModESklep is not null and  TTS.TwTS_TS_ModESklep > T.Twr_TS_Mod then TTS.TwTS_TS_ModESklep else T.Twr_TS_Mod end > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
  AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = T.Twr_TwrId )
  AND ((@EsklepCena0Int = 1 AND TC.TwC_Wartosc <> 0) or @EsklepCena0Int <> 1)
  AND isnull(Twr_OpiekunID,0) > 0 AND isnull(Twr_OpiekunTyp,0) = 8
 if @ExpKontrahenci = 1
  INSERT INTO  #OpiekunID
  SELECT DISTINCT
   knt_opiekunid
  from cdn.Kontrahenci b
  left outer join cdn.KntESklepy on b.Knt_KntId = KES_KntID and KES_eSklepID = @ESSID
  left outer join cdn.eSklepKntRelacje on b.Knt_KntId = ESK_KntOptimaID and ESK_eSklepID = @ESSID
  where
  KES_KntID is not null and
  b.Knt_Nieaktywny = 0 and
  b.Knt_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchrKnt ELSE 0 END and
  b.Knt_Nazwa1 <> '' and
  b.Knt_Email  <> ''and
  b.Knt_Ulica <> ''and
  b.Knt_NrDomu <> ''and
  b.Knt_KodPocztowy  <> ''and
  b.Knt_Miasto  <> ''and
  ISNULL(b.Knt_LpAnonimizacji, 0) = 0
  and isnull(Knt_OpiekunID,0) > 0 and isnull(Knt_OpiekunTyp,0) = 8
 DECLARE @fulldbname nvarchar(300)
 SET @fulldbname = CDN.BazaKonfiguracyjna()
 CREATE TABLE #KodyOperatorow(OpiekunID INT PRIMARY KEY, Nazwisko NVARCHAR(50), Telefon NVARCHAR(20),Email nVARCHAR(192))
 DECLARE @sqltxt NVARCHAR(512)
 SET @sqltxt = 'INSERT INTO  #KodyOperatorow(OpiekunID, Nazwisko,Telefon,Email)  SELECT OpE_OpEId,  LTRIM(RTRIM(OpE_Nazwisko)), Ope_Telefon, ope_Email FROM ' + CDN.BazaKonfiguracyjna() + N'.cdn.Operatorzy'
 EXEC sp_executeSql @sqltxt
 select  [@OpiekunID]=OpiekunID, [@Imie]= case when len(Nazwisko) > 1  and charindex(' ',Nazwisko) > 0 then substring(Nazwisko,1,charindex(' ',Nazwisko)-1) else '' end,
 [@Nazwisko]= case when len(Nazwisko) > 1 then case when charindex(' ',Nazwisko) = 0 then Nazwisko else  substring(Nazwisko,charindex(' ',Nazwisko)+1,datalength(Nazwisko)-charindex(' ',Nazwisko)) end else '' end,
 [@Telefon]=Telefon, [@Email]=Email from #KodyOperatorow
 where OpiekunID in (select OpiekunID from #OpiekunID)
 for xml  PATH('OPP'), type
 drop table #KodyOperatorow
 drop table #TwrGrupyESklep
 drop table #OpiekunID
