CREATE PROCEDURE CDN.EcodCatalogueXml
@podmiotTyp         INT,
@podmiotId          INT,
@numerCeny          INT,
@nieaktywne         INT,
@grupaTowarow  INT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @buyerILN NVARCHAR(15), @buyerName NVARCHAR(175),
   @sellerILN NVARCHAR(15), @sellerName NVARCHAR(175),
   @data NVARCHAR(10), @nrceny NVARCHAR(10), @totalLinesDesc NVARCHAR(10), @totalLines INT
 SELECT @sellerILN = IsNull((Select top 1 Fir_Wartosc From CDN.Firma Where fir_numer=1165), '')
 SELECT @sellerName = Cast(IsNull((Select Fir_Wartosc From cdn.firma Where fir_numer=1156), '') + ' ' + IsNull((Select Fir_Wartosc From cdn.firma Where fir_numer=1157), '') As nvarchar(175))
 SELECT @buyerILN  = IsNull(Knt_GLN,''), @buyerName = Cast(KnT_Nazwa1 + ' ' + KnT_Nazwa2  + ' ' + KnT_Nazwa3 As nvarchar(175))  FROM CDN.Kontrahenci Where Knt_PodmiotTyp=@podmiotTyp And Knt_KntId = @podmiotId
 SET @data = CONVERT(VARCHAR(10), GETDATE(), 120)
 SET @nrceny = STR(@numerCeny)
 CREATE TABLE #EcodCatalogueXmlTable (Id INT IDENTITY PRIMARY KEY, Tag varchar(50), Wartosc nvarchar(350), Flaga INT)
 exec CDN.EcodCatalogueInsert 'Document-ProductCatalogue', N'', -2
  exec CDN.EcodCatalogueInsert 'ProductCatalogue-Header', N'', -1
   exec CDN.EcodCatalogueInsert 'ProductCatalogueNumber', @nrceny, 0
   exec CDN.EcodCatalogueInsert 'ProductCatalogueDate', @data,  0
  exec CDN.EcodCatalogueInsert 'ProductCatalogue-Header', N'', 1
  exec CDN.EcodCatalogueInsert 'ProductCatalogue-Parties', N'', -1
   exec CDN.EcodCatalogueInsert 'Buyer', N'', -1
    exec CDN.EcodCatalogueInsert 'ILN', @buyerILN, 0
    exec CDN.EcodCatalogueInsert 'Name', @buyerName, 0
   exec CDN.EcodCatalogueInsert 'Buyer', N'',  1
   exec CDN.EcodCatalogueInsert 'Seller', N'', -1
    exec CDN.EcodCatalogueInsert 'ILN', @sellerILN, 0
    exec CDN.EcodCatalogueInsert 'Name', @sellerName, 0
   exec CDN.EcodCatalogueInsert 'Seller', N'',  1
  exec CDN.EcodCatalogueInsert 'ProductCatalogue-Parties', N'',  1
  EXEC CDN.EcodCatalogueLinesXml @podmiotTyp, @podmiotId, @numerCeny, @nieaktywne, @grupaTowarow, @totalLines OUTPUT
     IF @@Error<>0 GOTO KONIEC
  SET @totalLinesDesc = STR(@totalLines)
  exec CDN.EcodCatalogueInsert 'ProductCatalogue-Summary', N'', -1
   exec CDN.EcodCatalogueInsert  'TotalLines', @totalLinesDesc, 0
  exec CDN.EcodCatalogueInsert 'ProductCatalogue-Summary', N'', 1
 exec CDN.EcodCatalogueInsert 'Document-ProductCatalogue', N'', 2
 SELECT * FROM #EcodCatalogueXmlTable ORDER BY Id
KONIEC:
 SET NOCOUNT OFF;
END
