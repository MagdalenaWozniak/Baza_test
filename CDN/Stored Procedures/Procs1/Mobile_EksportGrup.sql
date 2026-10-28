CREATE Procedure [CDN].[Mobile_EksportGrup]
 @ID     INT, -- ID centrum praw struktury firmy - id mobilnego sprzedawcy
 @TypEksportu   INT, -- Typ eksportu (0 - różnicowy, 1 - pełny)
 @PackageSize   INT, -- rozmiar paczki
 @PackageNumber INT  -- numer paczki
AS
    DECLARE @TimeStamp INT
    DECLARE @Typ_Twr SMALLINT
    DECLARE @Typ_GrT SMALLINT
    DECLARE @Typ_Knt SMALLINT
    DECLARE @Typ_GrK SMALLINT
    SET @Typ_Twr = 16
    SET @Typ_GrT = -16
    SET @Typ_Knt = 32
    SET @Typ_GrK = -32
    UPDATE CDN.DetalStanowiska SET DSta_TS_Synchrogrup = GetDate() WHERE DSta_DStaId=@ID
 SELECT DISTINCT IDENTITY(INT,1,1) AS Rank,
   TwG_GIDTyp,
   TwG_GIDNumer,
   TwG_GrOTyp,
   TwG_GrONumer,
   TwG_Kod,
   TwG_Nazwa
      INTO #TempTwG
 FROM    CDN.TwrGrupy
   JOIN CDN.DetalStanowiska ON DSta_DStaId=@ID
 WHERE (TwG_GIDTyp = @Typ_GrT AND EXISTS(SELECT * FROM CDN.TwrGrupy WHERE TwG_GIDTyp = @Typ_GrT  AND dateadd( second, TwG_CzasModyfikacji,CONVERT(DATETIME,'1990-01-01',120)) > CASE WHEN @TypEksportu=0 THEN DSta_TS_SynchrogrupPotw ELSE 0 END ))
    OR (TwG_GIDTyp = @Typ_Twr AND TwG_GIDNumer > 0
    AND dateadd( second, TwG_CzasModyfikacji,CONVERT(DATETIME,'1990-01-01',120)) > CASE WHEN @TypEksportu=0 THEN DSta_TS_SynchrogrupPotw ELSE 0 END)
 DELETE FROM #TempTwG
 WHERE Rank <= @packageSize * (@packageNumber - 1) OR Rank > @packageSize * @packageNumber
 SELECT * FROM #TempTwG
/*
 SELECT DISTINCT IDENTITY(INT,1,1) AS Rank,
   KnG_GIDTyp,
   KnG_GIDNumer,
   KnG_GrOTyp,
   KnG_GrONumer,
   KnG_Akronim
      INTO #TempKnG
 FROM    CDN.KntGrupy
   JOIN CDN.PicoKonfig ON PcK_CentrumID=@CentrumID
 WHERE (KnG_GIDTyp = @Typ_GrK AND EXISTS(SELECT * FROM CDN.KntGrupy WHERE KnG_GIDTyp = @Typ_GrK  AND KnG_CzasModyfikacji > PcK_TSSynchrGrupPTW ))
    OR (KnG_GIDTyp = @Typ_Knt AND KnG_GIDNumer > 0 AND KnG_CzasModyfikacji > PcK_TSSynchrGrupPTW )
 DELETE FROM #TempKnG
 WHERE Rank <= @packageSize * (@packageNumber - 1) OR Rank > @packageSize * @packageNumber
 SELECT * FROM #TempKnG
*/
