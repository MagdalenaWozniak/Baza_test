CREATE Procedure [CDN].[KorektaKursuWalutKB] @DokTyp Int, @DokID Int, @TypKursuWalutyID Int, @DataKurStr NVARCHAR(20), @KursL DECIMAL(15,4), @KursM Int, @OpeID INT, @IDDokAnulowany INT = 0
AS
BEGIN
 -- Procedura aktualizuje notowanie na zdarzeniach walutowych powiązanych z podanym dokumentem oraz ich rozliczeniach wg podanych wartości typu kursu, daty kursu oraz licznika i mianownika kursu.
 -- Zmiana notowania pociąga za sobą zmianę wartości kwoty w walucie systemowej na zdarzeniach i rozliczeniach a także ewentualne powstanie/usunięcie różnicy kursowej.
 -- Procedura nie usuwa żadnych rekordów i nie dodaje nowych a tylko aktualizuje istniejące, dzięki czemu zmienia się tylko to, co ma się zmienić. UPDATE'y są dokonywane tylko w przypadku
 -- zaistnienia zmian - jeśli wszystkie nowe wartości miałyby być równe nowym, takie zdarzenia i rozliczenia są pomijane w procesie (UPDATE nie wykonuje się).
 -- W celu maksymalnego ograniczenia rykoszetów triggery na czas operacji są wyłączane - cała konieczna logika jest zawarta tylko w poniższej procedurze.
 SET NOCOUNT ON
 DECLARE @dataKur  DATETIME
  SET @dataKur = CONVERT(DATETIME, @dataKurStr, 120)
 DECLARE @BZdID   INT
 DECLARE @BZdKierunek INT
 DECLARE @BZdKursNumer INT
 DECLARE @BZdDataKursu DATETIME
 DECLARE @BZdKursL  DECIMAL(15,4)
 DECLARE @BZdKursM  INT
 DECLARE @BZdKwota  DECIMAL(15,2)
 DECLARE @BZdKwotaSysOrg DECIMAL(15,2)
 DECLARE @BZdPodTyp  INT
 DECLARE @BZdPodID  INT
 DECLARE @BZdRozliczono  INT
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeID, @OpeModKod OUT, @OpeModNazwisko OUT
 -- RT (start)
 DECLARE
 @TrN_TrybNettoVAT int,
 @KwotaCalkowitaSys DECIMAL(15,2),
 @KwotaCalkowitaNettoSys DECIMAL(15,2)
 select @TrN_TrybNettoVAT = TrN_TrybNettoVAT,
 @KwotaCalkowitaSys = TrN_RazemBrutto ,
 @KwotaCalkowitaNettoSys = TrN_RazemNetto
 from cdn.TraNag where TrN_TrNID = @DokID
 select
 @KwotaCalkowitaSys = @KwotaCalkowitaSys + ISNULL(SUM(TrN_RazemBrutto),0) ,
 @KwotaCalkowitaNettoSys = @KwotaCalkowitaNettoSys + ISNULL(SUM(TrN_RazemNetto),0)
 from cdn.TraNag where TrN_ZwrID = @DokID and trn_korekta = 8 and TrN_Bufor = 0 and TrN_TrNId != @IDDokAnulowany
 -- RT (end)
   DECLARE @KoncowaKwotaCalkowitaSysDokumentu DECIMAL(15,4)
   if @TrN_TrybNettoVAT = 1
  SELECT @KoncowaKwotaCalkowitaSysDokumentu = @KwotaCalkowitaNettoSys
   else
  SELECT @KoncowaKwotaCalkowitaSysDokumentu = @KwotaCalkowitaSys
 DECLARE @SumaKwotZdarzenSysDokumentu DECIMAL(15,4)
 SELECT @SumaKwotZdarzenSysDokumentu = 0
 DECLARE @BZdID_KwotaSysMax INT
 SELECT @BZdID_KwotaSysMax = 0
 DECLARE @BZd_KwotaSysMax DECIMAL(15,4)
 SELECT @BZd_KwotaSysMax = 0
  -- Wyłączamy triggery bo chcemy zminimalizować ilość operacji i ryzyko rykoszetów - wychodzimy od minimum i będziemy rozbudowywać w miarę potrzeb funkcjonalność
 ALTER TABLE cdn.BnkZdarzenia DISABLE TRIGGER ALL
 ALTER TABLE cdn.BnkRozKwoty DISABLE TRIGGER ALL
  -- Pętla po zdarzeniach w walucie obcej (tylko na tych będziemy zmieniać notowanie), podpiętych do podanego dokumentu
 DECLARE cZdarzenia CURSOR LOCAL FAST_FORWARD
  FOR SELECT BZd_BZdID, BZd_Kierunek, BZd_KursNumer, BZd_DataKur, BZd_KursL, BZd_KursM, BZd_Kwota, BZd_KwotaSys, BZd_PodmiotTyp, BZd_PodmiotID, BZd_Rozliczono
    FROM CDN.BnkZdarzenia
    WHERE BZd_DokumentTyp = @DokTyp AND BZd_DokumentID = @DokID AND BZd_WalutaDok <> ''
 OPEN cZdarzenia
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM cZdarzenia INTO @BZdID, @BZdKierunek, @BZdKursNumer, @BZdDataKursu, @BZdKursL, @BZdKursM, @BZdKwota, @BZdKwotaSysOrg, @BZdPodTyp, @BZdPodID, @BZdRozliczono
  IF @@Fetch_Status <> 0 BREAK
   -- Kwota w walucie się nie zmienia - obliczamy nową kwotę systemową po podanym kursie korekty
  DECLARE @BZdKwotaSysNew DECIMAL(15,2)
  SET @BZdKwotaSysNew = @BZdKwota * @kursL / @kursM
  SET @SumaKwotZdarzenSysDokumentu = @SumaKwotZdarzenSysDokumentu + @BZdKwotaSysNew
  IF @BZdKwotaSysNew > @BZd_KwotaSysMax
  BEGIN
   SELECT @BZd_KwotaSysMax = @BZdKwotaSysNew
   SELECT @BZdID_KwotaSysMax = @BZdID
  END
   -- Sprawdzamy czy cokolwiek trzeba zmienić na zdarzeniu,
   -- jeśli nie (kurs identyczny jak na korekcie) - pomijamy zdarzenie i jego rozliczenia (na któryc po odpowiedniej stronie jest ten właśnie, a więc poprzwny kurs)
  DECLARE @chg TINYINT
  IF @BZdKursNumer = @TypKursuWalutyID AND @BZdDataKursu = @dataKur AND @BZdKursL = @KursL AND @BZdKursM = @KursM AND @BZdKwotaSysNew = @BZdKwotaSysOrg
   SELECT @chg = 0
  ELSE
   SELECT @chg = 1
  IF @chg = 0 CONTINUE
  -- Aktualizacja limitu kredytu kontrahenta
  IF @BZdPodTyp = 1 AND @BZdRozliczono > 0
   UPDATE CDN.Kontrahenci
    SET Knt_LimitKredytuWykorzystany = Knt_LimitKredytuWykorzystany + @BZdKierunek * (@BZdKwotaSysNew - @BZdKwotaSysOrg),
    Knt_TS_Export = Knt_TS_Export
    WHERE Knt_KntId = @BZdPodID
   -- Na modyfikowanych zdarzeniach i rozliczeniach będzie trzeba zaktualizować timestamp ostatniej modyfikacji
  DECLARE @tsMod DATETIME
  SELECT @tsMod = GETDATE()
   -- Aktualizujemy notowanie i kwotę systemową na zdarzeniu wg przesłanego kursu korekty
  UPDATE CDN.BnkZdarzenia
   SET BZd_KursNumer = @typKursuWalutyID, BZd_DataKur = @dataKur, BZd_KursL = @kursL, BZd_KursM = @kursM, BZd_KwotaSys = @BZdKwotaSysNew,
    BZd_OpeModId = @OpeID, BZd_OpeModKod = @OpeModKod, BZd_OpeModNazwisko = @OpeModNazwisko, BZd_TS_Mod = @tsMod
  WHERE BZd_BZdID = @BZdID
   -- Poniżej sprawdzamy i ewentualnie aktualizujemy notowanie na rozliczeniach / różnicach kursowych zmienionego zdarzenia -
   -- uzgadniamy je z ustawionym na zdarzeniu notowaniem korekty
  DECLARE @BRKID    INT
  DECLARE @BRKLDokTyp   INT
  DECLARE @BRKLDokID    INT
  DECLARE @BRKPDokTyp   INT
  DECLARE @BRKPDokID    INT
  DECLARE @BRKKwota   DECIMAL(15,2)
  DECLARE @BRKKwotaSysLOrg DECIMAL(15,2)
  DECLARE @BRKKwotaSysPOrg DECIMAL(15,2)
  DECLARE @BRKRoznicaKursowaSysOrg DECIMAL(15,2)
  DECLARE @BRKNumerNrOrg  INT
  DECLARE @BRKDekID   INT
  DECLARE @BRKDek2ID   INT
  DECLARE @BRKPreDekID  INT
  DECLARE @BRKPreDek2ID  INT
  DECLARE @BRKKPRID   INT
  DECLARE @BRKRycID   INT
  DECLARE @KPNDekID   INT
  DECLARE @KPNPreDekID  INT
   -- Pętla po rozliczeniach, w których udział bierze zmieniane zdarzenie
  DECLARE cRozliczenia CURSOR LOCAL FAST_FORWARD FOR
   SELECT BRK_BRKID, BRK_LDokTyp, BRK_LDokID, BRK_PDokTyp, BRK_PDokID, BRK_Kwota, BRK_KwotaSysL, BRK_KwotaSysP, BRK_RoznicaKursowaSys, BRK_NumerNr,
     BRK_DekId, BRK_Dek2Id, BRK_PreDekID, BRK_PreDek2ID, BRK_KPRId, BRK_RycID, KPN_DekId ,KPN_PreDekID  FROM CDN.BnkRozKwoty
     left join CDN.KompensatyElem on kpe_brkid = BRK_BRKID left join CDN.KompensatyNag on KPE_KPNID = KPN_KPNID
    WHERE BRK_LDokTyp = 1 AND BRK_LDokID = @BZdID OR BRK_PDokTyp = 1 AND BRK_PDokID = @BZdID
  OPEN cRozliczenia
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM cRozliczenia INTO @BRKID, @BRKLDokTyp, @BRKLDokID, @BRKPDokTyp, @BRKPDokID,
    @BRKKwota, @BRKKwotaSysLOrg, @BRKKwotaSysPOrg, @BRKRoznicaKursowaSysOrg,
    @BRKNumerNrOrg,
    @BRKDekId, @BRKDek2Id, @BRKPreDekID, @BRKPreDek2ID, @BRKKPRId, @BRKRycID,@KPNDekID,@KPNPreDekID
   IF @@Fetch_Status <> 0 BREAK
    -- Wyliczamy (nową) różnicę kursową na podstawie notowania z korekty
   DECLARE @BRKKwotaSysNew DECIMAL(15,2)
   SELECT @BRKKwotaSysNew = @BRKKwota * @kursL / @kursM
   DECLARE @BRKRoznicaKursowaSysNew DECIMAL(15,2)
   IF @BRKLDokTyp = 1 AND @BRKLDokID = @BZdID
    SELECT @BRKRoznicaKursowaSysNew = CASE WHEN @BZdKierunek = 1 THEN @BRKKwotaSysPOrg - @BRKKwotaSysNew ELSE @BRKKwotaSysNew - @BRKKwotaSysPOrg END
   ELSE IF @BRKPDokTyp = 1 AND @BRKPDokID = @BZdID
    SELECT @BRKRoznicaKursowaSysNew = CASE WHEN @BZdKierunek = 1 THEN @BRKKwotaSysLOrg - @BRKKwotaSysNew ELSE @BRKKwotaSysNew - @BRKKwotaSysLOrg END
    -- Jeśli na rozliczeniu miałoby się nic nie zmienić, pomijamy takie rozliczenie
   IF (@BRKLDokTyp = 1 AND @BRKLDokID = @BZdID AND (@BRKKwotaSysNew <> @BRKKwotaSysLOrg OR @BRKRoznicaKursowaSysNew <> @BRKRoznicaKursowaSysOrg))
    OR
      (@BRKPDokTyp = 1 AND @BRKPDokID = @BZdID AND (@BRKKwotaSysNew <> @BRKKwotaSysPOrg OR @BRKRoznicaKursowaSysNew <> @BRKRoznicaKursowaSysOrg))
    SELECT @chg = 1
   ELSE
    SELECT @chg = 0
   IF @chg = 0 CONTINUE
    -- Sprawdzamy czy rozliczenie (różnica kursowa) nie jest zaksięgowane w jakiejkolwiek sposób
   IF @BRKDekId Is Not NULL OR @BRKDek2Id Is Not NULL OR @BRKPreDekID Is Not NULL OR @BRKPreDek2ID Is Not NULL OR @BRKKPRID Is Not NULL OR @BRKRycID Is Not NULL
   or @KPNDekId Is NOT Null OR @KPNPreDekID  Is NOT Null
   BEGIN
    ALTER TABLE cdn.BnkZdarzenia ENABLE TRIGGER ALL
    ALTER TABLE cdn.BnkRozKwoty ENABLE TRIGGER ALL
    RAISERROR('##OPT33024##', 16, 1) --RAISERROR('Nie można zapisać korekty kursu. Nie można zmieniać dokumentów zaksięgowanych.', 16, 1)
    RETURN
   END
    -- Aktualizujemy kwotę sys na rozliczeniu po odpowiedniej stronie oraz różnicę kursową
   IF @BRKLDokTyp = 1 AND @BRKLDokID = @BZdID
    UPDATE CDN.BnkRozKwoty
     SET BRK_KwotaSysL = @BRKKwotaSysNew,
      BRK_RoznicaKursowaSys = @BRKRoznicaKursowaSysNew,
      /* BRK_OpeZalId = @OpeID, BRK_TS_Zal = @tsMod, */ BRK_OpeModId = @OpeID, BRK_OpeModKod = @OpeModKod, BRK_OpeModNazwisko = @OpeModNazwisko, BRK_TS_Mod = @tsMod
    WHERE BRK_BRKID = @BRKID
   ELSE IF @BRKPDokTyp = 1 AND @BRKPDokID = @BZdID
    UPDATE CDN.BnkRozKwoty
     SET BRK_KwotaSysP = @BRKKwotaSysNew,
      BRK_RoznicaKursowaSys = @BRKRoznicaKursowaSysNew,
      /* BRK_OpeZalId = @OpeID, BRK_TS_Zal = @tsMod, */ BRK_OpeModId = @OpeID, BRK_OpeModKod = @OpeModKod, BRK_OpeModNazwisko = @OpeModNazwisko, BRK_TS_Mod = @tsMod
    WHERE BRK_BRKID = @BRKID
    -- Jeśli wyliczona różnica kursowa jest niezerowa, a wcześniej było to zwykłe rozliczenie, trzeba wyliczyć NumerNr dokumentu.
    -- Podobnie w drugą stronę - jeśli wyliczona różnica kursowa jest zerowa, a wcześniej rozliczenie miało niezerowy NumerNr - zerujemy go.
   IF @BRKRoznicaKursowaSysNew <> 0 AND @BRKNumerNrOrg = -1
   BEGIN
    DECLARE @MaxNr INT
    SELECT @MaxNr = IsNull(Max(BRK_NumerNr),0) + 1 FROM CDN.BnkRozKwoty WHERE BRK_NumerString = (SELECT BRK_NumerString FROM CDN.BnkRozKwoty WHERE BRK_BRKId=@BRKID)
    UPDATE CDN.BnkRozKwoty SET BRK_NumerNr = @MaxNr WHERE BRK_BRKId = @BRKID
   END
   ELSE IF @BRKRoznicaKursowaSysNew = 0 AND @BRKNumerNrOrg <> -1
    UPDATE CDN.BnkRozKwoty SET BRK_NumerNr = -1 WHERE BRK_BRKId = @BRKID
  END
  CLOSE cRozliczenia
  DEALLOCATE cRozliczenia
    UPDATE cdn.BnkZdarzenia
      SET BZd_KwotaRozSys = (SELECT IsNull(SUM(CASE WHEN BRK_LDokTyp = 1 AND BRK_LDokID = @BZdID THEN BRK_KwotaSysL ELSE BRK_KwotaSysP END), 0) FROM cdn.BnkRozKwoty WHERE BRK_LDokTyp = 1 AND BRK_LDokID = @BZdID OR BRK_PDokTyp = 1 AND BRK_PDokID = @BZdID)
    WHERE BZd_BZdID = @BZdID
 END
 CLOSE cZdarzenia
 DEALLOCATE cZdarzenia
  -- Jeśli po przeliczeniach (wynikających ze zmiany kursu) kwoty sys na zdarzeniach związanych z dokumentem okaże się, że suma kwot systemowych na zdarzeniach
  -- różni się od kwoty całkowitej sys na skorygowanym dokumencie, to tę różnicę "upychamy" w największym kwotowo (sys) zdarzeniu, oczywiście zmieniając jego kurs na nieokreślony.
  -- Oczywiście zmieniając kwotę Sys na zdarzeniu musimy o tyle samo zmienić sumę kwot sys na rozliczeniach tego zdarzenia (znajdujemy pierwsze i na nim tą różnicę uwzględniamy).
  -- (Patrz zgłoszenie 212664, 222651)
 IF @SumaKwotZdarzenSysDokumentu <> @KoncowaKwotaCalkowitaSysDokumentu
 BEGIN
  SELECT @BZdID = @BZdID_KwotaSysMax
  SELECT @BZdKwotaSysNew = @BZd_KwotaSysMax - (@SumaKwotZdarzenSysDokumentu - @KoncowaKwotaCalkowitaSysDokumentu)
  IF @BZdKwotaSysNew < 0
  BEGIN
   ALTER TABLE cdn.BnkZdarzenia ENABLE TRIGGER ALL
   ALTER TABLE cdn.BnkRozKwoty ENABLE TRIGGER ALL
   RAISERROR('##OPT33025##', 16, 1) --RAISERROR('Nie można zapisać korekty kursu. Zapis spowodowałby ujemną kwotę w walucie systemowej na płatności.', 16, 1)
   RETURN
  END
  -- Pobranie do zmiennych potrzebnych danych korygowanego zdarzenia
  SELECT @BZdPodTyp = BZd_PodmiotTyp, @BZdPodID = BZd_PodmiotID, @BZdRozliczono = BZd_Rozliczono, @BZdKierunek = BZd_Kierunek, @BZdKwotaSysOrg = BZd_KwotaSys FROM cdn.BnkZdarzenia
   WHERE BZd_BZdID = @BZdID
  DECLARE @ZmianaBZdKwotaSys DECIMAL(15,2)
  SELECT @ZmianaBZdKwotaSys = @BZdKwotaSysNew - @BZdKwotaSysOrg -- o tyle zmieniamy kwotę sys na zdarzeniu w zwiżaku z wyrównywaniem sumy zdarzeń dokumentu do kwoty całkowitej sys dokumentu
  -- Aktualizacja limitu kredytu kontrahenta
  IF @BZdPodTyp = 1 AND @BZdRozliczono > 0
   UPDATE CDN.Kontrahenci
    SET Knt_LimitKredytuWykorzystany = Knt_LimitKredytuWykorzystany + @BZdKierunek * (@BZdKwotaSysNew - @BZdKwotaSysOrg),
    Knt_TS_Export = Knt_TS_Export
    WHERE Knt_KntId = @BZdPodID
   -- Na modyfikowanych zdarzeniach i rozliczeniach będzie trzeba zaktualizować timestamp ostatniej modyfikacji
  SELECT @tsMod = GETDATE()
   -- Modyfikujemy kwotę sys na wybranym zdarzeniu i jednocześnie przełączamy typ kursu na nieokreślony aby uniknąć na zdarzeniu niezgodności kwota <> kurs * kwotaSys
  UPDATE CDN.BnkZdarzenia
   SET BZd_KursNumer = -1, BZd_DataKur = @dataKur, BZd_KursL = 0, BZd_KursM = 1, BZd_KwotaSys = @BZdKwotaSysNew,
    BZd_OpeModId = @OpeID, BZd_OpeModKod = @OpeModKod, BZd_OpeModNazwisko = @OpeModNazwisko, BZd_TS_Mod = @tsMod
  WHERE BZd_BZdID = @BZdID
   -- Pętla po rozliczeniach, w których udział bierze zmieniane zdarzenie
  DECLARE cRozliczenia CURSOR LOCAL FAST_FORWARD FOR
   SELECT BRK_BRKID, BRK_LDokTyp, BRK_LDokID, BRK_PDokTyp, BRK_PDokID, BRK_Kwota, BRK_KwotaSysL, BRK_KwotaSysP, BRK_RoznicaKursowaSys, BRK_NumerNr,
     BRK_DekId, BRK_Dek2Id, BRK_PreDekID, BRK_PreDek2ID, BRK_KPRId, BRK_RycID FROM CDN.BnkRozKwoty
    WHERE BRK_LDokTyp = 1 AND BRK_LDokID = @BZdID OR BRK_PDokTyp = 1 AND BRK_PDokID = @BZdID
  OPEN cRozliczenia
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM cRozliczenia INTO @BRKID, @BRKLDokTyp, @BRKLDokID, @BRKPDokTyp, @BRKPDokID,
    @BRKKwota, @BRKKwotaSysLOrg, @BRKKwotaSysPOrg, @BRKRoznicaKursowaSysOrg,
    @BRKNumerNrOrg,
    @BRKDekId, @BRKDek2Id, @BRKPreDekID, @BRKPreDek2ID, @BRKKPRId, @BRKRycID
   IF @@Fetch_Status <> 0 BREAK
   IF @ZmianaBZdKwotaSys < 0
   BEGIN
     -- zmniejszamy kwotę sys na zdarzeniu, więc musimy też zmniejszyć jego kwotę rozliczenia sys na którymś rozliczeniu, ale nie możemy zejść poniżej zera
    IF @BRKLDokTyp = 1 AND @BRKLDokID = @BZdID AND @BRKKwotaSysLOrg < -@ZmianaBZdKwotaSys
     CONTINUE
    ELSE IF @BRKPDokTyp = 1 AND @BRKPDokID = @BZdID AND @BRKKwotaSysPOrg < -@ZmianaBZdKwotaSys
     CONTINUE
   END
    -- Wyliczamy (nową) różnicę kursową, ale nie na podstawie notowania z korekty, bo to zrobiliśmy wcześniej, a tu modyfikujemy o wartość zmienioną na zdarzeniu w związku z różnicą z dokumentem
   --SELECT @BRKKwotaSysNew = @BRKKwota * @kursL / @kursM
   IF @BRKLDokTyp = 1 AND @BRKLDokID = @BZdID
    SELECT @BRKKwotaSysNew = @BRKKwotaSysLOrg + @ZmianaBZdKwotaSys
   ELSE IF @BRKPDokTyp = 1 AND @BRKPDokID = @BZdID
    SELECT @BRKKwotaSysNew = @BRKKwotaSysPOrg + @ZmianaBZdKwotaSys
   IF @BRKLDokTyp = 1 AND @BRKLDokID = @BZdID
    SELECT @BRKRoznicaKursowaSysNew = CASE WHEN @BZdKierunek = 1 THEN @BRKKwotaSysPOrg - @BRKKwotaSysNew ELSE @BRKKwotaSysNew - @BRKKwotaSysPOrg END
   ELSE IF @BRKPDokTyp = 1 AND @BRKPDokID = @BZdID
    SELECT @BRKRoznicaKursowaSysNew = CASE WHEN @BZdKierunek = 1 THEN @BRKKwotaSysLOrg - @BRKKwotaSysNew ELSE @BRKKwotaSysNew - @BRKKwotaSysLOrg END
    -- Jeśli na rozliczeniu miałoby się nic nie zmienić, pomijamy takie rozliczenie
   IF (@BRKLDokTyp = 1 AND @BRKLDokID = @BZdID AND (@BRKKwotaSysNew <> @BRKKwotaSysLOrg OR @BRKRoznicaKursowaSysNew <> @BRKRoznicaKursowaSysOrg))
    OR
      (@BRKPDokTyp = 1 AND @BRKPDokID = @BZdID AND (@BRKKwotaSysNew <> @BRKKwotaSysPOrg OR @BRKRoznicaKursowaSysNew <> @BRKRoznicaKursowaSysOrg))
    SELECT @chg = 1
   ELSE
    SELECT @chg = 0
   IF @chg = 0 CONTINUE
    -- Sprawdzamy czy rozliczenie (różnica kursowa) nie jest zaksięgowane w jakiejkolwiek sposób
   IF @BRKDekId Is Not NULL OR @BRKDek2Id Is Not NULL OR @BRKPreDekID Is Not NULL OR @BRKPreDek2ID Is Not NULL OR @BRKKPRID Is Not NULL OR @BRKRycID Is Not NULL
   BEGIN
    ALTER TABLE cdn.BnkZdarzenia ENABLE TRIGGER ALL
    ALTER TABLE cdn.BnkRozKwoty ENABLE TRIGGER ALL
    RAISERROR('##OPT33024##', 16, 1) --RAISERROR('Nie można zapisać korekty kursu. Nie można zmieniać dokumentów zaksięgowanych.', 16, 1)
    RETURN
   END
    -- Aktualizujemy kwotę sys na rozliczeniu po odpowiedniej stronie oraz różnicę kursową
   IF @BRKLDokTyp = 1 AND @BRKLDokID = @BZdID
    UPDATE CDN.BnkRozKwoty
     SET BRK_KwotaSysL = @BRKKwotaSysNew,
      BRK_RoznicaKursowaSys = @BRKRoznicaKursowaSysNew,
      /* BRK_OpeZalId = @OpeID, BRK_TS_Zal = @tsMod, */ BRK_OpeModId = @OpeID, BRK_OpeModKod = @OpeModKod, BRK_OpeModNazwisko = @OpeModNazwisko, BRK_TS_Mod = @tsMod
    WHERE BRK_BRKID = @BRKID
   ELSE IF @BRKPDokTyp = 1 AND @BRKPDokID = @BZdID
    UPDATE CDN.BnkRozKwoty
     SET BRK_KwotaSysP = @BRKKwotaSysNew,
      BRK_RoznicaKursowaSys = @BRKRoznicaKursowaSysNew,
      /* BRK_OpeZalId = @OpeID, BRK_TS_Zal = @tsMod, */ BRK_OpeModId = @OpeID, BRK_OpeModKod = @OpeModKod, BRK_OpeModNazwisko = @OpeModNazwisko, BRK_TS_Mod = @tsMod
    WHERE BRK_BRKID = @BRKID
    -- Jeśli wyliczona różnica kursowa jest niezerowa, a wcześniej było to zwykłe rozliczenie, trzeba wyliczyć NumerNr dokumentu.
    -- Podobnie w drugą stronę - jeśli wyliczona różnica kursowa jest zerowa, a wcześniej rozliczenie miało niezerowy NumerNr - zerujemy go.
   IF @BRKRoznicaKursowaSysNew <> 0 AND @BRKNumerNrOrg = -1
   BEGIN
    SELECT @MaxNr = IsNull(Max(BRK_NumerNr),0) + 1 FROM CDN.BnkRozKwoty WHERE BRK_NumerString = (SELECT BRK_NumerString FROM CDN.BnkRozKwoty WHERE BRK_BRKId=@BRKID)
    UPDATE CDN.BnkRozKwoty SET BRK_NumerNr = @MaxNr WHERE BRK_BRKId = @BRKID
   END
   ELSE IF @BRKRoznicaKursowaSysNew = 0 AND @BRKNumerNrOrg <> -1
    UPDATE CDN.BnkRozKwoty SET BRK_NumerNr = -1 WHERE BRK_BRKId = @BRKID
   BREAK -- zmieniliśmy jedno rozliczenie upychając w nim całą różnicę wynikającą z róznicy pomiędzy kwotą całkowitą dokumentu a sumą przeliczonych po kursie zdarzeń
  END
  CLOSE cRozliczenia
  DEALLOCATE cRozliczenia
 END
 ALTER TABLE cdn.BnkZdarzenia ENABLE TRIGGER ALL
 ALTER TABLE cdn.BnkRozKwoty ENABLE TRIGGER ALL
 SET NOCOUNT OFF
END
