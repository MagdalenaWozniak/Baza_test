-- wyraź ilość jm w orgJM
CREATE FUNCTION CDN.PrzeliczIloscJMDlaTowaru(@twrId INT, @ilosc DECIMAL(20,4), @jm NVARCHAR(20), @requestedJm NVARCHAR(20))
RETURNS DECIMAL(20,4)
AS
BEGIN
 IF lower(@jm) = lower(@requestedJm) RETURN @ilosc
    DECLARE @przelicznikL DECIMAL(15,2), @przelicznikM DECIMAL(15,2), @twrJM NVARCHAR(20)
 SELECT TOP 1 @twrJM = Twr_Jm FROM cdn.Towary WHERE Twr_TwrId = @twrId
 IF @twrJM IS NULL SET @twrJM = ''
 IF @twrJM = '' SET @twrJM = @jm
 IF  @jm = @twrJM
 BEGIN
  SELECT TOP 1 @przelicznikL = TwJZ_JMPrzelicznikL, @przelicznikM = TwJZ_JMPrzelicznikM FROM cdn.TwrJMZ WHERE TwJZ_TwrId = @twrId AND TwJZ_JM = @requestedJm AND TwJZ_eSklepID = 0
  DECLARE @liczba DECIMAL(15,2)
  SET @liczba = @przelicznikM
  SET @przelicznikM = @przelicznikL
  SET @przelicznikL = @liczba
 END
 ELSE
 BEGIN
  IF @requestedJm = @twrJM
  BEGIN
   SELECT TOP 1 @przelicznikL = TwJZ_JMPrzelicznikL, @przelicznikM = TwJZ_JMPrzelicznikM FROM cdn.TwrJMZ WHERE TwJZ_TwrId = @twrId AND TwJZ_JM = @jm AND TwJZ_eSklepID = 0
   IF @przelicznikL IS NULL SET @przelicznikL = 1.00
   IF @przelicznikM IS NULL SET @przelicznikM = 1.00
  END
  ELSE
  BEGIN
   SELECT TOP 1 @przelicznikL = TwJZ_JMPrzelicznikL, @przelicznikM = TwJZ_JMPrzelicznikM FROM cdn.TwrJMZ WHERE TwJZ_TwrId = @twrId AND TwJZ_JM = @jm AND TwJZ_eSklepID = 0
   IF @przelicznikL IS NULL SET @przelicznikL = 1.00
   IF @przelicznikM IS NULL SET @przelicznikM = 1.00
      DECLARE @przelicznikL_2 DECIMAL(15,2), @przelicznikM_2 DECIMAL(15,2)
   SELECT TOP 1 @przelicznikL_2 = TwJZ_JMPrzelicznikL, @przelicznikM_2 = TwJZ_JMPrzelicznikM FROM cdn.TwrJMZ WHERE TwJZ_TwrId = @twrId AND TwJZ_JM = @requestedJm AND TwJZ_eSklepID = 0
   IF @przelicznikL_2 IS NULL SET @przelicznikL_2 = 1.00
   IF @przelicznikM_2 IS NULL SET @przelicznikM_2 = 1.00
   SET @przelicznikL = @przelicznikL * @przelicznikM_2
   SET @przelicznikM = @przelicznikM * @przelicznikL_2
   IF @przelicznikL IS NULL SET @przelicznikL = 1.00
   IF @przelicznikM IS NULL SET @przelicznikM = 1.00
  END
 END
 IF @przelicznikL IS NULL SET @przelicznikL = 1.00
 IF @przelicznikM IS NULL SET @przelicznikM = 1.00
 RETURN CDN.PrzeliczIloscJM(@ilosc, @przelicznikL, @przelicznikM)
END
