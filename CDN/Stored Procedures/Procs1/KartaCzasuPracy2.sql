create  PROCEDURE CDN.KartaCzasuPracy2 @DataOd DATETIME, @DataDo DATETIME, @PrcId INT
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
--Tworze tabele tymczasowa, ktora zwracac bedzie typ dnia i nieobecnosci
declare @CzasPracy TABLE (
 Tmp_PrcId        INT,
 Tmp_Data         DATETIME,
 Tmp_TypDnia      INT,
 Tmp_TypNieob     INT
 )
--Wstawiam typ dnia oraz wystepujace nieobecnosci
INSERT INTO @CzasPracy
select @PrcId, Data, TypDnia, TypNieob
from
 (select Data, TypDnia, TypNieob
  FROM ( select Data, TypDnia, TypNieob from CDN.PracCzasPracyFN(3, @PrcId, @DataOd, @DataDo) ) CzasPracy
  inner join CDN.PracEtaty on @PrcId = Pre_PraId
  and Data between PRE_DataOd and PRE_DataDo
 ) Dni
SELECT Tmp_PrcId, Tmp_Data, Tmp_TypDnia, 1 from @CzasPracy
--where Tmp_TypNieob is null
group by Tmp_PrcId, Tmp_Data, Tmp_TypDnia--, Tmp_TypNieob
order by Tmp_Data--, Tmp_TypNieob
SET NOCOUNT OFF
END
