CREATE PROCEDURE CDN.RabatyKontrahenta_StalaCena
@Waluta     AS nvarchar(13),
@KntGrupaID    AS INT,
@KntID            AS INT,
@TwrGrupaID    AS INT,
@TwrID     AS INT
AS
BEGIN
if (@TwrID > 0 AND @TwrGrupaID > -1)
begin
SELECT Twr_Nazwa, Twr_Kod, Rab_Cena,
CASE WHEN Rab_Waluta = '' THEN @Waluta ELSE Rab_Waluta END AS Rab_Waluta,
CASE WHEN Rab_TypCenyNB = 1 THEN 'netto' ELSE 'brutto' END AS Rab_TypCenyNB,
CASE Rab_Typ WHEN 11 THEN 'Wszyscy' WHEN 12 THEN 'Grupa kontrahenta'
WHEN 13 THEN 'Kontrahent' END AS Rab_Typ,
Rab_RabId
FROM CDN.Rabaty
JOIN CDN.Towary ON Rab_TwrId=Twr_TwrId
WHERE ((Rab_Typ = 11 AND Twr_TwrID not in
(SELECT Twr_TwrID FROM cdn.rabaty JOIN cdn.towary ON rab_Twrid=twr_twrid
WHERE Rab_Typ=12 AND Rab_PodmiotId= @KntGrupaID
OR rab_typ=13 AND Rab_PodmiotId = @KntID)) OR
(Rab_Typ=12 AND Rab_PodmiotId= @KntGrupaID
AND Twr_TwrID NOT IN (SELECT Twr_TwrID FROM CDN.Rabaty JOIN cdn.towary ON rab_Twrid=twr_twrid
WHERE rab_typ=13 AND Rab_PodmiotId = @KntID)) OR
(Rab_Typ = 13 AND Rab_PodmiotId = @KntID))
AND Twr_TwrID = @TwrID AND Twr_TWGGIDNumer = @TwrGrupaID
ORDER BY Rab_Typ, Twr_Kod
end
ELSE IF (@TwrID > 0)
begin
SELECT Twr_Nazwa, Twr_Kod, Rab_Cena,
CASE WHEN Rab_Waluta = '' THEN @Waluta ELSE Rab_Waluta END AS Rab_Waluta,
CASE WHEN Rab_TypCenyNB = 1 THEN 'netto' ELSE 'brutto' END AS Rab_TypCenyNB,
CASE Rab_Typ WHEN 11 THEN 'Wszyscy' WHEN 12 THEN 'Grupa kontrahenta'
WHEN 13 THEN 'Kontrahent' END AS Rab_Typ,
Rab_RabId
FROM CDN.Rabaty
JOIN CDN.Towary ON Rab_TwrId=Twr_TwrId
WHERE ((Rab_Typ = 11 AND Twr_TwrID not in
(SELECT Twr_TwrID FROM cdn.rabaty JOIN cdn.towary ON rab_Twrid=twr_twrid
WHERE Rab_Typ=12 AND Rab_PodmiotId= @KntGrupaID
OR rab_typ=13 AND Rab_PodmiotId = @KntID)) OR
(Rab_Typ=12 AND Rab_PodmiotId= @KntGrupaID
AND Twr_TwrID NOT IN (SELECT Twr_TwrID FROM CDN.Rabaty JOIN cdn.towary ON rab_Twrid=twr_twrid
WHERE rab_typ=13 AND Rab_PodmiotId = @KntID)) OR
(Rab_Typ = 13 AND Rab_PodmiotId = @KntID))
AND Twr_TwrID = @TwrID
ORDER BY Rab_Typ, Twr_Kod
end
else if (@TwrGrupaID > -1)
begin
SELECT Twr_Nazwa, Twr_Kod, Rab_Cena,
CASE WHEN Rab_Waluta = '' THEN @Waluta ELSE Rab_Waluta END AS Rab_Waluta,
CASE WHEN Rab_TypCenyNB = 1 THEN 'netto' ELSE 'brutto' END AS Rab_TypCenyNB,
CASE Rab_Typ WHEN 11 THEN 'Wszyscy' WHEN 12 THEN 'Grupa kontrahenta'
WHEN 13 THEN 'Kontrahent' END AS Rab_Typ,
Rab_RabId
FROM CDN.Rabaty
JOIN CDN.Towary ON Rab_TwrId=Twr_TwrId
WHERE ((Rab_Typ = 11 AND Twr_TwrID not in
(SELECT Twr_TwrID FROM cdn.rabaty JOIN cdn.towary ON rab_Twrid=twr_twrid
WHERE Rab_Typ=12 AND Rab_PodmiotId= @KntGrupaID
OR rab_typ=13 AND Rab_PodmiotId = @KntID)) OR
(Rab_Typ=12 AND Rab_PodmiotId= @KntGrupaID
AND Twr_TwrID NOT IN (SELECT Twr_TwrID FROM CDN.Rabaty JOIN cdn.towary ON rab_Twrid=twr_twrid
WHERE rab_typ=13 AND Rab_PodmiotId = @KntID)) OR
(Rab_Typ = 13 AND Rab_PodmiotId = @KntID))
AND Twr_TWGGIDNumer = @TwrGrupaID
ORDER BY Rab_Typ, Twr_Kod
end
else
begin
SELECT Twr_Nazwa, Twr_Kod, Rab_Cena,
CASE WHEN Rab_Waluta = '' THEN @Waluta ELSE Rab_Waluta END AS Rab_Waluta,
CASE WHEN Rab_TypCenyNB = 1 THEN 'netto' ELSE 'brutto' END AS Rab_TypCenyNB,
CASE Rab_Typ WHEN 11 THEN 'Wszyscy' WHEN 12 THEN 'Grupa kontrahenta'
WHEN 13 THEN 'Kontrahent' END AS Rab_Typ,
Rab_RabId
FROM CDN.Rabaty
JOIN CDN.Towary ON Rab_TwrId=Twr_TwrId
WHERE ((Rab_Typ = 11 AND Twr_TwrID not in
(SELECT Twr_TwrID FROM cdn.rabaty JOIN cdn.towary ON rab_Twrid=twr_twrid
WHERE Rab_Typ=12 AND Rab_PodmiotId= @KntGrupaID
OR rab_typ=13 AND Rab_PodmiotId = @KntID)) OR
(Rab_Typ=12 AND Rab_PodmiotId= @KntGrupaID
AND Twr_TwrID NOT IN (SELECT Twr_TwrID FROM CDN.Rabaty JOIN cdn.towary ON rab_Twrid=twr_twrid
WHERE rab_typ=13 AND Rab_PodmiotId = @KntID)) OR
(Rab_Typ = 13 AND Rab_PodmiotId = @KntID))
ORDER BY Rab_Typ, Twr_Kod
end
END
