CREATE FUNCTION CDN.KorektaPodatku_Skorygowano(@BZd_BZdID INTEGER, @DkNID INTEGER, @PraID INTEGER, @TypDeklar INTEGER, @Rodzaj INTEGER, @RokMies INTEGER)
RETURNS decimal(15,2)
AS
BEGIN
 DECLARE @Skorygowano decimal(15,2)
 SELECT @Skorygowano = ISNULL((
  SELECT TOP 1 KZD_Skorygowano
  FROM CDN.KorektaPodatkuDochodowegoZD
  JOIN CDN.DeklNag ON DkN_DkNID = KZD_DkNID
  WHERE
  KZD_BZdID = @BZd_BZdID
  AND DkN_DkNID <> @DkNID
  AND ISNULL(DkN_PraID, 0) = ISNULL(@PraID, 0)
  AND DkN_TypDeklar = @TypDeklar
  AND KZD_Rodzaj = @Rodzaj
  AND DkN_RokMiesiac < @RokMies
  AND DkN_Finalna = 1
  ORDER BY DkN_RokMiesiac DESC)
 , 0)
 RETURN @Skorygowano
END
