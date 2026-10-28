CREATE PROCEDURE CDN.Trzydziestokrotnosc @DataWydr DATETIME, @Guid NVARCHAR(50), @OperatorID INT
AS
SET NOCOUNT ON
DECLARE @Dzien DATETIME
DECLARE @Nazw NVARCHAR(40)
DECLARE @Im NVARCHAR(30)
DECLARE @ER DECIMAL(15,2)
DECLARE @Wypad DECIMAL(15,2)
DECLARE @Chor DECIMAL(15,2)
DECLARE @IdPrc INT
DECLARE @Mies INT
DECLARE @BuffPrcId INT
SET @BuffPrcId = 0
DECLARE @prcid int
CREATE TABLE #Trzydziest (
 Tmp_Prcid INT,
 Tmp_Nazwisko NVARCHAR(40),
 Tmp_Imie NVARCHAR(30),
 Tmp_ER DECIMAL(15,2),
 Tmp_Chor DECIMAL(15,2),
 Tmp_Wypad DECIMAL(15,2),
 Tmp_Mies INT
)
DECLARE Tmp_Trzydziest CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
case when ISNULL(pri_parentid,0)=0 then pri_praid else pri_parentid end as parentid,
case pri_nadrzedny when 1 then '+ '+A.PRE_Nazwisko else case isnull(pri_parentid,0) when 0 then A.pre_nazwisko else '- '+A.pre_nazwisko  end  end,
case pri_nadrzedny when 1 then A.PRE_Imie1+ ' [' + A.PRE_Kod+']' else case isnull(pri_parentid,0) when 0 then A.PRE_Imie1+' [' + A.PRE_Kod+']' else A.PRE_Imie1+' [' + A.PRE_Kod+']'  end  end,
sum(WPE_PodstEmer) AS ER,
sum(WPE_PodstChor) as CHOR,
sum(WPE_PodstWypad) AS WYP,
A.PRE_PraId
FROM CDN.PracEtaty A
 join CDN.Wyplaty on PRE_PraId = WPL_Praid
 join CDN.WypElementy on WPL_WplId = WPE_WplId
 join CDN.ListyPlac on LPL_LplId = WPL_LplId
 join CDN.RptZaznaczenia2 on A.PRE_PraId = RpZ2_GIDNumer
 join CDN.Pracidx on PRI_PraId = A.PRE_PraId
 join CDN.PracEtaty B on B.PRE_PraId = RpZ2_GIDNumer
 join CDN.ZakazyDoWydzialowView on B.PRE_DzlId = DzlId
WHERE A.PRE_DataOd <= @DataWydr AND A.PRE_DataDo >= @DataWydr
 and PRI_TYP = 1
 and WPL_Tryb <> 1 and WPL_Tryb <> 2
 AND LPL_DataDok <= @DataWydr AND Year(LPL_DataDok) = Year(@DataWydr)
 AND RpZ2_GUID = @Guid
 and CONVERT(DATETIME, CAST(DATEPART(year ,getdate()) AS NVARCHAR) +'-'+CAST(DATEPART(month ,getdate()) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,getdate()) AS NVARCHAR)+' 00:00:000', 120) between B.Pre_DataOd and B.Pre_DataDo
 and OpeId = @OperatorID
 and WyplatyView is null
GROUP BY A.PRE_Nazwisko, A.PRE_Imie1, A.PRE_PraId, pri_nadrzedny, pri_parentid, A.PRE_Kod,PRI_PraId,wpl_miesiac,wpl_wplid
HAVING  (sum(WPE_PodstEmer) < sum(WPE_PodstChor) OR sum(WPE_PodstEmer) < sum(WPE_PodstWypad))
ORDER BY A.PRE_Nazwisko, A.PRE_Imie1,parentid,wpl_miesiac asc, wpl_wplid
  OPEN Tmp_Trzydziest
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM Tmp_Trzydziest INTO  @prcid,@Nazw, @Im, @ER, @Chor, @Wypad,  @IdPrc
   IF @@FETCH_STATUS <> 0 BREAK
     BEGIN
 SET @Mies = (select top 1 WPL_Miesiac from CDN.PracEtaty
 join CDN.Wyplaty on PRE_PraId = WPL_Praid
 join CDN.WypElementy on WPL_WplId = WPE_WplId
 WHERE Pre_PraId = @IdPrc and  WPL_Tryb <> 1 and WPL_Tryb <> 2 and WPL_Rok = Year(@DataWydr)
 GROUP BY WPL_Miesiac
 HAVING (sum(WPE_PodstEmer) < sum(WPE_PodstChor) OR sum(WPE_PodstEmer) < sum(WPE_PodstWypad))
 order by WPL_Miesiac asc)
if @BuffPrcId <> @PrcId
   begin
   INSERT INTO #Trzydziest values (@prcid,@Nazw, @Im, @ER, @Chor, @Wypad, @Mies)
   set @BuffPrcId = @PrcId
end
     END
  END
 CLOSE Tmp_Trzydziest
 DEALLOCATE Tmp_Trzydziest
 SET NOCOUNT OFF
SELECT * FROM #Trzydziest
