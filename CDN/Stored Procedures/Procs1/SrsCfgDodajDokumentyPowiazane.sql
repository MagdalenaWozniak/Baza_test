CREATE PROCEDURE CDN.SrsCfgDodajDokumentyPowiazane
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @Typ INT, @DomyslnaNumeracja INT, @Klasa INT, @Symbol NVARCHAR(5),
   @Nazwa NVARCHAR(256),@Numeracja NVARCHAR(50), @PowDDfID INT, @PowSeria NVARCHAR(5)
-- FA faktura sprzedaży
 SET @Typ   = 302
 SET @Klasa = 900000 + @Typ
 IF NOT EXISTS(select * from cdn.DokDefinicje where DDf_Klasa = @Klasa)
 BEGIN
  SET @Symbol = '900#1'
  SET @Nazwa  = N'Faktury sprzedaży'
  SET @DomyslnaNumeracja = 1269   --Domyślny typ faktury sprzedaży
  SELECT @PowDDfID = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = @DomyslnaNumeracja
  SELECT @Numeracja = DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID = @PowDDfID
  IF CHARINDEX('@rejestr', @Numeracja) > 0
   SET @PowSeria = CDN.DomyslnaSeria(@Typ * 1000)
  ELSE
   SET @PowSeria = ''
  INSERT INTO cdn.DokDefinicje(DDf_Klasa,DDf_Symbol,DDf_Nazwa,DDf_Numeracja,DDf_SeriaOperatora,DDf_PowDDfID,DDf_PowSeria,DDf_TS_Zal,DDf_TS_Mod)
  VALUES(@Klasa,@Symbol,@Nazwa,@Numeracja,0,@PowDdfID, @PowSeria,GetDate(),GetDate())
 END
-- RO rozchód wewnętrzny
 SET @Typ   = 304
 SET @Klasa = 900000 + @Typ
 IF NOT EXISTS(select * from cdn.DokDefinicje where DDf_Klasa = @Klasa)
 BEGIN
  SET @Symbol = '900#2'
  SET @Nazwa  = N'Rozchody wewnętrzne'
  SET @DomyslnaNumeracja = 1343 --Domyślny typ - rozchody wewnętrzne
  SELECT @PowDDfID = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = @DomyslnaNumeracja
  SELECT @Numeracja = DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID = @PowDDfID
  IF CHARINDEX('@rejestr', @Numeracja) > 0
   SET @PowSeria = CDN.DomyslnaSeria(@Typ * 1000)
  ELSE
   SET @PowSeria = ''
  INSERT INTO cdn.DokDefinicje(DDf_Klasa,DDf_Symbol,DDf_Nazwa,DDf_Numeracja,DDf_SeriaOperatora,DDf_PowDDfID,DDf_PowSeria,DDf_TS_Zal,DDf_TS_Mod)
  VALUES(@Klasa,@Symbol,@Nazwa,@Numeracja,0,@PowDdfID, @PowSeria,GetDate(),GetDate())
 END
-- PA paragon
 SET @Typ   = 305
 SET @Klasa = 900000 + @Typ
 IF NOT EXISTS(select * from cdn.DokDefinicje where DDf_Klasa = @Klasa)
 BEGIN
  SET @Symbol = '900#3'
  SET @Nazwa  = N'Paragony'
  SET @DomyslnaNumeracja = 1273 --Domyślny typ paragonu
  SELECT @PowDDfID = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = @DomyslnaNumeracja
  SELECT @Numeracja = DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID = @PowDDfID
  IF CHARINDEX('@rejestr', @Numeracja) > 0
   SET @PowSeria = CDN.DomyslnaSeria(@Typ * 1000)
  ELSE
   SET @PowSeria = ''
  INSERT INTO cdn.DokDefinicje(DDf_Klasa,DDf_Symbol,DDf_Nazwa,DDf_Numeracja,DDf_SeriaOperatora,DDf_PowDDfID,DDf_PowSeria,DDf_TS_Zal,DDf_TS_Mod)
  VALUES(@Klasa,@Symbol,@Nazwa,@Numeracja,0,@PowDdfID, @PowSeria,GetDate(),GetDate())
 END
-- WZ wydanie zewnętrzne
 SET @Typ   = 306
 SET @Klasa = 900000 + @Typ
 IF NOT EXISTS(select * from cdn.DokDefinicje where DDf_Klasa = @Klasa)
 BEGIN
  SET @Symbol = '900#4'
  SET @Nazwa  = N'Wydania zewnętrzne'
  SET @DomyslnaNumeracja = 1321 --Domyślny typ - wydania zewnętrzne
  SELECT @PowDDfID = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = @DomyslnaNumeracja
  SELECT @Numeracja = DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID = @PowDDfID
  IF CHARINDEX('@rejestr', @Numeracja) > 0
   SET @PowSeria = CDN.DomyslnaSeria(@Typ * 1000)
  ELSE
   SET @PowSeria = ''
  INSERT INTO cdn.DokDefinicje(DDf_Klasa,DDf_Symbol,DDf_Nazwa,DDf_Numeracja,DDf_SeriaOperatora,DDf_PowDDfID,DDf_PowSeria,DDf_TS_Zal,DDf_TS_Mod)
  VALUES(@Klasa,@Symbol,@Nazwa,@Numeracja,0,@PowDdfID, @PowSeria,GetDate(),GetDate())
 END
-- ZD zamówienia u dostawców
 SET @Typ   = 309
 SET @Klasa = 900000 + @Typ
 IF NOT EXISTS(select * from cdn.DokDefinicje where DDf_Klasa = @Klasa)
 BEGIN
  SET @Symbol = '900#5'
  SET @Nazwa  = N'Zamówienia u dostawcy'
  SET @DomyslnaNumeracja = 1319 --Domyślny typ - zamówienia u dostawców
  SELECT @PowDDfID = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = @DomyslnaNumeracja
  SELECT @Numeracja = DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID = @PowDDfID
  IF CHARINDEX('@rejestr', @Numeracja) > 0
   SET @PowSeria = CDN.DomyslnaSeria(@Typ * 1000)
  ELSE
   SET @PowSeria = ''
  INSERT INTO cdn.DokDefinicje(DDf_Klasa,DDf_Symbol,DDf_Nazwa,DDf_Numeracja,DDf_SeriaOperatora,DDf_PowDDfID,DDf_PowSeria,DDf_TS_Zal,DDf_TS_Mod)
  VALUES(@Klasa,@Symbol,@Nazwa,@Numeracja,0,@PowDdfID, @PowSeria,GetDate(),GetDate())
 END
-- MM przesunięcia międzymagazynowe
 SET @Typ   = 312
 SET @Klasa = 900000 + @Typ
 IF NOT EXISTS(select * from cdn.DokDefinicje where DDf_Klasa = @Klasa)
 BEGIN
  SET @Symbol = '900#6'
  SET @Nazwa  = N'Przesunięcia międzymagazynowe'
  SET @DomyslnaNumeracja = 1347 --Domyślny typ - przesunięcia międzymagazynowe lokalny-lokalny
  SELECT @PowDDfID = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = @DomyslnaNumeracja
  SELECT @Numeracja = DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID = @PowDDfID
  IF CHARINDEX('@rejestr', @Numeracja) > 0
   SET @PowSeria = CDN.DomyslnaSeria(@Typ * 1000)
  ELSE
   SET @PowSeria = ''
  INSERT INTO cdn.DokDefinicje(DDf_Klasa,DDf_Symbol,DDf_Nazwa,DDf_Numeracja,DDf_SeriaOperatora,DDf_PowDDfID,DDf_PowSeria,DDf_TS_Zal,DDf_TS_Mod)
  VALUES(@Klasa,@Symbol,@Nazwa,@Numeracja,0,@PowDdfID, @PowSeria,GetDate(),GetDate())
 END
KONIEC:
 SET NOCOUNT OFF;
END
