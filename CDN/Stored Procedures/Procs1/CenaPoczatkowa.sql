CREATE PROCEDURE CDN.CenaPoczatkowa
 @GIDTyp    int,    -- identyfikator pozycji/dokumentu (GID)
 @GIDNumer  int,    --
 @GIDLp     int,     --
 @Data   int,        -- bieżąca data i czas jako timestamp
 @KntTyp  smallint,  -- dane kontrahenta
 @KntNumer  int,    --
 @FrsId   NVARCHAR(255),   -- oddzielone przecinkami miejsca w strukturze firmy
 @TwrTyp  smallint,  -- dane towaru
 @TwrNumer  int,   --
 @CennikNumer int = -1,  -- numer cennika (gdy podany cena od razu pobierana z TwrCeny)
 @DokCennikNumer int = -1,  -- numer cennika wybrany na nagłówku dokumentu
 @FormaNr  int = -1,  -- numer formy płatności
 @RodzajDok  smallint = -1,   -- rodzaj dokumentu (przychód/rozchód)
 @ZstNumer  int = -1   -- numer zestawu (kompletu)
AS
-- Procedura pobiera numer cenę początkową oraz jej numer dla wskazanej pozycji dokumentu.
-- Najpierw poszukiwana jest cena na promocjach typu cennik, potem na nagłówku dokumentu, i ew.
-- na karcie towaru.
-- W przypadku nie podania identyfikatora towaru, zostaje on pobrany ze wskazanej pozycji dokumentu.
SET NOCOUNT ON
DECLARE @CENA_WARTOSC  decimal(17,4) -- wartość
DECLARE @CENA_WALUTA  NVARCHAR(3) -- waluta
DECLARE @CENA_KURSL  decimal(7,2)  -- kurs (opcjonalnie)
DECLARE @CENA_KURSM  decimal(5)  --
DECLARE @CENA_NUMER  smallint -- numer cennika
DECLARE @CENA_PRM  int  -- numer promocji, jeśli cena pochodzi z promocji typu cennik
DECLARE @CENA_PRECYZJA  decimal(7,4) -- dokładność ceny początkowej 2 lub 4)
DECLARE @CENA_FLAGANB  NVARCHAR(1)  -- czy cena brutto/netto (B lub N)
DECLARE @POMIN_POZ smallint -- czy pominąć pozostałe promocje
DECLARE @SKADCENA smallint -- skąd pobrano cenę (promocja =1,nagłówek=2,towar=3)
DECLARE @DOKLADNOSC smallint -- dokładność z CDN.Nazwy
SET @CENA_WARTOSC = NULL
SET @CENA_WALUTA = NULL
SET @CENA_KURSL = NULL
SET @CENA_KURSM = NULL
SET @CENA_NUMER = NULL
SET @CENA_PRM = NULL
SET @CENA_PRECYZJA = NULL
SET @CENA_FLAGANB = NULL
SET @POMIN_POZ = NULL
SET @SKADCENA = NULL
SET @DOKLADNOSC = NULL
--Pobierz indentyfikator towaru jeżeli pominięto
IF @CennikNumer >= 0
BEGIN
 SET @SKADCENA = 3
 SELECT @CENA_NUMER = TwC_TwrLp,@CENA_WARTOSC = TwC_Wartosc,@CENA_WALUTA = TwC_Waluta,@CENA_PRECYZJA = TwC_Zaokraglenie FROM CDN.TwrCeny WITH (NOLOCK) WHERE TwC_TwrTyp = @TwrTyp AND TwC_TwrNumer = @TwrNumer AND TwC_TwrLp = @CennikNumer
 --Pobierz Netto/Brutto
 SELECT @CENA_FLAGANB = SUBSTRING(Naz_Nazwa,LEN(Naz_Nazwa)-1,1),@DOKLADNOSC = SUBSTRING(Naz_Nazwa,LEN(Naz_Nazwa),1) FROM CDN.Nazwy WITH (NOLOCK) WHERE Naz_GIDLp = @CENA_NUMER AND Naz_GIDTyp = 64
 --Zwróć wyniki
 SELECT  ISNULL(@CENA_NUMER,0) AS CENA_LP,ISNULL(@CENA_WARTOSC,0) AS CENA_WARTOSC,
  ISNULL(@CENA_PRM,0) AS CENA_PRMID,ISNULL(@CENA_WALUTA,'') AS CENA_WALUTA,
  ISNULL(@CENA_KURSL,0) AS CENA_KursL,ISNULL(@CENA_KURSM,0) AS CENA_KursM,
  ISNULL(@CENA_PRECYZJA,0) AS CENA_Precyzja,ISNULL(@DOKLADNOSC,0) AS CENA_Dokladnosc,
  ISNULL(@CENA_FLAGANB,0) AS CENA_FlagaNB, ISNULL(@POMIN_POZ,0) AS CENA_PominPozostale,
  @SKADCENA AS CENA_ZRODLO WHERE @CENA_NUMER IS NOT NULL
-- SELECT ISNULL(@CENA_NUMER,0) AS NumerCennika,ISNULL(@CENA_WARTOSC,0) AS Cena,ISNULL(@CENA_PRM,0) AS IDPromocji,ISNULL(@CENA_WALUTA,'') AS Waluta,ISNULL(@CENA_KURSL,0) AS KursL,ISNULL(@CENA_KURSM,0) AS KursM,ISNULL(@CENA_PRECYZJA,0) AS Precyzja,ISNULL(@DOKLADNOSC,0) AS Dokladnosc,ISNULL(@CENA_FLAGANB,0) AS FlagaNB, ISNULL(@POMIN_POZ,0) AS PominPozostale,@SKADCENA AS ZrodloCeny WHERE @CENA_NUMER IS NOT NULL
 RETURN
END
--Pobierz cene z aktywnej promocji
SELECT TOP 1 @CENA_NUMER = TPR_RodzajCeny,@CENA_PRM = TPR_PrmId,@POMIN_POZ = PRM_PominPozostale FROM CDN.TwrPromocje WITH (NOLOCK)
 JOIN CDN.PrmKarty ON TPR_PrmID = PRM_Id
 JOIN CDN.KntPromocje ON KPR_PrmID = PRM_Id
 JOIN CDN.FrsPromocje ON FPR_PrmID = PRM_ID
 WHERE TPR_Typ = 4 AND PRM_Stan = 1 AND PRM_Typ = 7
  AND CDN.CzyPromocjaObowiazuje(PRM_DataOd, PRM_DataDo, PRM_Cykliczna, @Data) = 1
  AND
   (CASE --Sprawdz towary
   WHEN TPR_TwrTyp > 0 THEN
    (SELECT CASE WHEN TPR_TwrNumer = @TwrNumer AND TPR_TwrTyp = @TwrTyp THEN 1 ELSE 0 END)
   ELSE --Sprawdz w grupie towarów
    (SELECT CASE WHEN EXISTS(
     SELECT TwL_GIDNumer FROM CDN.TwrLinki WITH (NOLOCK)
     WHERE TwL_GroNumer = TPR_TwrNumer AND TwL_GroTyp = TPR_TwrTyp
     AND TwL_GIDNumer = @TwrNumer AND TwL_GIDTyp = @TwrTyp
    ) THEN 1 ELSE 0 END)
   END) = 1
  AND
   (CASE --Sprawdz kontrahenta
   WHEN KPR_KntTyp > 0 THEN
    (SELECT CASE WHEN KPR_KntNumer = @KntNumer AND KPR_KntTyp = @KntTyp THEN 1 ELSE 0 END)
   ELSE --Sprawdz w grupie kontrahentów
    (SELECT CASE WHEN EXISTS(
     SELECT KnL_GIDNumer FROM CDN.KntLinki WITH (NOLOCK)
     WHERE KnL_GIDNumer = @KntNumer AND KnL_GIDTyp = @KntTyp
     AND KPR_KntNumer = KnL_GroNumer AND KPR_KntTyp = KnL_GroTyp
    ) THEN 1 ELSE 0 END)
   END) = 1
  AND
   (CASE --Sprawdz w strukturze firmy
   WHEN EXISTS(
    SELECT FPR_PrmID FROM Cdn.FrsPromocje WITH (NOLOCK)
    WHERE FPR_PrmId = Prm_Id
                                 AND CharIndex(','+LTRIM(CAST(Fpr_FrsId AS NVARCHAR(5)))+',', ','+LTRIM(@FrsId)+',',1)>0
   ) THEN 1 ELSE 0 END) = 1
 ORDER BY PRM_Priorytet DESC,PRM_PriorytetLP ASC
IF @CENA_PRM IS NOT NULL
BEGIN
 SET @SKADCENA = 1
 --Pobierz cene z TwrCeny o numerze cennika z promocji
 SELECT @CENA_WARTOSC = TwC_Wartosc,@CENA_WALUTA = TwC_Waluta,@CENA_PRECYZJA = TwC_Zaokraglenie FROM CDN.TwrCeny WITH (NOLOCK)
  WHERE TwC_TwrTyp = @TwrTyp AND TwC_TwrNumer = @TwrNumer AND TwC_TwrLp = @CENA_NUMER
END
ELSE
BEGIN
 --Sprawdz czy naglowek dokumentu wskazuje na numer cennika
        IF @DokCennikNumer>=0 or (@DokCennikNumer< -10 and @DokCennikNumer<>-32000)
                SET @CENA_NUMER = @DokCennikNumer
        ELSE
        BEGIN
                SELECT @CENA_NUMER = Knt_Ceny FROM CDN.Kontrahenci WHERE Knt_GIDNumer = @KntNumer
                IF @CENA_NUMER <> 0
                   SET @CENA_Numer = @CENA_NUMER - 1
        END
 --Jeżeli nie na nagłówku to pobierz domyślną z TwrCeny
 SET @SKADCENA = 3
 IF @CENA_NUMER = 0
  SELECT @CENA_NUMER = Twr_CenaSpr FROM CDN.TwrKarty WITH (NOLOCK) WHERE Twr_GIDNumer = @TwrNumer AND Twr_GIDTyp = @TwrTyp
 ELSE
  SELECT @SKADCENA = 2
 --Pobierz wartosci dla ustalonego numeru cennika
 SELECT @CENA_WARTOSC = TwC_Wartosc,@CENA_WALUTA = TwC_Waluta,@CENA_PRECYZJA = TwC_Zaokraglenie FROM CDN.TwrCeny WITH (NOLOCK)
  WHERE TwC_TwrTyp = @TwrTyp AND TwC_TwrNumer = @TwrNumer AND TwC_TwrLp = @CENA_NUMER
END
--Pobierz Netto/Brutto
SELECT @CENA_FLAGANB = SUBSTRING(Naz_Nazwa,LEN(Naz_Nazwa)-1,1),@DOKLADNOSC = SUBSTRING(Naz_Nazwa,LEN(Naz_Nazwa),1) FROM CDN.Nazwy WITH (NOLOCK) WHERE Naz_GIDLp = @CENA_NUMER AND Naz_GIDTyp = 64
--Zwróć wyniki
 SELECT  ISNULL(@CENA_NUMER,0) AS CENA_LP,ISNULL(@CENA_WARTOSC,0) AS CENA_WARTOSC,
  ISNULL(@CENA_PRM,0) AS CENA_PRMID,ISNULL(@CENA_WALUTA,'') AS CENA_WALUTA,
  ISNULL(@CENA_KURSL,0) AS CENA_KursL,ISNULL(@CENA_KURSM,0) AS CENA_KursM,
  ISNULL(@CENA_PRECYZJA,0) AS CENA_Precyzja,ISNULL(@DOKLADNOSC,0) AS CENA_Dokladnosc,
  ISNULL(@CENA_FLAGANB,0) AS CENA_FlagaNB, ISNULL(@POMIN_POZ,0) AS CENA_PominPozostale,
  @SKADCENA AS CENA_ZRODLO WHERE @CENA_NUMER IS NOT NULL
--SELECT ISNULL(@CENA_NUMER,0) AS NumerCennika,ISNULL(@CENA_WARTOSC,0) AS Cena,ISNULL(@CENA_PRM,0) AS IDPromocji,ISNULL(@CENA_WALUTA,'') AS Waluta,ISNULL(@CENA_KURSL,0) AS KursL,ISNULL(@CENA_KURSM,0) AS KursM,ISNULL(@CENA_PRECYZJA,0) AS Precyzja,ISNULL(@DOKLADNOSC,0) AS Dokladnosc,ISNULL(@CENA_FLAGANB,0) AS FlagaNB, ISNULL(@POMIN_POZ,0) AS PominPozostale,@SKADCENA AS ZrodloCeny WHERE @CENA_NUMER IS NOT NULL
SET NOCOUNT OFF
