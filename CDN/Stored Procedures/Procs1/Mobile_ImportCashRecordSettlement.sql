CREATE PROCEDURE [CDN].[Mobile_ImportCashRecordSettlement]
@ID int,
@DocId int,
@Lp int,
@CashRecordId int,
@DocType int,
@ErpDocId int,
@PaymentFormId decimal(15,2),
@SerieName NVARCHAR(10),
@Value decimal(15,2)
AS
BEGIN
SET NOCOUNT ON
DECLARE
    @DPlD_DPlDId INT
if @DocId = 0
begin
  SELECT  @DPlD_DPlDId = DRZ_DRZId
    FROM CDN.DetalRoliczeniaZaleglosci
    WHERE DRZ_BZdId = @ErpDocId  and DRZ_DSZKBID = @CashRecordId AND DRZ_StanDetalID = @ID
  IF @DPlD_DPlDId IS NULL
    BEGIN
      INSERT INTO CDN.DetalRoliczeniaZaleglosci (
    DRZ_BZdId,
DRZ_DSZKBID,
DRZ_StanDetalID,
DRZ_Kwota,
DRZ_DSDRZId)
  VALUES (
    @ErpDocId ,
    @CashRecordId,
    @ID,
@Value,
@Lp
         )
end
end
else
begin
  SELECT  @DPlD_DPlDId = DPlD_DPlDId
    FROM CDN.DetalPlatnosciDokumentu
    WHERE DPlD_DSTrNId = @DocId and DPlD_DSZKBID = @CashRecordId AND DPlD_StanDetalID = @ID
  IF @DPlD_DPlDId IS NULL
    BEGIN
       INSERT INTO CDN.DetalPlatnosciDokumentu (
      DPlD_DSPlDId ,
      DPlD_DSTrNId ,
         DPlD_StanDetalID ,
      DPlD_DSFPlId ,
      DPlD_Kwota ,
      DPlD_KwotaZaplacona ,
      DPlD_DataPlatnosci,
         DPlD_Gotowka,
         DPlD_Termin ,
  DPlD_DSZKBID)
  VALUES (
    @Lp ,
 @DocId ,
    @ID,
 @PaymentFormId  ,
 @Value ,
 @Value,
 GETDATE(),
    0,
    0,
    @CashRecordId
         )
end
    END
  SET NOCOUNT OFF
END
