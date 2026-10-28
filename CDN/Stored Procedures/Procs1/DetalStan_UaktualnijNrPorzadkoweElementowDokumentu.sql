CREATE PROCEDURE [CDN].[DetalStan_UaktualnijNrPorzadkoweElementowDokumentu]
@DocumentId int,
@Lp int,
@type int
AS
BEGIN
SET NOCOUNT ON
UPDATE CDN.DetalStanTraElem
SET DSTrE_Lp = DSTrE_Lp - 1
 WHERE DSTrE_Lp > @Lp AND
    DSTrE_Kaucja = @type AND
    DSTrE_DSTrNId = @DocumentId
SET NOCOUNT OFF
END
