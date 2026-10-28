CREATE PROCEDURE CDN.EcodCatalogueLinesXml
@podmiotTyp         INT,
@podmiotId          INT,
@numerCeny          INT,
@nieaktywne         INT,
@grupaTowarow  INT,
@lineNumber   INT OUTPUT
AS
BEGIN
 SET @lineNumber = 0
 DECLARE
 @TwRId     INT,
 @EAN     nvarchar(20),
 @ItemDescription  nvarchar(512),
 @ItemType    nvarchar(2),
 @UnitOfMeasure   nvarchar(20),
 @UnitNetPrice   DECIMAL(15,2),
 @Discount    DECIMAL(15,2),
 @TaxRate    DECIMAL(5,2),
 @TaxRateDesc   NVARCHAR(10),
 @TaxCategoryCode  NVARCHAR(3),
 @ReferenceNumber  NVARCHAR(20),
 @komunikat    NVARCHAR(255),
 @lineNumberDesc   NVARCHAR(10),
 @totalLines    INT
 DECLARE Lines CURSOR FOR
  SELECT
   Twr_TwrId,
   Twr_EAN,
   LTrim(CDN.EcodUnitOfMeasure(TwR_JM, TwR_TwrId, 1, 0)) As UnitOfMeasure,
   Twr_Stawka,
   CDN.EcodTaxCategoryCode(Twr_Stawka, Twr_Flaga, 0),
   Twr_SWW,
         Twr_Nazwa,
   CASE WHEN Twr_Kaucja = 1 THEN 'RC' ELSE  'CU' END As ItemType
  FROM CDN.Towary
  WHERE Twr_Nazwa <> '' And Twr_Ean <> ''
  AND (@nieaktywne=1 OR  Twr_Nieaktywny = 0)
        AND (@grupaTowarow=-1 OR (Twr_GidNumer IN (SELECT GidNumer FROM CDN.TwrInTwG(@grupaTowarow))))
 exec CDN.EcodCatalogueInsert 'ProductCatalogue-Lines',  N'', -1
  OPEN Lines
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM Lines INTO
       @TwrId,
       @EAN,
       @UnitOfMeasure,
       @TaxRate,
       @TaxCategoryCode,
       @ReferenceNumber,
       @ItemDescription,
       @ItemType
   IF @@FETCH_STATUS <> 0 BREAK
    EXEC CDN.ObliczCenePoRabacie
  @PodmiotTyp = @PodmiotTyp
  ,@PodmiotId = @PodmiotId
  ,@Twr_Id = @TwrId
  ,@Twr_NumerCeny = @numerCeny
  ,@Twr_Stawka = @TaxRate
  ,@cenaPoRabacie = @UnitNetPrice OUTPUT
  ,@wartoscRabatu = @Discount OUTPUT
  ,@komunikat  = @komunikat OUTPUT
   SET @TaxRateDesc = CONVERT(NVARCHAR(10), @TaxRate)
   SET @lineNumber = @lineNumber + 1
   SET @lineNumberDesc = STR(@lineNumber)
   exec CDN.EcodCatalogueInsert 'Line',  N'', -1
    exec CDN.EcodCatalogueInsert 'Line-Item', N'', -1
     exec CDN.EcodCatalogueInsert 'LineNumber',  @lineNumberDesc, 0
     exec CDN.EcodCatalogueInsert 'LineType',  N'1', 0
     exec CDN.EcodCatalogueInsert 'EAN',    @EAN, 0
     exec CDN.EcodCatalogueInsert 'ItemDescription', @ItemDescription, 11
     exec CDN.EcodCatalogueInsert 'ItemType',  @ItemType, 0
     exec CDN.EcodCatalogueInsert 'UnitOfMeasure', @UnitOfMeasure, 0
     exec CDN.EcodCatalogueInsert 'UnitNetPrice', @UnitNetPrice, 0
     exec CDN.EcodCatalogueInsert 'Discount',  @Discount, 0
     exec CDN.EcodCatalogueInsert 'TaxRate', @TaxRateDesc, 0
     exec CDN.EcodCatalogueInsert 'TaxCategoryCode',  @TaxCategoryCode, 0
     exec CDN.EcodCatalogueInsert 'TaxReference',  N'', -1
      exec CDN.EcodCatalogueInsert 'ReferenceType',  N'PKWIU', 0
      exec CDN.EcodCatalogueInsert 'ReferenceNumber',  @ReferenceNumber, 0
     exec CDN.EcodCatalogueInsert 'TaxReference',  N'', 1
    exec CDN.EcodCatalogueInsert 'Line-Item', N'', 1
   exec CDN.EcodCatalogueInsert 'Line', N'', 1
  END
  CLOSE Lines
  DEALLOCATE Lines
 exec CDN.EcodCatalogueInsert 'ProductCatalogue-Lines',  N'', 1
END
