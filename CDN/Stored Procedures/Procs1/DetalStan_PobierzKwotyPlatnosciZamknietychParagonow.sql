CREATE PROCEDURE [CDN].[DetalStan_PobierzKwotyPlatnosciZamknietychParagonow]
@PosId int,
@PaymentModeId int
AS
BEGIN
SET NOCOUNT ON
SELECT b.DSPlD_Kwota, b.DSPlD_DataPlatnosci, a.DSTrN_OpeID FROM CDN.DetalStanTraNag a
inner join CDN.DetalStanPlatnosciDokumentu b
ON b.DSPlD_DSTrNID = a.DSTrN_DSTrNID
 WHERE a.DSTrN_TypDokumentu = 305 AND
   a.DSTrN_Bufor = 0 AND
   a.DSTrN_StanDetalID = @PosId AND
   b.DSPlD_DSFPlId = @PaymentModeId
SET NOCOUNT OFF
END
