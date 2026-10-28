-- SELECT CDN.IloscPoZostajeDlaTowaruNaRezerwacji(1,1)
CREATE FUNCTION CDN.IloscPoZostajeDlaTowaruNaRezerwacji(@twrId INT, @trnId INT)
RETURNS DECIMAL(20,4)
AS
BEGIN
 DECLARE @wynik DECIMAL(20,4), @rezerwacja DECIMAL(20,4), @zrealizowane DECIMAL(20,4)
 SET @rezerwacja = (SELECT Sum(TrE_Ilosc)
     FROM cdn.TraElem
     JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
     WHERE TrE_TwrId=@twrId AND TrE_TrNId = @trnId AND IsNull(TrN_ZwroconoCalaIlosc,0) < 3 AND TrN_Bufor <> -1
     GROUP BY TrE_TwrId)
 SET @zrealizowane = (SELECT Sum(ABS(IsNull(TrS_Ilosc, 0)))
      FROM cdn.TraElem
      JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
      LEFT OUTER JOIN cdn.TraSElem ON TrS_TrEID = TrE_TrEId AND TrS_TrEIdWydania <> 0
      WHERE TrE_TwrId=@twrId AND TrE_TrNId = @trnId AND IsNull(TrN_ZwroconoCalaIlosc,0) < 3 AND TrN_Bufor <> -1)
 IF @rezerwacja Is Null SET @rezerwacja = 0
 IF @zrealizowane Is Null SET @zrealizowane = 0
   SET @wynik = @rezerwacja - @zrealizowane
   IF @wynik < 0 SET @wynik = 0
 RETURN @wynik
END
