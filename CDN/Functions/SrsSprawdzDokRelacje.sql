CREATE FUNCTION CDN.SrsSprawdzDokRelacje (
 @SrsZlecenieId Int, @TypDokumentu Int, @TypDokumentu2 Int )
  RETURNS    NVARCHAR(30)
  AS
  BEGIN
  DECLARE @wynik NVARCHAR(30), @autoItem INT
  SET @autoItem = 255
  SET @wynik = ''
  IF @TypDokumentu = 0
  BEGIN
 SELECT TOP 1 @wynik = Str(IsNull(DoR_DokumentId, 0))
 FROM cdn.DokRelacje
 WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId AND DoR_Flaga = @autoItem
  END
  ELSE
  BEGIN
    IF @TypDokumentu = 700  -- e_OP_KlasaCRM
  SELECT TOP 1 @wynik = IsNull(CrK_NumerPelny,'') FROM cdn.CrmKontakty
  JOIN cdn.DokRelacje ON CrK_CrKId = DoR_DokumentId AND DoR_DokumentTyp = 700 AND DoR_Flaga = @autoItem
  WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId
    ELSE
    BEGIN
     IF @TypDokumentu2 != 0
   SELECT @wynik = IsNull(TrN_NumerPelny,'') FROM  cdn.TraNag
   JOIN cdn.DokRelacje ON TrN_TrNId = DoR_DokumentId AND TrN_TypDokumentu = DoR_DokumentTyp AND DoR_Flaga = @autoItem
   WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId
   AND (TrN_TypDokumentu = @TypDokumentu OR TrN_TypDokumentu = @TypDokumentu2) AND TrN_Bufor <> -1
     ELSE
   SELECT @wynik = IsNull(TrN_NumerPelny,'') FROM  cdn.TraNag
   JOIN cdn.DokRelacje ON TrN_TrNId = DoR_DokumentId AND TrN_TypDokumentu = DoR_DokumentTyp AND DoR_Flaga = @autoItem
   WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId
   AND TrN_TypDokumentu = @TypDokumentu  AND TrN_Bufor <> -1
 END
  END
KONIEC:
    RETURN  @wynik
  END
