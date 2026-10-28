CREATE PROCEDURE CDN.SprawdzRozliczeniaZapisuKB(@DokKBID INT)
AS
BEGIN
 DECLARE @ErrMsg NVARCHAR(256)
 SELECT @ErrMsg = ''
 DECLARE @numerDok VARCHAR(50)
 DECLARE @kwotaDokWal DECIMAL(15,2)
 DECLARE @kwotaDokSys DECIMAL(15,2)
  DECLARE @TypKursuWaluty INT
 DECLARE @KursHistorycznyMW TINYINT
 SELECT @numerDok = IsNull(BZp_Numer, ''), @kwotaDokWal = IsNull(BZp_Kwota, 0), @kwotaDokSys = IsNull(BZp_KwotaSys, 0), @TypKursuWaluty = IsNull(BZp_KursNumer, 0),
  @KursHistorycznyMW = IsNull(CASE WHEN (select bra_MagazynWalut from cdn.BnkRachunki join cdn.BnkRaporty on bra_braid=BRp_BRaID join cdn.bnkzapisy on BRp_BRpID=BZp_BRpID where BZp_BZpID=@DokKBID) <> 0 AND BZp_WgKursuMW = 2 THEN 1 ELSE 0 END, 0)
  FROM cdn.BnkZapisy WHERE BZp_BZpID = @DokKBID
 DECLARE @sumaRozWal DECIMAL(15,2)
 DECLARE @sumaRozSys DECIMAL(15,2)
 SELECT @sumaRozWal = IsNull(SUM(BRK_Kwota), 0) FROM cdn.BnkRozKwoty WHERE BRK_LDokTyp = 2 AND BRK_LDokID = @DokKBID OR BRK_PDokTyp = 2 AND BRK_PDokID = @DokKBID
 SELECT @sumaRozSys = IsNull(SUM(CASE WHEN BRK_LDokTyp = 2 AND BRK_LDokID = @DokKBID THEN BRK_KwotaSysL ELSE BRK_KwotaSysP END), 0) FROM cdn.BnkRozKwoty
  WHERE BRK_LDokTyp = 2 AND BRK_LDokID = @DokKBID OR BRK_PDokTyp = 2 AND BRK_PDokID = @DokKBID
 IF @sumaRozWal = @kwotaDokWal AND @sumaRozSys <> @kwotaDokSys
 BEGIN
  IF NOT (@kwotaDokWal = 0 AND @kwotaDokSys <> 0 AND @TypKursuWaluty = -1) --Zapis o kursie nieokreślonym może mieć zerową kwotę w walucie i niezerową kwotę w walucie systemowej
  BEGIN
   IF @sumaRozSys < @kwotaDokSys
    --SELECT @ErrMsg = 'Nieprawidłowy stan rozliczeń zapisu KB [' + @numerDok + ']: dokument rozliczony całkowicie w walucie obcej, natomiast nie rozliczony całkowicie w walucie systemowej.'
    RAISERROR('##OPT33030##%%nrDok%%=%s##', 16, 1, @numerDok)
   ELSE
    --SELECT @ErrMsg = 'Nieprawidłowy stan rozliczeń zapisu KB [' + @numerDok + ']: dokument rozliczony całkowicie w walucie obcej, ale suma rozliczeń w walucie systemowej przekracza kwotę dokumentu.'
    RAISERROR('##OPT33031##%%nrDok%%=%s##', 16, 1, @numerDok)
  END
 END
 ELSE IF @sumaRozWal <> @kwotaDokWal AND @sumaRozSys = @kwotaDokSys
 BEGIN
  IF NOT (@kwotaDokWal <> 0 AND @kwotaDokSys = 0 AND @TypKursuWaluty = -1 AND @KursHistorycznyMW = 1) --Zapis MW historyczny o kursie nieokreślonym może mieć niezerową kwotę w walucie i zerową kwotę w walucie systemowej
  BEGIN
   IF @sumaRozWal < @kwotaDokWal
    --SELECT @ErrMsg = 'Nieprawidłowy stan rozliczeń zapisu KB [' + @numerDok + ']: dokument rozliczony całkowicie w walucie systemowej, natomiast nie rozliczony całkowicie w walucie obcej.'
    RAISERROR('##OPT33032##%%nrDok%%=%s##', 16, 1, @numerDok)
   ELSE
    --SELECT @ErrMsg = 'Nieprawidłowy stan rozliczeń zapisu KB [' + @numerDok + ']: dokument rozliczony całkowicie w walucie systemowej, ale suma rozliczeń w walucie obcej przekracza kwotę dokumentu.'
    RAISERROR('##OPT33033##%%nrDok%%=%s##', 16, 1, @numerDok)
  END
 END
 --IF(@ErrMsg <> '')
 -- RAISERROR(@ErrMsg, 16, 1)
END
