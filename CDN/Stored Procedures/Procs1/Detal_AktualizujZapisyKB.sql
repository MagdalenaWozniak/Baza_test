CREATE  PROCEDURE [CDN].[Detal_AktualizujZapisyKB]
 @DSZKBID int ,
 @StanDetalID int ,
 @DSFPlId int ,
 @TypDokumentu int ,
 @NumerNr int ,
 @NumerString NVARCHAR(31) ,
 @NumerPelny NVARCHAR(50) ,
 @DataDok datetime ,
 @PodID int ,
 @RazemBrutto decimal(15, 2) ,
 @OpeID int,
    @Opis NVARCHAR(254)
AS
SET NOCOUNT ON
DECLARE
    @DZKB_DZKBID INT
  SELECT  @DZKB_DZKBID = DZKB_DZKBID
    FROM CDN.DetalZapisyKB
    WHERE DZKB_DSZKBID = @DSZKBID and DZKB_StanDetalID = @StanDetalID
  IF @DZKB_DZKBID IS NULL
    BEGIN
       INSERT INTO CDN.DetalZapisyKB (
 DZKB_DSZKBID,
 DZKB_StanDetalID,
 DZKB_DSFPlId,
 DZKB_TypDokumentu,
 DZKB_NumerNr,
 DZKB_NumerString,
 DZKB_NumerPelny,
 DZKB_DataDok,
 DZKB_PodID,
 DZKB_RazemBrutto,
 DZKB_StanSynchronizacji,
 DZKB_OpeID,
    DZKB_Opis
    )
  VALUES (
 @DSZKBID,
 @StanDetalID,
 @DSFPlId,
 @TypDokumentu,
 @NumerNr,
 @NumerString,
 @NumerPelny,
 @DataDok,
 @PodID,
 @RazemBrutto,
 1,
 @OpeID,
    @Opis
         )
    END
  SET NOCOUNT OFF
