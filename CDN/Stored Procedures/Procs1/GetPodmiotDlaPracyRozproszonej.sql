CREATE PROCEDURE CDN.GetPodmiotDlaPracyRozproszonej @Pod_TypOpis VARCHAR(15), @Pod_Kod NVARCHAR(20), @Pod_ImportRowId VARCHAR(36), @Pod_NIP NVARCHAR(20),
 @Tryb INT,
 @PodID INT OUTPUT, @PodTyp INT OUTPUT, @KntMedialny INT OUTPUT,
 @Warnings NVARCHAR(1000) OUTPUT
AS
BEGIN
 DECLARE @KntCzyWgNIP TINYINT
 DECLARE @KntCzyNadrzedny TINYINT
 DECLARE @KntKodDocelowy NVARCHAR(20)
  SET @KntCzyWgNIP = 0
  SET @KntCzyNadrzedny = 0
  SET @KntKodDocelowy = ''
 IF(@Pod_TypOpis = 'kontrahent')
 BEGIN
  DECLARE @NadID INT
  SET @PodId = NULL
  SELECT @PodId = Knt_KntId, @PodTyp = 1, @KntMedialny = Knt_Medialny, @NadID = Knt_NadID
   FROM CDN.Kontrahenci
   WHERE Knt_ImportRowId = @Pod_ImportRowId
  IF(@PodId is NULL)
      SELECT @PodId = Knt_KntId, @PodTyp = 1, @KntMedialny = Knt_Medialny, @NadID = Knt_NadID
      FROM CDN.Kontrahenci
      WHERE Knt_Kod = @Pod_Kod
  IF(@PodId IS NULL AND @Pod_NIP IS NOT NULL AND @Pod_NIP <> '')
  BEGIN
   -- Musimy obliczyć ilość kontrahentów w bazie o zadanym NIP-ie, ale tak aby nie zliczać wiele razy kontrahentów głównych i ich duplikatów.
   -- Innymi słowy, jeśli m spośród n duplikatów danego kontrahenta ma zgodny NIP, to traktujemy to jakby był jeden kontrahent o zgodnym NIP-ie.
   -- Podobnie, jeśli kontrahent główny ma zgodny NIP oraz m spośród jego n duplikatów ma zgodny NIP, traktujemy to jakby był jeden kontrahent o zgodnym NIP-ie.
   -- Obliczamy ilość kart-nieduplikatów o zgodnym NIP-ie
   DECLARE @cntNad INT
   SELECT @cntNad = COUNT(*) FROM CDN.Kontrahenci WHERE Knt_NadID Is Null AND Knt_Nip = REPLACE(@Pod_NIP, '-', '')
   -- Obliczamy ilość kart-duplikatów o zgodnym NIP-ie dla kart głównych o niezgodnym NIP-ie (główne o zgodnym zostały uwzględnione w @cntNad) tak jednak,
   --że jeśli dla danej karty głównej więcej niż 1 duplikat ma zgodny NIP, to traktujemy te zgodne duplikaty jako jeden kontrahent (DISTINCT).
   DECLARE @cntPod INT
   SELECT @cntPod = COUNT(DISTINCT(A.Knt_KntId)) FROM CDN.Kontrahenci B INNER JOIN CDN.Kontrahenci A ON A.Knt_KntId = B.Knt_NadId
        WHERE B.Knt_Nip = REPLACE(@Pod_NIP, '-', '') AND A.Knt_Nip <> REPLACE(@Pod_NIP, '-', '')
   IF @cntNad + @cntPod = 1
   BEGIN
    -- Tu mamy pewność, że albo jest tylko jeden kontrahent o zgodnym NIP-ie, albo, jeśli jest ich wiecej, to wszyscy są duplikatami tej samej karty głównej.
    -- W tym drugim przypadku można pobrać ID dowolnego spośród w/w duplikatów, bo i tak potem zostanie pobrane ID karty nadrzędnej.
    SELECT TOP 1 @PodId = Knt_KntId, @PodTyp = 1, @KntMedialny = Knt_Medialny,
     @NadID = Knt_NadID, @KntCzyWgNIP = 1, @KntKodDocelowy = Knt_Kod
    FROM CDN.Kontrahenci
    WHERE Knt_Nip = REPLACE(@Pod_NIP, '-', '')
    ORDER BY Knt_KntId
   END
  END
  -- Jeśli pobrany kontrahent jest duplikatem, pobieramy kartę główną
  IF(@PodId Is NOT NULL AND @NadID Is NOT NULL)
   SELECT @PodId = Knt_KntID, @PodTyp = 1, @KntMedialny = Knt_Medialny, @KntCzyNadrzedny = 1, @KntKodDocelowy = Knt_Kod
   FROM CDN.Kontrahenci
   WHERE Knt_KntID = @NadID
  IF @PodId IS NOT NULL
   SET @PodTyp = 1
 END
 ELSE
 IF @Pod_TypOpis = 'bank'
 BEGIN
  SELECT @PodId = BNa_BNaId, @PodTyp = 2
  FROM CDN.BnkNazwy
  WHERE BNa_ImportRowId = @Pod_ImportRowId
  IF @PodId is NULL
   SELECT @PodId = BNa_BNaId, @PodTyp = 2
   FROM CDN.BnkNazwy
   WHERE BNa_Akronim = @Pod_Kod
 END
 ELSE IF @Pod_TypOpis = 'pracownik'
 BEGIN
  SELECT @PodId = PRa_PRaId, @PodTyp = 3
  FROM CDN.PracKod
  WHERE PRA_ImportRowId = @Pod_ImportRowId
  IF @PodId is NULL
   SELECT @PodId = PRa_PRaId, @PodTyp = 3
   FROM CDN.PracKod
   WHERE PRA_Kod = @Pod_Kod
 END
 ELSE
 IF @Pod_TypOpis = 'US' OR @Pod_TypOpis = 'ZUS' OR @Pod_TypOpis = 'UC' OR @Pod_TypOpis = 'IC'
 BEGIN
  SELECT @PodId = Urz_UrzId, @PodTyp = 5
  FROM CDN.Urzedy
  WHERE Urz_ImportRowId = @Pod_ImportRowId
  IF @PodId IS NULL
   SELECT @PodId = Urz_UrzId, @PodTyp = 5
   FROM CDN.Urzedy
   WHERE Urz_Akronim = @Pod_Kod
 END
 IF (@PodID is NULL) -- jeśli nie ma kontrahenta w bazie dodajemy ostrzeżenie i przypisujemy kontrahenta nieokreślonego
 BEGIN
   IF @Tryb = 1
   --SET @Warnings = @Warnings + 'Brak podmiotu ' + IsNull(@Pod_Kod, '') + ' w bazie docelowej. Dokument zapisano dla podmiotu !NIEOKREŚLONY!.\'
   SET @Warnings = @Warnings + '##OPT33138##%%podmiot%%=' + IsNull(@Pod_Kod, '') + '##\'
  ELSE IF @Tryb = 2
   --SET @Warnings = @Warnings + 'Brak podmiotu ' + IsNull(@Pod_Kod, '') + ' w bazie docelowej. Dokument zapisano bez zaliczkobiorcy.\'
   SET @Warnings = @Warnings + '##OPT33139##%%podmiot%%=' + IsNull(@Pod_Kod, '') + '##\'
  ELSE IF @Tryb = 3
   --SET @Warnings = @Warnings + 'Brak podmiotu ' + IsNull(@Pod_Kod, '') + ' w bazie docelowej. Formę zapisano bez ustawienia płatnika.\'
   SET @Warnings = @Warnings + '##OPT33140##%%podmiot%%=' + IsNull(@Pod_Kod, '') + '##\'
  IF @Tryb = 1
   SELECT @PodID = Knt_KntId, @PodTyp = 1 FROM CDN.Kontrahenci WHERE Knt_Kod = '!NIEOKREŚLONY!'
 END
 ELSE IF @PodTyp = 1
 BEGIN
   DECLARE @doc4m VARCHAR(16)
   DECLARE @doc4d VARCHAR(16)
   DECLARE @pod1 VARCHAR(16)
   DECLARE @pod2 VARCHAR(16)
   IF @Tryb =1
   BEGIN
  SET @doc4m = 'dokument'
  SET @doc4d = 'Dokument'
  SET @pod1 = 'kontrahent'
  SET @pod2 = 'kontrahenta'
   END
   ELSE IF @Tryb = 2
   BEGIN
  SET @doc4m = 'dokument'
  SET @doc4d = 'Dokument'
  SET @pod1 = 'zaliczkobiorca'
  SET @pod2 = 'zaliczkobiorcy'
   END
   ELSE IF @Tryb = 3
   BEGIN
  SET @doc4m = 'formę'
  SET @doc4d = 'Formę'
  SET @pod1 = 'kontrahent'
  SET @pod2 = 'kontrahenta'
   END
   IF(@KntCzyWgNIP = 1 AND @KntCzyNadrzedny = 0)
      -- znaleziono kontrahenta po NIP-ie, nie będącego duplikatem
  --SET @Warnings = @Warnings + 'Nie znaleziono ' + @pod2 + ' ' + IsNull(@Pod_Kod, '') + '. Na ' + @doc4m + ' wstawiono kontrahenta wg numeru NIP, o akronimie ' + @KntKodDocelowy + '.\'
  BEGIN
   IF @Tryb = 1
    SET @Warnings = @Warnings + '##OPT33121##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
   ELSE IF @Tryb = 2
    SET @Warnings = @Warnings + '##OPT33123##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
   ELSE IF @Tryb = 3
    SET @Warnings = @Warnings + '##OPT33125##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
  END
   ELSE IF(@KntCzyWgNIP = 0 AND @KntCzyNadrzedny <> 0)
      -- znaleziono kontrahenta po RowID lub po kodzie, będącego jednak duplikatem i wobec tego zwrócono kontrahenta nadrzędnego
  --SET @Warnings = @Warnings + 'Znaleziony ' + @pod1 + ' ' + IsNull(@Pod_Kod, '') + ' jest duplikatem w bazie docelowej. ' + @doc4d + ' zapisano dla karty głównej ' + @KntKodDocelowy + '.\'
  BEGIN
   IF @Tryb = 1
    SET @Warnings = @Warnings + '##OPT33129##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
   ELSE IF @Tryb = 2
    SET @Warnings = @Warnings + '##OPT33133##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
   ELSE IF @Tryb = 3
    SET @Warnings = @Warnings + '##OPT33134##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
  END
   ELSE IF(@KntCzyWgNIP <> 0 AND @KntCzyNadrzedny <> 0)
      -- znaleziono kontrahenta po NIP, będącego równocześnie duplikatem i wobec tego zwrócono kontrahenta nadrzędnego
  --SET @Warnings = @Warnings + 'Nie znaleziono ' + @pod2 + ' ' + IsNull(@Pod_Kod, '') + ', natomiast kontrahent o zgodnym numerze NIP jest duplikatem w bazie docelowej. ' + @doc4d + ' zapisano dla karty głównej ' + @KntKodDocelowy + '.\'
  BEGIN
   IF @Tryb = 1
    SET @Warnings = @Warnings + '##OPT33135##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
   ELSE IF @Tryb = 2
    SET @Warnings = @Warnings + '##OPT33136##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
   ELSE IF @Tryb = 3
    SET @Warnings = @Warnings + '##OPT33137##%%szukany%%=' + IsNull(@Pod_Kod, '') + '%%podstawiony%%=' + @KntKodDocelowy + '##\'
  END
  END
END
