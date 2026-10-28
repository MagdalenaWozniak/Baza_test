CREATE PROCEDURE CDN.DoRDokumentyWind( @klasa INT, @id INT )
AS
BEGIN
        SELECT cdn.DokRelacje.*, 1 AS DoR_Kierunek
        FROM cdn.DokRelacje
        WHERE (DoR_ParentTyp IN (222, 700, 1011, 1020)  AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id)
        ORDER BY DoR_DoRID
END
