CREATE PROCEDURE CDN.PobierzSrsCzynnosci @zlecenieId INT, @konfigCena4 INT,  @decimalSeparator VARCHAR
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @kreski VARCHAR(15)
 SET @kreski = REPLICATE('-', 15)
 CREATE TABLE #KodyOperatorow(KO_Id INT PRIMARY KEY, KO_Kod NVARCHAR(20))
 DECLARE @sqltxt NVARCHAR(512)
 SET @sqltxt = 'INSERT INTO  #KodyOperatorow(KO_Id, KO_Kod)  SELECT OpE_OpEId,  OpE_Kod FROM ' + CDN.BazaKonfiguracyjna() + N'.cdn.Operatorzy'
 EXEC sp_executeSql @sqltxt
 SET NOCOUNT OFF
 DECLARE @cenaZCzteremaMiejscami INT
 SET @cenaZCzteremaMiejscami = 0
 IF @konfigCena4 = 1
 BEGIN
  IF (EXISTS(SELECT * FROM CDN.SrsCzynnosci WHERE SrY_SrZId = @zlecenieId AND SrY_CenaZCzteremaMiejscami=1))
   SET @cenaZCzteremaMiejscami = 1
 END
 SELECT CDN.SrsCzynnosci.*,
 CASE WHEN IsNull(SrY_TwrId, 0) = 0 THEN '' ELSE CDN.TeRStatusString(901, SrY_SrYId, 0) END  AS SrY_StatusWydania,
    IsNull(CASE WHEN SrY_SerwisantTyp = 8 THEN
   (SELECT KO_Kod FROM #KodyOperatorow WHERE SrY_SerwisantId = KO_Id)
    ELSE
   (SELECT TOP 1 PRI_Kod FROM cdn.PracIdx WHERE SrY_SerwisantId = PRI_PraID)
    END,'-nie znaleziono-') AS SrY_SerwisantKod,
 cdn.SrsCzynnosciKontrahentNaFa(SrY_SrYId)  AS SrY_KodKntNaFa
 FROM CDN.SrsCzynnosci
 JOIN CDN.SrsZlecenia ON SrY_SrZId = SrZ_SrZId
 WHERE SrY_SrZId = @zlecenieId
 ORDER BY SrY_Lp
END
