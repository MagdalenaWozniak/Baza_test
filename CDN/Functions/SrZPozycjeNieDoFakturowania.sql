CREATE FUNCTION CDN.SrZPozycjeNieDoFakturowania ( @SrsZlecenieId Int )
  RETURNS    INT
  AS
BEGIN
 DECLARE @wynik INT,@czynnosci INT, @czesci INT
  SELECT @czynnosci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzynnosci on SrY_SrZId = SrZ_SrZId
  WHERE SrZ_SrZId = @SrsZlecenieId AND SrY_Zakonczona = 0
  SELECT @czesci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzesci on SrC_SrZId = SrZ_SrZId
  WHERE SrZ_SrZId = @SrsZlecenieId AND ((SrC_Status & 1) = 0 and (SrC_Status & 4) = 0)
  set @wynik = @czynnosci + @czesci
KONIEC:
 RETURN  @wynik
END
