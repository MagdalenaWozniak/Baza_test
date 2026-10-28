create procedure cdn.ImportTypyWyplat
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Twp_PdpId int,       -- stałe ID (cdn.PozDeklPIT)
@Twp_PdzId int,       -- stałe ID (cdn.PozDeklZUS)
--@Twp_ParentId int,     -- Nie przenosić
@Twp_ImportRowId varchar(36),
@Twp_Nazwa varchar(40),
@Twp_Nazwa2 nvarchar(50),
@Twp_NazwaPelna nvarchar(127),
@Twp_Skrot nvarchar(40),
@Twp_Skrot2 nvarchar(50),
@Twp_RodzajZrodla int,     -- int
@Twp_ZalPodat int,      -- enums/nieużyw.
@Twp_ImPrzelZalPodat tinyint,   -- nieużyw.
@Twp_Koszty int,      -- enums
@Twp_KodRNA int,      -- 0
@Twp_SklZUS int,      -- Radio
@Twp_SklZdrow int,      -- Radio
@Twp_NiePomniejszZdrow tinyint,   -- Check
@Twp_Korygowana tinyint,    -- Check
@Twp_WchodziDoWyplaty tinyint,   -- Check
@Twp_UwzglMin tinyint,     -- Check
@Twp_UwzglNadgodz tinyint,    -- Check
@Twp_OkresWyplaty int,     -- ?  enums
@Twp_WplywaZalPodat tinyint,   -- Check
@Twp_WliczUrlop int,     -- Radio
@Twp_WliczChor int,      -- Radio
@Twp_WliczEkwiwal int,     -- Radio
@Twp_StOkrWartosc nvarchar(41),
@Twp_StOkrTyp int,      -- stała
@Twp_ZaOkrZwolLek tinyint,    -- Check
@Twp_AlgAlgorytm int,
@Twp_AlgPotracenie tinyint,    -- Check
@Twp_AlgZaokraglenie decimal(15, 2),
@Twp_AlgPotrNieobec tinyint,   -- Check
@Twp_AlgOdchylki tinyint,    -- Check
@Twp_AlgProcWynagr decimal(15, 2),
@Twp_AlgStaz tinyint,     -- ?  int
@Twp_AlgStOkrTyp int,     -- ?  int
@Twp_AlgStOkrWartosc nvarchar(41),
@Twp_AlgWspolcz decimal(15, 2),
@Twp_AlgLiczbaDni int,
@Twp_AlgLiczbaGodz int,
@Twp_AlgBrutto tinyint,     -- ?  enums
@Twp_AlgUrlop tinyint,     -- ?  int
@Twp_AlgAutomat tinyint,    -- ?  int
@Twp_AlgProcent decimal(15, 2),
@Twp_AlgKwota decimal(15, 2),
@Twp_AlgUzyjKwota tinyint,    -- ?  int
@Twp_AlgStdWspolcz tinyint,    -- Check
@Twp_AlgIlosc decimal(15, 2),
@Twp_AlgIloscMies int,
@Twp_AlgStdIloscMies tinyint,   -- ?  0/1
@Twp_KosztyProc decimal(15, 2),
@Twp_Zmienna1 nvarchar(128),
@Twp_Zmienna2 nvarchar(128),
@Twp_AktPoWyp1 tinyint,     -- ?  0/1
@Twp_AktPoWyp2 tinyint,     -- ?  0/1
@Twp_PriorytetZUS smallint,
@Twp_PriorytetFIS smallint,
@Twp_PriorytetKoszty smallint,
@Twp_RodzajFIS smallint,    -- Radio
@Twp_Kategoria int,      -- ?  int
@Twp_Podstawowe tinyint,    -- ?  int
@Twp_Standardowy smallint,
@Twp_Zasadnicze tinyint,    -- ?  0/1
@Twp_RodzajPotracenia tinyint,   -- ?  int
@Twp_Wycofany tinyint,     -- ?  0
@Twp_AlgSposobZaokr tinyint,   -- ?  enums
@Twp_Priorytet int,
@Twp_AlgStOkrPlusTyp int,
@Twp_AlgStOkrPlusWartosc nvarchar(40),
@Twp_AlgStazSposob tinyint,    -- Radio
@Twp_Ulga smallint,      -- ?  0/1
--@Twp_WzrId int,      -- Można nie przenosić
@Twp_AlgWzorzec nvarchar(2048),
@Twp_AlgRodzaj12 smallint,    -- Radio
@Twp_AlgSposobPomn smallint,   -- Radio
@Twp_Nieaktywny tinyint,    -- Check
@Twp_AlgPodstDzielGodz tinyint,   -- Check
@Twp_AlgGodziny nvarchar(19),
@Twp_WliczPFRON tinyint,    -- Check
@Twp_KosztFirma tinyint,    -- Check
@Twp_OpisAnalitCzasPracy tinyint,  -- Check
@Twp_Kopia int,       -- ?  null
@Twp_PozycjaRP7 int,     -- Radio
@Twp_Wskaznik tinyint,     -- Check
@Twp_Umowa tinyint,      -- Radio
@Twp_WliczanyDoGUS smallint,   -- Check
@Twp_ZalPodProc decimal(15, 2),
@Twp_PKZP tinyint,      -- Radio
@Twp_SwiadczFS tinyint,     -- ?
@Twp_TypWaluty tinyint,     -- Radio
@Twp_NieZapisujZerowego tinyint,  -- Check
@Twp_AlgIloscMiesWszystkie tinyint,  -- ?
@Twp_AlgGodzinyDni tinyint,    -- ?
@Twp_ZajecieWynagr tinyint,    -- Check
@Twp_DoliczNaKoncu tinyint,    -- Check
@Twp_AlgKnfWspolcz tinyint,    -- Check
@Twp_WliczChorPodwojnie tinyint,    -- Check
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int output,
@Warnings nvarchar(1000) output
as
 begin
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @OperationType INT
 SET @OperationType = 0
    DECLARE @Twp_AlgGodzinyDT DATETIME
    SELECT @Twp_AlgGodzinyDT = CASE WHEN @TWp_AlgGodziny is Null THEN CONVERT(DATETIME, '1899-12-30 00:00:00', 120) WHEN @TWp_AlgGodziny = '1899-12-30' THEN cdn.Minutes2DateTime(0) ELSE cdn.Minutes2DateTime(@TWp_AlgGodziny) END
  if((select count(*) from cdn.TypWyplata
   where ((isnull(@Twp_ImportRowId, '') <> '' and TWP_ImportRowId = @Twp_ImportRowId) OR TWP_Nazwa = @Twp_Nazwa) or (isnull(@Twp_ImportRowId, '') = '' and TWP_Nazwa = @Twp_Nazwa)) = 0)
  begin
   insert into cdn.TypWyplata
   (
    TWP_PdpId,
    TWP_PdzId,
    -- TWP_ParentId,
    TWP_Nazwa,
    TWP_RodzajZrodla,
    TWP_ZalPodat,
    TWP_ImPrzelZalPodat,
    TWP_Koszty,
    TWP_KodRNA,
    TWP_SklZUS,
    TWP_SklZdrow,
    TWP_NiePomniejszZdrow,
    TWP_Korygowana,
    TWP_WchodziDoWyplaty,
    TWP_UwzglMin,
    TWP_UwzglNadgodz,
    TWP_OkresWyplaty,
    TWP_WplywaZalPodat,
    TWP_WliczUrlop,
    TWP_WliczChor,
    TWP_WliczEkwiwal,
    TWP_StOkrTyp,
    TWP_ZaOkrZwolLek,
    TWP_AlgAlgorytm,
    TWP_AlgPotracenie,
    TWP_AlgZaokraglenie,
    TWP_AlgPotrNieobec,
    TWP_AlgOdchylki,
    TWP_AlgProcWynagr,
    TWP_AlgStaz,
    TWP_AlgStOkrTyp,
    TWP_AlgWspolcz,
    TWP_AlgLiczbaDni,
    TWP_AlgLiczbaGodz,
    TWP_AlgBrutto,
    TWP_AlgUrlop,
    TWP_AlgAutomat,
    TWP_AlgProcent,
    TWP_AlgKwota,
    TWP_AlgUzyjKwota,
    TWP_AlgStdWspolcz,
    TWP_AlgIlosc,
    TWP_AlgIloscMies,
    TWP_AlgStdIloscMies,
    TWP_KosztyProc,
    TWP_AktPoWyp1,
    TWP_AktPoWyp2,
    TWP_PriorytetZUS,
    TWP_PriorytetFIS,
    TWP_PriorytetKoszty,
    TWP_RodzajFIS,
    TWP_Kategoria,
    TWP_Podstawowe,
    TWP_Standardowy,
    TWP_Zasadnicze,
    TWP_RodzajPotracenia,
    TWP_Wycofany,
    TWP_AlgSposobZaokr,
    TWP_Priorytet,
    TWP_AlgStOkrPlusTyp,
    TWP_AlgStazSposob,
    TWP_Ulga,
    -- TWP_WzrId,
    TWP_AlgRodzaj12,
    TWP_AlgSposobPomn,
    TWP_Nieaktywny,
    TWP_AlgPodstDzielGodz,
    TWP_AlgGodziny,
    TWP_WliczPFRON,
    TWP_KosztFirma,
    TWP_OpisAnalitCzasPracy,
    TWP_Kopia,
    TWP_PozycjaRP7,
    TWP_Wskaznik,
    TWP_Umowa,
    TWP_WliczanyDoGUS,
    TWP_ZalPodProc,
    TWP_PKZP,
    TWP_SwiadczFS,
    TWP_OpeZalId,
    TWP_OpeZalKod,
    TWP_OpeZalNazwisko,
    TWP_TS_Zal,
    TWP_OpeModId,
    TWP_OpeModKod,
    TWP_OpeModNazwisko,
    TWP_TS_Mod,
    TWP_AlgStOkrPlusWartosc,
    TWP_AlgStOkrWartosc,
    TWP_AlgWzorzec,
    TWP_Nazwa2,
    TWP_NazwaPelna,
    TWP_Skrot,
    TWP_Skrot2,
    TWP_StOkrWartosc,
    TWP_Zmienna1,
    TWP_Zmienna2,
    TWP_TypWaluty,
    TWP_NieZapisujZerowego,
    TWP_AlgIloscMiesWszystkie,
    TWP_AlgGodzinyDni,
        TWp_ZajecieWynagr,
        TWp_DoliczNaKoncu,
    TWP_AlgKnfWspolcz,
    TWP_WliczChorPodwojnie,
    TWP_ImportAppId,
    TWP_ImportRowId--,
    --TWP_TS_Export
   )
   values
   (
    @Twp_PdpId,
    @Twp_PdzId,
    -- @Twp_ParentId,
    @Twp_Nazwa,
    @Twp_RodzajZrodla,
    @Twp_ZalPodat,
    @Twp_ImPrzelZalPodat,
    @Twp_Koszty,
    @Twp_KodRNA,
    @Twp_SklZUS,
    @Twp_SklZdrow,
    @Twp_NiePomniejszZdrow,
    @Twp_Korygowana,
    @Twp_WchodziDoWyplaty,
    @Twp_UwzglMin,
    @Twp_UwzglNadgodz,
    @Twp_OkresWyplaty,
    @Twp_WplywaZalPodat,
    @Twp_WliczUrlop,
    @Twp_WliczChor,
    @Twp_WliczEkwiwal,
    @Twp_StOkrTyp,
    @Twp_ZaOkrZwolLek,
    @Twp_AlgAlgorytm,
    @Twp_AlgPotracenie,
    @Twp_AlgZaokraglenie,
    @Twp_AlgPotrNieobec,
    @Twp_AlgOdchylki,
    @Twp_AlgProcWynagr,
    @Twp_AlgStaz,
    @Twp_AlgStOkrTyp,
    @Twp_AlgWspolcz,
    @Twp_AlgLiczbaDni,
    @Twp_AlgLiczbaGodz,
    @Twp_AlgBrutto,
    @Twp_AlgUrlop,
    @Twp_AlgAutomat,
    @Twp_AlgProcent,
    @Twp_AlgKwota,
    @Twp_AlgUzyjKwota,
    @Twp_AlgStdWspolcz,
    @Twp_AlgIlosc,
    @Twp_AlgIloscMies,
    @Twp_AlgStdIloscMies,
    @Twp_KosztyProc,
    @Twp_AktPoWyp1,
    @Twp_AktPoWyp2,
    @Twp_PriorytetZUS,
    @Twp_PriorytetFIS,
    @Twp_PriorytetKoszty,
    @Twp_RodzajFIS,
    @Twp_Kategoria,
    @Twp_Podstawowe,
    @Twp_Standardowy,
    @Twp_Zasadnicze,
    @Twp_RodzajPotracenia,
    @Twp_Wycofany,
    @Twp_AlgSposobZaokr,
    @Twp_Priorytet,
    @Twp_AlgStOkrPlusTyp,
    @Twp_AlgStazSposob,
    @Twp_Ulga,
    -- @Twp_WzrId,
    @Twp_AlgRodzaj12,
    @Twp_AlgSposobPomn,
    @Twp_Nieaktywny,
    @Twp_AlgPodstDzielGodz,
        @Twp_AlgGodzinyDT,
    @Twp_WliczPFRON,
    @Twp_KosztFirma,
    @Twp_OpisAnalitCzasPracy,
    @Twp_Kopia,
    @Twp_PozycjaRP7,
    @Twp_Wskaznik,
    @Twp_Umowa,
    @Twp_WliczanyDoGUS,
    @Twp_ZalPodProc,
    @Twp_PKZP,
    @Twp_SwiadczFS,
    @OpeId,
    @OpeModKod,
    @OpeModNazwisko,
    getdate(),
    @OpeId,
    @OpeModKod,
    @OpeModNazwisko,
    getdate(),
    @Twp_AlgStOkrPlusWartosc,
    @Twp_AlgStOkrWartosc,
    @Twp_AlgWzorzec,
    @Twp_Nazwa2,
    @Twp_NazwaPelna,
    @Twp_Skrot,
    @Twp_Skrot2,
    @Twp_StOkrWartosc,
    @Twp_Zmienna1,
    @Twp_Zmienna2,
    @Twp_TypWaluty,
    @Twp_NieZapisujZerowego,
    @Twp_AlgIloscMiesWszystkie,
    @Twp_AlgGodzinyDni,
        @TWp_ZajecieWynagr,
        @TWp_DoliczNaKoncu,
    @Twp_AlgKnfWspolcz,
    @Twp_WliczChorPodwojnie,
    @ZrdID,
    @Twp_ImportRowId--,
    --getdate()
   )
   select @SlowID = SCOPE_IDENTITY()
   SET @OperationType = 1 -- OptimaOperationType_Dodanie
  end
  else
  begin
      if @OnlyNew <> 1
   begin
    SELECT @SlowID = TWP_TWPID FROM CDN.TypWyplata WHERE (isnull(@Twp_ImportRowId, '') <> '' and Twp_ImportRowId = @Twp_ImportRowId) or (isnull(@Twp_ImportRowId, '') = '' AND TWP_Nazwa = @Twp_Nazwa)
    update cdn.TypWyplata
     set
      TWP_PdpId = @Twp_PdpId,
      TWP_PdzId = @Twp_PdzId,
      -- TWP_ParentId = @Twp_ParentId,
      TWP_Nazwa = @Twp_Nazwa,
      TWP_RodzajZrodla = @Twp_RodzajZrodla,
      TWP_ZalPodat = @Twp_ZalPodat,
      TWP_ImPrzelZalPodat = @Twp_ImPrzelZalPodat,
      TWP_Koszty = @Twp_Koszty,
      TWP_KodRNA = @Twp_KodRNA,
      TWP_SklZUS = @Twp_SklZUS,
      TWP_SklZdrow = @Twp_SklZdrow,
      TWP_NiePomniejszZdrow = @Twp_NiePomniejszZdrow,
      TWP_Korygowana = @Twp_Korygowana,
      TWP_WchodziDoWyplaty = @Twp_WchodziDoWyplaty,
      TWP_UwzglMin = @Twp_UwzglMin,
      TWP_UwzglNadgodz = @Twp_UwzglNadgodz,
      TWP_OkresWyplaty = @Twp_OkresWyplaty,
      TWP_WplywaZalPodat = @Twp_WplywaZalPodat,
      TWP_WliczUrlop = @Twp_WliczUrlop,
      TWP_WliczChor = @Twp_WliczChor,
      TWP_WliczEkwiwal = @Twp_WliczEkwiwal,
      TWP_StOkrTyp = @Twp_StOkrTyp,
      TWP_ZaOkrZwolLek = @Twp_ZaOkrZwolLek,
      TWP_AlgAlgorytm = @Twp_AlgAlgorytm,
      TWP_AlgPotracenie = @Twp_AlgPotracenie,
      TWP_AlgZaokraglenie = @Twp_AlgZaokraglenie,
      TWP_AlgPotrNieobec = @Twp_AlgPotrNieobec,
      TWP_AlgOdchylki = @Twp_AlgOdchylki,
      TWP_AlgProcWynagr = @Twp_AlgProcWynagr,
      TWP_AlgStaz = @Twp_AlgStaz,
      TWP_AlgStOkrTyp = @Twp_AlgStOkrTyp,
      TWP_AlgWspolcz = @Twp_AlgWspolcz,
      TWP_AlgLiczbaDni = @Twp_AlgLiczbaDni,
      TWP_AlgLiczbaGodz = @Twp_AlgLiczbaGodz,
      TWP_AlgBrutto = @Twp_AlgBrutto,
      TWP_AlgUrlop = @Twp_AlgUrlop,
      TWP_AlgAutomat = @Twp_AlgAutomat,
      TWP_AlgProcent = @Twp_AlgProcent,
      TWP_AlgKwota = @Twp_AlgKwota,
      TWP_AlgUzyjKwota = @Twp_AlgUzyjKwota,
      TWP_AlgStdWspolcz = @Twp_AlgStdWspolcz,
      TWP_AlgIlosc = @Twp_AlgIlosc,
      TWP_AlgIloscMies = @Twp_AlgIloscMies,
      TWP_AlgStdIloscMies = @Twp_AlgStdIloscMies,
      TWP_KosztyProc = @Twp_KosztyProc,
      TWP_AktPoWyp1 = @Twp_AktPoWyp1,
      TWP_AktPoWyp2 = @Twp_AktPoWyp2,
      TWP_PriorytetZUS = @Twp_PriorytetZUS,
      TWP_PriorytetFIS = @Twp_PriorytetFIS,
      TWP_PriorytetKoszty = @Twp_PriorytetKoszty,
      TWP_RodzajFIS = @Twp_RodzajFIS,
      TWP_Kategoria = @Twp_Kategoria,
      TWP_Podstawowe = @Twp_Podstawowe,
      TWP_Standardowy = @Twp_Standardowy,
      TWP_Zasadnicze = @Twp_Zasadnicze,
      TWP_RodzajPotracenia = @Twp_RodzajPotracenia,
      TWP_Wycofany = @Twp_Wycofany,
      TWP_AlgSposobZaokr = @Twp_AlgSposobZaokr,
      TWP_Priorytet = @Twp_Priorytet,
      TWP_AlgStOkrPlusTyp = @Twp_AlgStOkrPlusTyp,
      TWP_AlgStazSposob = @Twp_AlgStazSposob,
      TWP_Ulga = @Twp_Ulga,
      -- TWP_WzrId = @Twp_WzrId,
      TWP_AlgRodzaj12 = @Twp_AlgRodzaj12,
      TWP_AlgSposobPomn = @Twp_AlgSposobPomn,
      TWP_Nieaktywny = @Twp_Nieaktywny,
      TWP_AlgPodstDzielGodz = @Twp_AlgPodstDzielGodz,
      TWP_AlgGodziny = @Twp_AlgGodzinyDT,
      TWP_WliczPFRON = @Twp_WliczPFRON,
      TWP_KosztFirma = @Twp_KosztFirma,
      TWP_OpisAnalitCzasPracy = @Twp_OpisAnalitCzasPracy,
      TWP_Kopia = @Twp_Kopia,
      TWP_PozycjaRP7 = @Twp_PozycjaRP7,
      TWP_Wskaznik = @Twp_Wskaznik,
      TWP_Umowa = @Twp_Umowa,
      TWP_WliczanyDoGUS = @Twp_WliczanyDoGUS,
      TWP_ZalPodProc = @Twp_ZalPodProc,
      TWP_PKZP = @Twp_PKZP,
      TWP_SwiadczFS = @Twp_SwiadczFS,
      TWP_OpeZalId = @OpeId,
      TWP_OpeZalKod = @OpeModKod,
      TWP_OpeZalNazwisko = @OpeModNazwisko,
      TWP_TS_Zal = getdate(),
      TWP_OpeModId = @OpeId,
      TWP_OpeModKod = @OpeModKod,
      TWP_OpeModNazwisko = @OpeModNazwisko,
      TWP_TS_Mod = getdate(),
      TWP_AlgStOkrPlusWartosc = @Twp_AlgStOkrPlusWartosc,
      TWP_AlgStOkrWartosc = @Twp_AlgStOkrWartosc,
      TWP_AlgWzorzec = @Twp_AlgWzorzec,
      TWP_Nazwa2 = @Twp_Nazwa2,
      TWP_NazwaPelna = @Twp_NazwaPelna,
      TWP_Skrot = @Twp_Skrot,
      TWP_Skrot2 = @Twp_Skrot2,
      TWP_StOkrWartosc = @Twp_StOkrWartosc,
      TWP_Zmienna1 = @Twp_Zmienna1,
      TWP_Zmienna2 = @Twp_Zmienna2,
      TWP_TypWaluty = @Twp_TypWaluty,
      TWP_NieZapisujZerowego = @Twp_NieZapisujZerowego,
      TWP_AlgIloscMiesWszystkie = @Twp_AlgIloscMiesWszystkie,
      TWP_AlgGodzinyDni = @Twp_AlgGodzinyDni,
      TWp_ZajecieWynagr = @TWp_ZajecieWynagr,
      TWp_DoliczNaKoncu = @TWp_DoliczNaKoncu,
      TWP_AlgKnfWspolcz = @Twp_AlgKnfWspolcz,
      TWP_WliczChorPodwojnie = @Twp_WliczChorPodwojnie,
      TWP_ImportAppId = @ZrdID,
      TWP_ImportRowId = @Twp_ImportRowId--,
      --TWP_TS_Export = getdate()
     where TWP_TWPID = @SlowID
     SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
   end
   else
    RAISERROR('##OPT33096##', 16, 1) --raiserror('Taki zapis już istnieje. Typ wypłaty nie został dodany.', 16, 1)
  end
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 24110, -- OptimaObjectType_TypSkladnika
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Twp_Nazwa,
    @OperacjaTyp = @OperationType,
    @Opis = ''
 end
