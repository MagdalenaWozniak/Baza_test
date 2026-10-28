CREATE PROCEDURE CDN.SrsCyklZapiszRelacje
@wzorzecId AS INT,
@zlecenieId AS INT,
@flaga AS INT = 0
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS( SELECT * FROM CDN.SrsZlecenia WHERE SrZ_SrZId = @zlecenieId )  GOTO KONIEC
  IF NOT EXISTS( SELECT * FROM CDN.SrsCyklNag WHERE SrW_SrwId = @wzorzecId ) GOTO KONIEC
  DECLARE @wzorzecTyp INT, @zlecenieTyp INT
  SET @zlecenieTyp = 900
  SET @wzorzecTyp = 906
        IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                        DoR_ParentTyp = @wzorzecTyp
                    AND DoR_ParentId = @wzorzecId
                    AND DoR_DokumentTyp = @zlecenieTyp
                    AND DoR_DokumentId  = @zlecenieId)
         IF NOT EXISTS( SELECT * FROM CDN.DokRelacje WHERE
                        DoR_ParentTyp = @zlecenieTyp
                    AND DoR_ParentId = @zlecenieId
                    AND DoR_DokumentTyp = @wzorzecTyp
                    AND DoR_DokumentId  = @wzorzecId)
    INSERT INTO [CDN].[DokRelacje](
     [DoR_ParentTyp],
     [DoR_ParentId],
     [DoR_DokumentTyp],
     [DoR_DokumentId],
     [DoR_Flaga])
    VALUES(
     @wzorzecTyp,
     @wzorzecId,
     @zlecenieTyp,
     @zlecenieId,
     @flaga )
KONIEC:
 SET NOCOUNT OFF;
END
