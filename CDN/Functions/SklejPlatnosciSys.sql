CREATE FUNCTION CDN.SklejPlatnosciSys (@Typ INT, @Id INT)
RETURNS NVARCHAR(255)
AS
BEGIN
  DECLARE @Wynik NVARCHAR(255)
  DECLARE @Termin    DATETIME
  DECLARE @Kwota     NUMERIC(15,2)
  DECLARE @FormaPlat CHAR(20)
  SET @Wynik = ''
  DECLARE Zdarzenia CURSOR FAST_FORWARD FOR
      SELECT BZd_Termin, BZd_KwotaSys, FPl_Nazwa
 FROM CDN.BnkZdarzenia
 JOIN CDN.FormyPlatnosci
      ON BZd_FPlId = FPl_FPlId
      WHERE BZd_DokumentTyp = @Typ AND BZd_DokumentId = @Id
    OPEN Zdarzenia
    WHILE 1 = 1
    BEGIN
      FETCH NEXT FROM Zdarzenia INTO @Termin, @Kwota, @FormaPlat
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Wynik = @Wynik + CONVERT(CHAR(10), @Termin, 120) + STR(@Kwota, 15, 2)+@FormaPlat
    END
    CLOSE Zdarzenia
  RETURN @Wynik
END
