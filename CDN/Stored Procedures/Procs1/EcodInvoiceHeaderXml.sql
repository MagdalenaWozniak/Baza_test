CREATE PROCEDURE CDN.EcodInvoiceHeaderXml
@TrnID            AS INT,
@eFa           AS INT,
@duplikat         AS INT
AS
BEGIN
 EXEC CDN.FaWalidacjaForXml @TrnID, @eFa
    IF @@Error<>0 GOTO KONIEC
 DECLARE
  @GUID nvarchar(36),
  @InvoiceReferenceGUID nvarchar(36),
     @InvoiceDuplicateDate nvarchar(10),
  @CreationDateTime nvarchar(20),
  @Description nvarchar(1024),
  @VatCalculateType INT,
  @DocumentCorrectionType INT,
  @UWDBuyerId nvarchar(20),
  @UWDBuyerDepartment nvarchar(20),
  @UWDReceiverId nvarchar(20),
  @UWDReceiverDepartment nvarchar(20),
  @UWDSellerId nvarchar(20),
  @UWDSellerDepartment nvarchar(20)
 Declare @bufor   INT
 ,@korekta    INT
 ,@pcID     INT
 ,@InvoiceNumber   nvarchar(35)
 ,@InvoiceDate   nvarchar(10)
 ,@SalesDate    nvarchar(10)
 ,@InvoicePaymentType nvarchar(35)
 ,@InvoicePaymentDueDate nvarchar(10)
 ,@InvoicePaymentTerms nvarchar(50)
 ,@DocumentFunctionCode nvarchar(50)
 ,@NettoBruttoFlag   nvarchar(1)
 ,@InvoiceReferenceNumber nvarchar(35)
 ,@InvoiceReferenceDate  nvarchar(10)
 ,@ReturnsNoticeNumber  nvarchar(35)
 ,@ReturnsNoticeDate   nvarchar(10)
 ,@BuyerOrderNumber   nvarchar(35)
 ,@BuyerOrderDate   nvarchar(10)
 ,@DeliveryLocationNumber nvarchar(13)
 ,@DeliveryDate    nvarchar(10)
 ,@DespatchNumber   nvarchar(35)
 ,@DespatchDate     nvarchar(10)
 ,@DespatchAdviceNumber  nvarchar(35)
 ,@BuyerILN    nvarchar(13)
 ,@BuyerTaxId   nvarchar(50)
 ,@BuyerAccountNumber nvarchar(50)
 ,@BuyerName    nvarchar(175)
 ,@BuyerStreetAndNumber nvarchar(140)
 ,@BuyerStreet   nvarchar(50)
 ,@BuyerStreetNumber1 nvarchar(50)
 ,@BuyerStreetNumber2 nvarchar(50)
 ,@BuyerCityName   nvarchar(50)
 ,@BuyerPostalCode  nvarchar(50)
 ,@BuyerCountry   nvarchar(50)
 ,@ReceiverILN   nvarchar(50)
 ,@ReceiverTaxId   nvarchar(50)
 ,@ReceiverAccountNumber nvarchar(50)
 ,@ReceiverName   nvarchar(175)
 ,@ReceiverStreetAndNumber nvarchar(140)
 ,@ReceiverStreet  nvarchar(50)
 ,@ReceiverStreetNumber1 nvarchar(50)
 ,@ReceiverStreetNumber2 nvarchar(50)
 ,@ReceiverCityName  nvarchar(50)
 ,@ReceiverPostalCode nvarchar(50)
 ,@ReceiverCountry  nvarchar(50)
 ,@SellerILN    nvarchar(50)
 ,@SellerTaxID   nvarchar(50)
 ,@SellerAccountNumber nvarchar(50)
 ,@CodeByBuyer   nvarchar(50)
 ,@SellerName   nvarchar(175)
 ,@SellerStreetAndNumber nvarchar(140)
 ,@SellerName1   nvarchar(175)
 ,@SellerName2   nvarchar(175)
 ,@SellerStreet   nvarchar(50)
 ,@SellerStreetNumber1 nvarchar(50)
 ,@SellerStreetNumber2 nvarchar(50)
 ,@SellerCityName  nvarchar(50)
 ,@SellerPostalCode  nvarchar(50)
 ,@SellerCountry   nvarchar(50)
 ,@PayeeILN    nvarchar(50)
 ,@PayeeTaxID   nvarchar(50)
 ,@PayeeAccountNumber nvarchar(50)
 ,@PayeeName    nvarchar(175)
 ,@PayeeStreetAndNumber nvarchar(140)
 ,@PayeeStreet   nvarchar(50)
 ,@PayeeStreetNumber1 nvarchar(50)
 ,@PayeeStreetNumber2 nvarchar(50)
 ,@PayeeCityName   nvarchar(50)
 ,@PayeePostalCode  nvarchar(50)
 ,@PayeeCountry   nvarchar(50)
 ,@DeliveryName   nvarchar(175)
 ,@DeliveryStreetAndNumber nvarchar(140)
 ,@DeliveryCityName  nvarchar(50)
 ,@DeliveryPostalCode nvarchar(50)
 ,@DeliveryCountry  nvarchar(50)
 ,@OrderedByILN    nvarchar(50)
 ,@OrderedByTaxID   nvarchar(50)
 ,@OrderedByAccountNumber nvarchar(50)
 ,@OrderedByName    nvarchar(175)
 ,@OrderedByStreetAndNumber nvarchar(140)
 ,@OrderedByCityName   nvarchar(35)
 ,@OrderedByPostalCode  nvarchar(50)
 ,@OrderedByCountry   nvarchar(50)
 ,@UtilizationRegisterNumber  nvarchar(35)
 ,@CourtAndCapitalInformation nvarchar(350)
 ,@ZwrID     INT
 ,@OdbiorcaTyp   INT
 ,@OdbiorcaId   INT
 ,@EcodTesco    TINYINT
 ,@CorrectionReason  NVARCHAR(350)
 ,@Remarks    NVARCHAR(1050)
 ,@MPP     INT
 exec CDN.UWDParametr 'ADE.CurrentAccount.Login', @UWDSellerId OUTPUT
 exec CDN.UWDParametr 'ADE.CurrentDivision.Symbol', @UWDSellerDepartment OUTPUT
 Select
 @GUID     = fa.TrN_ImportRowId,
 @CreationDateTime  = Convert(nvarchar(20), GetDate(), 120),
 @InvoiceDuplicateDate = Convert(nvarchar(10), GetDate(), 120),
 @Description   = fa.TrN_Opis,
 @VatCalculateType  = fa.TrN_TypNB,
 @DocumentCorrectionType = fa.TrN_Korekta,
  @UWDBuyerId    = IsNull((Select Knt_UWDId From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
 @UWDBuyerDepartment  = IsNull((Select Knt_UWDOddzial From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
 @UWDReceiverId   = IsNull((Select Knt_UWDId From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
 @UWDReceiverDepartment = IsNull((Select Knt_UWDOddzial From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
 @InvoicePaymentType   = Cast(IsNull((SELECT FPl_Nazwa FROM CDN.FormyPlatnosci WHERE FPl_FPlId = (SELECT TOP 1 TrN_FplId FROM CDN.TraNag WHERE TrN_TrNid = @TrnID)), 'przelew') As nvarchar(35)),
 @bufor     = fa.TrN_Bufor,
 @korekta    = fa.TrN_Korekta,
 @ZwrID     = IsNull(fa.TrN_ZwrId, 0),
 @InvoiceNumber   = IsNull(fa.TrN_NumerPelny,'')  ,
 @InvoiceDate   = Convert(nvarchar(10), fa.TrN_DataDok, 120),
 @SalesDate    = Case fa.TrN_Korekta When 0 Then Convert(nvarchar(10), fa.TrN_DataOpe, 120) ELSE IsNull((Select Convert(nvarchar(10),zwr.TrN_DataOpe, 120) From cdn.TraNag As zwr Where zwr.TrN_TypDokumentu=302 And zwr.Trn_TrNId=fa.TrN_ZwrId),'') END,
 @InvoicePaymentDueDate = Convert(nvarchar(10), fa.TrN_Termin, 120),
 @InvoicePaymentTerms = Cast(fa.TrN_Termin-fa.TrN_DataDok As INT),
 @DocumentFunctionCode = Case fa.TrN_Korekta When 0 Then 'O' When 1 Then 'C' When 2 Then 'C' When 3 Then 'C' When 6 Then 'C' Else 'E' End,
 @NettoBruttoFlag  = Case fa.TrN_TypNB When 1 Then 'N' Else 'B' End,
 @InvoiceReferenceNumber = IsNull((Select zwr.TrN_NumerPelny From cdn.TraNag As zwr Where zwr.TrN_TypDokumentu=302 And zwr.Trn_TrNId=fa.TrN_ZwrId),' '),
 @InvoiceReferenceDate = IsNull((Select Convert(nvarchar(10),zwr.TrN_DataDok, 120) From cdn.TraNag As zwr Where zwr.TrN_TypDokumentu=302 And zwr.Trn_TrNId=fa.TrN_ZwrId),''),
 @DespatchNumber = CDN.EcodDelivery(1, @TrNId),
 @DespatchDate = CDN.EcodDelivery(6, @TrNId),
 @DeliveryDate   = CDN.EcodDelivery(2, @TrNId),
 @DeliveryLocationNumber = CDN.EcodDelivery(3, @TrNId),
 @OdbiorcaTyp = Convert(INT, CDN.EcodDelivery(4, @TrNId)),
 @OdbiorcaId  = Convert(INT, CDN.EcodDelivery(5, @TrNId)),
 @DeliveryName    = CDN.EcodDeliveryAddress(1, @TrnID),
 @DeliveryStreetAndNumber = CDN.EcodDeliveryAddress(2, @TrnID),
 @DeliveryCityName   = CDN.EcodDeliveryAddress(3, @TrnID),
 @DeliveryPostalCode   = CDN.EcodDeliveryAddress(4, @TrnID),
 @DeliveryCountry   = CDN.EcodDeliveryAddress(5, @TrnID),
 @BuyerILN    = IsNull((Select Knt_Gln From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
 @BuyerTaxId    = fa.TrN_PodNIPE,
 @BuyerAccountNumber  = IsNull((Select Knt_RachunekNr From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
 @BuyerName    = Cast(fa.TrN_PodNazwa1 + ' ' + fa.TrN_PodNazwa2  + ' ' + fa.TrN_PodNazwa3 As nvarchar(175)),
 @BuyerStreetAndNumber = Cast(fa.TrN_PodUlica  + ' ' + fa.TrN_PodNrDomu  + (CASE LEN(fa.TrN_PodNrLokalu) WHEN  0 THEN '' ELSE '/' + fa.TrN_PodNrLokalu END ) As nvarchar(140)),
 @BuyerStreet   = Cast(fa.TrN_PodUlica  As nvarchar(40)),
 @BuyerStreetNumber1  = Cast(fa.TrN_PodNrDomu As nvarchar(40)),
 @BuyerStreetNumber2  = Cast(fa.TrN_PodNrLokalu As nvarchar(40)),
 @BuyerCityName   = Cast(fa.TrN_PodMiasto  As nvarchar(40)),
 @BuyerPostalCode  = Cast(fa.TrN_PodKodPocztowy As nvarchar(9)),
 @BuyerCountry   = IsNull((Select Knt_KrajISO From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), 'PL'),
 @ReceiverILN   = IsNull((Select Knt_Gln From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
 @ReceiverTaxId   = fa.Trn_OdbNIPE,
 @ReceiverAccountNumber = IsNull((Select Knt_RachunekNr From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
 @ReceiverName   = Cast(fa.TrN_OdbNazwa1 + ' ' + fa.TrN_OdbNazwa2  + ' ' + fa.TrN_OdbNazwa3 As nvarchar(175)),
 @ReceiverStreetAndNumber= Cast(fa.TrN_OdbUlica  + ' ' + fa.TrN_OdbNrDomu  + (CASE LEN(fa.TrN_OdbNrLokalu) WHEN  0 THEN '' ELSE '/' + fa.TrN_OdbNrLokalu END ) As nvarchar(140)),
 @ReceiverStreet   = Cast(fa.TrN_OdbUlica As nvarchar(40)),
 @ReceiverStreetNumber1 = Cast(fa.TrN_OdbNrDomu As nvarchar(40)),
 @ReceiverStreetNumber2 = Cast(fa.TrN_OdbNrLokalu As nvarchar(40)),
 @ReceiverCityName  = Cast(fa.TrN_OdbMiasto  As nvarchar(40)),
 @ReceiverPostalCode  = Cast(fa.TrN_OdbKodPocztowy As nvarchar(9)),
 @ReceiverCountry  = IsNull((Select Knt_KrajISO From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), 'PL'),
 @SellerILN    = cdn.PieczatkaFirmyWartosc(1165,fa.TrN_PcId),
 @SellerTaxID   = cdn.PieczatkaFirmyWartosc(1101,fa.TrN_PcId),
 @SellerAccountNumber = IsNull((Select BRa_RachunekNr From Cdn.FormyPlatnosci Join Cdn.BnkRachunki ON Fpl_BraId=BRa_BraId Join Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID Where BRa_Typ = 2 And Fpl_FPlID=fa.TrN_FPlId), ''),
 @CodeByBuyer   = CDN.EcodCodeByBuyer( fa.TrN_TrNId, fa.TrN_PodmiotTyp, fa.TrN_PodId),
 @SellerName    = cdn.FirmaNazwaZPieczatki(fa.TrN_PcId),
 @SellerStreetAndNumber = Cast(cdn.PieczatkaFirmyWartosc(1149,fa.TrN_PcId)  + ' ' + cdn.PieczatkaFirmyWartosc(1150,fa.TrN_PcId)
        +(CASE LEN( cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId)) WHEN  0 THEN '' ELSE '/' + cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId) END )
        As nvarchar(140)),
 @SellerName1   = Cast(cdn.PieczatkaFirmyWartosc(1156,fa.TrN_PcId) As nvarchar(254)),
 @SellerName2   = Cast(cdn.PieczatkaFirmyWartosc(1157,fa.TrN_PcId) As nvarchar(254)),
 @SellerStreet   = Cast(cdn.PieczatkaFirmyWartosc(1149,fa.TrN_PcId) As nvarchar(40)),
 @SellerStreetNumber1 = Cast(cdn.PieczatkaFirmyWartosc(1150,fa.TrN_PcId) As nvarchar(40)),
 @SellerStreetNumber2 = Cast(cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId) As nvarchar(40)),
 @SellerCityName   = CAST(cdn.PieczatkaFirmyWartosc(1152,fa.TrN_PcId) As nvarchar(40)),
 @SellerPostalCode  = CAST(cdn.PieczatkaFirmyWartosc(1153,fa.TrN_PcId) As nvarchar(9)),
 @SellerCountry   = CAST(cdn.PieczatkaFirmyWartoscWithDefault(1169,fa.TrN_PcId, 'PL') As nvarchar(9)),
 @PayeeILN    = IsNull((Case cdn.PieczatkaFirmyWartosc(1166,fa.TrN_PcId) When '' Then cdn.PieczatkaFirmyWartosc(1165,fa.TrN_PcId) Else cdn.PieczatkaFirmyWartosc(1166,fa.TrN_PcId) End),cdn.PieczatkaFirmyWartosc(1165,fa.TrN_PcId)),
 @PayeeTaxID    = cdn.PieczatkaFirmyWartosc(1101,fa.TrN_PcId),
 @PayeeAccountNumber  = IsNull((Select BRa_RachunekNr From Cdn.FormyPlatnosci Join Cdn.BnkRachunki ON Fpl_BraId=BRa_BraId Join Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID Where BRa_Typ = 2 And Fpl_FPlID=fa.TrN_FPlId), ''),
 @PayeeName    = CDN.FirmaNazwaZPieczatki(fa.TrN_PcId),
 @PayeeStreetAndNumber = Cast(cdn.PieczatkaFirmyWartosc(1149,fa.TrN_PcId) + ' ' + cdn.PieczatkaFirmyWartosc(1150,fa.TrN_PcId)
        +(CASE LEN( cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId)) WHEN  0 THEN '' ELSE '/' + cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId) END )
        As nvarchar(140)),
 @PayeeStreet   = Cast(cdn.PieczatkaFirmyWartosc(1149,fa.TrN_PcId) As nvarchar(40)),
 @PayeeStreetNumber1  = Cast(cdn.PieczatkaFirmyWartosc(1150,fa.TrN_PcId) As nvarchar(40)),
 @PayeeStreetNumber2  = Cast(cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId) As nvarchar(40)),
 @PayeeCityName   = CAST(cdn.PieczatkaFirmyWartosc(1152,fa.TrN_PcId) As nvarchar(40)),
 @PayeePostalCode  = CAST(cdn.PieczatkaFirmyWartosc(1153,fa.TrN_PcId) As nvarchar(9)),
 @PayeeCountry   = CAST(cdn.PieczatkaFirmyWartoscWithDefault(1169,fa.TrN_PcId, 'PL') As nvarchar(9)),
 @EcodTesco    = cdn.Ecodtesco(fa.TrN_PodmiotTyp, fa.TrN_PodId),
 @CorrectionReason  = cdn.EcodCorrectionReason(@TrnID),
 @Remarks    = CAST(fa.TrN_Opis AS NVARCHAR(1050)),
 @pcID     = IsNull(fa.TrN_PcId, 0),
 @UtilizationRegisterNumber = CAST(cdn.PieczatkaFirmyWartosc(1881,fa.TrN_PcId) AS NVARCHAR(35)),
 @MPP = fa.TrN_SplitPay
 From cdn.TraNag fa
 Where fa.TrN_TrnId=@TrnID;
 SET @BuyerOrderNumber = cdn.EcodBuyerOrderNumberOnlyOne(@TrnID, @ZwrID, 0)
 SET @BuyerOrderDate = cdn.EcodBuyerOrderDateOnlyOne(@TrnID, @ZwrID, 0)
 SET @ReturnsNoticeNumber = N''
 IF @eFa = 0 AND @korekta = 1 AND @EcodTesco = 1  AND LTRIM(RTRIM(@CorrectionReason)) = N'2'   -- ECOD only i TESCO
 BEGIN
  EXEC cdn.EcodReturnsNotice @TrnID, @ReturnsNoticeNumber OUTPUT, @ReturnsNoticeDate OUTPUT
 END
 SET @CourtAndCapitalInformation = CDN.GetCourtAndCapitalInformation(@pcID)
 SET @OrderedByILN = CDN.EcodOrderedBy(1, @TrnID)
 IF RTRIM(LTRIM(@OrderedByILN)) <> ''
 BEGIN
  SET @OrderedByTaxID    = CDN.EcodOrderedBy(2, @TrnID)
  SET @OrderedByAccountNumber  = CDN.EcodOrderedBy(3, @TrnID)
  SET @OrderedByName    = CDN.EcodOrderedBy(4, @TrnID)
  SET @OrderedByStreetAndNumber = CDN.EcodOrderedBy(5, @TrnID)
  SET @OrderedByCityName   = CDN.EcodOrderedBy(6, @TrnID)
  SET @OrderedByPostalCode  = CDN.EcodOrderedBy(7, @TrnID)
  SET @OrderedByCountry   = CDN.EcodOrderedBy(8, @TrnID)
 END
 IF @EcodTesco = 1
 BEGIN
  SET @OrderedByAccountNumber = CDN.GetAlphanumericOnly(@OrderedByAccountNumber)
  SET @BuyerAccountNumber  = CDN.GetAlphanumericOnly(@BuyerAccountNumber)
  SET @ReceiverAccountNumber = CDN.GetAlphanumericOnly(@ReceiverAccountNumber)
  SET @SellerAccountNumber = CDN.GetAlphanumericOnly(@SellerAccountNumber)
  SET @PayeeAccountNumber  = CDN.GetAlphanumericOnly(@PayeeAccountNumber)
 END
 -- zapisz dane
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Header', '', -1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceNumber',   @InvoiceNumber, 11)
  IF @eFa = 1 -- eFaktura only
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('GUID',     @GUID, 0)
  END
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceDate',   @InvoiceDate, 0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('SalesDate',    @SalesDate, 0)
  IF @duplikat = 1
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceDuplicateDate', @InvoiceDuplicateDate, 0)
  END
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceCurrency',  'PLN', 0)
  IF @eFa = 1  -- eFaktura only
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoicePaymentType', @InvoicePaymentType, 0)
  END
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoicePaymentDueDate', @InvoicePaymentDueDate, 0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoicePaymentTerms', @InvoicePaymentTerms, 0)
  IF @MPP = 1
  BEGIN
      INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PaymentInformation', N'mechanizm podzielonej płatności', 0)
  END
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DocumentFunctionCode', @DocumentFunctionCode, 0)
  IF @eFa = 0 AND @korekta > 0 AND @EcodTesco = 1  -- ECOD only i TESCO
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionReason', @CorrectionReason, 0)
   IF LTRIM(RTRIM(@CorrectionReason)) = N'3'
   BEGIN
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Remarks', @Remarks, 0)
   END
  END
  IF @eFa = 1 -- eFaktura only
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DocumentCorrectionType', @DocumentCorrectionType, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('VatCalculateType',  @VatCalculateType, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CreationDateTime',  @CreationDateTime, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Description',   @Description, 11)
  END
  IF @eFa = 0 -- ECOD only
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Order', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('BuyerOrderNumber', @BuyerOrderNumber, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('BuyerOrderDate',  @BuyerOrderDate, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Order', '', 1)
  END
  IF @korekta > 0
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Reference', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceReferenceNumber', @InvoiceReferenceNumber, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceReferenceDate', @InvoiceReferenceDate, 0)
    IF @eFa = 1 -- eFaktura only
    BEGIN
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoiceReferenceGUID', @InvoiceReferenceGUID, 0)
    END
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Reference', '', 1)
  END
 IF @eFa = 1 -- eFaktura only
 BEGIN
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Buyer', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UWD', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Id',   @UWDBuyerId,   0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Department', @UWDBuyerDepartment, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UWD', '', 1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('NameAndAddress', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',   @BuyerName,   11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Street',   @BuyerStreet,  11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetNumber', @BuyerStreetNumber1,11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetNumber2', @BuyerStreetNumber2,11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',  @BuyerCityName,  11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',  @BuyerPostalCode, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('NameAndAddress', '', 1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @BuyerTaxId,  0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Buyer', '', 1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Receiver', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UWD', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Id',   @UWDReceiverId,   0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Department', @UWDReceiverDepartment, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UWD', '', 1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('NameAndAddress', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',   @ReceiverName,  11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Street',   @ReceiverStreet, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetNumber1', @ReceiverStreetNumber1, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetNumber2', @ReceiverStreetNumber2, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',  @ReceiverCityName, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',  @ReceiverPostalCode,0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('NameAndAddress', '', 1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @ReceiverTaxId,  0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Receiver', '', 1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Seller', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UWD', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Id',   @UWDSellerId,   0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Department', @UWDSellerDepartment, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UWD', '', 1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('NameAndAddress', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name1',   @SellerName1,  11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name2',   @SellerName2,  11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Street',   @SellerStreet,  11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetNumber1', @SellerStreetNumber1,11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetNumber2', @SellerStreetNumber2,11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',  @SellerCityName, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',  @SellerPostalCode, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UtilizationRegisterNumber',@UtilizationRegisterNumber, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CourtAndCapitalInformation',@CourtAndCapitalInformation, 11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('NameAndAddress', '', 1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @SellerTaxID,   0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CodeByBuyer',  @CodeByBuyer,   0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Seller', '', 1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Header', '', 1)
 END
IF @eFa = 0 -- ECOD only
BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Delivery', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DeliveryLocationNumber', @DeliveryLocationNumber, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DeliveryDate',   @DeliveryDate, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DespatchNumber',   @DespatchNumber, 0)
    --INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DespatchDate',   @DespatchDate, 0)  żadna sieć nie korzytsa z tego pola
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('DespatchAdviceNumber', '', 0)
    IF CDN.EcodPutDeliveryAddress(@OdbiorcaTyp, @OdbiorcaId) = 1
    BEGIN
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @DeliveryName,   11)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @DeliveryStreetAndNumber, 11)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@DeliveryCityName  As nvarchar(35)), 11)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @DeliveryPostalCode,  0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @DeliveryCountry,   0)
    END
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Delivery', '', 1)
   IF @korekta > 0 AND Len(@ReturnsNoticeNumber) > 0
   BEGIN
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Returns', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ReturnsNoticeNumber', @ReturnsNoticeNumber, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ReturnsNoticeDate',  @ReturnsNoticeDate, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Returns', '', 1)
   END
   --EXEC CDN.EcodInsertPaymentsToXml @TrnID
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Header', '', 1)
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Parties', '', -1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Buyer', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ILN',    @BuyerILN,   0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @BuyerTaxId,  0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('AccountNumber',  @BuyerAccountNumber,0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @BuyerName,    11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @BuyerStreetAndNumber, 11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@BuyerCityName  As nvarchar(35)),11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @BuyerPostalCode, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @BuyerCountry,  0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Buyer', '', 1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Payer', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ILN',    @BuyerILN,   0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @BuyerTaxId,  0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('AccountNumber',  @BuyerAccountNumber,0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @BuyerName,    11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @BuyerStreetAndNumber, 11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@BuyerCityName  As nvarchar(35)),   11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @BuyerPostalCode, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @BuyerCountry,  0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Payer', '', 1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoicee', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ILN',    @BuyerILN,  0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @BuyerTaxId,  0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('AccountNumber',  @BuyerAccountNumber,0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @BuyerName,    11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @BuyerStreetAndNumber,11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@BuyerCityName  As nvarchar(35)),   11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @BuyerPostalCode, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @BuyerCountry,  0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoicee', '', 1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Seller', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ILN',    @SellerILN,    0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @SellerTaxID,   0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('AccountNumber',  @SellerAccountNumber, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CodeByBuyer',  @CodeByBuyer,   0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @SellerName,   11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @SellerStreetAndNumber, 11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@SellerCityName  As nvarchar(35)),  11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @SellerPostalCode,  0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @SellerCountry,   0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('UtilizationRegisterNumber',@UtilizationRegisterNumber, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CourtAndCapitalInformation',@CourtAndCapitalInformation, 11)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Seller', '', 1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Payee', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ILN',    @PayeeILN,    0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @PayeeTaxID,   0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('AccountNumber',  @PayeeAccountNumber, 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @PayeeName,    11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @PayeeStreetAndNumber, 11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@PayeeCityName  As nvarchar(35)),11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @PayeePostalCode,  0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @PayeeCountry,   0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Payee', '', 1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('SellerHeadquarters', '', -1)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ILN',    @SellerILN,    0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @SellerName,   11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @SellerStreetAndNumber, 11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@SellerCityName  As nvarchar(35)), 11)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @SellerPostalCode,  0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @SellerCountry,   0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('SellerHeadquarters', '', 1)
  IF RTRIM(LTRIM(@OrderedByILN)) <> ''
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('OrderedBy', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('ILN',    @OrderedByILN,    0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxID',    @OrderedByTaxID,   0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('AccountNumber',  @OrderedByAccountNumber, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Name',    @OrderedByName,    11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('StreetAndNumber', @OrderedByStreetAndNumber, 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CityName',   Cast(@OrderedByCityName  As nvarchar(35)), 11)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PostalCode',   @OrderedByPostalCode,  0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Country',   @OrderedByCountry,   0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('OrderedBy', '', 1)
  END
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Parties', '', 1)
END
KONIEC:
 RETURN
END
