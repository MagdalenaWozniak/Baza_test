CREATE PROCEDURE CDN.EcodAwizoXml
@awizoId  AS INT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE  @trnId INT
 SELECT TOP 1  @trnId = DoR_ParentId FROM cdn.DokRelacje WHERE DoR_DokumentTyp = 380 AND DoR_DokumentId =  @awizoId AND DoR_ParentTyp = 308
 IF @awizoId IS NULL GOTO KONIEC
 CREATE TABLE #EcodAwizoXml (Id INT IDENTITY PRIMARY KEY, Tag nvarchar(50), Wartosc nvarchar(350), Flaga INT)
 exec cdn.EcodAwizoInsert 'Document-DespatchAdvice',  '', -2
 exec cdn.EcodAwizoHeaderXml @trnId, @awizoId
    IF @@Error<>0 GOTO KONIEC
 exec cdn.EcodAwizoInsert 'DespatchAdvice-Consignment',  '', -1
 EXEC CDN.EcodAwizoConsignmentXml @trnId, @awizoId
 exec cdn.EcodAwizoInsert 'DespatchAdvice-Consignment',  '', 1
    IF @@Error<>0 GOTO KONIEC
 exec cdn.EcodAwizoInsert 'Document-DespatchAdvice',  '', 2
 SELECT * FROM #EcodAwizoXml ORDER BY Id
KONIEC:
 SET NOCOUNT OFF;
END
