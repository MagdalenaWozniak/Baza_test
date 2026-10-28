CREATE PROCEDURE CDN.DefinicjaZmianPolaSP
 @DfzId   int,
 @Nazwa  NVARCHAR(128),
 @Rodzaj  tinyint,
 @Wartosc  decimal(15,2),
 @WartoscTekst NVARCHAR(254),
 @Nieaktywny tinyint,
 @Format  NVARCHAR(20),
 @Dodatkowe NVARCHAR(254),
 @Kolekcja  NVARCHAR(128),
 @Inne   NVARCHAR(128)
AS
BEGIN
SET NOCOUNT ON
IF EXISTS (SELECT * FROM CDN.DefinicjaZmianPola WHERE DZP_Nazwa = @Nazwa and DZP_DfzId = @DfzId)
 BEGIN
  UPDATE CDN.DefinicjaZmianPola SET
   DZP_DfzId  = @DfzId,
   DZP_Nazwa  = @Nazwa,
   DZP_Rodzaj  = @Rodzaj,
   DZP_Wartosc = @Wartosc,
   DZP_WartoscTekst = @WartoscTekst,
   DZP_Nieaktywny = @Nieaktywny,
   DZP_Format = @Format,
   DZP_Dodatkowe = @Dodatkowe,
   DZP_Kolekcja = @Kolekcja,
   DZP_Inne = @Inne
   WHERE DZP_DfzId = @DfzId and DZP_Nazwa = @Nazwa
 END
ELSE
 BEGIN
           --SET IDENTITY_INSERT CDN.DefinicjaZmianPola OFF
  INSERT INTO CDN.DefinicjaZmianPola
    (
    DZP_DfzId,
    DZP_Nazwa,
    DZP_Rodzaj,
    DZP_Wartosc,
    DZP_WartoscTekst,
    DZP_Nieaktywny,
    DZP_Format,
    DZP_Dodatkowe,
    DZP_Kolekcja,
    DZP_Inne
    )
   VALUES
    (
    @DfzId,
    @Nazwa,
    @Rodzaj,
    @Wartosc,
    @WartoscTekst,
    @Nieaktywny,
    @Format,
    @Dodatkowe,
    @Kolekcja,
    @Inne
    )
                --SET IDENTITY_INSERT CDN.DefinicjaZmianPola OFF
 END
END
SET NOCOUNT OFF
