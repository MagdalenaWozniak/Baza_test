CREATE PROCEDURE cdn.UsunZdarzeniaKBDokumentu(@DokumentTyp INT, @DokumentID INT)
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @WhereParam NVARCHAR(1024)
 SELECT @WhereParam = 'BZd_DokumentTyp = ' + CONVERT(VARCHAR(10), @DokumentTyp) + ' AND BZd_DokumentID = ' + CONVERT(VARCHAR(10), @DokumentID)
 EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001', -- OptimaObjectType_ZdarzenieKB
         @ObiektSubTyp = 'BZd_Kierunek',
         @ObiektID = 'BZd_BZdID',
         @ObiektNazwa = 'BZd_NumerPelny',
         @OperacjaTyp = 3, -- OptimaOperationType_Modyfikacja
         @Opis = '''''',
         @From = 'cdn.BnkZdarzenia',
         @Where = @WhereParam
 DELETE cdn.BnkZdarzenia WHERE BZd_DokumentTyp = @DokumentTyp AND BZd_DokumentID = @DokumentID
 SET NOCOUNT OFF
END
