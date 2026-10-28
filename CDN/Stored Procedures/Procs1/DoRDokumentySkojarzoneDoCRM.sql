CREATE PROCEDURE CDN.DoRDokumentySkojarzoneDoCRM( @id INT )
AS
BEGIN
 DECLARE @crm INT, @srs INT, @obd INT
 SET @crm = 700
 SET @obd = 750
 SET @srs = 900
 SELECT cdn.DokRelacje.*,CASE WHEN (DoR_ParentTyp=@srs OR DoR_ParentTyp=@obd) THEN 1
       ELSE 0 END AS DoR_Kierunek
 FROM cdn.DokRelacje WHERE
  (DoR_ParentTyp=@crm AND DoR_DokumentTyp NOT IN (@crm, @obd) AND DoR_ParentId=@id)
 OR  (DoR_ParentTyp=@srs AND DoR_DokumentTyp=@crm  AND DoR_DokumentId=@id)
 ORDER BY DoR_DoRID
END
