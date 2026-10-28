CREATE PROCEDURE CDN.Przekroczenie @DataDoch DATETIME, @OperatorID INT
AS
SET NOCOUNT ON
DECLARE @Dzien DATETIME
DECLARE @Data DATETIME
DECLARE @Nazw NVARCHAR(40)
DECLARE @Im NVARCHAR(30)
DECLARE @Doch DECIMAL(15,2)
DECLARE @Proc INT
DECLARE @Proc1 INT
DECLARE @IdPrc INT
DECLARE @Dochod DECIMAL(15,2)
DECLARE @dochodSum DECIMAL(15,2)
DECLARE @dochSum   DECIMAL(15,2)
DECLARE @BuffPrcId INT
SET @BuffPrcId = 0
DECLARE @prcid int
SET @Proc = 19
SET @Data = (CONVERT(DATETIME, CAST(DATEPART(year ,@DataDoch) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDoch) AS NVARCHAR)+'-'+ CAST(1 AS NVARCHAR) +' 00:00:000', 120)) - 1
CREATE TABLE #PrzekrProgu (
 Tmp_Prcid INT,
 Tmp_Nazwisko NVARCHAR(40),
 Tmp_Imie NVARCHAR(30),
 Tmp_Id INT,
 Tmp_Dochod DECIMAL(15,2),
 Tmp_Procent INT
)
DECLARE Tmp_PrzekrPr CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
case when ISNULL(pri_parentid,0)=0 then pri_praid else pri_parentid end as parentid,
case pri_nadrzedny when 1 then '+ '+A.pre_nazwisko else case isnull(pri_parentid,0) when 0 then A.pre_nazwisko else '- '+A.pre_nazwisko  end  end as nazwisko,
case pri_nadrzedny when 1 then A.PRE_Imie1+ ' [' + A.PRE_Kod+']' else case isnull(pri_parentid,0) when 0 then A.PRE_Imie1+' [' + A.PRE_Kod+']' else A.PRE_Imie1+' [' + A.PRE_Kod+']'  end  end,
A.PRE_Preid,
sum(WPE_Wartosc-WPE_SklEmerPrac-WPE_SklRentPrac-WPE_SklChorPrac-WPE_Koszty-WPE_Koszty50),
case when (select count(PRG_PrgId) from CDN.Progi where A.PRE_PreId = PRG_PreId)<>0 then 0 else 1 end
  FROM CDN.PracEtaty A
join CDN.Wyplaty on PRE_PraId = WPL_Praid
join CDN.WypElementy on WPL_WplId = WPE_WplId
join CDN.TypWyplata on WPE_TwpId = TWP_TwpId
join CDN.ListyPlac on LPL_LplId = WPL_LplId
join CDN.Pracidx on PRI_PraId = PRE_PraId
join CDN.PracEtaty B on B.PRE_PraId = A.PRE_PraId
join CDN.ZakazyDoWydzialowView on B.PRE_DzlId = DzlId
 WHERE TWP_RodzajFIS = 2 and TWP_RodzajZrodla <> 8 and
 PRI_TYP = 1 and
 WPL_Tryb <> 1 and WPL_Tryb <> 2 and
 A.PRE_DataOd <= @DataDoch AND A.PRE_DataDo >= @DataDoch
 AND LPL_Miesiac <= Month(@DataDoch) AND
 LPL_Rok = Year(@DataDoch)
 and WPE_ZalFisZwol<>1
 and CONVERT(DATETIME, CAST(DATEPART(year ,getdate()) AS NVARCHAR) +'-'+CAST(DATEPART(month ,getdate()) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,getdate()) AS NVARCHAR)+' 00:00:000', 120) between B.Pre_DataOd and B.Pre_DataDo
 and OpeId = @OperatorID
 and WyplatyView is null
  GROUP BY A.PRE_Nazwisko, A.PRE_Imie1, A.PRE_PreId, pri_nadrzedny, pri_parentid, A.PRE_Kod, PRI_PraId
  ORDER BY A.PRE_Nazwisko, A.PRE_imie1, parentid, nazwisko
  OPEN Tmp_PrzekrPr
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM Tmp_PrzekrPr INTO  @prcid,@Nazw, @Im, @IdPrc, @Doch, @Proc
   IF @@FETCH_STATUS <> 0 BREAK
     BEGIN
 IF @proc = 1
  begin
IF Month(@Data) <> 12
SET @dochod = IsNull((select sum(WPE_wartosc-WPE_SklEmerPrac-WPE_SklRentPrac-WPE_SklChorPrac-WPE_Koszty-WPE_Koszty50)
  FROM CDN.PracEtaty join CDN.Wyplaty on PRE_PraId = WPL_Praid
  join CDN.WypElementy on WPL_WplId = WPE_WplId
  join CDN.TypWyplata on WPE_TwpId = TWP_TwpId
  join CDN.ListyPlac on LPL_LplId = WPL_LplId
  WHERE PRE_PreId = @IdPrc and TWP_RodzajFIS = 2 and TWP_RodzajZrodla <> 8 and
  WPL_Tryb <> 1 and WPL_Tryb <> 2 and
  PRE_DataOd <= @Data AND PRE_DataDo >= @Data AND LPL_Miesiac <= Month(@Data)
  AND
  LPL_Rok = Year(@Data)
  and WPE_ZalFisZwol<>1
  ), 0)
ELSE
SET @dochod = 0
if @BuffPrcId <> @PrcId
  begin
 set @dochodSum =  @dochod
 set @dochSum   =  @Doch
 set @BuffPrcId = @PrcId
  end
   else
  begin
 set @dochodSum = @dochodSum  + @Dochod
 set @dochSum   = @dochSum  + @Doch
  end
IF Year(@DataDoch) = 2006
   BEGIN
   IF (@dochSum <= 37024) OR (@dochodSum > 74048)
    SET @Proc = 19
   IF (@dochSum > 37024) AND (@dochSum <= 74048) AND ((@dochodSum <= 37024) OR (@dochodSum = 0))
    SET @Proc = 30
   IF (@dochSum >  74048) AND ((@dochodSum <= 74048) OR (@dochodSum = 0) )
    SET @Proc = 40
   IF @Proc <> 19 and @Proc <> 1 and SUBSTRING (@Nazw, 1 , 1 ) <>'-'
      INSERT INTO #PrzekrProgu values (@prcid,@Nazw, @Im, @IdPrc, @dochSum, @Proc)
   END
ELSE
IF Year(@DataDoch) = 2007
   BEGIN
   IF (@dochSum <= 43405) OR (@dochodSum > 85528)
    SET @Proc = 19
   IF (@dochSum > 43405) AND (@dochSum <= 85528) AND ((@dochodSum <= 43405) OR (@dochodSum = 0))
    SET @Proc = 30
   IF (@dochSum >  85528) AND ((@dochodSum <= 85528) OR (@dochodSum = 0) )
    SET @Proc = 40
   IF @Proc <> 19 and @Proc <> 1 and SUBSTRING (@Nazw, 1 , 1 ) <>'-'
      INSERT INTO #PrzekrProgu values (@prcid,@Nazw, @Im, @IdPrc, @dochSum, @Proc)
   END
ELSE
IF Year(@DataDoch) = 2008
   BEGIN
   IF (@dochSum <= 44490) OR (@dochodSum > 85528)
    SET @Proc = 19
   IF (@dochSum > 44490) AND (@dochSum<= 85528) AND ((@dochodSum <= 44490) OR (@dochodSum = 0))
    SET @Proc = 30
   IF (@dochSum >  85528) AND ((@dochodSum <= 85528) OR (@dochodSum = 0) )
    SET @Proc = 40
   IF @Proc <> 19 and @Proc <> 1 and SUBSTRING (@Nazw, 1 , 1 ) <>'-'
        INSERT INTO #PrzekrProgu values (@prcid,@Nazw, @Im, @IdPrc, @dochSum, @Proc)
   END
ELSE
IF Year(@DataDoch) >= 2009
   BEGIN
   IF (@dochSum <= 85528) OR (@dochodSum > 85528)
    SET @Proc = 18
   IF (@dochSum >  85528) AND ((@dochodSum <= 85528) OR (@dochodSum = 0) )
    SET @Proc = 32
   IF @Proc <> 18 and @Proc <> 1 and SUBSTRING (@Nazw, 1 , 1 ) <>'-'
        INSERT INTO #PrzekrProgu values (@prcid,@Nazw, @Im, @IdPrc, @dochSum, @Proc)
   END
  end
 else
  begin
   SET @Proc = (select top 1 PRG_Procent from CDN.Progi where PRG_Kwota < @Doch and PRG_PreId = @IdPrc
   order by PRG_Kwota desc)
   SET @dochod = IsNull((select sum(WPE_Wartosc-WPE_SklEmerPrac-WPE_SklRentPrac-WPE_SklChorPrac-WPE_Koszty-WPE_Koszty50)
  FROM CDN.PracEtaty join CDN.Wyplaty on PRE_PraId = WPL_Praid
  join CDN.WypElementy on WPL_WplId = WPE_WplId
  join CDN.TypWyplata on WPE_TwpId = TWP_TwpId
  join CDN.ListyPlac on LPL_LplId = WPL_LplId
  WHERE PRE_PraId = @prcid and TWP_RodzajFIS = 2 and TWP_RodzajZrodla <> 8 and
--  WHERE PRE_PreId = @IdPrc and TWP_RodzajFIS = 2 and TWP_RodzajZrodla <> 8 and
  WPL_Tryb <> 1 and WPL_Tryb <> 2 and
  PRE_DataOd <= @Data AND PRE_DataDo >= @Data AND LPL_Miesiac <= Month(@Data)
  AND
  LPL_Rok = Year(@Data)
  and WPE_ZalFisZwol<>1
  ), 0)
   SET @Proc1 = (select top 1 PRG_Procent from CDN.Progi where ((PRG_Kwota < @Dochod) or (@Dochod=0))
   and PRG_PreId = @IdPrc order by PRG_Kwota desc)
   IF Year(@DataDoch) < 2009
   IF (@Proc <> 19 and @Proc1 <> @Proc) or (Month(@DataDoch) = 1 and @Proc <> 19)
      INSERT INTO #PrzekrProgu values (@prcid,@Nazw, @Im, @IdPrc, @Doch, @Proc)
   IF Year(@DataDoch) >= 2009
   IF (@Proc <> 18 and @Proc1 <> @Proc) or (Month(@DataDoch) = 1 and @Proc <> 18)
      INSERT INTO #PrzekrProgu values (@prcid,@Nazw, @Im, @IdPrc, @Doch, @Proc)
  end
     END
  END
 CLOSE Tmp_PrzekrPr
 DEALLOCATE Tmp_PrzekrPr
 SET NOCOUNT OFF
SELECT * FROM #PrzekrProgu
