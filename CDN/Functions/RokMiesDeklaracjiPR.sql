CREATE FUNCTION CDN.RokMiesDeklaracjiPR(@BZdID INT)
RETURNS INT
AS
BEGIN
 DECLARE @retVal INT
 DECLARE @DkNID INT
 DECLARE @podTyp INT
 DECLARE @podID INT
 DECLARE @terminRok INT
 DECLARE @terminMies TINYINT
 SELECT @DkNID = BZd_DokumentID, @podTyp = BZd_PodmiotTyp, @podID = BZd_PodmiotID, @terminRok = YEAR(BZd_Termin), @terminMies = MONTH(BZd_Termin) FROM cdn.BnkZdarzenia WHERE BZd_BZdID = @BZdID
 IF IsNull(@DkNID, 0) <> 0
 BEGIN
  --Płatność związana z deklaracją
  SELECT @retVal = DkN_RokMiesiac FROM cdn.DeklNag WHERE DkN_DkNID = @DkNID
  RETURN @retVal
 END
 SELECT @retVal = NULL
 --Płatność ręczna
 IF @podTyp = 5 AND (SELECT Urz_Standardowy FROM cdn.Urzedy WHERE Urz_UrzID = @podID) = 1
 BEGIN
  IF @terminMies > 1
   SELECT @retVal = 100*@terminRok + (@terminMies - 1)
  ELSE
   SELECT @retVal = 100*(@terminRok - 1) + 12
 END
 RETURN @retVal
END
