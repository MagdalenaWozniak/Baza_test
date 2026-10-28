CREATE  FUNCTION CDN.EcodPutDeliveryAddress (@podmiotTyp INT, @podmiotId INT)
RETURNS TINYINT
AS
BEGIN
 DECLARE @wynik TINYINT
 SET @wynik = 0
 IF EXISTS(SELECT * FROM CDN.KntAtrybuty JOIN CDN.DefAtrybuty ON DeA_DeAId = KnA_DeAId AND DeA_Typ=2 AND DeA_Kod='DELIVERYADDRESS'
    WHERE KnA_PodmiotTyp = @podmiotTyp AND KnA_PodmiotId = @podmiotId AND Upper(KnA_WartoscTxt) = 'TAK')
  SET @wynik = 1
 RETURN @wynik
END
