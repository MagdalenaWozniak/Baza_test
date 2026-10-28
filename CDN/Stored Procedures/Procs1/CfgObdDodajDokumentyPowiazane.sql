CREATE PROCEDURE CDN.CfgObdDodajDokumentyPowiazane
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @KlasaObd INT, @Klasa INT,@KlasaSuf INT,  @Typ INT,  @SubTyp INT, @DomyslnaNumeracja INT,@domyslnaSeria INT,  @Nazwa NVARCHAR(20), @lp INT, @katalogObdId INT
 SET @KlasaObd = 750
 SET @DomyslnaNumeracja = 1850  -- domyślna numeracja OBD
 SET @domyslnaSeria = 1851 -- domyślna seria OBD
 SET @KlasaSuf = @KlasaObd * 1000000
 SELECT TOP 1 @katalogObdId = Ktl_KtlId FROM cdn.Katalogi WHERE Ktl_Domyslny = 1
    SET @lp = 1
 SET @Nazwa  = 'Rej. zakupów VAT'
    SET @Typ   = 999 * 100
    SET @SubTyp= 1
    SET @Klasa = @KlasaSuf + @Typ + @SubTyp
 EXEC CDN.CfgAddDokDefinicjePowiazane @lp, @KlasaObd, @Klasa, @DomyslnaNumeracja, @domyslnaSeria, @Nazwa, @katalogObdId
    SET @lp = 2
    SET @Nazwa  = 'Rej. sprzedaży VAT'
    SET @Typ   = 999 * 100
    SET @SubTyp= 2
    SET @Klasa = @KlasaSuf + @Typ + @SubTyp
 EXEC CDN.CfgAddDokDefinicjePowiazane @lp, @KlasaObd, @Klasa, @DomyslnaNumeracja, @domyslnaSeria, @Nazwa, @katalogObdId
    SET @lp = 3
    SET @Nazwa  = 'Ew. dod. przychodów'
    SET @Typ   = 1003 * 100
    SET @SubTyp= 1
    SET @Klasa = @KlasaSuf + @Typ + @SubTyp
 EXEC CDN.CfgAddDokDefinicjePowiazane @lp, @KlasaObd, @Klasa, @DomyslnaNumeracja, @domyslnaSeria, @Nazwa, @katalogObdId
    SET @lp = 4
    SET @Nazwa  = 'Ew. dod. kosztów'
    SET @Typ   = 1003 * 100
    SET @SubTyp= 2
    SET @Klasa = @KlasaSuf + @Typ + @SubTyp
 EXEC CDN.CfgAddDokDefinicjePowiazane  @lp, @KlasaObd, @Klasa, @DomyslnaNumeracja, @domyslnaSeria, @Nazwa, @katalogObdId
KONIEC:
    SET NOCOUNT OFF;
END
