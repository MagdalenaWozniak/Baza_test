CREATE  PROCEDURE [CDN].[DetalStan_AktualizujTowaryEAN]
 @DSTwrId int,
 @EAN varchar(40),
 @Opis nvarchar(100),
 @Domyslny tinyint,
 @JM nvarchar(20)
AS
SET NOCOUNT ON
DECLARE
    @DSTwEId INT
  SELECT @DSTwEId = DSTwE_DSTwEId
    FROM CDN.DetalStanTwrEan
    WHERE DSTwE_DSTwrId = @DSTwrId and DSTwE_EAN = @EAN
  IF @DSTwEId IS NULL
    BEGIN
       INSERT INTO CDN.DetalStanTwrEan (DSTwE_DSTwrId,
                                        DSTwE_EAN,
          DSTwE_Opis,
          DSTwE_Domyslny,
          DSTwE_JM
                                        )
  VALUES (
                @DSTwrId,
                @EAN,
    @Opis,
    @Domyslny,
    @JM)
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalStanTwrEan
   SET
   DSTwE_Opis =@Opis,
   DSTwE_Domyslny =@Domyslny,
   DSTwE_JM =@JM
  WHERE (@DSTwEId = DSTwE_DSTwEId)
      END
  SET NOCOUNT OFF
