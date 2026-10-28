CREATE PROCEDURE CDN.EcodAwizoHeaderXml
@TrnID            AS INT
,@awizoId         AS INT
AS
BEGIN
 EXEC CDN.FaWalidacjaForXml @TrnID, 0
    IF @@Error<>0 GOTO KONIEC
 DECLARE
  @DespatchAdviceNumber nvarchar(35)
 ,@DespatchAdviceDate nvarchar(10)
 ,@EstimatedDeliveryDate nvarchar(10)
 ,@DespatchNumber  nvarchar(35)
 ,@DespatchDate   nvarchar(10)
 ,@TermsOfDelivery  nvarchar(3)
 ,@ModeOfTransport  nvarchar(3)
 ,@BuyerILN    nvarchar(13)
 ,@BuyerTaxId   nvarchar(35)
 ,@CodeBySeller   nvarchar(35)
 ,@BuyerName    nvarchar(175)
 ,@BuyerStreetAndNumber nvarchar(140)
 ,@BuyerCityName   nvarchar(35)
 ,@BuyerPostalCode  nvarchar(9)
 ,@BuyerCountry   nvarchar(3)
 ,@SellerHeadquarterILN    nvarchar(13)
 ,@SellerHeadquarterName    nvarchar(175)
 ,@SellerHeadquarterStreetAndNumber nvarchar(140)
 ,@SellerHeadquarterCityName   nvarchar(35)
 ,@SellerHeadquarterPostalCode  nvarchar(9)
 ,@SellerHeadquarterCountry   nvarchar(3)
 ,@SellerILN    nvarchar(13)
 ,@SellerTaxID   nvarchar(35)
 ,@CodeByBuyer   nvarchar(35)
 ,@SellerName   nvarchar(175)
 ,@SellerStreetAndNumber nvarchar(140)
 ,@SellerCityName  nvarchar(35)
 ,@SellerPostalCode  nvarchar(9)
 ,@SellerCountry   nvarchar(3)
 ,@SellerPhoneNumber  nvarchar(512)
 ,@SellerFaxNumber  nvarchar(512)
 ,@DeliveryPointILN    nvarchar(13)
 ,@DeliveryPointName    nvarchar(175)
 ,@DeliveryPointStreetAndNumber nvarchar(140)
 ,@DeliveryPointCityName   nvarchar(35)
 ,@DeliveryPointPostalCode  nvarchar(9)
 ,@DeliveryPointCountry   nvarchar(3)
 ,@FreightForwarderILN   nvarchar(13)
 ,@UltimateCustomerILN    nvarchar(13)
 ,@UltimateCustomerName    nvarchar(175)
 ,@UltimateCustomerStreetAndNumber nvarchar(140)
 ,@UltimateCustomerCityName   nvarchar(35)
 ,@UltimateCustomerPostalCode  nvarchar(9)
 ,@UltimateCustomerCountry   nvarchar(3)
 SELECT
  @DespatchAdviceNumber = AWZ_NUMER
 ,@DespatchAdviceDate = Convert(nvarchar(10), AWZ_DATA, 120)
 ,@EstimatedDeliveryDate = Convert(nvarchar(10), AWZ_DATADOSTAWY, 120)
 ,@TermsOfDelivery = ISNULL((SELECT AWWD_Kod FROM [CDN].[AwizoWarunkiDostawy] WHERE AWWD_AWWDId = AWZ_WarunkiDostawyID), '')
 ,@ModeOfTransport = CAST(AWZ_TypTransportuID AS NVARCHAR(3))
 ,@CodeByBuyer   = CDN.EcodCodeByBuyer( 0, AWZ_PodTyp, AWZ_PodId)
 ,@BuyerILN    = CAST(cdn.EcodAwizoCustomer(1, AWZ_PodTyp, AWZ_PodId) AS NVARCHAR(13))
 ,@BuyerTaxID   = CAST(cdn.EcodAwizoCustomer(2, AWZ_PodTyp, AWZ_PodId) AS NVARCHAR(35))
 ,@BuyerName    = CAST(cdn.EcodAwizoCustomer(4, AWZ_PodTyp, AWZ_PodId) AS NVARCHAR(175))
 ,@BuyerStreetAndNumber = CAST(cdn.EcodAwizoCustomer(5, AWZ_PodTyp, AWZ_PodId) AS NVARCHAR(140))
 ,@BuyerCityName   = CAST(cdn.EcodAwizoCustomer(6, AWZ_PodTyp, AWZ_PodId) AS NVARCHAR(35))
 ,@BuyerPostalCode  = CAST(cdn.EcodAwizoCustomer(7, AWZ_PodTyp, AWZ_PodId) AS NVARCHAR(9))
 ,@BuyerCountry   = CAST(cdn.EcodAwizoCustomer(8, AWZ_PodTyp, AWZ_PodId) AS NVARCHAR(3))
 ,@DeliveryPointILN    = CAST(cdn.EcodAwizoCustomer(1, AWZ_OdbTyp, AWZ_OdbId) AS NVARCHAR(13))
 ,@DeliveryPointName    = CAST(cdn.EcodAwizoCustomer(4, AWZ_OdbTyp, AWZ_OdbId) AS NVARCHAR(175))
 ,@DeliveryPointStreetAndNumber = CAST(cdn.EcodAwizoCustomer(5, AWZ_OdbTyp, AWZ_OdbId) AS NVARCHAR(140))
 ,@DeliveryPointCityName   = CAST(cdn.EcodAwizoCustomer(6, AWZ_OdbTyp, AWZ_OdbId) AS NVARCHAR(35))
 ,@DeliveryPointPostalCode  = CAST(cdn.EcodAwizoCustomer(7, AWZ_OdbTyp, AWZ_OdbId) AS NVARCHAR(9))
 ,@DeliveryPointCountry   = CAST(cdn.EcodAwizoCustomer(8, AWZ_OdbTyp, AWZ_OdbId) AS NVARCHAR(9))
 FROM cdn.Awizo
 WHERE AWZ_AWZID = @awizoId
 DECLARE @pcId INT
 SET @pcId = 0
 SELECT TOP 1
  @DespatchDate  = Convert(nvarchar(10), wz.TrN_DataDok, 120)
 ,@DespatchNumber = wz.TrN_NumerPelny
 ,@pcId = wz.TrN_PCID
 FROM cdn.traelem ROElem
    LEFT JOIN cdn.TraElemRelacje on ROElem.TrE_TrEID = TeR_ParentId and ter_parenttyp = 308
    LEFT JOIN cdn.traelem WZELEM on TeR_ChildId = WZELEM.TrE_TrEId
    LEFT JOIN cdn.tranag WZ on WZELEM.TrE_TrNId = TrN_TrNID
    WHERE ROElem.TrE_TrNId = @TrnID and TeR_ChildTyp = 306 and ROElem.TrE_TwrTyp = 1 and TrN_Bufor = 0
 ORDER BY WZ.TrN_TrNID
 IF @pcId IS NULL SET @pcId = 0
 SELECT
 @SellerILN    = CDN.FirmaCfgWartosc(1165,@pcId),
 @SellerTaxId   = CDN.FirmaCfgWartosc(1101,@pcId),
 @SellerName    = CDN.FirmaNazwaZPieczatki(@pcId),
 @SellerStreetAndNumber = CDN.FirmaCfgWartosc(1149,@pcId) + ' ' + CDN.FirmaCfgWartosc(1150,@pcId) + (CASE LEN( CDN.FirmaCfgWartosc(1151,@pcId) ) WHEN  0 THEN '' ELSE '/' + CDN.FirmaCfgWartosc(1151,@pcId) END ),
 @SellerCityName   = CDN.FirmaCfgWartosc(1152,@pcId),
 @SellerPostalCode  = CDN.FirmaCfgWartosc(1153,@pcId),
 @SellerCountry   = CDN.FirmaCfgWartosc(1169,@pcId),
 @SellerPhoneNumber  = CDN.FirmaCfgWartosc(1155,@pcId),
 @SellerFaxNumber  = CDN.FirmaCfgWartosc(1155,@pcId)
 IF @SellerCountry = '' SET @SellerCountry = 'PL'
 --SELECT FROM cdn.TraNag fa WHERE fa.TrN_TrnId=@TrnID;
 -- zapisz dane
 exec cdn.EcodAwizoInsert 'DespatchAdvice-Header',  '', -1
     exec cdn.EcodAwizoInsert 'DespatchAdviceNumber', @DespatchAdviceNumber, 11
     exec cdn.EcodAwizoInsert 'DespatchAdviceDate',  @DespatchAdviceDate, 0
     exec cdn.EcodAwizoInsert 'EstimatedDeliveryDate', @EstimatedDeliveryDate, 0
     exec cdn.EcodAwizoInsert 'DespatchNumber',   @DespatchNumber, 11
     exec cdn.EcodAwizoInsert 'DespatchDate',   @DespatchDate, 0
 exec cdn.EcodAwizoInsert 'DespatchAdvice-Header',  '', 1
 exec cdn.EcodAwizoInsert 'DespatchAdvice-Transport',  '', -1
  exec cdn.EcodAwizoInsert 'TermsOfDelivery', @TermsOfDelivery, 0
  exec cdn.EcodAwizoInsert 'ModeOfTransport', @ModeOfTransport, 0
 exec cdn.EcodAwizoInsert 'DespatchAdvice-Transport',  '', 1
 exec cdn.EcodAwizoInsert 'DespatchAdvice-Parties',  '', -1
  exec cdn.EcodAwizoInsert 'Buyer', '', -1
   exec cdn.EcodAwizoInsert 'ILN',    @BuyerILN,    0
   exec cdn.EcodAwizoInsert 'TaxID',   @BuyerTaxID,   0
   exec cdn.EcodAwizoInsert 'Name',   @BuyerName,    11
   exec cdn.EcodAwizoInsert 'StreetAndNumber', @BuyerStreetAndNumber, 11
   exec cdn.EcodAwizoInsert 'CityName',  @BuyerCityName, 11
   exec cdn.EcodAwizoInsert 'PostalCode',  @BuyerPostalCode,  0
   exec cdn.EcodAwizoInsert 'Country',   @BuyerCountry,   0
  exec cdn.EcodAwizoInsert 'Buyer', '', 1
  exec cdn.EcodAwizoInsert 'Seller', '', -1
   exec cdn.EcodAwizoInsert 'ILN',    @SellerILN, 0
   exec cdn.EcodAwizoInsert 'TaxID',   @SellerTaxId, 0
   exec cdn.EcodAwizoInsert 'CodeByBuyer',  @CodeByBuyer, 0
   exec cdn.EcodAwizoInsert 'Name',   @SellerName, 11
   exec cdn.EcodAwizoInsert 'StreetAndNumber', @SellerStreetAndNumber, 11
   exec cdn.EcodAwizoInsert 'CityName',  @SellerCityName, 11
   exec cdn.EcodAwizoInsert 'PostalCode',  @SellerPostalCode, 0
   exec cdn.EcodAwizoInsert 'Country',   @SellerCountry, 0
        exec cdn.EcodAwizoInsert 'PhoneNumber',  @SellerPhoneNumber, 0
        exec cdn.EcodAwizoInsert 'Fax',    @SellerFaxNumber, 0
  exec cdn.EcodAwizoInsert 'Seller', '', 1
  exec cdn.EcodAwizoInsert 'DeliveryPoint', '', -1
   exec cdn.EcodAwizoInsert 'ILN',    @DeliveryPointILN, 0
   exec cdn.EcodAwizoInsert 'Name',   @DeliveryPointName, 11
   exec cdn.EcodAwizoInsert 'StreetAndNumber', @DeliveryPointStreetAndNumber, 11
   exec cdn.EcodAwizoInsert 'CityName',  @DeliveryPointCityName, 11
   exec cdn.EcodAwizoInsert 'PostalCode',  @DeliveryPointPostalCode, 0
   exec cdn.EcodAwizoInsert 'Country',   @DeliveryPointCountry, 0
  exec cdn.EcodAwizoInsert 'DeliveryPoint', '', 1
  --exec cdn.EcodAwizoInsert 'FreightForwarder', '', -1
       -- exec cdn.EcodAwizoInsert 'ILN', @FreightForwarderILN, 0
  --exec cdn.EcodAwizoInsert 'FreightForwarder', '', 1
  --exec cdn.EcodAwizoInsert 'SellerHeadquarters', '', -1
  -- exec cdn.EcodAwizoInsert 'ILN',    @SellerHeadquarterILN, 0
  -- exec cdn.EcodAwizoInsert 'Name',   @SellerHeadquarterName, 11
  -- exec cdn.EcodAwizoInsert 'StreetAndNumber', @SellerHeadquarterStreetAndNumber, 11
  -- exec cdn.EcodAwizoInsert 'CityName',  @SellerHeadquarterCityName, 11
  -- exec cdn.EcodAwizoInsert 'PostalCode',  @SellerHeadquarterPostalCode, 0
  -- exec cdn.EcodAwizoInsert 'Country',   @SellerHeadquarterCountry, 0
  --exec cdn.EcodAwizoInsert 'SellerHeadquarters', '', 1
  --exec cdn.EcodAwizoInsert 'UltimateCustomer', '', -1
  -- exec cdn.EcodAwizoInsert 'ILN',    @UltimateCustomerILN, 0
  -- exec cdn.EcodAwizoInsert 'Name',   @UltimateCustomerName, 11
  -- exec cdn.EcodAwizoInsert 'StreetAndNumber', @UltimateCustomerStreetAndNumber, 11
  -- exec cdn.EcodAwizoInsert 'CityName',  @UltimateCustomerCityName, 11
  -- exec cdn.EcodAwizoInsert 'PostalCode',  @UltimateCustomerPostalCode, 0
  -- exec cdn.EcodAwizoInsert 'Country',   @UltimateCustomerCountry, 0
  --exec cdn.EcodAwizoInsert 'UltimateCustomer', '', 1
   exec cdn.EcodAwizoInsert 'DespatchAdvice-Parties',  '', 1
KONIEC:
 RETURN
END
