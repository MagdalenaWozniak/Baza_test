--* gSkrypt.sOpis = $Tworzenie procedury CRDrukujAtrybuty$
-- Generowanie listy atrybutów dla wydruków
CREATE PROCEDURE CDN.CRDrukujAtrybuty
@TraID INT
AS
BEGIN
SET NOCOUNT ON;
SELECT DISTINCT (TrA_LP), TrA_Kod, Tra_Wartosc, DeA_Format
 FROM CDN.TraElemAtr
    JOIN CDN.DefAtrybuty ON DeA_DeAID = TrA_DeAID
    left outer JOIN CDN.TwrAtrybuty ON TrA_DeAId = TwA_DeAId
   WHERE TrA_TrEID = @TraID
   and (TwA_CzyDrukowac = 1
   or        (TwA_CzyDrukowac is null  and DeA_CzyDrukowac = 1 ))
SET NOCOUNT OFF;
END
