CREATE PROCEDURE CDN.CfgAddDokDefinicjePowiazane
 @lp INT,
 @klasaParent INT,
 @klasaDok INT,
 @domyslnaNumeracja INT,
 @domyslnaSeria INT,
 @nazwa NVARCHAR(20),
 @katalogObdId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(select * from cdn.DokDefinicje where DDf_Klasa = @klasaDok)
    BEGIN
     DECLARE @symbol NVARCHAR(5), @numeracja NVARCHAR(50), @powDDfID INT, @powSeria NVARCHAR(5)
        SET @symbol =  RTrim(LTrim(Str(@klasaParent))) + '#' + LTrim(RTrim(Str(@lp)))
        SELECT @powDDfID = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = @domyslnaNumeracja
        SELECT @numeracja = DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID = @PowDDfID
        IF CHARINDEX('@rejestr', @numeracja) > 0
            SET @powSeria = CDN.DomyslnaSeria(@domyslnaSeria)
        ELSE
            SET @PowSeria = ''
        INSERT INTO cdn.DokDefinicje(DDf_Klasa,DDf_Symbol,DDf_Nazwa,DDf_Numeracja,DDf_SeriaOperatora,DDf_PowDDfID,DDf_PowSeria, DDf_KatalogObdId, DDf_TS_Zal,DDf_TS_Mod)
        VALUES(@klasaDok, @Symbol, @Nazwa, @Numeracja, 0, @PowDdfID, @PowSeria, @katalogObdId, GetDate(), GetDate())
    END
    SET NOCOUNT OFF;
END
