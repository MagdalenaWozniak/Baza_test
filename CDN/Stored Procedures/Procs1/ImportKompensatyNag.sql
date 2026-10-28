CREATE PROCEDURE CDN.ImportKompensatyNag
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@KPN_ImportRowID nvarchar(36),
@DDf_ImportRowID nvarchar(36),
@DDf_Symbol nvarchar(5),
@DDf_Numeracja nvarchar(50),
@KPN_NumerString nvarchar(50),
@KPN_NumerNr int,
@KPN_NumerPelny nvarchar(50),
@KPN_NumerObcy nvarchar(256),
@KPN_DataDok nvarchar(10),
@Pod_TypOpis nvarchar(20),
@Pod_Kod nvarchar(20),
@Pod_ImportRowId nvarchar(36),
@Pod_NIP nvarchar(20),
@Kat_ImportRowID nvarchar(36),
@Kat_KodSzczegol nvarchar(20),
@KPN_Kategoria nvarchar(50),
@KPN_Waluta nvarchar(3),
@KPN_KontoWn nvarchar(50),
@KPN_KontoMa nvarchar(50),
@KPN_Opis nvarchar(256),
@KPN_RazemKwotaRoz DECIMAL(15,2),
@ZrdID nvarchar(5),
@OpeID int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @DDfID INT
 DECLARE @KatID INT
 DECLARE @PodTyp INT
 DECLARE @PodId INT
 DECLARE @notUsed INT
 DECLARE @Error nvarchar(256)
 IF((SELECT count(*)
  FROM CDN.KompensatyNag
  WHERE KPN_ImportRowID = @KPN_ImportRowID) = 0)
 BEGIN
  SET @Warnings = ''
  SET @DDfID = NULL
  IF(@DDf_ImportRowID is not NULL)
  BEGIN
   SELECT @DDfID = DDf_DDfId
   FROM CDN.DokDefinicje
   WHERE DDf_ImportRowID = @DDf_ImportRowID AND DDf_Numeracja = @DDf_Numeracja
  END
  IF @DDfID is NULL
  BEGIN
   SELECT @DDfID = DDf_DDfID
   FROM CDN.DokDefinicje
   WHERE DDf_Symbol = @DDf_Symbol AND DDf_Numeracja = @DDf_Numeracja
  END
  IF @DDfID is NULL
  BEGIN
   -- SET @Warnings = 'Brak definicji dokumentu o zadanym symbolu i zgodnym schemacie numeracji ' + IsNull(@DDf_Symbol, '') + ' w bazie docelowej.\'
   RAISERROR('##OPT33084##', 16, 1) --RAISERROR('Brak zgodnego schematu numeracji w bazie.', 16, 1)
   RETURN
  END
  IF(@Kat_ImportRowID is not NULL OR @Kat_KodSzczegol is not NULL)
  BEGIN
   SET @KatId = NULL
   SELECT @KatId = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_ImportRowId = @Kat_ImportRowID
   IF @KatId is NULL
   BEGIN
    SELECT @KatID = Kat_KatID
    FROM CDN.Kategorie
    WHERE Kat_KodSzczegol = @Kat_KodSzczegol
    IF @KatId is NULL
     --SET @Warnings = @Warnings + 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria nie została zaimportowana.\'
     SET @Warnings = @Warnings + '##OPT33150##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
   END
  END
  EXEC CDN.GetPodmiotDlaPracyRozproszonej @Pod_TypOpis, @Pod_Kod, @Pod_ImportRowId, @Pod_NIP, 1, @PodID OUTPUT, @PodTyp OUTPUT, @notUsed OUTPUT, @Warnings OUTPUT
  INSERT
  INTO CDN.KompensatyNag
  (
  KPN_DDfID,
  KPN_NumerString,
  KPN_NumerNr,
  KPN_NumerObcy,
  KPN_DataDok,
  KPN_PodmiotTyp,
  KPN_PodmiotID,
  KPN_KatID,
  KPN_Kategoria,
  KPN_Waluta,
  KPN_KontoWn,
  KPN_KontoMa,
  KPN_Opis,
  KPN_RazemKwotaRoz,
  KPN_OpeZalID,
  KPN_OpeZalKod,
  KPN_OpeZalNazwisko,
  KPN_StaZalId,
  KPN_TS_Zal,
  KPN_OpeModID,
  KPN_OpeModKod,
  KPN_OpeModNazwisko,
  KPN_StaModId,
  KPN_TS_Mod,
  KPN_ImportAppID,
  KPN_ImportRowID
  )
  VALUES
  (
  @DDfID,
  @KPN_NumerString,
  @KPN_NumerNr,
  @KPN_NumerObcy,
  CONVERT(datetime, @KPN_DataDok, 120),
  @PodTyp,
  @PodID,
  @KatID,
  @KPN_Kategoria,
  @KPN_Waluta,
  @KPN_KontoWn,
  @KPN_KontoMa,
  @KPN_Opis,
  @KPN_RazemKwotaRoz,
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
  @KPN_ImportRowID
  )
  SET @IdParam = SCOPE_IDENTITY()
  DECLARE @NumerDok NVARCHAR(256)
  SET @NumerDok = (SELECT KpN_NumerPelny FROM cdn.KompensatyNag WHERE KpN_KpNID = @IdParam)
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1145, -- OptimaObjectType_Kompensata
    @ObiektSubTyp = 0,
    @ObiektID = @IdParam,
    @ObiektNazwa = @NumerDok,
    @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
    @Opis = '' --@KPN_Opis
 END
 ELSE
 BEGIN
  SET @Error = @KPN_NumerPelny + '. Taki dokument już istnieje w bazie.'
  RAISERROR('##OPT33077##%%dokument%%=%s##', 16, 1, @KPN_NumerPelny) --RAISERROR( @Error, 16, 1)
 END
END
