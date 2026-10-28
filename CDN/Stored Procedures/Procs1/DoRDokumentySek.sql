CREATE PROCEDURE CDN.DoRDokumentySek( @klasa INT, @id INT )
AS
BEGIN
 DECLARE @obd INT, @crm INT, @archiwumWydrukow INT
 SET @crm = 700
 SET @obd = 750
 SET @archiwumWydrukow = 752
 IF @klasa = @crm  -- dla CRM relacja może być dwustronna
 BEGIN
  SELECT cdn.DokRelacje.*,
  CASE WHEN (DoR_ParentTyp=@klasa AND DoR_ParentId=@id) THEN 1 ELSE 0 END AS DoR_Kierunek
  FROM cdn.DokRelacje
  WHERE  (DoR_ParentTyp IN (750, 751, 752) AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id)
  OR (DoR_ParentTyp = @crm AND DoR_ParentId = @id AND DoR_DokumentTyp=@obd)
 END
 ELSE
 IF @klasa = 999
 BEGIN
  SELECT cdn.DokRelacje.*,
  CASE
   WHEN (DoR_ParentTyp=@klasa AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id) THEN 1
   ELSE 0
  END AS DoR_Kierunek
  FROM cdn.DokRelacje
  WHERE (DoR_ParentTyp IN (750, 751, 752) AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id)
  OR ( DoR_ParentTyp = @archiwumWydrukow AND DoR_DokumentId IN (SELECT TrN_TrNId FROM cdn.TraNag where TrN_TypDokumentu=DoR_DokumentTyp AND TrN_VaNId = @id))
 END
 ELSE
 IF @klasa = @obd
 BEGIN
  SELECT cdn.DokRelacje.*,CASE WHEN (DoR_ParentTyp=@klasa AND DoR_DokumentTyp=@klasa AND DoR_ParentId=@id) THEN 1
        ELSE 0 END AS DoR_Kierunek
  FROM cdn.DokRelacje WHERE
        DoR_ParentTyp IN (750, 751, 752)
    AND DoR_DokumentTyp IN (750, 751, 752)
    AND (DoR_ParentId=@id OR DoR_DokumentId=@id)
  ORDER BY DoR_DoRID
 END
 ELSE
 BEGIN
  SELECT cdn.DokRelacje.*,
  CASE
   WHEN (DoR_ParentTyp=@klasa AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id) THEN 1
   ELSE 0
  END AS DoR_Kierunek
  FROM cdn.DokRelacje
  WHERE DoR_ParentTyp IN (750, 751, 752) AND DoR_DokumentTyp=@klasa AND DoR_DokumentId=@id
 END
END
