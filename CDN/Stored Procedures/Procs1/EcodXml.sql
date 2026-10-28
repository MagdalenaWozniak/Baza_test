CREATE PROCEDURE CDN.EcodXml
@TrnID            AS INT
AS
BEGIN
 SET NOCOUNT ON;
 CREATE TABLE #EcodXml (Id INT IDENTITY PRIMARY KEY, Tag nvarchar(50), Wartosc nvarchar(1050), Flaga INT)
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Document-Invoice',  '', -2)
 EXEC CDN.EcodInvoiceHeaderXml @TrnID, 0, 0
    IF @@Error<>0 GOTO KONIEC
 EXEC CDN.EcodInvoiceLinesXml @TrnID, 0
    IF @@Error<>0 GOTO KONIEC
 EXEC CDN.EcodInvoiceSummaryXml @TrnID
    IF @@Error<>0 GOTO KONIEC
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Document-Invoice',  '', 2)
 SELECT * FROM #EcodXml ORDER BY Id
KONIEC:
 SET NOCOUNT OFF;
END
