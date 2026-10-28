CREATE PROCEDURE CDN.GetZakladDlaPracyRozproszonej @Zak_Symbol NVARCHAR(30), @Zak_ImportRowId VARCHAR(36),
 @Tryb INT,
 @ZakID INT OUTPUT,
 @Warnings NVARCHAR(1000) OUTPUT
AS
BEGIN
  SET @ZakID = NULL
  DECLARE @rk INT
  SELECT @rk = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1204
  IF @rk <> 2
    RETURN
  DECLARE @wielozak INT
  SELECT @wielozak = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2240
  IF @wielozak <> 1
    RETURN
  DECLARE @UstawionoDomyslny INT
  SET @UstawionoDomyslny = 0
 IF(@Zak_ImportRowId is not NULL OR @Zak_Symbol is not NULL)
 BEGIN
  SET @ZakID = NULL
  SELECT @ZakID = Zak_ZakId
  FROM CDN.Zaklady
  WHERE Zak_ImportRowId = @Zak_ImportRowId
  IF(@ZakID is NULL)
  BEGIN
   SELECT @ZakID = Zak_ZakId
   FROM CDN.Zaklady
   WHERE Zak_Symbol = @Zak_Symbol
  END
 END
  IF(@ZakID is NULL AND @Tryb = 4) -- import LP - jeśli nie znaleziono żądanego zakładu, próbujemy podstawić domyślny w bazie docelowej
  BEGIN
    SELECT TOP 1 @ZakID = Zak_ZakId FROM CDN.Zaklady WHERE Zak_Domyslny = 1
    IF(@ZakID is NOT NULL)
      SET @UstawionoDomyslny = 1
  END
  IF (@ZakID is NULL) -- jeśli nie ustawiono zakładu, dajemy ostrzeżenie
  BEGIN
    IF IsNull(@Zak_Symbol, '') <> ''
 BEGIN
  IF @Tryb = 1
    --SET @Warnings = @Warnings + 'Brak zakładu ' + IsNull(@Zak_Symbol, '') + ' w bazie docelowej. Po imporcie należy zweryfikować zakład na pracowniku.\'
    SET @Warnings = @Warnings + '##OPT33171##%%zaklad%%=' + IsNull(@Zak_Symbol, '') + '##\'
  ELSE IF @Tryb = 2
    --SET @Warnings = @Warnings + 'Brak zakładu ' + IsNull(@Zak_Symbol, '') + ' w bazie docelowej. Po imporcie należy zweryfikować zakład na wspólniku.\'
    SET @Warnings = @Warnings + '##OPT33172##%%zaklad%%=' + IsNull(@Zak_Symbol, '') + '##\'
  ELSE IF (@Tryb = 3 OR @Tryb = 4)
    --SET @Warnings = @Warnings + 'Brak zakładu ' + IsNull(@Zak_Symbol, '') + ' w bazie docelowej. Po imporcie należy zweryfikować zakład na dokumencie.\'
    SET @Warnings = @Warnings + '##OPT33173##%%zaklad%%=' + IsNull(@Zak_Symbol, '') + '##\'
 END
 ELSE
 BEGIN
  IF @Tryb = 1
    --SET @Warnings = @Warnings + 'Brak zakładu w bazie docelowej. Po imporcie należy zweryfikować zakład na pracowniku.\'
    SET @Warnings = @Warnings + '##OPT34883##\'
  ELSE IF @Tryb = 2
    --SET @Warnings = @Warnings + 'Brak zakładu w bazie docelowej. Po imporcie należy zweryfikować zakład na wspólniku.\'
    SET @Warnings = @Warnings + '##OPT34884##\'
  ELSE IF (@Tryb = 3 OR @Tryb = 4)
    --SET @Warnings = @Warnings + 'Brak zakładu w bazie docelowej. Po imporcie należy zweryfikować zakład na dokumencie.\'
    SET @Warnings = @Warnings + '##OPT34885##\'
 END
  END
  ELSE IF @UstawionoDomyslny <> 0 -- jeśli ustawiono zakład, ale nie ten, co w pliku źródłowym tylko domyślny w bazie docelowej- też dajemy ostrzeżenie
 IF IsNull(@Zak_Symbol, '') <> ''
  --SET @Warnings = @Warnings + 'Brak zakładu ' + IsNull(@Zak_Symbol, '') + ' w bazie docelowej. Ustawiono zakład domyślny.\'
  SET @Warnings = @Warnings + '##OPT33174##%%zaklad%%=' + IsNull(@Zak_Symbol, '') + '##\'
 ELSE
  --SET @Warnings = @Warnings + 'Brak zakładu w bazie docelowej. Ustawiono zakład domyślny.\'
  SET @Warnings = @Warnings + '##OPT34886##\'
END
