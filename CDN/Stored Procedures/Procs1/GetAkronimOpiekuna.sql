CREATE PROCEDURE CDN.GetAkronimOpiekuna
@opiekunTyp int,
@opiekunID  int,
@akronim nvarchar(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    IF @opiekunTyp = 3 OR @opiekunTyp = 4
     SELECT TOP 1 @akronim = PRI_Kod  FROM CDN.PracIdx  WHERE PRI_PraID = @opiekunID
    ELSE
    IF @opiekunTyp = 8
    BEGIN
        DECLARE @sqltxt NVARCHAR(512)
        DECLARE @paramDefinition NVARCHAR(32)
        SET @sqltxt = N'SELECT @symbol = Ope_Kod FROM '  + CDN.BazaKonfiguracyjna() + N'.CDN.Operatorzy WHERE Ope_OpeID = ' + convert(nvarchar(20), @opiekunID)
        SET @paramDefinition = N'@symbol nvarchar(20) OUTPUT';
        EXEC sp_executeSql @sqltxt, @paramDefinition, @symbol=@akronim OUTPUT
    END
 IF @akronim IS NULL SET @akronim = N''
    SET NOCOUNT OFF
END
