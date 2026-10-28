CREATE FUNCTION CDN.MetodaRozliczaniaVatConfigTable_For_VatNag()
RETURNS @Result TABLE( Data DateTime,
      Metoda int )
-- 1 metoda zwykła
-- 2 metoda kasowa
AS
BEGIN
 declare @ddw Table (DataWystawienia Date)
 insert into @ddw select distinct VaN_DataWys from CDN.VatNag
 insert into @Result(Data, Metoda)
 SELECT DataWystawienia, CAST(CFW_Wartosc AS INT)
   FROM
   CDN.CfgWartosci
   left outer join CDN.CfgKlucze ON (CFW_CfkId = CFK_CfkId)
   left outer join @ddw on (CFK_OkresOd <= DataWystawienia and CFK_OkresDo > DataWystawienia)
   WHERE CFK_Nazwa = 'Metoda rozliczania VAT'
 return
END
