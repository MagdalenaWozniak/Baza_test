CREATE PROCEDURE CDN.DoRDokumentyCRM( @klasa INT, @id INT )
AS
BEGIN
 DECLARE @crm INT, @srs INT, @obd INT
 SET @crm = 700
 SET @obd = 750
 SET @srs = 900
 IF @klasa = @crm
 BEGIN
  SELECT cdn.DokRelacje.*,CASE WHEN (DoR_ParentTyp=@klasa AND DoR_DokumentTyp=@klasa AND DoR_ParentId=@id) THEN 1
        ELSE 0 END AS DoR_Kierunek
  FROM cdn.DokRelacje WHERE
      (DoR_ParentTyp=@crm AND DoR_DokumentTyp=@crm)
      AND( (DoR_DokumentId=@id) OR (DoR_ParentId=@id AND DoR_DokumentId<>@id) )
          OR  (DoR_ParentTyp IN (1010, 1011, 1020) AND DoR_DokumentTyp=@crm AND DoR_DokumentId=@id)
  ORDER BY DoR_DoRID
 END
 ELSE
 IF @klasa = @obd
 BEGIN
  SELECT cdn.DokRelacje.*,CASE WHEN (DoR_ParentTyp=@klasa) THEN 1
        ELSE 0 END AS DoR_Kierunek
  FROM cdn.DokRelacje WHERE
   (DoR_ParentTyp=@obd AND DoR_DokumentTyp=@crm AND DoR_ParentId=@id)
  OR  (DoR_ParentTyp IN (700, 1010, 1011, 1020) AND DoR_DokumentTyp=@obd AND DoR_DokumentId=@id)
  ORDER BY DoR_DoRID
 END
 ELSE
 IF @klasa = @srs
 BEGIN
  SELECT cdn.DokRelacje.*,CASE WHEN (DoR_ParentTyp=@klasa) THEN 1
        ELSE 0 END AS DoR_Kierunek
  FROM cdn.DokRelacje WHERE
   (DoR_ParentTyp=@srs AND DoR_DokumentTyp=@crm AND DoR_ParentId=@id)
  OR  (DoR_ParentTyp IN (700, 1010, 1011, 1020) AND DoR_DokumentTyp=@srs AND DoR_DokumentId=@id)
  ORDER BY DoR_DoRID
 END
 ELSE
 BEGIN
  SELECT cdn.DokRelacje.*,0 AS DoR_Kierunek
  FROM cdn.DokRelacje
  WHERE (DoR_ParentTyp IN (700, 1010, 1011, 1020)  AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id)
  ORDER BY DoR_DoRID
    END
END
