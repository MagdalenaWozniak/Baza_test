CREATE PROCEDURE [CDN].[IGaleria_CzyEksportDaneBinarne]
 @Opcje INT
 ,@CzyEksport INT OUTPUT
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
     @TypSynchro       INT,
     @ExpDaneBinarnePaczki INT,
  @ESSID            int
     set @ExpDaneBinarnePaczki = (@Opcje & 64) / 64
   CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
      IF (@Opcje & 1 = 0)
  set @CzyEksport = 0
     ELSE
     begin
        set @TypSynchro = (@Opcje & 2) / 2
 SET @DABID = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1854)
  if(@ExpDaneBinarnePaczki = 1 and  @DABID = 0)
  begin
  set @CzyEksport = 0
  return
  end
select  top 1 @ESSID = ESS_ESSID, @TSSynchr = ESS_TS_SynchroTwrPotw,@TwGNumerInt = ESS_TwGNumer
   from cdn.eSklepStanowiska where ESS_typ = 2
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900
 --SELECT @TwGNumerInt = CONVERT(INT,@TwGNumer)
INSERT INTO  #TwrGrupyESklep
     SELECT * FROM CDN.TwrGrupyESklep (@TwGNumerInt)
if
 (SELECT sum(CAST(ISNULL(DATALENGTH(DAB_Wartosc),0) as bigint))
    FROM CDN.Towary
 LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
    JOIN CDN.danebinarnelinki ON Twr_TwrId = dbl_TwrId
    JOIN CDN.DaneBinarne ON dbl_DABId = DAB_DABId
    --JOIN (SELECT MIN(dbl_dblId)AS TwaId  FROM CDN.danebinarnelinki
    --          join cdn.danebinarne on  dbl_DaBId = DaB_DaBId
--WHERE dbl_DaBId IS NOT NULL  and substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
--in ('jpg','png')AND dbl_ESklep =1
--GROUP BY dbl_TwrId) AS ATRBIN ON TwaId = dbl_dblId
--    WHERE DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL AND dbl_ESklep =1
--    AND Twes_Udostepnij =1 AND Twr_NieAktywny = 0 AND dbl_DaBId is not null  AND Twr_TS_Mod > CASE WHEN @TypSynchro=0 THEN @DateTSSynchr ELSE 0 END
WHERE DBL_DaBId IS NOT NULL  and (substring (right(dab_nazwapliku,4), convert(int,patindex('%.%',right(dab_nazwapliku,4)))+1,4)
in ('jpg','png','pdf','doc','xls') or substring (right(dab_nazwapliku,5), convert(int,patindex('%.%',right(dab_nazwapliku,5)))+1,5)
in ('docx','xlsx') )and DAB_DABId > @DABID AND DAB_Wartosc IS NOT NULL AND DBL_ESklep =1
    AND Twes_Udostepnij =1 AND Twr_NieAktywny = 0 AND DBL_DaBId is not null  AND DAB_TS_Mod > CASE WHEN @TypSynchro=0 THEN @DateTSSynchr ELSE 0 END
    AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId ) ) > 0
    select @CzyEksport = 1
    else
    select @CzyEksport = 0
end
