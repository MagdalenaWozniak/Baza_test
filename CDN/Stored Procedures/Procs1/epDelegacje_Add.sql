CREATE PROCEDURE [CDN].[epDelegacje_Add]
@KodPracownika NVARCHAR (20), @DataDokumentu DATETIME, @DataOd DATETIME, @DataDo DATETIME, @WyjazdZMZ SMALLINT, @Opis NVARCHAR (255), @CzyZagraniczna SMALLINT, @MiejsceDocelowe NVARCHAR(255)
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
IF NOT EXISTS (SELECT *
               FROM   CDN.PodmiotyView
               WHERE  Pod_PodmiotTyp = 3
                      AND Pod_Kod = @KodPracownika)
    BEGIN
        RAISERROR ('epDelegacje_Add. Nie znaleziono podmiotu [%s]w tabeli CDN.PodmiotyView.', 16, 1, @KodPracownika);
        SET NOCOUNT OFF;
        RETURN;
    END
IF @DataDokumentu IS NULL
    BEGIN
        RAISERROR ('epDelegacje_Add. Parametr @DataDokumentu jest wymagany.', 16, 1);
        SET NOCOUNT OFF;
        RETURN;
    END
IF @DataOd IS NULL
    BEGIN
        RAISERROR ('epDelegacje_Add. Parametr @DataOd jest wymagany.', 16, 1);
        SET NOCOUNT OFF;
        RETURN;
    END
IF @DataDo IS NULL
    SET @DataDo = @DataOd + 1;
SET @WyjazdZMZ = IsNull(@WyjazdZMZ, 0);
SET @Opis = IsNull(@Opis, '');
SET @MiejsceDocelowe = ISNULL(@MiejsceDocelowe, '')
DECLARE @sql AS NVARCHAR (2048);
SET @sql = 'declare @DataDokumentu DateTime; Set @DataDokumentu = ' + CDN.Date2String(@DataDokumentu, 120, 0) + ';' + 'declare @DataOd DateTime; Set @DataOd = ' + CDN.Date2String(@DataOd, 120, 0) + ';' + 'declare @DataDo DateTime; Set @DataDo = ' + CDN.Date2String(@DataDo, 120, 0) + ';' + 'exec CDN.epDelegacje_Insert NULL, NULL, NULL, NULL,' + '@DataDokumentu,' + '''' + @KodPracownika + ''',' + 'NULL, NULL,' + '@DataOd,' + '@DataDo,' + 'NULL,' + CONVERT (NVARCHAR, @WyjazdZMZ) + ',' + '''' + REPLACE(@Opis, '''', '''''''''') + ''',' + 'NULL,' + CONVERT (NVARCHAR, @OperatorId) + ',' + 'NULL,NULL,NULL, NULL,NULL,NULL,' + CONVERT (NVARCHAR, @CzyZagraniczna) + ',' + '''' + REPLACE(@MiejsceDocelowe, '''', '''''''''') + ''''; --'Convert(DateTime, ''' + convert(nvarchar, @DataOd, 120) + ''',120),''Convert(DateTime, ''' + convert(nvarchar, @DataDo, 120) + ''',120),'
EXECUTE dbo.sp_executesql @sql;
DECLARE @DelagacjaId AS INT;
SET @DelagacjaId = 0;
IF @@ERROR = 0
begin
    SET @DelagacjaId = IsNull(IDENT_CURRENT('CDN.DlgNag'), 0);
 exec CDN.eDelegacje_RejestrOperacjiDodaj @DelagacjaId, 1, @OperatorId;
end
--declare @DelagacjaElementId int;
--set @DelagacjaId = @@IDENTITY
SET NOCOUNT OFF;
--set @sql = 'select ' + convert(int, @DelagacjaId) + ' as DelagacjaId,' + convert(int, @DelagacjaElementId) + ' as DelagacjaElementId'
SET @sql = 'select ' + CONVERT (NVARCHAR, @DelagacjaId) + ' as DelagacjaId';
EXECUTE dbo.sp_executesql @sql;
