CREATE PROCEDURE [CDN].[GenMM2]
@IDTRANSKACJI INT,
@Dzientxt NVARCHAR(50)
AS
BEGIN
SET NOCOUNT ON;
 IF OBJECT_ID('tempdb..#WALNOT') IS NOT NULL
 DROP TABLE #WALNOT
 CREATE TABLE #WALNOT
 (
  Notowanie REAL,
  Symbol NVARCHAR (3),
  WNo_NrTabeli NVARCHAR(50)
 )
 INSERT INTO #WALNOT EXEC CDN.TabelkaWalut @Dzientxt
 SELECT Tre_LP, Tre_TrNID, TrE_TwrKod, TrE_TwrNazwa, TrE_TwRSWW, TrE_IloscJM, TrE_JM,Twr_CenaZCzteremaMiejscami, TwC_TwCNumer, TwC_Typ, TwC_Waluta, TwC_Wartosc,
   TrE_Stawka, TrE_Flaga, round(TrE_IloscJM * TwC_Wartosc,2 ) AS Wartosc, Twr_TWCNumer, Notowanie,
   round(Notowanie *  TrE_IloscJM * TwC_Wartosc,2) AS WartoscPLN, Tre_TwrOpis
  FROM CDN.Traelem
   JOIN CDN.TwrCeny on TrE_TwrID = TwC_TwrID
    JOIN CDN.Towary on TrE_TwrID = Twr_TwrID
     LEFT OUTER JOIN #WALNOT on TwC_Waluta = Symbol
  WHERE Tre_TrnID = @IDTRANSKACJI
SET NOCOUNT OFF;
END
