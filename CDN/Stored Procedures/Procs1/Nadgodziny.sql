create   procedure CDN.Nadgodziny @DataOd DATETIME, @DataDo DATETIME, @PrcId INT
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
DECLARE @dzien datetime
SET @dzien = @DataOd
if @DataDo<@DataOd set @DataDo=@DataOd
--Tworze zmienna tabelaryczna, ktora zwracac bedzie nadgodziny pracownika
declare @CzasPracy TABLE (
 Tmp_PrcId INT,
 Tmp_Data DATETIME,
 Tmp_OBM DECIMAL(15,2),
 Tmp_ONM DECIMAL(15,2),
 Tmp_WPL DECIMAL(15,2),
 Tmp_WNPL DECIMAL(15,2)
 )
WHILE @dzien<=@DataDo
BEGIN
  INSERT INTO @CzasPracy
  SELECT @prcId, @dzien,
IsNull(sum((Case when  PGR_OdbNadg = 2 then DATEDIFF(minute, PGR_OdGodziny,PGR_DoGodziny) + (Case When PGR_DoGodziny<PGR_OdGodziny Then 1440 Else 0 End) Else 0 End)),0),
IsNull(sum((Case when  PGR_OdbNadg = 3 then DATEDIFF(minute, PGR_OdGodziny,PGR_DoGodziny) + (Case When PGR_DoGodziny<PGR_OdGodziny Then 1440 Else 0 End) Else 0 End)),0),
IsNull(sum((Case when  PGR_OdbNadg = 4 then DATEDIFF(minute, PGR_OdGodziny,PGR_DoGodziny) + (Case When PGR_DoGodziny<PGR_OdGodziny Then 1440 Else 0 End) Else 0 End)),0),
IsNull(sum((Case when  PGR_OdbNadg = 5 then DATEDIFF(minute, PGR_OdGodziny,PGR_DoGodziny) + (Case When PGR_DoGodziny<PGR_OdGodziny Then 1440 Else 0 End) Else 0 End)),0)
  FROM CDN.PracPracaDni join CDN.PracPracaDniGodz on ppr_pprid = pgr_pprid where @PrcId = Ppr_PraId and @dzien = PPR_Data
  SET @dzien = @dzien+1
END
SELECT * from @CzasPracy
order by Tmp_Data
SET NOCOUNT OFF
END
