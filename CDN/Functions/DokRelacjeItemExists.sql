CREATE FUNCTION cdn.DokRelacjeItemExists(
 @dok_typ_1 INT, @dok_id_1 INT, @dok_guid_1 varchar(50),
 @dok_typ_2 INT, @dok_id_2 INT, @dok_guid_2 varchar(50))
RETURNS INT
AS
BEGIN
 DECLARE @result INT
 SET @result = 1
 IF @dok_guid_1 IS NULL SET @dok_guid_1 = '';
 IF Substring(@dok_guid_1, 1, 1) = '{'  SET @dok_guid_1 = Substring(@dok_guid_1, 2, LEN(@dok_guid_1) - 2)
 IF @dok_guid_2 IS NULL SET @dok_guid_2 = '';
 IF Substring(@dok_guid_2, 1, 1) = '{'  SET @dok_guid_2 = Substring(@dok_guid_2, 2, LEN(@dok_guid_2) - 2)
 IF LEN(@dok_guid_1) = 36 AND LEN(@dok_guid_2) = 36
 BEGIN
  IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
      (DoR_ParentGuid = @dok_guid_1) AND (DoR_DokumentGuid = @dok_guid_2)
   OR (DoR_ParentGuid = @dok_guid_2) AND (DoR_DokumentGuid = @dok_guid_1) )
   RETURN 0
 END
 IF LEN(@dok_guid_1) = 36
 BEGIN
  IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE (DoR_ParentGuid = @dok_guid_1) OR (DoR_DokumentGuid = @dok_guid_1) )
   RETURN 0
 END
 IF LEN(@dok_guid_2) = 36
 BEGIN
  IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE (DoR_ParentGuid = @dok_guid_2) OR (DoR_DokumentGuid = @dok_guid_2) )
   RETURN 0
 END
 IF @dok_typ_1 IS NULL RETURN @result
 IF @dok_id_1  IS NULL RETURN @result
 IF @dok_typ_2 IS NULL RETURN @result
 IF @dok_id_2  IS NULL RETURN @result
 IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
    DoR_ParentTyp = @dok_typ_1
   AND DoR_ParentId  = @dok_id_1
   AND DoR_DokumentTyp = @dok_typ_2
   AND DoR_DokumentId  = @dok_id_2)
     IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                    DoR_ParentTyp = @dok_typ_2
                AND DoR_ParentId = @dok_id_2
                AND DoR_DokumentTyp = @dok_typ_1
                AND DoR_DokumentId  = @dok_id_1)
   SET @result = 0
KONIEC:
 RETURN @result
END
