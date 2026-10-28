-- SELECT CDN.IloscNaWybranychRezerwacjach(1,1, '1,2,3')
CREATE FUNCTION CDN.IloscNaWybranychRezerwacjach(@twrId INT, @magId INT, @wybraneRO TEXT)
RETURNS DECIMAL(20,4)
AS
BEGIN
 DECLARE @wynik DECIMAL(20,4)
    SET @wynik = ( SELECT  Sum( CDN.IloscPoZostajeDlaTowaruNaRezerwacji(@twrId, TrN_TrNId) ) AS Obroty
     FROM cdn.TraNag
     WHERE       TrN_TypDokumentu=308
       AND IsNull(TrN_ZwroconoCalaIlosc,0) < 3 AND TrN_Bufor <> -1
       AND (@magId=0 OR TrN_MagZrdId = @magId)
           AND TrN_TrNId IN (SELECT NextIdInt FROM CDN.Text2TableInt(@wybraneRO))
       AND TrN_Korekta <= 1
 )
 IF @wynik Is Null
  SET @wynik = 0
 RETURN @wynik
END
