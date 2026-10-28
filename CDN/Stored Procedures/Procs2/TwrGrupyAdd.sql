CREATE PROCEDURE CDN.TwrGrupyAdd
@sciezka    NVARCHAR(MAX),
@nazwa  NVARCHAR(255),
@GidNumer INT OUTPUT
  AS
BEGIN
    IF @sciezka IS NULL OR RTRIM(LTRIM(@sciezka)) = ''
    BEGIN
  SET @GidNumer = 0
  RETURN
 END
    DECLARE @TwG_GIDId  INT
    DECLARE @kod  VARCHAR(50)
    DECLARE @ojciecId INT
    DECLARE @from  INT
    DECLARE @to   INT
    DECLARE @ile  INT
    SET  @ojciecId = 0
    -- odrzuć wiodące spacje, \, TAB,
    SET @from = 1
 WHILE 1=1
  BEGIN
   DECLARE @znak CHAR
   SET @znak = SUBSTRING(@sciezka, @from, 1)
   IF @znak = '\' OR @znak = SPACE(1) OR @znak = CHAR(9) OR  @znak = CHAR(10) OR @znak = CHAR(13)
    BEGIN
     SET @from = @from + 1;
     CONTINUE;
    END
   ELSE
    BREAK
  END
    SET @to  = CHARINDEX('\', @sciezka, @from)
    -- by odrzucić grupę główna jeśli występuje
    IF  @to > 0
  BEGIN
   SET @ile = @to - @from
   IF @ile < 0 SET @ile = 0
   SET @kod = SUBSTRING(@sciezka, @from, @ile)
   IF RTRIM(LTRIM( @kod )) = 'Grupa Główna'
    SET @from = @from + @ile +1
  END
    WHILE 1=1
    BEGIN
        SET @to  = CHARINDEX('\', @sciezka, @from)
        IF @to = 0
        BEGIN
         SET @ile = LEN(@sciezka)- @from + 1
      IF @ile < 0 SET @ile = 0
            SET @kod = RTRIM(LTRIM(SUBSTRING(@sciezka, @from, @ile)))
            IF RTRIM(LTRIM( @kod )) = '' BREAK
            EXEC CDN.TwrGrupaAdd @kod, @nazwa, @ojciecId, @TwG_GIDId OUTPUT
            BREAK
        END
        ELSE
        BEGIN
         SET @ile = @to - @from
      IF @ile < 0 SET @ile = 0
            SET @kod = RTRIM(LTRIM(SUBSTRING(@sciezka, @from, @ile)))
            IF RTRIM(LTRIM( @kod )) = '' BREAK
            EXEC CDN.TwrGrupaAdd @kod, '', @ojciecId, @TwG_GIDId OUTPUT
            SELECT @ojciecId = IsNull(TwG_GIDNumer, 0) FROM [CDN].[TwrGrupy] WHERE TwG_GrOTyp=-16 AND TwG_GidTyp=-16 AND TwG_GrONumer = @ojciecId AND TwG_Kod = @kod
            SET @from = @to + 1
            CONTINUE
        END
    END
    SET @GidNumer = IsNull(@TwG_GIDId, 0)
    RETURN
END
