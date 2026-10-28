CREATE PROCEDURE CDN.WlascicieleDoPoliczenia @rok INT, @miesiac INT
 AS
 SET NOCOUNT ON
 DECLARE @miesiacTemp INT;
 DECLARE @praID INT, @wlasciciel NVARCHAR(100);
 DECLARE @liniowy INT, @kwartalny INT, @najem1 INT, @najem2 INT, @najem_L DECIMAL(6,2), @najem_M DECIMAL(6,2);
 CREATE TABLE #temp ( Pra_PraId INT, Wlasciciel NVARCHAR(100), Liniowy INT, Kwartalny INT, Najem1 INT, Najem2 INT);
 DECLARE wlascCursor CURSOR FAST_FORWARD
 FOR
 SELECT Pra_PraId,  Pri_Imie1 + ' ' + Pri_Nazwisko AS Wlasciciel
 FROM CDN.PracKod INNER JOIN CDN.PracIdx ON PRA_PraId=PRI_PraId
 LEFT OUTER JOIN CDN.PracEtaty ON PRA_PraId = PRE_PraId
 WHERE PRA_Archiwalny=0 AND Pri_Typ=2 AND DATEADD(DAY, 0, DATEADD(MONTH, @miesiac-1, DATEADD(YEAR, @rok-1900, 0))) BETWEEN PRE_DataOD AND PRE_DataDo
 ORDER BY PRE_MalzonekId, Wlasciciel
 OPEN wlascCursor
 FETCH NEXT FROM wlascCursor INTO @praID, @wlasciciel;
 WHILE @@FETCH_STATUS = 0
 BEGIN
 -- wyszukanie parametru czy rozliczanie liniowe
 SET @miesiacTemp = @miesiac;
 SET @liniowy = NULL;
 WHILE @liniowy IS NULL
 BEGIN
  SELECT TOP 1 @liniowy = CASE WHEN PPK_Wartosc IS NULL THEN NULL ELSE CAST(ISNULL(PPK_Wartosc,'0') AS INT) END
  FROM CDN.PracPitKwoty
  INNER JOIN CDN.PracPitMies ON PPK_PPMId=PPM_PPMId
  WHERE PPK_Numer = 21705 AND ( PPM_Rok < @rok OR (PPM_Rok=@rok AND PPM_Miesiac<=@miesiacTemp) ) AND PPM_PraID=@praID
  ORDER BY PPM_Rok DESC, PPM_Miesiac DESC
  SET @miesiacTemp = @miesiacTemp + 1;
  IF(@miesiacTemp % 3 = 1)
   BREAK;
 END
 -- wyszukanie parametru czy rozliczanie kwartalne
 SET @miesiacTemp = @miesiac;
 SET @kwartalny = NULL;
 WHILE @kwartalny IS NULL
 BEGIN
  SELECT TOP 1 @kwartalny = CASE WHEN PPK_Wartosc IS NULL THEN NULL ELSE CAST(ISNULL(PPK_Wartosc,'0') AS INT) END
  FROM CDN.PracPitKwoty
  INNER JOIN CDN.PracPitMies ON PPK_PPMId=PPM_PPMId
  WHERE PPK_Numer = 45205 AND ( PPM_Rok < @rok OR (PPM_Rok=@rok AND PPM_Miesiac<=@miesiacTemp) ) AND PPM_PraID=@praID
  ORDER BY PPM_Rok DESC, PPM_Miesiac DESC
  SET @miesiacTemp = @miesiacTemp + 1;
  IF(@miesiacTemp % 3 = 1)
   BREAK;
 END
 -- sprawdzanie udziałów najmu ma sens gdy właściciel rozlicza się liniowo
 -- dalsze sprawdzanie ma sens, gdy rozliczanie jest kwartalne albo znaleźlismy potrzebne kwoty do deklaracji w wybranym miesiącu
 IF( @liniowy > 0 )
 BEGIN
  -- wyszukanie udziałów 'L' w najmie
  SET @miesiacTemp = @miesiac;
  SET @najem_L = NULL;
  WHILE @najem_L IS NULL
  BEGIN
   SELECT TOP 1 @najem_L = CASE WHEN PPK_Wartosc IS NULL THEN NULL ELSE CAST(ISNULL(PPK_Wartosc,'0') AS DECIMAL(6,2)) END
   FROM CDN.PracPitKwoty
   INNER JOIN CDN.PracPitMies ON PPK_PPMId=PPM_PPMId
   WHERE PPK_Numer = 31001 AND ( PPM_Rok < @rok OR (PPM_Rok=@rok AND PPM_Miesiac<=@miesiacTemp) ) AND PPM_PraID=@praID
   ORDER BY PPM_Rok DESC, PPM_Miesiac DESC
   SET @miesiacTemp = @miesiacTemp + 1;
   IF(@miesiacTemp % 3 = 1)
    BREAK;
  END
  -- wyszukanie udziałów 'M' w najmie pierwszym
  SET @miesiacTemp = @miesiac;
  SET @najem_M = NULL;
  WHILE @najem_M IS NULL
  BEGIN
   SELECT TOP 1 @najem_M = CASE WHEN PPK_Wartosc IS NULL THEN NULL ELSE CAST(ISNULL(PPK_Wartosc,'0') AS DECIMAL(6,2)) END
   FROM CDN.PracPitKwoty
   INNER JOIN CDN.PracPitMies ON PPK_PPMId=PPM_PPMId
   WHERE PPK_Numer = 31002 AND ( PPM_Rok < @rok OR (PPM_Rok=@rok AND PPM_Miesiac<=@miesiacTemp) ) AND PPM_PraID=@praID
   ORDER BY PPM_Rok DESC, PPM_Miesiac DESC
   SET @miesiacTemp = @miesiacTemp + 1;
   IF(@miesiacTemp % 3 = 1)
    BREAK;
  END
  -- jeżeli udziały niezerowe to zapamietuję
  IF(@najem_L*@najem_M > 0)
   SET @najem1 = 1;
  ELSE
   SET @najem1 = NULL;
  -- wyszukanie udziałów 'L' w najmie drugim
  SET @miesiacTemp = @miesiac;
  SET @najem_L = NULL;
  WHILE @najem_L IS NULL
  BEGIN
   SELECT TOP 1 @najem_L = CASE WHEN PPK_Wartosc IS NULL THEN NULL ELSE CAST(ISNULL(PPK_Wartosc,'0') AS DECIMAL(6,2)) END
   FROM CDN.PracPitKwoty
   INNER JOIN CDN.PracPitMies ON PPK_PPMId=PPM_PPMId
   WHERE PPK_Numer = 31501 AND ( PPM_Rok < @rok OR (PPM_Rok=@rok AND PPM_Miesiac<=@miesiacTemp) ) AND PPM_PraID=@praID
   ORDER BY PPM_Rok DESC, PPM_Miesiac DESC
   SET @miesiacTemp = @miesiacTemp + 1;
   IF(@miesiacTemp % 3 = 1)
    BREAK;
  END
  -- wyszukanie udziałów 'M' w najmie
  SET @miesiacTemp = @miesiac;
  SET @najem_M = NULL;
  WHILE @najem_M IS NULL
  BEGIN
   SELECT TOP 1 @najem_M = CASE WHEN PPK_Wartosc IS NULL THEN NULL ELSE CAST(ISNULL(PPK_Wartosc,'0') AS DECIMAL(6,2)) END
   FROM CDN.PracPitKwoty
   INNER JOIN CDN.PracPitMies ON PPK_PPMId=PPM_PPMId
   WHERE PPK_Numer = 31502 AND ( PPM_Rok < @rok OR (PPM_Rok=@rok AND PPM_Miesiac<=@miesiacTemp) ) AND PPM_PraID=@praID
   ORDER BY PPM_Rok DESC, PPM_Miesiac DESC
   SET @miesiacTemp = @miesiacTemp + 1;
   IF(@miesiacTemp % 3 = 1)
    BREAK;
  END
  IF(@najem_L*@najem_M > 0)
   SET @najem2 = 1;
  ELSE
   SET @najem2 = NULL;
 END
 ELSE
 BEGIN
  SET @najem1 = NULL;
  SET @najem2 = NULL;
 END
 INSERT INTO #temp(Pra_PraId, Wlasciciel, Liniowy, Kwartalny, Najem1, Najem2)
 VALUES( @praID, @wlasciciel, ISNULL(@liniowy,0), ISNULL(@kwartalny,0), ISNULL(@najem1,0), ISNULL(@najem2,0) );
 FETCH NEXT FROM wlascCursor INTO @praID, @wlasciciel;
 END
 CLOSE wlascCursor
 DEALLOCATE wlascCursor
 SELECT * FROM #temp
 DROP TABLE #temp
