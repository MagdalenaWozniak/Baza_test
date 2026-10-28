CREATE FUNCTION CDN.FzPz (@TrNId INT)
RETURNS INT
AS
BEGIN
  DECLARE @Wynik          INT
  DECLARE @LiczbaSkojPz   INT
  DECLARE @Rodzaj       INT
  SET @Wynik = 0
  SELECT @Rodzaj = TrN_Rodzaj FROM cdn.TraNag WHERE TrN_TrNId = @TrNId
  IF @Rodzaj = 301004
   SET @Wynik = 1
  ELSE
 BEGIN
                SELECT @LiczbaSkojPz = Count(*) FROM cdn.TraNagRelacje WHERE TrR_FaId = @TrNId AND TrR_TrNTyp = 307
--  SELECT @LiczbaSkojPz = Count(*) FROM cdn.TraNag WHERE TrN_FaId = @TrNId AND TrN_TypDokumentu = 307
  IF @LiczbaSkojPz > 0
     SET @Wynik = 1
 END
  RETURN @Wynik
END
