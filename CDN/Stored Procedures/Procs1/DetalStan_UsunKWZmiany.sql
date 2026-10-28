CREATE PROCEDURE [CDN].[DetalStan_UsunKWZmiany]
@ShiftId int
AS
BEGIN
SET NOCOUNT ON
DELETE FROM CDN.DetalStanZapisyKB
 WHERE DSZKB_ZmianaId = @ShiftId AND
 DSZKB_TypDokumentu = 2  AND
 DSZKB_Opis = 'Wypłata przy zakończeniu zmiany'
SET NOCOUNT OFF
END
