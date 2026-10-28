CREATE PROCEDURE CDN.ImportWspol
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@PRA_ImportRowId nvarchar(36),
@PRA_Kod nvarchar(20),
@PRA_Archiwalny tinyint,
@PRE_Nazwisko nvarchar(40),
@PRE_Imie1 nvarchar(30),
@PRE_Imie2 nvarchar(30),
@PRE_ImieOjca nvarchar(30),
@PRE_ImieMatki nvarchar(30),
@PRE_DataUr nvarchar(10),
@PRE_MiejsceUr nvarchar(40),
@PRE_NazwRodowe nvarchar(40),
@PRE_NazwRodoweM nvarchar(40),
@PRE_Pesel nvarchar(11),
@PRE_NipKraj nvarchar(2),
@PRE_NipE nvarchar(32),
@Status nvarchar(15),
@PRE_MLDKraj nvarchar(40),
@PRE_MLDWojewodztwo nvarchar(40),
@PRE_MLDPowiat nvarchar(40),
@PRE_MLDGmina nvarchar(40),
@PRE_MLDUlica nvarchar(40),
@PRE_MLDNrDomu nvarchar(10),
@PRE_MLDNrLokalu nvarchar(10),
@PRE_MLDMiasto nvarchar(40),
@PRE_MLDKodPocztowy nvarchar(10),
@PRE_MLDPoczta nvarchar(40),
@PRE_MLDAdres2 nvarchar(40),
@PRE_HDKTelefon1 nvarchar(20),
@PRE_ZatrudnionyOd nvarchar(10),
@PRE_PODMnoznikUlga decimal(15,2),
@Fpl_Nazwa nvarchar(20),
@Fpl_ImportRowId nvarchar(36),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@PRE_KategoriaOpis nvarchar(50),
@BNa_Numer nvarchar(10),
@BNa_ImportRowId nvarchar(36),
@Urz_Akronim nvarchar(20),
@Urz_ImportRowId nvarchar(36),
@PRE_RachunekNr nvarchar(51),
@PRE_IBAN tinyint,
@PRE_HDKUwagi nvarchar(1024),
@PRE_NieRozliczac tinyint,
@PRE_RodzajDokumentu tinyint,
@PRE_KontoKsiegowe nvarchar(50),
@PRE_KontoKsiegowe2 nvarchar(50),
@PRE_ETAEtatL int,
@PRE_ETAEtatM int,
@PRE_PODZwolPIT26 tinyint,
@Zak_Symbol nvarchar(30),
@Zak_ImportRowId nvarchar(36),
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @OperationType INT
 SET @OperationType = 0
 DECLARE @Kat_Id int
 DECLARE @BNa_Id int
 DECLARE @Fpl_Id int
 DECLARE @Pra_Id int
 DECLARE @Urz_Id int
 DECLARE @TmpAkr nvarchar(20)
 DECLARE @PRA_ParentId int, @PRA_Nadrzedny int
 SET @PRA_ParentId = 0
 SET @PRA_Nadrzedny = 0
 IF @status <> 'zameldowania' OR @status = '' OR @status is NULL
 BEGIN
  SELECT
  @PRE_MLDKraj = '',
  @PRE_MLDWojewodztwo = '',
  @PRE_MLDPowiat = '',
  @PRE_MLDGmina  = '',
  @PRE_MLDUlica = '',
  @PRE_MLDNrDomu = '',
  @PRE_MLDNrLokalu = '',
  @PRE_MLDMiasto = '',
  @PRE_MLDKodPocztowy = '',
  @PRE_MLDPoczta = '',
  @PRE_MLDAdres2 = '',
  @PRE_HDKTelefon1 = ''
 END
 IF(@Fpl_ImportRowId is NULL or @Fpl_ImportRowId = '')
  SELECT @Fpl_Id = Fpl_FplId
  FROM CDN.FormyPlatnosci
  WHERE Fpl_Nazwa = @Fpl_Nazwa
 ELSE
  SELECT @Fpl_Id = Fpl_FplId
  FROM CDN.FormyPlatnosci
  WHERE Fpl_ImportRowId = @Fpl_ImportRowId
 SET @Warnings = ''
 IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
 BEGIN
  SET @Kat_Id = NULL
  SELECT @Kat_Id = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowId
  IF(@Kat_Id is NULL)
  BEGIN
   SELECT @Kat_Id = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegol
   IF(@Kat_Id is NULL)
    --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria nie została zaimportowana.\'
    SET @Warnings = '##OPT33150##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
  END
 END
 SELECT @BNa_Id = BNa_BNaId
 FROM CDN.BnkNazwy
 WHERE BNa_ImportRowId = @BNa_ImportRowId
 IF @BNa_Id is NULL
  SELECT @BNa_Id = BNa_BNaId
  FROM CDN.BnkNazwy
  WHERE BNa_Numer = @BNa_Numer
 IF(@Urz_ImportRowId is NULL or @Urz_ImportRowId = '')
  SELECT @Urz_Id = Urz_UrzId
  FROM CDN.Urzedy
  WHERE Urz_Akronim = @Urz_Akronim
 ELSE
  SELECT @Urz_Id = Urz_UrzId
  FROM CDN.Urzedy
  WHERE Urz_ImportRowId = @Urz_ImportRowId
 IF(@PRE_ZatrudnionyOd = '00:00:00') SET @PRE_ZatrudnionyOd = NULL
 IF(SELECT Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 2) = 1
 BEGIN
   SET @TmpAkr = @PRA_Kod
   SET @TmpAkr = REPLACE(REPLACE(REPLACE(REPLACE(@TmpAkr, ',', '.'), ' ', '.'), '-', '.'), '''', '.')
   IF CHARINDEX('.', @TmpAkr) <> 0
    --SET @Warnings = @Warnings + 'Akronim zawiera znaki specjalne.\'
    SET @Warnings = @Warnings + '##OPT33152##\'
 END
 IF(SELECT Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 1494) = '1'
  BEGIN
   IF CDN.IsCorrectNIP(@PRE_NipKraj, REPLACE(@PRE_NipE, '-', '')) = 0
   BEGIN
    --SET @Warnings = @Warnings + 'Niepoprawny NIP wspólnika.\'
    SET @Warnings = @Warnings + '##OPT33153##\'
    SET @PRE_NipE = ''
   END
  END
 IF(SELECT Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 1499) = '1'
 BEGIN
  IF CDN.IsCorrectPesel(@PRE_Pesel) = 0
  BEGIN
   --SET @Warnings = @Warnings + 'Niepoprawny Pesel wspólnika.\'
   SET @Warnings = @Warnings + '##OPT33154##\'
   SET @PRE_Pesel = ''
  END
 END
  DECLARE @Zak_Id int
  EXEC CDN.GetZakladDlaPracyRozproszonej @Zak_Symbol, @Zak_ImportRowId, 2, @Zak_ID OUTPUT, @Warnings OUTPUT
  DECLARE @sprawdzPesel TINYINT
  SELECT @sprawdzPesel = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 3038
  IF @sprawdzPesel<>0 AND IsNull(@PRE_Pesel, '') <> '' AND EXISTS(SELECT * FROM CDN.PracEtaty WHERE PRE_Pesel = @PRE_Pesel)
  BEGIN
    IF @sprawdzPesel=1
      --SET @Warnings = @Warnings + 'W bazie danych istnieje wspólnik z numerem PESEL ' + @PRE_Pesel + '. Element został dodany.\'
   SET @Warnings = @Warnings + '##OPT33155##%%pesel%%=' +  @PRE_Pesel + '##\';
    ELSE
    BEGIN
      DECLARE @msg VARCHAR(256)
      SET @msg = 'W bazie danych istnieje wspólnik z numerem PESEL ' + @PRE_Pesel + '. Element nie został dodany.'
      RAISERROR('##OPT33040##%%pesel%%=%s##', 16, 1, @PRE_Pesel) --RAISERROR(@msg, 16, 1)
    END
  END
 IF((SELECT count(*)
     FROM CDN.PracKod
     WHERE ((IsNull(@PRA_ImportRowId, '') <> '' AND  PRA_ImportRowId = @PRA_ImportRowId) OR PRA_Kod = @PRA_Kod)
    OR (IsNull(@PRA_ImportRowId, '') = '' AND PRA_Kod = @PRA_Kod)) = 0)
 BEGIN
  INSERT INTO CDN.PracKod
  (
  PRA_Kod,
  PRA_ImportRowId,
  PRA_ImportAppId,
  PRA_TS_Export,
  PRA_Archiwalny,
  PRA_Nadrzedny,
  PRA_ParentId
  )
  VALUES
  (
  @PRA_Kod,
  @PRA_ImportRowId,
  @ZrdId,
  GETDATE(),
  @PRA_Archiwalny,
  @PRA_Nadrzedny,
  @PRA_ParentID
  )
  SET @PRa_Id = SCOPE_IDENTITY()
  INSERT INTO CDN.PracEtaty
  (
  PRE_PraId,
  PRE_Nazwisko,
  PRE_Imie1,
  PRE_Imie2,
  PRE_ImieOjca,
  PRE_ImieMatki,
  PRE_DataUr,
  PRE_MiejsceUr,
  PRE_NazwRodowe,
  PRE_NazwRodoweM,
  PRE_Pesel,
  PRE_NipKraj,
  PRE_NipE,
  PRE_MLDKraj,
  PRE_MLDWojewodztwo,
  PRE_MLDPowiat,
  PRE_MLDGmina,
  PRE_MLDUlica,
  PRE_MLDNrDomu,
  PRE_MLDNrLokalu,
  PRE_MLDMiasto,
  PRE_MLDKodPocztowy,
  PRE_MLDPoczta,
  PRE_MLDAdres2,
  PRE_HDKTelefon1,
  PRE_ZatrudnionyOd,
  PRE_PODMnoznikKoszty,
  PRE_PODMnoznikUlga,
  PRE_PODUrzSkarbId,
  PRE_FPlId,
  PRE_KatId,
  PRE_BNaId,
  PRE_RachunekNr,
  PRE_IBAN,
  PRE_HDKUwagi,
  PRE_KalId,
  PRE_HDKGUSPracSezonowy,
  PRE_HDKGUSPoraNocna,
  PRE_HDKGUSPierwszaPraca,
  PRE_HDKGUSGlowneMiejscePracy,
  PRE_ETAIndywProcWypadProcent,
  PRE_ETAIndywProcWypad,
  PRE_ETAPodstZdrowMnoznik,
  PRE_TS_Mod,
  PRE_TS_Zal,
  PRE_ABSProcWynChor,
  PRE_ABSProcWynChorFlaga,
  PRE_ABSLimitLiczbaDni,
  PRE_UBZOgraniczSklZdrow,
  PRE_HDKRodzajMiejsc,
  PRE_ETANormaDobowa,
  PRE_KodWyksztPFRON,
  PRE_IndywLimitNadgodzin,
  PRE_IndywDRA,
  PRE_ABSChorMiesKorekta,
  PRE_ABSUrlMies,
  PRE_ABSUrlMiesKorekta,
  PRE_ABSOP14,
  PRE_ABSOP60,
  PRE_ABSChor6M,
  PRE_ABSChor90,
  PRE_ABSChor35,
  PRE_HDKPrawoJazdy,
  PRE_PrawoER,
  PRE_UBZJestDobrZdrow,
  PRE_UBZJestDobrChorobowe,
  PRE_UBZJestDobrRentowe,
  PRE_UBZJestDobrEmerytal,
  PRE_UBZZdrowKwotaPierwSkl,
  PRE_UBZJestWypad,
  PRE_UBZJestChorobowe,
  PRE_UBZJestRentowe,
  PRE_UBZJestEmerytal,
  PRE_KodWyksztal,
  PRE_KodStgorniczego,
  PRE_KodNiezdol,
  PRE_Wspolgosp,
  PRE_KodPokrew,
  PRE_StNiepelnosp,
  PRE_ETAGwarantProcMin,
  PRE_ETAStandard,
  PRE_ETAWymiar,
  PRE_ETAStawkaM,
  PRE_ETAStawkaL,
  PRE_ETAStawkagodz,
  PRE_ETAStawka,
  PRE_ETAMinimalna,
  PRE_ETAEtatL,
  PRE_ETAEtatM,
  PRE_ETARozwiazUmowy,
  PRE_ETAStosunekPracy,
  PRE_PODZaniechPodat,
  PRE_PODProcKosztyUzysk,
  PRE_PODKosztyTytul,
  PRE_MLDGminaKod,
  PRE_Filtr,
  PRE_WypNaKonto,
  PRE_ZestCzasuPracy,
  PRE_DataDo,
  PRE_DataOd,
  PRE_ETARodzajZatrudnienia,
  PRE_TypPracownika,
  PRE_UBZTyuId,
  PRE_Kod,
  PRE_NrwAktach,
  PRE_Obywatelstwo,
  PRE_Plec,
  PRE_StanCywilny,
  PRE_HDKTelefon2,
  PRE_DowOsobisty,
  PRE_DowGdzie,
  PRE_DowKto,
  PRE_Paszport,
  PRE_KORKraj,
  PRE_KORWojewodztwo,
  PRE_KORPowiat,
  PRE_KORGmina,
  PRE_KORUlica,
  PRE_KORNrDomu,
  PRE_KORNrLokalu,
  PRE_KORMiasto,
  PRE_KORKodPocztowy,
  PRE_KORPoczta,
  PRE_KORAdres2,
  PRE_ZAMKraj,
  PRE_ZAMWojewodztwo,
  PRE_ZAMPowiat,
  PRE_ZAMGmina,
  PRE_ZAMUlica,
  PRE_ZAMNrDomu,
  PRE_ZAMNrLokalu,
  PRE_ZAMMiasto,
  PRE_ZAMKodPocztowy,
  PRE_ZAMPoczta,
  PRE_ZAMAdres2,
  PRE_HDKFax,
  PRE_HDKTeleks,
  PRE_HDKSkrytkaPoczt,
  PRE_HDKWypOsoba,
  PRE_HDKWypAdres,
  PRE_HDKWypTelefon,
  PRE_HDKWojStosunek,
  PRE_HDKWojStopien,
  PRE_HDKWojSpecjal,
  PRE_HDKWojWKU,
  PRE_HDKWojNrKsiaz,
  PRE_HDKWojPrzydzial,
  PRE_ETARodzajUmowy,
  --PRE_ETAWypowPowod,
  --PRE_ETAStanowisko,
  --PRE_ETAFunkcja,
  PRE_ETAMiejsce,
  PRE_KartaPobytu,
  --PRE_KodZawodu,
  PRE_WarSzczegolne,
  PRE_KodKasyChorych,
  PRE_HDKPrawoJazdyKat,
  PRE_HDKEmail,
  PRE_HDKURL,
  PRE_KategoriaOpis,
  PRE_AdresDzialu,
  PRE_Opis,
  PRE_NieRozliczac,
  PRE_RodzajDokumentu,
  PRE_KontoKsiegowe,
  PRE_KontoKsiegowe2,
  PRE_OpeModID,
  PRE_OpeModKod,
  PRE_OpeModNazwisko,
  PRE_OpeZalID,
  PRE_OpeZalKod,
  PRE_OpeZalNazwisko,
  PRE_ZatrudnionyDo,
        PRE_NieNaliczacFP,
        PRE_NieNaliczacFGSP,
        PRE_ABSFinansowanePracodawca,
        PRE_ABSFinansowanePracodawcaDni,
        PRE_PelneDaneAdresowePFRON,
        PRE_PomocPublicznaPFRON,
        PRE_WzrostZatrudnieniaPFRON,
        PRE_ZatrudRozwUmowyPFRON,
  PRE_KodFEP,
  PRE_FEPOd,
  PRE_FEPDo,
  PRE_Oddelegowany,
  PRE_OddelegowanyFIS,
  PRE_OddelegowanyZUS,
  PRE_OddelegowanyDieta,
  PRE_OddelegowanyWaluta,
  PRE_WychPodstEmerRentMax,
  PRE_PODNieLiczKoszty50,
  PRE_ETADkmIdStanowisko,
  PRE_ETADkmIdFunkcja,
  PRE_ETADkmIdWypowPowod,
  PRE_DkmIdKodZawodu,
  PRE_ZakId,
  PRE_PODZwolPIT26
  )
  VALUES
  (
  @Pra_Id,
  @PRE_Nazwisko,
  @PRE_Imie1,
  @PRE_Imie2,
  @PRE_ImieOjca,
  @PRE_ImieMatki,
  convert(datetime, @PRE_DataUr, 120),
  @PRE_MiejsceUr,
  @PRE_NazwRodowe,
  @PRE_NazwRodoweM,
  @PRE_Pesel,
  @PRE_NipKraj,
  REPLACE(@PRE_NipE, ' ', ''),
  @PRE_MLDKraj,
  @PRE_MLDWojewodztwo,
  @PRE_MLDPowiat,
  @PRE_MLDGmina,
  @PRE_MLDUlica,
  @PRE_MLDNrDomu,
  @PRE_MLDNrLokalu,
  @PRE_MLDMiasto,
  @PRE_MLDKodPocztowy,
  @PRE_MLDPoczta,
  @PRE_MLDAdres2,
  @PRE_HDKTelefon1,
  convert(datetime, @PRE_ZatrudnionyOd, 120),
  0,
  @PRE_PODMnoznikUlga,
  @Urz_Id,
  @FPl_Id,
  @Kat_Id,
  @BNa_Id,
  @PRE_RachunekNr,
  @PRE_IBAN,
  @PRE_HDKUwagi,
  1,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  GETDATE(),
  GETDATE(),
  0,
  0,
  0,
  0,
  0,
  convert(datetime, '1899-12-30 08:00:00.000', 120),--PRE_ATANNormaDobowa
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0, -- PRE_ABSChor35
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0, --PRE_KodWyksztal
  0,
  1, --PRE_KodNiezdol
  0,
  0,
  0,
  100, --PRE_ETAGwarantProcMin
  0,
  0,
  0,
  0, --PRE_StawkaL
  0,
  0,
  0,
    IsNull(@PRE_ETAEtatL, 1),
    IsNull(@PRE_ETAEtatM, 1),
  0,
  0,
  0,
  0,
  0, --
  '',
  0,
  0,
  0,
  convert(datetime, '2999-12-31', 120),
  convert(datetime, '1900-01-01', 120),
  0,
  1,
  99999,
  @PRA_Kod,
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  --'',
  --'',
  --'',
  '', --PRE_ETAMiejsce
  '',
  --'',
  '',
  '',
  0,
  '',
  '',
  @PRE_KategoriaOpis,
  '',
  '',
  @PRE_NieRozliczac,
  @PRE_RodzajDokumentu,
  @PRE_KontoKsiegowe,
  @PRE_KontoKsiegowe2,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  convert(datetime, '2999-12-31', 120),
                0,
                0,
        0, -- PRE_ABSFinansowanePracodawca
        0,
        0,
        1,
        0,
        0,
  0,   -- PRE_KodFEP,
  NULL,  -- PRE_FEPOd,
  NULL,   -- PRE_FEPDo
  0,  -- PRE_Oddelegowany
  1,  --PRE_OddelegowanyFIS,
  1,  --PRE_OddelegowanyZUS,
  0,  --PRE_OddelegowanyDieta,
  '',  --PRE_OddelegowanyWaluta
  0,  --PRE_WychPodstEmerRentMax
  0,  --PRE_PODNieLiczKoszty50
  NULL, --PRE_ETADkmIdStanowisko,
  NULL, --PRE_ETADkmIdFunkcja
  NULL, --PRE_ETADkmIdWypowPowod
  NULL, --PRE_DkmIdKodZawodu
  @Zak_Id,
  IsNull(@PRE_PODZwolPIT26, 0)
  )
  SET @SlowId = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
 END ELSE IF (@OnlyNew <> 1)
 BEGIN
  UPDATE CDN.PracKod
  SET Pra_Kod = @Pra_Kod, PRA_Archiwalny = @PRA_Archiwalny
  WHERE (IsNull(@PRA_ImportRowId, '') <> '' AND  PRA_ImportRowId = @PRA_ImportRowId)
    OR (IsNull(@PRA_ImportRowId, '') = '' AND PRA_Kod = @PRA_Kod)
  SELECT @Pra_Id = Pra_PraId, @PRA_ParentId = PRA_ParentId, @PRA_Nadrzedny = PRA_Nadrzedny
  FROM CDN.PracKod
  WHERE (IsNull(@PRA_ImportRowId, '') <> '' AND  PRA_ImportRowId = @PRA_ImportRowId)
    OR (IsNull(@PRA_ImportRowId, '') = '' AND PRA_Kod = @PRA_Kod)
  UPDATE CDN.PracEtaty
  SET
  PRE_Nazwisko = @PRE_Nazwisko,
  PRE_Imie1 = @PRE_Imie1,
  PRE_Imie2 = @PRE_Imie2,
  PRE_ImieOjca = @PRE_ImieOjca,
  PRE_ImieMatki = @PRE_ImieMatki,
  PRE_DataUr = convert(datetime, @PRE_DataUr, 120),
  PRE_ZatrudnionyOd = convert(datetime, @PRE_ZatrudnionyOd, 120),
  PRE_MiejsceUr = @PRE_MiejsceUr,
  PRE_NazwRodowe = @PRE_NazwRodowe,
  PRE_NazwRodoweM = @PRE_NazwRodoweM,
  PRE_Pesel = @PRE_Pesel,
  PRE_NipKraj = @PRE_NipKraj,
  PRE_NipE = REPLACE(@PRE_NipE, ' ', ''),
  PRE_MLDKraj = @PRE_MLDKraj,
  PRE_MLDWojewodztwo = @PRE_MLDWojewodztwo,
  PRE_MLDPowiat = @PRE_MLDPowiat,
  PRE_MLDGmina = @PRE_MLDGmina,
  PRE_MLDUlica = @PRE_MLDUlica,
  PRE_MLDNrDomu = @PRE_MLDNrDomu,
  PRE_MLDNrLokalu = @PRE_MLDNrLokalu,
  PRE_MLDMiasto = @PRE_MLDMiasto,
  PRE_MLDKodPocztowy = @PRE_MLDKodPocztowy,
  PRE_MLDPoczta = @PRE_MLDPoczta,
  PRE_HDKTelefon1 = @PRE_HDKTelefon1,
  --PRE_PODMnoznikUlga = @PRE_PODMnoznikUlga,
  PRE_PODUrzSkarbId = @Urz_Id,
  PRE_FPlId = @FPl_Id,
  PRE_KatId = @Kat_Id,
  PRE_KategoriaOpis = @PRE_KategoriaOpis,
  PRE_BNaId = @BNa_Id,
  PRE_RachunekNr = @PRE_RachunekNr,
  PRE_IBAN = @PRE_IBAN,
  PRE_HDKUwagi = @PRE_HDKUwagi,
  PRE_TS_Mod = GETDATE(),
  PRE_NieRozliczac = @PRE_NieRozliczac,
  PRE_RodzajDokumentu = @PRE_RodzajDokumentu,
  --PRE_KontoKsiegowe = CASE WHEN IsNull(@PRE_KontoKsiegowe, '') <> '' THEN @PRE_KontoKsiegowe ELSE PRE_KontoKsiegowe END,
  --PRE_KontoKsiegowe2 = CASE WHEN IsNull(@PRE_KontoKsiegowe2, '') <> '' THEN @PRE_KontoKsiegowe2 ELSE PRE_KontoKsiegowe2 END,
  PRE_ZakId = @Zak_Id,
  PRE_PODZwolPIT26 = IsNull(@PRE_PODZwolPIT26, 0),
  PRE_OpeModID = @OpeId,
  PRE_OpeModKod = @OpeModKod,
  PRE_OpeModNazwisko = @OpeModNazwisko
  WHERE PRE_PraId = @Pra_Id
  SELECT @SlowId = PRE_PREId
  FROM CDN.PracEtaty
  WHERE PRE_PraId = @Pra_Id
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
 END
 ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 exec CDN.AktualizujPracIdx @Pra_Id, @PRA_Archiwalny, @PRA_ParentId, @PRA_Nadrzedny
 IF @OperationType <> 0
 BEGIN
  DECLARE @Nazwa1 NVARCHAR(1024)
  SELECT @Nazwa1 = '[' + @PRA_Kod + '] ' + @PRE_Imie1 + ' ' + @PRE_Nazwisko
  --DECLARE @Opis1 NVARCHAR(255)
  --SELECT @Opis1 = CASE WHEN @OperationType = 1 THEN 'Pracownik' ELSE 'Pracownik (zapis historyczny)' END
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 24000, -- OptimaObjectType_Pracownik
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Nazwa1,
    @OperacjaTyp = @OperationType,
    @Opis = '' --@Opis1
 END
END
