CREATE PROCEDURE CDN.KonfigWartosc
@numer  int,
@wartosc    nvarchar(254) OUTPUT
AS
BEGIN
        SET NOCOUNT ON
        DECLARE @sqltxt NVARCHAR(512)
        DECLARE @ParamDefinition NVARCHAR(64)
        SET @sqltxt = N'SELECT @konWartosc = Kon_Wartosc FROM ' + CDN.BazaKonfiguracyjna() + N'.cdn.Konfig WHERE Kon_Numer=@konNumer'
        SET @ParamDefinition = N'@konNumer int, @konWartosc nvarchar(254) OUTPUT';
        EXEC sp_executeSql @sqltxt, @ParamDefinition, @konNumer=@numer, @konWartosc=@wartosc OUTPUT
        SET NOCOUNT OFF
END
