CREATE PROCEDURE CDN.GUS @DataOd DATETIME, @DataDo DATETIME
AS
SET NOCOUNT ON
SET @DataOd = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataOd) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataOd) AS NVARCHAR)+' 00:00:000', 120)
SET @DataDo = CONVERT(DATETIME, CAST(DATEPART(year ,@DataDo) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDo) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataDo) AS NVARCHAR)+' 00:00:000', 120)
--Tworzę tabelę tymczasową
CREATE TABLE #tblGUS (
 Tmp_PrzLZatr         DECIMAL(15,2), -- Przeciętna liczba zatrudnionych
 Tmp_LPrwOs           DECIMAL(15,2), -- Liczba pracowników w osobach
 Tmp_PrzLZnsR       DECIMAL(15,2), -- Przeciętna liczba zatr. na st. robotniczych
 Tmp_PrzLZnsNR       DECIMAL(15,2), -- Przeciętna liczba zatr. na st. nierobotniczych
 Tmp_PrzLZUczn       DECIMAL(15,2), -- Przeciętna liczba zatr. uczniów
 Tmp_CzPrzOg       DECIMAL(15,2), -- Czas przepracowany ogółem
 Tmp_CzPrzGN          DECIMAL(15,2), -- Czas przepracowany w godzinahc nadliczbowych
 Tmp_CzPrzOgBDN       DECIMAL(15,2), -- Czas przepracowany ogółem bez dni wolnych
 Tmp_CzNPOplac        DECIMAL(15,2), -- Czas nieprzepracowany - opłacony
 Tmp_CzNPUrlWyp       DECIMAL(15,2), -- Czas nieprzepracowany - urlop wypoczynkowy
 Tmp_CzNPChor         DECIMAL(15,2) -- Czas nieprzepracowany - Chorob.(bez godzin opłaconych przez ZUS)
 )
 exec CDN.GUSCalc @DataOd, @DataDo
SET NOCOUNT OFF
SELECT
 Tmp_PrzLZatr,
 Tmp_LPrwOs,
 Tmp_PrzLZnsR,
 Tmp_PrzLZnsNR,
 Tmp_PrzLZUczn,
 Tmp_CzPrzOg,
 Tmp_CzPrzGN,
 Tmp_CzPrzOgBDN,
 Tmp_CzNPOplac,
 Tmp_CzNPUrlWyp,
 Tmp_CzNPChor
FROM #tblGUS
--JOIN CDN.PracKod ON Pra_PraId = Tmp_PrcId
