Create PROCEDURE CDN.SprawdzZaleglosci
      @Tryb                 INT,
      @ID                   INT,
      @PodID                INT,
      @PodmiotTyp           INT,
      @Bufor                INT,
      @SumaKwotZdarzen      DECIMAL(15,2),
      @Gotowka              DECIMAL(15,2),
      @KwotaCalkowitaSys    DECIMAL(15,2),
      @KursL                DECIMAL(15,4),
      @KursM                DECIMAL(5,0),
      @NumerPelny           NVARCHAR(30),
      @TodayChar            NVARCHAR(25)
AS
  SET NOCOUNT ON
  DECLARE
      @Flaga            INT,
      @FlagaPlat        INT,
      @limit            DECIMAL(15,2),
      @limitPlat        DECIMAL(15,2),
      @zaleglosci       DECIMAL(15,2),
      @zaleglosciPlat   DECIMAL(15,2),
      @KwotaZdarzen     DECIMAL(15,2),
      @KwotaZdarzenPlat DECIMAL(15,2),
      @KwotaZdarzenZ    DECIMAL(15,2),
      @Today            DATETIME,
      @FlagaZwrotna     INT
  SELECT
      @Flaga =0,
      @limitPlat =0,
      @zaleglosciPlat =0,
      @limit =0,
      @zaleglosci =0,
      @KwotaZdarzen =0,
      @KwotaZdarzenZ =0,
      @FlagaZwrotna =0,
      @KwotaZdarzenPlat =0,
      @Today = CONVERT(DATETIME, @TodayChar, 120)
 IF @PodID <> 1 and @PodmiotTyp = 1
        SELECT @Flaga = Knt_LimitFlag, @FlagaPlat = Knt_LimitPrzeterKredytFlag,@zaleglosciPlat = Knt_LimitPrzeterKredytWartosc  FROM CDN.Kontrahenci WHERE knt_kntid = @PodID
IF @Flaga = 0 and @FlagaPlat = 0
   SET @FlagaZwrotna = -1
ELSE
BEGIN
 IF @Flaga = 1 and (@Bufor <> -1  or @Tryb=1)
 BEGIN
    IF @PodmiotTyp = 1 AND @SumaKwotZdarzen <> @Gotowka
       BEGIN
           SELECT @limit = knt_limitkredytu from cdn.kontrahenci where knt_limitflag = 1 and knt_kntid = @PodID
           SELECT @zaleglosci = Knt_LimitKredytuWykorzystany FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID
           --W przypadku gdy dokument jest juz w buforze istnieje juz dla niego zdarzenie KB. Po ponownym zapisaniu zostanie ono zaktualizowane
           --Od sumy zaleglosci nalezy odjac kwote tego zdarzenia aby wartosc biezacego dokumentu nie byla liczona 2 razy
           if @ID > 0
               SELECT @KwotaZdarzen = Sum (BZd_Kierunek * (BZd_KwotaSys - BZd_KwotaRozSys)) FROM CDN.BnkZdarzenia WHERE  BZd_DokumentId = @ID AND BZd_DokumentTyp = 1 AND Bzd_Rozliczono > 0 AND  Bzd_Podmiotid=@PodID and bzd_podmiottyp=@PodmiotTyp
           else
               SELECT @KwotaZdarzen = Sum (BZd_Kierunek * (BZd_KwotaSys - BZd_KwotaRozSys)) FROM CDN.BnkZdarzenia WHERE  BZd_NumerPelny = @NumerPelny AND Bzd_Rozliczono > 0 AND  Bzd_Podmiotid=@PodID and bzd_podmiottyp=@PodmiotTyp
           SELECT @KwotaZdarzenZ = Sum (BZp_Kierunek * (BZp_KwotaSys - BZp_KwotaRozSys)) FROM CDN.BnkZapisy WHERE BZp_NumerPelny = @NumerPelny AND Bzp_Rozliczono > 0
           SET @KwotaZdarzen = isnull(@KwotaZdarzen,0) + isnull(@KwotaZdarzenZ,0)
           SET @zaleglosci = isnull(@zaleglosci,0)-isnull(@KwotaZdarzen,0)+(@KwotaCalkowitaSys-@Gotowka*@KursL/@KursM)
       END
 END
  IF @Flaga = 1 and @Tryb = 2
 BEGIN
    IF @PodmiotTyp = 1
       BEGIN
           SELECT @limit = knt_limitkredytu from cdn.kontrahenci where knt_limitflag = 1 and knt_kntid = @PodID
           SELECT @zaleglosci = Knt_LimitKredytuWykorzystany FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID
       END
 END
 IF @FlagaPlat = 1 AND @PodmiotTyp = 1 AND @PodID <> 1 AND (@SumaKwotZdarzen <> @Gotowka or @Tryb = 2)
 BEGIN
 SELECT @KwotaZdarzenPlat = sum(Bzd_KwotaSys-Bzd_KwotaRozSys) from cdn.bnkzdarzenia where  bzd_podmiotid=@PodID and bzd_podmiottyp=@PodmiotTyp and Bzd_DataReal< @Today  and bzd_kierunek=1 and Bzd_Rozliczono=1
        IF @zaleglosciPlat > @KwotaZdarzenPlat
  SET @KwotaZdarzenPlat = 0
 END
END
 SET NOCOUNT OFF
 SELECT @FlagaZwrotna as FlagaZwrotna, @Limit as limit, @zaleglosci as zaleglosci,@KwotaZdarzenPlat-ISNULL(@zaleglosciPlat,0) as KwotaZdarzenPlat
