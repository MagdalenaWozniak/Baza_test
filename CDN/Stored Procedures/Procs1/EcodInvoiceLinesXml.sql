CREATE PROCEDURE CDN.EcodInvoiceLinesXml
@TrnID            AS INT,
@eFa           AS INT
AS
BEGIN
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Lines',  '', -1)
 DECLARE @Korekta  INT
 DECLARE @TrnZwrId INT
 SELECT @TrnZwrId = IsNull(TrN_ZwrId, 0), @Korekta = IsNull(TrN_Korekta, 0) FROM CDN.TraNag WHERE TrN_TrNID = @TrnID
 DECLARE
 @LineNumber    nvarchar(20),
 @EAN     nvarchar(20),
 @BuyerItemCode   nvarchar(35),
 @SupplierItemCode  nvarchar(35),
 @ItemDescription  nvarchar(70),
 @ItemType    nvarchar(2),
 @UnitOfMeasure   nvarchar(20),
 @InvoiceUnitPacksize DECIMAL(15,4),
 @PackItemUnitOfMeasure nvarchar(20),
 @TaxRate    nvarchar(20),
 @TaxCategoryCode  nvarchar(2),
 @ReferenceType   nvarchar(35),
 @ReferenceNumber  nvarchar(35),
 @PreviousTaxRate    nvarchar(20),
 @PreviousTaxCategoryCode  nvarchar(2),
 @InvoiceReferenceNumber nvarchar(35),
 @InvoiceReferenceDate nvarchar(10),
 @BuyerOrderNumber  nvarchar(35),
 @BuyerOrderDate   nvarchar(10),
 @DeliveryLocationNumber nvarchar(13),
 @DeliveryDate   nvarchar(10),
 @DespatchNumber   nvarchar(35),
 @DespatchAdviceNumber nvarchar(35),
 @OdbiorcaTyp   INT
 ,@OdbiorcaId   INT
 ,@DeliveryName   nvarchar(175)
 ,@DeliveryStreetAndNumber nvarchar(140)
 ,@DeliveryCityName  nvarchar(50)
 ,@DeliveryPostalCode nvarchar(50)
 ,@DeliveryCountry  nvarchar(50),
 @CorrectionReason  nvarchar(350),
 @InvoiceQuantity  DECIMAL(15,4),
 @InvoiceUnitNetPrice DECIMAL(15,2),
 @TaxAmount    DECIMAL(15,2),
 @NetAmount    DECIMAL(15,2),
 @PreviousInvoiceQuantity  DECIMAL(15,4),
 @PreviousInvoiceUnitNetPrice DECIMAL(15,2),
 @PreviousTaxAmount    DECIMAL(15,2),
 @PreviousNetAmount    DECIMAL(15,2)
 IF @TrnZwrId = 0
 BEGIN
  DECLARE fakturaLines CURSOR FOR
  Select
  LTrim(Str(faElem.TrE_Lp,15))  As LineNumber,
  LTrim(Cast(faElem.TrE_TwrEan  As nvarchar(20))) As EAN,
  Substring(IsNull((Select TOP 1 IsNull(TkA_WartoscTxt, '')
   From CDN.TwrKntAtrybuty
   Join CDN.TwrAtrybuty ON TkA_TwAId=TwA_TwAId
   Join CDN.DefAtrybuty ON TwA_DeAId=DeA_DeAId
   Where DeA_Kod = 'BUYERITEMCODE' And TwA_TwrId = faElem.TrE_TwrId
   And TkA_PodmiotTyp = faElem.TrE_PodmiotTyp
   And TkA_PodmiotId = faElem.TrE_PodId), ''),1,35) As BuyerItemCode,
  Substring(faElem.TrE_TwrKod,1,35)   As SupplierItemCode,
  faElem.TrE_TwrNazwa As ItemDescription,
  CASE WHEN faElem.TrE_Kaucja = 1 THEN 'RC' ELSE 'CU' END As ItemType,
  faElem.TrE_IloscJM As InvoiceQuantity,
  LTrim(cdn.EcodUnitOfMeasure(faElem.TrE_JM, faElem.TrE_TrEId, 1, @eFa)) As UnitOfMeasure,
  CDN.InvoiceUnitPacksize(faElem.TrE_TrEId) As InvoiceUnitPacksize,
  LTrim(cdn.EcodUnitOfMeasure(faElem.TrE_JM, faElem.TrE_TrEId, 0, @eFa)) As PackItemUnitOfMeasure,
  cdn.Round2(faElem.TrE_CenaT) As InvoiceUnitNetPrice,
  LTrim(Str(faElem.TrE_Stawka,15,2))  As TaxRate,
  CDN.EcodTaxCategoryCode(faElem.TrE_Stawka, faElem.TrE_Flaga, @TrnID) As TaxCategoryCode,
  'PKWiU' As ReferenceType,
  Substring(faElem.TrE_TwrSWW,1,20)  As ReferenceNumber,
  faElem.TrE_WartoscBrutto-faElem.TrE_WartoscNetto As TaxAmount,
  faElem.TrE_WartoscNetto As NetAmount,
  cdn.EcodBuyerOrderNumberOnlyOne(faElem.TrE_TrnId, 0, faElem.TrE_LpPow) As BuyerOrderNumber,
  cdn.EcodBuyerOrderDateOnlyOne(faElem.TrE_TrnId, 0, faElem.TrE_LpPow)   As BuyerOrderDate,
  CDN.EcodDelivery(1, faElem.TrE_TrnId) As DespatchNumber,
  CDN.EcodDelivery(2, faElem.TrE_TrnId) As DeliveryDate,
  CDN.EcodDelivery(3, faElem.TrE_TrnId) As DeliveryLocationNumber,
  Convert(INT, CDN.EcodDelivery(4, faElem.TrE_TrnId)) As OdbiorcaTyp,
  Convert(INT, CDN.EcodDelivery(5, faElem.TrE_TrnId)) As OdbiorcaId,
  DeliveryName   = CDN.EcodDeliveryAddress(1, faElem.TrE_TrnId),
  DeliveryStreetAndNumber = CDN.EcodDeliveryAddress(2, faElem.TrE_TrnId),
  DeliveryCityName  = CDN.EcodDeliveryAddress(3, faElem.TrE_TrnId),
  DeliveryPostalCode  = CDN.EcodDeliveryAddress(4, faElem.TrE_TrnId),
  DeliveryCountry   = CDN.EcodDeliveryAddress(5, faElem.TrE_TrnId)
  From cdn.TraElem faElem
  Where faElem.TrE_TrnId=@TrnID
  ORDER BY faElem.TrE_Lp
  OPEN fakturaLines
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM fakturaLines INTO @LineNumber, @EAN, @BuyerItemCode, @SupplierItemCode,
           @ItemDescription, @ItemType, @InvoiceQuantity,
           @UnitOfMeasure, @InvoiceUnitPacksize, @PackItemUnitOfMeasure,
           @InvoiceUnitNetPrice, @TaxRate,
           @TaxCategoryCode, @ReferenceType, @ReferenceNumber,
           @TaxAmount, @NetAmount,
           @BuyerOrderNumber,  @BuyerOrderDate,
           @DespatchNumber, @DeliveryDate, @DeliveryLocationNumber,
           @OdbiorcaTyp, @OdbiorcaId,
           @DeliveryName,@DeliveryStreetAndNumber,@DeliveryCityName,@DeliveryPostalCode,@DeliveryCountry
   IF @@FETCH_STATUS <> 0 BREAK
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Item', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('LineNumber', @LineNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('EAN',  @EAN, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('BuyerItemCode',  @BuyerItemCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('SupplierItemCode', @SupplierItemCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ItemDescription', @ItemDescription, 11)  --CDATA
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ItemType',   @ItemType, 0)
     IF @eFa=1
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceQuantity', LTrim(Str(@InvoiceQuantity,15,4)), 0)
     ELSE
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceQuantity', LTrim(Str(@InvoiceQuantity,15,3)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UnitOfMeasure',  LTrim(@UnitOfMeasure), 0)
     IF @eFa=1
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceUnitPacksize',LTrim(Str(@InvoiceUnitPacksize,15,4)), 0)
     ELSE
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceUnitPacksize',LTrim(Str(@InvoiceUnitPacksize,15,3)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PackItemUnitOfMeasure',LTrim(@PackItemUnitOfMeasure), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceUnitNetPrice',LTrim(Str(@InvoiceUnitNetPrice,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxRate',   @TaxRate, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxCategoryCode', @TaxCategoryCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxReference', '', -1)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ReferenceType',  @ReferenceType, 0)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ReferenceNumber', @ReferenceNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxReference', '', 1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxAmount',   LTrim(Str(@TaxAmount,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('NetAmount',   LTrim(Str(@NetAmount,15,2)), 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Item', '', 1)
   IF @eFa = 0 -- ECOD only
   BEGIN
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Order', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('BuyerOrderNumber', @BuyerOrderNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('BuyerOrderDate',  @BuyerOrderDate, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Order', '', 1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Delivery', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DeliveryLocationNumber', @DeliveryLocationNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DeliveryDate',  @DeliveryDate, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DespatchNumber',  @DespatchNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DespatchAdviceNumber','', 0)
     IF CDN.EcodPutDeliveryAddress(@OdbiorcaTyp, @OdbiorcaId) = 1
     BEGIN
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @DeliveryName,   11)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @DeliveryStreetAndNumber, 11)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@DeliveryCityName  As nvarchar(35)), 11)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @DeliveryPostalCode,  0)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @DeliveryCountry,   0)
     END
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Delivery', '', 1)
   END
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line', '', 1)
  END
  CLOSE fakturaLines
  DEALLOCATE fakturaLines
 END  -- end zwykła FA
 IF @TrnZwrId > 0
 BEGIN   -- korekta faktury
  SET @InvoiceReferenceNumber = ''
  SET @InvoiceReferenceDate = ''
  Select @InvoiceReferenceNumber = IsNull(faOrg.TrN_NumerPelny, ''),
    @InvoiceReferenceDate = IsNull(Convert(nvarchar(10), faOrg.TrN_DataDok, 120), '')
  From cdn.TraNag As faOrg
  Join cdn.TraNag As faKor ON faOrg.TrN_TypDokumentu=302 And faOrg.Trn_TrNId = faKor.TrN_ZwrId
  Where faKor.TrN_TrNID = @TrnID
  DECLARE fakturaLinesKor CURSOR FOR
  Select -- FA korygująca (po korekcie)
  LTrim(Str(faKor.TrE_Lp))    As LineNumber,
  LTrim(Cast(faKor.TrE_TwrEan As nvarchar(20))) As EAN,
  Substring(IsNull((Select TOP 1 IsNull(TkA_WartoscTxt, '')
   From CDN.TwrKntAtrybuty
   Join CDN.TwrAtrybuty ON TkA_TwAId=TwA_TwAId
   Join CDN.DefAtrybuty ON TwA_DeAId=DeA_DeAId
   Where DeA_Kod = 'BUYERITEMCODE' And TwA_TwrId = faKor.TrE_TwrId
   And TkA_PodmiotTyp = faKor.TrE_PodmiotTyp
   And TkA_PodmiotId = faKor.TrE_PodId), ''),1,35) As BuyerItemCode,
  Substring(faKor.TrE_TwrKod,1,35)   As SupplierItemCode,
  faKor.TrE_TwrNazwa As ItemDescription,
  CASE WHEN faKor.TrE_Kaucja = 1 THEN 'RC' ELSE 'CU' END As ItemType,
  CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) As InvoiceQuantity,
  LTrim(cdn.EcodUnitOfMeasure(faKor.TrE_JM, faKor.TrE_TrEId, 1, @eFa)) As UnitOfMeasure,
  CDN.InvoiceUnitPacksize(faKor.TrE_TrEId) As InvoiceUnitPacksize,
  LTrim(cdn.EcodUnitOfMeasure(faKor.TrE_JM, faKor.TrE_TrEId, 0, @eFa)) As PackItemUnitOfMeasure,
  cdn.Round2(faKor.TrE_CenaT) As InvoiceUnitNetPrice,
  LTrim(Str(faKor.TrE_Stawka,15,2))  As TaxRate,
  CDN.EcodTaxCategoryCode(faKor.TrE_Stawka,faKor.TrE_Flaga, @TrnID) As TaxCategoryCode,
  'PKWiU' As ReferenceType,
  Substring(faKor.TrE_TwrSWW,1,20)  As ReferenceNumber,
  CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT * faKor.TrE_Stawka/100) AS DECIMAL(15,2) ) As TaxAmount,
  CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT) AS DECIMAL(15,2) ) As NetAmount,
  -- previous
  CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,0, 1) As PreviousInvoiceQuantity,
  CASE WHEN @Korekta=2 THEN CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,0, 2) As DECIMAL(15,2)) ELSE cdn.Round2(faKor.TrE_CenaT) END  As PreviousInvoiceUnitNetPrice,
        LTrim(Str(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,0, 3),15,2)) As PreviousTaxRate,
        CDN.EcodTaxCategoryCode(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,@Korekta, 3) ,
    CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,@Korekta, 4) As INT), @TrnID) As PreviousTaxCategoryCode,
        CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId, CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW),@Korekta, 5) As DECIMAL(15,2)) As PreviousTaxAmount,
        CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW),@Korekta, 6) As DECIMAL(15,2)) As PreviousNetAmount,
  -- previous
  cdn.EcodBuyerOrderNumberOnlyOne(faPier.TrN_TrNId, faKor.TrE_TrnId, faKor.TrE_LpPow) As BuyerOrderNumber,
  cdn.EcodBuyerOrderDateOnlyOne(faPier.TrN_TrNId, faKor.TrE_TrnId, faKor.TrE_LpPow)   As BuyerOrderDate,
  CDN.EcodDelivery(1, faKor.TrE_TrnId) As DespatchNumber,
  CDN.EcodDelivery(2, faKor.TrE_TrnId) As DeliveryDate,
  CDN.EcodDelivery(3, faKor.TrE_TrnId) As DeliveryLocationNumber,
  Convert(INT, CDN.EcodDelivery(4, faKor.TrE_TrnId)) As OdbiorcaTyp,
  Convert(INT, CDN.EcodDelivery(5, faKor.TrE_TrnId)) As OdbiorcaId,
  CDN.EcodDeliveryAddress(1, faKor.TrE_TrnId) As DeliveryName,
  CDN.EcodDeliveryAddress(2, faKor.TrE_TrnId) As DeliveryStreetAndNumber,
  CDN.EcodDeliveryAddress(3, faKor.TrE_TrnId) As DeliveryCityName,
  CDN.EcodDeliveryAddress(4, faKor.TrE_TrnId) As DeliveryPostalCode,
  CDN.EcodDeliveryAddress(5, faKor.TrE_TrnId) As DeliveryCountry,
  CDN.EcodCorrectionReason(@TrnID) As CorrectionReason
  From cdn.TraElem faKor
  Join cdn.TraElem faOrg  on faKor.TrE_ZwrID = faOrg.TrE_TrEId
  Join cdn.TraNag  faPier on faOrg.TrE_TrNID = faPier.TrN_TrNId
  Where faKor.TrE_TrnId = @TrnID
   --And CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) <> 0
  ORDER BY faKor.TrE_Lp
  OPEN fakturaLinesKor
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM fakturaLinesKor INTO @LineNumber, @EAN, @BuyerItemCode, @SupplierItemCode,
           @ItemDescription, @ItemType, @InvoiceQuantity,
           @UnitOfMeasure, @InvoiceUnitPacksize, @PackItemUnitOfMeasure,
           @InvoiceUnitNetPrice, @TaxRate,
           @TaxCategoryCode, @ReferenceType, @ReferenceNumber,
           @TaxAmount, @NetAmount,
           @PreviousInvoiceQuantity, @PreviousInvoiceUnitNetPrice,
           @PreviousTaxRate, @PreviousTaxCategoryCode,
           @PreviousTaxAmount, @PreviousNetAmount,
           @BuyerOrderNumber, @BuyerOrderDate,
           @DespatchNumber, @DeliveryDate, @DeliveryLocationNumber,
           @OdbiorcaTyp, @OdbiorcaId,
           @DeliveryName,@DeliveryStreetAndNumber,@DeliveryCityName,@DeliveryPostalCode,@DeliveryCountry,
           @CorrectionReason
   IF @@FETCH_STATUS <> 0 BREAK
   DECLARE @CorrectionTaxAmount DECIMAL(15,2)
   SET @CorrectionTaxAmount =  Round((@NetAmount - @PreviousNetAmount) * @TaxRate/100, 2)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Item', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('LineNumber', @LineNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('EAN',  @EAN, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('BuyerItemCode',  @BuyerItemCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('SupplierItemCode', @SupplierItemCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ItemDescription', @ItemDescription, 11)  --CDATA
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ItemType',   @ItemType, 0)
     IF @eFa = 1
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceQuantity', LTrim(Str(@InvoiceQuantity,15,4)), 0)
     ELSE
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceQuantity', LTrim(Str(@InvoiceQuantity,15,3)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UnitOfMeasure',  LTrim(@UnitOfMeasure), 0)
     IF @eFa = 1
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceUnitPacksize',LTrim(Str(@InvoiceUnitPacksize,15,4)), 0)
     ELSE
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceUnitPacksize',LTrim(Str(@InvoiceUnitPacksize,15,3)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PackItemUnitOfMeasure',LTrim(@PackItemUnitOfMeasure), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceUnitNetPrice',LTrim(Str(@InvoiceUnitNetPrice,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxRate',   @TaxRate, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxCategoryCode', @TaxCategoryCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxReference', '', -1)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ReferenceType',  @ReferenceType, 0)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ReferenceNumber', @ReferenceNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxReference', '', 1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxAmount',   LTrim(Str(@TaxAmount,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('NetAmount',   LTrim(Str(@NetAmount,15,2)), 0)
     IF @Korekta = 2 -- korekta wartości; aby uwzględnić korektę ceny dla części ilości
     begin
      set @PreviousInvoiceQuantity = @InvoiceQuantity
     end
     IF @eFa = 1
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousInvoiceQuantity', LTrim(Str(@PreviousInvoiceQuantity,15,4)), 0)
     ELSE
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousInvoiceQuantity', LTrim(Str(@PreviousInvoiceQuantity,15,3)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousInvoiceUnitNetPrice',LTrim(Str(@PreviousInvoiceUnitNetPrice,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTaxRate',   @PreviousTaxRate, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTaxCategoryCode', @PreviousTaxCategoryCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTaxAmount',   LTrim(Str(@PreviousTaxAmount,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousNetAmount',   LTrim(Str(@PreviousNetAmount,15,2)), 0)
     IF @eFa = 1
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionInvoiceQuantity',  LTrim(Str(@InvoiceQuantity - @PreviousInvoiceQuantity,15,4)), 0)
     ELSE
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionInvoiceQuantity',  LTrim(Str(@InvoiceQuantity - @PreviousInvoiceQuantity,15,3)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionInvoiceUnitNetPrice', LTrim(Str(@InvoiceUnitNetPrice - @PreviousInvoiceUnitNetPrice,15,2)), 0)
     --INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTaxAmount',   LTrim(Str(@TaxAmount - @PreviousTaxAmount,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTaxAmount',   LTrim(Str(@CorrectionTaxAmount,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionNetAmount',   LTrim(Str(@NetAmount - @PreviousNetAmount,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionReason',    @CorrectionReason, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Item', '', 1)
   IF @eFa = 0 -- ECOD only
   BEGIN
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Order', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('BuyerOrderNumber', @BuyerOrderNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('BuyerOrderDate',  @BuyerOrderDate, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Order', '', 1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Reference', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceReferenceNumber', @InvoiceReferenceNumber, 11)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceReferenceDate', @InvoiceReferenceDate, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Reference', '', 1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Delivery', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DeliveryLocationNumber', @DeliveryLocationNumber, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DeliveryDate',  @DeliveryDate, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DespatchNumber',  @DespatchNumber, 0)
     IF CDN.EcodPutDeliveryAddress(@OdbiorcaTyp, @OdbiorcaId) = 1
     BEGIN
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @DeliveryName,   11)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @DeliveryStreetAndNumber, 11)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@DeliveryCityName  As nvarchar(35)), 11)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @DeliveryPostalCode,  0)
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @DeliveryCountry,   0)
     END
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line-Delivery', '', 1)
   END
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Line', '', 1)
  END
  CLOSE fakturaLinesKor
  DEALLOCATE fakturaLinesKor
 END
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Lines',  '', 1)
END
