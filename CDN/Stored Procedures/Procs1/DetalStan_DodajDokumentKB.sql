CREATE PROCEDURE [CDN].[DetalStan_DodajDokumentKB]
@PosId int,
@FPlId int,
@DocType int,
@NrNumer int,
@NrString NVARCHAR(31),
@DataDok datetime,
@KontrahentId int,
@RazemBrutto decimal(15, 2),
@OpeId int,
@Bufor smallint,
@ZmianaId int
AS
BEGIN
SET NOCOUNT ON
INSERT INTO CDN.DetalStanZapisyKB (DSZKB_StanDetalID,
         DSZKB_DSFPlId,
         DSZKB_TypDokumentu,
         DSZKB_NumerNr,
         DSZKB_NumerString,
         DSZKB_DataDok,
         DSZKB_PodID,
         DSZKB_RazemBrutto,
         DSZKB_OpeID,
         DSZKB_Bufor,
         DSZKB_ZmianaId)
VALUES (@PosId,
  @FPlId,
  @DocType,
  @NrNumer,
  @NrString,
  @DataDok,
  @kontrahentId,
  @RazemBrutto,
  @OpeId,
  @Bufor,
  @ZmianaId)
SET NOCOUNT OFF
END
