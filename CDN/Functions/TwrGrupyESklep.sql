CREATE  FUNCTION [CDN].[TwrGrupyESklep] (@GIDNumer INT)
RETURNS @TwrGrupy TABLE (TwGID INT, Kod nvarchar(50), Nazwa nvarchar(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT,eSklepLp int )
AS
 BEGIN
  DECLARE @GIDTyp SMALLINT
  DECLARE @Poziom INT
  SET @GIDTyp = -16
   INSERT INTO @TwrGrupy (TwGID, Kod, Nazwa, Poziom, GIDNumer, GrONumer, GIDTyp, GrOTyp, CzasModyfikacji,eSklepLp)
          SELECT TwG_TwGID, TwG_Kod, TwG_Nazwa, 0, TwG_GIDNumer, TwG_GrONumer, TwG_GIDTyp, TwG_GrOTyp, TwG_CzasModyfikacji,TwG_eSklepLp
          FROM CDN.TwrGrupy
          WHERE TwG_GiDNumer = @GiDNumer and TwG_GIDTyp = -16
  SET @Poziom = 0
  WHILE 1=1
   BEGIN
    INSERT INTO @TwrGrupy (TwGID, Kod, Nazwa, Poziom, GIDNumer, GrONumer, GIDTyp, GrOTyp, CzasModyfikacji,eSklepLp)
           SELECT TwG_TwGID, TwG_Kod, TwG_Nazwa,  @Poziom + 1, TwG_GIDNumer, TwG_GrONumer,TwG_GIDTyp, TwG_GrOTyp, TwG_CzasModyfikacji,TwG_eSklepLp
           FROM @TwrGrupy JOIN CDN.TwrGrupy
           ON TwG_GrOTyp = @GIDTyp AND TwG_GrONumer = GIDNumer AND Poziom = @Poziom AND TwG_GIDTyp = -16 where  TwG_TwGID <> 0
    IF @@ROWCOUNT = 0 BREAK
    SET @Poziom = @Poziom + 1
   END
   INSERT INTO @TwrGrupy (TwGID, Kod, Nazwa, Poziom, GIDNumer, GrONumer, GIDTyp, GrOTyp, CzasModyfikacji,eSklepLp)
          SELECT TwG_TwGID,  TwG_Kod, TwG_Nazwa,  1, TwG_GIDNumer, TwG_GrONumer, TwG_GIDTyp, TwG_GrOTyp, TwG_CzasModyfikacji,TwG_eSklepLp
          FROM @TwrGrupy
          JOIN CDN.TwrGrupy ON TwG_GrOTyp = -16 AND TwG_GrONumer = GIDNumer  AND TwG_GIDTyp = 16
          WHERE  TwG_TwGID <> 0
 RETURN
END
