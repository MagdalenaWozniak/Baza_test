CREATE PROCEDURE CDN.OFF_UstawPrawoDoAnulowania
@Prawo    INT,
@FaID     INT,
@KlasaDok INT
  AS
  SET NOCOUNT ON
  UPDATE cdn.tranag
  SET TrN_OFFPrawoDoAnulowania = @Prawo
  WHERE TrN_TrNId = @FaID
    And TrN_TypDokumentu = @KlasaDok
 SET NOCOUNT OFF
 SELECT 0
