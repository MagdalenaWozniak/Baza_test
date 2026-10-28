CREATE PROCEDURE [CDN].[DetalStan_UaktualnijDokumentKB]
@Id int,
@FPlId int,
@KontrahentId int,
@RazemBrutto decimal(15, 2),
@OpeId int,
@Bufor smallint,
@Opis NVARCHAR(254)
AS
BEGIN
SET NOCOUNT ON
UPDATE CDN.DetalStanZapisyKB
SET DSZKB_DSFPlId = @FPlId,
 DSZKB_PodID = @KontrahentId,
 DSZKB_RazemBrutto = @RazemBrutto,
 DSZKB_Bufor = @Bufor,
 DSZKB_OpeID = @OpeId,
 DSZKB_Opis  = @Opis
WHERE DSZKB_DSZKBID = @Id
SET NOCOUNT OFF
END
