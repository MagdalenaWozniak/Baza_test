CREATE PROCEDURE CDN.SrsCyklZapiszRelacjeAuto
@wzorzecId AS INT,
@zlecenieId AS INT
AS
BEGIN
 exec CDN.SrsCyklZapiszRelacje @wzorzecId, @zlecenieId, 255
END
