CREATE FUNCTION CDN.TwrGrupa ( @Id INT, @Mode INT )
  RETURNS     NVARCHAR(MAX)
  AS
  BEGIN
    DECLARE @Grupa  NVARCHAR(MAX)
    SELECT TOP 1 @Grupa = Sciezka FROM CDN.fnTwrGrupy () WHERE GIDNumer = IsNull(@Id, 0)
    IF @Grupa IS NULL
  SET @Grupa = ''
    IF @Mode=1
  IF LTRIM(RTRIM(@Grupa))=''
   SET @Grupa = '(PUSTA)'
    RETURN  RTRIM(@Grupa)
  END
