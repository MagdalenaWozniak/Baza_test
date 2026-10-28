CREATE PROCEDURE [CDN].[Mobile_ImportCashReport]
@ID int,
@ReportId int,
@ReportNumber int,
@DateOpened datetime,
@DateClosed datetime,
@ErpId int,
@Seria NVARCHAR(254)
AS
BEGIN
SET NOCOUNT ON
if not exists(select DRap_DRapId from cdn.detalraporty where DRap_DSRapId = @ReportId and DRap_DStaId = @ID)
insert into cdn.detalraporty(DRap_DStaId,DRap_DSRapID,DRap_TS_Export) values(@ID,@ReportId,GETDATE())
SET NOCOUNT OFF
END
