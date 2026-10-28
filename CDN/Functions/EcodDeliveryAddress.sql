-- funkcja zwraca oznaczenie kodowe stawki VAT dla systemu ECOD
CREATE FUNCTION CDN.EcodDeliveryAddress ( @mode INT, @FaId INT )
RETURNS     nvarchar(175)
AS
BEGIN
 DECLARE @wynik nvarchar(175)
 DECLARE @wzID INT
    SELECT TOP 1 @wzID = TrR_FaId  FROM CDN.TraNagRelacje WHERE TrR_TrNTyp=302 AND TrR_TrNId = @faId AND TrR_FaTyp = 306
 IF @wzID is NULL  RETURN N''
 IF @mode = 1   -- @DeliveryName
  SELECT TOP 1 @wynik = Cast(wz.TrN_OdbNazwa1 + ' ' + wz.TrN_OdbNazwa2  + ' ' + wz.TrN_OdbNazwa3 As nvarchar(175)) FROM cdn.TraNag wz WHERE wz.TrN_TypDokumentu=306 AND TrN_TrNId = @wzID
 IF @mode = 2   --@DeliveryStreetAndNumber
  Select TOP 1 @wynik = Cast(wz.TrN_OdbUlica  + ' ' + wz.TrN_OdbNrDomu  + (CASE LEN(wz.TrN_OdbNrLokalu) WHEN  0  THEN '' ELSE '/' + wz.TrN_OdbNrLokalu END ) As nvarchar(140)) FROM cdn.TraNag wz WHERE wz.TrN_TypDokumentu=306 AND wz.TrN_TrNId = @wzID
 IF @mode = 3   --@DeliveryCityName
  Select TOP 1 @wynik = Cast(wz.TrN_OdbMiasto  As nvarchar(40)) FROM cdn.TraNag wz WHERE wz.TrN_TypDokumentu=306 AND wz.TrN_TrNId = @wzID
 IF @mode = 4   --@DeliveryPostalCode
  Select TOP 1 @wynik = Cast(wz.TrN_OdbKodPocztowy As nvarchar(9)) FROM cdn.TraNag wz WHERE wz.TrN_TypDokumentu=306 AND wz.TrN_TrNId = @wzID
 IF @mode = 5   --@DeliveryCountry
  Select  TOP 1 @wynik = Knt_KrajISO From cdn.Kontrahenci Join cdn.TraNag As wzOdb On wzOdb.TrN_OdbiorcaTyp=Knt_PodmiotTyp And wzOdb.TrN_OdbId=Knt_KntId WHERE wzOdb.TrN_TypDokumentu=306 AND wzOdb.TrN_TrNId = @wzID
 IF @wynik IS NULL
 BEGIN
  IF @mode = 5
   SET @wynik = 'PL'
  ELSE
   SET @wynik = ''
 END
  RETURN RTRIM(@wynik)
END
