CREATE PROCEDURE CDN.GetPlatnikDlaPracyRozproszonej @Platnik_TypOpis VARCHAR(15), @Platnik_Kod NVARCHAR(20), @Platnik_ImportRowId VARCHAR(36), @Platnik_NIP NVARCHAR(20), @Platnik_RachunekNr0 NVARCHAR(51),
 @Tryb INT,
 @PlatnikTyp INT OUTPUT, @PlatnikID INT OUTPUT, @PlatnikRachunekLp INT OUTPUT,
 @Warnings NVARCHAR(1000) OUTPUT
AS
BEGIN
 SET @PlatnikTyp = NULL
 SET @PlatnikID = NULL
 SET @PlatnikRachunekLp = NULL
 DECLARE @KntCzyWgNIP TINYINT
 DECLARE @KntCzyNadrzedny TINYINT
 DECLARE @KntKodDocelowy NVARCHAR(20)
 SET @KntCzyWgNIP = 0
 SET @KntCzyNadrzedny = 0
 SET @KntKodDocelowy = ''
 IF @Platnik_TypOpis = 'kontrahent'
 BEGIN
  DECLARE @NadID INT
  SET @PlatnikID = NULL
  SELECT @PlatnikID = Knt_KntID, @PlatnikTyp = 1, @NadID = Knt_NadID FROM CDN.Kontrahenci WHERE ISNULL(@Platnik_ImportRowId,'') <> '' AND Knt_ImportRowID = @Platnik_ImportRowId
  IF @PlatnikID IS NULL
   SELECT @PlatnikID = Knt_KntID, @NadID = Knt_NadID FROM CDN.Kontrahenci WHERE Knt_Kod = @Platnik_Kod
  IF(@PlatnikID IS NULL AND @Platnik_NIP IS NOT NULL AND @Platnik_NIP <> '')
  BEGIN
   -- Musimy obliczyć ilość kontrahentów w bazie o zadanym NIP-ie, ale tak aby nie zliczać wiele razy kontrahentów głównych i ich duplikatów.
   -- Innymi słowy, jeśli m spośród n duplikatów danego kontrahenta ma zgodny NIP, to traktujemy to jakby był jeden kontrahent o zgodnym NIP-ie.
   -- Podobnie, jeśli kontrahent główny ma zgodny NIP oraz m spośród jego n duplikatów ma zgodny NIP, traktujemy to jakby był jeden kontrahent o zgodnym NIP-ie.
   -- Obliczamy ilość kart-nieduplikatów o zgodnym NIP-ie
   DECLARE @cntNad INT
   SELECT @cntNad = COUNT(*) FROM CDN.Kontrahenci WHERE Knt_NadID Is Null AND Knt_Nip = REPLACE(@Platnik_NIP, '-', '')
   -- Obliczamy ilość kart-duplikatów o zgodnym NIP-ie dla kart głównych o niezgodnym NIP-ie (główne o zgodnym zostały uwzględnione w @cntNad) tak jednak,
   --że jeśli dla danej karty głównej więcej niż 1 duplikat ma zgodny NIP, to traktujemy te zgodne duplikaty jako jeden kontrahent (DISTINCT).
   DECLARE @cntPod INT
   SELECT @cntPod = COUNT(DISTINCT(A.Knt_KntId)) FROM CDN.Kontrahenci B INNER JOIN CDN.Kontrahenci A ON A.Knt_KntId = B.Knt_NadId
        WHERE B.Knt_Nip = REPLACE(@Platnik_NIP, '-', '') AND A.Knt_Nip <> REPLACE(@Platnik_NIP, '-', '')
   IF @cntNad + @cntPod = 1
   BEGIN
    -- Tu mamy pewność, że albo jest tylko jeden kontrahent o zgodnym NIP-ie, albo, jeśli jest ich wiecej, to wszyscy są duplikatami tej samej karty głównej.
    -- W tym drugim przypadku można pobrać ID dowolnego spośród w/w duplikatów, bo i tak potem zostanie pobrane ID karty nadrzędnej.
    SELECT TOP 1 @PlatnikID = Knt_KntId, @PlatnikTyp = 1,
     @NadID = Knt_NadID, @KntCzyWgNIP = 1, @KntKodDocelowy = Knt_Kod
    FROM CDN.Kontrahenci
    WHERE Knt_Nip = REPLACE(@Platnik_NIP, '-', '')
    ORDER BY Knt_KntId
   END
  END
  -- Jeśli pobrany kontrahent jest duplikatem, pobieramy kartę główną
  IF(@PlatnikID Is NOT NULL AND @NadID Is NOT NULL)
   SELECT @PlatnikID = Knt_KntID, @PlatnikTyp = 1, @KntCzyNadrzedny = 1, @KntKodDocelowy = Knt_Kod
   FROM CDN.Kontrahenci
   WHERE Knt_KntID = @NadID
  IF @PlatnikID IS NOT NULL
   SET @PlatnikTyp = 1
 END
 ELSE IF @Platnik_TypOpis = 'bank'
 BEGIN
  SELECT @PlatnikID = BNa_BNaID FROM CDN.BnkNazwy WHERE ISNULL(@Platnik_ImportRowId,'') <> '' AND BNa_ImportRowID = @Platnik_ImportRowId
  IF @PlatnikID IS NULL
   SELECT @PlatnikID = BNa_BNaID FROM CDN.BnkNazwy WHERE BNa_Akronim = @Platnik_Kod
  IF @PlatnikID IS NOT NULL
   SET @PlatnikTyp = 2
 END
 ELSE IF @Platnik_TypOpis = 'pracownik'
 BEGIN
  SELECT @PlatnikID = Pra_PraID FROM CDN.PracKod WHERE ISNULL(@Platnik_ImportRowId,'') <> '' AND Pra_ImportRowID = @Platnik_ImportRowId
  IF @PlatnikID IS NULL
   SELECT @PlatnikID = Pra_PraID FROM CDN.PracKod WHERE Pra_Kod = @Platnik_Kod
    -- IF @PlatnikID IS NOT NULL
      -- SELECT @PlatnikID = PRE_PREID FROM CDN.PracEtaty WHERE PRE_PraID = @PlatnikID AND PRE_DataDo=Convert(datetime,'2999-12-31',121)
  IF @PlatnikID IS NOT NULL
   SET @PlatnikTyp = 3
 END
 ELSE IF @Platnik_TypOpis = 'US' OR @Platnik_TypOpis = 'ZUS' OR @Platnik_TypOpis = 'UC' OR @Platnik_TypOpis = 'IC'
 BEGIN
  SELECT @PlatnikID = Urz_UrzID FROM CDN.Urzedy WHERE ISNULL(@Platnik_ImportRowId,'') <> '' AND Urz_ImportRowID = @Platnik_ImportRowId
  IF @PlatnikID IS NULL
   SELECT @PlatnikID = Urz_UrzID FROM CDN.Urzedy WHERE Urz_Akronim = @Platnik_Kod
  IF @PlatnikID IS NOT NULL
   SET @PlatnikTyp = 5
 END
 IF @PlatnikID Is Not Null
 BEGIN
  IF @PlatnikTyp = 1 OR @PlatnikTyp = 3
  BEGIN
   IF @Platnik_RachunekNr0 Is Not Null AND @Platnik_RachunekNr0 <> ''
    SELECT @PlatnikRachunekLp = SPl_SPlID FROM CDN.SchematPlatnosci WHERE SPl_PodmiotTyp = @PlatnikTyp AND SPl_PodmiotID = @PlatnikID AND SPl_RachunekNr0 = @Platnik_RachunekNr0
  END
  ELSE IF @PlatnikTyp = 5
  BEGIN
   IF @Platnik_RachunekNr0 Is Not Null AND @Platnik_RachunekNr0 <> ''
    SELECT @PlatnikRachunekLp = URa_Lp FROM CDN.UrzRachunki WHERE URa_UrzID = @PlatnikID AND URa_RachunekNr0 = @Platnik_RachunekNr0
  END
 END
 IF (@PlatnikID is NULL AND @Tryb = 1) -- jeśli nie ma kontrahenta w bazie dodajemy ostrzeżenie i przypisujemy kontrahenta nieokreślonego
  --SET @Warnings = @Warnings + 'Brak podmiotu ' + IsNull(@Platnik_Kod, '') + ' w bazie docelowej. Dokument zapisano z płatnikiem równym podmiotowi.\'
  SET @Warnings = @Warnings + '##OPT33143##%%podmiot%%=' + IsNull(@Platnik_Kod, '') + '##\'
 ELSE IF @PlatnikTyp = 1
 BEGIN
  IF(@KntCzyWgNIP = 1 AND @KntCzyNadrzedny = 0)
   -- znaleziono kontrahenta po NIP-ie, nie będącego duplikatem
   --SET @Warnings = @Warnings + 'Nie znaleziono płatnika ' + IsNull(@Platnik_Kod, '') + '. Na płatność wstawiono kontrahenta wg numeru NIP, o akronimie ' + @KntKodDocelowy + '.\'
   SET @Warnings = @Warnings + '##OPT33144##%%platnik%%=' + IsNull(@Platnik_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
  ELSE IF(@KntCzyWgNIP = 0 AND @KntCzyNadrzedny = 1)
   -- znaleziono kontrahenta po RowID lub po kodzie, będącego jednak duplikatem i wobec tego zwrócono kontrahenta nadrzędnego
   --SET @Warnings = @Warnings + 'Znaleziony płatnik ' + IsNull(@Platnik_Kod, '') + ' jest duplikatem w bazie docelowej. Płatność zapisano dla karty głównej ' + @KntKodDocelowy + '.\'
   SET @Warnings = @Warnings + '##OPT33145##%%platnik%%=' + IsNull(@Platnik_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
  ELSE IF(@KntCzyWgNIP = 1 AND @KntCzyNadrzedny = 1)
   -- znaleziono kontrahenta po NIP, będącego równocześnie duplikatem i wobec tego zwrócono kontrahenta nadrzędnego
   --SET @Warnings = @Warnings + 'Nie znaleziono płatnika ' + IsNull(@Platnik_Kod, '') + ', natomiast kontrahent o zgodnym numerze NIP jest duplikatem w bazie docelowej. Płatność zapisano dla karty głównej ' + @KntKodDocelowy + '.\'
   SET @Warnings = @Warnings + '##OPT33147##%%platnik%%=' + IsNull(@Platnik_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
 END
END
