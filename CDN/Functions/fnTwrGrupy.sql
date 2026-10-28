CREATE FUNCTION CDN.fnTwrGrupy ()
RETURNS @TwrGrupy TABLE (Id int IDENTITY, TwGID INT, Sciezka NVARCHAR(4000), Kod NVARCHAR(50), Nazwa NVARCHAR(255), Poziom INT, GIDNumer INT, GrONumer INT, PRIMARY KEY(Id, Poziom, GrONumer, GIDNumer))
AS
 BEGIN
  DECLARE @GIDTyp SMALLINT
  SET @GIDTyp = -16
  INSERT INTO @TwrGrupy (TwGID, Sciezka, Kod, Nazwa,Poziom, GIDNumer, GrONumer)
 SELECT TwG_TwGID, TwG_Kod, TwG_Kod,TwG_Nazwa, 0, TwG_GIDNumer, TwG_GrONumer FROM    CDN.TwrGrupy WHERE TwG_TwGID = 0
  DECLARE @Poziom INT
  SET @Poziom = 0
  WHILE 1=1
   BEGIN
    INSERT INTO @TwrGrupy (TwGID,Sciezka, Kod, Nazwa,Poziom, GIDNumer, GrONumer)
    SELECT TwG_TwGID, CASE Sciezka
 WHEN 'Grupa Główna' THEN ' ' ELSE Sciezka
 END + '\ ' + TwG_Kod, TwG_Kod, TwG_Nazwa, @Poziom + 1, TwG_GIDNumer, TwG_GrONumer
    FROM @TwrGrupy JOIN CDN.TwrGrupy
    ON TwG_GrOTyp = @GIDTyp AND TwG_GrONumer = GIDNumer AND Poziom = @Poziom AND TwG_GIDTyp = @GIDTyp WHERE TwG_TwGID <> 0
    IF @@ROWCOUNT = 0 BREAK
    SET @Poziom = @Poziom + 1
   END
 RETURN
END
