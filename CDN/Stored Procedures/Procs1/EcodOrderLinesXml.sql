CREATE PROCEDURE CDN.EcodOrderLinesXml
@TrnID            AS INT
AS
BEGIN
 DECLARE
 @LineNumber    nvarchar(20),
 @EAN     nvarchar(20),
 @BuyerItemCode   nvarchar(35),
 @SupplierItemCode  nvarchar(35),
 @ItemDescription  nvarchar(70),
 @ItemType    nvarchar(2),
 @UnitOfMeasure   nvarchar(20),
 @OrderedUnitPacksize nvarchar(20),
 @PackItemUnitOfMeasure nvarchar(20),
 @OrderedQuantity  nvarchar(20),
 @OrderedUnitNetPrice nvarchar(20),
 @Remarks    nvarchar(350)
 DECLARE fakturaLines CURSOR FOR
  SELECT
  LTrim(Str(faElem.TrE_Lp,15))  As LineNumber,
  LTrim(Cast(faElem.TrE_TwrEan  As nvarchar(20))) As EAN,
  Substring(IsNull((Select TOP 1 IsNull(TkA_WartoscTxt, '')
   From CDN.TwrKntAtrybuty
   Join CDN.TwrAtrybuty ON TkA_TwAId=TwA_TwAId
   Join CDN.DefAtrybuty ON TwA_DeAId=DeA_DeAId
   Where DeA_Kod = 'BUYERITEMCODE' And TwA_TwrId = faElem.TrE_TwrId
   And TkA_PodmiotTyp = faElem.TrE_PodmiotTyp
   And TkA_PodmiotId = faElem.TrE_PodId), ''),1,35) As BuyerItemCode,
  SUBSTRING(faElem.TrE_TwrKod,1,35)   As SupplierItemCode,
  CAST(faElem.TrE_TwrNazwa aS nvarchar(70)) As ItemDescription,
  CASE WHEN faElem.TrE_Kaucja = 1 THEN 'RC' ELSE 'CU' END As ItemType,
  LTrim(Str(faElem.TrE_IloscJM,15,3)) As OrderedQuantity,
  LTrim(cdn.EcodUnitOfMeasure(faElem.TrE_JM, faElem.TrE_TrEId, 1, 0)) As UnitOfMeasure,
  LTrim(Str(CDN.InvoiceUnitPacksize(faElem.TrE_TrEId),15,3)) As OrderedUnitPacksize,
  LTrim(Str(cdn.Round2(faElem.TrE_CenaT),15,2))  As OrderedUnitNetPrice,
  CAST(TrE_TwrOpis AS NVARCHAR(350)) As Remarks
  From cdn.TraElem faElem
  Where faElem.TrE_TrnId=@TrnID
  ORDER BY faElem.TrE_Lp
 exec cdn.EcodOrderInsert 'Order-Lines',  '', -1
  OPEN fakturaLines
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM fakturaLines INTO @LineNumber,
            @EAN,
            @BuyerItemCode,
            @SupplierItemCode,
            @ItemDescription,
            @ItemType,
            @OrderedQuantity,
            @UnitOfMeasure,
            @OrderedUnitPacksize,
            @OrderedUnitNetPrice,
            @Remarks
   IF @@FETCH_STATUS <> 0 BREAK
    exec cdn.EcodOrderInsert 'Line',  '', -1
    exec cdn.EcodOrderInsert 'Line-Item', '', -1
     exec cdn.EcodOrderInsert 'LineNumber',  @LineNumber, 0
     exec cdn.EcodOrderInsert 'EAN',    @EAN, 0
     exec cdn.EcodOrderInsert 'BuyerItemCode', @BuyerItemCode, 0
     exec cdn.EcodOrderInsert 'SupplierItemCode',@SupplierItemCode, 0
     exec cdn.EcodOrderInsert 'ItemDescription', @ItemDescription, 11
     exec cdn.EcodOrderInsert 'ItemType',  @ItemType, 0
     exec cdn.EcodOrderInsert 'OrderedQuantity', @OrderedQuantity, 0
     exec cdn.EcodOrderInsert 'OrderedUnitPacksize', @OrderedUnitPacksize, 0
     exec cdn.EcodOrderInsert 'UnitOfMeasure',  @UnitOfMeasure, 0
     exec cdn.EcodOrderInsert 'OrderedUnitNetPrice', @OrderedUnitNetPrice, 0
     exec cdn.EcodOrderInsert 'Remarks',   @Remarks, 11
    exec cdn.EcodOrderInsert 'Line-Item', '', 1
   exec cdn.EcodOrderInsert 'Line', '', 1
  END
  CLOSE fakturaLines
  DEALLOCATE fakturaLines
 exec cdn.EcodOrderInsert 'Order-Lines',  '', 1
END
