CREATE FUNCTION CDN.OpisDeklaracjiPR(@BZdID INT)
RETURNS NVARCHAR(1024)
AS
BEGIN
 DECLARE @retVal NVARCHAR(1024)
 DECLARE @DkNID INT
 DECLARE @podTyp INT
 DECLARE @podID INT
 DECLARE @terminRok INT
 DECLARE @terminMies TINYINT
 SELECT @retVal = BZd_Opis, @podTyp = BZd_PodmiotTyp, @podID = BZd_PodmiotID, @terminRok = YEAR(BZd_Termin), @terminMies = MONTH(BZd_Termin) FROM cdn.BnkZdarzenia WHERE BZd_BZdID = @BZdID
 IF IsNull(@retVal, '') <> ''
  RETURN @retVal
 SELECT @retVal = ''
 IF @podTyp = 5 AND (SELECT Urz_Standardowy FROM cdn.Urzedy WHERE Urz_UrzID = @podID) = 1
 BEGIN
  IF @terminMies = 1
   SELECT @terminMies = 12, @terminRok = @terminRok - 1
  ELSE
   SELECT @terminMies = @terminMies - 1
  SELECT @retVal = '01'
  IF @terminMies < 10
   SELECT @retVal = @retVal + '0' + CONVERT(CHAR(1), @terminMies)
  ELSE
   SELECT @retVal = @retVal + CONVERT(CHAR(2), @terminMies)
  SELECT @retVal = 'Deklaracja DRA numer: ' + @retVal + CONVERT(CHAR(4), @terminRok)
 END
 RETURN @retVal
END
