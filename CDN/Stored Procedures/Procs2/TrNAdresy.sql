CREATE PROCEDURE CDN.TrNAdresy
@TrnID            AS INT
AS
BEGIN
 DECLARE @pcId INT
 SELECT  TOP 1 @pcId = TrN_PCID FROM cdn.TraNag WHERE TrN_TrNId = @TrnID
 IF @pcId IS NULL SET @pcId = 0
  SELECT
    BuyerILN               = IsNull((Select Knt_Gln From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
    BuyerTaxIdPrefix       = IsNull((Select Knt_NipKraj From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
    BuyerTaxId             = IsNull((Select Knt_NIP From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
    BuyerAccountNumber     = IsNull((Select Knt_RachunekNr From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
    BuyerKod               = IsNull((Select Knt_Kod From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), ''),
    BuyerName              = RTRIM(Cast(fa.TrN_PodNazwa1 + ' ' + fa.TrN_PodNazwa2  + ' ' + fa.TrN_PodNazwa3 As NVARCHAR(175))),
    BuyerStreetAndNumber   = RTRIM(Cast(fa.TrN_PodUlica  + ' ' + fa.TrN_PodNrDomu  + (CASE LEN(fa.TrN_PodNrLokalu) WHEN  0 THEN '' ELSE '/' + fa.TrN_PodNrLokalu END ) As NVARCHAR(35))),
    BuyerStreet            = Cast(fa.TrN_PodUlica  As NVARCHAR(40)),
    BuyerStreetNumber1     = Cast(fa.TrN_PodNrDomu As NVARCHAR(40)),
    BuyerStreetNumber2     = Cast(fa.TrN_PodNrLokalu As NVARCHAR(40)),
    BuyerCityName          = Cast(fa.TrN_PodMiasto  As NVARCHAR(40)),
    BuyerPostalCode        = Cast(fa.TrN_PodKodPocztowy As NVARCHAR(9)),
    BuyerCountry           = IsNull((Select Knt_KrajISO From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId), 'PL'),
    BuyerCountryName       = Cast(fa.TrN_PodKraj  As NVARCHAR(40)),
    BuyerSplitPay          = (Select Knt_SplitPay From cdn.Kontrahenci Join cdn.TraNag As faPod On faPod.TrN_PodmiotTyp=Knt_PodmiotTyp And faPod.TrN_PodId=Knt_KntId  Where faPod.TrN_TrnId=fa.TrN_TrnId),
    ReceiverKod            = IsNull((Select Knt_Kod From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
    ReceiverILN            = IsNull((Select Knt_Gln From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
    ReceiverTaxIdPrefix    = IsNull((Select Knt_NipKraj From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
    ReceiverTaxId          = IsNull((Select Knt_NIP From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
    ReceiverAccountNumber  = IsNull((Select Knt_RachunekNr From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), ''),
    ReceiverName           = RTRIM(Cast(fa.TrN_OdbNazwa1 + ' ' + fa.TrN_OdbNazwa2  + ' ' + fa.TrN_OdbNazwa3 As NVARCHAR(175))),
    ReceiverStreetAndNumber= RTRIM(Cast(fa.TrN_OdbUlica  + ' ' + fa.TrN_OdbNrDomu  + (CASE LEN(fa.TrN_OdbNrLokalu) WHEN  0 THEN '' ELSE '/' + fa.TrN_OdbNrLokalu END ) As NVARCHAR(35))),
    ReceiverStreet         = Cast(fa.TrN_OdbUlica As NVARCHAR(40)),
    ReceiverStreetNumber1  = Cast(fa.TrN_OdbNrDomu As NVARCHAR(40)),
    ReceiverStreetNumber2  = Cast(fa.TrN_OdbNrLokalu As NVARCHAR(40)),
    ReceiverCityName       = Cast(fa.TrN_OdbMiasto  As NVARCHAR(40)),
    ReceiverPostalCode     = Cast(fa.TrN_OdbKodPocztowy As NVARCHAR(9)),
    ReceiverCountry        = IsNull((Select Knt_KrajISO From cdn.Kontrahenci Join cdn.TraNag As faOdb On faOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And faOdb.TrN_OdbId=Knt_KntId  Where faOdb.TrN_TrnId=fa.TrN_TrnId), 'PL'),
    ReceiverCountryName    = Cast(fa.TrN_OdbKraj  As NVARCHAR(40)),
    SellerILN    = CDN.PieczatkaFirmyWartosc(1165, @pcId),
    SellerTaxIdPrefix  = CDN.PieczatkaFirmyWartosc(1169, @pcId),
    SellerTaxID    = CDN.PieczatkaFirmyWartosc(1101, @pcId),
    SellerAccountNumber    = IsNull((Select BRa_RachunekNr From Cdn.FormyPlatnosci Join Cdn.BnkRachunki ON Fpl_BraId=BRa_BraId Join Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID Where BRa_Typ = 2 And Fpl_FPlID=fa.TrN_FPlId), ''),
    SellerBankName     = RTRIM(IsNull((Select BNa_Nazwa1 + SPACE(1) + BNa_Nazwa2 From Cdn.FormyPlatnosci Join Cdn.BnkRachunki ON Fpl_BraId=BRa_BraId Join Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID Where BRa_Typ = 2 And Fpl_FPlID=fa.TrN_FPlId), '')),
    SellerName             = RTRIM(Cast( CDN.PieczatkaFirmyWartosc(1156, @pcId) + ' ' + CDN.PieczatkaFirmyWartosc(1157, @pcId) As NVARCHAR(175))),
    SellerStreetAndNumber  = RTRIM(Cast( CDN.PieczatkaFirmyWartosc(1149, @pcId)
          + ' '
          + CDN.PieczatkaFirmyWartosc(1150, @pcId)
                                  + CASE LEN(CDN.PieczatkaFirmyWartosc(1151, @pcId)) WHEN  0 THEN '' ELSE '/' + CDN.PieczatkaFirmyWartosc(1151, @pcId) END
                                As NVARCHAR(35))),
    SellerName1            = Cast(CDN.PieczatkaFirmyWartosc(1156, @pcId) As NVARCHAR(254)),
    SellerName2            = Cast(CDN.PieczatkaFirmyWartosc(1157, @pcId) As NVARCHAR(254)),
    SellerStreet           = Cast(CDN.PieczatkaFirmyWartosc(1149, @pcId) As NVARCHAR(40)),
    SellerStreetNumber1    = Cast(CDN.PieczatkaFirmyWartosc(1150, @pcId) As NVARCHAR(40)),
    SellerStreetNumber2    = Cast(CDN.PieczatkaFirmyWartosc(1151, @pcId) As NVARCHAR(40)),
    SellerCityName         = CAST(CDN.PieczatkaFirmyWartosc(1152, @pcId) As NVARCHAR(40)),
    SellerPostalCode       = CAST(CDN.PieczatkaFirmyWartosc(1153, @pcId) As NVARCHAR(9)),
    SellerCountry          = CAST(CDN.PieczatkaFirmyWartoscWithDefault(1169, @pcId,'PL') As NVARCHAR(9)),
    SellerCountryName      = CAST(CDN.PieczatkaFirmyWartoscWithDefault(1145, @pcId,'Polska') As NVARCHAR(40)),
    PayeeILN               = CASE cdn.PieczatkaFirmyWartosc(1166, @pcId) WHEN '' THEN CDN.PieczatkaFirmyWartosc(1165, @pcId) ELSE CDN.PieczatkaFirmyWartosc(1166, @pcId) END,
    PayeeTaxIdPrefix       = CDN.PieczatkaFirmyWartosc(1169, @pcId),
    PayeeTaxID             = CDN.PieczatkaFirmyWartosc(1101, @pcId),
    PayeeAccountNumber     = IsNull((Select BRa_RachunekNr From Cdn.FormyPlatnosci Join Cdn.BnkRachunki ON Fpl_BraId=BRa_BraId Join Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID Where BRa_Typ = 2 And Fpl_FPlID=fa.TrN_FPlId), ''),
    PayeeName              = Cast(CDN.PieczatkaFirmyWartosc(1156, @pcId) + ' ' + CDN.PieczatkaFirmyWartosc(1157, @pcId) As NVARCHAR(175)),
    PayeeStreetAndNumber   = RTRIM(Cast(
          CDN.PieczatkaFirmyWartosc(1149, @pcId) + ' ' + CDN.PieczatkaFirmyWartosc(1150, @pcId)
                                + CASE LEN(CDN.PieczatkaFirmyWartosc(1151, @pcId)) WHEN  0 THEN '' ELSE '/' + CDN.PieczatkaFirmyWartosc(1151, @pcId) END
                                As NVARCHAR(35))),
    PayeeStreet            = Cast(CDN.PieczatkaFirmyWartosc(1149, @pcId) As NVARCHAR(40)),
    PayeeStreetNumber1     = Cast(CDN.PieczatkaFirmyWartosc(1150, @pcId) As NVARCHAR(40)),
    PayeeStreetNumber2     = Cast(CDN.PieczatkaFirmyWartosc(1151, @pcId) As NVARCHAR(40)),
    PayeeCityName          = CAST(CDN.PieczatkaFirmyWartosc(1152, @pcId) As NVARCHAR(40)),
    PayeePostalCode        = CAST(cdn.PieczatkaFirmyWartosc(1153, @pcId) As NVARCHAR(9)),
    PayeeCountry           = CAST(CDN.PieczatkaFirmyWartoscWithDefault(1169, @pcId, 'PL') As NVARCHAR(9)),
    PayeeCountryName       = CAST(CDN.PieczatkaFirmyWartoscWithDefault(1145, @pcId, 'Polska') As NVARCHAR(40))
    FROM cdn.TraNag fa
    WHERE fa.TrN_TrnId=@TrnID;
END
