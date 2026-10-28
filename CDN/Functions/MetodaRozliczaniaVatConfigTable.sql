CREATE FUNCTION CDN.MetodaRozliczaniaVatConfigTable(@DataOd DateTime, @DataDo DateTime)
RETURNS @Result TABLE( Data DateTime,
      Metoda int )
-- 1 metoda zwykła
-- 2 metoda kasowa
AS
BEGIN
 declare @current DateTime; set @current = @DataOd
 declare @metoda int
 while @current <= @DataDo
 begin
  SELECT @metoda = CAST(CFW_Wartosc AS INT)
  FROM CDN.CfgWartosci left outer join CDN.CfgKlucze ON (CFW_CfkId = CFK_CfkId)
  WHERE CFK_Nazwa = 'Metoda rozliczania VAT' and CFK_OkresOd <= @current and CFK_OkresDo > @current
  insert into @Result(Data, Metoda) Values(@current, @metoda)
  set @current = DateAdd(day, 1, @current)
 end
 return
END
