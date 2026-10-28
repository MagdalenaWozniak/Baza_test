CREATE PROCEDURE CDN.DoRListaSkojarzonych( @mode INT, @klasa INT, @id INT)
AS
BEGIN
 IF @mode = 0
 BEGIN
  SELECT cdn.DokRelacje.*, 0 AS DoR_Kierunek FROM cdn.DokRelacje WHERE DoR_ParentTyp=@klasa AND DoR_ParentId=@id
 END
 ELSE
 BEGIN
  SELECT cdn.DokRelacje.*,
  CASE
   WHEN (DoR_ParentTyp=@klasa AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id) THEN 1
   ELSE 0
  END AS DoR_Kierunek
  FROM cdn.DokRelacje
  WHERE (DoR_ParentTyp=@klasa AND DoR_ParentId=@id)
   OR (DoR_ParentTyp=@klasa AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id)
 END
END
