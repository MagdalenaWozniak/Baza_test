CREATE PROCEDURE CDN.FaCyklZapiszRelacje
@FaCyklId AS INT,
@TrNId AS INT,
@TypDokumentu AS INT,
@flaga AS INT = 0
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS( SELECT * FROM CDN.FaCyklNag WHERE FcN_FcNId = @FaCyklId )  GOTO KONIEC
  IF @TypDokumentu < 300 OR @TypDokumentu > 399  GOTO KONIEC
  IF @TypDokumentu > 299 AND @TypDokumentu < 400
  BEGIN
   IF NOT EXISTS( SELECT * FROM CDN.TraNag WHERE TrN_TypDokumentu = @TypDokumentu AND TrN_TrNId = @TrNId ) GOTO KONIEC
  END
  DECLARE @faCyklTyp INT
  SET @faCyklTyp = 702
        IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                        DoR_ParentTyp = @faCyklTyp
                    AND DoR_ParentId = @FaCyklId
                    AND DoR_DokumentTyp = @TypDokumentu
                    AND DoR_DokumentId  = @TrNId)
         IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                        DoR_ParentTyp = @TypDokumentu
                    AND DoR_ParentId = @TrNId
                    AND DoR_DokumentTyp = @faCyklTyp
                    AND DoR_DokumentId  = @FaCyklId)
    INSERT INTO [CDN].[DokRelacje](
     [DoR_ParentTyp],
     [DoR_ParentId],
     [DoR_DokumentTyp],
     [DoR_DokumentId],
     [DoR_Flaga])
    VALUES(
     @faCyklTyp,
     @FaCyklId,
     @TypDokumentu,
     @TrNId,
     @flaga)
KONIEC:
  SET NOCOUNT OFF;
END
