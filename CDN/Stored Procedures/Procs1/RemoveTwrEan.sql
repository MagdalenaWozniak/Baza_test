CREATE PROCEDURE cdn.RemoveTwrEan
 @twrId   INT,
 @ean   VARCHAR(40) = '',
 @removeDefault INT = 0,
 @selectTwrKod INT = 0,
 @rejestrOperacji INT = 1
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE
 @Kod NVARCHAR(50),
 @zmodyfikowanoTwr INT
 SET @zmodyfikowanoTwr = 0
 SELECT @Kod = Twr_Kod FROM cdn.Towary WHERE Twr_TwrId = @twrId
 IF @ean IS NULL OR @ean = ''
 BEGIN
  IF( @removeDefault = 1 )
  BEGIN
   UPDATE CDN.Towary SET Twr_EAN = '', Twr_TS_mod = GetDate() WHERE Twr_TwrId = @twrId
   SET @zmodyfikowanoTwr = 1
   DELETE CDN.TwrEan WHERE TwE_TwrId = @twrId  AND TwE_Domyslny = 1
  END
  ELSE
  BEGIN
   DELETE CDN.TwrEan WHERE TwE_TwrId = @twrId AND TwE_Domyslny = 0
   SET @zmodyfikowanoTwr = 1
  END
 END
 ELSE
 BEGIN
  IF( @removeDefault = 1 )
  BEGIN
   UPDATE CDN.Towary SET Twr_EAN = '', Twr_TS_mod = GetDate() WHERE Twr_TwrId = @twrId AND Twr_Ean = @ean
   SET @zmodyfikowanoTwr = 1
   DELETE CDN.TwrEan WHERE TwE_TwrId = @twrId AND TwE_Ean = @ean AND TwE_Domyslny = 1
  END
  ELSE
  BEGIN
   DELETE CDN.TwrEan WHERE TwE_TwrId = @twrId AND TwE_Ean = @ean AND TwE_Domyslny = 0
   SET @zmodyfikowanoTwr = 1
  END
 END
 IF @rejestrOperacji = 1 AND @zmodyfikowanoTwr = 1
 BEGIN
  EXEC [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 END
 IF @selectTwrKod = 1
  SELECT Twr_Kod FROM CDN.Towary WHERE Twr_TwrId = @twrId
 SET NOCOUNT OFF;
END
