create PROCEDURE CDN.GUS1 @DataOd DATETIME, @DataDo DATETIME, @Typ INT, @PonPowNormy INT
AS
BEGIN
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
DECLARE @F1 FLOAT
DECLARE @F2 FLOAT
DECLARE @F3 FLOAT
DECLARE @P1 DECIMAL(15,2)
DECLARE @P2 DECIMAL(15,2)
DECLARE @P3 DECIMAL(15,2)
DECLARE @P4 DECIMAL(15,2)
DECLARE @P5 DECIMAL(15,2)
DECLARE @P6 DECIMAL(15,2)
DECLARE @P7 DECIMAL(15,2)
--[JK] TFS:196379
DECLARE @P6_1 DECIMAL(15,2)
DECLARE @P6_2 DECIMAL(15,2)
DECLARE @P6_3 DECIMAL(15,2)
DECLARE @P7_1 DECIMAL(15,2)
DECLARE @P7_2 DECIMAL(15,2)
DECLARE @P7_3 DECIMAL(15,2)
DECLARE @P8 DECIMAL(15,2)
DECLARE @P9 DECIMAL(15,2)
DECLARE @P10 DECIMAL(15,2)
DECLARE @P11 DECIMAL(15,2)
DECLARE @P12 DECIMAL(15,2)
DECLARE @P13 DECIMAL(15,2)
DECLARE @P14 DECIMAL(15,2)
DECLARE @P15 DECIMAL(15,2)
DECLARE @P16 DECIMAL(15,2)
DECLARE @P17 DECIMAL(15,2)
DECLARE @P18 DECIMAL(15,2)
DECLARE @P19 DECIMAL(15,2)
DECLARE @P20 DECIMAL(15,2)
DECLARE @P21 DECIMAL(15,2)
DECLARE @P22 DECIMAL(15,2)
DECLARE @P23 DECIMAL(15,2)
DECLARE @P24 DECIMAL(15,2)
--[JK] TFS:170026
DECLARE @P25 DECIMAL(15,2)
DECLARE @P26 DECIMAL(15,2)
DECLARE @P27 DECIMAL(15,2)
DECLARE @P28 DECIMAL(15,2)
DECLARE @Petla  INT
DECLARE @n  INT
DECLARE @TypCzas INT
DECLARE @Dni  INT
DECLARE @Data1  DATETIME
DECLARE @Data2  DATETIME
DECLARE @DataOst DATETIME
DECLARE @DataOst1 DATETIME
DECLARE @Data0 DATETIME
SET @DataOst = @DataDo
SET @DataOst1 = @DataOd - 1
SET @Data0    = CONVERT(DATETIME, '1899-12-30 00:00:00' , 120)
SET @P1 = 0
SET @P2 = 0
SET @P3 = 0
SET @P4 = 0
SET @P5 = 0
SET @P6 = 0
SET @P7 = 0
SET @P8 = 0
SET @P9 = 0
SET @P10 = 0
SET @P11 = 0
SET @P12 = 0
SET @P13 = 0
SET @P14 = 0
SET @P15 = 0
SET @P16 = 0
SET @P17 = 0
SET @P18 = 0
SET @P19 = 0
SET @P20 = 0
SET @P21 = 0
SET @P22 = 0
SET @P23 = 0
SET @P24 = 0
--[JK] TFS:170026
SET @P25 = 0
SET @P26 = 0
SET @P27 = 0
SET @P28 = 0
--[JK] TFS:196379
SET @P6_1 = 0
SET @P6_2 = 0
SET @P6_3 = 0
SET @P7_1 = 0
SET @P7_2 = 0
SET @P7_3 = 0
--
-- Zatrudnienie i wynagrodzenie
If @Typ = 1
BEGIN
DECLARE @NazwaSerwera NVARCHAR (1000)
DECLARE @Serwer  NVARCHAR (1000)
DECLARE @BazaK  NVARCHAR (1000)
DECLARE @MinKonf DECIMAL (15,2)
DECLARE @MinKonf1 DECIMAL (15,2)
--[JK] TFS:155895
DECLARE @Wynik  NVARCHAR(4000)
SET @Serwer = (select SYS_Wartosc from CDN.SystemCDN where SYS_ID = 1001)
SET @BazaK = (select SYS_Wartosc from CDN.SystemCDN where SYS_ID = 1002)
SET @NazwaSerwera = 'EXECUTE [' + @Serwer + '].' + @BazaK + '.[CDN].[WartKonf] @DataDo , 0 , @Wynik OutPut'
execute sp_executesql @NazwaSerwera, N'@DataDo  DATETIME, @param INT, @Wynik NVARCHAR(4000) Output', @DataDo , 0, @Wynik output
SET @MinKonf =   convert( DECIMAL(15,2), REPLACE (@wynik , ',' , '.' ))
set @MinKonf1 = @MinKonf * 0.8
DECLARE @ZatrOG  FLOAT
DECLARE @SZatrOG FLOAT
DECLARE @ZatrObcy FLOAT
DECLARE @SZatrObcy FLOAT
DECLARE @ZatrUcz FLOAT
DECLARE @SZatrUcz FLOAT
DECLARE @LiczWynObcy DECIMAL(15,2)
DECLARE @WynUcz  DECIMAL(15,2)
DECLARE @LiczWynUcz DECIMAL(15,2)
SET @Petla = 0
SET @n = 12
SET @Dni = 1
SET @Data1 = @DataOd
SET @Data2 = DATEADD(m, 1, @Data1)-1
SET @ZatrOg = 0
SET @SZatrOg = 0
SET @ZatrObcy = 0
SET @SZatrObcy = 0
SET @ZatrUcz = 0
SET @SZatrUcz = 0
SET @LiczWynObcy = 0
SET @LiczWynUcz = 0
--[JK] TFS:196379
DECLARE @Norma  INT
IF YEAR(@DataDo) < 2017
BEGIN
 SET @Norma = 168
END
IF YEAR(@DataDo) >= 2017
BEGIN
 SET @Norma = 152
END
--
-- POCZATEK PĘTLI x 12
WHILE @Petla < @n
BEGIN
 SET @Petla = @Petla + 1
 SET @Dni = DATEDIFF(d, @data1, @Data2)+1
--
-- Wyliczenie zatrudnieni ogolem
--[JK] TFS:195766 - dodanie warunku na pobieranie PRE_ETAEtatL i PRE_ETAEtatM (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end) i (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end)
set  @ZatrOg = (select IsNull(sum(Liczba)/@Dni,0) from (
select (datediff(day,DataOd,DataDo)+1 - isnull(sum(case when TNB_PdzId in (111,112,121,122,311,312,319,325,327)
then datediff(day,
Case When PNB_OkresOd<DataOd Then DataOd Else PNB_OkresOd End,
Case When PNB_OkresDo>DataDo Then DataDo Else PNB_OkresDo End)+1 else 0 end),0)
--[JK] wykluczenie nieobecności rozliczonej z kodem 313 i 314
-(select isnull(SUM(WPS_OkresDni),0) as okres_dni from cdn.WypSkladniki
LEFT OUTER JOIN CDN.TypWYplata on WPS_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPS_WplId = WPL_WplId where WPL_Tryb<>1 and WPL_Tryb<>2 and TWP_PdzId in (313,314)
and @Data1 <= WPS_DataOd and WPS_DataDo <=@Data2 and WPL_PraId = PRE_PraId)
)
* 0.1 * (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end)/(Case When (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) = 0 then 1 Else (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) End)*10
 Liczba
from
(
select PRE_PraId,PRE_PRMPracaRodzic, PRE_PRMEtatL,PRE_ETAEtatL,PRE_ETAEtatM,PRE_PRMEtatM,
Case When @data1>PRE_DataOd and @data1>PRE_ZatrudnionyOd Then @data1
 When PRE_DataOd>PRE_ZatrudnionyOd Then PRE_DataOd
        Else PRE_ZatrudnionyOd
        End DataOd,
Case When @data2<PRE_DataDo and @data2<PRE_ZatrudnionyDo Then @data2
 When PRE_DataDo<PRE_ZatrudnionyDo Then PRE_DataDo
        Else PRE_ZatrudnionyDo
        End DataDo
from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120)
--[JK] TFS:169880 or (PRE_UbzTyuID = 800)) and
or (PRE_UbzTyuID = 800)) and PRE_Oddelegowany = 0 and
@data2>=PRE_DataOd and PRE_DataDo>=@data1 and
@data2>=PRE_ZatrudnionyOd and PRE_ZatrudnionyDo>=@data1 and
PRE_DataOd<=PRE_ZatrudnionyDo and PRE_ZatrudnionyOd<=PRE_DataDo
) Etaty
left outer join CDN.PracNieobec on PNB_PraId=PRE_PraId
  and PNB_OkresOd<=DataDo and DataOd<=PNB_OkresDo and PNB_Tryb<>1
  --[JK] TFS:195766
  and PNB_PracaRodzic <> 1
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
group by PRE_PraId, DataOd, DataDo, PRE_PRMPracaRodzic, PRE_PRMEtatL,PRE_ETAEtatL,PRE_ETAEtatM,PRE_PRMEtatM
) Dni)
SET @SZatrOg = @SZatrOg + @ZatrOg
--
-- Wyliczenie zatrudnieni oddelegowani
set  @ZatrObcy = (select IsNull(sum(Liczba)/@Dni,0) from (
select (datediff(day,DataOd,DataDo)+1 - isnull(sum(case when TNB_PdzId in (111,112)
then datediff(day,
Case When PNB_OkresOd<DataOd Then DataOd Else PNB_OkresOd End,
Case When PNB_OkresDo>DataDo Then DataDo Else PNB_OkresDo End)+1 else 0 end),0))
* 0.1 * PRE_EtaEtatL/(Case When PRE_EtaEtatM = 0 then 1 Else PRE_EtaEtatM End)*10
 Liczba
from
(
select PRE_PraId,PRE_EtaEtatL, PRE_EtaEtatM,
Case When @data1>PRE_DataOd and @data1>PRE_ZatrudnionyOd Then @data1
 When PRE_DataOd>PRE_ZatrudnionyOd Then PRE_DataOd
        Else PRE_ZatrudnionyOd
        End DataOd,
Case When @data2<PRE_DataDo and @data2<PRE_ZatrudnionyDo Then @data2
 When PRE_DataDo<PRE_ZatrudnionyDo Then PRE_DataDo
        Else PRE_ZatrudnionyDo
        End DataDo
from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120)
--[JK] TFS:169880 or (PRE_UbzTyuID = 800)) and
or (PRE_UbzTyuID = 800)) and PRE_Oddelegowany = 1 and
@data2>=PRE_DataOd and PRE_DataDo>=@data1 and
@data2>=PRE_ZatrudnionyOd and PRE_ZatrudnionyDo>=@data1 and
PRE_DataOd<=PRE_ZatrudnionyDo and PRE_ZatrudnionyOd<=PRE_DataDo
) Etaty
left outer join CDN.PracNieobec on PNB_PraId=PRE_PraId
  and PNB_OkresOd<=DataDo and DataOd<=PNB_OkresDo and PNB_Tryb<>1
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
group by PRE_PraId, DataOd, DataDo, PRE_EtaEtatL, PRE_EtaEtatM
) Dni)
SET @SZatrObcy = @SZatrObcy + @ZatrObcy
--
-- Wyliczenie zatrudnieni uczniowie
set  @ZatrUcz = (select IsNull(sum(Liczba)/@Dni,0) from (
select (datediff(day,DataOd,DataDo)+1 - isnull(sum(case when TNB_PdzId in (111,112)
then datediff(day,
Case When PNB_OkresOd<DataOd Then DataOd Else PNB_OkresOd End,
Case When PNB_OkresDo>DataDo Then DataDo Else PNB_OkresDo End)+1 else 0 end),0))
* 0.1 * PRE_EtaEtatL/(Case When PRE_EtaEtatM = 0 then 1 Else PRE_EtaEtatM End)*10
 Liczba
from
(
select PRE_PraId,PRE_EtaEtatL, PRE_EtaEtatM,
Case When @data1>PRE_DataOd and @data1>PRE_ZatrudnionyOd Then @data1
 When PRE_DataOd>PRE_ZatrudnionyOd Then PRE_DataOd
        Else PRE_ZatrudnionyOd
        End DataOd,
Case When @data2<PRE_DataDo and @data2<PRE_ZatrudnionyDo Then @data2
 When PRE_DataDo<PRE_ZatrudnionyDo Then PRE_DataDo
        Else PRE_ZatrudnionyDo
        End DataDo
from cdn.pracetaty
where  PRE_UbzTyuID = 120 and
@data2>=PRE_DataOd and PRE_DataDo>=@data1 and
@data2>=PRE_ZatrudnionyOd and PRE_ZatrudnionyDo>=@data1 and
PRE_DataOd<=PRE_ZatrudnionyDo and PRE_ZatrudnionyOd<=PRE_DataDo
) Etaty
left outer join CDN.PracNieobec on PNB_PraId=PRE_PraId
  and PNB_OkresOd<=DataDo and DataOd<=PNB_OkresDo and PNB_Tryb<>1
left outer join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
group by PRE_PraId, DataOd, DataDo, PRE_EtaEtatL, PRE_EtaEtatM
) Dni)
SET @SZatrUcz = @SZatrUcz + @ZatrUcz
--  wynagrodzenia uczniow
SET @LiczWynUcz = @LiczWynUcz + (select IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWyplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.Pracetaty on WPE_PraId = PRE_PraId
WHERE TWP_Wliczanydogus<>0 and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and Month(@data2) = Month(WPL_DataDo) and Year(@data2) = Year(WPL_DataDo)
and (LEFT(WPE_TyUb, 3)  = 120 or (LEFT(WPE_TyUb, 3)  = 300 and PRE_UbzTyuID=120 ))and
@data2 between PRE_DataOd and PRE_DataDo and
(@data2 between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo OR
Month(PRE_ZatrudnionyDo) = Month(@data2) and Year(PRE_ZatrudnionyDo) = Year(@data2)) and
PRE_DataOd<=PRE_ZatrudnionyDo and PRE_ZatrudnionyOd<=PRE_DataDo)
SET @Data1 = @Data2+1
SET @Data2 = DATEADD(m, 1, @Data1)-1
END
--
-- KONIEC PĘTLI x 12
--@P2 - wynagrodzenie oddelegowanych @P3 - wyn. uczniów
Select @P2 = IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.Pracetaty  on WPE_PraId = PRE_PraId
WHERE WPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus<>0 and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and ((Left(WPE_TyUb,1)=1 and Len(WPE_TyUb)=5 and Left(WPE_TyUb,3)<>120)
OR WPE_TyUb = 80000 or
(LEFT(WPE_TyUb, 3)  = 300 and (Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120)
or (PRE_UbzTyuID = 800))
) and PRE_Oddelegowany = 1
and Year(@DataDo) = Year(WPL_DataDo)
and (TWP_Standardowy < 15 or TWP_Standardowy > 18) and TWP_Standardowy <> 20 and TWP_Standardowy <> 21 and TWP_Standardowy <> 22 and TWP_Standardowy <> 23
SET @P3 = @LiczWynUcz
--
/* 196379
-- Minimalna
select @P6 = count(*) from (
select PRE_PraId
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWyplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.Pracetaty A on WPE_PraId = PRE_PraId
WHERE TWP_Wliczanydogus<>0 and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and 12 = Month(LPL_DataDok) and Year(LPL_DataDok)= Year(@DataDo)
and  ((Left(WPE_TyUb,1)=1 and Len(WPE_TyUb)=5 and Left(WPE_TyUb,3)<>120)
or (PRE_UbzTyuID = 800)) and
WPL_DataDo between PRE_DataOd and PRE_DataDo
and exists(select * from CDN.PracEtaty B where B.PRE_PraId=A.PRE_PraId and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo)
GROUP BY PRE_PraId
HAVING sum(WPE_Wartosc* PRE_EtaEtatM/(Case When PRE_EtaEtatL = 0 then 1 Else PRE_EtaEtatL End)) <= @MinKonf
) Pracownicy
--
--Minimalna i pierwszy rok pracy
select @P7 = count(*) from (
select PRE_PraId
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWyplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.Pracetaty A on WPE_PraId = PRE_PraId
WHERE TWP_Wliczanydogus<>0 and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and 12 = Month(LPL_DataDok) and Year(LPL_DataDok)= Year(@DataDo)
and  ((Left(WPE_TyUb,1)=1 and Len(WPE_TyUb)=5 and Left(WPE_TyUb,3)<>120)
or (PRE_UbzTyuID = 800))
and PRE_HDKGUSPierwszaPraca = 1 and
WPL_DataDo between PRE_DataOd and PRE_DataDo
and exists(select * from CDN.PracEtaty B where B.PRE_PraId=A.PRE_PraId and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo)
GROUP BY PRE_PraId
HAVING sum(WPE_Wartosc* PRE_EtaEtatM/(Case When PRE_EtaEtatL = 0 then 1 Else PRE_EtaEtatL End)) <= @MinKonf
) Pracownicy
*/
--[JK] 196379
-- Minimalna
select  @P6_1 = count(*) from (
select PRE_PraId
from CDN.Pracetaty
WHERE
@DataDo between PRE_DataOd and PRE_DataDo
and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_ETAMinimalna = 1 and PRE_ETARodzajZatrudnienia = 0
--[JK] 196677
and PRE_Oddelegowany = 0
GROUP BY PRE_PraId
) Pracownicy
select  @P6_2 = count(*) from (
select PRE_PraId
from CDN.Pracetaty
WHERE
@DataDo between PRE_DataOd and PRE_DataDo
and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_ETAMinimalna = 0 and PRE_ETAWymiar = 1 and PRE_ETARodzajZatrudnienia = 0
and (PRE_ETAStawka * PRE_EtaEtatM/(Case When PRE_EtaEtatL = 0 then 1 Else PRE_EtaEtatL End)) <= @MinKonf
--[JK] 196677
and PRE_Oddelegowany = 0
GROUP BY PRE_PraId
) Pracownicy
select  @P6_3 = count(*) from (
select PRE_PraId
from CDN.Pracetaty
WHERE
@DataDo between PRE_DataOd and PRE_DataDo
and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_ETAMinimalna = 0 and PRE_ETAWymiar = 2 and PRE_ETARodzajZatrudnienia = 0
and (PRE_ETAStawka * @Norma) <= @MinKonf
--[JK] 196677
and PRE_Oddelegowany = 0
GROUP BY PRE_PraId
) Pracownicy
SET @P6 =  @P6_1 +  @P6_2 +  @P6_3
--Minimalna i pierwszy rok pracy
select  @P7_1 = count(*) from (
select PRE_PraId
from CDN.Pracetaty
WHERE
@DataDo between PRE_DataOd and PRE_DataDo
and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_ETAMinimalna = 1 and PRE_HDKGUSPierwszaPraca = 1 and PRE_ETARodzajZatrudnienia = 0
--[JK] 196677
and PRE_Oddelegowany = 0
GROUP BY PRE_PraId
) Pracownicy
select  @P7_2 = count(*) from (
select PRE_PraId
from CDN.Pracetaty
WHERE
@DataDo between PRE_DataOd and PRE_DataDo
and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_ETAMinimalna = 0 and PRE_ETAWymiar = 1 and PRE_HDKGUSPierwszaPraca = 1 and PRE_ETARodzajZatrudnienia = 0
and (PRE_ETAStawka * PRE_EtaEtatM/(Case When PRE_EtaEtatL = 0 then 1 Else PRE_EtaEtatL End)) <= @MinKonf
--[JK] 196677
and PRE_Oddelegowany = 0
GROUP BY PRE_PraId
) Pracownicy
select  @P7_3 = count(*) from (
select PRE_PraId
from CDN.Pracetaty
WHERE
@DataDo between PRE_DataOd and PRE_DataDo
and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_ETAMinimalna = 0 and PRE_ETAWymiar = 2 and PRE_HDKGUSPierwszaPraca = 1 and PRE_ETARodzajZatrudnienia = 0
and (PRE_ETAStawka * @Norma) <= @MinKonf
--[JK] 196677
and PRE_Oddelegowany = 0
GROUP BY PRE_PraId
) Pracownicy
SET @P7 =  @P7_1 +  @P7_2 +  @P7_3
--Wynagrodzenia ogolem
SELECT @P1 = IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.Pracetaty  on WPE_PraId = PRE_PraId
WHERE WPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus<>0 and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and ((Left(WPE_TyUb,1)=1 and Len(WPE_TyUb)=5 and Left(WPE_TyUb,3)<>120)
OR WPE_TyUb = 80000 or
(LEFT(WPE_TyUb, 3)  = 300 and (Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120)
or (PRE_UbzTyuID = 800))
) and PRE_Oddelegowany = 0
and Year(@DataDo) = Year(WPL_DataDo)
and (TWP_Standardowy < 15 or TWP_Standardowy > 18) and TWP_Standardowy <> 20 and TWP_Standardowy <> 21 and TWP_Standardowy <> 22 and TWP_Standardowy <> 23
-- Skladki, podatki
SELECT @P4 = IsNull(sum(WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac),0),
@P5 = IsNull(sum(WPE_NalFIS),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.Pracetaty  on WPE_PraId = PRE_PraId
WHERE WPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus<>0 and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and ((Left(WPE_TyUb,1)=1 and Len(WPE_TyUb)=5 and Left(WPE_TyUb,3)<>120)
OR WPE_TyUb = 80000 or
(LEFT(WPE_TyUb, 3)  = 300 and (Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120)
or (PRE_UbzTyuID = 800))
) and PRE_Oddelegowany = 0
and Year(@DataDo) = Year(WPL_DataDo)
END
SET @F1 = @SZatrOg/@n
SET @F2 = @SZatrObcy/@n
SET @F3 = @SZatrUcz/@n
--
--
--Skladniki wynagrodzen
If @Typ = 2
BEGIN
DECLARE @DataDo2 DATETIME
--
SET @DataDo2 = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd)+1 AS NVARCHAR) +'-'+CAST(1 AS NVARCHAR)+'-'+ CAST(18 AS NVARCHAR)+' 00:00:000', 120)
--
-- Wynagrodzenia osobowe
SET @P1 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.Pracetaty  on WPE_PraId = PRE_PraId
WHERE WPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus in (1,2,8,9,10) and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (LEFT(WPE_TyUb, 3)  = 110 or LEFT(WPE_TyUb, 3)  = 200 or
(LEFT(WPE_TyUb, 3)  = 300 and PRE_UbzTyuID<>120)
or  (LEFT(WPE_TyUb, 3) = 800))
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo)
and (TWP_Standardowy < 15 or TWP_Standardowy > 18) and TWP_Standardowy <> 20 and TWP_Standardowy <> 21 and TWP_Standardowy <> 22 and TWP_Standardowy <> 23)
--
-- Wynagrodzenia nadliczbowe
SET @P2 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus= 2 and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (LEFT(WPE_TyUb, 3)  = 110 or LEFT(WPE_TyUb, 3)  = 200 or LEFT(WPE_TyUb, 3)  = 300 or  (LEFT(WPE_TyUb, 3) = 800))
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo))
--
-- JK TFS:170746
IF @PonPowNormy = 1
 BEGIN
  SET @P2 = @P2 + (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus= 1 and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (LEFT(WPE_TyUb, 3)  = 110 or LEFT(WPE_TyUb, 3)  = 200 or LEFT(WPE_TyUb, 3)  = 300 or  (LEFT(WPE_TyUb, 3) = 800))
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo)
and Twp_Standardowy in (11,12))
 END
-- Wynagrodzenia nakladcow
SET @P3 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus in (1,8,9,10) and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and LEFT(WPE_TyUb, 3)  = 200
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo))
--
-- Wynagrodzenia umowy
SET @P4 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus = 3 and
WPL_Tryb<>1 and WPL_Tryb<>2 and
LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo))
--
-- Wynagrodzenia honoraria
SET @P5 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus = 4
and WPL_Tryb<>1 and WPL_Tryb<>2
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo))
--
-- Wynagrodzenia agencyjno-prowizyjne
SET @P6 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus = 5 and
WPL_Tryb<>1 and WPL_Tryb<>2 and
LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo))
-- Wypłaty z tytułu udziału w zysku lub nadwyżce bilansowej w spółdzielniach
SET @P7 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus = 6
and WPL_Tryb<>1 and WPL_Tryb<>2
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo))
--
-- Dodatkowe wynagrodzenie roczne dla pracowników jednostek sfery budżetowej
SET @P8 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus = 7 and
WPL_Tryb<>1 and WPL_Tryb<>2 and
LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo))
--[JK] TFS:170026
-- Wynagrodzenia osobowe dla pracowników obych
SET @P25 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
LEFT OUTER JOIN CDN.Pracetaty  on WPE_PraId = PRE_PraId
WHERE WPL_DataDo between PRE_DataOd and PRE_DataDo and
TWP_Wliczanydogus in (1,2,8,9,10) and LPL_Kategoria in (1, 4, 128)
and WPL_Tryb<>1 and WPL_Tryb<>2
and (LEFT(WPE_TyUb, 3)  = 110 or LEFT(WPE_TyUb, 3)  = 200 or
(LEFT(WPE_TyUb, 3)  = 300 and PRE_UbzTyuID<>120)
or  (LEFT(WPE_TyUb, 3) = 800))
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo)
and (TWP_Standardowy < 15 or TWP_Standardowy > 18) and TWP_Standardowy <> 20 and TWP_Standardowy <> 21 and TWP_Standardowy <> 22 and TWP_Standardowy <> 23
and LPL_Oddelegowani=1)
--
-- Wypłaty z tytułu udziału w zysku lub nadwyżce bilansowej w spółdzielniach dla pracowników obych
SET @P26 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus = 6
and WPL_Tryb<>1 and WPL_Tryb<>2
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo)
and LPL_Oddelegowani=1)
--
-- Dodatkowe wynagrodzenie roczne dla pracowników jednostek sfery budżetowej
SET @P27 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus = 7 and
WPL_Tryb<>1 and WPL_Tryb<>2 and
LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo)
and LPL_Oddelegowani=1)
-- Wynagrodzenia honoraria bez pracowników obcych
SET @P28 = (SELECT IsNull(sum(WPE_Wartosc),0)
from cdn.wypelementy
LEFT OUTER JOIN CDN.TypWYplata on WPE_TwpId = TWP_TWPId
LEFT OUTER JOIN CDN.Wyplaty on WPE_WplId = WPL_WplId
LEFT OUTER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
WHERE TWP_Wliczanydogus = 4
and WPL_Tryb<>1 and WPL_Tryb<>2
and LPL_DataDok <= @DataDo2 and Year(LPL_DataDo) = Year(@DataDo)
and LPL_Oddelegowani=0 and LPL_Kategoria<>2)
--
END
-- Czas pracy
If @Typ = 3
BEGIN
 DECLARE @CzasPracyOg  INT
 DECLARE @CzasPracyNadl  INT
 DECLARE @CzasPracyNie  INT
 DECLARE @CzasPracyOpl  INT
 DECLARE @CzasUrlWyp  INT
 DECLARE @CzasChoroby  INT
 DECLARE @CzasPracyUrl  INT
 DECLARE @PrcId INT
 SET @CzasPracyOg =  0
 SET @CzasPracyNadl =  0
 SET @CzasPracyNie =  0
 SET @CzasPracyOpl = 0
 SET @CzasUrlWyp = 0
 SET @CzasChoroby = 0
 SET @CzasPracyUrl =  0
--
  CREATE TABLE #TMP2 (
  Typ smallint,
  Data datetime,
  TypDnia int,
  Nieobec int,
  TypNieob int,
  Lp INT,
  GodzOd datetime,
  GodzDo datetime,
  Strefa int,
  Dzial int,
  Projekt int ,
  Norma int ,
  Praca int ,
  Zrodlo int
  )
--
   CREATE TABLE #TMP1 (
  Typ smallint,
  Data datetime,
  TypDnia int,
  Nieobec int,
  TypNieob int,
  Lp INT,
  GodzOd datetime,
  GodzDo datetime,
  Strefa int,
  Dzial int,
  Projekt int ,
  Norma int ,
  Praca int ,
  Zrodlo int
  )
--
  DECLARE Tmp_Czas CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT distinct PRE_PraId
  FROM CDN.PracEtaty
  WHERE (@DataOd between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   or @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   or  PRE_ZatrudnionyOd between @DataOd and @DataDo)
  OPEN Tmp_Czas
  WHILE 1=1
BEGIN
 FETCH NEXT FROM Tmp_Czas INTO @PrcId
 IF @@FETCH_STATUS <> 0 BREAK
--
INSERT INTO #TMP1
select  Typ ,
 Data ,
 TypDnia ,
 Nieobec ,
 TypNieob ,
 Lp ,
 GodzOd ,
 GodzDo ,
 Strefa ,
 Dzial ,
 Projekt  ,
 Norma  ,
 Praca  ,
 Zrodlo
from  CDN.PracCzasPracyFN (3, @PrcId, @DataOd, @DataDo)
--
INSERT INTO #TMP2
select  Typ ,
 Data ,
 TypDnia ,
 Nieobec ,
 TypNieob ,
 Lp ,
 GodzOd ,
 GodzDo ,
 Strefa ,
 Dzial ,
 Projekt  ,
 Norma  ,
 Praca  ,
 Zrodlo
from  CDN.PracCzasPracyFN (2, @PrcId, @DataOd, @DataDo)
--
   select @CzasPracyUrl = @CzasPracyUrl + isnull((case when (isnull(PNB_Calodzienna, 0)=0) then (sum(norma) - (DATEDIFF(minute, CONVERT(datetime,'1899.12.30',102),PNB_Godz))) else 0 end), 0)
   from (
   select Data, IsNull(sum(praca), 0) as praca, IsNull(sum(norma), 0) as norma, nieobec, TypDnia, PNB_PnbId, PNB_Calodzienna, PNB_Godz, ROW_NUMBER() OVER(PARTITION BY Data ORDER BY PNB_PnbId) AS "Row Number"
   from  #TMP1
   inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
   and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
   and Typ <> 5
   LEFT OUTER JOIN CDN.PracNieobec on Pre_PraId = PNB_praid and PNB_Tryb<>1 and Data between PNB_OkresOd and PNB_OkresDo
   group by Data, nieobec, TypDnia, PNB_PnbId, PNB_Calodzienna, PNB_Godz
   union all
   select Data, IsNull(sum(praca), 0) as praca, IsNull(sum(norma), 0) as norma, nieobec, TypDnia, PNB_PnbId, PNB_Calodzienna, PNB_Godz, ROW_NUMBER() OVER(PARTITION BY Data ORDER BY PNB_PnbId) AS "Row Number"
   from  #TMP2
   inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
   and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
   and Typ <> 5
   LEFT OUTER JOIN CDN.PracNieobec on Pre_PraId = PNB_praid and PNB_Tryb<>1 and Data between PNB_OkresOd and PNB_OkresDo
   group by Data, nieobec, TypDnia, PNB_PnbId, PNB_Calodzienna, PNB_Godz
   ) Praca
   where PNB_Calodzienna = 0
   group by PNB_Calodzienna, PNB_Godz
--
   select @CzasPracyOg = @CzasPracyOg + isnull(sum(praca), 0),
   @CzasPracyOg = @CzasPracyOg,
   @CzasPracyNie = @CzasPracyNie + isnull(sum(case when (isnull(PNB_PnbId, 0)>0 and TypDnia=1 and TNB_PomnCzasPracy=1 and TNB_PdzId not in (111, 112, 121, 122, 321, 322, 311, 325, 319, 327, 312, 331)) then norma - praca else 0 end), 0),
   @CzasPracyNie = @CzasPracyNie
   from (
   select Data, IsNull(sum(praca), 0) as praca, IsNull(sum(norma), 0) as norma, nieobec, TypDnia, PNB_PnbId, PNB_Calodzienna, PNB_Godz, TNB_PomnCzasPracy, TNB_PdzId, ROW_NUMBER() OVER(PARTITION BY Data ORDER BY PNB_PnbId) AS "Row Number"
   from  #TMP1
   inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
   and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
   and (Typ <> 5 or TypNieob in (select TNB_TnbId from CDN.TypNieobec where TNB_PomnCzasPracy = 0))
   LEFT OUTER JOIN CDN.PracNieobec on Pre_PraId = PNB_praid and PNB_Tryb<>1 and Data between PNB_OkresOd and PNB_OkresDo
   LEFT OUTER JOIN CDN.TypNieobec on PNB_TnbId = TNB_TnbId
   group by Data, nieobec, TypDnia, PNB_PnbId, PNB_Calodzienna, PNB_Godz, TNB_PomnCzasPracy, TNB_PdzId
   union all
   select Data, IsNull(sum(praca), 0) as praca, IsNull(sum(norma), 0) as norma, nieobec, TypDnia, PNB_PnbId, PNB_Calodzienna, PNB_Godz, TNB_PomnCzasPracy, TNB_PdzId, ROW_NUMBER() OVER(PARTITION BY Data ORDER BY PNB_PnbId) AS "Row Number"
   from  #TMP2
   inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
   and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
   and (Typ <> 5 or TypNieob in (select TNB_TnbId from CDN.TypNieobec where TNB_PomnCzasPracy = 0))
   LEFT OUTER JOIN CDN.PracNieobec on Pre_PraId = PNB_praid and PNB_Tryb<>1 and Data between PNB_OkresOd and PNB_OkresDo
   LEFT OUTER JOIN CDN.TypNieobec on PNB_TnbId = TNB_TnbId
   group by Data, nieobec, TypDnia, PNB_PnbId, PNB_Calodzienna, PNB_Godz, TNB_PomnCzasPracy, TNB_PdzId
   ) Praca
   where "Row Number" = 1
   group by PNB_PnbId
   order by PNB_PnbId
--
   select @CzasPracyNie = @CzasPracyNie + isnull(sum(case when (TNB_Typ=1 or TNB_Typ=8) and TNB_PomnCzasPracy=1 and TNB_TypRozliczenia=2 and TWP_PdzId=331 and TypDnia=1 then norma else 0 end),0)
   from  #TMP1
   INNER JOIN CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
   and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
   LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
   INNER JOIN CDN.WypSkladniki on WPS_PraId=@PrcId and Data between WPS_DataOd and WPS_DataDo
   INNER JOIN CDN.Wyplaty on WPS_WplId = WPL_WplId and WPL_Tryb<>1 and WPL_Tryb<>2
   INNER JOIN CDN.TypWyplata on WPS_TwpId = TWP_TwpId
--
   select @CzasPracyNadl = @CzasPracyNadl + isnull((case when (SUM(Praca) > SUM(Norma)) then (SUM(Praca) - SUM(Norma)) else 0 end), 0)
   from (
   select Data, IsNull(sum(praca), 0) as praca, IsNull(sum(norma), 0) as norma, nieobec, TypDnia, PNB_PnbId
   from  #TMP1
   inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
   and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
   and Typ <> 5
   LEFT OUTER JOIN CDN.PracNieobec on Pre_PraId = PNB_praid and PNB_Tryb<>1 and Data between PNB_OkresOd and PNB_OkresDo
   group by Data, nieobec, TypDnia, PNB_PnbId
   union all
   select Data, IsNull(sum(praca), 0) as praca, IsNull(sum(norma), 0) as norma, nieobec, TypDnia, PNB_PnbId
   from  #TMP2
   inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
   and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
   and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
   and Typ <> 5
   LEFT OUTER JOIN CDN.PracNieobec on Pre_PraId = PNB_praid and PNB_Tryb<>1 and Data between PNB_OkresOd and PNB_OkresDo
   group by Data, nieobec, TypDnia, PNB_PnbId
   ) Praca
   where PNB_PnbId is null
--
   select @CzasPracyOg = @CzasPracyOg + (select  IsNull(sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_czas, 120))),0)
   FROM cdn.praczestaw INNER join CDN.PracEtaty on  Pre_PraId = PZE_PraId and @DataDo between PRE_DataOd and PRE_DataDo
   WHERE @DataOd<= pze_okresod AND @DataDo>=pze_okresdo and @PrcId = PRE_PraId
   and PZE_Tryb<>1 and PRE_ZestCzasuPracy = 2 AND (PRE_DataOd between  @DataOd and @DataDo or PRE_DataDo  between  @DataOd and @DataDo
   or @DataOd between PRE_DataOd and PRE_DataDo))
--
   select  @CzasPracyNadl = @CzasPracyNadl + (select IsNull(sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, PZE_Nadgodziny50, 120))),0)
   + IsNull(sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, PZE_Nadgodziny100, 120))),0)
   FROM cdn.praczestaw INNER join CDN.PracEtaty on  Pre_PraId = PZE_PraId and @DataDo between PRE_DataOd and PRE_DataDo
   WHERE @DataOd<= pze_okresod AND @DataDo>=pze_okresdo and @PrcId = PRE_PraId
   and PZE_Tryb<>1 and PRE_ZestCzasuPracy = 2 AND (PRE_DataOd between  @DataOd and @DataDo or PRE_DataDo  between  @DataOd and @DataDo
   or @DataOd between PRE_DataOd and PRE_DataDo))
--
 select @CzasPracyOpl = @CzasPracyOpl + isnull(sum(case when TNB_Typ = 4 and TNB_PomnCzasPracy=1 and TypDnia=1 then norma else 0 end),0)
 from  #TMP1
 inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
 and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
 and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
 LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
--
 select @CzasPracyOpl = @CzasPracyOpl + isnull(sum(case when (TNB_Typ=1 or TNB_Typ=8) and TNB_PomnCzasPracy=1 and TNB_TypRozliczenia=0 and TNB_Pomniejszenie=0 and TypDnia=1 then norma else 0 end),0)
 from  #TMP1
 inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
 and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
 and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
 LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
--
 select @CzasPracyOpl = @CzasPracyOpl + isnull(sum(case when (TNB_Typ=1 or TNB_Typ=8) and TNB_PomnCzasPracy=1 and TNB_TypRozliczenia=1 and (TWP_PdzId=331 or TWP_PdzId=999) and TypDnia=1 then norma else 0 end),0)
 from  #TMP1
 INNER JOIN CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
 and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
 and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
 LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
 INNER JOIN CDN.TypWyplata on TNB_TwpId = TWP_TwpId
--
 select @CzasPracyOpl = @CzasPracyOpl + isnull(sum(case when (TNB_Typ=1 or TNB_Typ=8) and TNB_PomnCzasPracy=1 and TNB_TypRozliczenia=2 and TWP_PdzId=331 and TypDnia=1 then norma else 0 end),0)
 from  #TMP1
 INNER JOIN CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
 and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
 and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
 LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
 INNER JOIN CDN.WypSkladniki on WPS_PraId=@PrcId and Data between WPS_DataOd and WPS_DataDo
 INNER JOIN CDN.Wyplaty on WPS_WplId = WPL_WplId and WPL_Tryb<>1 and WPL_Tryb<>2
 INNER JOIN CDN.TypWyplata on WPS_TwpId = TWP_TwpId
--
 select @CzasUrlWyp = @CzasUrlWyp + isnull(sum(case when TNB_Typ = 4 and TNB_LnbId=1 and TypDnia=1 then norma else 0 end),0)
 from  #TMP1
 inner join CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
 and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
 and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
 LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
--
 select @CzasChoroby = @CzasChoroby + isnull(sum(case when (TNB_Typ=1 or TNB_Typ=8) and TNB_TypRozliczenia=1 and TWP_PdzId=331 and TypDnia=1 then norma else 0 end),0)
 from  #TMP1
 INNER JOIN CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
 and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
 and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
 LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
 INNER JOIN CDN.TypWyplata on TNB_TwpId = TWP_TwpId
--
 select @CzasChoroby = @CzasChoroby + isnull(sum(case when (TNB_Typ=1 or TNB_Typ=8) and TNB_TypRozliczenia=2 and TWP_PdzId=331 and TypDnia=1 then norma else 0 end),0)
 from  #TMP1
 INNER JOIN CDN.PracEtaty on Pre_PRaId=@PrcId and dateadd(day,-1,dateadd(month,1,dateadd(day,1-day(Data),Data))) between PRE_DataOd
 and PRE_DataDo and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
 and ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3 and PRE_UbzTyuID<>120) OR (PRE_UbzTyuID = 800))
 LEFT OUTER JOIN CDN.TypNieobec on TypNieob = TNB_TnbId
 INNER JOIN CDN.WypSkladniki on WPS_PraId=@PrcId and Data between WPS_DataOd and WPS_DataDo
 INNER JOIN CDN.Wyplaty on WPS_WplId = WPL_WplId and WPL_Tryb<>1 and WPL_Tryb<>2
 INNER JOIN CDN.TypWyplata on WPS_TwpId = TWP_TwpId
--
DELETE #TMP1
DELETE #TMP2
--
END
CLOSE Tmp_Czas
DEALLOCATE Tmp_Czas
SET @P1 = @CzasPracyOg/60
SET @P3 = @CzasPracyNadl/60
SET @P5 = @CzasPracyNie/60
SET @P7 = @CzasPracyOpl/60
SET @P9 = @CzasUrlWyp/60
SET @P11 = @CzasChoroby/60
--
DROP TABLE #TMP1
DROP TABLE #TMP2
--
END
--
If @Typ = 4
--
BEGIN
DECLARE @ZatrOst INT
DECLARE @ZatrOstK INT
DECLARE @PrzyZw  INT
DECLARE @PrzyZwK INT
DECLARE @FirstJob INT
DECLARE @FirstJobK INT
DECLARE @SzkW  INT
DECLARE @SzkWK  INT
DECLARE @SzkPol  INT
DECLARE @SzkPolK INT
DECLARE @Lic  INT
DECLARE @LicK  INT
DECLARE @SzkZas  INT
DECLARE @SzkZasK INT
DECLARE @PoprzPraca INT
DECLARE @PoprzPracaK INT
DECLARE @UrlWB  INT
DECLARE @UrlWBK  INT
DECLARE @Inni  INT
DECLARE @InniK  INT
SET @ZatrOst = 0
SET @ZatrOstK = 0
SET @PrzyZw = 0
SET @PrzyZwK = 0
SET @FirstJob = 0
SET @FirstJobK = 0
SET @SzkW = 0
SET @SzkWK = 0
SET @SzkPol = 0
SET @SzkPolK = 0
SET @Lic = 0
SET @LicK = 0
SET @SzkZas = 0
SET @SzkZasK = 0
SET @PoprzPraca = 0
SET @PoprzPracaK = 0
SET @UrlWB = 0
SET @UrlWBK = 0
SET @Inni = 0
SET @InniK = 0
--
SET @ZatrOst =  (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where TNB_PdzId in (111, 112, 121, 122) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst1 and max(grp) >= @DataOst1)
 ,0) <91
and ((Left(PRE_UbzTyuID,1)=1 or Left(PRE_UbzTyuID,1)=2) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and PRE_HDKGUSPracSezonowy = 0 and @DataOst1 between PRE_DataOd and PRE_DataDo
and @DataOst1 between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)>=1) T)
--
SET @ZatrOstK =  (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where TNB_PdzId in (111, 112, 121, 122) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst1 and max(grp) >= @DataOst1)
 ,0) <91 and ((Left(PRE_UbzTyuID,1)=1 or Left(PRE_UbzTyuID,1)=2) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and PRE_HDKGUSPracSezonowy = 0 and @DataOst1 between PRE_DataOd and PRE_DataDo
and @DataOst1 between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo  and  PRE_plec = 'K' group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)>=1) T)
--
SET @FirstJob = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @FirstJobK = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and  PRE_plec = 'K' and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @SzkW = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and PRE_kodwyksztal=50 and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @SzkWK = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_plec = 'K' and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and PRE_kodwyksztal=50 and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @SzkPol = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and PRE_kodwyksztal in (31, 40) and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @SzkPolK = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_plec = 'K' and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and PRE_kodwyksztal in (31, 40) and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @Lic = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and PRE_kodwyksztal=32 and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @LicK = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_plec = 'K' and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and PRE_kodwyksztal=32 and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @SzkZas = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and PRE_kodwyksztal=20 and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @SzkZasK = (select count(A.PRE_PraId) from (select PRE_PraId from cdn.pracetaty
where  ((Left(PRE_UbzTyuID,1)=1 and Len(PRE_UbzTyuID)=3) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM
and PRE_plec = 'K' and PRE_HDKGUSGlowneMiejscePracy = 1 and PRE_HDKGUSPracSezonowy = 0 and PRE_kodwyksztal=20 and
PRE_HDKGUSPierwszaPraca=1 and PRE_ZatrudnionyOd between @DataOd and @DataDo
Group by Pre_praid, PRE_ZatrudnionyOd) as A)
--
SET @PoprzPraca = (select (
select IsNull(sum(BylZatrudniony),0) from (
 select distinct PRE_PraId, PRE_ZatrudnionyOd, case when
exists(select * from CDN.PracEtaty H where H.PRE_PraId=E.PRE_PraId and
H.PRE_ZatrudnionyDo between dateadd(day,-31,E.PRE_ZatrudnionyOd) and
dateadd(day,-1,E.PRE_ZatrudnionyOd) and
datediff(month,H.PRE_ZatrudnionyDo,E.PRE_ZatrudnionyOd)<2) then 1
     when exists(select * from CDN.HisZatrud where
HZT_PraId=PRE_PraId and HZT_OkresDo between
dateadd(day,-31,E.PRE_ZatrudnionyOd) and dateadd(day,-1,E.PRE_ZatrudnionyOd)
and datediff(month,HZT_OkresDo,E.PRE_ZatrudnionyOd)<2) then 1  else 0 end
BylZatrudniony
 from CDN.PracEtaty E
 where PRE_ZatrudnionyOd between @DataOd and @DataDo and
PRE_ETAEtatL>=PRE_ETAEtatM and PRE_HDKGUSPierwszaPraca=0 and PRE_HDKGUSGlowneMiejscePracy=1
) Etaty)
+ (
select count(*)
from CDN.PracEtaty E
inner join CDN.PracEtaty H on H.PRE_PraId=E.PRE_PraId and
H.PRE_DataDo=dateadd(day,-1,E.PRE_DataOd) and
H.PRE_ZatrudnionyOd=E.PRE_ZatrudnionyOd
where E.PRE_DataOd between @DataOd and @DataDo and E.PRE_HDKGUSPierwszaPraca=0 and E.PRE_HDKGUSGlowneMiejscePracy=1 and
E.PRE_ETAEtatL>=E.PRE_ETAEtatM and H.PRE_ETAEtatL<H.PRE_ETAEtatM and
1.0 * E.PRE_ETAEtatL/E.PRE_ETAEtatM  >  1.0 * H.PRE_ETAEtatL/H.PRE_ETAEtatM))
--
SET @PoprzPracaK = (select (
select IsNull(sum(BylZatrudniony),0) from (
 select distinct PRE_PraId, PRE_ZatrudnionyOd, case when
exists(select * from CDN.PracEtaty H where H.PRE_PraId=E.PRE_PraId and
H.PRE_ZatrudnionyDo between dateadd(day,-31,E.PRE_ZatrudnionyOd) and
dateadd(day,-1,E.PRE_ZatrudnionyOd) and
datediff(month,H.PRE_ZatrudnionyDo,E.PRE_ZatrudnionyOd)<2) then 1
     when exists(select * from CDN.HisZatrud where
HZT_PraId=PRE_PraId and HZT_OkresDo between
dateadd(day,-31,E.PRE_ZatrudnionyOd) and dateadd(day,-1,E.PRE_ZatrudnionyOd)
and datediff(month,HZT_OkresDo,E.PRE_ZatrudnionyOd)<2) then 1  else 0 end
BylZatrudniony
 from CDN.PracEtaty E
 where PRE_ZatrudnionyOd between @DataOd and @DataDo and
PRE_ETAEtatL>=PRE_ETAEtatM and PRE_HDKGUSPierwszaPraca=0 and  PRE_plec = 'K' and PRE_HDKGUSGlowneMiejscePracy=1
) Etaty)
+ (
select count(*)
from CDN.PracEtaty E
inner join CDN.PracEtaty H on H.PRE_PraId=E.PRE_PraId and
H.PRE_DataDo=dateadd(day,-1,E.PRE_DataOd) and
H.PRE_ZatrudnionyOd=E.PRE_ZatrudnionyOd
where E.PRE_DataOd between @DataOd and @DataDo and E.PRE_HDKGUSPierwszaPraca=0 and E.PRE_plec = 'K' and E.PRE_HDKGUSGlowneMiejscePracy=1 and
E.PRE_ETAEtatL>=E.PRE_ETAEtatM and H.PRE_ETAEtatL<H.PRE_ETAEtatM and
1.0 * E.PRE_ETAEtatL/E.PRE_ETAEtatM  >  1.0 * H.PRE_ETAEtatL/H.PRE_ETAEtatM))
--
SET @UrlWB = (select count(T.ID) from (
 select Pre_Praid ID
 from CDN.PracEtaty
 where isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where TNB_PdzId in (121, 122) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst1 and max(grp) >= @DataOst1 and max(grp) < @DataOst)
 ,0) >90
  and ((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and
Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
  and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or
(PRE_UbzTyuID = 800))
  and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOd between
PRE_DataOd and PRE_DataDo
  and @DataOd between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
and PRE_ETAEtatL>=PRE_ETAEtatM
) T)
--
SET @UrlWBK = (select count(T.ID) from (
 select Pre_Praid ID
 from CDN.PracEtaty
 where isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where TNB_PdzId in (121, 122) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst1 and max(grp) >= @DataOst1 and max(grp) < @DataOst)
 ,0) >90
  and ((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and
Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
  and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or
(PRE_UbzTyuID = 800)) and PRE_plec = 'K'
  and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOd between
PRE_DataOd and PRE_DataDo
  and @DataOd between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
and PRE_ETAEtatL>=PRE_ETAEtatM
) T)
--
SET @Inni = (select (select IsNull(sum(BylZatrudniony),0) from (select distinct PRE_PraId, PRE_ZatrudnionyOd,
case when exists(select * from CDN.PracEtaty H where H.PRE_PraId=E.PRE_PraId and
H.PRE_ZatrudnionyDo between dateadd(day,-31,E.PRE_ZatrudnionyOd) and dateadd(day,-1,E.PRE_ZatrudnionyOd) and
datediff(month,H.PRE_ZatrudnionyDo,E.PRE_ZatrudnionyOd)<2) then 0
when exists(select * from CDN.HisZatrud where HZT_PraId=PRE_PraId and HZT_OkresDo between
dateadd(day,-31,E.PRE_ZatrudnionyOd) and dateadd(day,-1,E.PRE_ZatrudnionyOd)
and datediff(month,HZT_OkresDo,E.PRE_ZatrudnionyOd)<2) then 0  else 1 end BylZatrudniony
from CDN.PracEtaty E where PRE_ZatrudnionyOd between @DataOd and @DataDo and PRE_ZatrudnionyOd>=PRE_DataOd and
((Left(PRE_UbzTyuID,1)=1 or Left(PRE_UbzTyuID,1)=2) or (PRE_UbzTyuID = 800))
and PRE_ETAEtatL>=PRE_ETAEtatM and PRE_HDKGUSPierwszaPraca=0 and PRE_HDKGUSGlowneMiejscePracy=1) Etaty)
+
(select count(T.ID) from (
 select Pre_Praid ID
 from CDN.PracEtaty
 where isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where TNB_PdzId in (111, 112) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst1 and max(grp) >= @DataOst1 and max(grp) < @DataOst)
 ,0) >90
  and ((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and
Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
  and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or
(PRE_UbzTyuID = 800))
  and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOd between
PRE_DataOd and PRE_DataDo
  and @DataOd between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
and PRE_ETAEtatL>=PRE_ETAEtatM
) T)
)
--
SET @InniK = (select (select IsNull(sum(BylZatrudniony),0) from (select distinct PRE_PraId, PRE_ZatrudnionyOd,
case when exists(select * from CDN.PracEtaty H where H.PRE_PraId=E.PRE_PraId and
H.PRE_ZatrudnionyDo between dateadd(day,-31,E.PRE_ZatrudnionyOd) and dateadd(day,-1,E.PRE_ZatrudnionyOd) and
datediff(month,H.PRE_ZatrudnionyDo,E.PRE_ZatrudnionyOd)<2) then 0
when exists(select * from CDN.HisZatrud where HZT_PraId=PRE_PraId and HZT_OkresDo between
dateadd(day,-31,E.PRE_ZatrudnionyOd) and dateadd(day,-1,E.PRE_ZatrudnionyOd)
and datediff(month,HZT_OkresDo,E.PRE_ZatrudnionyOd)<2) then 0  else 1 end BylZatrudniony
from CDN.PracEtaty E where PRE_ZatrudnionyOd between @DataOd and @DataDo and PRE_ZatrudnionyOd>=PRE_DataOd and
PRE_ETAEtatL>=PRE_ETAEtatM and PRE_HDKGUSPierwszaPraca=0 and
((Left(PRE_UbzTyuID,1)=1 or Left(PRE_UbzTyuID,1)=2) or (PRE_UbzTyuID = 800))
and PRE_plec = 'K' and PRE_HDKGUSGlowneMiejscePracy=1) Etaty)
+
(select count(T.ID) from (
 select Pre_Praid ID
 from CDN.PracEtaty
 where isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where TNB_PdzId in (111, 112) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst1 and max(grp) >= @DataOst1 and max(grp) < @DataOst)
 ,0) >90
  and ((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and
Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
  and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or
(PRE_UbzTyuID = 800)) and PRE_plec = 'K'
  and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOd between
PRE_DataOd and PRE_DataDo
  and @DataOd between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
and PRE_ETAEtatL>=PRE_ETAEtatM
) T)
)
--
SET @P1 = @ZatrOst
SET @P2 = @ZatrOstK
SET @P3 = @PrzyZw
SET @P4 = @PrzyZwK
SET @P5 = @FirstJob
SET @P6 = @FirstJobK
SET @P7 = @SzkW
SET @P8 = @SzkWK
SET @P9 = @SzkPol
SET @P10 = @SzkPolK
SET @P11 = @Lic
SET @P12 = @LicK
SET @P13 = @SzkZas
SET @P14 = @SzkZasK
SET @P15 = @PoprzPraca
SET @P16 = @PoprzPracak
SET @P17 = @UrlWB
SET @P18 = @UrlWBK
SET @P19 = @Inni
SET @P20 = @InniK
END
-- Stan na 31
--
/*
[JK] zgł.138128
Grupowanie ilości osób: COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end)
Sumowanie etatów: join CDN.PracKod + group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)
*/
If @Typ = 5
--
BEGIN
DECLARE @PracaOg INT
DECLARE @PracaOgK INT
DECLARE @PracaG  INT
DECLARE @PracaGK INT
DECLARE @PelnZatr INT
DECLARE @PelnZatrK INT
DECLARE @NiepZatr INT
DECLARE @NiepZatrK INT
--
DECLARE @PelnZatrOkres INT
DECLARE @PelnZatrOkresK INT
DECLARE @NiepZatrOkres INT
DECLARE @NiepZatrOkresK INT
--
DECLARE @WlascWsp INT
DECLARE @WlascWspK INT
DECLARE @Wlasc  INT
DECLARE @WlascK  INT
DECLARE @Nakl  INT
DECLARE @NaklK  INT
DECLARE @Noc  INT
DECLARE @NocK  INT
DECLARE @PrNiep  INT
DECLARE @PrNiepK INT
DECLARE @Cudz  INT
DECLARE @CudzK  INT
DECLARE @EmR  INT
DECLARE @EmRK  INT
SET @PracaOg = 0
SET @PracaOgK = 0
SET @PracaG = 0
SET @PracaGK = 0
SET @PelnZatr = 0
SET @PelnZatrK = 0
SET @NiepZatr = 0
SET @NiepZatrK = 0
--
SET @PelnZatrOkres = 0
SET @PelnZatrOkresK = 0
SET @NiepZatrOkres = 0
SET @NiepZatrOkresK = 0
--
SET @WlascWsp = 0
SET @WlascWspK = 0
SET @Wlasc = 0
SET @WlascK = 0
SET @Nakl = 0
SET @NaklK = 0
SET @Noc = 0
SET @NocK = 0
SET @PrNiep = 0
SET @PrNiepK = 0
SET @Cudz = 0
SET @CudzK = 0
SET @EmR = 0
SET @EmRK = 0
--
SET @PracaOg = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end)from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where  PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4 and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910
and (Len(PRE_UbzTyuID)=3 or PRE_UbzTyuID = 20000 or PRE_UbzTyuID = 800) and
@DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_Tymczasowy = 0)
--
SET @PracaOgK = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end)from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where  PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4 and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and (Len(PRE_UbzTyuID)=3 or PRE_UbzTyuID = 20000 or PRE_UbzTyuID = 800)
and PRE_plec = 'K' and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_Tymczasowy = 0)
--
SET @PelnZatr =  (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)>=1) T)
--
SET @PelnZatrOkres = (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_ETARodzajUmowy<> '  ' and PRE_ETARodzajUmowy<> 'na czas nieokreślony' group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)>=1) T)
--
SET @PelnZatrK =  (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_plec = 'K'
group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)>=1) T)
--
SET @PelnZatrOkresK = (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_plec = 'K' and PRE_ETARodzajUmowy<> '  ' and PRE_ETARodzajUmowy<> 'na czas nieokreślony'
group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)>=1) T)
--
SET @NiepZatr =  (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)<1) T)
--
SET @NiepZatrOkres = (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_ETARodzajUmowy<> '  ' and PRE_ETARodzajUmowy<> 'na czas nieokreślony' group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)<1) T)
--
SET @NiepZatrK =  (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_plec = 'K'
group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)<1) T)
--
--
SET @NiepZatrOkresK = (select count(T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on PRE_PraId = PRA_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID = 800))
and PRE_HDKGUSGlowneMiejscePracy=1 and @DataOst between PRE_DataOd and PRE_DataDo
and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and PRE_plec = 'K'  and PRE_ETARodzajUmowy<> '  ' and PRE_ETARodzajUmowy<> 'na czas nieokreślony'
group by case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end having round(sum(PRE_ETAEtatL*1.0/PRE_ETAEtatM),5)<1) T)
--
--
SET @WlascWsp = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end)from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where  Left(PRE_UbzTyuID,1)=5 and Len(PRE_UbzTyuID)=3 and PRE_HDKGUSGlowneMiejscePracy=1 and
@DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo)
--
SET @WlascWspK = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end)from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where  Left(PRE_UbzTyuID,1)=5 and Len(PRE_UbzTyuID)=3 and PRE_plec = 'K' and PRE_HDKGUSGlowneMiejscePracy=1 and
@DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo)
--
SET @Wlasc = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end)from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where  Left(PRE_UbzTyuID,1)=5 and PRE_UbzTyuID<>511 and PRE_UbzTyuID<>545 and Len(PRE_UbzTyuID)=3
and PRE_HDKGUSGlowneMiejscePracy=1 and
@DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo)
--
SET @WlascK = (select COUNT(DISTINCT case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end)from cdn.pracetaty join cdn.prackod on pra_praid=pre_praid
where  Left(PRE_UbzTyuID,1)=5 and PRE_UbzTyuID<>511 and PRE_UbzTyuID<>545 and Len(PRE_UbzTyuID)=3
and PRE_plec = 'K' and PRE_HDKGUSGlowneMiejscePracy=1 and
@DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo)
--
SET @Nakl =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
(PRE_UbzTyuID=20000 or PRE_UbzTyuID=200)and PRE_HDKGUSGlowneMiejscePracy=1 and
@DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @NaklK =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where PRE_plec='K'  and
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
(PRE_UbzTyuID=20000 or PRE_UbzTyuID=200)and PRE_HDKGUSGlowneMiejscePracy=1 and
@DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @Noc =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID, 1)<>4 and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910
and (Len(PRE_UbzTyuID)=3 or PRE_UbzTyuID = 20000 or PRE_UbzTyuID = 800)
and PRE_HDKGUSPoraNocna=1 and PRE_HDKGUSGlowneMiejscePracy=1
and @DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @NocK =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where PRE_plec='K'  and
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID, 1)<>4 and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910
and (Len(PRE_UbzTyuID)=3 or PRE_UbzTyuID = 20000 or PRE_UbzTyuID = 800)
and PRE_HDKGUSPoraNocna=1 and PRE_HDKGUSGlowneMiejscePracy=1
and @DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @PrNiep =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID, 1)<>4 and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and (Len(PRE_UbzTyuID)=3 or PRE_UbzTyuID = 20000 or PRE_UbzTyuID = 800)
and PRE_StNiepelnosp <> 0 and PRE_HDKGUSGlowneMiejscePracy=1
and @DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @PrNiepK =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and  PRE_plec = 'K' and
PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID, 1)<>4 and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and (Len(PRE_UbzTyuID)=3 or PRE_UbzTyuID = 20000 or PRE_UbzTyuID = 800)
and PRE_StNiepelnosp <> 0 and PRE_HDKGUSGlowneMiejscePracy=1
and @DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @Cudz =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID=110  and Len(PRE_UbzTyuID)=3) or PRE_UbzTyuID = 800)
and  PRE_Obywatelstwo<>'polskie'
and PRE_HDKGUSGlowneMiejscePracy=1
and @DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @CudzK =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
((PRE_UbzTyuID=110  and Len(PRE_UbzTyuID)=3) or PRE_UbzTyuID = 800)
and  PRE_Obywatelstwo<>'polskie' and PRE_plec = 'K'
and PRE_HDKGUSGlowneMiejscePracy=1
and @DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @EmR =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4 and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and (Len(PRE_UbzTyuID)=3 or PRE_UbzTyuID = 20000 or PRE_UbzTyuID = 800)
and PRE_HDKGUSGlowneMiejscePracy=1 and PRE_PrawoER<>0
and @DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @EmRK =  (select count(DISTINCT T.ID) from
(select case when ISNULL(pra_parentid,0)=0 then pra_praid else pra_parentid end ID from CDN.PracEtaty join CDN.PracKod on Pre_PraId = Pra_PraId
where
isNull(
(select datediff(day, min(d.PNB_OkresOd), max(d.grp)) + 1 as dlugosc
from
  (select PNB_OkresOd, (select min(b.PNB_OkresDo) from CDN.PracNieobec as b
     where b.PNB_TnbId = a.PNB_TnbId and b.PNB_OkresDo >= a.PNB_OkresDo and b.PNB_Tryb <> 1 and b.PNB_PraId = PRE_PraId and not exists
       (select * from CDN.PracNieobec as c where c.PNB_TnbId = b.PNB_TnbId and c.PNB_OkresOd = dateadd(day, 1, b.PNB_OkresDo) and c.PNB_Tryb <> 1 and c.PNB_PraId = PRE_PraId)) as grp
   from CDN.PracNieobec as a
   inner join CDN.TypNieobec on TNB_TnbId = a.PNB_TnbId
   where (TNB_PdzId in (111, 112, 121, 122) or (TNB_PdzId in (321, 322) and a.PNB_Przyczyna <> 5) or TNB_Standardowy=312) and a.PNB_Tryb <> 1 and a.PNB_PraId = PRE_PraId) as d
group by d.grp
having min(d.PNB_OkresOd) <= @DataOst and max(grp) >= @DataOst)
 ,0) <91 and
PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4 and PRE_UbzTyuID<>920 and PRE_UbzTyuID<>910 and (Len(PRE_UbzTyuID)=3 or PRE_UbzTyuID = 20000 or PRE_UbzTyuID = 800)
and PRE_HDKGUSGlowneMiejscePracy=1 and PRE_PrawoER<>0  and PRE_plec = 'K'
and @DataOst between PRE_DataOd and PRE_DataDo and @DataOst between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo) T)
--
SET @P1 = @PracaOg
SET @P2 = @PracaOgK
SET @P3 = @PracaG
SET @P4 = @PracaGK
SET @P5 = @PelnZatr
SET @P6 = @PelnZatrK
SET @P7 = @NiepZatr
SET @P8 = @NiepZatrK
SET @P9 = @WlascWsp
SET @P10 = @WlascWspK
SET @P11 = @PelnZatrOkres
SET @P12 = @PelnZatrOkresK
SET @P13 = @Nakl
SET @P14 = @NaklK
SET @P15 = @Noc
SET @P16 = @NocK
SET @P17 = @PrNiep
SET @P18 = @PrNiepK
SET @P19 = @Cudz
SET @P20 = @CudzK
SET @P21 = @EmR
SET @P22 = @EmRK
SET @P23 = @NiepZatrOkres
SET @P24 = @NiepZatrOkresK
END
--
select @F1 F1, @F2 F2, @F3 F3, @P1 P1, @P2 P2, @P3 P3, @P4 P4, @P5 P5, @P6 P6, @P7 P7, @P8 P8, @P9 P9, @P10 P10,
 @P11 P11, @P12 P12, @P13 P13, @P14 P14, @P15 P15, @P16 P16, @P17 P17, @P18 P18, @P19 P19, @P20 P20,
 @P21 P21, @P22 P22, @P23 P23, @P24 P24, @P25 P25, @P26 P26, @P27 P27, @P28 P28
SET NOCOUNT OFF
END
