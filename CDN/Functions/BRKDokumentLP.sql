CREATE FUNCTION CDN.BRKDokumentLP (@LTyp Int, @LId Int, @PTyp Int, @PId Int)
RETURNS INT
AS
BEGIN
DECLARE @Wynik INT
SET @Wynik = 0
IF @LTyp = 1 AND @PTyp = 2
  BEGIN
    -- Zdarzenie - Zapis
    SET @Wynik = 1
  END
ELSE IF @LTyp = 2 AND @PTyp = 1
  BEGIN
    -- Zapis - Zdarzenie
    SET @Wynik = 2
  END
ELSE IF @LTyp = 1 AND @PTyp = 1
  BEGIN
    -- Zdarzenie - Zdarzenie
    IF EXISTS (SELECT * FROM CDN.BnkZdarzenia WHERE BZd_BZdId = @LId AND BZd_Kierunek = -1)
      SET @Wynik = 1
    ELSE
      SET @Wynik = 2
  END
ELSE IF @LTyp = 2 AND @PTyp = 2
  BEGIN
    -- Zapis - zapis
    IF EXISTS (SELECT * FROM CDN.BnkZapisy WHERE BZp_BZpId = @LId AND BZp_Kierunek = -1)
      SET @Wynik = 1
    ELSE
      SET @Wynik = 2
  END
RETURN @Wynik
END
