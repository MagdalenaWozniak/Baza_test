CREATE PROCEDURE CDN.DoRDokumentySkojarzoneDoOBD( @id INT )
AS
BEGIN
 DECLARE @obd INT, @srs INT, @crm INT
    SET @crm = 700
    SET @obd = 750
    SET @srs = 900
    SELECT cdn.DokRelacje.DoR_DoRId, cdn.DokRelacje.DoR_ParentTyp,cdn.DokRelacje.DoR_ParentId,cdn.DokRelacje.DoR_ParentGUID,cdn.DokRelacje.DoR_DokumentTyp,cdn.DokRelacje.DoR_DokumentId,cdn.DokRelacje.DoR_DokumentGUID,cdn.DokRelacje.DoR_Flaga, CASE WHEN (DoR_ParentTyp=@srs) THEN 1
    ELSE 0 END AS DoR_Kierunek
    FROM cdn.DokRelacje WHERE
        (DoR_ParentTyp=@obd AND DoR_ParentTyp<>@crm  AND DoR_DokumentTyp<>@obd  AND DoR_DokumentTyp<>@crm AND DoR_ParentId=@id)
    OR  (DoR_ParentTyp=@srs AND DoR_DokumentTyp=@obd  AND DoR_DokumentId=@id)
    ORDER BY DoR_DoRID
END
