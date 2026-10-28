CREATE PROCEDURE CDN.SrsZapiszRelacje
@SrZId AS INT,
@TrNId AS INT,
@TypDokumentu AS INT,
@flaga AS INT = 0
AS
BEGIN
 SET NOCOUNT ON;
    BEGIN TRAN;
  IF NOT EXISTS( SELECT * FROM CDN.SrsZlecenia WHERE SrZ_SrZId = @SrZId )
            GOTO KONIEC
  IF @TypDokumentu = 906  -- zlecenia cykliczne
  BEGIN
   IF NOT EXISTS( SELECT * FROM CDN.SrsCyklNag WHERE SrW_SrwId = @TrNId ) GOTO KONIEC
  END
  IF @TypDokumentu = 700  -- crm
  BEGIN
   IF NOT EXISTS( SELECT * FROM CDN.CrmKontakty WHERE CrK_CrKId = @TrNId ) GOTO KONIEC
  END
  IF @TypDokumentu > 299 AND @TypDokumentu < 400
  BEGIN
   IF NOT EXISTS( SELECT * FROM CDN.TraNag WHERE TrN_TypDokumentu = @TypDokumentu AND TrN_TrNId = @TrNId )  GOTO KONIEC
  END
        IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                        DoR_ParentTyp = 900
                    AND DoR_ParentId = @SrZId
                    AND DoR_DokumentTyp = @TypDokumentu
                    AND DoR_DokumentId  = @TrNId)
         IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                        DoR_ParentTyp = @TypDokumentu
                    AND DoR_ParentId = @TrNId
                    AND DoR_DokumentTyp = 900
                    AND DoR_DokumentId  = @SrZId)
    INSERT INTO [CDN].[DokRelacje](
     [DoR_ParentTyp],
     [DoR_ParentId],
     [DoR_DokumentTyp],
     [DoR_DokumentId],
     [DoR_Flaga])
    VALUES(
     900,
     @SrZId,
     @TypDokumentu,
     @TrNId,
     @flaga )
KONIEC:
    IF @@TRANCOUNT <> 0
    BEGIN
  IF @@ERROR = 0
  BEGIN
   COMMIT TRAN
   UPDATE cdn.SrsZlecenia SET SrZ_Stan = cdn.SrsZlecenieUstalStan(@SrZId),
          SrZ_DokStatus = cdn.SrsZlecenieStatus(@SrZId)
   WHERE cdn.SrsZlecenia.SrZ_SrZId = @SrZId
  END
  ELSE
   ROLLBACK TRAN
 END
 SET NOCOUNT OFF;
 SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
END
