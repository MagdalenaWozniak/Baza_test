CREATE PROCEDURE CDN.ZapiszDokRelacjeAuto
@ParentTyp AS INT,
@ParentId AS INT,
@DokumentTyp AS INT,
@DokumentId AS INT
AS
BEGIN
 exec CDN.ZapiszDokRelacjeCore @ParentTyp, @ParentId, @DokumentTyp, @DokumentId, 255
END
