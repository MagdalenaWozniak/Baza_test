CREATE FUNCTION CDN.SrZPozycjeDoZafakturowania ( @SrsZlecenieId INT, @TypDok INT, @ForTyp INT )
RETURNS    INT
AS
BEGIN
 DECLARE @wynik int
 DECLARE @czesci int, @czynnosci int
 SET @czesci = 0
 SET @czynnosci = 0
 SET @wynik = 0
 IF @SrsZlecenieId = 0
  GOTO KONIEC
 IF @TypDok Is Null OR @TypDok = 0
 BEGIN
  SELECT @czynnosci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzynnosci on SrY_SrZId = SrZ_SrZId
  WHERE SrZ_SrZId = @SrsZlecenieId AND SrY_Zakonczona = 1 AND (SrY_Fakturowac = 1 OR SrZ_ZbiorczeFaCzynnosci = 1)
  and  cdn.SrsRozchodDlaPozycji(901, SrY_SrYId, @ForTyp) = 0
  SELECT @czesci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzesci on SrC_SrZId = SrZ_SrZId
  WHERE SrZ_SrZId = @SrsZlecenieId
  AND SrC_IloscJM > 0
  AND ((SrC_Status & 1) > 0  or (SrC_Status & 4) > 0)
  AND  cdn.SrsRozchodDlaPozycji(902, SrC_SrCId, @ForTyp) = 0
  GOTO KONIEC
 END
 IF @TypDok = 302 OR @TypDok = 305
 BEGIN
  SELECT @czynnosci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzynnosci on SrY_SrZId = SrZ_SrZId
  WHERE SrZ_SrZId = @SrsZlecenieId AND SrY_Zakonczona = 1 AND (SrY_Fakturowac = 1 OR SrZ_ZbiorczeFaCzynnosci = 1)
  and  cdn.SrsRozchodDlaPozycji(901, SrY_SrYId, @ForTyp) = 0
  SELECT @czesci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzesci on SrC_SrZId = SrZ_SrZId
  WHERE SrZ_SrZId = @SrsZlecenieId
  AND (SrC_Fakturowac = 1  OR SrZ_ZbiorczeFaCzesci = 1)
  AND SrC_IloscJM > 0
  AND ((SrC_Status & 1) > 0  OR (SrC_Status & 4) > 0)
  AND  cdn.SrsRozchodDlaPozycji(902, SrC_SrCId, @ForTyp) = 0
  GOTO KONIEC
 END
 IF @TypDok = 304
 BEGIN
  SELECT @czesci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzesci on SrC_SrZId = SrZ_SrZId
  WHERE SrZ_SrZId = @SrsZlecenieId
  AND SrC_Fakturowac=0 AND SrC_IloscJM > 0
  AND ((SrC_Status & 1) > 0  or (SrC_Status & 4) > 0)
  AND  cdn.SrsRozchodDlaPozycji(902, SrC_SrCId, @ForTyp) = 0
  GOTO KONIEC
 END
 IF @TypDok = 306
 BEGIN
  SELECT @czesci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzesci on SrC_SrZId = SrZ_SrZId
  WHERE SrZ_SrZId = @SrsZlecenieId
  AND SrZ_ZbiorczeFaCzesci=0 AND SrC_Fakturowac = 1 AND SrC_IloscJM > 0
  AND ((SrC_Status & 1) > 0  or (SrC_Status & 4) > 0)
  AND  cdn.SrsRozchodDlaPozycji(902, SrC_SrCId, @ForTyp) = 0
  GOTO KONIEC
 END
 IF @TypDok = 312  --MM
 BEGIN
  SELECT @czesci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzesci ON SrC_SrZId = SrZ_SrZId AND SrC_MagId <> SrZ_MagId
  WHERE SrZ_SrZId = @SrsZlecenieId
  AND ((SrC_Status & 1) = 0  AND (SrC_Status & 4) = 0)
  AND SrC_IloscPobieranaJM > 0
  AND cdn.SrsRozchodDlaPozycji(902, SrC_SrCId, @ForTyp) = 0
  GOTO KONIEC
 END
 IF @TypDok = 312001  --MM-
 BEGIN
  SELECT @czesci = count(*)
  FROM cdn.SrsZlecenia
  JOIN cdn.SrsCzesci ON SrC_SrZId = SrZ_SrZId AND SrC_MagId <> SrZ_MagId
  WHERE SrZ_SrZId = @SrsZlecenieId
  AND SrC_MMZwrot = 0 -- nie było zwrotu
  AND (SrC_Status & 1) = 1 -- było pobranie
  AND SrC_IloscPobieranaJM > SrC_IloscJM  -- ilość pobrana jest większa od ilości wykorzystanej
  GOTO KONIEC
 END
KONIEC:
 set @wynik = @czynnosci + @czesci
 RETURN  @wynik
END
