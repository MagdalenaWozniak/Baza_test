CREATE PROCEDURE cdn.InsertTwrEan
 @twrId  INT,
 @ean  VARCHAR(40),
 @jm   NVARCHAR(20)  = N'',
 @opis  NVARCHAR(100) = N'',
 @domyslny TINYINT = 0,
 @rejestrOperacji INT = 1
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @twrJm NVARCHAR(20), @kod VARCHAR(40)
 SELECT TOP 1 @twrJm = Twr_JM, @kod = Twr_Kod FROM cdn.Towary WHERE Twr_TwrId = @twrId
 IF @twrJm IS NULL GOTO KONIEC    -- nie ma karty towarowej
 IF  @jm IS NULL OR LEN(LTRIM(RTRIM(@jm))) = 0  SET @jm = @twrJm
 IF NOT EXISTS(SELECT * FROM [CDN].[TwrEan] WHERE [TwE_TwrID] = @twrId AND [TwE_EAN] = @ean)
 BEGIN
     INSERT INTO [CDN].[TwrEan]
           ([TwE_TwrID]
           ,[TwE_EAN]
           ,[TwE_Opis]
           ,[TwE_Domyslny]
           ,[TwE_JM])
  VALUES(
           @twrId
           ,@ean
           ,@opis
           ,@domyslny
           ,@jm)
  IF @rejestrOperacji = 1
  BEGIN
   EXEC [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @kod, 2, '';
  END
 END
KONIEC:
 SET NOCOUNT OFF;
END
