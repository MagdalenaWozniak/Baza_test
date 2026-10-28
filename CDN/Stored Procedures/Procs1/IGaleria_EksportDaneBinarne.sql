CREATE PROCEDURE [CDN].[IGaleria_EksportDaneBinarne]
  @TypExp INT  -- Typ eksportu cennika (0 - różnicowy, 1 - pełny)
AS
SET NOCOUNT ON
 DECLARE
     @DABID            INT,
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @TSSynchrGr       nvarchar(254),
     @TSSynchrIntGr    INT,
     @TwGNumer         nvarchar(254),
     @TwGNumerInt      INT,
  @ESSID            int
 CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
 SET @DABID = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1854)
   select  top 1 @ESSID = ESS_ESSID,@TSSynchr = ESS_TS_SynchroTwrPotw ,@TwGNumerInt = ESS_TwGNumer
   from cdn.eSklepStanowiska where ESS_typ = 2
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900
 --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
 INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
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
 LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
     JOIN CDN.DanebinarneLinki ON DBL_TwrID = Twr_TwrId
    JOIN CDN.DaneBinarne ON DBL_DABId = DAB_DABId
    --JOIN (SELECT MIN(Twa_TwaId)AS TwaId  FROM CDN.TwrAtrybuty
    --          join cdn.danebinarne on  TwA_DaBId = DaB_DaBId
--WHERE TwA_DaBId IS NOT NULL  and substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
--in ('jpg','png')
--GROUP BY Twa_TwrId) AS ATRBIN ON TwaId = Twa_TwaId
    WHERE DBL_DaBId IS NOT NULL  and (substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
in ('jpg','png','pdf','doc','xls') or substring (right(dab_nazwapliku,5), convert(int,patindex('%.%',right(dab_nazwapliku,5)))+1,5)
in ('docx','xlsx') )and DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL AND DBL_ESklep =1
    AND Twes_Udostepnij =1 AND Twr_NieAktywny = 0 AND DBL_DaBId is not null  AND DAB_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
    AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
/* SELECT DISTINCT DAB_DABId, ISNULL(DATALENGTH(DAB_Wartosc),0)
    FROM CDN.Towary
    JOIN CDN.TwrAtrybuty ON TwA_TwrID = Twr_TwrId
 JOIN CDN.DaneBinarne ON TwA_DABId = DAB_DABId
    WHERE DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL AND TwA_ESklep =1
    AND Twr_ESklep = 1 AND Twr_NieAktywny = 0 AND TwA_DaBId is not null  AND Twr_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
    AND EXISTS(SELECT GrONumer FROM CDN.TwrGrupyESklep (@TwGNumerInt) WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
    */
/*INSERT INTO @Table2
SELECT DISTINCT DAB_DABId, ISNULL(DATALENGTH(DAB_Wartosc),0)
    FROM CDN.TwrGrupy
    JOIN CDN.TwrGrupyAtrybuty ON TwGA_TwgID = Twg_TwgId
   JOIN CDN.DaneBinarne ON TwGA_DABId = DAB_DABId
    WHERE DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL
      AND TwGA_DaBId is not null  AND TwG_CzasModyfikacji > CASE WHEN @TypExp=0 THEN @TSSynchrIntGr ELSE 0 END
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
      AND Mrk_Logo is not null  AND Mrk_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END*/
 INSERT INTO @Table
select distinct DABID , DABRozmiar from @Table2
 ORDER BY DABId
 UPDATE @Table SET @Rozmiar = @Rozmiar + DABRozmiar, DABRozmiar = @Rozmiar
 SELECT @Last_DABID = MAX(DABID) FROM @Table WHERE DABRozmiar <= @RozmiarMax
 UPDATE CDN.Firma SET Fir_Wartosc = (CASE WHEN @Last_DABID < (SELECT MAX(DABID) FROM @Table) THEN @Last_DABID ELSE 0 END) WHERE Fir_Numer = 1854
 SELECT DAB_DABID AS ID, DAB_Nazwa AS Nazwa, substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4) AS Rozszerzenie, DAB_Rozmiar AS Rozmiar, DAB_Wartosc AS Dane FROM CDN.DaneBinarne AS DAB
 WHERE DAB_DABID IN (SELECT DABID FROM @Table WHERE DABID <= @Last_DABID)
 FOR XML AUTO,BINARY BASE64
