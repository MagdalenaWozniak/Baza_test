CREATE PROCEDURE [CDN].[DetalStan_UaktualnijPlatnoscDokumentu]
@DocumentId int,
@PaymentModeId int,
@Kwota decimal(15, 2),
@KwotaZaplacona decimal(15, 2),
@DataPlatnosci datetime,
@Termin datetime
AS
BEGIN
SET NOCOUNT ON
UPDATE CDN.DetalStanPlatnosciDokumentu
SET DSPlD_Kwota = @Kwota,
 DSPlD_KwotaZaplacona = @KwotaZaplacona,
 DSPlD_DataPlatnosci = @DataPlatnosci,
 DSPlD_Termin = @Termin
WHERE DSPlD_DSTrNId = @DocumentId AND
  DSPlD_DSFPlId = @PaymentModeId
SET NOCOUNT OFF
END
