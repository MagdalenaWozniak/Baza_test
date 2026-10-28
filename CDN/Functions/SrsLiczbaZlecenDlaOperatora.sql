CREATE FUNCTION CDN.SrsLiczbaZlecenDlaOperatora (
 @InfKod NVARCHAR(20), @OpeId Int, @Data DateTime )
  RETURNS     NVARCHAR(20)
  AS
  BEGIN
  DECLARE @wynik NVARCHAR(20)
  SET @wynik = ''
 IF @InfKod = 'ZLE. OPE. DZISIEJSZE'
  SELECT @wynik = Str(IsNull(Count(SrY_SrYId), 0), 20) FROM cdn.SrsCzynnosci JOIN cdn.SrsZlecenia on SrY_SrZId = SrZ_SrZId
  WHERE -- czynności do wykonania dla danego operatora, które nie mają statusu Zrealizowane
   SrZ_Bufor = 1 AND SrY_Zakonczona = 0 And SrY_SerwisantTyp = 8 And SrY_SerwisantID = @OpeId
   AND (
    SrY_Realizacja = 0 -- wszystkie z wybrana opcją Niezależna
     -- wszystkie, które mają zaznaczony parametr Po wykonaniu poprzedniej, a poprzednia czynność została wykonana
    OR (SrY_Realizacja = 1 AND SrY_PoprzedniaOk = 1)
     -- te, dla których data today zawiera się w terminie realizacji
    OR (SrY_Realizacja = 2 AND SrY_TerminOd < @Data + 1 AND SrY_TerminDo >= @Data)
   )
 ELSE
   IF  @InfKod = 'ZLE. OPE. ZALEGLE'
   SELECT @wynik = Str(IsNull(Count(SrY_SrYId), 0), 20) FROM cdn.SrsCzynnosci JOIN cdn.SrsZlecenia on SrY_SrZId = SrZ_SrZId
   WHERE -- czynności do wykonania dla danego operatora, które nie mają statusu Zrealizowane
    SrZ_Bufor = 1 AND SrY_Zakonczona = 0 And SrY_SerwisantTyp = 8 And SrY_SerwisantID = @OpeId
   AND SrY_Realizacja = 2 AND SrY_TerminDo < @Data
KONIEC:
    RETURN  @wynik
  END
