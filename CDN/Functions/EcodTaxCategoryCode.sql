-- funkcja zwraca oznaczenie kodowe stawki VAT dla systemu ECOD
CREATE FUNCTION CDN.EcodTaxCategoryCode ( @StawkaVAT DECIMAL, @Flaga INT, @faId INT )
  RETURNS     nvarchar(2)
  AS
  BEGIN
  IF @StawkaVAT = 0 AND @Flaga = 4 AND @faId IS NOT NULL
  BEGIN
 DECLARE @statusKnt INT
 SELECT TOP 1 @statusKnt = TrN_Export FROM cdn.TraNag WHERE TrN_TrnId = @faId
 IF @statusKnt IS NOT NULL AND @statusKnt = 5  RETURN 'AE'  -- odwrotne obciążenie
  END
  DECLARE @StawkaEcod nvarchar(2)
  SET @StawkaEcod =
    CASE
      WHEN @StawkaVAT=0 AND @Flaga=1 THEN 'E' --zwolniona
      WHEN @StawkaVAT=0 AND @Flaga=4 THEN 'NA'  --nie podlega
      ELSE 'S'
    END
  RETURN @StawkaEcod
END
