CREATE PROCEDURE [CDN].[KartaCzasuPracy] @DataOd DATETIME, @DataDo DATETIME, @PrcId INT, @TylkoPodsum INT, @TylkoStrefy INT
AS
SET NOCOUNT ON
IF @DataOd IS NULL OR @DataDo IS NULL
 BEGIN
  SET @DataOd = '1899-12-30 00:00:00'
  SET @DataDo = '1899-12-30 00:00:00'
 END
 ELSE
 BEGIN
  SET @DataOd = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataOd) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataOd) AS NVARCHAR)+' 00:00:000', 120)
  SET @DataDo = CONVERT(DATETIME, CAST(DATEPART(year ,@DataDo) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDo) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataDo) AS NVARCHAR)+' 00:00:000', 120)
 END
--Tworze tabele tymczasowa, ktora zwracac bedzie czas pracy pracownika
CREATE TABLE #CzasPracy
(
 Tmp_Typ          INT,
 Tmp_PrcId        INT,
 Tmp_Rok          INT,
 Tmp_Mc           INT,
 Tmp_Dzien        INT,
 Tmp_Data         DATETIME,
 Tmp_PNBId        INT,
 Tmp_NormaTyg     DECIMAL(15,2),
 Tmp_NormaDob     DECIMAL(15,2),
 Tmp_Nadgodz50    DECIMAL(15,2),
 Tmp_Nadgodz100   DECIMAL(15,2),
 Tmp_NadgodzDS    DECIMAL(15,2),
 Tmp_GodzNocne    DECIMAL(15,2),
 Tmp_Praca        DECIMAL(15,2),
 Tmp_PrcEtat      DECIMAL(15,2),
 Tmp_PracaPlan    DECIMAL(15,2),
 Tmp_OdGodz       INT,
 Tmp_OdGodzPlan   INT,
 Tmp_NBZwolLek    INT,
 Tmp_NBUrlMac     INT,
 Tmp_NBUrlReh     INT,
 Tmp_NBUrlopyOk   INT, --Urlop okolicznosciowy
 Tmp_NBNN         INT, --Nieusprawiedliwiona
 Tmp_NBZwolOpieka INT,
 Tmp_NBUrlWych    INT,
 Tmp_NBUrlBezp    INT,
 Tmp_NBInne       INT,
 Tmp_NBSW         INT, -- sluzba wojskowa
 Tmp_NBUrlopyWyp  INT, --Urlop wypoczynkowy
 Tmp_NBNiePomn    INT, -- nie pomniejszajaca czasu pracy
 Tmp_NBWlasna1    INT, -- nieobecnosci wlasne dodefiniowane
 Tmp_NBWlasna2    INT,
 Tmp_NBWlasna3    INT,
 Tmp_NBWlasna4    INT,
 Tmp_NBWlasna5    INT,
 Tmp_NBWlasna6    INT,
 Tmp_NBWlasna7    INT,
 Tmp_NBWlasna8    INT,
 Tmp_NBUrlOp   INT, -- Urlop opiekunczy -- SB 2021 [] --
 Tmp_TnkId   INT,
 Tmp_Opis         NVARCHAR(400), -- opis nieobecnosci
 Tmp_DstId        INT -- strefa
)
--CREATE UNIQUE INDEX TmpData ON #CzasPracy(Tmp_Data)
CREATE INDEX TmpPrcId ON #CzasPracy(Tmp_Prcid)
exec CDN.KartaCzasuPracyCalc @DataOd, @DataDo, @PrcId, @TylkoPodsum
-- Jesli tylko podsumowanie to kasuje elementy
IF @TylkoPodsum=1
  DELETE FROM #CzasPracy where Tmp_Typ<>2
ELSE
BEGIN
  --
  -- GRUPUJE CZAS W STREFACH
  --
  DECLARE @S1  INT
  DECLARE @S2  INT
  DECLARE @S3  INT
  DECLARE Tmp_SumaNB CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Sum (Tmp_NormaDob), Sum (Tmp_Praca),  Tmp_DstId
      FROM #CzasPracy WHERE Tmp_Typ=3
      GROUP BY Tmp_DstId
  OPEN Tmp_SumaNB
  WHILE 1=1
  BEGIN
     FETCH NEXT FROM Tmp_SumaNB INTO @S1, @S2, @S3
     IF @@FETCH_STATUS <> 0 BREAK
     INSERT INTO #CzasPracy
       SELECT 4, @PrcId,
          null,
          null,
          null,
          null,
          null,
          null,
          @S1,
          0,0,0,0,@S2,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,null,0,@S3 -- SB 2021 [12263] --
  END
  CLOSE Tmp_SumaNB
  DEALLOCATE Tmp_SumaNB
  -- Po podsumowaniu kasuje niepotrzebne wyniki
  --
  IF @TylkoStrefy=1
    DELETE FROM #CzasPracy where Tmp_Typ<>3
  ELSE
    DELETE FROM #CzasPracy WHERE Tmp_Typ=3
  DELETE FROM #CzasPracy WHERE Tmp_Typ=4 AND Tmp_DstId=0
END
SET NOCOUNT OFF
-- Nie przestawiac kolejnosci kolumn w selekcie gdyz powoduje to problem z wydrukami GenRap
SELECT
 Dst_Nazwa as Tmp_Strefa, Tmp_DstId, Tmp_Typ, Tmp_PrcId, Tmp_Rok, Tmp_Mc, Tmp_Dzien, Tmp_Data, Tmp_PNBId, Tmp_NormaTyg, Tmp_NormaDob, Tmp_Nadgodz50, Tmp_Nadgodz100, Tmp_NadgodzDS, Tmp_GodzNocne, Tmp_Praca, Tmp_PrcEtat, Tmp_PracaPlan, Tmp_OdGodz, Tmp_OdGodzPlan, Tmp_NBZwolLek, Tmp_NBUrlMac, Tmp_NBUrlReh, Tmp_NBUrlopyOk, Tmp_NBNN, Tmp_NBZwolOpieka, Tmp_NBUrlWych, Tmp_NBUrlBezp, Tmp_NBInne, Tmp_NBSW, Tmp_NBUrlopyWyp, Tmp_NBNiePomn, Tmp_NBWlasna1, Tmp_NBWlasna2, Tmp_NBWlasna3, Tmp_NBWlasna4, Tmp_NBWlasna5, Tmp_NBWlasna6, Tmp_NBWlasna7, Tmp_NBWlasna8, Tmp_TnkId, Tmp_Opis, Tmp_DstId, DST_DstId, DST_Akronim, DST_Nazwa, DST_UwzglCzasPracy, DST_Symbol, DST_ProcentWynZas, DST_Standardowy, DST_OpeZalId, DST_StaZalId, DST_TS_Zal, DST_OpeModId, DST_StaModId, DST_TS_Mod, Tmp_NBUrlOp -- SB 2021 [12263] --
FROM #CzasPracy left outer join CDN.DefinicjeStref on dst_dstid = Tmp_DstId ORDER BY Tmp_Typ Desc, Tmp_Data
