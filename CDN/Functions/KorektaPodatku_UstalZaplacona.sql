CREATE FUNCTION CDN.KorektaPodatku_UstalZaplacona(@BZd_BZdID INTEGER, @NaDzien DATETIME, @DkNID INTEGER, @PraID INTEGER, @TypDeklar INTEGER)
RETURNS INTEGER
AS
BEGIN
 DECLARE @Zaplacona INTEGER
 DECLARE @RozliczonaKwota NUMERIC(15,2)
 DECLARE @RozliczonaKwotaPierwotna NUMERIC(15,2)
 SET @Zaplacona = 0
 SELECT @RozliczonaKwota = CDN.KorektaPodatku_RozliczonaKwota(@BZd_BZdID, @NaDzien)
 SELECT @RozliczonaKwotaPierwotna = KZD_RozliczonaKwota
 FROM CDN.KorektaPodatkuDochodowegoZD
 JOIN CDN.DeklNag ON DkN_DkNID = KZD_DkNID
 WHERE
 KZD_BZdID = @BZd_BZdID
 AND DkN_DkNID <> @DkNID
 AND ISNULL(DkN_PraID, 0) = ISNULL(@PraID, 0)
 AND DkN_TypDeklar = @TypDeklar
 AND DkN_Finalna = 1
 AND KZD_Pierwszy = 1
 IF @RozliczonaKwotaPierwotna IS NOT NULL AND (@RozliczonaKwota - @RozliczonaKwotaPierwotna) <> 0
  SET @Zaplacona = 1
 RETURN @Zaplacona
END
