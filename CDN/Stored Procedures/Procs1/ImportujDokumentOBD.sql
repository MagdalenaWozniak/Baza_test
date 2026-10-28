CREATE PROCEDURE CDN.ImportujDokumentOBD
@DokId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@AdditionalIntParam INT, -- TypeForOBD
@DoN_ImportRowID nvarchar(36),
@DDf_ImportRowID nvarchar(36),
@DDf_Symbol nvarchar(5),
@DDf_Numeracja nvarchar(50),
@DoN_NumerString nvarchar(50),
@DoN_NumerNr int,
@DoN_NumerPelny nvarchar(50),
@DoN_NumerObcy nvarchar(256),
@DoN_DataDok nvarchar(10),
@DoN_Tytul nvarchar(50),
@DoN_Dotyczy nvarchar(1024),
@DoN_Typ int,
@DoN_Katalog nvarchar(20),
@DoN_Status int,
@DoN_OriginId int,
@DnP_WBazie smallint,
@DnP_NazwaPliku nvarchar(256),
@DnP_Sciezka nvarchar(256),
@DnP_Wersja smallint,
@DnP_FileMode smallint,
@DnP_DataDok nvarchar(10),
@DnP_Typ int,
@DnP_Archiwalny int,
@DnPID int,
--@DAB_ImportRowID nvarchar(36),
@DAB_MagazynDanych int,
@DAB_MagazynDanychID int,
@DAB_Typ int,
@DAB_Flaga int,
@DAB_Wartosc nvarchar(max),
@DAB_Rozmiar INT,
@DAB_NazwaPliku nvarchar(254),
@DAB_Nazwa nvarchar(128),
@DAB_Rozszerzenie nvarchar(4),
@DAB_Sciezka nvarchar(255),
@DAB_Wersja nvarchar(20),
@DAB_IBard24ID bigint,
@DAB_IBard24LinkPrywatny nvarchar(512),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @DokTyp INT
 SELECT @DokTyp = @AdditionalIntParam
 DECLARE @DataDok DATETIME
 DECLARE @DataDokParent DATETIME
 DECLARE @PodTyp INT
 DECLARE @PodID INT
 DECLARE @DDf_SeriaOperatora TINYINT
 DECLARE @DDfID INT
 DECLARE @zakspr TINYINT
 SET @zakspr = 0
 SET @DDfID = NULL
 IF @DokTyp = 999
  -- Rejestr VAT
 BEGIN
  SELECT @DataDokParent = VaN_DataWys, @PodTyp = VaN_PodmiotTyp, @PodID = VaN_PodID, @zakspr = VaN_Typ FROM CDN.VatNag WHERE VaN_VaNID = @DokId
  IF @zakspr = 1
   SELECT @DDfID = DDf_PowDDfID FROM cdn.DokDefinicje WHERE DDf_Klasa = 750099901
  ELSE IF @zakspr = 2
   SELECT @DDfID = DDf_PowDDfID FROM cdn.DokDefinicje WHERE DDf_Klasa = 750099902
 END
 ELSE IF @DokTyp = 1003
  -- Ewidencja dodatkowa
 BEGIN
  SELECT @DataDokParent = EDN_DataWys, @PodTyp = EDN_PodmiotTyp, @PodID = EDN_PodID, @zakspr = EDN_Typ FROM CDN.EwidDodNag WHERE EDN_EDNID = @DokId
  IF @zakspr = 101
   SELECT @DDfID = DDf_PowDDfID FROM cdn.DokDefinicje WHERE DDf_Klasa = 750100301
  ELSE IF @zakspr = 102
   SELECT @DDfID = DDf_PowDDfID FROM cdn.DokDefinicje WHERE DDf_Klasa = 750100302
 END
 ELSE IF @DokTyp = 1001
  -- Zdarzenie KB
  SELECT @DataDokParent = BZd_DataDok, @PodTyp = BZd_PodmiotTyp, @PodID = BZd_PodmiotID FROM CDN.BnkZdarzenia WHERE BZd_BZdID = @DokId
 ELSE IF @DokTyp = 1122
  -- Raport KB
  SELECT @DataDokParent = BRp_DataDok, @PodTyp = NULL, @PodID = NULL FROM CDN.BnkRaporty WHERE BRp_BRpID = @DokId
 ELSE IF @DokTyp = 1145
  -- Kompensata KB
  SELECT @DataDokParent = KPN_DataDok, @PodTyp = KPN_PodmiotTyp, @PodID = KPN_PodmiotID FROM CDN.KompensatyNag WHERE KPN_KPNID = @DokId
 IF @DoN_DataDok IS NOT NULL
  SELECT @DataDok = CONVERT(datetime, @DoN_DataDok, 120)
 ELSE
  SELECT @DataDok = @DataDokParent
 IF @DataDok IS NULL SELECT @DataDok = GETDATE()
 DECLARE @OCR TINYINT
 IF @DnP_WBazie Is NULL
  SELECT @OCR = 1
 ELSE
  SELECT @OCR = 0
 DECLARE @DoNExists TINYINT
 IF((SELECT count(*)
  FROM CDN.DokNag
  WHERE DoN_ImportRowID = @DoN_ImportRowID) = 0)
 BEGIN
  IF @OCR = 1
   RETURN
  SELECT @DoNExists = 0
  SET @Warnings = ''
/*
  IF(@DDf_ImportRowID IS NOT NULL)
  BEGIN
   SELECT @DDfID = DDf_DDfId
   FROM CDN.DokDefinicje
   WHERE DDf_ImportRowID = @DDf_ImportRowID AND DDf_Numeracja = @DDf_Numeracja
  END
  IF @DDfID IS NULL AND @DDf_Symbol IS NOT NULL
  BEGIN
   SELECT @DDfID = DDf_DDfID
   FROM CDN.DokDefinicje
   WHERE DDf_Symbol = @DDf_Symbol AND DDf_Numeracja = @DDf_Numeracja
  END
  IF @DDf_ImportRowID IS NULL AND @DDf_Symbol IS NULL AND @DDf_Numeracja IS NULL --XT
  BEGIN
*/
  IF @DDfID Is Not NULL
   SELECT @DDf_Symbol = DDf_Symbol, @DDf_Numeracja = DDf_Numeracja, @DDf_SeriaOperatora = DDf_SeriaOperatora
    FROM CDN.DokDefinicje
    WHERE DDf_DDfID = @DDfID
  ELSE
   SELECT @DDfID = Fir_Wartosc, @DDf_Symbol = DDf_Symbol, @DDf_Numeracja = DDf_Numeracja, @DDf_SeriaOperatora = DDf_SeriaOperatora
    FROM CDN.Firma JOIN CDN.DokDefinicje ON DDf_DDfID = Fir_Wartosc
    WHERE Fir_Numer = 1850
  IF @DDfID IS NOT NULL
  BEGIN
   DECLARE
    @RokKal  INT,
    @RokObr  NVARCHAR(5),
    @Miesiac CHAR(2),
    @Seria  NVARCHAR(5),
    @Katalog NVARCHAR(5)
   SET @RokKal = YEAR(@DataDok)
   SET @RokObr  = ISNULL(( SELECT TOP 1 OOb_Symbol FROM cdn.okresyobrach WHERE @DataDok BETWEEN OOb_DataOtw AND DATEADD(day,-1, DATEADD(MONTH, OOb_Dlugosc, OOb_DataOtw))),'')
   SET @Miesiac = CONVERT( CHAR(2), MONTH(@DataDok))
   SET @Miesiac = CASE WHEN CONVERT (INT, @Miesiac) BETWEEN 1 AND 9 THEN '0' + @Miesiac ELSE @Miesiac END
   IF @DDf_SeriaOperatora <> 0
   BEGIN
    DECLARE @sqltxt NVARCHAR (1000)
    SET @sqltxt = 'SELECT @Seria = IsNull(Ope_SymbolDlaNumeracji, '''') FROM [' + @ServerName + '].[' + @ConfigDBName + '].CDN.Operatorzy WHERE Ope_OpeID = ' + convert(varchar(10), @OpeId, 0)
    EXEC sp_executesql @sqltxt, N'@Seria nvarchar(5) OUTPUT', @Seria OUTPUT
   END
   ELSE
    SELECT @Seria = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1851
   IF CHARINDEX('@katalog', @DDf_Numeracja) > 0
   BEGIN
    IF @DokTyp = 999 OR @DokTyp = 1003 -- RejVat lub EwidDod
    BEGIN
     DECLARE @klasa INT
     IF @DokTyp = 999 AND @zakspr = 1      -- RejVat zak
      SELECT @Klasa = 750099901
     ELSE IF @DokTyp = 999 AND @zakspr = 2   -- RejVat spr
      SELECT @Klasa = 750099902
     ELSE IF @DokTyp = 1003 AND @zakspr = 101  -- EwidDod zak
      SELECT @Klasa = 750100301
     ELSE IF @DokTyp = 1003 AND @zakspr = 102  -- EwidDod spr
      SELECT @Klasa = 750100302
     SELECT @Katalog = IsNull(Ktl_Symbol, '') FROM cdn.DokDefinicje JOIN cdn.Katalogi ON Ktl_KtlId = DDf_KatalogObdId WHERE DDf_Klasa = @klasa
    END
    ELSE
     SELECT @Katalog = IsNull(Ktl_Numeracja, 0) FROM cdn.Katalogi WHERE Ktl_Domyslny = 1
   END
   ELSE
    SELECT @Katalog = ''
   SET @DoN_NumerString = @DDf_Numeracja
   SET @DoN_NumerString = REPLACE(@DoN_NumerString, '@symbol' , @DDf_Symbol)
   SET @DoN_NumerString = REPLACE(@DoN_NumerString, '@rok_kal', @RokKal)
   SET @DoN_NumerString = REPLACE(@DoN_NumerString, '@rok_obr', @RokObr)
   SET @DoN_NumerString = REPLACE(@DoN_NumerString, '@miesiac', @Miesiac)
   SET @DoN_NumerString = REPLACE(@DoN_NumerString, '@rejestr', @Seria)
   SET @DoN_NumerString = REPLACE(@DoN_NumerString, '@katalog', @Katalog)
   SET @DoN_NumerString = REPLACE(@DoN_NumerString, '@brak/'  , '')
   SET @DoN_NumerString = REPLACE(@DoN_NumerString, '/@brak'  , '')
   SET @DoN_NumerString = CONVERT(NVARCHAR(31), @DoN_NumerString)
   IF SUBSTRING(REVERSE(@DoN_NumerString),1,1) = '/'
    SET @DoN_NumerString = SUBSTRING (@DoN_NumerString, 1, LEN(@DoN_NumerString) - 1 )
  END
-- END
  IF @DDfID IS NULL
  BEGIN
   RAISERROR('##OPT33116##', 16, 1) --RAISERROR('Brak schematu numeracji dokumentów OBD w bazie.', 16, 1)
   RETURN
  END
  --IF @DoN_NumerNr Is NULL OR EXISTS(SELECT * FROM CDN.DokNag WHERE DoN_NumerString = @DoN_NumerString AND DoN_NumerNr = @DoN_NumerNr)
   SELECT @DoN_NumerNr = IsNull(MAX(DoN_NumerNr), 0) + 1 FROM CDN.DokNag WHERE DoN_NumerString = @DoN_NumerString
  DECLARE @dokNagWasCreated INT
  SET @dokNagWasCreated = 0
  DECLARE @maxLen INT
  SELECT @maxLen = character_maximum_length FROM INFORMATION_SCHEMA.COLUMNS
  where UPPER(TABLE_NAME) = 'doknag' AND UPPER(column_name) = 'DON_DOTYCZY'
  DECLARE @dotyczy NVARCHAR(4000)
  SELECT @dotyczy = NULL
  IF @DoN_Dotyczy Is NOT NULL OR @DoN_NumerPelny Is NOT NULL
  BEGIN
   IF IsNull(@DoN_Dotyczy, '') <> ''
    SELECT @dotyczy = @DoN_Dotyczy
   IF IsNull(@DoN_NumerPelny, '') <> ''
   BEGIN
    IF @dotyczy Is NULL
     SELECT @dotyczy = @DoN_NumerPelny
    ELSE
     SELECT @dotyczy = @dotyczy + ' ' + @DoN_NumerPelny
   END
   SELECT @dotyczy = SUBSTRING(@dotyczy, 1, @maxLen);
  END
  DECLARE @KtlID INT
  IF @DoN_Katalog Is Not Null
   SELECT @KtlID = Ktl_KtlID FROM cdn.Katalogi WHERE Ktl_Symbol = @DoN_Katalog
  IF @KtlID Is Null
   SELECT @KtlID = Ktl_KtlID FROM cdn.Katalogi WHERE Ktl_Domyslny = 1
  INSERT
  INTO CDN.DokNag
  (
   DoN_DDfId,
   DoN_NumerString,
   DoN_NumerNr,
   DoN_NumerObcy,
   DoN_DataDok,
   DoN_Tytul,
   DoN_Dotyczy,
   DoN_Typ,
   DoN_Katalog,
   DoN_Status,
   DoN_OriginId,
   DoN_ProcesKod,
   DoN_EtapBiezacyLp,
   DoN_OpiekunTyp,
   DoN_OpiekunID,
   DoN_OpeZalID,
   DoN_OpeZalKod,
   DoN_OpeZalNazwisko,
   DoN_StaZalId,
   DoN_TS_Zal,
   DoN_OpeModID,
   DoN_OpeModKod,
   DoN_OpeModNazwisko,
   DoN_StaModId,
   DoN_TS_Mod,
   DoN_ImportAppID,
   DoN_ImportRowID
  )
  VALUES
  (
   @DDfID,
   @DoN_NumerString,
   @DoN_NumerNr,
   IsNull(@DoN_NumerObcy, ''),
   @DataDok,
   @DoN_Tytul,
   @dotyczy,
   IsNull(@DoN_Typ, 1),
   @KtlID,
   @DoN_Status,
   @DoN_OriginId,
   '', -- DoN_ProcesKod
   0, -- DoN_EtapBiezacyLp
   8, -- DoN_OpiekunTyp
   @OpeID, -- DoN_OpiekunID
   @OpeID,
   @OpeModKod,
   @OpeModNazwisko,
   NULL,
   GETDATE(),
   @OpeID,
   @OpeModKod,
   @OpeModNazwisko,
   NULL,
   GETDATE(),
   @ZrdID,
   @DoN_ImportRowID
  )
  SET @IdParam = SCOPE_IDENTITY()
  SET @dokNagWasCreated = 1
 END
 ELSE
 BEGIN
  SELECT @DoNExists = 1
  SELECT @IdParam = DoN_DoNID FROM CDN.DokNag WHERE DoN_ImportRowID = @DoN_ImportRowID
 END
 DECLARE @DoNTyp INT
 DECLARE @DoNNumerPelny NVARCHAR(256)
 SELECT @DoNTyp = DoN_Typ, @DoNNumerPelny = DoN_NumerPelny FROM cdn.DokNag WHERE DoN_DoNID = @IdParam
 DECLARE @Operacja INT
 SELECT @Operacja = CASE WHEN @DoNExists=1 THEN 1 ELSE 2 END
 IF @dokNagWasCreated = 1
 BEGIN
  EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 750, -- e_op_KlasaSEK
   @ObiektSubTyp = @DoNTyp,
   @ObiektID = @IdParam,
   @ObiektNazwa = @DoNNumerPelny,
   @OperacjaTyp = @Operacja,
   @Opis = ''
 END
 DECLARE @DoNID INT
 SELECT @DoNID = @IdParam
 DECLARE @DoR_ParentTyp INT
 SELECT @DoR_ParentTyp = 750
 IF @DokTyp > 0 AND @DokId > 0   -- powiazanie do dokumentu nie jest obowiazkowe
 BEGIN
  -- Ponieważ procedura dla każdego dokumentu będzie wykonana tyle razy ile jest elementów w DokNagPliki podpiętych pod dany dokument OBD (DokNag),
  -- musimy podpiąć relację do DokNag tylko dla pierwszego pliku; inaczej byłaby duplikacja bo próbowalibyśmy podpiąć do dokumentu
  -- kilka razy ten sam dokument OBD.
  IF NOT EXISTS (SELECT * FROM CDN.DokRelacje
      WHERE DoR_ParentTyp = @DoR_ParentTyp AND DoR_ParentID = @DoNID AND DoR_DokumentTyp = @DokTyp AND DoR_DokumentId = @DokId)
  BEGIN
   INSERT INTO CDN.DokRelacje
   (
    DoR_ParentTyp,
    DoR_ParentId,
    DoR_DokumentTyp,
    DoR_DokumentId,
    DoR_Flaga
   )
   VALUES
   (
    @DoR_ParentTyp,
    @DoNID,
    @DokTyp,
    @DokId,
    0
   )
  END
 END
  IF @OCR = 1
  BEGIN
   IF @DnPID Is NOT NULL
   BEGIN
    IF @DokTyp = 999
     -- Rejestr VAT
     UPDATE CDN.VatNag SET VaN_DnPID = @DnPID WHERE VaN_VaNID = @DokId
    --ELSE IF @DokTyp = 1003
     -- Ewidencja dodatkowa
    -- UPDATE CDN.EwidDodNag SET EDN_DnPID = @DnPID WHERE EDN_EDNID = @DokId
   END
   RETURN
  END
 IF @PodTyp IS NOT NULL AND @PodID IS NOT NULL
   AND NOT EXISTS(SELECT * FROM CDN.DokPodmioty WHERE DoP_DoNID = @DoNID AND DoP_PodmiotTyp = @PodTyp AND DoP_PodmiotID = @PodID)
  INSERT INTO CDN.DokPodmioty (DoP_DoNID, DoP_PodmiotTyp, DoP_PodmiotID) VALUES(@DoNID, @PodTyp, @PodID)
  -- Linki do plików na dysku mają zostać przeniesione jako pliki zapisane w bazie.
  -- Ich zawartość została "wpruta" do XML-a podczas eksportu (klasa FileContentPtrField), a teraz będzie zapisana do bazy.
  -- DnP_WBazie ze stanu 0 w bazie źródłowej musi zatem przejść na 1 w docelowej, podobnie DnP_FileMode musi zmienić wartość z 1 na 2.
  -- Dla pliku zapisanego w bazie nie ma też sensu ścieżka do pliku
 IF @DnP_WBazie = 0
  SELECT @DnP_WBazie = 1, @DnP_FileMode = 2
 IF @DnP_Wersja IS NULL SELECT @DnP_Wersja = 1
 IF @DnP_Typ IS NULL SELECT @DnP_Typ = 2
 IF @DnP_Archiwalny IS NULL SELECT @DnP_Archiwalny = 0
 DECLARE @DnP_DataDok_DT DATETIME
 SELECT @DnP_DataDok_DT = CASE WHEN @DnP_DataDok IS NOT NULL THEN CONVERT(DATETIME, @DnP_DataDok, 120) ELSE GETDATE() END
 DECLARE @DnPID2 INT
 SELECT @DnPID2 = DnP_DnPID FROM CDN.DokNagPliki WHERE DnP_DoNID = @DoNID AND
  DnP_DataDok = @DnP_DataDok_DT AND
  DnP_WBazie = @DnP_WBazie AND DnP_Sciezka = @DnP_Sciezka AND DnP_NazwaPliku = @DnP_NazwaPliku AND DnP_FileMode = @DnP_FileMode AND
  DnP_Typ = @DnP_Typ AND DnP_Archiwalny = @DnP_Archiwalny AND DnP_Wersja = @DnP_Wersja
 IF @DnPID2 Is NULL
 BEGIN
  INSERT INTO CDN.DokNagPliki
  (
   DnP_DoNID,
   DnP_Wersja,
   DnP_FileMode,
   DnP_DataDok,
   DnP_Typ,
   DnP_Archiwalny,
   DnP_NazwaPliku,
   DnP_Sciezka,
   DnP_WBazie,
   DnP_StaEditId,
   DnP_OpeEditId,
   DnP_OpeZalID,
   DnP_OpeZalKod,
   DnP_OpeZalNazwisko,
   DnP_StaZalId,
   DnP_TS_Zal,
   DnP_OpeModID,
   DnP_OpeModKod,
   DnP_OpeModNazwisko,
   DnP_StaModId,
   DnP_TS_Mod
  )
  VALUES
  (
   @DoNID,
   @DnP_Wersja,
   @DnP_FileMode,
   @DnP_DataDok_DT,
   @DnP_Typ,
   @DnP_Archiwalny,
   @DnP_NazwaPliku,
   @DnP_Sciezka,
   @DnP_WBazie,
   NULL,
   NULL,
   @OpeID,
   @OpeModKod,
   @OpeModNazwisko,
   NULL,
   GETDATE(),
   @OpeID,
   @OpeModKod,
   @OpeModNazwisko,
   NULL,
   GETDATE()
  )
  SET @DnPID2 = SCOPE_IDENTITY()
 END
   -- Jeśli @DnP_WBazie = 1 (zawartość pliku ma być w bazie) lub 2 (zawartość pliku ma być w iBard24, a tylko link w bazie) to trzeba dodać odpowiednią dana binarną
 IF @DnP_WBazie <> 0
 BEGIN
  IF(NOT EXISTS(SELECT * FROM CDN.DaneBinarne WHERE DAB_Typ = (CASE WHEN @DAB_Typ Is NOT NULL THEN @DAB_Typ ELSE 2 END) AND DAB_TwAID = @DnPID2))
  BEGIN
   DECLARE @decoded VARBINARY(max)
   IF @DAB_Wartosc Is NOT Null
    SET @decoded = cast('' as xml).value('xs:base64Binary(sql:variable(''@DAB_Wartosc''))', 'varbinary(max)')
   ELSE
    SET @decoded = NULL -- tylko link do pliku zapisanego w iBard24
   INSERT INTO CDN.DaneBinarne
   (
    --DAB_ImportRowID,
    DAB_MagazynDanych,
    DAB_MagazynDanychId,
    DAB_Typ,
    DAB_Flaga,
    DAB_TwAID,
    DAB_Wartosc,
    DAB_Rozmiar,
    DAB_NazwaPliku,
    DAB_Nazwa,
    DAB_Rozszerzenie,
    DAB_Sciezka,
    DAB_Wersja,
    DAB_IBard24Id,
    DAB_IBard24LinkPrywatny,
    DAB_OpeZalID,
    DAB_OpeZalKod,
    DAB_OpeZalNazwisko,
    DAB_StaZalId,
    DAB_TS_Zal,
    DAB_OpeModID,
    DAB_OpeModKod,
    DAB_OpeModNazwisko,
    DAB_StaModId,
    DAB_TS_Mod
   )
   VALUES
   (
    --@DAB_ImportRowID,
    CASE WHEN @DAB_MagazynDanych Is NOT NULL THEN @DAB_MagazynDanych ELSE @DnP_WBazie END,
    @DAB_MagazynDanychID,
    CASE WHEN @DAB_Typ Is NOT NULL THEN @DAB_Typ ELSE 2 END,
    @DAB_Flaga,
    @DnPID2,
    @decoded,
    CASE WHEN IsNull(@DAB_MagazynDanych, 1) = 1 AND @DAB_Rozmiar IS NULL THEN 0 ELSE @DAB_Rozmiar END,
    CASE WHEN @DAB_NazwaPliku Is NOT NULL THEN @DAB_NazwaPliku ELSE @DnP_NazwaPliku END,
    @DAB_Nazwa,
    @DAB_Rozszerzenie,
    CASE WHEN @DnP_WBazie = 1 THEN '' ELSE (CASE WHEN @DAB_Sciezka Is NOT NULL THEN @DAB_Sciezka ELSE @DnP_Sciezka END) END,
    @DAB_Wersja,
    @DAB_IBard24ID,
    @DAB_IBard24LinkPrywatny,
    @OpeID,
    @OpeModKod,
    @OpeModNazwisko,
    NULL,
    GETDATE(),
    @OpeID,
    @OpeModKod,
    @OpeModNazwisko,
    NULL,
    GETDATE()
   )
  END
 --ELSE -- IF @DnP_WBazie = 0
  -- Jeśli @DnP_WBazie = 0 (zawartość pliku w pliku na dysku) - takiej sytuacji nie będzie, bo zawartość eksportowanych plików na dysku przenosimy do importowanej bazy
 END
END
