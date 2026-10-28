CREATE FUNCTION CDN.DrukowacAtrybuty (@DeaID INT, @TwrID INT)
RETURNS TINYINT
AS
BEGIN
   DECLARE @Drukowac TINYINT
 BEGIN
   IF EXISTS (SELECT * FROM CDN.TwrAtrybuty WHERE TwA_DeAID = @DeAID AND
     Twa_TwrID = @TwrID)
          SELECT  @Drukowac = Twa_CzyDrukowac from CDN.TwrAtrybuty WHERE TwA_DeAID = @DeAID
    AND  Twa_TwrID = @TwrID
   ELSE
          SELECT @Drukowac = DeA_CzyDrukowac FROM CDN.DefAtrybuty WHERE DeA_DeAID = @DeAID
 END
    RETURN @Drukowac
END
