CREATE PROCEDURE CDN.DoRDokumentySkojarzoneDoZlecenia( @id INT )
AS
BEGIN
 DECLARE @crm INT, @srs INT, @obd INT
 SET @crm = 700
 SET @obd = 750
 SET @srs = 900
 EXEC CDN.InsertDorDokumentySkojarzoneDoZlecenia @id
 SELECT cdn.DokRelacje.*, CASE WHEN (DoR_ParentTyp=@crm OR DoR_ParentTyp=@obd) THEN 1 ELSE 0 END AS DoR_Kierunek
 FROM cdn.DokRelacje WHERE DoR_ParentTyp=@srs AND DoR_ParentId=@id AND DoR_DokumentTyp <> @crm
 ORDER BY DoR_DoRID
END
