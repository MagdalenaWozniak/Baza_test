CREATE FUNCTION CDN.MetodyRozliczaniaVAT()
RETURNS
  @Wyniki TABLE(_Metoda INT, _Okres INT PRIMARY KEY )
AS
BEGIN
INSERT INTO @Wyniki
SELECT CAST(CFW_Wartosc AS INT) AS _Metoda, YEAR (CFK_OkresOd)*100 + MONTH(CFK_OkresOd) AS _Okres
FROM CDN.CfgWartosci left outer join CDN.CfgKlucze ON (CFW_CfkId = CFK_CfkId)
WHERE CFK_Nazwa = 'Metoda rozliczania VAT'
ORDER BY YEAR (CFK_OkresOd)*100 + MONTH (CFK_OkresOd)
RETURN
END
