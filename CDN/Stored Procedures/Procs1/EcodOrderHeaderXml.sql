CREATE PROCEDURE CDN.EcodOrderHeaderXml
@TrnID            AS INT
AS
BEGIN
 EXEC CDN.FaWalidacjaForXml @TrnID, 0
    IF @@Error<>0 GOTO KONIEC
 DECLARE @bufor   INT
 ,@korekta    INT
 ,@pcID     INT
 ,@OrderNumber   nvarchar(35)
 ,@OrderDate    nvarchar(10)
 ,@ExpectedDeliveryDate  nvarchar(10)
 ,@DocumentFunctionCode nvarchar(50)
 ,@Remarks    nvarchar(1024)
 ,@BuyerILN    nvarchar(13)
 ,@BuyerTaxId   nvarchar(50)
 ,@BuyerAccountNumber nvarchar(50)
 ,@BuyerName    nvarchar(175)
 ,@BuyerStreetAndNumber nvarchar(140)
 ,@BuyerCityName   nvarchar(35)
 ,@BuyerPostalCode  nvarchar(50)
 ,@BuyerCountry   nvarchar(50)
 ,@BuyerHeadquarterILN    nvarchar(13)
 ,@BuyerHeadquarterName    nvarchar(175)
 ,@BuyerHeadquarterStreetAndNumber nvarchar(140)
 ,@BuyerHeadquarterCityName   nvarchar(35)
 ,@BuyerHeadquarterPostalCode  nvarchar(50)
 ,@BuyerHeadquarterCountry   nvarchar(50)
 ,@SellerILN    nvarchar(50)
 ,@SellerTaxID   nvarchar(50)
 ,@SellerAccountNumber nvarchar(50)
 ,@CodeByBuyer   nvarchar(50)
 ,@SellerName   nvarchar(175)
 ,@SellerStreetAndNumber nvarchar(140)
 ,@SellerCityName  nvarchar(35)
 ,@SellerPostalCode  nvarchar(50)
 ,@SellerCountry   nvarchar(50)
 ,@ShipFromILN    nvarchar(50)
 ,@ShipFromName    nvarchar(175)
 ,@ShipFromStreetAndNumber nvarchar(140)
 ,@ShipFromCityName   nvarchar(35)
 ,@ShipFromPostalCode  nvarchar(50)
 ,@ShipFromCountry   nvarchar(50)
 ,@OrderedByILN    nvarchar(50)
 ,@OrderedByTaxID   nvarchar(50)
 ,@OrderedByAccountNumber nvarchar(50)
 ,@OrderedByName    nvarchar(175)
 ,@OrderedByStreetAndNumber nvarchar(140)
 ,@OrderedByCityName   nvarchar(35)
 ,@OrderedByPostalCode  nvarchar(50)
 ,@OrderedByCountry   nvarchar(50)
 ,@DeliveryILN   nvarchar(50)
 ,@DeliveryName   nvarchar(175)
 ,@DeliveryStreetAndNumber nvarchar(140)
 ,@DeliveryCityName  nvarchar(35)
 ,@DeliveryPostalCode nvarchar(50)
 ,@DeliveryCountry  nvarchar(50)
 ,@UtilizationRegisterNumber  nvarchar(35)
 ,@CourtAndCapitalInformation nvarchar(350)
 ,@ZwrID     INT
 ,@EcodTesco    TINYINT
 SELECT
 @bufor     = fa.TrN_Bufor,
 @korekta    = fa.TrN_Korekta,
 @pcID     = IsNull(fa.TrN_PcId, 0),
 @ZwrID     = IsNull(fa.TrN_ZwrId, 0),
 @OrderNumber   = IsNull(fa.TrN_NumerPelny,'')  ,
 @OrderDate    = Convert(nvarchar(10), fa.TrN_DataDok, 120),
 @ExpectedDeliveryDate   = Convert(nvarchar(10), fa.TrN_DataWys, 120),
 @Remarks    = fa.TrN_Opis,
 @DocumentFunctionCode = Case fa.TrN_Korekta When 0 Then 'O' When 1 Then 'C' When 2 Then 'C' When 3 Then 'C' When 6 Then 'C' Else 'E' End,
 @BuyerILN    = cdn.PieczatkaFirmyWartosc(1165,fa.TrN_PcId),
 @BuyerTaxID    = cdn.PieczatkaFirmyWartosc(1101,fa.TrN_PcId),
 @BuyerAccountNumber  = IsNull((Select BRa_RachunekNr From Cdn.FormyPlatnosci Join Cdn.BnkRachunki ON Fpl_BraId=BRa_BraId Join Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID Where BRa_Typ = 2 And Fpl_FPlID=fa.TrN_FPlId), ''),
 @BuyerName    = CDN.FirmaNazwaZPieczatki(fa.TrN_PcId),
 @BuyerStreetAndNumber = Cast(cdn.PieczatkaFirmyWartosc(1149,fa.TrN_PcId) + ' ' + cdn.PieczatkaFirmyWartosc(1150,fa.TrN_PcId)
        +(CASE LEN( cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId)) WHEN  0 THEN '' ELSE '/' + cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId) END )
        As nvarchar(140)),
 @BuyerCityName   = CAST(cdn.PieczatkaFirmyWartosc(1152,fa.TrN_PcId) As nvarchar(35)),
 @BuyerPostalCode  = CAST(cdn.PieczatkaFirmyWartosc(1153,fa.TrN_PcId) As nvarchar(9)),
 @BuyerCountry   = CAST(cdn.PieczatkaFirmyWartoscWithDefault(1169,fa.TrN_PcId, 'PL') As nvarchar(9)),
 @BuyerHeadquarterILN    = IsNull((Case cdn.PieczatkaFirmyWartosc(1166,fa.TrN_PcId) When '' Then cdn.PieczatkaFirmyWartosc(1165,fa.TrN_PcId) Else cdn.PieczatkaFirmyWartosc(1166,fa.TrN_PcId) End),cdn.PieczatkaFirmyWartosc(1165,fa.TrN_PcId)),
 @BuyerHeadquarterName    = CDN.FirmaNazwaZPieczatki(fa.TrN_PcId),
 @BuyerHeadquarterStreetAndNumber = Cast(cdn.PieczatkaFirmyWartosc(1149,fa.TrN_PcId) + ' ' + cdn.PieczatkaFirmyWartosc(1150,fa.TrN_PcId)
          +(CASE LEN( cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId)) WHEN  0 THEN '' ELSE '/' + cdn.PieczatkaFirmyWartosc(1151,fa.TrN_PcId) END )
          As nvarchar(140)),
 @BuyerHeadquarterCityName   = CAST(cdn.PieczatkaFirmyWartosc(1152,fa.TrN_PcId) As nvarchar(35)),
 @BuyerHeadquarterPostalCode   = CAST(cdn.PieczatkaFirmyWartosc(1153,fa.TrN_PcId) As nvarchar(9)),
 @BuyerHeadquarterCountry   = CAST(cdn.PieczatkaFirmyWartoscWithDefault(1169,fa.TrN_PcId, 'PL') As nvarchar(9)),
 @SellerILN    = IsNull((Select Knt_Gln From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
 @SellerTaxId   = fa.TrN_PodNIPE,
 @SellerAccountNumber = IsNull((Select Knt_RachunekNr From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
 @SellerName    = Cast(fa.TrN_PodNazwa1 + ' ' + fa.TrN_PodNazwa2  + ' ' + fa.TrN_PodNazwa3 As nvarchar(175)),
 @SellerStreetAndNumber = Cast(fa.TrN_PodUlica  + ' ' + fa.TrN_PodNrDomu  + (CASE LEN(fa.TrN_PodNrLokalu) WHEN  0 THEN '' ELSE '/' + fa.TrN_PodNrLokalu END ) As nvarchar(140)),
 @SellerCityName   = Cast(fa.TrN_PodMiasto  As nvarchar(140)),
 @SellerPostalCode  = Cast(fa.TrN_PodKodPocztowy As nvarchar(9)),
 @SellerCountry   = IsNull((Select Knt_KrajISO From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), 'PL'),
 @CodeByBuyer   = CDN.EcodCodeByBuyer( fa.TrN_TrNId, fa.TrN_PodmiotTyp, fa.TrN_PodId),
 @ShipFromILN   = IsNull((Select Knt_Gln From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
 @ShipFromName   = Cast(fa.TrN_OdbNazwa1 + ' ' + fa.TrN_OdbNazwa2  + ' ' + fa.TrN_OdbNazwa3 As nvarchar(175)),
 @ShipFromStreetAndNumber= Cast(fa.TrN_OdbUlica  + ' ' + fa.TrN_OdbNrDomu  + (CASE LEN(fa.TrN_OdbNrLokalu) WHEN  0 THEN '' ELSE '/' + fa.TrN_OdbNrLokalu END ) As nvarchar(140)),
 @ShipFromCityName  = Cast(fa.TrN_OdbMiasto  As nvarchar(35)),
 @ShipFromPostalCode  = Cast(fa.TrN_OdbKodPocztowy As nvarchar(9)),
 @ShipFromCountry  = IsNull((Select Knt_KrajISO From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), 'PL'),
 @EcodTesco    = cdn.Ecodtesco(fa.TrN_PodmiotTyp, fa.TrN_PodId),
 @UtilizationRegisterNumber = CAST(cdn.PieczatkaFirmyWartosc(1881,fa.TrN_PcId) AS NVARCHAR(35))
 From cdn.TraNag fa
 Where fa.TrN_TrnId=@TrnID;
 SET @DeliveryILN    = @BuyerILN
 SET @DeliveryName    = @BuyerName
 SET @DeliveryStreetAndNumber = @BuyerStreetAndNumber
 SET @DeliveryCityName   = @BuyerCityName
 SET @DeliveryPostalCode   = @BuyerPostalCode
 SET @DeliveryCountry   = @BuyerCountry
 SET @OrderedByILN = CDN.EcodOrderedBy(1, @TrnID)
 IF RTRIM(LTRIM(@OrderedByILN)) = ''
 BEGIN
  SET @OrderedByILN    = @BuyerILN
  SET @OrderedByTaxID    = @BuyerTaxID
  SET @OrderedByAccountNumber  = @BuyerAccountNumber
  SET @OrderedByName    = @BuyerName
  SET @OrderedByStreetAndNumber = @BuyerStreetAndNumber
  SET @OrderedByCityName   = @BuyerCityName
  SET @OrderedByPostalCode  = @BuyerPostalCode
  SET @OrderedByCountry   = @BuyerCountry
 END
 ELSE
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
  --SET @ReceiverAccountNumber = CDN.GetAlphanumericOnly(@ReceiverAccountNumber)
  SET @SellerAccountNumber = CDN.GetAlphanumericOnly(@SellerAccountNumber)
  --SET @PayeeAccountNumber  = CDN.GetAlphanumericOnly(@PayeeAccountNumber)
 END
 SET @CourtAndCapitalInformation = CDN.GetCourtAndCapitalInformation(@pcID)
 -- zapisz dane
 exec cdn.EcodOrderInsert 'Order-Header', '', -1
  exec cdn.EcodOrderInsert 'OrderNumber',    @OrderNumber, 11
  exec cdn.EcodOrderInsert 'OrderDate',    @OrderDate, 0
  exec cdn.EcodOrderInsert 'ExpectedDeliveryDate', @ExpectedDeliveryDate, 0
  exec cdn.EcodOrderInsert 'DocumentFunctionCode', @DocumentFunctionCode, 0
  exec cdn.EcodOrderInsert 'Remarks',     @Remarks, 11
  exec cdn.EcodOrderInsert 'OrderCurrency',   'PLN', 0
 exec cdn.EcodOrderInsert 'Order-Header', '', 1
 exec cdn.EcodOrderInsert 'Order-Parties', '', -1
  exec cdn.EcodOrderInsert 'Buyer', '', -1
   exec cdn.EcodOrderInsert 'ILN',    @BuyerILN,    0
   exec cdn.EcodOrderInsert 'TaxID',   @BuyerTaxID,   0
   exec cdn.EcodOrderInsert 'AccountNumber', @BuyerAccountNumber, 0
   exec cdn.EcodOrderInsert 'Name',   @BuyerName,    11
   exec cdn.EcodOrderInsert 'StreetAndNumber', @BuyerStreetAndNumber, 11
   exec cdn.EcodOrderInsert 'CityName',  @BuyerCityName, 11
   exec cdn.EcodOrderInsert 'PostalCode',  @BuyerPostalCode,  0
   exec cdn.EcodOrderInsert 'Country',   @BuyerCountry,   0
   exec cdn.EcodOrderInsert 'CourtAndCapitalInformation',@CourtAndCapitalInformation, 11
  exec cdn.EcodOrderInsert 'Buyer', '', 1
  exec cdn.EcodOrderInsert 'BuyerHeadquarters', '', -1
   exec cdn.EcodOrderInsert 'ILN',    @BuyerHeadquarterILN, 0
   exec cdn.EcodOrderInsert 'Name',   @BuyerHeadquarterName, 11
   exec cdn.EcodOrderInsert 'StreetAndNumber', @BuyerHeadquarterStreetAndNumber, 11
   exec cdn.EcodOrderInsert 'CityName',  @BuyerHeadquarterCityName, 11
   exec cdn.EcodOrderInsert 'PostalCode',  @BuyerHeadquarterPostalCode, 0
   exec cdn.EcodOrderInsert 'Country',   @BuyerHeadquarterCountry, 0
  exec cdn.EcodOrderInsert 'BuyerHeadquarters', '', 1
  exec cdn.EcodOrderInsert 'Seller', '', -1
   exec cdn.EcodOrderInsert 'ILN',    @SellerILN,   0
   exec cdn.EcodOrderInsert 'TaxID',   @SellerTaxId,  0
   exec cdn.EcodOrderInsert 'AccountNumber', @SellerAccountNumber,0
   exec cdn.EcodOrderInsert 'Name',   @SellerName,11
   exec cdn.EcodOrderInsert 'StreetAndNumber', @SellerStreetAndNumber,11
   exec cdn.EcodOrderInsert 'CityName',  @SellerCityName,11
   exec cdn.EcodOrderInsert 'PostalCode',  @SellerPostalCode, 0
   exec cdn.EcodOrderInsert 'Country',   @SellerCountry,  0
   exec cdn.EcodOrderInsert 'CodeByBuyer',  @CodeByBuyer,   0
  exec cdn.EcodOrderInsert 'Seller', '', 1
  exec cdn.EcodOrderInsert 'DeliveryPoint', '', -1
   exec cdn.EcodOrderInsert 'ILN',    @DeliveryILN, 0
   exec cdn.EcodOrderInsert 'Name',   @DeliveryName, 11
   exec cdn.EcodOrderInsert 'StreetAndNumber', @DeliveryStreetAndNumber, 11
   exec cdn.EcodOrderInsert 'CityName',  @DeliveryCityName, 11
   exec cdn.EcodOrderInsert 'PostalCode',  @DeliveryPostalCode, 0
   exec cdn.EcodOrderInsert 'Country',   @DeliveryCountry, 0
  exec cdn.EcodOrderInsert 'DeliveryPoint', '', 1
  exec cdn.EcodOrderInsert 'ShipFrom', '', -1
   exec cdn.EcodOrderInsert 'ILN',    @ShipFromILN, 0
   exec cdn.EcodOrderInsert 'Name',   @ShipFromName, 11
   exec cdn.EcodOrderInsert 'StreetAndNumber', @ShipFromStreetAndNumber, 11
   exec cdn.EcodOrderInsert 'CityName',  @ShipFromCityName, 11
   exec cdn.EcodOrderInsert 'PostalCode',  @ShipFromPostalCode, 0
   exec cdn.EcodOrderInsert 'Country',   @ShipFromCountry, 0
  exec cdn.EcodOrderInsert 'ShipFrom', '', 1
  exec cdn.EcodOrderInsert 'OrderedBy', '', -1
   exec cdn.EcodOrderInsert 'ILN',    @OrderedByILN, 0
   exec cdn.EcodOrderInsert 'Name',   @OrderedByName, 11
   exec cdn.EcodOrderInsert 'StreetAndNumber', @OrderedByStreetAndNumber, 11
   exec cdn.EcodOrderInsert 'CityName',  @OrderedByCityName, 11
   exec cdn.EcodOrderInsert 'PostalCode',  @OrderedByPostalCode, 0
   exec cdn.EcodOrderInsert 'Country',   @OrderedByCountry, 0
  exec cdn.EcodOrderInsert 'OrderedBy', '', 1
 exec cdn.EcodOrderInsert 'Order-Parties', '', 1
KONIEC:
 RETURN
END
