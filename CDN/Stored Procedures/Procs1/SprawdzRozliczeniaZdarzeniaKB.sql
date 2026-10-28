CREATE PROCEDURE CDN.SprawdzRozliczeniaZdarzeniaKB(@DokKBID INT)
AS
BEGIN
 DECLARE @ErrMsg NVARCHAR(256)
 SELECT @ErrMsg = ''
 DECLARE @numerDok VARCHAR(50)
 DECLARE @kwotaDokWal DECIMAL(15,2)
 DECLARE @kwotaDokSys DECIMAL(15,2)
 SELECT @numerDok = IsNull(BZd_Numer, ''), @kwotaDokWal = IsNull(BZd_Kwota, 0), @kwotaDokSys = IsNull(BZd_KwotaSys, 0) FROM cdn.BnkZdarzenia WHERE BZd_BZdID = @DokKBID
 DECLARE @sumaRozWal DECIMAL(15,2)
 DECLARE @sumaRozSys DECIMAL(15,2)
 SELECT @sumaRozWal = IsNull(SUM(BRK_Kwota), 0) FROM cdn.BnkRozKwoty WHERE BRK_LDokTyp = 1 AND BRK_LDokID = @DokKBID OR BRK_PDokTyp = 1 AND BRK_PDokID = @DokKBID
 SELECT @sumaRozSys = IsNull(SUM(CASE WHEN BRK_LDokTyp = 1 AND BRK_LDokID = @DokKBID THEN BRK_KwotaSysL ELSE BRK_KwotaSysP END), 0) FROM cdn.BnkRozKwoty
  WHERE BRK_LDokTyp = 1 AND BRK_LDokID = @DokKBID OR BRK_PDokTyp = 1 AND BRK_PDokID = @DokKBID
 IF @sumaRozWal = @kwotaDokWal AND @sumaRozSys <> @kwotaDokSys
  BEGIN
    IF @sumaRozSys < @kwotaDokSys
   --SELECT @ErrMsg = 'Nieprawidłowy stan rozliczeń płatności [' + @numerDok + ']: dokument rozliczony całkowicie w walucie obcej, natomiast nie rozliczony całkowicie w walucie systemowej.'
   RAISERROR('##OPT33026##%%nrDok%%=%s##', 16, 1, @numerDok)
    ELSE
   --SELECT @ErrMsg = 'Nieprawidłowy stan rozliczeń płatności [' + @numerDok + ']: dokument rozliczony całkowicie w walucie obcej, ale suma rozliczeń w walucie systemowej przekracza kwotę dokumentu.'
   RAISERROR('##OPT33027##%%nrDok%%=%s##', 16, 1, @numerDok)
  END
 ELSE IF @sumaRozWal <> @kwotaDokWal AND @sumaRozSys = @kwotaDokSys
  BEGIN
    IF @sumaRozWal < @kwotaDokWal
   --SELECT @ErrMsg = 'Nieprawidłowy stan rozliczeń płatności [' + @numerDok + ']: dokument rozliczony całkowicie w walucie systemowej, natomiast nie rozliczony całkowicie w walucie obcej.'
   RAISERROR('##OPT33028##%%nrDok%%=%s##', 16, 1, @numerDok)
    ELSE
   --SELECT @ErrMsg = 'Nieprawidłowy stan rozliczeń płatności [' + @numerDok + ']: dokument rozliczony całkowicie w walucie systemowej, ale suma rozliczeń w walucie obcej przekracza kwotę dokumentu.'
   RAISERROR('##OPT33029##%%nrDok%%=%s##', 16, 1, @numerDok)
  END
 --IF(@ErrMsg <> '')
 -- RAISERROR(@ErrMsg, 16, 1)
END
