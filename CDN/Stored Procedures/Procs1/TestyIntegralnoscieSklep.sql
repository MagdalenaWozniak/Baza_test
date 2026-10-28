create  PROCEDURE [CDN].[TestyIntegralnoscieSklep]
@Typ int
as
DECLARE
  @SklepMin INT,
  @SklepMax INT,
     @StanowiskoId INT,
  @GrupaDomyslnaId INT,
  @NrCeny INT,
  @KosztPrzesylkiKarta NVARCHAR(50),
  @FantomMin INT,
  @FantomMax INT,
  @OjciecId INT,
  @DeaId INT,
  @JezykId SMALLINT,
  @WartoscTxt nVARCHAR(200)
if exists (select * from cdn.eSklepStanowiska where ess_typ = 1 and ESS_Nieaktywny=0)
begin
 CREATE TABLE #Towary (Typ INT, KodTowaru NVARCHAR(50), NazwaTowaru nVARCHAR(max), StanowiskoId INT)
 CREATE TABLE #TwrGrupyESklep (TwGID INT,  Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
 CREATE TABLE #Stanowiska (TblIdentity INT Identity(1,1), StanowiskoId INT, GrupaDomyslnaID INT, NrCeny INT, KosztPrzesylkiKarta nVARCHAR(50))
 CREATE TABLE #Fantomy (TblIdentity INT Identity(1,1), TwrId INT)
 INSERT INTO #Stanowiska (StanowiskoId, GrupaDomyslnaID, NrCeny, KosztPrzesylkiKarta)
 SELECT Ess_EssId, ESS_TwGNumer, ESS_NrCeny, Ess_KosztPrzesylki FROM CDN.eSklepStanowiska WHERE eSS_Typ = 1 AND ESS_Nieaktywny=0
 SELECT @SklepMin = 1, @SklepMax = @@ROWCOUNT
  WHILE @SklepMin < =  @SklepMax
  BEGIN
 SELECT @StanowiskoId = StanowiskoId, @GrupaDomyslnaID = GrupaDomyslnaId, @NrCeny = NrCeny, @KosztPrzesylkiKarta = KosztPrzesylkiKarta FROM #Stanowiska WHERE TblIdentity = @SklepMin
 INSERT INTO  #TwrGrupyESklep (TwGID, GIDNumer, GroNumer, Poziom, GIDTyp )
 SELECT TwGID, GIDNumer, GroNumer, Poziom, GIDTyp FROM CDN.TwrGrupyESklep (@GrupaDomyslnaID)
 DELETE FROM #TwrGrupyESklep WHERE GrONumer = @GrupaDomyslnaId and GIDTyp = 16
 if @Typ = 1
 INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId) -- sprawdzamy czy nie jest w dobrej grupie
 select 1,  Twr_Kod, twr_nazwa, @StanowiskoId   from cdn.towary  JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @StanowiskoId
 where Twes_Udostepnij =1 AND twr_kod <> @KosztPrzesylkiKarta  AND NOT EXISTS(SELECT GrONumer FROM #TwrGrupyESklep  WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
 if @Typ = 2
 INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId) -- sprawdzamy czy towar ma cene 0
 select 2,  Twr_Kod, twr_nazwa, @StanowiskoId   from cdn.towary  JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @StanowiskoId
 JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrID AND TwC_TwCNumer = @NrCeny
 where TwC_Wartosc =0 AND Twes_Udostepnij =1 AND twr_kod <> @KosztPrzesylkiKarta  AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep  WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
    if @Typ = 3
 INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId) -- sprawdzamy czy ma przynajmniej zdjęcie
 select 3,  Twr_Kod, twr_nazwa, @StanowiskoId   from cdn.towary  JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @StanowiskoId
 WHERE
 Twes_Udostepnij =1 AND twr_kod <> @KosztPrzesylkiKarta  AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep  WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
 AND
 ISNULL((SELECT COUNT (*) FROM CDN.DaneBinarneLinki LEFT OUTER JOIN CDN.DaneBinarne ON Dab_DabId = DBL_DabId
 WHERE DBL_TwrID = Twr_TwrId AND Dbl_Esklep = 1 AND DBL_Typ = 4 ),0) < 1
 if @Typ = 4
 INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId) -- sprawdzamy czy pojedyncza dana binarna > 10 MB
 select 4,  Twr_Kod, twr_nazwa, @StanowiskoId   from cdn.towary  JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @StanowiskoId
 WHERE
 Twes_Udostepnij =1 AND twr_kod <> @KosztPrzesylkiKarta  AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep  WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
 AND Twr_twrID in (select DBL_TwrID from cdn.danebinarne JOIN  cdn.danebinarnelinki on DAB_DABID = DBL_DabID Where DBL_ESklep = 1 and DaB_RozmiarWartosci/1024 >9999)
 if @Typ = 5
 INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)  -- niedozwolone znaki w opisie
    select 5, Twr_Kod,Twr_Nazwa, @StanowiskoId
  from cdn.towary
 LEFT OUTER JOIN cdn.twrjezykobcy JezES ON JezES.TwrJ_TwrId = Twr_TwrId and JezES.TwrJ_eSklepID = @StanowiskoId
 LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @StanowiskoId
 where Twes_Udostepnij =1
 AND twr_kod <> @KosztPrzesylkiKarta  AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep  WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
 AND (CDN.ValidateXMLChars(TwrJ_NazwaHTML)=1 OR CDN.ValidateXMLChars(TwrJ_OpisHTML)=1 /*sprawdzenie w nazwie i opisie języka*/
 OR  CDN.ValidateXMLChars(Twr_Nazwa)=1 /*sprawdzenie w nazwie*/
 OR CDN.ValidateXMLChars(Twr_Kod)=1 /*sprawdzenie w kodzie*/
 OR CDN.ValidateXMLChars(Twr_ProducentKod)=1 /*sprawdzenie w kodzie prod*/
 OR CDN.ValidateXMLChars(Twr_NumerKat)=1/*sprawdzenie w nr kat*/
 OR CDN.ValidateXMLChars(Twr_Opis)=1)  /*sprawdzenie w opisie*/
 if @Typ = 6 or @Typ = 7 or @Typ = 8 or @Typ = 10 or @Typ = 11
 IF EXISTS (SELECT * FROM CDN.Towary WHERE Twr_EsklepFantomID IS NOT NULL AND EXISTS (SELECT * from cdn.twresklep WHERE Twes_Udostepnij = 1 AND TweS_TwrId = Twr_TwrId)) -- fantomy
 BEGIN
 INSERT INTO #Fantomy (TwrId)
 SELECT DISTINCT Twr_EsklepFantomId FROM CDN.Towary WHERE Twr_ESklepFantomID IS NOT NULL AND EXISTS (SELECT * from cdn.twresklep WHERE Twes_Udostepnij = 1 AND TweS_TwrId = Twr_TwrId) ORDER BY  Twr_ESklepFantomID
 SELECT @FantomMin = 1, @FantomMax = @@ROWCOUNT
  WHILE @FantomMin < = @FantomMax
   BEGIN
   SELECT @OjciecId = TwrId FROM #Fantomy WHERE TblIdentity = @FantomMin
   -- fantomy ktore nie maja wartosci w atrybutach grupujacych
   if @Typ = 6
   INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)
   SELECT 6, Twr_kod,  Twr_Nazwa, 0 FROM CDN.Towary
   WHERE TwR_TwrId = @OjciecId AND NOT EXISTS (SELECT * FROM CDN.TwrAtrybuty WHERE Twr_TwrId = TwA_TwrId
   AND TwA_ESklep=1 AND TwA_AtrybutGrupujacyFantom=1)
   if @Typ = 10
   INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)
   SELECT 10, Twr_kod,  Twr_Nazwa, 0 FROM CDN.Towary
   WHERE TwR_TwrId = @OjciecId AND EXISTS (SELECT * FROM CDN.TwrAtrybuty WHERE Twr_TwrId = TwA_TwrId
   AND TwA_ESklep=1 AND TwA_AtrybutGrupujacyFantom=1 AND len(TwA_WartoscTxt) =0)
   if @Typ = 10
   INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)
   SELECT 10, Twr_kod,  Twr_Nazwa, 0 FROM CDN.Towary
   WHERE Twr_ESklepFantomID = @OjciecId AND EXISTS (SELECT * FROM CDN.TwrAtrybuty WHERE Twr_TwrId = TwA_TwrId
   AND TwA_ESklep=1 AND TwA_AtrybutGrupujacyFantom=1 AND len(TwA_WartoscTxt) =0)
   if @Typ = 6
   begin
    -- sprawdzamy czy fantomy nie maja duplikatow w atrybutach grupujacych o typie tekst
    ;WITH CTE AS (
    SELECT @OjciecID AS FantomID, 0 AS Poziom
    UNION ALL
    SELECT Twr_TwrID, 1 AS Poziom FROM CDN.Towary JOIN CTE ON Twr_ESklepFantomID = FantomID WHERE Twr_ESklepFantomID IS NOT NULL AND Twr_EsklepFantomId <> @OjciecId
    AND EXISTS (SELECT * from cdn.twresklep WHERE Twes_Udostepnij = 1 AND TweS_TwrId = Twr_TwrId)
    ),
     CTE2 AS (
    SELECT FantomId, TwA_DeaId AS DeaId, TwA_JezykId AS JezykId, TwA_WartoscTxt AS Txt FROM CTE JOIN CDN.TwrAtrybuty ON FantomId = TwA_TwrId
    WHERE TwA_ESklep=1 AND TwA_AtrybutGrupujacyFantom=1
    )
    INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)  -- fantomy
    select 6, max(twr_kod), max(twr_nazwa), 0 from cte2 join cdn.towary on fantomid = twr_twrid
    AND EXISTS (SELECT * from cdn.twresklep WHERE Twes_Udostepnij = 1 AND TweS_TwrId = Twr_TwrId)
    group by Txt, JezykId
    having count(*) > 1
   end
   -- sprawdzanie czy nie ma duplikatow atrybutow o typie lista
   if @Typ = 7
   IF EXISTS (SELECT * FROM CDN.Towary JOIN CDN.TwrAtrybuty ON Twr_TwrId = TwA_TwrId JOIN CDN.DefAtrybuty ON DeA_DeAId = TwA_DeAId
   WHERE Twr_Twrid = @OjciecId AND TwA_ESklep=1  AND TwA_AtrybutGrupujacyFantom=1 AND DeA_Format = 3)
   BEGIN
   INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)  -- fantomy
   SELECT 7, Twr_kod,  Twr_Nazwa, 0 FROM CDN.Towary
   WHERE TwR_TwrId = @OjciecId AND EXISTS (
   SELECT COUNT(*) FROM CDN.TwrAtrybuty JOIN CDN.DefAtrybuty ON DeA_DeAId = TwA_DeAId
   JOIN CDN.DefAtrElem ON DAE_DeAId = DeA_DeAId
   WHERE (Twr_TwrId = TwA_TwrId) AND TwA_ESklep=1  AND Dea_Format =  3 AND TwA_AtrybutGrupujacyFantom=1
   GROUP By DeA_DeAId,DAE_Wartosc
   HAVING COUNT(*) > 1
   )
   if @Typ = 7
   INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)  -- fantomy
   SELECT 7, Twr_kod,  Twr_Nazwa, 0 FROM CDN.Towary
   WHERE Twr_ESklepFantomID = @OjciecId AND EXISTS (
   SELECT COUNT(*) FROM CDN.TwrAtrybuty JOIN CDN.DefAtrybuty ON DeA_DeAId = TwA_DeAId
   JOIN CDN.DefAtrElem ON DAE_DeAId = DeA_DeAId
   WHERE (Twr_TwrId = TwA_TwrId) AND TwA_ESklep=1  AND Dea_Format =  3 AND TwA_AtrybutGrupujacyFantom=1
   GROUP By DeA_DeAId,DAE_Wartosc
   HAVING COUNT(*) > 1
   )
   END
   -- przypadek kiedy którys z towarow nie ma atrybutu grupujacego np. ojciec ma 2 dzieci, 1 dziecko nie ma atrybutu
   if @Typ = 11
   INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)  -- fantomy
   SELECT 11, C.Twr_Kod, C.Twr_Nazwa, @StanowiskoId FROM CDN.Towary A JOIN CDN.TwrAtrybuty B ON A.Twr_TwrId = B.TwA_TwrId
   JOIN CDN.Towary C ON C.Twr_ESklepFantomID = A.Twr_TwrId
   LEFT OUTER JOIN CDN.TwrAtrybuty D ON C.TwR_TwrId = D.TwA_TwrId AND B.TwA_DeAId  = D.TwA_DeAId
   WHERE
   A.Twr_Twrid = @OjciecId AND B.TwA_ESklep=1  AND B.TwA_AtrybutGrupujacyFantom=1
   AND isnull(D.TwA_AtrybutGrupujacyFantom,0) = 0
   -- fantomy, sprawdzamy czy ojciec nie jest podpiety jako dziecko
   if @Typ = 8
   INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId)
   SELECT 8, Twr_kod,  Twr_Nazwa, 0  FROM CDN.Towary A
   WHERE TwR_TwrId = @OjciecId AND Twr_eSKlepFantomid IS NOT NULL
   AND EXISTS (SELECT * from cdn.twresklep WHERE Twes_Udostepnij = 1 AND TweS_TwrId = Twr_TwrId)
   SELECT @FantomMin = @FantomMin +1
   END
 END
 SELECT @SklepMin = @SklepMin +1
 if @Typ = 9
 INSERT INTO #Towary (Typ, KodTowaru, NazwaTowaru, StanowiskoId) -- sprawdzamy czy pojedyncza zdjęcie waży > 500 kb
 select 9,  Twr_Kod, twr_nazwa, @StanowiskoId   from cdn.towary  JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @StanowiskoId
 WHERE
 Twes_Udostepnij =1 AND twr_kod <> @KosztPrzesylkiKarta  AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep  WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId )
 AND Twr_twrID in (select DBL_TwrID from cdn.danebinarne JOIN  cdn.danebinarnelinki on DAB_DABID = DBL_DabID Where DBL_ESklep = 1 AND Dbl_Typ = 4 and DaB_RozmiarWartosci/1024 >500)
 TRUNCATE TABLE #TwrGrupyESklep
  END
  select distinct typ as RowID, KodTowaru as Str1, nazwatowaru as Str2, StanowiskoId, ISNULL(ESS_Nazwa, 'wszystkie sklepy') as Str3  from #towary left outer join cdn.esklepstanowiska on ESS_ESSId = stanowiskoid
  order by typ
drop table #towary
drop table #TwrGrupyESklep
drop table #Stanowiska
drop table #Fantomy
END
