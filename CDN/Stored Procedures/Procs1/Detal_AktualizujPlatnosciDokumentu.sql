CREATE PROCEDURE [CDN].[Detal_AktualizujPlatnosciDokumentu]
    @DSPlDId int ,
 @DSTrNId int ,
    @StanDetalID int ,
 @DSFPlId int ,
 @Kwota decimal(15, 2) ,
 @KwotaZaplacona decimal(15, 2) ,
 @DataPlatnosci datetime,
    @Gotowka tinyint,
    @Termin datetime
AS
SET NOCOUNT ON
DECLARE
    @DPlD_DPlDId INT
  SELECT  @DPlD_DPlDId = DPlD_DPlDId
    FROM CDN.DetalPlatnosciDokumentu
    WHERE DPlD_DSPlDId = @DSPlDId AND DPlD_StanDetalID = @StanDetalID
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
         DPlD_Termin,
         DPlD_DSZKBID )
  VALUES (
    @DSPlDId ,
 @DSTrNId ,
    @StanDetalID,
 @DSFPlId ,
 @Kwota ,
 @KwotaZaplacona ,
 @DataPlatnosci,
    @Gotowka,
    @Termin,
    0
         )
    END
  SET NOCOUNT OFF
