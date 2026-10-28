CREATE PROCEDURE CDN.DoRDokumentySekDoEmaila(  @guid varchar(50) )
AS
BEGIN
 IF Substring(@guid, 1, 1) = '{'
  SET @guid = Substring(@guid, 2, LEN(@guid) - 2)
 IF LEN(@guid) <> 36
 BEGIN
  SELECT cdn.DokRelacje.*, 1 As DoR_Kierunek FROM cdn.DokRelacje WHERE 0=1
  GOTO KONIEC
 END
 DECLARE @crm INT, @srs INT, @obd INT
 SET @crm = 700
 SET @obd = 750
 SET @srs = 900
 SELECT cdn.DokRelacje.*, 1 As DoR_Kierunek
    FROM cdn.DokRelacje
    WHERE  DoR_ParentGuid = @guid AND DoR_DokumentTyp IN (750, 751, 752)
KONIEC:
END
