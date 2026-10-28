CREATE  FUNCTION CDN.TwrGrupyPot( @wezel int )
RETURNS @TwrGrupy TABLE (TwGID INT, GIDNumer INT, GrONumer INT, Poziom INT)
AS
BEGIN
 INSERT INTO @TwrGrupy (TwGID, GIDNumer,  GrONumer, Poziom)
     SELECT TwG_TwGID, TwG_GIDNumer, TwG_GrONumer, 0
 FROM CDN.TwrGrupy WHERE TwG_GrOTyp=-16 AND TwG_GIDTyp=-16 AND TwG_GIDNumer = @wezel
 DECLARE @Poziom INT
 SET @Poziom = 0
 WHILE 1=1
 BEGIN
  INSERT INTO @TwrGrupy (TwGID, GidNumer, GroNumer, Poziom)
  SELECT
   TwG_TwGID,
   TwG_GIDNumer,
   TwG_GroNumer,
   @Poziom + 1
  FROM
   @TwrGrupy JOIN CDN.TwrGrupy ON TwG_GrOTyp=-16 AND TwG_GIDTyp=-16 AND TwG_GrONumer = GidNumer AND Poziom = @Poziom
     WHERE TwG_GidNumer > @wezel
  IF @@ROWCOUNT = 0 BREAK
  SET @Poziom = @Poziom + 1
 END
 RETURN
END
