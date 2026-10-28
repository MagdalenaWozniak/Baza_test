CREATE FUNCTION CDN.KorektaPodatku_RozliczonaKwota(@BZd_BZdID INTEGER, @NaDzien DATETIME)
RETURNS decimal(15,2)
AS
BEGIN
 DECLARE @SumaL decimal(15, 2)
 DECLARE @SumaP decimal(15, 2)
 SELECT @SumaL = ISNULL(SUM(BRK_KwotaSysL),0)
 FROM CDN.BnkRozKwoty
 WHERE BRK_LDokTyp = 1 AND BRK_LDokID = @BZd_BZdID AND BRK_DataDok <= @NaDzien
 SELECT @SumaP = ISNULL(SUM(BRK_KwotaSysP),0)
 FROM CDN.BnkRozKwoty
 WHERE BRK_PDokTyp = 1 AND BRK_PDokID = @BZd_BZdID AND BRK_DataDok <= @NaDzien
 RETURN @SumaL + @SumaP
END
