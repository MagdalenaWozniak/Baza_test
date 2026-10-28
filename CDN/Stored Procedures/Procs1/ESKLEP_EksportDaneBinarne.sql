CREATE  PROCEDURE [CDN].[ESKLEP_EksportDaneBinarne]
  @ID INT   -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu cennika (0 - różnicowy, 1 - pełny)
 ,@DABID INT OUTPUT -- ID danych binarnych, które zostały jako ostatnie wyeksportowane do e-sklepu w poprzedniej paczce
     -- Jeżeli @DABID = -1 to w OUTPUT zwracany jest DAB_DABID danych binarnych wyeksportowanych jako ostatnie w poprzedniej paczce
AS
SET NOCOUNT ON
 IF @DABID = -1
 BEGIN
  --SET @DABID = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1854)
  SET @DABID = (SELECT ESS_OstatnieDabId FROM CDN.eSklepStanowiska WHERE ESS_IdISklep = @ID)
  RETURN
 END
 DECLARE
     @ESSID            int,
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @TSSynchrGr       nvarchar(254),
     @TSSynchrIntGr    INT,
  @DateTSSynchrGr   DATETIME,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT
  CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
 select @ESSID = ESS_ESSID,@TSSynchr =  case when  ESS_TS_SynchroBinPotw = 0 then ESS_TS_SynchroTwrPotw else ESS_TS_SynchroBinPotw end ,@TwGNumerInt = ESS_TwGNumer,@TSSynchrGr = ESS_TS_SynchroGrupPotw,@TSSynchrIntGr = ESS_TS_SynchroGrupPotw from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 SELECT @DateTSSynchrGr = dateadd( second, CONVERT(INT,@TSSynchrIntGr),CONVERT(DATETIME,'1990-01-01',120))
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837
 --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841) SELECT @TSSynchrGr = 0 ELSE SELECT @TSSynchrGr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841
      INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
      delete from #TwrGrupyESklep where GrONumer = @TwGNumerInt and GIDTyp = 16
 DECLARE  @Rozmiar BIGINT
   ,@RozmiarMax BIGINT -- Maksymalny rozmiar danych binarnych eksportowanych w jednej paczce
   ,@Last_DABID INT
 DECLARE @Table TABLE(DABID INT, DABRozmiar BIGINT)
 DECLARE @Table2 TABLE(DABID INT, DABRozmiar BIGINT)
 SELECT  @Rozmiar = 0
   ,@RozmiarMax = 10485760 -- 10MB
        --,@RozmiarMax = 20971520 --20MB
 INSERT INTO @Table2
  SELECT DISTINCT DAB_DABId, ISNULL(DATALENGTH(DAB_Wartosc),0)
    FROM CDN.Towary
    JOIN CDN.DanebinarneLinki ON DBL_TwrID = Twr_TwrId
 JOIN CDN.DaneBinarne ON DBL_DABId = DAB_DABId
 LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
    WHERE DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL AND DBL_ESklep =1
    AND Twes_Udostepnij =1 AND Twr_NieAktywny = 0 AND DBL_DaBId is not null  AND DAB_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
    AND EXISTS(SELECT GrONumer FROM  #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
INSERT INTO @Table2
SELECT DISTINCT DAB_DABId, ISNULL(DATALENGTH(DAB_Wartosc),0)
    FROM CDN.TwrGrupy
    JOIN CDN.TwrGrupyAtrybuty ON TwGA_TwgID = Twg_TwgId
   JOIN CDN.DaneBinarne ON TwGA_DABId = DAB_DABId
    WHERE DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL
      AND TwGA_DaBId is not null  AND DAB_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchrGr ELSE 0 END
INSERT INTO @Table2
SELECT DISTINCT DAB_DABId, ISNULL(DATALENGTH(DAB_Wartosc),0)
    FROM CDN.Producenci
   JOIN CDN.DaneBinarne ON Prd_Logo = DAB_DABId
    WHERE DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL
      AND Prd_Logo is not null  AND Prd_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
INSERT INTO @Table2
SELECT DISTINCT DAB_DABId, ISNULL(DATALENGTH(DAB_Wartosc),0)
    FROM CDN.Marki
   JOIN CDN.DaneBinarne ON Mrk_Logo = DAB_DABId
    WHERE DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL
      AND Mrk_Logo is not null  AND Mrk_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
 INSERT INTO @Table
select distinct DABID , DABRozmiar from @Table2
 ORDER BY DABId
 --UPDATE @Table SET @Rozmiar = @Rozmiar + DABRozmiar, DABRozmiar = @Rozmiar
  ;WITH q AS (
    SELECT  top 10000000000000 *
    FROM    @Table
    ORDER BY
            DABID
)
UPDATE  q
SET     @Rozmiar = @Rozmiar + DABRozmiar, DABRozmiar = @Rozmiar
 SELECT @Last_DABID = MAX(DABID) FROM @Table WHERE DABRozmiar <= @RozmiarMax
 --UPDATE CDN.Firma SET Fir_Wartosc = (CASE WHEN @Last_DABID < (SELECT MAX(DABID) FROM @Table) THEN @Last_DABID ELSE 0 END) WHERE Fir_Numer = 1854
 UPDATE CDN.eSklepStanowiska SET ESS_OstatnieDabId = (CASE WHEN @Last_DABID < (SELECT MAX(DABID) FROM @Table) THEN @Last_DABID ELSE 0 END) WHERE ESS_IdISklep = @ID
 SELECT DAB_DABID AS ID, DAB_Nazwa AS Nazwa, substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4) AS Rozszerzenie, DAB_Rozmiar AS Rozmiar,case when DAB_Rozmiar > 0 then DAB_Rozmiar else DATALENGTH(DAB_Wartosc) end AS Rozmiar2,   DAB_Wartosc AS Dane FROM CDN.DaneBinarne AS DAB
 WHERE DAB_DABID IN (SELECT DABID FROM @Table WHERE DABID <= @Last_DABID)
 FOR XML AUTO,BINARY BASE64
