CREATE PROCEDURE cdn.InsertTwrJmz
 @twrId  INT,
 @jm  NVARCHAR(20),
 @przelicznikL  DECIMAL(15,2),
 @przelicznikM  DECIMAL(7,0),
 @rejestrOperacji INT = 1
AS
BEGIN
 SET NOCOUNT ON;
 IF @jm IS NULL OR @jm = '' GOTO KONIEC
 IF @przelicznikL IS NULL GOTO KONIEC
 IF @przelicznikM IS NULL GOTO KONIEC
 DECLARE @twrJm NVARCHAR(20), @kod VARCHAR(40)
    SELECT TOP 1 @twrJm = Twr_JM, @kod = Twr_Kod FROM cdn.Towary WHERE Twr_TwrId = @twrId
 IF @twrJm IS NULL OR @twrJm = '' OR  @twrJm = @jm GOTO KONIEC -- jednostka pusta lub podstawowa nie jest dodawana
 IF EXISTS(SELECT * FROM [CDN].[TwrJMZ] WHERE [TwJZ_TwrID] = @twrId AND [TwJZ_JM] = @jm)  GOTO KONIEC
 INSERT INTO [CDN].[TwrJMZ]
           ([TwJZ_TwrID]
           ,[TwJZ_JM]
           ,[TwJZ_JMPrzelicznikL]
           ,[TwJZ_JMPrzelicznikM])
  VALUES(
           @twrId
           ,@jm
           ,@przelicznikL
           ,@przelicznikM)
 IF @rejestrOperacji = 1
 BEGIN
  EXEC [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @kod, 2, '';
 END
KONIEC:
 SET NOCOUNT OFF;
END
