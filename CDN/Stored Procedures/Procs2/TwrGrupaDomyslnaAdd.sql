CREATE PROCEDURE CDN.TwrGrupaDomyslnaAdd
@TwrKod   VARCHAR(50),
@TwrGidNumer INT,
@TwGGidNumer INT
  AS
BEGIN
    IF @TwrKod IS NULL OR RTRIM(LTRIM(@TwrKod))= '' RETURN
 IF @TwGGidNumer IS NULL RETURN
 -- Nie dodajemy, jeśli grupa o takim kodzie już istnieje
    IF NOT EXISTS (SELECT * FROM [CDN].[TwrGrupy]
  WHERE TwG_GrOTyp=-16 AND TwG_GIDTyp=16 AND TwG_GIDNumer=@TwrGidNumer AND TwG_GroNumer=@TwGGidNumer AND TwG_Kod=@TwrKod)
   BEGIN
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
               16,
               0,
               @TwrGidNumer,
               0,
              -16,
               0,
               @TwGGidNumer,
               0,
               @TwrKod,
               N''
            )
   END
END
