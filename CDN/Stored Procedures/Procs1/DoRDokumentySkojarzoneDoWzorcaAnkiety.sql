CREATE PROCEDURE CDN.DoRDokumentySkojarzoneDoWzorcaAnkiety( @id INT )
AS
BEGIN
    DECLARE @wzorzecAnk INT
    SET @wzorzecAnk = 714
    SELECT cdn.DokRelacje.*, CASE WHEN (DoR_ParentTyp=@wzorzecAnk) THEN 1 ELSE 0 END AS DoR_Kierunek
    FROM cdn.DokRelacje WHERE DoR_ParentTyp=@wzorzecAnk AND DoR_ParentId=@id AND DoR_DokumentTyp <> @wzorzecAnk
    ORDER BY DoR_DoRID
END
