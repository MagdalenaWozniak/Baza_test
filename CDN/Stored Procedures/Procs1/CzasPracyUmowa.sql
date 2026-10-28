CREATE PROCEDURE [CDN].[CzasPracyUmowa] @Mies INT, @Rok INT, @Typ INT, @Guid NVARCHAR(50)
AS
SET NOCOUNT ON
DECLARE @IdPrac INT
DECLARE @Ozn Char(1)
DECLARE @Osoba NVarChar(71)
DECLARE @Kod NVarChar(20)
DECLARE @DataOd DATETIME
DECLARE @DataDo DATETIME
DECLARE @Czas INT
DECLARE @Data NVarChar(11)
DECLARE @NrUmowy NVarChar(31)
DECLARE @Od DATETIME
DECLARE @Do DATETIME
SET @DataOd = CONVERT(DATETIME, STR(@Rok) +'-'+STR(@Mies)+'-'+ '01'+' 00:00:000', 120)
IF  @Mies in (1,3,5,7,8,10,12)
SET @DataDo = CONVERT(DATETIME,STR(@Rok) +'-'+STR(@Mies)+'-'+ '31'+' 00:00:000', 120)
IF  @Mies in (4,6,9,11)
SET @DataDo = CONVERT(DATETIME,STR(@Rok) +'-'+STR(@Mies)+'-'+ '30'+' 00:00:000', 120)
IF  @Mies =2
SET @DataDo = CONVERT(DATETIME,STR(@Rok) +'-'+'3'+'-'+ '01'+' 00:00:000', 120)-1
--select @DataDo
CREATE TABLE #CzasUmowy(
 Tmp_Znacznik smallint,
 Tmp_Prcid INT,
 Tmp_Ozn NVarChar(1),
 Tmp_Osoba NVarChar(71),
 Tmp_Akronim NVarChar(20),
 Tmp_Data  NVarChar(11),
 Tmp_Czas INT,
 Tmp_NumerUmowy NVarChar(31)
)
IF @Typ = 1 or @Typ = 3
BEGIN
DECLARE Tmp_CzasU_1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
 PRI_PraID,
 case pri_nadrzedny when 1 then '+'else case isnull(pri_parentid,0) when 0 then ' ' else '-'end  end,
 case pri_nadrzedny when 1 then pri_nazwisko+' '+ PRI_Imie1 else case isnull(pri_parentid,0) when 0 then pri_nazwisko+' '+ PRI_Imie1 else pri_nazwisko+' '+ PRI_Imie1 end  end,
 PRI_Kod,
 'ZESTAWIENIE',
 isnull(DATEDIFF(n,convert(datetime ,'1899-12-30 00:00:00.000',120),UMZ_Czas),0),
 UMW_NumerPelny
 FROM CDN.PracIdx
 join CDN.RptZaznaczenia2 on PRI_PraId = RpZ2_GIDNumer join CDN.Umowy on PRI_PraId = UMW_PraId join TypWyplata on TWP_TwpId = UMW_TwpId left join CDN.UmowyZestCzasu on UMW_UmwId = UMZ_UmwId and UMZ_Miesiac = @Mies and UMZ_Rok = @Rok
 WHERE RpZ2_GUID = @Guid and PRI_Typ = 1 and (@DataOd between UMW_DataOd and UMW_DataDo or UMW_DataOd between @DataOd and @DataDo) and (UMW_UwzglMin = 1 or TWP_AlgAlgorytm = 14)
 and UMW_CzasPracy=1
 OPEN Tmp_CzasU_1
  WHILE 1=1
    BEGIN
      FETCH NEXT FROM Tmp_CzasU_1 INTO  @IdPrac, @Ozn, @Osoba,@Kod, @Data, @Czas, @NrUmowy
      IF @@FETCH_STATUS <> 0 BREAK
   INSERT INTO #CzasUmowy values (1,@IdPrac, @Ozn, @Osoba,@Kod, @Data, @Czas, @NrUmowy)
 END
 CLOSE Tmp_CzasU_1
 DEALLOCATE Tmp_CzasU_1
 SET NOCOUNT OFF
 END
IF @Typ = 2 or @Typ = 3
BEGIN
DECLARE Tmp_CzasU_2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
 PRI_PraID,
 case pri_nadrzedny when 1 then '+'else case isnull(pri_parentid,0) when 0 then ' ' else '-'end  end,
 case pri_nadrzedny when 1 then pri_nazwisko+' '+ PRI_Imie1 else case isnull(pri_parentid,0) when 0 then pri_nazwisko+' '+ PRI_Imie1 else pri_nazwisko+' '+ PRI_Imie1 end  end,
 PRI_Kod,
 CASE WHEN UMW_DataOd < @DataOd THEN @DataOd ELSE UMW_DataOd END,
 CASE WHEN UMW_DataDo > @DataDo THEN @DataDo ELSE UMW_DataDo END,
 UMW_NumerPelny
 FROM CDN.PracIdx
 join CDN.RptZaznaczenia2 on PRI_PraId = RpZ2_GIDNumer join CDN.Umowy on PRI_PraId = UMW_PraId join TypWyplata on TWP_TwpId = UMW_TwpId
 WHERE RpZ2_GUID = @Guid and PRI_Typ = 1 and (@DataOd between UMW_DataOd and UMW_DataDo or UMW_DataOd between @DataOd and @DataDo) and (UMW_UwzglMin = 1 or TWP_AlgAlgorytm = 14)
 and UMW_CzasPracy=0
 OPEN Tmp_CzasU_2
 WHILE 1=1
    BEGIN
      FETCH NEXT FROM Tmp_CzasU_2 INTO  @IdPrac, @Ozn, @Osoba,@Kod, @Od, @Do, @NrUmowy
      IF @@FETCH_STATUS <> 0 BREAK
   EXEC [CDN].[CzasPracyUmowaCalc] @IdPrac, @Ozn, @Osoba,@Kod, @Od, @Do, @NrUmowy
 END
 CLOSE Tmp_CzasU_2
 DEALLOCATE Tmp_CzasU_2
 SET NOCOUNT OFF
END
SELECT Tmp_Znacznik,Tmp_Prcid,Tmp_Ozn,Tmp_Osoba,Tmp_Akronim, Tmp_Data, Tmp_Czas, Tmp_NumerUmowy FROM #CzasUmowy
