CREATE PROCEDURE CDN.ObrotyKBMW
 @RejestrID INT,
 @ZakresDat INT,
 @DataOdChar CHAR(10),
 @DataDoChar CHAR(10),
 @Przychody INT,
 @Rozchody INT,
 @BlokPrac INT,
 @BlokTylkoWynagr INT,
 @OpeId INT,
 @Plus TINYINT
AS
SET NOCOUNT ON
-- Kreujemy tabelę wynikową
DECLARE @tmp TABLE
(
NumerPelny NVARCHAR(30), NumerObcy NVARCHAR(256), DataDok DATETIME, Kwota DECIMAL(15,2), KwotaSys DECIMAL(15,2), Kierunek INT,
PodmiotTyp INT, PodmiotID INT, Wynagrodzenie INT,
TypKursu INT, NazwaTypuKursu NVARCHAR(45), DataKur DATETIME, KursL DECIMAL(15,4), KursM DECIMAL(15, 0),
PrzychRozl DECIMAL(15,2), PrzychRozlSys DECIMAL(15,2), RozchRozl DECIMAL(15,2), RozchRozlSys DECIMAL(15,2), RozKurSys DECIMAL(15,2),
dokTyp TINYINT, dokID INT, Poziom TINYINT, parentTyp TINYINT, parentID INT PRIMARY KEY (Poziom, DataDok, dokTyp, dokID, parentTyp, parentID)
)
DECLARE @DataOd     DATETIME
DECLARE @DataDo     DATETIME
SET @DataOd = CONVERT(datetime, @DataOdChar, 120)
SET @DataDo = CONVERT(datetime, @DataDoChar, 120)
CREATE TABLE #kursy (wku_wkuid int , wku_nazwa NVARCHAR(45) PRIMARY KEY (wku_wkuid))
DECLARE @query nVARCHAR(1024)
SET @query =N'insert into #kursy (wku_wkuid, wku_nazwa) select wku_wkuid, wku_nazwa from ' + cdn.BazaKonfiguracyjna() + '.cdn.WalKursy'
EXECUTE dbo.sp_executesql @query
-- Ładujemy do tabeli wynikowej pierwszy poziom dwupoziomowego drzewa
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
-- Rozliczone (częściowo lub całkowicie) BOMWKW
SELECT NumerPelny = BOMW_NumerPelny, NumerObcy = BOMW_NumerObcy, DataDok = BOMW_DataDok, Kwota = BOMW_Kwota, KwotaSys = BOMW_KwotaSys, Kierunek = BOMW_Kierunek,
PodmiotTyp = 0, PodmiotID = 0, Wynagrodzenie = 0,
TypKursu = BOMW_KursNumer, NazwaTypuKursu = MAX(Wku_Nazwa), DataKur = BOMW_DataKur, KursL = BOMW_KursL, KursM=BOMW_KursM,
PrzychRozl = 0, PrzychRozlSys = 0,
RozchRozl = BOMW_KwotaRozMW, RozchRozlSys = BOMW_KwotaRozSysMW,
RozKurSys = SUM(BRKMW_RoznicaKursowaSys),
dokTyp = 0, dokID = BOMW_BOMWID, 1, parentTyp = 0, parentID = BOMW_BOMWID
FROM cdn.BnkBOMW
JOIN cdn.BnkRozKwotyMW ON BRKMW_LDokTyp=3 AND BRKMW_LDokID=BOMW_BOMWID
JOIN #kursy on wku_wkuid = BOMW_KursNumer
WHERE BOMW_BRaID = @RejestrID AND BOMW_KwotaRozSysMW<>0
AND (@ZakresDat=0 OR BOMW_DataDok BETWEEN @DataOd AND @DataDo)
AND (@Rozchody=1 AND BOMW_Kierunek=-1)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BOMW_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BOMW_BRaID, @OpeId, 4, 2) = 0)
GROUP BY BOMW_NumerPelny, BOMW_NumerObcy, BOMW_DataDok, BOMW_Kwota, BOMW_KwotaSys, BOMW_Kierunek, BOMW_KursNumer, BOMW_DataKur, BOMW_KursL, BOMW_KursM, BOMW_KwotaRozMW, BOMW_KwotaRozSysMW, BOMW_BOMWID
UNION ALL
-- Rozliczone (częściowo lub całkowicie) KW
SELECT NumerPelny = BZp_NumerPelny, NumerObcy = BZp_NumerObcy, DataDok = BZp_DataDok, Kwota = BZp_Kwota, KwotaSys = BZp_KwotaSys, Kierunek = BZp_Kierunek,
PodmiotTyp = BZp_PodmiotTyp, PodmiotID = BZp_PodmiotID, Wynagrodzenie = BZp_Wynagrodzenie,
TypKursu = BZp_KursNumer, NazwaTypuKursu = MAX(Wku_Nazwa), DataKur = BZp_DataKur, KursL = BZp_KursL, KursM=BZp_KursM,
PrzychRozl = 0, PrzychRozlSys = 0,
RozchRozl = BZp_KwotaRozMW, RozchRozlSys = BZp_KwotaRozSysMW,
RozKurSys = SUM(BRKMW_RoznicaKursowaSys),
dokTyp = 2, dokID = BZp_BZpID, 1, parentTyp = 2, parentID = BZp_BZpID
FROM cdn.BnkZapisy
JOIN cdn.BnkRozKwotyMW ON BRKMW_LDokTyp=2 AND BRKMW_LDokID=BZp_BZpID
JOIN #kursy on wku_wkuid = BZp_KursNumer
WHERE BZp_BRaID = @RejestrID AND BZp_MagazynWalut=1 AND BZp_KwotaRozSysMW<>0
AND (@Rozchody=1 AND BZp_Kierunek=-1)
AND (@ZakresDat=0 OR BZp_DataDok BETWEEN @DataOd AND @DataDo)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZp_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZp_BRaID, @OpeId, 4, 2) = 0)
GROUP BY BZp_NumerPelny, BZp_NumerObcy, BZp_DataDok, BZp_Kwota, BZp_KwotaSys, BZp_Kierunek,
BZp_PodmiotTyp, BZp_PodmiotID, BZp_Wynagrodzenie,
BZp_KursNumer, BZp_DataKur, BZp_KursL, BZp_KursM, BZp_KwotaRozMW, BZp_KwotaRozSysMW, BZp_BZpID
UNION ALL
-- Rozliczone (częściowo lub całkowicie) BOMWKP
SELECT NumerPelny = BOMW_NumerPelny, NumerObcy = BOMW_NumerObcy, DataDok = BOMW_DataDok, Kwota = BOMW_Kwota, KwotaSys = BOMW_KwotaSys, Kierunek = BOMW_Kierunek,
PodmiotTyp = 0, PodmiotID = 0, Wynagrodzenie = 0,
TypKursu = BOMW_KursNumer, NazwaTypuKursu = MAX(Wku_Nazwa), DataKur = BOMW_DataKur, KursL = BOMW_KursL, KursM=BOMW_KursM,
PrzychRozl = BOMW_KwotaRozMW, PrzychRozlSys = BOMW_KwotaRozSysMW,
RozchRozl = 0, RozchRozlSys = 0,
RozKurSys = SUM(BRKMW_RoznicaKursowaSys),
dokTyp = 0, dokID = BOMW_BOMWID, 1, parentTyp = 0, parentID = BOMW_BOMWID
FROM cdn.BnkBOMW
JOIN cdn.BnkRozKwotyMW ON BRKMW_PDokTyp=3 AND BRKMW_PDokID=BOMW_BOMWID
JOIN #kursy on wku_wkuid = BOMW_KursNumer
WHERE BOMW_BRaID = @RejestrID AND BOMW_KwotaRozSysMW<>0
AND (@ZakresDat=0 OR BOMW_DataDok BETWEEN @DataOd AND @DataDo)
AND (@Przychody=1 AND BOMW_Kierunek=1)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BOMW_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BOMW_BRaID, @OpeId, 4, 2) = 0)
GROUP BY BOMW_NumerPelny, BOMW_NumerObcy, BOMW_DataDok, BOMW_Kwota, BOMW_KwotaSys, BOMW_Kierunek, BOMW_KursNumer, BOMW_DataKur, BOMW_KursL, BOMW_KursM, BOMW_KwotaRozMW, BOMW_KwotaRozSysMW, BOMW_BOMWID
UNION ALL
-- Rozliczone (częściowo lub całkowicie) KP
SELECT NumerPelny = BZp_NumerPelny, NumerObcy = BZp_NumerObcy, DataDok = BZp_DataDok, Kwota = BZp_Kwota, KwotaSys = BZp_KwotaSys, Kierunek = BZp_Kierunek,
PodmiotTyp = BZp_PodmiotTyp, PodmiotID = BZp_PodmiotID, Wynagrodzenie = BZp_Wynagrodzenie,
TypKursu = BZp_KursNumer, NazwaTypuKursu = MAX(Wku_Nazwa), DataKur = BZp_DataKur, KursL = BZp_KursL, KursM=BZp_KursM,
PrzychRozl = BZp_KwotaRozMW, PrzychRozlSys = BZp_KwotaRozSysMW,
RozchRozl = 0, RozchRozlSys = 0,
RozKurSys = SUM(BRKMW_RoznicaKursowaSys),
dokTyp = 2, dokID = BZp_BZpID, 1, parentTyp = 2, parentID = BZp_BZpID
FROM cdn.BnkZapisy
JOIN cdn.BnkRozKwotyMW ON BRKMW_PDokTyp=2 AND BRKMW_PDokID=BZp_BZpID
JOIN #kursy on wku_wkuid = BZp_KursNumer
WHERE BZp_BRaID = @RejestrID AND BZp_MagazynWalut=1 AND BZp_KwotaRozSysMW<>0
AND (@Przychody=1 AND BZp_Kierunek=1)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZp_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZp_BRaID, @OpeId, 4, 2) = 0)
AND (@ZakresDat=0 OR BZp_DataDok BETWEEN @DataOd AND @DataDo)
GROUP BY BZp_NumerPelny, BZp_NumerObcy, BZp_DataDok, BZp_Kwota, BZp_KwotaSys, BZp_Kierunek,
BZp_PodmiotTyp, BZp_PodmiotID, BZp_Wynagrodzenie,
BZp_KursNumer, BZp_DataKur, BZp_KursL, BZp_KursM, BZp_KwotaRozMW, BZp_KwotaRozSysMW, BZp_BZpID
)
-- Ładujemy do tabeli wynikowej drugi poziom dwupoziomowego drzewa (dokumenty rozliczające dokumenty pierwszego poziomu)
    -- BOMWKW ->> BOMWKP (podpinamy BOMWKP rozliczające BOMWKW)
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
SELECT BOMW_NumerPelny, BOMW_NumerObcy, BOMW_DataDok, BOMW_Kwota, BOMW_KwotaSys, BOMW_Kierunek,
0, 0, 0,
BOMW_KursNumer, Wku_Nazwa, BOMW_DataKur, BOMW_KursL, BOMW_KursM,
BRKMW_Kwota, BRKMW_KwotaSysP, 0, 0, BRKMW_RoznicaKursowaSys,
0, BOMW_BOMWID, 2, dokTyp, dokID
FROM @tmp
JOIN cdn.BnkRozKwotyMW ON BRKMW_LDokTyp=3 AND BRKMW_LDokID=dokID AND BRKMW_PDokTyp=3 --rozliczenia, w którym bieżące BOMWKW jest lewym dokumentem
JOIN cdn.BnkBOMW ON BOMW_BOMWID=BRKMW_PDokID -- szukamy rozliczających BOMWKP (KP, więc po prawej stonie rozliczenia)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BOMW_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BOMW_BRaID, @OpeId, 4, 2) = 0)
join #kursy on wku_wkuid = TypKursu
WHERE Poziom=1 AND dokTyp=0 AND Kierunek=-1 --Rozliczane dokumenty BOMWKW
)
 -- BOMWKW ->> KP (podpinamy KP rozliczające BOMWKW)
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
SELECT BZp_NumerPelny, BZp_NumerObcy, BZp_DataDok, BZp_Kwota, BZp_KwotaSys, BZp_Kierunek,
BZp_PodmiotTyp, BZp_PodmiotID, BZp_Wynagrodzenie,
BZp_KursNumer, Wku_Nazwa, BZp_DataKur, BZp_KursL, BZp_KursM,
BRKMW_Kwota, BRKMW_KwotaSysP, 0, 0, BRKMW_RoznicaKursowaSys,
2, BZp_BZpID, 2, dokTyp, dokID
FROM @tmp
JOIN cdn.BnkRozKwotyMW ON BRKMW_LDokID=dokID AND BRKMW_PDokTyp=2 AND BRKMW_LDokTyp=3 --rozliczenia, w którym bieżące BOMWKW jest lewym dokumentem
JOIN cdn.BnkZapisy ON BZp_BZpID=BRKMW_PDokID -- szukamy rozliczających KP (KP, więc po prawej stonie rozliczenia)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZp_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZp_BRaID, @OpeId, 4, 2) = 0)
join #kursy on wku_wkuid = TypKursu
WHERE Poziom=1 AND dokTyp=0 AND Kierunek=-1 --Rozliczane dokumenty BOMWKW
)
 -- KW ->> BOMWKP (podpinamy BOMWKP rozliczające KW)
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
SELECT BOMW_NumerPelny, BOMW_NumerObcy, BOMW_DataDok, BOMW_Kwota, BOMW_KwotaSys, BOMW_Kierunek,
0, 0, 0,
BOMW_KursNumer, Wku_Nazwa, BOMW_DataKur, BOMW_KursL, BOMW_KursM,
BRKMW_Kwota, BRKMW_KwotaSysP, 0, 0, BRKMW_RoznicaKursowaSys,
0, BOMW_BOMWID, 2, dokTyp, dokID
FROM @tmp
JOIN cdn.BnkRozKwotyMW ON BRKMW_LDokTyp=2 AND BRKMW_LDokID=dokID AND BRKMW_PDokTyp=3 --rozliczenia, w którym bieżące KW jest lewym dokumentem
JOIN cdn.BnkBOMW ON BOMW_BOMWID=BRKMW_PDokID -- szukamy rozliczających BOMWKP (KP, więc po prawej stonie rozliczenia)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BOMW_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BOMW_BRaID, @OpeId, 4, 2) = 0)
join #kursy on wku_wkuid = TypKursu
WHERE Poziom=1 AND dokTyp=2 AND Kierunek=-1 --Rozliczane dokumenty KW
)
  -- KW ->> KP (podpinamy KP rozliczające KW)
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
SELECT BZp_NumerPelny, BZp_NumerObcy, BZp_DataDok, BZp_Kwota, BZp_KwotaSys, BZp_Kierunek,
BZp_PodmiotTyp, BZp_PodmiotID, BZp_Wynagrodzenie,
BZp_KursNumer, Wku_Nazwa, BZp_DataKur, BZp_KursL, BZp_KursM,
BRKMW_Kwota, BRKMW_KwotaSysP, 0, 0, BRKMW_RoznicaKursowaSys,
2, BZp_BZpID, 2, dokTyp, dokID
FROM @tmp
JOIN cdn.BnkRozKwotyMW ON BRKMW_LDokTyp=2 AND BRKMW_LDokID=dokID AND BRKMW_PDokTyp=2 --rozliczenia, w którym bieżące KW jest lewym dokumentem
JOIN cdn.BnkZapisy ON BZp_BZpID=BRKMW_PDokID -- szukamy rozliczających KP (KP, więc po prawej stonie rozliczenia)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZp_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZp_BRaID, @OpeId, 4, 2) = 0)
join #kursy on wku_wkuid = TypKursu
WHERE Poziom=1 AND dokTyp=2 AND Kierunek=-1 --Rozliczane dokumenty KW
)
  -- BOMWKP ->> BOMWKW (podpinamy BOMWKW rozliczające BOMWKP)
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
SELECT BOMW_NumerPelny, BOMW_NumerObcy, BOMW_DataDok, BOMW_Kwota, BOMW_KwotaSys, BOMW_Kierunek,
0, 0, 0,
BOMW_KursNumer, Wku_Nazwa, BOMW_DataKur, BOMW_KursL, BOMW_KursM,
0, 0, BRKMW_Kwota, BRKMW_KwotaSysL, BRKMW_RoznicaKursowaSys,
0, BOMW_BOMWID, 2, dokTyp, dokID
FROM @tmp
JOIN cdn.BnkRozKwotyMW ON BRKMW_PDokTyp=3 AND BRKMW_PDokID=dokID AND BRKMW_LDokTyp=3 --rozliczenia, w którym bieżące BOMWKP jest prawym dokumentem
JOIN cdn.BnkBOMW ON BOMW_BOMWID=BRKMW_LDokID -- szukamy rozliczających BOMWKW (KW, więc po lewej stonie rozliczenia)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BOMW_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BOMW_BRaID, @OpeId, 4, 2) = 0)
join #kursy on wku_wkuid = TypKursu
WHERE Poziom=1 AND dokTyp=0 AND Kierunek=1 --Rozliczane dokumenty BOMWKP
)
  -- BOMWKP ->> KW (KW rozliczające BOMWKP)
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
SELECT BZp_NumerPelny, BZp_NumerObcy, BZp_DataDok, BZp_Kwota, BZp_KwotaSys, BZp_Kierunek,
BZp_PodmiotTyp, BZp_PodmiotID, BZp_Wynagrodzenie,
BZp_KursNumer, Wku_Nazwa, BZp_DataKur, BZp_KursL, BZp_KursM,
0, 0, BRKMW_Kwota, BRKMW_KwotaSysL, BRKMW_RoznicaKursowaSys,
2, BZp_BZpID, 2, dokTyp, dokID
FROM @tmp
JOIN cdn.BnkRozKwotyMW ON BRKMW_PDokTyp=3 AND BRKMW_PDokID=dokID AND BRKMW_LDokTyp=2 --rozliczenia, w którym bieżące BOMWKP jest prawym dokumentem
JOIN cdn.BnkZapisy ON BZp_BZpID=BRKMW_LDokID -- szukamy rozliczających KW (KW, więc po lewej stonie rozliczenia)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZp_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZp_BRaID, @OpeId, 4, 2) = 0)
join #kursy on wku_wkuid = TypKursu
WHERE Poziom=1 AND dokTyp=0 AND Kierunek=1 --Rozliczane dokumenty BOMWKP
)
  -- KP ->> BOMWKW (BOMWKW rozliczające KP)
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
SELECT BOMW_NumerPelny, BOMW_NumerObcy, BOMW_DataDok, BOMW_Kwota, BOMW_KwotaSys, BOMW_Kierunek,
0, 0, 0,
BOMW_KursNumer, Wku_Nazwa, BOMW_DataKur, BOMW_KursL, BOMW_KursM,
0, 0, BRKMW_Kwota, BRKMW_KwotaSysL, BRKMW_RoznicaKursowaSys,
0, BOMW_BOMWID, 2, dokTyp, dokID
FROM @tmp
JOIN cdn.BnkRozKwotyMW ON BRKMW_PDokTyp=2 AND BRKMW_PDokID=dokID AND BRKMW_LDokTyp=3 --rozliczenia, w którym bieżące KP jest prawym dokumentem
JOIN cdn.BnkBOMW ON BOMW_BOMWID=BRKMW_LDokID -- szukamy rozliczających BOMWKW (KW, więc po lewej stonie rozliczenia)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BOMW_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BOMW_BRaID, @OpeId, 4, 2) = 0)
join #kursy on wku_wkuid = TypKursu
WHERE Poziom=1 AND dokTyp=2 AND Kierunek=1 --Rozliczane dokumenty KP
)
  -- KP ->> KW (KW rozliczające KP)
INSERT INTO @tmp
(
NumerPelny, NumerObcy, DataDok, Kwota, KwotaSys, Kierunek,
PodmiotTyp, PodmiotID, Wynagrodzenie,
TypKursu, NazwaTypuKursu, DataKur, KursL, KursM,
PrzychRozl, PrzychRozlSys, RozchRozl, RozchRozlSys, RozKurSys,
dokTyp, dokID, Poziom, ParentTyp, ParentID
)
(
SELECT BZp_NumerPelny, BZp_NumerObcy, BZp_DataDok, BZp_Kwota, BZp_KwotaSys, BZp_Kierunek,
BZp_PodmiotTyp, BZp_PodmiotID, BZp_Wynagrodzenie,
BZp_KursNumer, Wku_Nazwa, BZp_DataKur, BZp_KursL, BZp_KursM,
0, 0, BRKMW_Kwota, BRKMW_KwotaSysL, BRKMW_RoznicaKursowaSys,
2, BZp_BZpID, 2, dokTyp, dokID
FROM @tmp
JOIN cdn.BnkRozKwotyMW ON BRKMW_PDokTyp=2 AND BRKMW_PDokID=dokID AND BRKMW_LDokTyp=2 --rozliczenia, w którym bieżące KP jest prawym dokumentem
JOIN cdn.BnkZapisy ON BZp_BZpID=BRKMW_LDokID -- szukamy rozliczających KW (KW, więc po lewej stonie rozliczenia)
AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZp_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZp_BRaID, @OpeId, 4, 2) = 0)
join #kursy on wku_wkuid = TypKursu
WHERE Poziom=1 AND dokTyp=2 AND Kierunek=1 --Rozliczane dokumenty KP
)
UPDATE t set t.NazwaTypuKursu = wku_nazwa from @tmp t join #kursy on wku_wkuid = t.typkursu
IF @BlokPrac<>0
  UPDATE @tmp set NumerPelny = ' - ', NumerObcy = ' - ' WHERE (PodmiotTyp=3 OR PodmiotTyp=4)
IF @BlokTylkoWynagr<>0
  UPDATE @tmp set NumerPelny = ' - ', NumerObcy = ' - ' WHERE (Wynagrodzenie=1)
SET NOCOUNT OFF
-- Zwracamy wyniki posortowane wg poziomu; na kliencie trzeba będzie je przesortować tak,
-- aby reokrdy poziomu 1 były posortowane po dacie, a rekordy drugiego poziomu były podczepione
-- pod swoich rodziców a w ramach nich posortowane po dacie, typie i ID.
SELECT * FROM @tmp ORDER BY Poziom ASC, DataDok ASC, dokTyp ASC, dokID ASC
