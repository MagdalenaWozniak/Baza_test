CREATE PROCEDURE [CDN].[DetalStan_DodajPlatnoscDokumentu]
@DocumentId int,
@PaymentModeId int,
@Kwota decimal(15, 2),
@KwotaZaplacona decimal(15, 2),
@DataPlatnosci datetime,
@termin datetime
AS
BEGIN
SET NOCOUNT ON
INSERT INTO CDN.DetalStanPlatnosciDokumentu (DSPlD_DSTrNId,
            DSPlD_DSFPlId,
            DSPlD_Kwota,
            DSPlD_KwotaZaplacona,
            DSPlD_DataPlatnosci,
            DSPlD_Termin)
VALUES (@DocumentId,
  @PaymentModeId,
  @Kwota,
  @KwotaZaplacona,
  @DataPlatnosci,
  @termin)
SET NOCOUNT OFF
END
