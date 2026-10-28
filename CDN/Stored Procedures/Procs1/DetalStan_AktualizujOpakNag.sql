CREATE PROCEDURE CDN.DetalStan_AktualizujOpakNag
    @StanDetalID int,
    @OptimaId int,
 @Nieaktywny tinyint,
 @Kod NVARCHAR(20),
 @Nazwa NVARCHAR(50),
    @DateTSSynchrNew datetime
AS
SET NOCOUNT ON
DECLARE
    @DSON_Id INT
  SELECT @DSON_Id = DSON_DSONId
    FROM CDN.DetalStanOpakNag
    WHERE DSON_OptimaId = @OptimaId and DSON_StanDetalID = @StanDetalID
  IF @DSON_Id IS NULL
    BEGIN
       IF @NieAktywny = 0
       INSERT INTO CDN.DetalStanOpakNag (
        DSON_OptimaId,
        DSON_Nieaktywny,
     DSON_Kod,
        DSON_Nazwa,
        DSON_StanDetalID,
        DSON_TS_Mod
               )
       VALUES (
        @OptimaId,
        @Nieaktywny,
        @Kod,
        @Nazwa,
        @StanDetalID,
        @DateTSSynchrNew)
    END
  ELSE
 BEGIN
   Delete from  CDN.DetalStanOpakElem where DSOE_DSONId = @DSON_Id
   UPDATE  CDN.DetalStanOpakNag
   SET   DSON_Nieaktywny = @Nieaktywny,
 DSON_Kod = @Kod,
 DSON_Nazwa = @Nazwa,
 DSON_TS_Mod = @DateTSSynchrNew
  WHERE (@DSON_Id = DSON_DSONId)
      END
  SET NOCOUNT OFF
