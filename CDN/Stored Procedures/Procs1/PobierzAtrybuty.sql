CREATE PROCEDURE CDN.PobierzAtrybuty
@PodTyp Int,
 @PodId Int,
 @TwrId Int,
 @TylkoZalezne Int = 0,
 @UstawAtrSQL Int = -1,
 @UstawAtrSQLDokTyp Int = 1
  AS
SET NOCOUNT ON
   CREATE TABLE #PobierzAtr (TwA_LP INT,TwA_DeAID INT,DeA_Kod NVARCHAR(20), TwA_WartoscTxT NVARCHAR(100), TKA_TKAId int, Zalezny int)
   if @UstawAtrSQL > 0
   begin
    if @UstawAtrSQLDokTyp = 1
  INSERT INTO #PobierzAtr(TwA_LP,TwA_DeAID, DeA_Kod, TwA_WartoscTxt,TKA_TKAId, Zalezny)
  select TrA_Lp,TrA_DeAId,TrA_Kod,TrA_Wartosc,1, 0 from CDN.TraElemAtr where TrA_TrEId = @UstawAtrSQL
    ELSE
  INSERT INTO #PobierzAtr(TwA_LP,TwA_DeAID, DeA_Kod, TwA_WartoscTxt,TKA_TKAId, Zalezny)
  select TrA_Lp,TrA_DeAId,TrA_Kod,TrA_Wartosc,1, 0 from CDN.TraElemAtr where TrA_DokId = @UstawAtrSQL and TrA_DokTyp = @UstawAtrSQLDokTyp
   end
   else
   begin
    if @TylkoZalezne = 0 or @UstawAtrSQL = 0
    INSERT INTO #PobierzAtr(TwA_LP,TwA_DeAID, DeA_Kod, TwA_WartoscTxt,TKA_TKAId, Zalezny)
       SELECT TwA_LP,TwA_DeAID,DeA_Kod, TwA_Wartosctxt,0,TwA_Zalezny FROM CDN.TwrAtrybuty
       JOIN CDN.DefAtrybuty ON TwA_DeAID = DeA_DeAID
        WHERE TwA_CzyPrzenosic = 1 AND TwA_TwrID = @TwrId
        AND TwA_Zalezny = 0
    UNION
       SELECT TwA_LP,TwA_DeAID,DeA_Kod, TKA_Wartosctxt,TKA_TKAId,TwA_Zalezny FROM CDN.TwrAtrybuty
      JOIN cdn.DefAtrybuty ON TwA_DeAID = DeA_DeAID
      JOIN cdn.TwrKntAtrybuty ON TKA_TwAID = TwA_TwAID
       WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 1
       AND TwA_TwrID = @TwrId AND TKA_PodmiotTyp = @PodTyp
       AND TKA_PodmiotID = @PodId
    ORDER BY TwA_LP
    if @TylkoZalezne = 1
    INSERT INTO #PobierzAtr(TwA_LP,TwA_DeAID, DeA_Kod, TwA_WartoscTxt,TKA_TKAId, Zalezny)
  SELECT TwA_LP,TwA_DeAID,DeA_Kod, ISNULL(TKA_Wartosctxt,TwA_Wartosctxt),isnull(TKA_TKAId,0),TwA_Zalezny  FROM CDN.TwrAtrybuty
      JOIN cdn.DefAtrybuty ON TwA_DeAID = DeA_DeAID
      left JOIN cdn.TwrKntAtrybuty ON TKA_TwAID = TwA_TwAID AND TKA_PodmiotTyp = @PodTyp
       AND TKA_PodmiotID = @PodId
       WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 1
       AND TwA_TwrID = @TwrId
  ORDER BY TwA_LP
  end
 SET NOCOUNT Off
 SELECT * from #PobierzAtr
