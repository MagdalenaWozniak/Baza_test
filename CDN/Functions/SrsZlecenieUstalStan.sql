CREATE FUNCTION CDN.SrsZlecenieUstalStan ( @SrsZlecenieId INT )
-- 0  pusta - jeśli nie ma żadnego dokumentu wydającego części/ usługi (RW,WZ,FA,PA)
-- 1  w realizacji – jeśli usługi/ części zostały wydane, ale na zleceniu istnieją jeszcze:
     -- części, które nie mają wartości w kolumnie status wydania
     --W przypadku czynności powinno działać tak:
     -- jeśli jest jakakolwiek czynność do wykonania (obojętne, czy z reki czy z cennika, ważne, że nie jest zaznaczone zakończenie) - wtedy status jest w realizacji
     -- jeśli wszystkie czynności są zakończone, ale: mają status do zafakturowania i nie zostały zafakturowane - wtedy status jest w realizacji
     -- jeśli wszystkie czynności są zakończone i wszystkie do zafakturowania mają status FA/PA - wtedy zlecenie jest zrealizowane.
-- 2  zrealizowano -  jeśli wszystkie usługi, części zostały wydane/ zafakturowane
-- zmiana 2009-02-02
  RETURNS    INT
  AS
BEGIN
 DECLARE @wynik INT, @autoItem INT
 SET @autoItem = 255
 SET @wynik = 0
 IF @SrsZlecenieId = 0  GOTO KONIEC
 --IF EXISTS( SELECT SrC_SrCId FROM CDN.SrsCzesci WHERE SrC_IloscJM < SrC_IloscPobieranaJM AND SrC_SrZId = @SrsZlecenieId)
 --BEGIN
  -- TFS 160582 [AR] jeśli są niezwrócone ilości to nawet po utworzeniu FA lub RW status nie powinien sie zmienic na zrealizowany, tylko pozostać w realizacji.
  --SET @wynik = 1   --e_SRS_SrZ_StanWrealizacji
  --GOTO KONIEC
 --END
 DECLARE @wydano INT, @doZafak INT, @klasa INT
 SET @klasa = 900
 SELECT @wydano = count(*) FROM cdn.DokRelacje
     WHERE DoR_ParentTyp = @klasa AND DoR_ParentId = @SrsZlecenieId
       AND DoR_DokumentTyp IN (302, 304, 305, 306) AND DoR_Flaga = @autoItem
 IF @wydano > 0
 BEGIN
  SELECT @doZafak = CDN.SrZPozycjeDoZafakturowania(@SrsZlecenieId, 0, 0)
  IF @doZafak = 0
  BEGIN
   SELECT @wydano = CDN.SrZPozycjeNieDoFakturowania(@SrsZlecenieId)
   IF @wydano = 0
    SET @wynik = 2
   ELSE
    SET @wynik = 1
  END
  ELSE
  BEGIN
   SET @wynik = 1
  END
 END
 ELSE
 BEGIN
  -- zmiana 2009-02-02
  SET @wynik = 0
  DECLARE @czesci  INT, @czynnosci INT
  SELECT @czesci    = Count(*) FROM cdn.SrsCzesci    WHERE SrC_SrZId = @SrsZlecenieId AND SrC_IloscJM > 0
  SELECT @czynnosci = Count(*) FROM cdn.SrsCzynnosci WHERE SrY_SrZId = @SrsZlecenieId
  IF @czesci > 0
  BEGIN
   SET @wynik = 1
   GOTO KONIEC
  END
  IF @czynnosci > 0
  BEGIN
   SET @wynik = 1
   SELECT @czynnosci = count(*)
   FROM cdn.SrsZlecenia
   JOIN cdn.SrsCzynnosci on SrY_SrZId = SrZ_SrZId
   WHERE SrZ_SrZId = @SrsZlecenieId AND SrY_Zakonczona = 1 AND (SrZ_ZbiorczeFaCzynnosci = 1 OR SrY_Fakturowac = 1)
   AND  cdn.SrsRozchodDlaPozycji(901, SrY_SrYId, 0) = 0
   -- nie ma nic do zafakturowania
   IF @czynnosci = 0
   BEGIN
    SELECT @czynnosci = count(*)
    FROM cdn.SrsZlecenia
    JOIN cdn.SrsCzynnosci on SrY_SrZId = SrZ_SrZId
    WHERE SrZ_SrZId = @SrsZlecenieId and SrY_Zakonczona = 0
    IF @czynnosci = 0
    BEGIN
     SET @wynik = 2
    END
   END
  END
 END
KONIEC:
  RETURN  @wynik
END
