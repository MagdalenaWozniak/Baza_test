CREATE PROCEDURE [CDN].[NierozDokKBDoVATDoDoch]
@naDzien DATETIME,
@RejestrID SMALLINT,
@czyDataDokOdDo SMALLINT,
@dataDokOd DATETIME,
@dataDokDo DATETIME,
@czyTerminOdDo SMALLINT,
@terminOd DATETIME,
@terminDo DATETIME,
@PodTyp SMALLINT,
@PodID  INT,
@Waluta NVARCHAR(11),
@CzyZdarzeniaKB SMALLINT,
@CzyZdarzeniaKBBufor SMALLINT,
@CzyZapisyKB SMALLINT,
@CzyNalez SMALLINT,
@CzyZobow SMALLINT,
@CzyDokPrzych SMALLINT,
@CzyDokRozch SMALLINT,
@BlokPrac SMALLINT,
@BlokTylkoWynagr SMALLINT,
@KatID INT,
@OpeId INT = NULL,
@Plus TINYINT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @Licznik INT
  DECLARE @Max INT
  DECLARE @TypDokKB INT
  DECLARE @IDDOKKb INT
  DECLARE @Kierunek INT
  DECLARE @Kwota DECIMAL (15,2)
  DECLARE @KwotaSys DECIMAL (15,2)
  DECLARE @NalezRozlL  DECIMAL(15,2)
  DECLARE @NalezSysRozlL DECIMAL(15,2)
  DECLARE @ZobowRozlL  DECIMAL(15,2)
  DECLARE @ZobowSysRozlL DECIMAL(15,2)
  DECLARE @NalezRozlP  DECIMAL(15,2)
  DECLARE @NalezSysRozlP DECIMAL(15,2)
  DECLARE @ZobowRozlP  DECIMAL(15,2)
  DECLARE @ZobowSysRozlP DECIMAL(15,2)
  DECLARE @NalezRozl   DECIMAL(15,2)
  DECLARE @NalezSysRozl  DECIMAL(15,2)
  DECLARE @ZobowRozl  DECIMAL(15,2)
  DECLARE @ZobowSysRozl  DECIMAL(15,2)
  DECLARE @DokumentyKB TABLE
  (
    Licznik       INT IDENTITY(1,1),
    TypDokKB      INT,
    IDDokKB       INT,
    Kierunek      INT,
    NumerDok      NVARCHAR(256),
    Kwota       DECIMAL(15,2),
    KwotaSys      DECIMAL(15,2),
    Nalez       DECIMAL(15,2),
    NalezSys      DECIMAL(15,2),
    Zobow       DECIMAL(15,2),
    ZobowSys      DECIMAL(15,2),
    Waluta        NVARCHAR(3),
    PodmiotTyp      INT,
    PodmiotID     INT,
    PodmiotAkronim    NVARCHAR(20),
    PodmiotNazwa    NVARCHAR(255),
    Termin        DATETIME,
    PoTerminie      INT,
    DataDok       DATETIME,
    Stan        INT,
    Opis        NVARCHAR(1024),
    Telefon     VARCHAR(20),
    TelefonSMS  VARCHAR(20),
    InfoDod     NVARCHAR(255),
    Kategoria   NVARCHAR(20),
    PoTerminieDoVAT INT,
    PoTerminieDoDoch INT
    PRIMARY KEY (Licznik, TypDokKB, IDDokKB)
  )
  INSERT INTO @DokumentyKB (TypDokKB, IDDokKB, Kierunek, NumerDok, Kwota, KwotaSys, Nalez, NalezSys, Zobow, ZobowSys,
                            Waluta, PodmiotTyp,PodmiotId, PodmiotAkronim, PodmiotNazwa, Termin, PoTerminie,
                            DataDok, Stan, Opis, Telefon, TelefonSMS, InfoDod, Kategoria, PoTerminieDoVAT, PoTerminieDoDoch)
  (
 SELECT
      TypDokKB = 1,
      IDDokKB = BZd_BZdID,
      Kierunek = BZd_Kierunek,
      NumerDok = CASE WHEN BZd_NumerObcy<>'' THEN BZd_NumerObcy ELSE (CASE WHEN BZd_NumerPelny<>'' THEN BZd_NumerPelny ELSE BZd_Opis END) END,
      Kwota = BZd_Kwota,
      KwotaSys = BZd_KwotaSys,
      Nalez = 0,
      NalezSys = 0,
      Zobow = 0,
      ZobowSys = 0,
      Waluta = BZd_Waluta,
      PodmiotTyp = 1,
      PodmiotID = Pod_GlID,
      PodmiotAkronim = Pod_GlKod,
      PodmiotNazwa = Pod_GlNazwa12,
      Termin = BZd_Termin,
      PoTerminie = DATEDIFF(dd, BZd_TerminR, @Nadzien),
      DataDok = BZd_DataDok,
      Stan = BZd_Stan,
      Opis = BZd_Opis,
      Telefon = Pod_Telefon1,
      TelefonSMS = Pod_TelefonSMS,
      InfoDod = CASE WHEN Pod_Telefon2<>'' THEN Pod_Telefon1 + ', ' + Pod_Telefon2 ELSE Pod_Telefon1 END,
      Kategoria = Kat_KodSzczegol,
      PoTerminieDoVAT = 0,
   PoTerminieDoDoch = DATEDIFF(day, BZd_TerminR, @naDzien - 90)
 FROM cdn.BnkZdarzenia
 JOIN CDN.PodmiotyView ON Pod_PodmiotTyp = BZd_PodmiotTyp AND Pod_PodID = BZd_PodmiotID
 JOIN CDN.Kontrahenci ON Knt_KntID = BZd_PodmiotID
    JOIN CDN.DokDefinicje ON DDf_DDfID=BZd_DDfID
 LEFT OUTER JOIN CDN.Kategorie ON Kat_KatID=BZd_KatID
    WHERE @CzyZdarzeniaKB = 1
  AND BZd_DokumentTyp NOT IN (0, 27, 28, 39, 40)
  AND (BZd_Stan>0 OR @CzyZdarzeniaKBBufor=1)
  AND BZd_DataDok<=@NaDzien
  AND (BZd_BRaID=@RejestrID OR @RejestrID=0)
  AND BZd_Termin>CONVERT(datetime, '2019-12-31', 120)
  AND BZd_DataWys>CONVERT(datetime, '2017-12-31', 120)
  AND (@czyDataDokOdDo=0 OR bzd_datadok>=@dataDokOd AND bzd_datadok<=@dataDokDo)
  AND (@czyTerminOdDo=0 OR bzd_Termin>=@terminOd AND bzd_Termin<=@terminDo)
  AND BZd_PodmiotTyp = 1 AND Knt_Finalny = 0 AND Knt_Export IN (0, 5) AND Knt_PowiazanyUoV = 0
  AND BZd_PodmiotTyp = 1 AND (@PodID=0 OR CDN.PodmiotMatch(BZd_PodmiotTyp, BZd_PodmiotID, @PodTyp, @PodID) = 1)
  AND (@BlokPrac=0 OR BZd_PodmiotTyp<>3 AND BZd_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZd_DokumentTyp<>8)
  AND (@Waluta='<wszystkie>' OR BZd_Waluta = @Waluta)
  AND (@CzyNalez=1 AND BZd_Kierunek=1 OR @CzyZobow=1 AND BZd_Kierunek=-1)
  AND ((@CzyDokPrzych=1 AND @CzyDokRozch=0 AND (DDf_KierunekOrg=1 OR DDf_Klasa=345)) OR  (@CzyDokPrzych=0 AND @CzyDokRozch=1 AND DDf_KierunekOrg=-1) OR (@CzyDokPrzych=1 AND @CzyDokRozch=1))
  AND BZd_Rozliczono<>0
  AND (@KatID=0 OR BZd_KatID=@KatID)
  AND DATEDIFF(day, BZd_TerminR, @naDzien - 89) > 0
  AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZd_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZd_BRaID, @OpeId, 3, 2) = 0)
  )
  ORDER BY PodmiotTyp, PodmiotAkronim, DataDok
  --Przygotowuję recordset do wysyłania wyników
  SELECT @Licznik = 1
  SELECT @Max = Max(Licznik) FROM @DokumentyKB
  WHILE 1=1 AND @Licznik <= @Max
  BEGIN
 SELECT @TypDokKB = TypDokKB, @IDDokKB = IDDokKB, @Kierunek = Kierunek, @Kwota = Kwota, @KwotaSys = KwotaSys
    FROM @DokumentyKB
    WHERE Licznik = @Licznik
    SELECT @NalezRozlL    = isnull(SUM(CASE @kierunek WHEN 1  THEN isnull(BRK_Kwota, 0) ELSE 0 END), 0),
           @NalezSysRozlL = isnull(SUM(CASE @kierunek WHEN 1  THEN isnull(BRK_KwotaSysL, 0) ELSE 0 END), 0),
           @ZobowRozlL    = isnull(SUM(CASE @kierunek WHEN -1 THEN isnull(BRK_Kwota, 0) ELSE 0 END), 0),
           @ZobowSysRozlL = isnull(SUM(CASE @kierunek WHEN -1 THEN isnull(BRK_KwotaSysL, 0) ELSE 0 END), 0)
    FROM cdn.BnkRozKwoty
    WHERE BRK_LDokTyp=@TypDokKb AND BRK_LDokID=@IDDokKB AND BRK_DataDok<=@naDzien
    SELECT @NalezRozlP    = isnull(SUM(CASE @kierunek WHEN 1  THEN isnull(BRK_Kwota, 0) ELSE 0 END), 0),
           @NalezSysRozlP = isnull(SUM(CASE @kierunek WHEN 1  THEN isnull(BRK_KwotaSysP, 0) ELSE 0 END), 0),
           @ZobowRozlP    = isnull(SUM(CASE @kierunek WHEN -1 THEN isnull(BRK_Kwota, 0) ELSE 0 END), 0),
           @ZobowSysRozlP = isnull(SUM(CASE @kierunek WHEN -1 THEN isnull(BRK_KwotaSysP, 0) ELSE 0 END), 0)
    FROM cdn.BnkRozKwoty
    WHERE BRK_PDokTyp=@TypDokKb AND BRK_PDokID=@IdDokKb AND BRK_DataDok<=@naDzien
    SELECT @NalezRozl = @NalezRozlL + @NalezRozlP,
            @NalezSysRozl = @NalezSysRozlL + @NalezSysRozlP,
            @ZobowRozl = @ZobowRozlL + @ZobowRozlP,
            @ZobowSysRozl = @ZobowSysRozlL + @ZobowSysRozlP
    UPDATE @DokumentyKB
              SET Nalez = CASE @kierunek WHEN 1 THEN @Kwota - @NalezRozl ELSE 0 END,
                  NalezSys = CASE @kierunek WHEN 1 THEN @KwotaSys - @NalezSysRozl ELSE 0 END,
                  Zobow = CASE @kierunek WHEN -1 THEN @Kwota - @ZobowRozl ELSE 0 END,
                  ZobowSys = CASE @kierunek WHEN -1 THEN @KwotaSys - @ZobowSysRozl ELSE 0 END,
                  PoTerminieDoDoch = CASE WHEN @TypDokKB = 2 AND @kierunek = -1 THEN 0 ELSE PoTerminieDoDoch END
    WHERE TypDokKB = @TypDokKB AND IDDokKB = @IdDokKb AND Licznik = @licznik
    IF @licznik > @max BREAK
      SELECT @Licznik = @licznik + 1
  END
  DELETE FROM @DokumentyKB WHERE Nalez=0 AND NalezSys=0 AND Zobow=0 AND ZobowSys=0
  SET NOCOUNT OFF
  SELECT * FROM @DokumentyKB ORDER BY PodmiotTyp, PodmiotAkronim, DataDok
END
