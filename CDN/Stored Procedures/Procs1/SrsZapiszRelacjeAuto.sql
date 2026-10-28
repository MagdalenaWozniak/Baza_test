CREATE PROCEDURE CDN.SrsZapiszRelacjeAuto
@SrZId AS INT,
@TrNId AS INT,
@TypDokumentu AS INT
AS
BEGIN
 exec CDN.SrsZapiszRelacje @SrZId, @TrNId, @TypDokumentu, 255
END
