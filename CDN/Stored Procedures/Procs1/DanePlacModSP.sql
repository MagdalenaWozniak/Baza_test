CREATE PROCEDURE CDN.DanePlacModSP
 @DpmId   int,
 @Kod   int,
 @Rodzaj  smallint,
 @Wartosc  decimal(15,2),
 @Opis   NVARCHAR(127),
 @Nazwa  NVARCHAR(254),
 @Nieaktywny tinyint,
 @Format  NVARCHAR(20),
 @Dodatkowe NVARCHAR(254),
 @Kolekcja  NVARCHAR(128),
 @Inne   NVARCHAR(128),
 @KolejkaWartosc NVARCHAR(254),
 @KolejkaOpis  NVARCHAR(254),
 @Tag int
AS
BEGIN
SET NOCOUNT ON
IF EXISTS (SELECT * FROM CDN.DanePlacMod WHERE DPM_DpmId = @DpmId)
 BEGIN
  UPDATE CDN.DanePlacMod SET
   DPM_Kod  = @Kod,
   DPM_Rodzaj = @Rodzaj,
   DPM_Wartosc = @Wartosc,
   DPM_Opis = @Opis,
   DPM_Nazwa = @Nazwa,
   DPM_Nieaktywny = @Nieaktywny,
   DPM_Format = @Format,
   DPM_Dodatkowe = @Dodatkowe,
   DPM_Kolekcja = @Kolekcja,
   DPM_Inne = @Inne,
   DPM_KolejkaWartosc = @KolejkaWartosc,
   DPM_KolejkaOpis = @KolejkaOpis,
   DPM_Tag = @Tag
   WHERE DPM_DpmId = @DpmId
 END
ELSE
 BEGIN
                SET IDENTITY_INSERT CDN.DanePlacMod ON
  INSERT INTO CDN.DanePlacMod
     (
     DPM_DpmId,
     DPM_Kod,
     DPM_Rodzaj,
     DPM_Wartosc,
     DPM_Opis,
     DPM_Nazwa,
     DPM_Nieaktywny,
     DPM_Format,
     DPM_Dodatkowe,
     DPM_Kolekcja,
     DPM_Inne,
     DPM_KolejkaWartosc,
     DPM_KolejkaOpis,
     DPM_Tag
     )
   VALUES
    (
    @DpmId,
    @Kod,
    @Rodzaj,
    @Wartosc,
    @Opis,
    @Nazwa,
    @Nieaktywny,
    @Format,
    @Dodatkowe,
    @Kolekcja,
    @Inne,
    @KolejkaWartosc,
    @KolejkaOpis,
    @Tag
    )
                SET IDENTITY_INSERT CDN.DanePlacMod OFF
 END
END
SET NOCOUNT OFF
