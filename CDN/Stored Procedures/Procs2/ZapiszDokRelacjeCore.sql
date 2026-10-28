CREATE PROCEDURE CDN.ZapiszDokRelacjeCore
@ParentTyp AS INT,
@ParentId AS INT,
@DokumentTyp AS INT,
@DokumentId AS INT,
@Flaga AS INT = 0
AS
BEGIN
 SET NOCOUNT ON;
    BEGIN TRAN;
  IF @DokumentTyp = 900  -- serwis
   IF NOT EXISTS( SELECT * FROM CDN.SrsZlecenia WHERE SrZ_SrZId = @DokumentId )
   BEGIN
    GOTO KONIEC
   END
  ELSE
  IF @DokumentTyp = 700  -- crm
   BEGIN
   IF NOT EXISTS( SELECT * FROM CDN.CrmKontakty WHERE CrK_CrKId = @DokumentId )
    GOTO KONIEC
   END
  ELSE
  IF @DokumentTyp = 714  -- wzorzec ankiety
   BEGIN
   IF NOT EXISTS( SELECT * FROM CDN.AnkWzorzecAnkietyNag WHERE AnkWaN_AnkWaNId = @DokumentId )
    GOTO KONIEC
   END
  ELSE
   BEGIN
   IF NOT EXISTS( SELECT * FROM CDN.TraNag WHERE TrN_TypDokumentu = @DokumentTyp AND TrN_TrNId = @DokumentId )
    GOTO KONIEC
   END
        IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                        DoR_ParentTyp = @ParentTyp
                    AND DoR_ParentId = @ParentId
                    AND DoR_DokumentTyp = @DokumentTyp
                    AND DoR_DokumentId  = @DokumentId)
         IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                        DoR_ParentTyp = @DokumentTyp
                    AND DoR_ParentId = @DokumentId
                    AND DoR_DokumentTyp = @ParentTyp
                    AND DoR_DokumentId  = @ParentId)
    INSERT INTO [CDN].[DokRelacje](
     [DoR_ParentTyp],
     [DoR_ParentId],
     [DoR_DokumentTyp],
     [DoR_DokumentId],
     [DoR_Flaga])
    VALUES(
     @ParentTyp,
     @ParentId,
     @DokumentTyp,
     @DokumentId,
     @Flaga )
KONIEC:
    IF @@TRANCOUNT <> 0
    BEGIN
  IF @@ERROR = 0
   COMMIT TRAN
  ELSE
   ROLLBACK TRAN
 END
 SET NOCOUNT OFF;
 SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
END
