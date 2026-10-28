CREATE PROCEDURE [CDN].[ZwrocIdTowarAIP]
   @Towar                  NVARCHAR(255)
  ,@TrNID                  INT
AS
SET NOCOUNT ON
DECLARE @TowarID INT
DECLARE @TowarEAN VARCHAR(255)
SET @TowarEAN  = cast(@Towar as VARCHAR(255))
BEGIN
 IF @TowarID is null
     BEGIN
       SELECT  TOP 1 @TowarID=Twr_TwrID  FROM CDN.Towary
       left JOIN CDN.TwrEan on Twr_TwrId = Twe_twrid
       WHERE (Twe_EAN=@TowarEAN or Twr_Kod=@Towar or Twr_PLU=@Towar)
       ORDER BY  CASE WHEN Twe_EAN =@TowarEAN THEN 1 WHEN Twr_Kod =@Towar THEN 2 WHEN Twr_Kod =@Towar THEN 3 END
     END
     IF @TowarID is null
   IF ((SELECT COUNT(Twr_Nazwa) FROM CDN.Towary WHERE Twr_Nazwa=@Towar )>1)
   SET @TowarID = 0
   ELSE
     SELECT  TOP 1 @TowarID=Twr_TwrID  FROM CDN.Towary
     WHERE Twr_Nazwa=@Towar
     ORDER BY  Twr_Kod,Twr_Nazwa
     IF (@TrNID = 0)
     BEGIN
  IF EXISTS(SELECT TOP 1 Twe_TwrID FROM CDN.TwrEAN WHERE Twe_EAN=@TowarEAN)
   SELECT TOP 1 Twr_TwrId as TrE_TwrId,Twr_Kod as TrE_TwrKod,Twr_Nazwa as TrE_TwrNazwa,@TowarEAN as TrE_TwrEAN,Twe_JM as TrE_JM,Twr_JM as TrE_JMZ,0 as TrE_TrEId , Twr_Typ
   FROM CDN.towary
   left JOIN CDN.TwrEan on Twr_TwrId = Twe_twrid
   WHERE Twe_EAN=@TowarEAN
  ELSE
   SELECT TOP 1 Twr_TwrId as TrE_TwrId,Twr_Kod as TrE_TwrKod,Twr_Nazwa as TrE_TwrNazwa,'' as TrE_TwrEAN,Twr_JM as TrE_JM,Twr_JM as TrE_JMZ,0 as TrE_TrEId, Twr_Typ  FROM CDN.towary
   WHERE twr_twrid=@TowarID
  END
  ELSE
  BEGIN
     IF EXISTS(SELECT TOP 1 Twe_TwrID FROM CDN.TwrEAN WHERE Twe_EAN=@TowarEAN)
   SELECT TOP 1 Twr_TwrId as TrE_TwrId,Twr_Kod as TrE_TwrKod,Twr_Nazwa as TrE_TwrNazwa,@TowarEAN as TrE_TwrEAN,Twe_JM as TrE_JM,Twr_JM as TrE_JMZ,TrE_TrEId as TrE_TrEId , Twr_Typ  FROM CDN.towary
   left JOIN CDN.TwrEan on Twr_TwrId = Twe_twrid
   Join CDN.TraElem on TrE_TwrId = twr_twrid AND TrE_trnid = @TrNID
   WHERE Twe_EAN=@TowarEAN
     ELSE
   SELECT TOP 1 TrE_TwrId,TrE_TwrKod,TrE_TwrNazwa,TrE_TwrEAN,TrE_JM,TrE_JMZ,TrE_TrEId,0 FROM CDN.TraElem WHERE TrE_TwrId=@TowarID AND TrE_trnid = @TrNID
  END
 END
SET NOCOUNT OFF
