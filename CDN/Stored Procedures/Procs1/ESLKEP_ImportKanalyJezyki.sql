CREATE PROCEDURE [CDN].[ESLKEP_ImportKanalyJezyki]
  @JezykIdChr                     nvarchar(11),
  @Nazwa                          nvarchar(100),
  @IDChr                          nvarchar(50)
AS
  SET NOCOUNT ON
  DECLARE
  @ID        UNIQUEIDENTIFIER,
  @JezykId                    INT,
  @OptimaID                   INT
  SELECT
  @ID             = CONVERT(UNIQUEIDENTIFIER,@IDChr),@JezykId     = CONVERT(int,@JezykIdChr)
  SELECT @OptimaID = RZFK_RZFKId
    FROM Cdn.RejestracjaZgodFormyKontaktu
    WHERE RZFK_Guid = @ID
 if not exists (select * from [CDN].[RejestracjaZgodFormyKontaktuJezykObcy] where RZFKJ_RZFKId = @OptimaID and RZFKJ_JezykID = @JezykId)
INSERT INTO [CDN].[RejestracjaZgodFormyKontaktuJezykObcy]
           ([RZFKJ_RZFKId]
           ,[RZFKJ_JezykID]
           ,[RZFKJ_Nazwa])
     VALUES
           (@OptimaID
           ,@JezykID
           ,@Nazwa)
SET NOCOUNT OFF
