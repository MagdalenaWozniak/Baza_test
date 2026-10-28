CREATE FUNCTION CDN.EcodBuyerOrderDateOnlyOne ( @TrnID INT, @ZwrID INT, @TrE_LpPow INT)
  RETURNS     nvarchar(10)
  AS
  BEGIN
 DECLARE @BuyerOrderDate nvarchar(10)
 SET @BuyerOrderDate = ''
 DECLARE @ID INT
 IF @TrE_LpPow > 0 AND @ZwrID > 0
  SET @ID = @ZwrID
 ELSE
  SET @ID = @TrnID
 -- TRACK ID=146991
 SELECT @BuyerOrderDate = (SELECT TOP 1 Convert(nvarchar(10),DateAdd( day, CAST(DAt_WartoscTxt AS INT) ,CONVERT(DATETIME,'1800-12-28',120)), 120)  FROM CDN.DokAtrybuty
         WHERE DAt_TrNID=@ID AND DAt_Kod = 'BUYERORDERDATE'  ORDER BY DAT_DATID)
 IF @BuyerOrderDate Is NULL  SET @BuyerOrderDate = ''
 IF @BuyerOrderDate = ''
 BEGIN
  IF @TrE_LpPow > 0
  BEGIN
   SELECT TOP 1 @BuyerOrderDate = (Select TOP 1 Convert(nvarchar(10), ro.TrN_DataOpe, 120)
     FROM  cdn.TraNag  As ro
     WHERE ro.TrN_TrNId IN (SELECT TrN_TrNId from cdn.Powiazania(@TrnId, 302) WHERE TrN_TypDokumentu = 308))
   IF @BuyerOrderDate Is NULL  SET @BuyerOrderDate = ''
   IF @BuyerOrderDate = ''
    SELECT TOP 1 @BuyerOrderDate = (SELECT TOP 1 Convert(nvarchar(10), ro.TrN_DataOpe, 120)
     FROM  cdn.TraNag  As ro
     JOIN  cdn.TraNag  As wz     On ro.TrN_FaId=wz.TrN_TrNId And ro.TrN_TypDokumentu=308 And wz.TrN_TrNId IN (SELECT TrN_TrNId from cdn.Powiazania(@TrnId, 302) WHERE TrN_TypDokumentu = 306))
   IF @BuyerOrderDate Is NULL  SET @BuyerOrderDate = ''
  END
  ELSE
  BEGIN
   SET @BuyerOrderDate = (SELECT TOP 1 Convert(nvarchar(10), TrN_DataOpe, 120) FROM CDN.TraNag WHERE TrN_TrNId IN (SELECT TOP 1  TrN_TrNId from cdn.Powiazania(@TrnId, 302) WHERE TrN_TypDokumentu = 308))
  END
  IF @BuyerOrderDate Is NULL  SET @BuyerOrderDate = ''
  IF @BuyerOrderDate = ''  AND @ZwrID > 0 AND @TrE_LpPow=0 -- ECOD - eksport korekty do ECOD - w pola numeru i daty zamówienia przenosic dane z zamówienia do faktury korygowanej.
  BEGIN
   SET @BuyerOrderDate = (SELECT TOP 1 Convert(nvarchar(10), TrN_DataOpe, 120) FROM CDN.TraNag WHERE TrN_TrNId IN (SELECT TOP 1  TrN_TrNId from cdn.Powiazania(@ZwrID, 302) WHERE TrN_TypDokumentu = 308))
   IF @BuyerOrderDate is NULL
    SET @BuyerOrderDate = ''
  END
 END
KONIEC:
 RETURN @BuyerOrderDate
END
