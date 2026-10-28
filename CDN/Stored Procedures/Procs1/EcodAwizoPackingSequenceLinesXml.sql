CREATE PROCEDURE CDN.EcodAwizoPackingSequenceLinesXml
@awizoId         AS INT,
@packageId       AS INT,
@buyerTyp   AS INT,
@buyerId      AS INT,
@lineNumber   AS INT OUTPUT
AS
BEGIN
   --LTrim(Str(faElem.TrE_Lp,15))  As LineNumber,
    DECLARE @TrEID INT,
   @lineNumberStr  VARCHAR(6), @EAN VARCHAR(14), @BuyerItemCode NVARCHAR(35), @QuantityDespatched VARCHAR(20), @UnitOfMeasure VARCHAR(3),
   @ItemDescription NVARCHAR(70), @BuyerOrderNumber NVARCHAR(35), @BuyerOrderDate VARCHAR(10),
   @UltimateCustomerILN VARCHAR(13), @UltimateCustomerName NVARCHAR(175)
 DECLARE packingLineSequenceCursor CURSOR FOR
 SELECT AWO_TrEID,
     QuantityDespatched = LTRIM(STR(AWO_TwrIlosc,15,3))
 FROM [CDN].[AwizoOpakowania]
 WHERE AWO_AWZId = @awizoId AND AWO_ParentId = @packageId AND AWO_OpakowanieId = -1
 OPEN packingLineSequenceCursor
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM packingLineSequenceCursor INTO @TrEID, @QuantityDespatched
  IF @@FETCH_STATUS <> 0 BREAK
  SELECT
  @EAN = AWT_TwrEAN,
  @BuyerItemCode = cdn.EcodElemBuyerItemCode(AWT_TrEId, AWT_TwrId, @buyerTyp, @buyerId),
  @UnitOfMeasure = LTRIM(cdn.EcodUnitOfMeasure(AWT_JM, 0, 0, 0)),
  @ItemDescription = AWT_TwrNazwa,
  @BuyerOrderNumber = AWT_NrZamowienia,
  @BuyerOrderDate = Convert(nvarchar(10), AWT_DataZamowienia, 120),
  @UltimateCustomerILN = AWT_NrOdbiorca
  FROM [CDN].[AwizoTowary] WHERE AWT_TrEId = @TrEID
  SET @UltimateCustomerName = ''
  SELECT TOP 1 @UltimateCustomerName = CAST(KnT_Nazwa1 + ' ' + KnT_Nazwa2  + ' ' + KnT_Nazwa3 As NVARCHAR(175)) FROM cdn.Kontrahenci WHERE Knt_GLN = @UltimateCustomerILN
  SET @lineNumber = @lineNumber + 1
  SET @lineNumberStr = LTRIM(Str(@lineNumber))
  exec cdn.EcodAwizoInsert 'Line',  '', -1
   exec cdn.EcodAwizoInsert 'Line-Item',  '', -1
    exec cdn.EcodAwizoInsert 'LineNumber', @lineNumberStr, 0
    exec cdn.EcodAwizoInsert 'EAN', @EAN, 0
    exec cdn.EcodAwizoInsert 'BuyerItemCode', @BuyerItemCode, 11
    exec cdn.EcodAwizoInsert 'QuantityDespatched', @QuantityDespatched,0
    exec cdn.EcodAwizoInsert 'UnitOfMeasure', @UnitOfMeasure, 0
    exec cdn.EcodAwizoInsert 'ItemDescription', @ItemDescription, 11
   exec cdn.EcodAwizoInsert 'Line-Item',  '', 1
   exec cdn.EcodAwizoInsert 'Line-Order',  '', -1
    exec cdn.EcodAwizoInsert 'BuyerOrderNumber', @BuyerOrderNumber, 0
    exec cdn.EcodAwizoInsert 'BuyerOrderDate', @BuyerOrderDate, 0
   exec cdn.EcodAwizoInsert 'Line-Order',  '', 1
   exec cdn.EcodAwizoInsert 'Line-Parties',  '', -1
    exec cdn.EcodAwizoInsert 'UltimateCustomer',  '', -1
     exec cdn.EcodAwizoInsert 'ILN', @UltimateCustomerILN, 0
     exec cdn.EcodAwizoInsert 'Name', @UltimateCustomerName, 11
    exec cdn.EcodAwizoInsert 'UltimateCustomer',  '', 1
   exec cdn.EcodAwizoInsert 'Line-Parties',  '', 1
  exec cdn.EcodAwizoInsert 'Line',  '', 1
 END
 CLOSE packingLineSequenceCursor
 DEALLOCATE packingLineSequenceCursor
END
