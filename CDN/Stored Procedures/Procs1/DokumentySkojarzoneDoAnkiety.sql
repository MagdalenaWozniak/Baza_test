CREATE PROCEDURE CDN.DokumentySkojarzoneDoAnkiety( @id INT )
AS
BEGIN
 DECLARE @crm INT, @srs INT, @obd INT, @ank INT, @wzorzecAnk INT, @emailP INT, @emailW INT, @sms INT, @archW INT
 SET @crm = 700
 SET @ank = 710
 SET @obd = 750
 SET @archW = 752
 SET @srs = 900
 SET @emailP = 1010
 SET @emailW = 1011
 SET @sms = 1020
    SET @wzorzecAnk = 714
 SELECT cdn.DokRelacje.*,CASE WHEN DoR_DokumentTyp=@ank AND DoR_DokumentId=@id THEN 1 ELSE 0 END AS DoR_Kierunek
 FROM cdn.DokRelacje
 WHERE DoR_ParentTyp NOT IN (@crm, @obd, @archW, @emailP, @emailW, @sms) AND DoR_DokumentTyp NOT IN (@crm, @obd, @archW, @emailP, @emailW, @sms)
 AND ((DoR_ParentTyp=@ank AND DoR_ParentId=@id) OR  (DoR_DokumentTyp=@ank AND DoR_DokumentId=@id))
 ORDER BY DoR_DoRID
END
