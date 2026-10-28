CREATE PROCEDURE [CDN].[CzasPracyUmowaCalc] @IdPrac INT, @Ozn Char(1), @Osoba NVarChar(71), @Kod NVarChar(20), @DataOd DATETIME, @DataDo DATETIME, @NrUmowy NVarChar(31)
AS
SET NOCOUNT ON
INSERT INTO #CzasUmowy
select
2,
@IdPrac,
@Ozn,
@Osoba,
@Kod,
Substring(CONVERT(char,Data,120),1,11),
case when isnull(Nieobec,0)=0 then case when datediff(n,GodzOd,GodzDo) <= 0 and Strefa > 1 then datediff(n,GodzOd,GodzDo) + 1440 else datediff(n,GodzOd,GodzDo) end else 0 end,
@NrUmowy from CDN.PracCzasPracyFN(3,@IdPrac,@DataOd, @DataDo)
