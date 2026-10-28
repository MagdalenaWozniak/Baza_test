CREATE PROCEDURE CDN.IndywidualnyCennik(@PodmiotID INT, @TwrGrupa INT, @nieaktywne INT)
AS
 SET NOCOUNT ON
    DECLARE @Cennik TABLE (TwrId INT, TypRabatu SMALLINT, RabatCena DECIMAL(17,4), TypCenyNB SMALLINT, Waluta NVARCHAR(3), PRIMARY KEY (TwrId))
   DECLARE @TowaryGrupy TABLE (TId INT IDENTITY(1,1), TwrId INT, PRIMARY KEY (TId))
   DECLARE @TwrId INT, @PodmiotTyp SMALLINT, @NumerCeny INT, @TwrIDMax INT, @TId INT, @TIdMax INT
     SELECT @PodmiotTyp=1
     SELECT @NumerCeny = Knt_Ceny FROM CDN.Kontrahenci Where Knt_KntId = @PodmiotId
     INSERT INTO @TowaryGrupy (TwrId)
     SELECT Twr_TwrId FROM CDN.Towary
     WHERE (Twr_TwGGIDNumer = @TwrGrupa OR @TwrGrupa=-1) AND (@nieaktywne=1 OR Twr_Nieaktywny=0)
  ORDER BY Twr_TwrId
     SELECT @TIdMax = MAX(TId) FROM @TowaryGrupy
      SELECT @TId = 1
        WHILE (1=1 AND @TId <= @TIdMax)
         BEGIN
           SELECT @TwrId = TwrId FROM @TowaryGrupy WHERE TId = @TId
           INSERT INTO @Cennik (TwrId, TypRabatu, RabatCena, TypCenyNB, Waluta)
            SELECT @TwrId, TypRabatu, RabatCena, Typcenynb, Waluta FROM CDN.fnObliczRabat(1, @PodmiotId, @TwrId)
              SET @TId = @TId + 1
              IF @TIdMAX > @TID AND @@ROWCOUNT = 0 BREAK
         END
 SET NOCOUNT OFF
   IF  @NumerCeny = 0
  SELECT T.Twr_Kod,
    T.Twr_Nazwa,
    Cen.TypCenyNB,
    CASE Cen.TypRabatu WHEN 1 THEN Cen.RabatCena ELSE ROUND(Twc.TwC_Wartosc * (100-Cen.RabatCena)/100,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end) END AS Cena,
    CASE Cen.TypRabatu WHEN 1 THEN Cen.Waluta ELSE TwC.TwC_Waluta END AS Waluta,
    CASE Cen.TypRabatu WHEN 1 THEN
      CASE WHEN Cen.TypCenyNB = 1 THEN 'netto' ELSE 'brutto' END
    ELSE CASE WHEN TwC.TwC_Typ = 1 THEN 'netto' ELSE 'brutto' END
    END AS NettoBrutto,
    CASE Cen.TypRabatu WHEN 1 THEN 0 ELSE Cen.RabatCena END AS Rabat,
    Twr_Nieaktywny, null as rab_rabid
          FROM CDN.Towary T
          JOIN @Cennik Cen on T.Twr_TwrId = Cen.TwrId
          JOIN CDN.TwrCeny TwC ON TwC.TwC_TwrId = T.Twr_TwrId AND TwC.TwC_TwCNumer = T.Twr_TwCNumer
          ORDER BY T.Twr_Kod
   ELSE
  SELECT T.Twr_Kod, T.Twr_Nazwa, Cen.TypCenyNB,
    CASE Cen.TypRabatu WHEN 1 THEN Cen.RabatCena ELSE ROUND(TwC.TwC_Wartosc * (100-Cen.RabatCena)/100,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end) END AS Cena,
    CASE Cen.TypRabatu WHEN 1 THEN Cen.Waluta ELSE TwC.TwC_Waluta END AS Waluta,
    CASE Cen.TypRabatu WHEN 1 THEN
      CASE WHEN Cen.TypCenyNB = 1 THEN 'netto' ELSE 'brutto' END
    ELSE CASE WHEN TwC.TwC_Typ = 1 THEN 'netto' ELSE 'brutto' END
    END AS NettoBrutto,
    CASE Cen.TypRabatu WHEN 1 THEN 0 ELSE Cen.RabatCena END AS Rabat,
    Twr_NieAktywny, null as rab_rabid
         FROM CDN.Towary T
         JOIN @Cennik Cen ON T.Twr_TwrId= Cen.TwrId
         JOIN CDN.TwrCeny TwC ON TwC.TwC_TwrId = T.Twr_TwrId AND TwC.TwC_TwCNumer = @NumerCeny
         ORDER BY Twr_Kod
