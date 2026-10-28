CREATE FUNCTION [CDN].PrzeliczCene(@cena DECIMAL(17,4), @stawkaVat DECIMAl(5,2), @typCeny INT, @typDocelowy INT ,@ZaokraglajDo  SMALLINT)
RETURNS DECIMAl(17,4)
BEGIN
 DECLARE @cenaDlaTypu DECIMAl(17,4)
 SET @cenaDlaTypu = @cena
 IF @typCeny = @typDocelowy
 BEGIN
  GOTO KONIEC
 END
 IF @typCeny = 1 AND @typDocelowy = 2 -- przelicz z netto na brutto
 BEGIN
  SET @cenaDlaTypu = CDN.CenaBruttoPrecyzja(@cena, @typCeny, @stawkaVat, 1, 1, 1, 1,@ZaokraglajDo)
  GOTO KONIEC
 END
 IF @typCeny = 2 AND @typDocelowy = 1 -- przelicz z brutto na netto
 BEGIN
  SET @cenaDlaTypu = round(@cena - (@cena * @stawkaVat /(100 + @stawkaVat)),@ZaokraglajDo)
  GOTO KONIEC
 END
KONIEC:
 RETURN @cenaDlaTypu
END
