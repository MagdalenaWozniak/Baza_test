CREATE PROCEDURE cdn.ModyfikujZdarzeniaKBDokumentu(@DokumentTyp INT, @DokumentIDTable cdn.IdsTableType READONLY)
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @WhereParam NVARCHAR(1024)
 SELECT @WhereParam = 'BZd_DokumentTyp = ' + CONVERT(VARCHAR(10), @DokumentTyp) + ' AND BZd_DokumentID IN (SELECT ID FROM #IDS)'
 CREATE TABLE #IDS (ID INT)
 INSERT INTO #IDS SELECT distinct ID FROM @DokumentIDTable
 EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001', -- OptimaObjectType_ZdarzenieKB
         @ObiektSubTyp = 'BZd_Kierunek',
         @ObiektID = 'BZd_BZdID',
         @ObiektNazwa = 'BZd_NumerPelny',
         @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
         @Opis = '''''',
         @From = 'cdn.BnkZdarzenia',
         @Where = @WhereParam
 DROP TABLE #IDS
 SET NOCOUNT OFF
END
