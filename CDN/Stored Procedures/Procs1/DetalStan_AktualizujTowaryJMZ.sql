CREATE  PROCEDURE [CDN].[DetalStan_AktualizujTowaryJMZ]
 @DSTwrId int,
 @JM nvarchar(20),
 @JMPrzelicznikL decimal(15,2),
 @JMPrzelicznikM decimal(7,0)
AS
SET NOCOUNT ON
DECLARE
    @DSTJZId INT
  SELECT @DSTJZId = DSTJZ_DSTJZId
    FROM CDN.DetalStanTwrJMZ
    WHERE DSTJZ_DSTwrId = @DSTwrId and DSTJZ_JM = @JM
  IF @DSTJZId IS NULL
    BEGIN
       INSERT INTO CDN.DetalStanTwrJMZ (DSTJZ_DSTwrId,
                                        DSTJZ_JM,
          DSTJZ_JMPrzelicznikL,
          DSTJZ_JMPrzelicznikM
                                        )
  VALUES (
                @DSTwrId,
                @JM,
    @JMPrzelicznikL,
    @JMPrzelicznikM)
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalStanTwrJMZ
   SET
   DSTJZ_JMPrzelicznikL =@JMPrzelicznikL,
   DSTJZ_JMPrzelicznikM =@JMPrzelicznikM
  WHERE (@DSTJZId = DSTJZ_DSTJZId)
      END
  SET NOCOUNT OFF
