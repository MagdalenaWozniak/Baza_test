CREATE  PROCEDURE CDN.SprawdzMagazyn
 @MagSymbolOperator   NVARCHAR(20),
 @MagSymbolStanowisko NVARCHAR(20),
 @MagIdDomyslny       INT,
 @OperatorId          INT
  AS
  SET NOCOUNT ON
  DECLARE
    @MagId      INT,
    @Komunikat  INT
  SELECT @Komunikat ='',@MagId = 0
  IF @MagSymbolOperator <>''
    BEGIN
      SELECT @MagId = Mag_MagId FROM Cdn.Magazyny
       WHERE Mag_Nieaktywny=0 AND Mag_Typ = 1 AND Mag_Symbol=@MagSymbolOperator
      IF @MagId = 0
         BEGIN
            SET @Komunikat = 33812
         END
      ELSE
         BEGIN
            IF EXISTS(SELECT MaZ_MagId FROM cdn.magazynzakazy WHERE MaZ_MagId = @MagId AND MaZ_OpeId = @OperatorId)
              SET @Komunikat = 33813
         END
    END
   ELSE
      IF @MagSymbolStanowisko <>''
        BEGIN
          SET @MagId = 0
          SELECT @MagId = Mag_MagId FROM Cdn.Magazyny
           WHERE Mag_Nieaktywny=0 AND Mag_Typ = 1 AND Mag_Symbol=@MagSymbolStanowisko
          IF @MagId = 0
             BEGIN
                SET @Komunikat = 33814
             END
          ELSE
             BEGIN
                IF EXISTS(SELECT MaZ_MagId FROM cdn.magazynzakazy WHERE MaZ_MagId = @MagId AND MaZ_OpeId = @OperatorId)
                  SET @Komunikat = 33815
             END
        END
      ELSE
        BEGIN
           IF @MagIdDomyslny <> 0
              SET @MagId = @MagIdDomyslny
           ELSE
              SET @MagId = 1
        END
    SET NOCOUNT Off
  SELECT @MagId as MagId ,@Komunikat as Komunikat
