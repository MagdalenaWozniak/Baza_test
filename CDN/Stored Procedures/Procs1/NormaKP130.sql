--/////////////////////////////////////////////////////////////////////////////////////////////////////
create proc cdn.NormaKP130
@StartDate DATETIME, @EndDate DATETIME, @KalId INT
as
begin
SET NOCOUNT ON
SET LANGUAGE us_english;
declare @swieta int
EXEC  @swieta = cdn.IleWolnychWOkresie @StartDate,@EndDate
SELECT
   (DATEDIFF(dd, @StartDate, @EndDate) + 1)
  -(DATEDIFF(wk, @StartDate, @EndDate) * 2)
  -(CASE WHEN DATENAME(dw, @StartDate) = 'Sunday' THEN 1 ELSE 0 END)
  -(CASE WHEN DATENAME(dw, @EndDate) = 'Saturday' THEN 1 ELSE 0 END)
 -@swieta
SET NOCOUNT OFF
end
