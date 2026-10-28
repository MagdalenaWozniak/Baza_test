CREATE FUNCTION CDN.SrZSumuj ( @SrsZlecenieId INT, @mode INT )
-- @mode = 1 wartość netto
-- @mode = 2 wartość brutto
-- @mode = 3 wartość netto do zafakturowania
-- @mode = 4 wartość brutto do zafakturowania
-- @mode = 5 czas realizacji czynności
  RETURNS    DECIMAL(15,2)
  AS
BEGIN
  DECLARE @wynik DECIMAL(15,2), @suma DECIMAL(15,2)
  SET @suma = 0.00;
  SET @wynik = 0.00;
  IF @SrsZlecenieId = 0
  BEGIN
 GOTO KONIEC
  END
 IF @mode = 1  -- suma netto
 BEGIN
  SELECT @suma = Sum(SrC_WartoscNetto) FROM cdn.SrsCzesci WHERE SrC_SrZId = @SrsZlecenieId
  SET @wynik = IsNull(@suma, 0.00)
  SELECT @suma = Sum(SrY_WartoscNetto) FROM cdn.SrsCzynnosci WHERE SrY_SrZId = @SrsZlecenieId
  SET @wynik = @wynik + IsNull(@suma, 0.00)
  GOTO KONIEC
 END
 IF @mode = 2  -- suma brutto
 BEGIN
  SELECT @suma = Sum(SrC_WartoscBrutto) FROM cdn.SrsCzesci WHERE SrC_SrZId = @SrsZlecenieId
  SET @wynik = IsNull(@suma, 0.00)
  SELECT @suma = Sum(SrY_WartoscBrutto) FROM cdn.SrsCzynnosci WHERE SrY_SrZId = @SrsZlecenieId
  SET @wynik = @wynik + IsNull(@suma, 0.00)
  GOTO KONIEC
 END
 IF @mode = 3  -- suma netto do fakturowania
 BEGIN
  SELECT @suma = Sum(SrC_WartoscNetto) FROM cdn.SrsCzesci JOIN cdn.SrsZlecenia ON SrC_SrZId = SrZ_SrZId WHERE SrC_SrZId = @SrsZlecenieId AND (SrC_Fakturowac = 1 OR SrZ_ZbiorczeFaCzesci = 1)
  SET @wynik = IsNull(@suma, 0.00)
  SELECT @suma = Sum(SrY_WartoscNetto) FROM cdn.SrsCzynnosci JOIN cdn.SrsZlecenia ON SrY_SrZId = SrZ_SrZId WHERE SrY_SrZId = @SrsZlecenieId AND (SrY_Fakturowac = 1 OR SrZ_ZbiorczeFaCzynnosci = 1)
  SET @wynik = @wynik + IsNull(@suma, 0.00)
  GOTO KONIEC
 END
 IF @mode = 4  -- suma brutto  do fakturowania
 BEGIN
  SELECT @suma = Sum(SrC_WartoscBrutto) FROM cdn.SrsCzesci JOIN cdn.SrsZlecenia ON SrC_SrZId = SrZ_SrZId WHERE SrC_SrZId = @SrsZlecenieId AND (SrC_Fakturowac = 1 OR SrZ_ZbiorczeFaCzesci = 1)
  SET @wynik = IsNull(@suma, 0.00)
  SELECT @suma = Sum(SrY_WartoscBrutto) FROM cdn.SrsCzynnosci JOIN cdn.SrsZlecenia ON SrY_SrZId = SrZ_SrZId WHERE SrY_SrZId = @SrsZlecenieId AND (SrY_Fakturowac = 1 OR SrZ_ZbiorczeFaCzynnosci = 1)
  SET @wynik = @wynik + IsNull(@suma, 0.00)
  GOTO KONIEC
 END
 IF @mode = 5  -- suma czasów realizacji
 BEGIN
  DECLARE @Data0 DATETIME, @sumaMi INT
  SET @Data0 = CONVERT( DATETIME, '1899-12-30 00:00:00' , 120 )
  SELECT @sumaMi = Sum(DATEDIFF(mi,@Data0, CONVERT( DATETIME, SrY_CzasTrwania, 120 )))
  FROM cdn.SrsCzynnosci WHERE SrY_SrZId = @SrsZlecenieId
  SET @wynik = IsNull(@sumaMi, 0.00)
  GOTO KONIEC
 END
KONIEC:
  RETURN @wynik
END
