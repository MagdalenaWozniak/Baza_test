CREATE  FUNCTION CDN.CzySaAtrybuty (@PodTyp Int, @PodId Int, @TwrId Int)
Returns tinyint
AS
BEGIN
DECLARE @Wynik tinyint
   if exists(          SELECT TwA_DeAID,DeA_Kod, ISNULL(TKA_Wartosctxt,TwA_Wartosctxt) FROM cdn.twratrybuty
          JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          LEFT JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID and TKA_PodmiotID = @PodId AND TKA_PodmiotTyp = @PodTyp
          WHERE TwA_CzyPrzenosic = 1  AND TwA_TwrID = @TwrId )
   select  @Wynik=1 else select  @Wynik=0
  RETURN @Wynik
END
