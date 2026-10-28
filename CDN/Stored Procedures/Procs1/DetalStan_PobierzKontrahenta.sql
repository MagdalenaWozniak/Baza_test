CREATE PROCEDURE [CDN].[DetalStan_PobierzKontrahenta]
@code NVARCHAR(20)
AS
BEGIN
SET NOCOUNT ON
SELECT DSKnt_DSKntId, DSKnt_Kod, DSKnt_Nazwa1, DSKnt_OsobaOdbierajaca FROM CDN.DetalStanKontrahenci
WHERE DSKnt_Kod = @code
SET NOCOUNT OFF
END
