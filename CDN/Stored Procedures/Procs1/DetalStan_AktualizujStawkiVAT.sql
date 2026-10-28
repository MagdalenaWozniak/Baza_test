CREATE  PROCEDURE [CDN].[DetalStan_AktualizujStawkiVAT]
    @StanDetalID int,
 @Stawka decimal(5, 2) ,
 @Flaga smallint
AS
SET NOCOUNT ON
DECLARE
  @DSSVAT_DSSVATId INT
  SELECT @DSSVAT_DSSVATId = DSSVAT_DSSVATId
    FROM CDN.DetalStanStawkiVAT
    WHERE DSSVAT_Stawka = @Stawka and DSSVAT_Flaga = @Flaga and DSSVAT_StanDetalID = @StanDetalID
  IF @DSSVAT_DSSVATId IS NULL
    BEGIN
       INSERT INTO CDN.DetalStanStawkiVAT (
            DSSVAT_StanDetalID
           ,DSSVAT_Stawka
           ,DSSVAT_Flaga
           ,DSSVAT_DFSymbol
           )
  VALUES (
            @StanDetalID,
            @Stawka,
            @Flaga,
            ''
         )
    END
  SET NOCOUNT OFF
