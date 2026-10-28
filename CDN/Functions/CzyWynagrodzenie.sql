CREATE FUNCTION CDN.CzyWynagrodzenie (@Typ Int, @Id Int)
RETURNS TINYINT
AS
BEGIN
DECLARE @Wynik TINYINT
SET @Wynik = 0
IF @Typ = 1
  BEGIN
    -- Zdarzenie
    IF EXISTS (SELECT * FROM CDN.BnkZdarzenia WHERE BZd_BZdId = @Id AND BZd_DokumentTyp=8)
      SET @Wynik = 1
    ELSE
      SET @Wynik = 0
  END
ELSE IF @Typ = 2
  BEGIN
    -- Zapis
    IF EXISTS (SELECT * FROM CDN.BnkZapisy WHERE BZp_BZpId = @Id AND BZp_Wynagrodzenie=1)
      SET @Wynik = 1
    ELSE
      SET @Wynik = 0
  END
RETURN @Wynik
END
