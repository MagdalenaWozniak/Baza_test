CREATE PROCEDURE CDN.GenBrakiPWP
@Identyfikator int
AS
BEGIN
 SET NOCOUNT ON;
 -- Deklaracja tabeli tymczasowej #Rekordy
 IF OBJECT_ID('tempdb..#Rekordy') IS NOT NULL
 DROP TABLE #Rekordy
 CREATE TABLE #Rekordy (
  Twr_TwrID int,
  Twr_Kod NVARCHAR(50),
  Twr_Nazwa NVARCHAR(255),
  Twr_EAN NVARCHAR(40),
  Twr_NumerKat NVARCHAR(40),
  PdE_Ilosc decimal(16,4),
  PdE_Jm NVARCHAR(20),
  Mag_Symbol NVARCHAR(20),
  Mag_Nazwa NVARCHAR(50),
  Mag_MagID int,
  BrakiPWP decimal(16,4)
       )
 -- Wypełnienie zmiennej tabelarycznej @Rekordy
 INSERT INTO #Rekordy
 SELECT Twr_TwrId, Twr_Kod, Twr_Nazwa, Twr_EAN, Twr_NumerKat, SUM(PdE_Ilosc), PdE_Jm, Mag_Symbol, Mag_Nazwa, Mag_MagID, NULL
  FROM CDN.TraNag TRN JOIN CDN.TraElem TRE ON TRN.TrN_TrNID = TRE.TrE_TrNId
   JOIN CDN.ProdElem PRE ON TRE.TrE_TrEID = PRE.PdE_TrEId
    JOIN CDN.Towary TWR ON PRE.PdE_TwrId = TWR.Twr_TwrId
     JOIN CDN.Magazyny MGN ON PRE.PdE_MagId = MGN.Mag_MagId
      WHERE TrN_TrNID = @Identyfikator
       GROUP BY Mag_Symbol, Mag_Nazwa, Mag_MagID, Twr_TwrId, Twr_Kod, Twr_Nazwa, Twr_EAN, Twr_NumerKat, PdE_Jm
 -- Deklaracja zmiennych pomocniczych
 DECLARE @Data datetime
 SET @Data = (SELECT TrN_DataDok FROM CDN.TraNag WHERE TrN_TrNID = @Identyfikator)
 -- Wyliczenie braków dla składników
 -- Kursor
 DECLARE @KTwr_TwrID int
 DECLARE @KMag_MagID int
 DECLARE @KPdE_Ilosc decimal(16,4)
 DECLARE KursorPWP CURSOR FAST_FORWARD
 FOR SELECT Twr_TwrID, Mag_MagID, PdE_Ilosc FROM #Rekordy
 OPEN KursorPWP
 FETCH NEXT
 FROM KursorPWP
 INTO @KTwr_TwrID, @KMag_MagID, @KPdE_Ilosc
 WHILE @@FETCH_STATUS = 0
 BEGIN
  -- Pobieramy ilość z TwrIlosci i liczymy braki
  DECLARE @IloscTwI decimal(16,4)
  SET @IloscTwI = (SELECT TwI_Ilosc FROM CDN.TwrIlosci WHERE TwI_TwrId = @KTwr_TwrID AND TwI_MagId = @KMag_MagID AND TwI_Data = @Data)
  DECLARE @RezerwacjeTwI decimal(16,4)
  SET @RezerwacjeTwI = (SELECT TwI_Rezerwacje FROM CDN.TwrIlosci WHERE TwI_TwrId = @KTwr_TwrID AND TwI_MagId = @KMag_MagID AND TwI_Data = @Data)
  IF (@IloscTwI - @RezerwacjeTwI) >= 0
   BEGIN
    UPDATE #Rekordy SET BrakiPWP = -1 WHERE Twr_TwrID = @KTwr_TwrID AND Mag_MagID = @KMag_MagID
   END
   ELSE BEGIN
    IF (@IloscTwI - @RezerwacjeTwI) >= @KPdE_Ilosc
     BEGIN
      UPDATE #Rekordy SET BrakiPWP = @KPdE_Ilosc WHERE Twr_TwrID = @KTwr_TwrID AND Mag_MagID = @KMag_MagID
     END
     ELSE BEGIN
      UPDATE #Rekordy SET BrakiPWP = -(@IloscTwI - @RezerwacjeTwI) WHERE Twr_TwrID = @KTwr_TwrID AND Mag_MagID = @KMag_MagID
     END
   END
 FETCH NEXT FROM KursorPWP INTO @KTwr_TwrID, @KMag_MagID, @KPdE_Ilosc
 END
 CLOSE KursorPWP
 DEALLOCATE KursorPWP
 -- Pobranie wyników dla wydruku
 SELECT * FROM #Rekordy WHERE BrakiPWP > 0 ORDER BY Twr_TwrID
 SET NOCOUNT OFF;
END
