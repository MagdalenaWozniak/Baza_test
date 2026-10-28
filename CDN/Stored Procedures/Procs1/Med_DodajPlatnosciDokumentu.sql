CREATE PROCEDURE [CDN].[Med_DodajPlatnosciDokumentu]
 @DSPlDId int , --id obce platnosci
 @DSTrNId int , --id obce dokumentu
 @StanDetalID int , -- id stanowiska
 @DSFPlId int , -- id formy platnosci
 @Kwota decimal(15, 2) , -- kwota platnosci
 @DataPlatnosci datetime, -- data płatności
 @Termin datetime -- temin płatnosci
AS
SET NOCOUNT ON
DECLARE
    @DPlD_DPlDId INT
  SELECT  @DPlD_DPlDId = DPlD_DPlDId
    FROM CDN.DetalPlatnosciDokumentu
    WHERE DPlD_DSPlDId = @DSPlDId and  DPlD_StanDetalID = @StanDetalID
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
 @Kwota ,
 @DataPlatnosci,
    0,
    @Termin,
    0
         )
END
  SET NOCOUNT OFF
