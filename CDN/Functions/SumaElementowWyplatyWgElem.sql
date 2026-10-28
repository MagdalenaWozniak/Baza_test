CREATE FUNCTION CDN.SumaElementowWyplatyWgElem( @WpeID INT, @Potracenie TINYINT )
RETURNS DECIMAL(15,2)
AS
BEGIN
 DECLARE @Wartosc DECIMAL(15,2)
 if @Potracenie is not NULL
 begin
  -- jeżeli księgujemy wypłatę stornującą - to ze znakiem minus ma się księgować.
  -- w p.p. jeżeli księgujemy potrącenia - to bierzemy wartość bezwzględną.
  SELECT @Wartosc = CASE WHEN WPL_Tryb = 2 THEN CASE WHEN @Potracenie > 0 THEN -WpE_Wartosc ELSE WpE_Wartosc END ELSE CASE WHEN @Potracenie > 0 THEN ABS(WpE_Wartosc) ELSE WpE_Wartosc END END
  FROM CDN.WypElementy INNER JOIN CDN.TypWyplata ON WPE_TWpID = TWp_TWpID
  INNER JOIN CDN.Wyplaty ON WpE_WplID = Wpl_WplID
  WHERE
  TWp_AlgPotracenie = @Potracenie AND WPE_WpeID = @WpeID
  and TWP_Standardowy not in (15,16,17,18,19,20,21,22,23)
 end
 else
 begin
  select @Wartosc = WpE_Wartosc
  from CDN.WypElementy
  left outer join cdn.TypWyplata on (TWP_TwpId=WPE_TwpId)
  where
  WPE_WpeID = @WpeID and IsNull(TWP_WchodziDoWyplaty, 0) = 1
  and TWP_Standardowy not in (15,16,17,18,19,20,21,22,23)
 end
  RETURN ISNULL(@Wartosc, 0)
END
