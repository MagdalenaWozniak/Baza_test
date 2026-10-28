-- SELECT CDN.IloscSprzedana(1, '2009-08-01 00:00:00.000', '2009-08-13 00:00:00.000')
CREATE FUNCTION CDN.IloscSprzedana(@twrId INT,@magId INT, @dataOd DATETIME, @dataDo DATETIME)
RETURNS DECIMAL(20,4)
AS
BEGIN
 DECLARE @wynik DECIMAL(20,4)
    SET @wynik = (SELECT  Sum(TrE_Ilosc) AS Obroty
 FROM cdn.TraElem JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
 WHERE   TrE_TwrId = @twrId AND TrE_Aktywny = 1
       AND TrN_DataDok BETWEEN @dataOd AND @dataDo AND TrN_Bufor<>-1
   AND (@magId=0 OR TrN_MagZrdId = @magId)
   AND TrN_Korekta <= 1
   AND TrN_Rodzaj <> 302100
      AND (TrN_TypDokumentu=302 OR  TrN_TypDokumentu=305)
  )
 IF @wynik Is Null
  SET @wynik = 0
 RETURN @wynik
END
