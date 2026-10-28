CREATE PROCEDURE CDN.EcodOrderXml
@TrnID            AS INT
AS
BEGIN
 SET NOCOUNT ON;
 CREATE TABLE #EcodOrderXml (Id INT IDENTITY PRIMARY KEY, Tag nvarchar(50), Wartosc nvarchar(350), Flaga INT)
 exec cdn.EcodOrderInsert 'Document-Order',  '', -2
 exec cdn.EcodOrderHeaderXml @TrnID
    IF @@Error<>0 GOTO KONIEC
 EXEC CDN.EcodOrderLinesXml @TrnID
    IF @@Error<>0 GOTO KONIEC
 EXEC CDN.EcodOrderSummary @TrnID
    IF @@Error<>0 GOTO KONIEC
 exec cdn.EcodOrderInsert 'Document-Order',  '', 2
 SELECT * FROM #EcodOrderXml ORDER BY Id
KONIEC:
 SET NOCOUNT OFF;
END
