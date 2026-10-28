CREATE  FUNCTION CDN.EcodElemBuyerItemCode(@treId INT, @twrId INT, @podmiotTyp INT, @podmiotId INT)
RETURNS NVARCHAR(35)
BEGIN
 DECLARE @buyerItemCode NVARCHAR(35)
 --IF @treId > 0
 --BEGIN
  --SELECT @buyerItemCode = Substring(TrA_Wartosc,1,35)
  --FROM cdn.TraElemAtr
  --JOIN CDN.DefAtrybuty ON TrA_DeAId=DeA_DeAId
  --WHERE DeA_Kod = 'BUYERITEMCODE' AND TrA_TrEId = @treId
 --END
 IF @buyerItemCode IS NULL
 BEGIN
  SET @buyerItemCode = CDN.EcodBuyerItemCode(@twrId, @podmiotTyp, @podmiotId)
 END
 RETURN @buyerItemCode
END
