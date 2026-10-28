CREATE FUNCTION CDN.SrsZlecenieFakturowano ( @SrsZlecenieId INT, @mode INT )
-- 0  sprawdź, czy fakturowano cześci lub czynności
-- e_op_KlasaSerwisCzynnosci - 901 - sprawdź dla czynności
-- e_op_KlasaSerwisCzesci - 902 - sprawdź dla czesci
  RETURNS    INT
AS
BEGIN
 DECLARE @wynik INT, @autoItem INT
 SET @autoItem = 255
 SET @wynik = 0
 IF @SrsZlecenieId = 0
  GOTO KONIEC
 DECLARE @wydano INT
 IF @mode = 0
 BEGIN
  SELECT @wydano = Count(*) FROM cdn.DokRelacje
      WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId
        AND DoR_DokumentTyp IN (302, 304, 305, 306) AND DoR_Flaga = @autoItem
  GOTO KONIEC
 END
 IF @mode = 901
 BEGIN
  SELECT @wydano = Count(*) FROM cdn.TraElemRelacje
  WHERE TeR_ParentTyp = 901 AND TeR_ParentId IN ( SELECT SrY_SrYId FROM cdn.SrsCzynnosci WHERE SrY_SrZId = @SrsZlecenieId)
   AND TeR_ChildTyp IN (302, 304, 305, 306)
  GOTO KONIEC
 END
 IF @mode = 902
 BEGIN
  SELECT @wydano = Count(*) FROM cdn.TraElemRelacje
  WHERE TeR_ParentTyp = 902 AND TeR_ParentId IN ( SELECT SrC_SrCId FROM cdn.SrsCzesci WHERE SrC_SrZId = @SrsZlecenieId)
   AND TeR_ChildTyp IN (302, 304, 305, 306)
  GOTO KONIEC
 END
KONIEC:
 IF @wydano > 0
 SET @wynik = 1
 RETURN  @wynik
END
