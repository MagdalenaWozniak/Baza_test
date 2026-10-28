CREATE FUNCTION CDN.EcodBuyerOrderNumberOnlyOne ( @TrnID INT, @ZwrID INT, @TrE_LpPow INT )
  RETURNS     nvarchar(35)
  AS
  BEGIN
 DECLARE @BuyerOrderNumber nvarchar(35)
 SET @BuyerOrderNumber = ''
 DECLARE @ID INT
 IF @TrE_LpPow > 0 AND @ZwrID > 0
  SET @ID = @ZwrID
 ELSE
  SET @ID = @TrnID
 -- TRACK ID=146991
 SELECT @BuyerOrderNumber = (SELECT TOP 1 DAt_WartoscTxt FROM CDN.DokAtrybuty JOIN CDN.DefAtrybuty ON DAt_DeAId=DeA_DeAId
        WHERE DAt_TrNID=@ID AND DeA_Kod = 'BUYERORDERNUMBER'  ORDER BY DAT_DATID)
 IF @BuyerOrderNumber Is Null SET @BuyerOrderNumber = ''
 IF @BuyerOrderNumber = ''
 BEGIN
  IF @TrE_LpPow > 0
  BEGIN
   SELECT TOP 1 @BuyerOrderNumber = (SELECT TOP 1 ro.TrN_NumerObcy FROM  cdn.TraNag  As ro
             WHERE ro.TrN_TrNId IN (SELECT TrN_TrNId from cdn.Powiazania(@TrnId, 302) WHERE TrN_TypDokumentu = 308))
   IF @BuyerOrderNumber Is Null SET @BuyerOrderNumber = ''
   IF @BuyerOrderNumber = ''
     SELECT TOP 1 @BuyerOrderNumber = (SELECT TOP 1 ro.TrN_NumerObcy FROM  cdn.TraNag  As ro
     JOIN  cdn.TraNag  As wz On ro.TrN_FaId=wz.TrN_TrNId And ro.TrN_TypDokumentu=308
     And wz.TrN_TrNId IN (SELECT TrN_TrNId from cdn.Powiazania(@TrnId, 302) WHERE TrN_TypDokumentu = 306))
   IF @BuyerOrderNumber Is Null SET @BuyerOrderNumber = ''
  END
  ELSE
  BEGIN
   SET @BuyerOrderNumber = (SELECT TOP 1 TrN_NumerObcy FROM CDN.TraNag WHERE TrN_TrNId IN (SELECT TrN_TrNId from cdn.Powiazania(@TrnId, 302) WHERE TrN_TypDokumentu = 308))
  END
  IF @BuyerOrderNumber is NULL SET @BuyerOrderNumber = ''
  IF @BuyerOrderNumber = ''  AND @ZwrID > 0 AND @TrE_LpPow=0 -- ECOD - eksport korekty do ECOD - w pola numeru i daty zamówienia przenosic dane z zamówienia do faktury korygowanej.
  BEGIN
   SET @BuyerOrderNumber = (SELECT TOP 1 TrN_NumerObcy FROM CDN.TraNag WHERE TrN_TrNId IN (SELECT TrN_TrNId from cdn.Powiazania(@ZwrID, 302) WHERE TrN_TypDokumentu = 308))
   IF @BuyerOrderNumber is NULL SET @BuyerOrderNumber = ''
  END
 END
KONIEC:
 RETURN @BuyerOrderNumber
END
