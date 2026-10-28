CREATE PROCEDURE CDN.eFakturaXml
@TrnID            AS INT,
@duplikat         AS INT,
@BazId        AS INT
AS
BEGIN
 SET NOCOUNT ON;
 CREATE TABLE #EcodXml (Id INT IDENTITY PRIMARY KEY, Tag NVARCHAR(50), Wartosc NVARCHAR(350), Flaga INT)
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Document',  '', -2)
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice',  '', -1)
 EXEC CDN.EcodInvoiceHeaderXml @TrnID, 1, @duplikat
    IF @@Error<>0 GOTO KONIEC
 EXEC CDN.EcodInvoiceLinesXml @TrnID, 1
    IF @@Error<>0 GOTO KONIEC
 EXEC CDN.EcodInvoiceSummaryXml @TrnID
    IF @@Error<>0 GOTO KONIEC
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice',  '', 1)
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Document',  '', 2)
 SELECT * FROM #EcodXml ORDER BY Id
KONIEC:
 SET NOCOUNT OFF;
END
