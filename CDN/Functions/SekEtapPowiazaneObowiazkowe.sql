CREATE FUNCTION CDN.SekEtapPowiazaneObowiazkowe(@Typ INT, @Id INT)
RETURNS INT
-- -1  - to nie jest zadanie główne
--  0  - wszystkie obowiązkowe są zamknięte
--  1  - istnieją  obowiązkowe nie zamknięte
AS
BEGIN
    DECLARE @wynik INT

    DECLARE @donTyp INT
    DECLARE @donID  INT
    DECLARE @poziom INT
    DECLARE @lp INT

    SET @wynik = 0

    SELECT  @donTyp= IsNull(DnPr_Typ, 0),
            @donID = IsNull(DnPr_DonID, 0),
            @poziom = IsNull(DnPr_Poziom, 0),
            @lp = IsNull(DnPr_Lp, 0) FROM CDN.DokNagProcesEtapyView WHERE DnPr_Typ = @Typ AND DnPr_DnPrId = @Id

    IF @poziom = 2     -- zadanie powiązane
    BEGIN
        SET @wynik = -1  -- nie jest to zadanie główne
        GOTO KONIEC
    END
    -- czy etap główny posiada niezamkniete OBOWIAZKOWE etapy powiązane
    IF EXISTS(SELECT * FROM CDN.DokNagProcesEtapyView
            JOIN CDN.DokNagEtapyView on DnE_Typ =DnPr_Typ AND DnE_DnPrID = DnPr_DnPrId  AND DnE_Wykonany=0
            WHERE (DnPr_Typ=@donTyp AND DnPr_DonID=@donID AND DnPr_Poziom=2 AND DnPr_Lp=@Lp AND DnE_Obowiazkowy=1)
            )
    BEGIN
        SET @wynik = 1 -- istnieją  obowiązkowe nie zamknięte
    END

KONIEC:
    RETURN @wynik
END
