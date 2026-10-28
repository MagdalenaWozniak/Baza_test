CREATE  PROCEDURE CDN.SprawdzPlatnoscDokumentu
@DokId INT, @DokTyp INT
AS
DECLARE
@BruttoWal  DECIMAL(15,2),
@NettoWal  DECIMAL(15,2),
@VatSys    DECIMAL(15,2),
@TrybNettoVAT INT,
@BzdKwota  DECIMAL(15,2),
@Komunikat  NVARCHAR(200),
@Waluta   NVARCHAR(5);
IF(@DokTyp = 12)
BEGIN
 SELECT @BruttoWal = CASE EDN_Platnosci WHEN 0 THEN 0 ELSE ABS(EDN_KwotaRazem) END, @Waluta = CDN.Waluta(EDN_Waluta)
 FROM CDN.EwidDodNag
 WHERE EDN_EDNID=@dokId
 IF( @BruttoWal IS NULL )
  SET @Komunikat = 'Brak dokumentu w tabeli CDN.EwidDodNag o ID ' + @dokId
 ELSE
 BEGIN
  IF( @Waluta = CDN.Waluta('') )
   SELECT @BzdKwota = ISNULL(SUM(BZd_KwotaSys * BZd_Kierunek),0) FROM CDN.BnkZdarzenia WHERE BZd_DokumentTyp=12 AND BZd_DokumentID=@dokId
  ELSE
   SELECT @BzdKwota = ISNULL(SUM(BZd_Kwota * BZd_Kierunek),0) FROM CDN.BnkZdarzenia WHERE BZd_DokumentTyp=12 AND BZd_DokumentID=@dokId
  IF( ABS(@BzdKwota) <> @BruttoWal )
   SET @Komunikat = 'Suma kwot płatności dokumentu nie zgadza się z kwotą na dokumencie. Płatność wynosi ' + CONVERT(NVARCHAR(17), @BzdKwota);
 END
END
ELSE IF(@DokTyp = 2)
BEGIN
 SELECT
  @TrybNettoVAT = VaN_TrybNettoVat,
  @BruttoWal  = CASE VaN_Wewnetrzna WHEN 0 THEN ABS(VaN_RazemBruttoWal) ELSE 0 END,
  @VatSys   = CASE VaN_Wewnetrzna WHEN 0 THEN ISNULL(ABS(SUM(VaT_VATDoVAT)),0) ELSE 0 END,
  @NettoWal  = CASE VaN_Wewnetrzna WHEN 0 THEN ISNULL(ABS(SUM(VaT_NettoWal)),0) ELSE 0 END,
  @Waluta   = CDN.Waluta(VaN_Waluta)
 FROM CDN.VatNag LEFT OUTER JOIN CDN.VatTab ON VaN_VaNID=Vat_VanID
 WHERE VaN_VaNID=@dokId
 GROUP BY VaN_VaNID, VaN_TrybNettoVat, VaN_RazemBruttoWal, Van_Waluta, VaN_Wewnetrzna
 IF( @BruttoWal IS NULL )
  --SET @Komunikat = 'Brak dokumentu w tabeli CDN.VatNag o ID ' + @dokId
 BEGIN
  declare @DokIdStr NVARCHAR(20)
  SET @DokIdStr = CONVERT(NVARCHAR(20), @DokId)
  RAISERROR('##OPT33053##%%kwotaPlat%%=%s##', 16, 1, @DokIdStr)
 END
 ELSE
 BEGIN
  DECLARE @kwotaPlat NVARCHAR(17)
  IF(@TrybNettoVAT = 0)
  BEGIN
   IF( @Waluta = CDN.Waluta('') )
    SELECT @BzdKwota = ISNULL(SUM(BZd_KwotaSys * BZd_Kierunek),0) FROM CDN.BnkZdarzenia WHERE BZd_DokumentTyp=2 AND BZd_DokumentID=@dokId
   ELSE
    SELECT @BzdKwota = ISNULL(SUM(BZd_Kwota * BZd_Kierunek),0) FROM CDN.BnkZdarzenia WHERE BZd_DokumentTyp=2 AND BZd_DokumentID=@dokId
   IF(ABS(@BzdKwota) <> @BruttoWal)
    --SET @Komunikat = 'Suma kwot płatności dokumentu nie zgadza się z kwotą na dokumencie. Płatność wynosi ' + CONVERT(NVARCHAR(17), @BzdKwota);
   BEGIN
    SELECT @kwotaPlat = CONVERT(NVARCHAR(17), @BzdKwota)
    RAISERROR('##OPT33049##%%kwotaPlat%%=%s##', 16, 1, @kwotaPlat)
   END
  END
  ELSE
  BEGIN
   SELECT @BzdKwota = ISNULL(SUM(BZd_Kwota * BZd_Kierunek),0) FROM CDN.BnkZdarzenia WHERE BZd_DokumentTyp=2 AND BZd_DokumentID=@dokId AND CDN.Waluta(Bzd_Waluta)=@Waluta;
   IF(ABS(@BzdKwota) <> @NettoWal)
    --SET @Komunikat = 'Suma kwot płatności dokumentu w ['+@Waluta+'] nie zgadza się z kwotą netto na dokumencie. Płatność wynosi ' + CONVERT(NVARCHAR(17), @BzdKwota);
   BEGIN
    SELECT @kwotaPlat = CONVERT(NVARCHAR(17), @BzdKwota)
    RAISERROR('##OPT33051##%%waluta%%=%s%%kwotaPlat%%=%s##', 16, 1, @kwotaPlat)
   END
   SELECT @BzdKwota = ISNULL(SUM(BZd_KwotaSys * BZd_Kierunek),0) FROM CDN.BnkZdarzenia WHERE BZd_DokumentTyp=2 AND BZd_DokumentID=@dokId AND CDN.Waluta(Bzd_Waluta)=CDN.Waluta('');
   IF(ABS(@BzdKwota) <> @VatSys)
    --SET @Komunikat = 'Suma kwot płatności dokumentu w ['+CDN.Waluta('')+'] nie zgadza się z kwotą vat na dokumencie. Płatność wynosi ' + CONVERT(NVARCHAR(17), @BzdKwota);
   BEGIN
    DECLARE @walutaTmp NVARCHAR(3)
    SELECT @walutaTmp = CDN.Waluta('')
    SELECT @kwotaPlat = CONVERT(NVARCHAR(17), @BzdKwota)
    RAISERROR('##OPT33052##%%waluta%%=%s%%kwotaPlat%%=%s##', 16, 1, @kwotaPlat)
   END
  END
 END
END
--IF(@Komunikat IS NOT NULL)
-- RAISERROR(@Komunikat, 16, 1)
