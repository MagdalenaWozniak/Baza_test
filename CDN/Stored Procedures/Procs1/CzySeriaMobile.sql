create  PROCEDURE [CDN].[CzySeriaMobile]
@Seria nvarchar(10)
AS
BEGIN
SET NOCOUNT ON
    if exists (select dsta_seria from cdn.detalstanowiska where  dsta_seria = @Seria ) select 1 else select 0
SET NOCOUNT OFF
END
