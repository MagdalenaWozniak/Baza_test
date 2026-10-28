CREATE PROCEDURE [CDN].[Z3_Macierzynskie] @DataZas DATETIME, @IdPrac INT
AS
SET NOCOUNT ON
DECLARE @Okres_Od DATETIME
DECLARE @Okres_Do DATETIME
DECLARE @Kont INT
DECLARE @Nazwa NVarChar(40)
CREATE TABLE #Macierz(
 Tmp_Prcid INT,
 Tmp_Od DATETIME,
 Tmp_Do DATETIME,
 Tmp_Kontynuacja INT,
 Tmp_Nazwa NVarChar(40)
 )
DECLARE Tmp_Prac CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 Tnb_Nazwa
 FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 WHERE PNB_PraId = @IdPrac and TNB_PdzId in (311, 319, 325, 327)  and (PNB_Tryb = 0 or PNB_Tryb = 2) and @DataZas between Pnb_OkresOd and PNB_OkresDo
 --group by PRI_PraID ,  case pri_nadrzedny when 1 then '+'else case isnull(pri_parentid,0) when 0 then ' ' else '-'end  end,  case pri_nadrzedny when 1 then pri_nazwisko+' '+ PRI_Imie1 else case isnull(pri_parentid,0) when 0 then pri_nazwisko+' '+ PRI_Imie1 else pri_nazwisko+' '+ PRI_Imie1 end  end,PRI_Kod
 OPEN Tmp_Prac
  WHILE 1=1
    BEGIN
      FETCH NEXT FROM Tmp_Prac INTO  @IdPrac, @Okres_Od, @Okres_Do, @Nazwa
      IF @@FETCH_STATUS <> 0 BREAK
 exec CDN.Z3_MacierzynskieCalc @IdPrac, @Okres_Od, @Okres_Do--, @Nazwa
    END
 CLOSE Tmp_Prac
 DEALLOCATE Tmp_Prac
 SET NOCOUNT OFF
SELECT DISTINCT * FROM #Macierz order by Tmp_Od desc
