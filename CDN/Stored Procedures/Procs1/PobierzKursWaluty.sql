CREATE PROCEDURE [CDN].PobierzKursWaluty
 @symbolWal  VARCHAR(3),
 @dataNotowania DATETIME,
 @kursL   DECIMAL(15,4) OUTPUT,
 @kursM   DECIMAL(5,0)  OUTPUT,
 @err   INT  OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  SET @kursL = NULL
  SET @kursM = NULL
  SET @err = 0
 -- Notowania walut
  DECLARE
  @sqltxt   NVARCHAR(1024),
  @FullKnfName      NVARCHAR(512),
  @WalOstrzegaj     NVARCHAR(3),
  @DataNotowaniaChar  NVARCHAR(25)
--pobranie notowania
 SET @FullKnfName = CDN.GetFullKnfName()
 SELECT @DataNotowaniaChar = CONVERT(NVARCHAR(25), @dataNotowania, 102)
 -- 1 = "Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)"
 IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 )
  SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540
 ELSE
  SELECT @WalOstrzegaj=1
 SET @sqltxt = 'EXEC ' + @FullKnfName + '.CDN.PobierzNotowania '''', 2,'''+ @DataNotowaniaChar +''','+ @WalOstrzegaj+''
 CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta VARCHAR(3) PRIMARY KEY, KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
 INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
 EXEC sp_executesql @sqltxt
 DECLARE @komunikat NVARCHAR(128)
 SET @err = 0
 IF NOT EXISTS( SELECT * FROM #Notowania WHERE Waluta = @symbolWal ) OR
       EXISTS( SELECT * FROM #Notowania WHERE Brak Is Null )
   SET @err = 1   -- SET @komunikat = 'W Konfiguracji nie znaleziono definicji waluty: ' + @symbolWal
 IF EXISTS( SELECT * FROM #Notowania WHERE Waluta = @symbolWal AND Brak = 1 )
   SET @err = 2   -- SET @komunikat = 'Brak kursu waluty ' + @symbolWal + ' na dzień ' + @DataNotowaniaChar + ' !'
 IF EXISTS( SELECT * FROM #Notowania WHERE Waluta = @symbolWal AND Brak = 0 AND (KursL Is NULL OR KursM Is NULL) )
   SET @err = 2   -- SET @komunikat = 'Brak kursu waluty ' + @symbolWal + ' na dzień ' + @DataNotowaniaChar + ' !'
 IF  @err = 0
 BEGIN
  SELECT @kursL = KursL, @kursM = KursM FROM #Notowania WHERE Waluta = @symbolWal AND Brak = 0
 END
 RETURN
END
