CREATE PROCEDURE CDN.PobierzSrsCzesci @zlecenieId INT, @konfigCena4 INT, @decimalSeparator VARCHAR
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
  IF (EXISTS(SELECT * FROM CDN.SrsCzesci WHERE SrC_SrZId = @zlecenieId AND SrC_CenaZCzteremaMiejscami=1))
   SET @cenaZCzteremaMiejscami = 1
 END
 SELECT CDN.SrsCzesci.*,
 N''  AS SrC_StatusFrm,
 CDN.StatusWydaniaCzesciNaZleceniu(SrC_SrCId) AS SrC_StatusWydania,
 CDN.StatusWydaniaCzesciNaZleceniuTxt(SrC_SrCId) AS SrC_StatusWydaniaTxt,
 (SELECT MaG_Symbol FROM cdn.Magazyny WHERE Mag_MagId=SrC_MagId) AS SrC_SymbolMagazynu,
    IsNull(CASE WHEN SrC_SerwisantTyp = 8 THEN
   (SELECT KO_Kod FROM #KodyOperatorow WHERE SrC_SerwisantId = KO_Id)
    ELSE
   (SELECT TOP 1 PRI_Kod FROM cdn.PracIdx WHERE SrC_SerwisantId = PRI_PraID)
    END,'-nie znaleziono-') AS SrC_SerwisantKod,
 CDN.SrsCzesciKontrahentNaFa(SrC_SrCId) AS SrC_KodKntNaFa
 FROM CDN.SrsCzesci
 JOIN CDN.SrsZlecenia ON SrC_SrZId = SrZ_SrZId
 WHERE SrC_SrZId = @zlecenieId
 ORDER BY SrC_Lp
END
