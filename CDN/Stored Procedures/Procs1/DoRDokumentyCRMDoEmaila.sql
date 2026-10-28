CREATE PROCEDURE CDN.DoRDokumentyCRMDoEmaila(  @guid varchar(50) )
AS
BEGIN
 IF Substring(@guid, 1, 1) = '{'
  SET @guid = Substring(@guid, 2, LEN(@guid) - 2)
 IF LEN(@guid) <> 36
 BEGIN
  SELECT cdn.DokRelacje.*, 1 As DoR_Kierunek FROM cdn.DokRelacje WHERE 0=1
  GOTO KONIEC
 END
 DECLARE @crm INT, @srs INT, @obd INT, @mailIn INT, @mailOut INT,@sms INT
 SET @crm = 700
 SET @obd = 750
 SET @srs = 900
 SET @mailIn = 1010
 SET @mailOut = 1011
    SET @sms = 1020
    SELECT cdn.DokRelacje.*, CASE WHEN (DoR_DokumentGuid = @guid AND DoR_ParentTyp = @sms) THEN 0 ELSE 1 END As DoR_Kierunek
    FROM cdn.DokRelacje
    WHERE (DoR_ParentGuid = @guid AND DoR_DokumentTyp IN (@crm, @sms))
  OR (DoR_DokumentGuid = @guid AND DoR_ParentTyp = @sms)
    ORDER BY DoR_DoRID
KONIEC:
END
