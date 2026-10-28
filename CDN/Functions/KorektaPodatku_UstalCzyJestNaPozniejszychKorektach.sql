CREATE FUNCTION CDN.KorektaPodatku_UstalCzyJestNaPozniejszychKorektach(@BZd_BZdID INTEGER, @DkNID INTEGER, @PraID INTEGER, @TypDeklar INTEGER)
RETURNS INTEGER
AS
BEGIN
 DECLARE @JestNaPozniejszychZaliczkach INTEGER
 SET @JestNaPozniejszychZaliczkach = 0;
 IF EXISTS(SELECT KZD_KZDID FROM CDN.KorektaPodatkuDochodowegoZD
  JOIN CDN.DeklNag ON DkN_DkNID = KZD_DkNID
  WHERE
  KZD_BZdID = @BZd_BZdID
  AND DkN_DkNID <> @DkNID
  AND ISNULL(DkN_PraID, 0) = ISNULL(@PraID, 0)
  AND DkN_TypDeklar = @TypDeklar
  AND DkN_Finalna = 1
  AND KZD_Skorygowano != 0)
   SET @JestNaPozniejszychZaliczkach = 1;
 RETURN @JestNaPozniejszychZaliczkach
END
