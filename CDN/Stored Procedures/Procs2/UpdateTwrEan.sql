CREATE PROCEDURE cdn.UpdateTwrEan
 @mode   TINYINT,
 @twrId   INT,
 @ean   VARCHAR(40),
 @domyslny  TINYINT = 0,
 @jm    NVARCHAR(20) = N'',
 @opis   NVARCHAR(100) = N'',
 @poprzedniEan VARCHAR(40) = '',
 @rejestrOperacji INT = 1
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE
 @twrJm NVARCHAR(20),
 @Kod NVARCHAR(50),
 @zmodyfikowanoTwr INT
 SET @zmodyfikowanoTwr = 0
 SELECT @twrJm = Twr_JM,@Kod = Twr_Kod FROM cdn.Towary WHERE Twr_TwrId = @twrId
 IF @twrJm IS NULL GOTO KONIEC    -- nie ma karty towarowej
 IF @opis is NULL SET @opis = ''
 IF  @jm IS NULL OR LEN(LTRIM(RTRIM(@jm))) = 0  SET @jm = @twrJm
 IF @mode = 1   -- dodawanie lub zmiana kodu na pierwszej zakładce
 BEGIN
  IF LEN(LTRIM(RTRIM(@poprzedniEan))) = 0
  BEGIN
   SELECT @poprzedniEan = Twr_EAN  FROM cdn.Towary WHERE Twr_TwrId = @twrId
   IF @poprzedniEan IS NULL SET @poprzedniEan = ''
  END
  IF LEN(LTRIM(RTRIM(@poprzedniEan))) > 0
  BEGIN
   -- Zmieniam kod na pierwszej zakładce – stary usuwa się z trzeciej a dodaje nowy
   DELETE FROM [CDN].[TwrEan] WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] = @poprzedniEan AND [TwE_JM] = @jm
  END
  UPDATE cdn.Towary SET Twr_EAN = @ean, Twr_TS_mod = GetDate() WHERE Twr_TwrId = @twrId
  SET @zmodyfikowanoTwr = 1
  SET @domyslny = 1
  -- Jeśli na trzeciej zakładce mam juz kod xxx i wpisze go na  pierwszą zakladke, wówczas ten kod na zakładce trzeciej dostanie domyślność.
  IF EXISTS(SELECT * FROM [CDN].[TwrEan] WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] = @ean )
  begin
   UPDATE [CDN].[TwrEan] SET TwE_Domyslny = 1 WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] = @ean
   SET @zmodyfikowanoTwr = 1
        end
  ELSE-- dodaję nowy
  begin
   EXEC cdn.InsertTwrEan  @twrId, @ean, @jm, @opis, @domyslny, 0
   SET @zmodyfikowanoTwr = 1
  end
  IF @domyslny = 1
  begin
   UPDATE [CDN].[TwrEan] SET TwE_Domyslny = 0 WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] <> @ean
   SET @zmodyfikowanoTwr = 1
        end
  GOTO KONIEC
 END
 -- dodawanie lub zmiana kodu na trzeciej zakładce
 IF EXISTS(SELECT * FROM [CDN].[TwrEan] WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] = @ean )
 BEGIN
  IF @domyslny = 1
  BEGIN
   UPDATE [CDN].[TwrEan] SET TwE_Domyslny = 0 WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] <> @ean
   UPDATE [CDN].[TwrEan] SET TwE_Domyslny = 1 WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] = @ean
   UPDATE cdn.Towary SET Twr_EAN = @ean, Twr_TS_mod = GetDate() WHERE Twr_TwrId = @twrId
   SET @zmodyfikowanoTwr = 1
  END
  IF LEN(LTRIM(RTRIM(@jm))) > 0  -- zmien jm
  BEGIN
   UPDATE [CDN].[TwrEan] SET TwE_JM = @jm WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] = @ean
   SET @zmodyfikowanoTwr = 1
  END
  IF LEN(LTRIM(RTRIM(@opis))) > 0  -- zmien opis
  BEGIN
   UPDATE [CDN].[TwrEan] SET TwE_Opis = @opis WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] = @ean
   SET @zmodyfikowanoTwr = 1
  END
 END
 ELSE
 BEGIN
  EXEC cdn.InsertTwrEan  @twrId, @ean, @jm, @opis, @domyslny, 0
  IF @domyslny = 1
  BEGIN
   UPDATE [CDN].[TwrEan] SET TwE_Domyslny = 0 WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] <> @ean
   UPDATE cdn.Towary SET Twr_EAN = @ean, Twr_TS_mod = GetDate() WHERE Twr_TwrId = @twrId
  END
  SET @zmodyfikowanoTwr = 1
 END
KONIEC:
 IF @rejestrOperacji = 1 AND @zmodyfikowanoTwr = 1
 BEGIN
  EXEC [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 END
 SET NOCOUNT OFF;
END
