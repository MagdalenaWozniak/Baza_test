CREATE PROCEDURE CDN.ImportRejPosAddRecord
@DokId int,
@VaT_Lp int,
@VaT_Stawka decimal(5, 2),
@VaT_Flaga smallint,
@VaT_Zrodlowa decimal(5,2),
@VaT_RodzajZakupu smallint,
@VaT_Odliczenia smallint,
@VaT_NettoWal decimal(15, 2),
@VaT_VatWal decimal(15, 2),
@VaT_Netto decimal(15, 2),
@VaT_VAT decimal(15, 2),
@VaT_NettoDoVAT decimal(15,2),
@VaT_VatDoVAT decimal(15,2),
@VaT_StawkaSymbol NVARCHAR(10),
@VaT_KatID int,
@VaT_KatOpis nvarchar(50),
@VaT_Kat2ID int,
@VaT_Kat2Opis nvarchar(50),
@VaT_KolKPiR tinyint,
@VaT_KolRyc tinyint
AS
BEGIN
 DECLARE @VaT_KwotaNKUP DECIMAL(15,2)
 DECLARE @VaT_VATNKUP DECIMAL(15,2)
 SET @VaT_Odliczenia = IsNull(@VaT_Odliczenia, 0)
 IF @VaT_Odliczenia = 0
 BEGIN
  SET @VaT_KwotaNKUP = @VaT_Netto + @VaT_VAT
  SET @VaT_VATNKUP = @VaT_VAT
 END
 ELSE
 BEGIN
  SET @VaT_KwotaNKUP = @VaT_Netto
  SET @VaT_VATNKUP = 0
 END
 IF @VaT_Lp Is Null OR @VaT_Lp Is NOT Null AND EXISTS (SELECT * FROM cdn.VaTTab WHERE VaT_VaNID = @DokId AND VaT_Lp = @VaT_Lp)
  SELECT @VaT_Lp = IsNull(VaT_Lp, 0) + 1 FROM cdn.VaTTab WHERE VaT_VaNID = @DokId
 IF @VaT_Lp Is Null
  SELECT @VaT_Lp = 1
 INSERT INTO CDN.VatTab
 (
 VaT_VaNID,
 VaT_Lp,
 VaT_Stawka,
 VaT_Flaga,
 VaT_Zrodlowa,
 VaT_RodzajZakupu,
 VaT_Odliczenia,
 VaT_NettoWal,
 VaT_VATWal,
 VaT_Netto,
 VaT_VAT,
 VaT_NettoDoVAT,
 VaT_VatDoVAT,
 VaT_KwotaNKUP,
 VaT_VATNKUP,
 VaT_StawkaSymbol,
 VaT_KatID,
 VaT_KolumnaKPR,
 VaT_KolumnaRYC,
 VaT_KatOpis,
 VaT_Kat2ID,
 VaT_Kat2Opis
 )
 VALUES
 (
 @DokId,
 @VaT_Lp,
 @VaT_Stawka,
 @VaT_Flaga,
 @VAT_Zrodlowa,
 @VaT_RodzajZakupu,
 @VaT_Odliczenia,
 @VaT_NettoWal,
 @VaT_VATWal,
 @VaT_Netto,
 @VaT_VAT,
 @VaT_NettoDoVAT,
 @VaT_VatDoVAT,
 @VaT_KwotaNKUP,
 @VaT_VATNKUP,
 @VaT_StawkaSymbol,
 @VAT_KatID,
 @VaT_KolKPiR,
 @VaT_KolRyc,
 @VaT_KatOpis,
 @VAT_Kat2ID,
 @VaT_Kat2Opis
 )
 UPDATE CDN.VatNag SET VaN_KwotaNKUP = VaN_KwotaNKUP + @VaT_KwotaNKUP, VaN_VATNKUP = VaN_VATNKUP + @VaT_VATNKUP WHERE VaN_VaNId = @DokId
END
