CREATE FUNCTION cdn.OptimaNazwaObiektuEx (@typId INT, @subTyp INT, @jezykId INT)
  RETURNS     NVARCHAR(256)
  AS
  BEGIN
    DECLARE @nazwa NVARCHAR(256)
 IF @jezykId IS NULL SET @jezykId = cdn.UI_LCID()
 IF @subTyp IS NULL
 BEGIN
  SELECT TOP 1 @nazwa = ROPTOb_Nazwa  FROM [CDN].[RejestrOperacjiTypyObiektow] WHERE ROPTOb_Typ = @typId AND ROPTOb_Jezyk = @jezykId
  IF @nazwa IS NULL SET @nazwa = N''
  IF @nazwa = N'' AND @jezykId <> 1045
   SELECT TOP 1 @nazwa = ROPTOb_Nazwa  FROM [CDN].[RejestrOperacjiTypyObiektow] WHERE ROPTOb_Typ = @typId AND ROPTOb_Jezyk = 1045
    END
 ELSE
 BEGIN
  SELECT TOP 1 @nazwa = ROPTOb_Nazwa  FROM [CDN].[RejestrOperacjiTypyObiektow] WHERE ROPTOb_Typ = @typId AND ROPTOb_SubTyp = @subTyp AND ROPTOb_Jezyk = @jezykId
  IF @nazwa IS NULL SET @nazwa = N''
  IF @nazwa = N'' AND @jezykId <> 1045
   SELECT TOP 1 @nazwa = ROPTOb_Nazwa  FROM [CDN].[RejestrOperacjiTypyObiektow] WHERE ROPTOb_Typ = @typId AND ROPTOb_SubTyp = @subTyp AND ROPTOb_Jezyk = 1045
 END
 IF @nazwa IS NULL SET @nazwa = N''
 RETURN @nazwa
  END
