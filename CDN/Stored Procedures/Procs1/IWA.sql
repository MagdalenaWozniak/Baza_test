CREATE  PROCEDURE CDN.IWA  @DataOd DATETIME, @DataDo DATETIME
AS
SET NOCOUNT ON
DECLARE @MYOd       INT
DECLARE @MYDo       INT
DECLARE @Month      INT
DECLARE @Year       INT
DECLARE @MYCurrent  INT
DECLARE @UbezWyp INT
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
--Tworze tabele tymczasowa, ktora zwracac bedzie liczbę ubezp. pracowników
CREATE TABLE #IWA (
 Tmp_Rok          INT,
 Tmp_Mc           INT,
 Tmp_UbezWyp    INT,
 )
--Inicjalizuje wartosci domyslne
SET @MYOd = DATEPART (year,@DataOd)*12+DATEPART(month, @DataOd)
SET @MYDo = DATEPART (year,@DataDo)*12+DATEPART(month, @DataDo)
SET @MYCurrent = @MYOd
WHILE @MYCurrent<=@MYDo
BEGIN
 --Zeruje zmienne
SET @UbezWyp = 0
 --Przerabiam miesiac na daty od i do
 SET @Year   = @MYCurrent/12
 SET @Month  = @MYCurrent - (@Year*12)
 IF @Month = 0
 BEGIN
    SET @Year  = @Year -1
    SET @Month = 12
 END
 SET @DataOd = CONVERT (datetime, CAST(@Year as NVARCHAR)+'-'+CAST(@Month as NVARCHAR)+'-01 00:00:00', 120)
 IF @Month<12
   SET @DataDo = CONVERT (datetime, CAST(@Year as NVARCHAR)+'-'+CAST(@Month+1 as NVARCHAR)+'-01 00:00:00', 120)-1
 ELSE
   SET @DataDo = CONVERT (datetime, CAST(@Year as NVARCHAR)+'-12-31 00:00:00', 120)
--
-- Wyliczenie osób z ubezpieczeniem wypadkowym z pominięciem osób z nieobec. za cały okres
select @UbezWyp = count(*) from (
--select @Nieobec = count(Nieobecnosci.ID) from (
select distinct case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID
from cdn.pracetaty A
LEFT OUTER JOIN CDN.PracKod on pra_praid=pre_praid
LEFT OUTER JOIN cdn.wypelementy on WPE_PraId = PRE_PraId
LEFT OUTER JOIN CDN.TypWyplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.WypSkladniki on WPS_WplId = WPL_WplId
LEFT OUTER JOIN CDN.Umowy on UMW_UmwId = WPS_ZrodloId
and UMW_PRAId = PRE_PRAId
WHERE WPL_Tryb<>1 and WPL_Tryb<>2
and LPL_DataOd between @DataOd and @DataDo and LPL_Kategoria<>64
and WPS_DataOd between PRE_DataOd and PRE_DataDo and
((((Left(WPE_TyUb,1)=1 and Len(WPE_TyUb)=5) or  Left(WPE_TyUb,3) = 800 or Left(WPE_TyUb,3)=920 or Left(WPE_TyUb,1)=3
or Left(WPE_TyUb,3)=411
or (Left(WPE_TyUb,1)=5 and isnull(PRE_WlascicielId,0)=0 and PRE_IndywDRA = 0))
and PRE_UBZJestWypad=1 and (isnull(PRE_UBZWypadDo,0)=0 or year(PRE_UBZWypadDo)=1899 or PRE_UBZWypadDo > @DataOd)and (PRE_UBZZusOd<=@DataDo ))
or (
--UMW_DataOd between @DataOd and @DataDo and
UMW_JestWypad=1
and (isnull(UMW_WypadDo,0)=0 or year(UMW_WypadDo)=1899 or UMW_WypadDo > @DataOd) and (UMW_ZusOd<=@DataDo )))
and
(not exists(
select  Pre_Praid
from CDN.PracEtaty B join CDN.PracNieobec on B.Pre_PraId = PNB_PraId join CDN.TypNieobec on PNB_TnbId = Tnb_TnbId
where (B.PRE_PraId=A.PRE_PraId)
--and(@DataOd between PRE_DataOd and PRE_DataDo)
and(B.PRE_DataOd=A.PRE_DataOd and B.PRE_DataDo=A.PRE_DataDo)
and ((@DataOd between Pnb_OkresOd and Pnb_OkresDo) or (Pnb_OkresOd between @DataOd and @DataDo))
and (TNB_PdzId in (111,112, 121, 122,311,319,325,327) or TNB_Standardowy in (312,402,412,413,414))
and PNB_PracaRodzic <> 1
group by Pre_Praid,PRE_ZatrudnionyOd,PRE_ZatrudnionyDo
having sum(datediff(day,Case When PNB_OkresOd<@DataOd Then @DataOd Else PNB_OkresOd End,
Case When PNB_OkresDo>@DataDo Then @DataDo Else PNB_OkresDo End+1))>=
(datediff(day,Case When PRE_ZatrudnionyOd between @DataOd and @DataDo Then PRE_ZatrudnionyOd Else @DataOd End,
Case When PRE_ZatrudnionyDo between @DataOd and @DataDo Then PRE_ZatrudnionyDo Else @DataDo End+1))
) or
exists(
select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID
from cdn.pracetaty C
LEFT OUTER JOIN CDN.PracKod on pra_praid=pre_praid
LEFT OUTER JOIN cdn.wypelementy on WPE_PraId = PRE_PraId
LEFT OUTER JOIN CDN.TypWyplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE (C.PRE_PraId=A.PRE_PraId) and
WPL_Tryb<>1 and WPL_Tryb<>2
and LPL_DataOd between @DataOd and @DataDo and LPL_Kategoria<>64
and  ((Left(WPE_TyUb,1)=1 and Len(WPE_TyUb)=5) or Left(WPE_TyUb,1)=4
or Left(WPE_TyUb,3) = 800 or Left(WPE_TyUb,3)=920 or Left(WPE_TyUb,1)=3 or (Left(WPE_TyUb,1)=5 and isnull(PRE_WlascicielId,0)=0 and PRE_IndywDRA = 0)) and
WPS_DataOd between PRE_DataOd and PRE_DataDo
GROUP BY case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end
HAVING sum(WPE_SklWypadPrac+WPE_SklWypadFirma)>0
)
) GROUP BY case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ,PRE_ZatrudnionyOd,PRE_ZatrudnionyDo
--HAVING sum(WPE_SklWypadPrac+WPE_SklWypadFirma)=0
) Wypadkowe
   insert into #IWA values (@Year, @Month,@UbezWyp)
 SET @MYCurrent = @MYCurrent + 1
END
SET NOCOUNT OFF
SELECT
 * FROM #IWA
