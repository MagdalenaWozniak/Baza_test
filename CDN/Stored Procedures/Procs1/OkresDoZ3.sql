CREATE  PROCEDURE [CDN].[OkresDoZ3] @PraId INT, @DataNieobec DATETIME
AS
SET NOCOUNT ON
select * from cdn.OkresZ3(@PraId, @DataNieobec)
SET NOCOUNT OFF
