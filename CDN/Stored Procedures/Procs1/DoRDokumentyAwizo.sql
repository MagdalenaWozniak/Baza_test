CREATE PROCEDURE [CDN].[DoRDokumentyAwizo]( @klasa INT, @id INT )
AS
BEGIN
        SELECT cdn.DokRelacje.*, 0 As DoR_Kierunek FROM cdn.DokRelacje
        WHERE (DoR_ParentTyp =308  AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id)
        ORDER BY DoR_DoRID
END
