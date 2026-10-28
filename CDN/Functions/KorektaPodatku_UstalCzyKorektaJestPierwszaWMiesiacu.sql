CREATE FUNCTION CDN.KorektaPodatku_UstalCzyKorektaJestPierwszaWMiesiacu(@BZd_BZdID INTEGER, @DkNID INTEGER, @PraID INTEGER, @TypDeklar INTEGER, @RokMiesiac INTEGER)
RETURNS INTEGER
AS
BEGIN
 DECLARE @PierwszaWMiesiacu INTEGER
 SET @PierwszaWMiesiacu = 0
 IF EXISTS(
  SELECT KZD_KZDID FROM CDN.KorektaPodatkuDochodowegoZD
  JOIN CDN.Deklnag ON DkN_DkNID = KZD_DkNID
  WHERE
  KZD_BZdID = @BZd_BZdID
  AND DkN_DkNID <> @DkNID
  AND ISNULL(DkN_PraID, 0) = ISNULL(@PraID, 0)
  AND DkN_TypDeklar = @TypDeklar
  AND DkN_RokMiesiac = @RokMiesiac
  AND KZD_Pierwszy = 1
  )
  SET @PierwszaWMiesiacu = 1
 RETURN @PierwszaWMiesiacu
END
