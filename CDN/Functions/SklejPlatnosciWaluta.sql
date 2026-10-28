CREATE FUNCTION CDN.SklejPlatnosciWaluta (@Typ INT, @Id INT )
RETURNS NVARCHAR(255)
AS
BEGIN
  DECLARE @Wynik NVARCHAR(255)
  DECLARE @Termin    DATETIME
  DECLARE @Kwota     NUMERIC(15,2)
  DECLARE @FormaPlat CHAR(20)
  DECLARE @Waluta NVARCHAR(4)
  SET @Wynik = ''
  DECLARE Zdarzenia CURSOR FAST_FORWARD FOR
      SELECT BZd_Termin, BZd_Kwota, FPl_Nazwa,case when Bzd_waluta = '' then 'PLN' else Bzd_waluta end FROM CDN.BnkZdarzenia JOIN CDN.FormyPlatnosci
      ON BZd_FPlId = FPl_FPlId
      WHERE BZd_DokumentTyp = @Typ AND BZd_DokumentId = @Id
    OPEN Zdarzenia
    WHILE 1 = 1
    BEGIN
      FETCH NEXT FROM Zdarzenia INTO @Termin, @Kwota, @FormaPlat, @Waluta
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Wynik = @Wynik + convert (char(5), @Waluta )
    END
    CLOSE Zdarzenia
  RETURN @Wynik
END
