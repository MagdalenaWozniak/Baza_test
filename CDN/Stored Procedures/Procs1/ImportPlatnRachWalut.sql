CREATE  PROCEDURE CDN.ImportPlatnRachWalut
@DokId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BRa_Symbol nvarchar(5),
@BRa_ImportRowId nvarchar(36),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @BRaId int
 IF @BRa_ImportRowId is NULL OR @BRa_ImportRowId = ''
  SELECT @BRaId = BRa_BRaId
  FROM CDN.BnkRachunki
  WHERE BRa_Symbol = @BRa_Symbol
 ELSE
  SELECT @BRaId = BRa_BRaId
  FROM CDN.BnkRachunki
  WHERE BRa_ImportRowId = @BRa_ImportRowId
 IF(@BRaId is NULL)
 BEGIN
  --SET @Warnings = 'Nie znaleziono rejestru walutowego.\'
  SET @Warnings = '##OPT33200##\'
  RETURN
 END
 INSERT
 INTO CDN.FormyPlatnWaluty
 (
 FPW_FplId,
 FPW_BRaId
 )
 VALUES
 (
 @DokId,
 @BRaId
 )
END
