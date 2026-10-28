CREATE PROCEDURE CDN.ImportFormy
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@FPl_ImportRowId nvarchar(36),
@FPl_Nazwa nvarchar(20),
@FPl_Typ int,
@BRa_Symbol nvarchar(5),
@BRa_ImportRowId nvarchar(36),
@FPl_Termin smallint,
@FPl_PodmiotTyp nvarchar(10),
@FPl_PodmiotKod nvarchar(20),
@FPl_PodmiotImportRowID nvarchar(36),
@FPl_PodmiotNIP nvarchar(20),
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @BRa_Id int
 DECLARE @FPl_Id int
 DECLARE @PodmiotTyp int
 DECLARE @PodmiotID int
 DECLARE @OperationType INT
 SET @OperationType = 0
 SET @Warnings = ''
 IF(@BRa_ImportRowId is NULL or @BRa_ImportRowId = '')
  SELECT @BRa_Id = BRa_BRaId
  FROM CDN.BnkRachunki
  WHERE BRa_Symbol = @BRa_Symbol
 ELSE
  SELECT @BRa_Id = BRa_BRaId
  FROM CDN.BnkRachunki
  WHERE BRa_ImportRowId = @BRa_ImportRowId
 IF(@BRa_Id is NULL)
 BEGIN
  --SET @Warnings = 'Nie znaleziono rejestru w bazie.\'
  SET @Warnings = '##OPT33192##\'
 END
 SET @PodmiotTyp = NULL;
 SET @PodmiotID = NULL;
 IF @FPl_PodmiotTyp = 'kontrahent'
 BEGIN
  DECLARE @notUsed INT
  EXEC CDN.GetPodmiotDlaPracyRozproszonej  @FPl_PodmiotTyp, @FPl_PodmiotKod, @FPl_PodmiotImportRowID, @FPl_PodmiotNIP, 3, @PodmiotID OUTPUT, @PodmiotTyp OUTPUT, @notUsed OUTPUT, @Warnings OUTPUT
 END
 ELSE IF @FPl_PodmiotTyp = 'bank'
 BEGIN
  SELECT @PodmiotID = BNa_BNaID FROM CDN.BnkNazwy WHERE ISNULL(@FPl_PodmiotImportRowID,'') <> '' AND BNa_ImportRowID = @FPl_PodmiotImportRowID
  IF @PodmiotID IS NULL
   SELECT @PodmiotID = BNa_BNaID FROM CDN.BnkNazwy WHERE BNa_Akronim = @FPl_PodmiotKod
  IF @PodmiotID IS NOT NULL
    SET @PodmiotTyp = 2
 END
 ELSE IF @FPl_PodmiotTyp = 'pracownik'
 BEGIN
  SELECT @PodmiotID = Pra_PraID FROM CDN.PracKod WHERE ISNULL(@FPl_PodmiotImportRowID,'') <> '' AND Pra_ImportRowID = @FPl_PodmiotImportRowID
  IF @PodmiotID IS NULL
   SELECT @PodmiotID = Pra_PraID FROM CDN.PracKod WHERE Pra_Kod = @FPl_PodmiotKod
  IF @PodmiotID IS NOT NULL
   SELECT @PodmiotID = PRE_PREID FROM CDN.PracEtaty WHERE PRE_PraID = @PodmiotID AND PRE_DataDo=Convert(datetime,'2999-12-31',121)
  IF @PodmiotID IS NOT NULL
    SET @PodmiotTyp = 3
 END
 ELSE IF @FPl_PodmiotTyp = 'US' OR @FPl_PodmiotTyp = 'ZUS'
 BEGIN
  SELECT @PodmiotID = Urz_UrzID FROM CDN.Urzedy WHERE ISNULL(@FPl_PodmiotImportRowID,'') <> '' AND Urz_ImportRowID = @FPl_PodmiotImportRowID
  IF @PodmiotID IS NULL
   SELECT @PodmiotID = Urz_UrzID FROM CDN.Urzedy WHERE Urz_Akronim = @FPl_PodmiotKod
  IF @PodmiotID IS NOT NULL
    SET @PodmiotTyp = 5
 END
 IF @FPl_PodmiotTyp Is Not Null AND @PodmiotID IS NULL
 begin
  --SET @Warnings = @Warnings + 'Brak podmiotu ' + IsNull(@FPl_PodmiotKod, '') + ' w bazie docelowej. Formę zapisano bez ustawienia płatnika.\'
  SET @Warnings = @Warnings + '##OPT33193##%%podmiot%%=' +  IsNull(@FPl_PodmiotKod, '') + '##\';
 end
 If((SELECT count(*)
  FROM CDN.FormyPlatnosci
  WHERE (IsNull(@FPl_ImportRowId, '') <> '' AND  FPl_ImportRowId = @FPl_ImportRowId)
    OR (IsNull(@FPl_ImportRowId, '') = '' AND FPl_Nazwa = @FPl_Nazwa))=0)
 BEGIN
  INSERT INTO CDN.FormyPlatnosci
  (
  FPl_ImportRowId,
  FPl_Nazwa,
  FPl_Typ,
  FPl_BRaId,
  FPl_Termin,
  FPl_PodmiotTyp,
  FPl_PodmiotID,
  FPl_Rabat,
  Fpl_NieAktywny,
  Fpl_TS_Export,
  Fpl_ImportAppId
  )
  VALUES
  (
  @FPl_ImportRowId,
  @FPl_Nazwa,
  @FPl_Typ,
  @BRa_Id,
  @FPl_Termin,
  @PodmiotTyp,
  @PodmiotID,
  0,
  0,
  GETDATE(),
  @ZrdId
  )
  SET @SlowId = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
 END ELSE IF (@OnlyNew <> 1)
 BEGIN
  UPDATE  CDN.FormyPlatnosci
  SET
   FPl_Nazwa = @FPl_Nazwa,
   Fpl_Typ = @FPl_Typ,
   FPl_BRaId = @BRa_Id,
   FPl_Termin = @FPl_Termin
  WHERE (IsNull(@FPl_ImportRowId, '') <> '' AND  FPl_ImportRowId = @FPl_ImportRowId)
    OR (IsNull(@FPl_ImportRowId, '') = '' AND FPl_Nazwa = @FPl_Nazwa)
  SELECT @SlowId = Fpl_FplId
  FROM CDN.FormyPlatnosci
  WHERE (IsNull(@FPl_ImportRowId, '') <> '' AND  FPl_ImportRowId = @FPl_ImportRowId)
    OR (IsNull(@FPl_ImportRowId, '') = '' AND FPl_Nazwa = @FPl_Nazwa)
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
 END
 ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1100, -- OptimaObjectType_FormaPlatnosci
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @FPl_Nazwa,
    @OperacjaTyp = @OperationType,
    @Opis = ''
END
