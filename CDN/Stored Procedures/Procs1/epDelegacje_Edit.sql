CREATE PROCEDURE [CDN].[epDelegacje_Edit]
@ID INT, @KodPracownika NVARCHAR (20), @DataDokumentu DATETIME, @DataOd DATETIME, @DataDo DATETIME, @WyjazdZMZ SMALLINT, @Opis NVARCHAR (255), @Status INT, @DataZmianyStatusu DATETIME, @CzyZagraniczna SMALLINT, @MiejsceDocelowe NVARCHAR(255)
AS
SET NOCOUNT ON;
DECLARE @OperatorId AS INT;
SELECT @OperatorId = CONVERT (INT, Fir_Wartosc)
FROM   cdn.Firma
WHERE  Fir_Numer = 2185;
IF IsNull(@OperatorId, 0) = 0
    BEGIN
        RAISERROR ('Nie zdefiniowano operatora dla zapisów z aplikacji Comarch ERP e-Pracownik', 16, 1);
        SET NOCOUNT OFF;
        RETURN;
    END
IF IsNull(@ID, 0) = 0
    BEGIN
        RAISERROR ('CDN.epDelegacje_Edit. Nie podano ID rekordu do zmiany.', 16, 1);
        SET NOCOUNT OFF;
        RETURN;
    END
DECLARE @PodmiotTyp AS INT;
SET @PodmiotTyp = NULL;
DECLARE @PodmiotId AS INT;
SET @PodmiotId = NULL;
IF @KodPracownika IS NOT NULL
    SELECT @PodmiotTyp = Pod_PodmiotTyp,
           @PodmiotId = Pod_PodId
    FROM   CDN.PodmiotyView
    WHERE  Pod_PodmiotTyp = 3
           AND Pod_Kod = @KodPracownika;
DECLARE @sql AS NVARCHAR (2048);
SET @sql = '';
DECLARE @upd AS NVARCHAR (2048);
SET @upd = '';
IF @PodmiotTyp IS NOT NULL
    BEGIN
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_PodmiotTyp=' + CONVERT (NVARCHAR, @PodmiotTyp);
    END
IF @PodmiotId IS NOT NULL
    BEGIN
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_PodmiotId=' + CONVERT (NVARCHAR, @PodmiotId);
    END
IF @DataDokumentu IS NOT NULL
    BEGIN
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_DataDok=' + CDN.Date2String(@DataDokumentu, 120, 0); -- convert(nvarchar, @DataDokumentu, 120) + ''''
    END
IF @DataOd IS NOT NULL
    BEGIN
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_DataOd=' + CDN.Date2String(@DataOd, 120, 0); -- convert(nvarchar, @DataOd, 120) + ''''
    END
IF @DataDo IS NOT NULL
    BEGIN
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_DataDo=' + CDN.Date2String(@DataDo, 120, 0); -- convert(nvarchar, @DataDo, 120) + ''''
        DECLARE @DataRozliczenia AS DATETIME;
        SET @DataRozliczenia = @DataDo + 1;
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_DataRozliczenia=' + CDN.Date2String(@DataRozliczenia, 120, 0); -- convert(nvarchar, @DataDo, 120) + ''''
    END
IF @WyjazdZMZ IS NOT NULL
    BEGIN
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_WyjazdZMZ=' + CONVERT (NVARCHAR, @WyjazdZMZ);
    END
IF @Opis IS NOT NULL
    BEGIN
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_Opis=''' + REPLACE(@Opis, '''', '''''') + '''';
    END
IF @MiejsceDocelowe IS NOT NULL
    BEGIN
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_MiejsceDocelowe=''' + REPLACE(@MiejsceDocelowe, '''', '''''') + '''';
    END
IF @CzyZagraniczna IS NOT NULL
BEGIN
  IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_Zagraniczna=' + CONVERT (NVARCHAR, @CzyZagraniczna);
END
IF @Status IS NOT NULL
    BEGIN
        IF @Status < 0
           OR @Status > 3
            BEGIN
                RAISERROR ('CDN.epDelegacje_Edit. Wartość parametru @Status [%i] poza zakresem [0,1,2,3,4].', 16, 1, @Status);
                SET NOCOUNT OFF;
                RETURN;
            END
        IF @DataZmianyStatusu IS NULL
            BEGIN
                SET @DataZmianyStatusu = GetDate();
            --RAISERROR('CDN.epDelegacje_Edit. Dla wartości @Status różnych od NULL, parametr @DataZmianyStatusu jest wymagany.', 16, 1)
            --SET NOCOUNT OFF
            --RETURN
            END
        IF len(@upd) > 0
            SET @upd = @upd + ', ';
        SET @upd = @upd + 'DLN_Status=' + CONVERT (NVARCHAR, @Status);
        DECLARE @sdZatwierdzona AS INT;
        SET @sdZatwierdzona = 0;
        DECLARE @sdBufor AS INT;
        SET @sdBufor = 1;
        DECLARE @sdZaakceptowanePolecenieWyjazdu AS INT;
        SET @sdZaakceptowanePolecenieWyjazdu = 2;
        DECLARE @sdZaakceptowaneWydatki AS INT;
        SET @sdZaakceptowaneWydatki = 3;
       IF @Status = @sdZatwierdzona
            BEGIN
                IF len(@upd) > 0
                    SET @upd = @upd + ', ';
                SET @upd = @upd + 'DLN_ZatwierdzenieData=' + CDN.Date2String(@DataZmianyStatusu, 120, 0);
                IF len(@upd) > 0
                    SET @upd = @upd + ', ';
                SET @upd = @upd + 'DLN_ZatwierdzenieOperatorId=' + CONVERT (NVARCHAR, @OperatorId);
            END
        ELSE
            IF @Status = @sdBufor
                BEGIN
                    IF len(@upd) > 0
                        SET @upd = @upd + ', ';
                    SET @upd = @upd + 'DLN_BuforData=' + CDN.Date2String(@DataZmianyStatusu, 120, 0);
                    IF len(@upd) > 0
                        SET @upd = @upd + ', ';
                    SET @upd = @upd + 'DLN_BuforOperatorId=' + CONVERT (NVARCHAR, @OperatorId);
                END
            ELSE
                IF @Status = @sdZaakceptowanePolecenieWyjazdu
                    BEGIN
                        IF len(@upd) > 0
                            SET @upd = @upd + ', ';
                        SET @upd = @upd + 'DLN_PolecenieWyjazduData=' + CDN.Date2String(@DataZmianyStatusu, 120, 0);
                        IF len(@upd) > 0
                            SET @upd = @upd + ', ';
                        SET @upd = @upd + 'DLN_PolecenieWyjazduOperatorId=' + CONVERT (NVARCHAR, @OperatorId);
                    END
                ELSE
                    IF @Status = @sdZaakceptowaneWydatki
                        BEGIN
                            IF len(@upd) > 0
                                SET @upd = @upd + ', ';
                            SET @upd = @upd + 'DLN_WydatkiData=' + CDN.Date2String(@DataZmianyStatusu, 120, 0);
                            IF len(@upd) > 0
                                SET @upd = @upd + ', ';
                            SET @upd = @upd + 'DLN_WydatkiOperatorId=' + CONVERT (NVARCHAR, @OperatorId);
                        END
    END
IF len(@upd) > 0
    BEGIN
        SET @sql = 'update CDN.DlgNag Set ' + @upd + ' where DlN_DlNId = ' + CONVERT (NVARCHAR, @ID);
        EXECUTE dbo.sp_executesql @sql;
  exec CDN.eDelegacje_RejestrOperacjiDodaj @ID, 2, @OperatorId;
    END
SET NOCOUNT OFF;
