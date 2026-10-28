CREATE PROCEDURE CDN.FaCyklZapiszRelacjeAuto
@FaCyklId AS INT,
@TrNId AS INT,
@TypDokumentu AS INT
AS
BEGIN
 EXEC CDN.FaCyklZapiszRelacje @FaCyklId, @TrNId, @TypDokumentu, 255
END
