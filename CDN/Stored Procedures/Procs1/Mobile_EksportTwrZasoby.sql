CREATE PROCEDURE [CDN].[Mobile_EksportTwrZasoby]
@ID INT -- ID centrum praw struktury firmy
AS
BEGIN
DECLARE  @TwGNumer INT
SELECT @TwGNumer = dsta_twggidnumer from cdn.detalstanowiska where dsta_dstaid = @ID
CREATE TABLE #TwrGrupyESklep (TwGID INT, Kod NVARCHAR(50), Nazwa NVARCHAR(255), Poziom INT, GIDNumer INT, GrONumer INT, GIDTyp SMALLINT,GrOTyp SMALLINT, CzasModyfikacji INT, eSklepLp INT, PRIMARY KEY(Poziom, GrONumer, GIDNumer, GIDTyp))
INSERT INTO  #TwrGrupyESklep
SELECT * FROM CDN.TwrGrupyESklep (@TwGNumer)
-- Usługi
SELECT Twr_TwrId AS TwZ_TwrNumer, Mag_MagId AS TwZ_MagNumer, TwZ_Ilosc = 1
 FROM CDN.Towary
  CROSS JOIN CDN.Magazyny
   WHERE Mag_typ = 1 AND Mag_NieAktywny = 0
   AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId) AND Twr_Typ = 0
UNION ALL
-- Towary
SELECT Twr_TwrId AS  TwZ_TwrNumer, Mag_MagId AS TwZ_MagNumer, IsNull(B.TwI_Ilosc - B.TwI_Rezerwacje, 0.00) AS TwZ_Ilosc
 FROM CDN.Towary
  JOIN CDN.TwrIlosci B ON CDN.Towary.Twr_TwrId = B.TwI_TwrId
  JOIN CDN.Magazyny ON B.TwI_MagId = Mag_MagId
   WHERE B.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = CDN.Towary.Twr_TwrId AND H.TwI_MagId = Mag_MagId AND H.TwI_Data <= GETDATE() ORDER BY H.TwI_Data DESC)
   and Mag_typ = 1 and  Mag_NieAktywny = 0 AND IsNull(B.TwI_Ilosc - B.TwI_Rezerwacje, 0.00) > 0
   AND EXISTS(SELECT GrONumer FROM #TwrGrupyESklep WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId ) AND Twr_Typ = 1
END
