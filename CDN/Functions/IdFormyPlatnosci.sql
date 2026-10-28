CREATE FUNCTION CDN.IdFormyPlatnosci(@nazwa NVARCHAR(20))
RETURNS INT
AS
BEGIN
 DECLARE @Fpl_Id INT
    SELECT @Fpl_Id = Fpl_FplID FROM CDN.FormyPlatnosci WHERE LOWER(Fpl_Nazwa) = LOWER(@nazwa)
 IF @Fpl_Id IS NULL
 BEGIN
  SET @nazwa = '%' + LOWER(@nazwa) + '%'
     SELECT @Fpl_Id = Fpl_FplID FROM CDN.FormyPlatnosci WHERE LOWER(Fpl_Nazwa) LIKE @nazwa
 END
 IF @Fpl_Id IS NULL SET @Fpl_Id = 0
 RETURN @Fpl_Id
END
