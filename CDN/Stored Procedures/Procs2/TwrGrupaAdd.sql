CREATE PROCEDURE CDN.TwrGrupaAdd
@kod        VARCHAR(50),
@nazwa      NVARCHAR(255),
@ojciec     INT,
@GidNumer INT OUTPUT
  AS
BEGIN
    -- procedura dodaje do tabeli TwrGrupy nowa grupe
    SET @kod = UPPER(RTRIM(LTRIM(@kod)))
    IF @kod IS NULL OR RTRIM(LTRIM(@kod))= ''
    BEGIN
  SET @GidNumer = 0
  RETURN
    END
    IF @ojciec IS NULL
        SET @ojciec = 0
    -- Nie dodajemy, jeśli grupa o takim kodzie już istnieje
    IF NOT EXISTS (SELECT * FROM [CDN].[TwrGrupy] WHERE TwG_GrOTyp=-16 AND TwG_GidTyp=-16 AND TwG_GroNumer=@ojciec AND TwG_Kod=@kod)
    BEGIN
    DECLARE @TwG_GIDNumer INT
          SELECT  @TwG_GIDNumer = MAX(TwG_GIDNumer)+1 FROM [CDN].[TwrGrupy]
          INSERT INTO [CDN].[TwrGrupy]
          (
            TwG_GIDTyp,
            TwG_GIDFirma,
            TwG_GIDNumer,
            TwG_GIDLp,
            TwG_GrOTyp,
            TwG_GrOFirma,
            TwG_GrONumer,
            TwG_GrOLp,
            TwG_Kod,
            TwG_Nazwa
          )
          VALUES
          (
            -16,
             0,
             @TwG_GIDNumer,
             0,
            -16,
             0,
             @ojciec,
             0,
             @kod,
             IsNull(@nazwa, N'')
          )
  SET @GidNumer = IsNull(@TwG_GidNumer,0)
    END
    ELSE
    BEGIN
  -- zwroc numer i kod dla cdn.Towary
  SELECT  @GidNumer = IsNull(TwG_GidNumer,0) FROM [CDN].[TwrGrupy] WHERE TwG_GrOTyp=-16 AND TwG_GidTyp=-16 AND TwG_GroNumer=@ojciec AND TwG_Kod=@kod
 END
END
