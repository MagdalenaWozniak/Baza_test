CREATE FUNCTION CDN.fnSrC_WartoscZakupu ( @SrC_SrCId INT )
RETURNS DECIMAL(15,2)
AS
BEGIN
 DECLARE @wynik DECIMAL(15,2)
 SET @wynik = 0.00
 IF EXISTS( SELECT * FROM CDN.TraElemRelacje WHERE TeR_ParentTyp=902 AND TeR_ParentId=@SrC_SrCId AND TeR_ChildTyp IN (304,306))
 BEGIN
  DECLARE  @TrE_TrEId INT, @TrE_TrNId INT, @TrE_LpPow INT, @TrE_TwrId INT
  SELECT TOP 1  @TrE_TrEId = TrE_TrEId, @TrE_TrNId = TrE_TrNId, @TrE_LpPow = TrE_LpPow, @TrE_TwrId = TrE_TwrId
  FROM CDN.TraElemRelacje
  JOIN CDN.TraElem ON TeR_ChildTyp = TrE_TypDokumentu AND TeR_ChildId = TrE_TrEId
  WHERE TeR_ParentTyp=902 AND TeR_ParentId=@SrC_SrCId AND TeR_ChildTyp IN (304,306)
  IF IsNull(@TrE_TrEId, 0) <> 0
   SET @wynik = CDN.fnTrE_WartoscZakupu( @TrE_TrEId, @TrE_TrNId, @TrE_LpPow, @TrE_TwrId)
 END
 ELSE
 BEGIN
  SELECT TOP 1  @wynik = SrC_WartoscZakupuWylicz FROM CDN.SrsCzesci WHERE SrC_SrCId = @SrC_SrCId
 END
 RETURN IsNull(@wynik, 0.00)
END
