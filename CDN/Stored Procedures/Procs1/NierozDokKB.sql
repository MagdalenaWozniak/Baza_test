CREATE PROCEDURE [CDN].[NierozDokKB]
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
@DoVAT TINYINT,
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
      PodmiotTyp = Pod_PodmiotTyp,
      PodmiotID = Pod_GlID,
      PodmiotAkronim = Pod_GlKod,
      PodmiotNazwa = Pod_GlNazwa12,
      /*
      PodmiotID = CASE WHEN Pod_PodmiotTyp <> 1 THEN Pod_PodID ELSE (SELECT CASE WHEN Knt_NadID Is Null THEN Knt_KntID ELSE Knt_NadID END FROM cdn.Kontrahenci WHERE Knt_KntID = Pod_PodID) END,
      PodmiotAkronim = CASE WHEN Pod_PodmiotTyp <> 1 THEN Pod_Kod ELSE (SELECT CASE WHEN A.Knt_NadID Is Null THEN A.Knt_Kod ELSE (SELECT B.Knt_Kod FROM cdn.Kontrahenci B WHERE B.Knt_KntID = A.Knt_NadID) END FROM cdn.Kontrahenci A WHERE A.Knt_KntID = Pod_PodID) END,
   PodmiotNazwa = CASE WHEN Pod_PodmiotTyp <> 1 THEN Pod_Nazwa1 + ' ' + Pod_Nazwa2 ELSE (SELECT CASE WHEN A.Knt_NadID Is Null THEN A.Knt_Nazwa1 + ' ' + A.Knt_Nazwa2 ELSE (SELECT B.Knt_Nazwa1 + ' ' + B.Knt_Nazwa2 FROM cdn.Kontrahenci B WHERE B.Knt_KntId = A.Knt_NadID) END FROM cdn.Kontrahenci A WHERE A.Knt_KntID = Pod_PodID) END,
      */
      Termin = BZd_Termin,
      PoTerminie = DATEDIFF(dd, cdn.fn_GetWorkingDayAfter(BZd_Termin), @Nadzien),
      DataDok = BZd_DataDok,
      Stan = BZd_Stan,
      Opis = BZd_Opis,
      Telefon = Pod_Telefon1,
      TelefonSMS = Pod_TelefonSMS,
      InfoDod = CASE WHEN Pod_Telefon2<>'' THEN Pod_Telefon1 + ', ' + Pod_Telefon2 ELSE Pod_Telefon1 END,
      Kategoria = Kat_KodSzczegol,
      PoTerminieDoVAT = CASE WHEN YEAR(@NaDzien) >= 2019 THEN (CASE WHEN @DoVAT <> 0 THEN DATEDIFF(day, cdn.fn_GetWorkingDayAfter(BZd_Termin), @naDzien - 89) ELSE 0 END)
                  ELSE (CASE WHEN @DoVAT <> 0 AND YEAR(DATEADD(day, 150, cdn.fn_GetWorkingDayAfter(BZd_Termin))) >= 2013 THEN DATEDIFF(day, cdn.fn_GetWorkingDayAfter(BZd_Termin), @naDzien - 149) ELSE 0 END) END,
      PoTerminieDoDoch = 0
    FROM cdn.BnkZdarzenia
      JOIN CDN.PodmiotyView ON Pod_PodmiotTyp=BZd_PodmiotTyp AND Pod_PodID=BZd_PodmiotID
      JOIN CDN.DokDefinicje ON DDf_DDfID=BZd_DDfID
      LEFT OUTER JOIN CDN.Kategorie ON Kat_KatID=BZd_KatID
    WHERE @CzyZdarzeniaKB=1
      AND (BZd_Stan>0 OR (@CzyZdarzeniaKBBufor=1 AND @DoVAT=0))
      AND BZd_DataDok<=@NaDzien
      AND (BZd_BRaID=@RejestrID OR @RejestrID=0)
      AND (@czyDataDokOdDo=0 OR bzd_datadok>=@dataDokOd AND bzd_datadok<=@dataDokDo)
      AND (@czyTerminOdDo=0 OR bzd_Termin>=@terminOd AND bzd_Termin<=@terminDo)
      AND (@PodTyp=0 OR BZd_PodmiotTyp=@PodTyp) AND (@PodID=0 OR CDN.PodmiotMatch(BZd_PodmiotTyp, BZd_PodmiotID, @PodTyp, @PodID)=1)
--    AND (@PodTyp=0 OR BZd_PodmiotTyp=@PodTyp) AND (@PodID=0 OR BZd_PodmiotID=@PodID OR @PodTyp = 1 AND BZd_PodmiotID IN (SELECT @PodID UNION ALL SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID))
      AND (@BlokPrac=0 OR BZd_PodmiotTyp<>3 AND BZd_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZd_DokumentTyp<>8)
      AND (@Waluta='<wszystkie>' OR @Waluta='-wszystkie-' OR BZd_Waluta = @Waluta)
      AND (@CzyNalez=1 AND BZd_Kierunek=1 OR @CzyZobow=1 AND BZd_Kierunek=-1)
      AND ((@CzyDokPrzych=1 AND @CzyDokRozch=0 AND (DDf_KierunekOrg=1 OR DDf_Klasa=345)) OR  (@CzyDokPrzych=0 AND @CzyDokRozch=1 AND DDf_KierunekOrg=-1) OR (@CzyDokPrzych=1 AND @CzyDokRozch=1))
      AND BZd_Rozliczono<>0
      AND (@KatID=0 OR BZd_KatID=@KatID)
      AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZd_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZd_BRaID, @OpeId, 3, 2) = 0)
      AND (@DoVAT = 0 OR BZd_DokumentTyp IN (1, 101, 2))
   AND (@DoVAT = 0 OR
  (YEAR(@NaDzien)<2019 AND DATEDIFF(day, cdn.fn_GetWorkingDayAfter(BZd_Termin), @NaDzien) >= 150 AND YEAR(DATEADD(day, 150, cdn.fn_GetWorkingDayAfter(BZd_Termin))) >= 2013 OR YEAR(@NaDzien)>=2019 AND DATEDIFF(day, cdn.fn_GetWorkingDayAfter(BZd_Termin), @NaDzien) >= 90)
  AND (BZd_Kierunek < 0 OR YEAR(BZd_DataDok) >= YEAR(@naDzien) - 2))
  )
  UNION ALL
  (
    SELECT
      TypDokKB = 2,
      IDDokKB = BZp_BZpID,
      Kierunek = -BZp_Kierunek,
      NumerDok = CASE WHEN BZp_NumerObcy<>'' THEN BZp_NumerObcy ELSE BZp_NumerPelny END,
      Kwota = BZp_Kwota,
      KwotaSys = BZp_KwotaSys,
      Nalez = 0,
      NalezSys = 0,
      Zobow = 0,
      ZobowSys = 0,
      Waluta = BZp_Waluta,
      PodmiotTyp = Pod_PodmiotTyp,
      PodmiotID = Pod_GlID,
      PodmiotAkronim = Pod_GlKod,
      PodmiotNazwa = Pod_GlNazwa12,
      /*
      PodmiotID = CASE WHEN Pod_PodmiotTyp <> 1 THEN Pod_PodID ELSE (SELECT CASE WHEN Knt_NadID Is Null THEN Knt_KntID ELSE Knt_NadID END FROM cdn.Kontrahenci WHERE Knt_KntID = Pod_PodID) END,
      PodmiotAkronim = CASE WHEN Pod_PodmiotTyp <> 1 THEN Pod_Kod ELSE (SELECT CASE WHEN A.Knt_NadID Is Null THEN A.Knt_Kod ELSE (SELECT B.Knt_Kod FROM cdn.Kontrahenci B WHERE B.Knt_KntID = A.Knt_NadID) END FROM cdn.Kontrahenci A WHERE A.Knt_KntID = Pod_PodID) END,
   PodmiotNazwa = CASE WHEN Pod_PodmiotTyp <> 1 THEN Pod_Nazwa1 + ' ' + Pod_Nazwa2 ELSE (SELECT CASE WHEN A.Knt_NadID Is Null THEN A.Knt_Nazwa1 + ' ' + A.Knt_Nazwa2 ELSE (SELECT B.Knt_Nazwa1 + ' ' + B.Knt_Nazwa2 FROM cdn.Kontrahenci B WHERE B.Knt_KntId = A.Knt_NadID) END FROM cdn.Kontrahenci A WHERE A.Knt_KntID = Pod_PodID) END,
      */
      Termin = BZp_DataDok,
      PoTerminie = 0,
      DataDok = BZp_DataDok,
      Stan = 1,
      Opis = BZp_Opis,
      Telefon = Pod_Telefon1,
      TelefonSMS = Pod_TelefonSMS,
      InfoDod = CASE WHEN Pod_Telefon2<>'' THEN Pod_Telefon1 + ', ' + Pod_Telefon2 ELSE Pod_Telefon1 END,
      Kategoria = Kat_KodSzczegol,
      PoTerminieDoVAT = 0,
      PoTerminieDoDoch = 0
    FROM cdn.BnkZapisy
      JOIN CDN.podmiotyView ON Pod_PodmiotTyp=BZp_PodmiotTyp AND Pod_PodID=BZp_PodmiotID
      JOIN CDN.DokDefinicje ON DDf_DDfID=BZp_DDfID
      LEFT OUTER JOIN CDN.Kategorie ON Kat_KatID=BZp_KatID
    WHERE @CzyZapisyKB=1
      AND BZp_DataDok<=@NaDzien
      AND (BZp_BRaID=@RejestrID OR @RejestrID=0)
      AND (@czyDataDokOdDo=0 AND @czyTerminOdDo=0 OR (@czyDataDokOdDo=1 AND BZp_DataDok BETWEEN @dataDokOd AND @dataDokDo) OR  (@czyDataDokOdDo=0 AND @czyTerminOdDo=1 AND BZp_DataDok BETWEEN @terminOd AND @terminDo))
      AND (@PodTyp=0 OR BZp_PodmiotTyp=@PodTyp) AND (@PodID=0 OR CDN.PodmiotMatch(BZp_PodmiotTyp, BZp_PodmiotID, @PodTyp, @PodID)=1)
--    AND (@PodTyp=0 OR BZp_PodmiotTyp=@PodTyp) AND (@PodID=0 OR BZp_PodmiotID=@PodID OR @PodTyp = 1 AND BZp_PodmiotID IN (SELECT @PodID UNION ALL SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID))
      AND (@BlokPrac=0 OR BZp_PodmiotTyp<>3 AND BZp_PodmiotTyp<>4) AND (@BlokTylkoWynagr=0 OR BZp_Wynagrodzenie=0)
      AND (@Waluta='<wszystkie>' OR @Waluta='-wszystkie-' OR BZp_Waluta = @Waluta)
      AND (@CzyNalez=1 AND BZp_Kierunek=-1 OR @CzyZobow=1 AND BZp_Kierunek=1)
      AND ((@CzyDokPrzych=1 AND @CzyDokRozch=0 AND DDf_KierunekOrg=1) OR (@CzyDokPrzych=0 AND @CzyDokRozch=1 AND DDf_KierunekOrg=-1) OR (@CzyDokPrzych=1 AND @CzyDokRozch=1))
      AND BZp_Rozliczono<>0
      AND (@KatID=0 OR BZp_KatID=@KatID)
      AND (@Plus = 0 AND CDN.ZakazDoRachunku(BZp_BRaID, @OpeId) = 0 OR @Plus = 1 AND CDN.ZakazDoRachunkuPlus(BZp_BRaID, @OpeId, 4, 2) = 0)
      AND @DoVAT = 0
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
                  ZobowSys = CASE @kierunek WHEN -1 THEN @KwotaSys - @ZobowSysRozl ELSE 0 END--,
                  --PoTerminieDoDoch = CASE WHEN @TypDokKB = 2 AND @kierunek = -1 THEN 0 ELSE PoTerminieDoDoch END
    WHERE TypDokKB = @TypDokKB AND IDDokKB = @IdDokKb AND Licznik = @licznik
    IF @licznik > @max BREAK
      SELECT @Licznik = @licznik + 1
  END
  DELETE FROM @DokumentyKB WHERE Nalez=0 AND NalezSys=0 AND Zobow=0 AND ZobowSys=0
  SET NOCOUNT OFF
  SELECT * FROM @DokumentyKB ORDER BY PodmiotTyp, PodmiotAkronim, DataDok
END
