CREATE PROCEDURE CDN.ESLKEP_ImportDefZgodyKanaly
  @VerIDChr                       nvarchar(50),
  @KanalChr        nvarchar(50)
AS
  SET NOCOUNT ON
  DECLARE
  @VerID        UNIQUEIDENTIFIER,
  @Kanal        UNIQUEIDENTIFIER,
  @IDKanal        INT,
  @OptimaID        INT
  SELECT
 @VerID             = CONVERT(UNIQUEIDENTIFIER,@VerIDChr),
 @Kanal             = CONVERT(UNIQUEIDENTIFIER,@KanalChr)
  select @IDKanal = RZFK_RZFKId from CDN.RejestracjaZgodFormyKontaktu where RZFK_GUID = @Kanal
  if @IDKanal = 1
  update [CDN].[RejestracjaZgodTresc] set RZT_EMAIL = 1
 where RZT_GuidVer = @VerID
  if @IDKanal = 2
  update [CDN].[RejestracjaZgodTresc] set RZT_SMS = 1
 where RZT_GuidVer = @VerID
  if @IDKanal = 3
  update [CDN].[RejestracjaZgodTresc] set RZT_Telefon = 1
 where RZT_GuidVer = @VerID
  if @IDKanal = 4
  update [CDN].[RejestracjaZgodTresc] set RZT_List = 1
 where RZT_GuidVer = @VerID
SET NOCOUNT OFF
