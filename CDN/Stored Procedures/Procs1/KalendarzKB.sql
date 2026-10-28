CREATE PROCEDURE CDN.KalendarzKB
 @RejestrID INT, @DataOdChar CHAR(10), @DataDoChar CHAR(10), @PomijajDniBezObrotow TINYINT,
 @ZwracajRoota TINYINT, @ZwracajTygodnie TINYINT, @ZwracajDni TINYINT, @ZwracajZdarzenia TINYINT,
  @OpeId INT = NULL,
  @Zdarzenia TINYINT = NULL, @Zapisy TINYINT = NULL, @PomijajZdarzeniaNieRozliczac TINYINT = NULL, @PomijajZapisyNieRozliczac TINYINT = NULL,
  @BlokPrac TINYINT = 0, @BlokTylkoWynagr TINYINT = 0
AS
SET NOCOUNT ON
-- Ustawienie zmiennej @PomijajZdarzeniaNieRozliczac
IF IsNull(@PomijajZdarzeniaNieRozliczac, 0) = 0
  SET @PomijajZdarzeniaNieRozliczac = 0
ELSE
  SET @PomijajZdarzeniaNieRozliczac = 1
-- Ustawienie zmiennej @PomijajZapisyNieRozliczac
IF IsNull(@PomijajZapisyNieRozliczac, 0) = 0
  SET @PomijajZapisyNieRozliczac = 0
ELSE
  SET @PomijajZapisyNieRozliczac = 1
-- Sprawdzenie zakazu do rachunku
IF IsNull(@OpeId,0)<>0 And @RejestrId<>0 And CDN.ZakazDoRachunku(@RejestrId, @OpeId)<>0
Begin
  Declare @RachAkr NVARCHAR(20)
  Select @RachAkr = BRa_Akronim From CDN.BnkRachunki Where BRa_BRaId=@RejestrId
  RaisError('##OPT23425##%%Nazwa%%=%s##', 16, 1, @RachAkr) --RaisError('Operator posiada zakaz do rachunku %s. ', 16, 1,@RachAkr)
  Return
End
-- Konwersja parametrów
DECLARE @DataOd     DATETIME
DECLARE @DataDo     DATETIME
SET @DataOd = CONVERT(datetime, @DataOdChar, 120)
SET @DataDo = CONVERT(datetime, @DataDoChar, 120)
-- Obliczenie sald początkowych
DECLARE @SaldoBO          DECIMAL(15,2)
DECLARE @Saldo0Zdarzenia  DECIMAL(15,2)
DECLARE @Saldo0Zapisy     DECIMAL(15,2)
DECLARE @Saldo0           DECIMAL(15,2)
DECLARE @SaldoRootaZdarzenia  DECIMAL(15,2)
DECLARE @SaldoRootaZapisy DECIMAL(15,2)
DECLARE @SaldoRoota       DECIMAL(15,2)
DECLARE @RejWalutowy      TINYINT
SET @RejWalutowy = 0
IF @RejestrID <> 0 AND EXISTS (Select * From CDN.BnkRachunki Where BRa_BRaId = @RejestrID And BRa_Waluta <> '')
  SET @RejWalutowy = 1
IF @RejestrID=0
  SET @SaldoBO = (SELECT Sum(BRa_SaldoBOSys) FROM cdn.BnkRachunki Where CDN.ZakazDoRachunku(BRa_BRaId, @OpeId)=0)
ELSE
 SET @SaldoBO = (SELECT Sum(Case @RejWalutowy When 1 Then BRa_SaldoBO Else BRa_SaldoBOSys End) FROM cdn.BnkRachunki WHERE BRa_BRaID=@RejestrID)
IF @Zdarzenia <> 0
BEGIN
 IF @RejestrID=0
  SET @Saldo0Zdarzenia =
   (SELECT (SUM(CASE BZd_Kierunek WHEN 1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END) - SUM(CASE BZd_Kierunek WHEN -1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END))
   FROM cdn.BnkZdarzenia
     WHERE BZd_DataReal < @DataOd AND BZd_Rozliczono<2 And BZd_Rozliczono>=@PomijajZdarzeniaNieRozliczac And CDN.ZakazDoRachunku(BZd_BRaId, @OpeId)=0 AND (@BlokPrac=0 OR BZd_PodmiotTyp<>3 AND BZd_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZd_DokumentTyp<>8) )
 ELSE
  SET @Saldo0Zdarzenia =
   (SELECT (SUM(CASE BZd_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END) - SUM(CASE BZd_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END))
   FROM cdn.BnkZdarzenia
     WHERE BZd_DataReal < @DataOd AND BZd_BRaID=@RejestrID AND BZd_Rozliczono<2 And BZd_Rozliczono>=@PomijajZdarzeniaNieRozliczac AND (@BlokPrac=0 OR BZd_PodmiotTyp<>3 AND BZd_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZd_DokumentTyp<>8) )
 SET @Saldo0Zdarzenia = IsNull(@Saldo0Zdarzenia, 0)
END
ELSE
 SET @Saldo0Zdarzenia = 0
IF @Zapisy <> 0
BEGIN
 IF @RejestrID=0
  SET @Saldo0Zapisy =
   (SELECT (SUM(CASE BZp_Kierunek WHEN 1 THEN BZp_KwotaSys ELSE 0 END) - SUM(CASE BZp_Kierunek WHEN -1 THEN BZp_KwotaSys ELSE 0 END))
   FROM cdn.BnkZapisy
     WHERE BZp_DataDok < @DataOd And BZp_Rozliczono>=@PomijajZapisyNieRozliczac AND CDN.ZakazDoRachunku(BZp_BRaId, @OpeId)=0 AND (@BlokPrac=0 OR BZp_PodmiotTyp<>3 AND BZp_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZp_Wynagrodzenie=0) )
 ELSE
  SET @Saldo0Zapisy =
   (SELECT (SUM(CASE BZp_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END) - SUM(CASE BZp_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END))
   FROM cdn.BnkZapisy
     WHERE BZp_DataDok < @DataOd AND BZp_BRaID=@RejestrID AND BZp_Rozliczono>=@PomijajZapisyNieRozliczac AND (@BlokPrac=0 OR BZp_PodmiotTyp<>3 AND BZp_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZp_Wynagrodzenie=0) )
 SET @Saldo0Zapisy = IsNull(@Saldo0Zapisy, 0)
END
ELSE
 SET @Saldo0Zapisy = 0
SET @Saldo0 = @Saldo0Zdarzenia + @Saldo0Zapisy
-- Wykreowanie tabeli tymczasowej
CREATE TABLE #Tmp (
 ID int, BZdBZp int, Data DATETIME, Data5 CHAR(5), Dokument NVARCHAR(256), PodTyp INT, PodID INT, PodNazwa NVARCHAR(101),
 PrzychodZdarzenia DECIMAL(15,2), PrzychodZapisy DECIMAL(15,2), Przychod DECIMAL(15,2),
 RozchodZdarzenia DECIMAL(15,2), RozchodZapisy DECIMAL(15,2), Rozchod DECIMAL(15,2),
 BilansZdarzenia DECIMAL(15,2), BilansZapisy DECIMAL(15,2), Bilans DECIMAL(15,2),
 SaldoZdarzenia DECIMAL(15,2), SaldoZapisy DECIMAL(15,2), Saldo DECIMAL(15,2),
 Poziom TINYINT, ObrotyWsk DECIMAL(15,2))
CREATE INDEX TmpData ON #Tmp(Data)
--Zapis zdarzeń do tabeli tymczasowej
IF @Zdarzenia <> 0
BEGIN
  IF @RejestrID=0
    INSERT INTO #Tmp (
   ID, BZdBZp, Data, Data5, Dokument, PodTyp, PodID, PodNazwa,
   PrzychodZdarzenia, PrzychodZapisy, Przychod,
   RozchodZdarzenia, RozchodZapisy, Rozchod,
   BilansZdarzenia, BilansZapisy, Bilans,
   SaldoZdarzenia, SaldoZapisy, Saldo,
   Poziom, ObrotyWsk)
    SELECT
   ID = BZd_BZdID,
   BZdBZp = 1,
   Data = BZd_DataReal,
   Data5 = CONVERT(CHAR(5), BZd_DataReal, 10),
   Dokument = CASE WHEN BZd_NumerPelny<>'' THEN BZd_NumerPelny ELSE CASE WHEN BZd_NumerObcy<>'' THEN BZd_NumerObcy ELSE BZd_Opis END END,
   PodTyp = BZd_PodmiotTyp,
   PodID = BZd_PodmiotID,
   PodNazwa = Pod_Nazwa1 + ' ' + Pod_Nazwa2,
   PrzychodZdarzenia = CASE BZd_Kierunek WHEN 1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END,
   PrzychodZapisy = 0,
   Przychod = CASE BZd_Kierunek WHEN 1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END,
   RozchodZdarzenia = CASE BZd_Kierunek WHEN -1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END,
   RozchodZapisy = 0,
   Rozchod = CASE BZd_Kierunek WHEN -1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END,
   BilansZdarzenia = (CASE BZd_Kierunek WHEN 1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END - CASE BZd_Kierunek WHEN -1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END),
   BilansZapisy = 0,
   Bilans = (CASE BZd_Kierunek WHEN 1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END - CASE BZd_Kierunek WHEN -1 THEN (BZd_KwotaSys-BZd_KwotaRozSys) ELSE 0 END),
   SaldoZdarzenia = 0,
   SaldoZapisy = 0,
   Saldo = 0,
   Poziom = 3,
   ObrotyWsk = 1
    FROM cdn.BnkZdarzenia
    LEFT OUTER JOIN CDN.PodmiotyView ON Pod_PodId=BZd_PodmiotId AND Pod_PodmiotTyp=BZd_PodmiotTyp
   WHERE BZd_DataReal BETWEEN @DataOd AND @DataDo AND BZd_Rozliczono<2 And BZd_Rozliczono>=@PomijajZdarzeniaNieRozliczac And CDN.ZakazDoRachunku(BZd_BRaId, @OpeId)=0 AND (@BlokPrac=0 OR BZd_PodmiotTyp<>3 AND BZd_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZd_DokumentTyp<>8)
    ORDER BY Data, Dokument
 ELSE
    INSERT INTO #Tmp (
   ID, BZdBZp, Data, Data5, Dokument, PodTyp, PodID, PodNazwa,
   PrzychodZdarzenia, PrzychodZapisy, Przychod,
   RozchodZdarzenia, RozchodZapisy, Rozchod,
   BilansZdarzenia, BilansZapisy, Bilans,
   SaldoZdarzenia, SaldoZapisy, Saldo,
   Poziom, ObrotyWsk)
    SELECT
   ID = BZd_BZdID,
   BZdBZp = 1,
   Data = BZd_DataReal,
   Data5 = CONVERT(CHAR(5), BZd_DataReal, 10),
   Dokument = CASE WHEN BZd_NumerPelny<>'' THEN BZd_NumerPelny ELSE CASE WHEN BZd_NumerObcy<>'' THEN BZd_NumerObcy ELSE BZd_Opis END END,
   PodTyp = BZd_PodmiotTyp,
   PodID = BZd_PodmiotID,
   PodNazwa = Pod_Nazwa1 + ' ' + Pod_Nazwa2,
   PrzychodZdarzenia = CASE BZd_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END,
   PrzychodZapisy = 0,
   Przychod = CASE BZd_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END,
   RozchodZdarzenia = CASE BZd_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END,
   RozchodZapisy = 0,
   Rozchod = CASE BZd_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END,
   BilansZdarzenia = (CASE BZd_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END - CASE BZd_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END),
   BilansZapisy = 0,
   Bilans = (CASE BZd_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END - CASE BZd_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZd_Kwota-BZd_KwotaRoz Else BZd_KwotaSys-BZd_KwotaRozSys End) ELSE 0 END),
   SaldoZdarzenia = 0,
   SaldoZapisy = 0,
   Saldo = 0,
   Poziom = 3,
   ObrotyWsk = 1
    FROM cdn.BnkZdarzenia
    LEFT OUTER JOIN CDN.PodmiotyView ON Pod_PodId=BZd_PodmiotId AND Pod_PodmiotTyp=BZd_PodmiotTyp
   WHERE BZd_DataReal BETWEEN @DataOd AND @DataDo AND BZd_BRaID=@RejestrID AND BZd_Rozliczono<2 And BZd_Rozliczono>=@PomijajZdarzeniaNieRozliczac AND (@BlokPrac=0 OR BZd_PodmiotTyp<>3 AND BZd_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZd_DokumentTyp<>8)
    ORDER BY Data, Dokument
END
--Zapis zapisów do tabeli tymczasowej
IF @Zapisy <> 0
BEGIN
 IF @RejestrID=0
    INSERT INTO #Tmp (
   ID, BZdBZp, Data, Data5, Dokument, PodTyp, PodID, PodNazwa,
   PrzychodZdarzenia, PrzychodZapisy, Przychod,
   RozchodZdarzenia, RozchodZapisy, Rozchod,
   BilansZdarzenia, BilansZapisy, Bilans,
   SaldoZdarzenia, SaldoZapisy, Saldo,
   Poziom, ObrotyWsk)
    SELECT
   ID = BZp_BZpID,
   BZdBZp = 2,
   Data = BZp_DataDok,
   Data5 = CONVERT(CHAR(5), BZp_DataDok, 10),
   Dokument = BZp_NumerPelny,
   PodTyp = BZp_PodmiotTyp,
   PodID = BZp_PodmiotID,
   PodNazwa = Pod_Nazwa1 + ' ' + Pod_Nazwa2,
   PrzychodZdarzenia = 0,
   PrzychodZapisy    = CASE BZp_Kierunek WHEN 1 THEN BZp_KwotaSys ELSE 0 END,
   Przychod          = CASE BZp_Kierunek WHEN 1 THEN BZp_KwotaSys ELSE 0 END,
   RozchodZdarzenia  = 0,
   RozchodZapisy     = CASE BZp_Kierunek WHEN -1 THEN BZp_KwotaSys ELSE 0 END,
   Rozchod           = CASE BZp_Kierunek WHEN -1 THEN BZp_KwotaSys ELSE 0 END,
   BilansZdarzenia = 0,
   BilansZapisy    = (CASE BZp_Kierunek WHEN 1 THEN BZp_KwotaSys ELSE 0 END - CASE BZp_Kierunek WHEN -1 THEN BZp_KwotaSys ELSE 0 END),
   Bilans          = (CASE BZp_Kierunek WHEN 1 THEN BZp_KwotaSys ELSE 0 END - CASE BZp_Kierunek WHEN -1 THEN BZp_KwotaSys ELSE 0 END),
   SaldoZdarzenia = 0,
   SaldoZapisy    = 0,
   Saldo          = 0,
   Poziom = 3,
   ObrotyWsk = 1
   FROM cdn.BnkZapisy
  LEFT OUTER JOIN CDN.PodmiotyView ON Pod_PodId=BZp_PodmiotId AND Pod_PodmiotTyp=BZp_PodmiotTyp
   WHERE BZp_DataDok BETWEEN @DataOd AND @DataDo And BZp_Rozliczono>=@PomijajZapisyNieRozliczac AND CDN.ZakazDoRachunku(BZp_BRaId, @OpeId)=0 AND (@BlokPrac=0 OR BZp_PodmiotTyp<>3 AND BZp_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZp_Wynagrodzenie=0)
  ORDER BY Data, Dokument
 ELSE
  INSERT INTO #Tmp (
   ID, BZdBZp,Data, Data5, Dokument, PodTyp, PodID, PodNazwa,
   PrzychodZdarzenia, PrzychodZapisy, Przychod,
   RozchodZdarzenia, RozchodZapisy, Rozchod,
   BilansZdarzenia, BilansZapisy, Bilans,
   SaldoZdarzenia, SaldoZapisy, Saldo,
   Poziom, ObrotyWsk)
  SELECT
   ID = BZp_BZpID,
   BZdBZp = 2,
   Data = BZp_DataDok,
   Data5 = CONVERT(CHAR(5), BZp_DataDok, 10),
   Dokument = BZp_NumerPelny,
   PodTyp = BZp_PodmiotTyp,
   PodID = BZp_PodmiotID,
   PodNazwa = Pod_Nazwa1 + ' ' + Pod_Nazwa2,
   PrzychodZdarzenia = 0,
   PrzychodZapisy    = CASE BZp_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END,
   Przychod          = CASE BZp_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END,
   RozchodZdarzenia  = 0,
   RozchodZapisy     = CASE BZp_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END,
   Rozchod           = CASE BZp_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END,
   BilansZdarzenia = 0,
   BilansZapisy    = (CASE BZp_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END - CASE BZp_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END),
   Bilans          = (CASE BZp_Kierunek WHEN 1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END - CASE BZp_Kierunek WHEN -1 THEN (Case @RejWalutowy When 1 Then BZp_Kwota Else BZp_KwotaSys End) ELSE 0 END),
   SaldoZdarzenia = 0,
   SaldoZapisy    = 0,
   Saldo          = 0,
   Poziom = 3,
   ObrotyWsk = 1
    FROM cdn.BnkZapisy
    LEFT OUTER JOIN CDN.PodmiotyView ON Pod_PodId=BZp_PodmiotId AND Pod_PodmiotTyp=BZp_PodmiotTyp
   WHERE BZp_DataDok BETWEEN @DataOd AND @DataDo AND BZp_BRaID=@RejestrID AND BZp_Rozliczono>=@PomijajZapisyNieRozliczac AND (@BlokPrac=0 OR BZp_PodmiotTyp<>3 AND BZp_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZp_Wynagrodzenie=0)
    ORDER BY Data, Dokument
END
-- Dodanie totali dni
DECLARE @Data          DATETIME
DECLARE @PrzychodZdarzeniaTmp  NUMERIC(15,2)
DECLARE @PrzychodZapisyTmp  NUMERIC(15,2)
DECLARE @PrzychodTmp   NUMERIC(15,2)
DECLARE @RozchodZdarzeniaTmp  NUMERIC(15,2)
DECLARE @RozchodZapisyTmp  NUMERIC(15,2)
DECLARE @RozchodTmp   NUMERIC(15,2)
DECLARE @BilansZdarzeniaTmp  NUMERIC(15,2)
DECLARE @BilansZapisyTmp  NUMERIC(15,2)
DECLARE @BilansTmp   NUMERIC(15,2)
DECLARE @SaldoZdarzeniaTmp  NUMERIC(15,2)
DECLARE @SaldoZapisyTmp  NUMERIC(15,2)
DECLARE @SaldoTmp   NUMERIC(15,2)
DECLARE @ObrotyWskZdarzeniaTmp NUMERIC(15,2)
DECLARE @ObrotyWskZapisyTmp  NUMERIC(15,2)
DECLARE @ObrotyWskTmp   NUMERIC(15,2)
SET @Data = @DataOd
WHILE @Data<=@DataDo
 BEGIN
  SELECT
   @PrzychodZdarzeniaTmp = ISNULL(SUM(CASE WHEN Data = @Data THEN PrzychodZdarzenia ELSE 0 END), 0),
   @PrzychodZapisyTmp    = ISNULL(SUM(CASE WHEN Data = @Data THEN PrzychodZapisy ELSE 0 END), 0),
   @PrzychodTmp          = ISNULL(SUM(CASE WHEN Data = @Data THEN Przychod ELSE 0 END), 0),
   @RozchodZdarzeniaTmp  = ISNULL(SUM(CASE WHEN Data = @Data THEN RozchodZdarzenia  ELSE 0 END), 0),
   @RozchodZapisyTmp     = ISNULL(SUM(CASE WHEN Data = @Data THEN RozchodZapisy  ELSE 0 END), 0),
   @RozchodTmp           = ISNULL(SUM(CASE WHEN Data = @Data THEN Rozchod  ELSE 0 END), 0),
   @BilansZdarzeniaTmp   = ISNULL(SUM(CASE WHEN Data = @Data THEN BilansZdarzenia   ELSE 0 END), 0),
   @BilansZapisyTmp      = ISNULL(SUM(CASE WHEN Data = @Data THEN BilansZapisy   ELSE 0 END), 0),
   @BilansTmp            = ISNULL(SUM(CASE WHEN Data = @Data THEN Bilans   ELSE 0 END), 0),
   @SaldoZdarzeniaTmp    = ISNULL(@Saldo0Zdarzenia + SUM(BilansZdarzenia), @Saldo0Zdarzenia),
   @SaldoZapisyTmp       = ISNULL(@SaldoBO + @Saldo0Zapisy + SUM(BilansZapisy), @SaldoBO + @Saldo0Zapisy),
   @SaldoTmp             = ISNULL(@SaldoBO + @Saldo0 + SUM(Bilans), @SaldoBO + @Saldo0)
  FROM #Tmp
  WHERE Data<=@Data AND Poziom <> 2
  SELECT
   @ObrotyWskTmp = SUM(Bilans)
  FROM #Tmp
  WHERE Data=@Data AND Poziom <> 2
--      IF @PomijajDniBezObrotow=0 OR EXISTS (SELECT * FROM #Tmp WHERE Data=@Data)
  INSERT INTO #Tmp (
   ID, BZdBZp, Data, Data5, Dokument, PodTyp, PodID, PodNazwa,
   PrzychodZdarzenia, PrzychodZapisy, Przychod,
   RozchodZdarzenia, RozchodZapisy, Rozchod,
   BilansZdarzenia, BilansZapisy, Bilans,
   SaldoZdarzenia, SaldoZapisy, Saldo,
   Poziom, ObrotyWsk)
  VALUES(
   -1, 0, @Data, CONVERT(CHAR(5), @Data, 10), Convert(NVARCHAR(40), @Data, 102), '', 0, '',
   @PrzychodZdarzeniaTmp, @PrzychodZapisyTmp, @PrzychodTmp,
   @RozchodZdarzeniaTmp, @RozchodZapisyTmp, @RozchodTmp,
   @BilansZdarzeniaTmp, @BilansZapisyTmp, @BilansTmp,
   @SaldoZdarzeniaTmp, @SaldoZapisyTmp, @SaldoTmp,
   2, @ObrotyWskTmp)
  SET @SaldoRootaZdarzenia = @SaldoZdarzeniaTmp
  SET @SaldoRootaZapisy = @SaldoZapisyTmp
  SET @SaldoRoota = @SaldoTmp
  SET @Data = @Data + 1
 END
-- Dodanie totali tygodni
IF @ZwracajTygodnie=1
 BEGIN
  SET DATEFIRST 1
  DECLARE @d DATETIME
  DECLARE @monday DATETIME
  DECLARE @sunday DATETIME
  DECLARE @t INT
  SET @d = @DataOd
  WHILE @d<=@DataDo --Idziemy po kolejnych tygodniach
   BEGIN
    SET @monday = @d - DATEPART(dw, @d) + 1
    SET @sunday = @d + (7 - DATEPART(dw, @d))
    SET @t = DATEPART(wk, @d)
    SELECT
     @PrzychodZdarzeniaTmp= SUM(PrzychodZdarzenia),
     @PrzychodZapisyTmp = SUM(PrzychodZapisy),
     @PrzychodTmp  = SUM(Przychod),
     @RozchodZdarzeniaTmp= SUM(RozchodZdarzenia),
     @RozchodZapisyTmp = SUM(RozchodZapisy),
     @RozchodTmp   = SUM(Rozchod),
     @BilansZdarzeniaTmp = SUM(BilansZdarzenia),
     @BilansZapisyTmp = SUM(BilansZapisy),
     @BilansTmp   = SUM(Bilans),
     @SaldoZdarzeniaTmp = 0,
     @SaldoZapisyTmp  = 0,
     @SaldoTmp   = 0
    FROM #Tmp
    WHERE Poziom=2 AND Data BETWEEN @monday AND @sunday
    SET @Data    = 0
    SET @SaldoZdarzeniaTmp = 0
    SET @SaldoZapisyTmp  = 0
    SET @SaldoTmp   = 0
    SELECT
     @Data    = Data,
     @SaldoZdarzeniaTmp = SaldoZdarzenia,
     @SaldoZapisyTmp  = SaldoZapisy,
     @SaldoTmp   = Saldo
    FROM #Tmp
    WHERE Poziom=2 AND Data = @sunday
    IF @Data=0 OR @Data Is Null --Nie ma niedzieli ostatniego tygodnia w tabeli tymczasowej
     BEGIN
      SET @Data = (SELECT MAX(Data) FROM #Tmp)
      SET @Data = DATEADD(day, 7-DATEPART(dw, @Data), @Data)
      SET @SaldoZdarzeniaTmp  = @SaldoRootaZdarzenia
      SET @SaldoZapisyTmp  = @SaldoRootaZapisy
      SET @SaldoTmp   = @SaldoRoota
     END
    INSERT INTO #Tmp (
     ID, BZdBZp, Data, Data5, Dokument, PodTyp, PodID, PodNazwa,
     PrzychodZdarzenia, PrzychodZapisy, Przychod,
     RozchodZdarzenia, RozchodZapisy, Rozchod,
     BilansZdarzenia, BilansZapisy, Bilans,
     SaldoZdarzenia, SaldoZapisy, Saldo, Poziom)
    VALUES(
     -1, 0, @Data-6, CONVERT(CHAR(5), @monday, 10), Convert(NVARCHAR(40), @monday, 102)+' - '+Convert(NVARCHAR(40), @sunday, 102), '', 0, '',
     @PrzychodZdarzeniaTmp, @PrzychodZapisyTmp, @PrzychodTmp,
     @RozchodZdarzeniaTmp, @RozchodZapisyTmp, @RozchodTmp,
     @BilansZdarzeniaTmp, @BilansZapisyTmp, @BilansTmp,
     @SaldoZdarzeniaTmp, @SaldoZapisyTmp, @SaldoTmp, 1)
    SET @d = @sunday + 1
   END
  SET DATEFIRST 7
 END
--Opcjonalne wykasowanie dni bez obrotów
IF @PomijajDniBezObrotow=1 AND @ZwracajDni=1
  DELETE FROM #Tmp WHERE Poziom=2 AND ObrotyWsk Is Null
--Dodanie totalu roota
IF @ZwracajRoota=1
BEGIN
  SELECT
   @PrzychodZdarzeniaTmp  = SUM(PrzychodZdarzenia),
   @PrzychodZapisyTmp = SUM(PrzychodZapisy),
   @PrzychodTmp   = SUM(Przychod),
   @RozchodZdarzeniaTmp   = SUM(RozchodZdarzenia),
   @RozchodZapisyTmp   = SUM(RozchodZapisy),
   @RozchodTmp    = SUM(Rozchod),
   @BilansZdarzeniaTmp    = SUM(BilansZdarzenia),
   @BilansZapisyTmp    = SUM(BilansZapisy),
   @BilansTmp     = SUM(Bilans)
  FROM #Tmp
  WHERE Poziom=2
  INSERT INTO #Tmp (
   ID, BZdBZp, Data, Data5, Dokument, PodTyp, PodID, PodNazwa,
   PrzychodZdarzenia, PrzychodZapisy, Przychod,
   RozchodZdarzenia, RozchodZapisy, Rozchod,
   BilansZdarzenia, BilansZapisy, Bilans,
   SaldoZdarzenia, SaldoZapisy, Saldo,
   Poziom)
  VALUES(
   -1, 0, 0, '', 'Kalendarz', '', 0, '',
   @PrzychodZdarzeniaTmp, @PrzychodZapisyTmp, @PrzychodTmp,
   @RozchodZdarzeniaTmp, @RozchodZapisyTmp, @RozchodTmp,
   @BilansZdarzeniaTmp, @BilansZapisyTmp, @BilansTmp,
   @SaldoRootaZdarzenia, @SaldoRootaZapisy, @SaldoRoota,
   0)
 END
--Opcjonalne wykasowanie dni
IF @ZwracajDni=0
  DELETE FROM #Tmp WHERE Poziom=2
--Opcjonalne wykasowanie zdarzeń
IF @ZwracajZdarzenia=0
  DELETE FROM #Tmp WHERE Poziom=3
SET NOCOUNT OFF
--Zapytanie zwracające resultset na zewnątrz
-- SELECT * FROM #Tmp ORDER BY Data, Poziom, Dokument
SELECT
 ID, Data, Data5, BZdBZp, Dokument, PodTyp, PodID, PodNazwa,
 Przychod,
 Rozchod,
 SaldoPreliminarza = SaldoZdarzenia, SaldoZapisów = SaldoZapisy, Saldo,
 Poziom
FROM #Tmp
ORDER BY Data, Poziom, Dokument
--Porządki
SET NOCOUNT ON
DROP TABLE #Tmp
SET NOCOUNT OFF
