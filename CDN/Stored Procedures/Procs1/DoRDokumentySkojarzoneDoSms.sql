CREATE PROCEDURE CDN.DoRDokumentySkojarzoneDoSms( @guid varchar(50) )
AS
BEGIN
 IF Substring(@guid, 1, 1) = '{'
  SET @guid = Substring(@guid, 2, LEN(@guid) - 2)
 IF LEN(@guid) <> 36
 BEGIN
  SELECT cdn.DokRelacje.*, 0 As DoR_Kierunek FROM cdn.DokRelacje WHERE 0=1
  GOTO KONIEC
 END
 DECLARE @crm INT, @srs INT, @obd INT, @mailIn INT, @mailOut INT
 SET @crm = 700
 SET @obd = 750
 SET @srs = 900
 SET @mailIn = 1010
 SET @mailOut = 1011
 SELECT cdn.DokRelacje.*, 0 As DoR_Kierunek
 FROM cdn.DokRelacje WHERE DoR_ParentGuid = @guid AND DoR_DokumentTyp > 0 AND  DoR_DokumentTyp NOT IN (@crm, @obd, @mailIn, @mailOut)
 ORDER BY DoR_DoRID
KONIEC:
END
