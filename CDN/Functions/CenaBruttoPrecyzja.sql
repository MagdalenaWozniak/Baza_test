CREATE  FUNCTION CDN.CenaBruttoPrecyzja (@Cena DECIMAL(18,4), @Typ SMALLINT, @Stawka DECIMAL(5,2), @KursLWalutaCeny DECIMAL(15,4),
                                 @KursMWalutaCeny DECIMAL(5,0), @KursLWalutaKoncowa DECIMAL(15,4), @KursMWalutaKoncowa DECIMAL(5,0),@ZaokraglajDo SMALLINT = 2)
RETURNS DECIMAL(18,4)
AS
BEGIN
  DECLARE @CzyNetto SMALLINT, @Wartosc DECIMAL(18,4)
  if @Typ < 3
  BEGIN
  SELECT @CzyNetto= CASE WHEN @Typ = 1 THEN 1 ELSE 0 END
  SET @Wartosc =  ROUND((@Cena*(1+ + @CzyNetto*@Stawka/100.00))*( @KursLWalutaCeny / @KursMWalutaCeny ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),@ZaokraglajDo)
  END
  ELSE
  BEGIN
    SELECT @CzyNetto= CASE WHEN @Typ = 4 THEN 1 ELSE 0 END
 SET @Wartosc =  ROUND((@Cena-@CzyNetto*@Cena*@Stawka/(100.0+@Stawka))*( @KursLWalutaCeny / @KursMWalutaCeny ) / ( @KursLWalutaKoncowa / @KursMWalutaKoncowa ),@ZaokraglajDo)
  END
  RETURN @Wartosc
END
