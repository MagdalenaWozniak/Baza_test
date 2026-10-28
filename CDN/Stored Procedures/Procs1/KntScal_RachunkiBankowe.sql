CREATE PROCEDURE CDN.KntScal_RachunkiBankowe
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 IF EXISTS(SELECT * FROM CDN.SchematPlatnosci D WHERE D.SPL_PodmiotTyp = 1 AND D.SPL_PodmiotID = @KntPodID
       AND NOT EXISTS (SELECT * FROM cdn.SchematPlatnosci G WHERE G.Spl_PodmiotTyp = 1 AND G.SPl_PodmiotId = @KntNadID AND G.SPL_RachunekNr0 = D.SPL_RachunekNr0))
 BEGIN
  DECLARE @SplID INT
  DECLARE @Opis NVARCHAR(50)
  DECLARE @OdbPodmiotTyp INT
  DECLARE @OdbPodmiotID INT
  DECLARE @FplId INT
  DECLARE @BnaId INT
  DECLARE @RachunekNr NVARCHAR(51)
  DECLARE @RachunekNr0 NVARCHAR(51)
  DECLARE @IBAN TINYINT
  DECLARE @Rodzaj SMALLINT
  DECLARE @Kwota DECIMAL(14,2)
  DECLARE @Procent DECIMAL(14,2)
  DECLARE @LiczbaPorz INT
  DECLARE @StaModId INT
  DECLARE @OpeZalID INT
  DECLARE @TS_Zal DATETIME
  DECLARE @OpeModID INT
  DECLARE @TS_Mod DATETIME
  declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
  declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
  IF EXISTS(SELECT SPl_SplID FROM CDN.SchematPlatnosci D WHERE D.SPL_PodmiotTyp = 1 AND D.SPL_PodmiotID = @KntPodID
        AND NOT EXISTS (SELECT * FROM cdn.SchematPlatnosci G WHERE G.Spl_PodmiotTyp = 1 AND G.SPl_PodmiotId = @KntNadID AND G.SPL_RachunekNr0 = D.SPL_RachunekNr0))
  BEGIN
   DECLARE @KntNadKod NVARCHAR(20)
   DECLARE @KntPodKod NVARCHAR(20)
   SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
   SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
   DECLARE @cnt0 INT
   SELECT @cnt0 = COUNT(*) FROM cdn.SchematPlatnosci WHERE SPL_PodmiotTyp = 1 AND SPL_PodmiotID = @KntNadID
   ALTER TABLE cdn.SchematPlatnosci DISABLE TRIGGER ALL
   DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT D.SPL_SplID, D.SPL_Opis, D.SPL_OdbPodmiotTyp, D.SPL_OdbPodmiotID, D.SPL_FplId, D.SPL_BnaId, D.SPL_RachunekNr, D.SPL_IBAN, D.SPL_Rodzaj, D.SPL_Kwota, D.SPL_Procent, D.SPL_LiczbaPorz,
     D.SPL_StaModId, D.SPL_OpeZalID, D.SPL_OpeZalKod, D.SPL_OpeZalNazwisko, D.SPL_TS_Zal, D.SPL_OpeModID, D.SPL_OpeModKod, D.SPL_OpeModNazwisko, D.SPL_TS_Mod
    FROM CDN.SchematPlatnosci D WHERE D.SPL_PodmiotTyp = 1 AND D.SPL_PodmiotID = @KntPodID
         AND NOT EXISTS (SELECT * FROM cdn.SchematPlatnosci G WHERE G.Spl_PodmiotTyp = 1 AND G.SPl_PodmiotId = @KntNadID AND G.SPL_RachunekNr0 = D.SPL_RachunekNr0)
   OPEN c
   DECLARE @i INT
   SELECT @i = 1
   WHILE 1=1
   BEGIN
    FETCH NEXT FROM c INTO @SplID, @Opis, @OdbPodmiotTyp, @OdbPodmiotID, @FplId, @BnaId, @RachunekNr, @IBAN, @Rodzaj, @Kwota, @Procent, @LiczbaPorz, @StaModId, @OpeZalID, @OpeZalKod, @OpeZalNazwisko, @TS_Zal, @OpeModID, @OpeModKod, @OpeModNazwisko, @TS_Mod
    IF @@fetch_status <> 0
     BREAK
    DECLARE @reszta TINYINT
    SELECT @reszta = CASE WHEN @cnt0 = 0 AND @i = 1 THEN 1 ELSE 0 END
    INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
         VALUES ('cdn.SchematPlatnosci', @SplID, @Opis, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod)
    INSERT INTO cdn.SchematPlatnosci
     (SPl_Opis, SPl_PodmiotTyp, SPl_PodmiotID, SPL_OdbPodmiotTyp, SPL_OdbPodmiotID, SPL_FplId, SPL_BnaId, SPL_RachunekNr, SPl_IBAN,
     SPL_Rodzaj, SPL_Kwota, SPL_Procent, SPL_LiczbaPorz, SPL_Reszta, SPL_StaModId, SPL_OpeZalID, SPL_OpeZalKod, SPL_OpeZalNazwisko, SPL_TS_Zal, SPL_OpeModID, SPL_OpeModKod, SPL_OpeModNazwisko, SPL_TS_Mod)
     VALUES(@Opis, 1, @KntNadID, @OdbPodmiotTyp, @OdbPodmiotID, @FplId, @BnaId, @RachunekNr, @IBAN,
     @Rodzaj, @Kwota, @Procent, @LiczbaPorz, @reszta, @StaModId, @OpeZalID, @OpeZalKod, @OpeZalNazwisko, @TS_Zal, @OpeModID, @OpeModKod, @OpeModNazwisko, @TS_Mod)
    SELECT @i = @i + 1
   END
   CLOSE c
   DEALLOCATE c
   ALTER TABLE cdn.SchematPlatnosci ENABLE TRIGGER ALL
  END
 END
 SET NOCOUNT OFF
