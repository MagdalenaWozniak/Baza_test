CREATE PROCEDURE CDN.StanRobot @DataOd DATETIME, @DataDo DATETIME, @Rob INT
AS
SET NOCOUNT ON
DECLARE @IdPrac INT
DECLARE @Ozn Char(1)
DECLARE @Osoba NVARCHAR(71)
DECLARE @Akronim NVARCHAR(20)
CREATE TABLE #Stan (
 TMP_Kod INT,
 Tmp_Ozn Char(1),
 Tmp_Osoba NVARCHAR(71),
 Tmp_Akronim NVARCHAR(20),
 Tmp_Od DATETIME,
 Tmp_Do DATETIME,
 Tmp_Nazwa NVARCHAR(127),
 Tmp_Rob INT
)
DECLARE Tmp_Prac CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
 PRE_PraID,
 case pri_nadrzedny when 1 then '+'else case isnull(pri_parentid,0) when 0 then ' ' else '-'end  end,
 case pri_nadrzedny when 1 then pri_nazwisko+' '+ PRI_Imie1 else case isnull(pri_parentid,0) when 0 then pri_nazwisko+' '+ PRI_Imie1 else pri_nazwisko+' '+ PRI_Imie1 end  end,
  PRI_Kod
  FROM CDN.PracIdx
 join CDN.PracEtaty on PRI_PraId = PRE_PraId
 join CDN.DaneKadMod on PRE_ETADkmIdStanowisko = DKM_DkmId
  WHERE (PRE_ZatrudnionyDo >= @DataOd and PRE_ZatrudnionyOd <= @DataDo)
and PRI_Typ = 1 and DKM_Rodzaj = 1
  order by PRE_DataOd
 OPEN Tmp_Prac
  WHILE 1=1
    BEGIN
      FETCH NEXT FROM Tmp_Prac INTO  @IdPrac, @Ozn, @Osoba, @Akronim
      IF @@FETCH_STATUS <> 0 BREAK
 exec CDN.StanRobotCalc @IdPrac, @Ozn, @Osoba, @Akronim, @DataOd, @DataDo
    END
 CLOSE Tmp_Prac
 DEALLOCATE Tmp_Prac
 SET NOCOUNT OFF
SELECT DISTINCT * FROM #Stan
WHERE (@Rob = Tmp_Rob) and
((Tmp_Od <= @DataDo and Tmp_Do >= @DataOd) or
(Tmp_Od <= @DataOd and Tmp_Do >= @DataDo))
order by Tmp_Osoba
