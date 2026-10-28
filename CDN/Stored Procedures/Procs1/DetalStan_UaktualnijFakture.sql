CREATE PROCEDURE [CDN].[DetalStan_UaktualnijFakture]
@dataDok datetime,
@ts_zal datetime,
@kontrahentId int,
@osOdbierajaca NVARCHAR(40),
@receiptId int,
@opis NVARCHAR(1024)
AS
BEGIN
SET NOCOUNT ON
UPDATE CDN.DetalStanTraNag SET
DSTrN_DataDok = @dataDok,
DSTrN_TS_Zal = @ts_zal,
DSTrN_PodID = @kontrahentId,
DSTrN_OdbID = @kontrahentId,
DSTrN_Bufor = 0,
DSTrN_OsobaOdbierajaca = @osOdbierajaca,
DSTrN_Opis = @opis
WHERE DSTrN_TypDokumentu = 302 AND DSTrN_FAID = @receiptId
SET NOCOUNT OFF
END
