CREATE PROCEDURE [CDN].[ESKLEP_EksportDaneBinarneRomiar]
  @ID INT   -- ID e-sklepu
AS
SET NOCOUNT ON
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
 select @ESSID = ESS_ESSID,@TSSynchr =  ESS_TS_SynchroBinPotw,@TwGNumerInt = ESS_TwGNumer,@TSSynchrGr = ESS_TS_SynchroGrupPotw,@TSSynchrIntGr = ESS_TS_SynchroGrupPotw from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 SELECT @DateTSSynchrGr = dateadd( second, CONVERT(INT,@TSSynchrIntGr),CONVERT(DATETIME,'1990-01-01',120))
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837
 --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
 --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841) SELECT @TSSynchrGr = 0 ELSE SELECT @TSSynchrGr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841
      INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
      delete from #TwrGrupyESklep where GrONumer = @TwGNumerInt and GIDTyp = 16
 if exists (select * from cdn.danebinarne  WHERE DAB_DABID in(
 SELECT DISTINCT DAB_DABId
    FROM CDN.Towary
    JOIN CDN.DanebinarneLinki ON DBL_TwrID = Twr_TwrId
 JOIN CDN.DaneBinarne ON DBL_DABId = DAB_DABId
 LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
    WHERE  DAB_Wartosc IS NOT NULL AND DBL_ESklep =1
    AND Twes_Udostepnij =1 AND Twr_NieAktywny = 0 AND DBL_DaBId is not null
    AND EXISTS(SELECT GrONumer FROM  #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
union all
SELECT DISTINCT DAB_DABId
    FROM CDN.TwrGrupy
    JOIN CDN.TwrGrupyAtrybuty ON TwGA_TwgID = Twg_TwgId
   JOIN CDN.DaneBinarne ON TwGA_DABId = DAB_DABId
    WHERE  DAB_Wartosc IS NOT NULL
      AND TwGA_DaBId is not null
union all
SELECT DISTINCT DAB_DABId
    FROM CDN.Producenci
   JOIN CDN.DaneBinarne ON Prd_Logo = DAB_DABId
    WHERE  DAB_Wartosc IS NOT NULL
      AND Prd_Logo is not null
union all
SELECT DISTINCT DAB_DABId
    FROM CDN.Marki
   JOIN CDN.DaneBinarne ON Mrk_Logo = DAB_DABId
    WHERE  DAB_Wartosc IS NOT NULL
      AND Mrk_Logo is not null  )
      and DATALENGTH(DAB_Wartosc)/1024 > 9999)
      BEGIN
    RaisError ('##OPT34192##', 16,1)
          Return
    END
