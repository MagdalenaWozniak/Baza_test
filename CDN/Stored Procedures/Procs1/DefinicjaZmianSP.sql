CREATE PROCEDURE CDN.DefinicjaZmianSP
 @Nazwa  NVARCHAR(128),
 @Pole1   int,
 @Pole2   int,
 @Pole3   int,
 @Wzor1   NVARCHAR(254),
 @Wzor2   NVARCHAR(254),
 @Wzor3   NVARCHAR(254),
 @Wzor   NVARCHAR(1024),
 @Interaktywna tinyint,
 @Aktualizacja tinyint,
 @Standardowy int,
 @Nieaktywny tinyint,
 @Zaawansowany tinyint
AS
BEGIN
SET NOCOUNT ON
IF EXISTS (SELECT * FROM CDN.DefinicjaZmian WHERE DFZ_Standardowy = @Standardowy)
 BEGIN
  UPDATE CDN.DefinicjaZmian SET
   DFZ_Nazwa  = @Nazwa,
   DFZ_Pole1  = @Pole1,
   DFZ_Pole2  = @Pole2,
   DFZ_Pole3  = @Pole3,
   DFZ_Wzor1  = @Wzor1,
   DFZ_Wzor2   = @Wzor2,
   DFZ_Wzor3   = @Wzor3,
   DFZ_Wzor   = @Wzor,
   DFZ_Interaktywna = @Interaktywna,
   DFZ_Aktualizacja = @Aktualizacja,
   DFZ_Standardowy = @Standardowy,
   DFZ_Nieaktywny = @Nieaktywny,
   DFZ_Zaawansowany = @Zaawansowany
   WHERE DFZ_Standardowy = @Standardowy
 END
ELSE
 BEGIN
           --SET IDENTITY_INSERT CDN.DefinicjaZmian OFF
  INSERT INTO CDN.DefinicjaZmian
    (
    DFZ_Nazwa,
    DFZ_Pole1,
    DFZ_Pole2,
    DFZ_Pole3,
    DFZ_Wzor1,
    DFZ_Wzor2,
    DFZ_Wzor3,
    DFZ_Wzor,
    DFZ_Interaktywna,
    DFZ_Aktualizacja,
    DFZ_Standardowy,
    DFZ_Nieaktywny,
    DFZ_Zaawansowany
    )
   VALUES
    (
    @Nazwa,
    @Pole1,
    @Pole2,
    @Pole3,
    @Wzor1,
    @Wzor2,
    @Wzor3,
    @Wzor,
    @Interaktywna,
    @Aktualizacja,
    @Standardowy,
    @Nieaktywny,
    @Zaawansowany
    )
                --SET IDENTITY_INSERT CDN.DefinicjaZmian OFF
 END
END
SET NOCOUNT OFF
