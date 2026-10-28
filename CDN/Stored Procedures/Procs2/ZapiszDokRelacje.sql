CREATE PROCEDURE CDN.ZapiszDokRelacje
@ParentTyp AS INT,
@ParentId AS INT,
@DokumentTyp AS INT,
@DokumentId AS INT
AS
BEGIN
 exec CDN.ZapiszDokRelacjeCore @ParentTyp, @ParentId, @DokumentTyp, @DokumentId, 0
END
