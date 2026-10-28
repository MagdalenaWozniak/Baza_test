CREATE PROCEDURE CDN.DetalStan_AktualizujOpakElem
    @StanDetalID int,
  @DSONId int,
 @Lp int,
 @TwrOptimaId int,
 @Ilosc decimal(15, 4)
AS
SET NOCOUNT ON
DECLARE
    @DSON_Id INT,
    @DSOE_Id INT,
    @DSOE_DSTwrId INT
  SELECT @DSON_Id = DSON_DSONId
    FROM CDN.DetalStanOpakNag
    WHERE DSON_OptimaId = @DSONId and DSON_StanDetalID = @StanDetalID
  IF @DSON_Id is NULL return
  SELECT @DSOE_DSTwrId = DSTwr_DSTwrId
    FROM CDN.DetalStanTowary
    WHERE DSTwr_OptimaId = @TwrOptimaId AND DSTwr_StanDetalID = @StanDetalID
       INSERT INTO CDN.DetalStanOpakElem (
  DSOE_DSONId,
 DSOE_Lp,
 DSOE_DSTwrId,
 DSOE_Ilosc
               )
       VALUES (
        @DSON_Id,
        @Lp,
        @DSOE_DSTwrId,
        @Ilosc)
  SET NOCOUNT OFF
