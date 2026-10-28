create procedure CDN.DodajPracownika
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
@PRE_PODMnoznikKoszty decimal(15,2),
@PRE_PODMnoznikUlga decimal(15),
@Urz_Akronim nvarchar(20),
@Urz_ImportRowId nvarchar(36),
@Fpl_Nazwa nvarchar(20),
@Fpl_ImportRowId nvarchar(36),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@PRE_KategoriaOpis nvarchar(50),
@BNa_Numer nvarchar(10),
@BNa_ImportRowId nvarchar(36),
@PRE_RachunekNr nvarchar(51),
@PRE_IBAN tinyint,
@PRE_HDKUwagi nvarchar(1024),
@PRE_NieRozliczac tinyint,
@PRE_RodzajDokumentu tinyint,
@PRE_KontoKsiegowe nvarchar(50),
@PRE_KontoKsiegowe2 nvarchar(50),
@PRE_ETAEtatL int,
@PRE_ETAEtatM int,
@Zak_Symbol nvarchar(30),
@Zak_ImportRowId nvarchar(36),
@ZrdId nvarchar(5),
@PRE_HDKEmail nvarchar(127),
@CntId int,
@StanowiskoId int,
@OpeId int,
@SlowId int output,
@Warnings nvarchar(1000) output
as
begin
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod out, @OpeModNazwisko out
 set dateformat DMY
 declare @Urz_Id int, @Kat_Id int, @BNa_Id int, @Fpl_Id int, @Pra_Id int, @TmpAkr nvarchar(20), @PRA_ParentId int, @PRA_Nadrzedny int
 set @PRA_ParentId = 0
 set @PRA_Nadrzedny = 0
 set @Warnings = ''
 if(@StanowiskoId is not null)
 begin
  declare @DkmStanowiskoId int
  select @DkmStanowiskoId = DKM_DkmId from cdn.DaneKadMod where DKM_Rodzaj = 1 and DKM_DkmId = @StanowiskoId
  if @DkmStanowiskoId is null
   set @Warnings = '##OPT34233##'
 end
 declare @CntIdBase int, @CntAdresWezla nvarchar(512)
 if (@CntId is not null)
 begin
  select @CntIdBase = CNT_CntId, @CntAdresWezla = CNT_AdresWezla from cdn.Centra where CNT_CntId = @CntId
  if @CntIdBase is null
  begin
   set @Warnings = '##OPT34234##'
   set @CntIdBase = 3
   set @CntAdresWezla = '1'
  end
 end
 if (@PRE_DataUr is not null)
 begin
  if (@PRE_DataUr <= convert(datetime, '1901-01-01', 120))
   set @PRE_DataUr = null
 end
 if @PRE_MLDKraj = '' or @PRE_MLDKraj is null
  set @PRE_MLDKraj = 'Polska'
 /*if @status <> 'zameldowania' or @status = '' or @status is null
 begin
  select
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
 end*/
 if(@Fpl_ImportRowId is null or @Fpl_ImportRowId = '')
  select @Fpl_Id = Fpl_FplId
  from CDN.FormyPlatnosci
  where Fpl_Nazwa = @Fpl_Nazwa
 else
  select @Fpl_Id = Fpl_FplId
  from CDN.FormyPlatnosci
  where Fpl_importRowId = @Fpl_ImportRowId
 if(@Kat_ImportRowId is not null or @Kat_KodSzczegol is not null)
 begin
  set @Kat_Id = null
  select @Kat_Id = Kat_KatId
  from CDN.Kategorie
  where Kat_ImportRowId = @Kat_ImportRowId
  if @Kat_Id is null
  begin
   select @Kat_Id = Kat_KatId
   from CDN.Kategorie
   where Kat_KodSzczegol = @Kat_KodSzczegol
   if @Kat_Id is null
    set @Warnings = '##OPT34235##%kategoria%=' + isnull(@Kat_KodSzczegol, '') + '##'
  end
 end
 /*select @BNa_Id = BNa_BNaId
 from CDN.BnkNazwy
 where BNa_ImportRowId = @BNa_ImportRowId
 if @BNa_Id is null
  select @BNa_Id = BNa_BNaId
  from CDN.BnkNazwy
  where BNa_Numer = @BNa_Numer*/
 if(@Urz_ImportRowId is null or @Urz_ImportRowId = '')
  select @Urz_Id = Urz_UrzId
  from CDN.Urzedy
  where Urz_Akronim = @Urz_Akronim
 else
  select @Urz_Id = Urz_UrzId
  from CDN.Urzedy
  where Urz_ImportRowId = @Urz_ImportRowId
 if(@PRE_ZatrudnionyOd = '00:00:00' or @PRE_ZatrudnionyOd = '' or @PRE_ZatrudnionyOd = 0)
  set @PRE_ZatrudnionyOd = null
 if(select Fir_Wartosc
  from CDN.Firma
  where Fir_Numer = 2) = 1
 begin
   set @TmpAkr = @PRA_Kod
   set @TmpAkr = replace(replace(replace(replace(@TmpAkr, ',', '.'), ' ', '.'), '-', '.'), '''', '.')
   if charindex('.', @TmpAkr) <> 0 SET @Warnings = @Warnings + '##OPT34236##'
 end
 if(select Fir_Wartosc
  from CDN.Firma
  where Fir_Numer = 1494) = '1'
  begin
   if CDN.IsCorrectNIP(@PRE_NipKraj, replace(@PRE_NipE, '-', '')) = 0
   begin
    SET @Warnings = @Warnings + '##OPT34237##'
    SET @PRE_NipE = ''
   end
  end
 if(select Fir_Wartosc
  from CDN.Firma
  where Fir_Numer = 1499) = '1'
 begin
  if CDN.IsCorrectPesel(@PRE_Pesel) = 0
  begin
   SET @Warnings = @Warnings + '##OPT33166##'
   SET @PRE_Pesel = ''
  end
 end
  declare @Zak_Id int
  exec CDN.GetZakladDlaPracyRozproszonej @Zak_Symbol, @Zak_ImportRowId, 1, @Zak_ID output, @Warnings output
  declare @sprawdzPesel tinyint
  select @sprawdzPesel = Fir_Wartosc from cdn.Firma where Fir_Numer = 3038
  if @sprawdzPesel<>0 and isnull(@PRE_Pesel, '') <> '' and exists(select * from CDN.PracEtaty where PRE_Pesel = @PRE_Pesel)
  begin
    if @sprawdzPesel=1
      set @Warnings = @Warnings + '##OPT34238##%pesel%=' + @PRE_Pesel + '##'--ERR_SQL_Place_IstniejePeselZostalDodany 32475
    else
    begin
      declare @msg varchar(256)
      set @msg = '##OPT33042##%pesel%=' + @PRE_Pesel + '##' --ERR_SQL_Place_IstniejePeselNieDodany 32473
      RAISERROR('##OPT32473##%%nr%%=%s##', 16, 1, @PRE_Pesel)--raiserror(@msg, 16, 1)
    end
  end
 if((select count(*)
     from CDN.PracKod
     where ((Isnull(@PRA_ImportRowId, '') <> '' AND  PRA_ImportRowId = @PRA_ImportRowId) OR PRA_Kod = @PRA_Kod)
    OR (Isnull(@PRA_ImportRowId, '') = '' AND PRA_Kod = @PRA_Kod)) = 0)
 begin
  insert into CDN.PracKod
  (
  PRA_Kod,
  PRA_ImportRowId,
  PRA_ImportAppId,
  PRA_TS_Export,
  PRA_Archiwalny,
  PRA_Nadrzedny,
  PRA_ParentId
  )
  values
  (
  @PRA_Kod,
  @PRA_ImportRowId,
  @ZrdId,
  getdate(),
  @PRA_Archiwalny,
  @PRA_Nadrzedny,
  @PRA_ParentID
  )
  set @PRa_Id = scope_identity()
  insert into CDN.PracEtaty
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
  PRE_ETAMiejsce,
  PRE_KartaPobytu,
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
  PRE_OpeModId,
  PRE_OpeModKod,
  PRE_OpeModNazwisko,
  PRE_OpeZalId,
  PRE_OpeZalKod,
  PRE_OpeZalNazwisko,
  PRE_ZatrudnionyDo,
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
  PRE_ZakID,
  PRE_CntId,
  PRE_AdresCentrum,
  PRE_DzlId,
  PRE_PrmWymiar
  )
  values
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
  @PRE_PODMnoznikKoszty,
  @PRE_PODMnoznikUlga,
  @Urz_Id,
  @FPl_Id,
  @Kat_Id,
  @BNa_Id,
  @PRE_RachunekNr,
  @PRE_IBAN,
  @PRE_HDKUwagi,
  1, --PRE_KalId
  0, --PRE_HDKGUSPracSezonowy
  0,
  0,
  1, --PRE_HDKGUSGlowneMiejscePracy
  0,
  0,
  1, --PRE_ETAPodstZdrowMnoznik
  getdate(),
  getdate(), --PRE_TS_ZAL
  0, --PRE_ABSProcWynChor
  0,
  0,
  0, --PRE_UBZOgraniczSklZdrow
  0,
  convert(datetime, '1899-12-30 08:00:00.000', 120),--PRE_ATANNormaDobowa
  0,
  0,
  0, --PRE_IndywDRA
  0,
  0, --PRE_ABSUrlMies
  0,
  0,
  0,
  0,
  0,
  0, -- PRE_ABSChor35
  0, --PRE_HDKPrawoJazdy
  0, --PRE_PrawoER
  0, --PRE_UBZJestDobrZdrow
  0,
  0,
  0,
  0,
  0, --PRE_UBZJestWypad,
  0,
  0,
  0,
  0, --PRE_KodWyksztal
  0,
  1, --PRE_KodNiezdol
  0,
  0, --PRE_KodPokrew
  0,
  100, -- PRE_ETAGwarantProcMin
  0,
  1, --PRE_ETAWymiar
  0,
  0, --PRE_StawkaL
  0,
  0, --PRE_ETAStawka
  0,
  isnull(@PRE_ETAEtatL, 1),
  isnull(@PRE_ETAEtatM, 1),
  0,
  0,
  0, --PRE_PODZaniechPodat
  0,
  1, --PODKosztyTytul
  '',
  0,
  0,
  0, --PRE_ZestCzasuPracy
  convert(datetime, '2999-12-31', 120), --PRE_DataDo
  convert(datetime, '1900-01-01', 120), --PRE_DataOd
  '', --PRE_ETARodzajZatrudnienia
  '', --PRE_TypPracownika
  99999, --PRE_UBZTyuId
  @PRA_Kod,
  '',
  'POLSKIE', --PRE_Obywatelstwo
  'M', --PRE_Plec
  '', --PRE_StanCywilny
  '', --PRE_HDKTelefon2
  '', --PRE_DowOsobisty
  '',
  '',
  '',
  'Polska', --PRE_KORKraj
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
  'Polska', --PRE_ZAMKraj
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
  '', --PRE_HDKFax
  '', --PRE_HDKTeleks
  '', --PRE_HDKSkrytkaPoczt
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
  '', --PRE_ETAMiejsce
  '', --PRE_KartaPobytu
  '',
  '',
  '', --PRE_HDKPrawoJazdyKat
  @PRE_HDKEmail,
  '', --PRE_HDKURL
  @PRE_KategoriaOpis,
  '1', --PRE_AdresDzialu
  '', --PRE_Opis
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
  null, --convert(datetime, '2999-12-31', 120),
  0, --PRE_ABSFinansowanePracodawca,
     0,
     0,
     1,
     0,
     0,
  0,   -- PRE_KodFEP,
  null,  -- PRE_FEPOd,
  null, -- PRE_FEPDo
  0,  -- PRE_Oddelegowany
  1,  --PRE_OddelegowanyFIS,
  1,  --PRE_OddelegowanyZUS,
  0,  --PRE_OddelegowanyDieta,
  '',  --PRE_OddelegowanyWaluta
  0,  --PRE_WychPodstEmerRentMax
  0,  --PRE_PODNieLiczKoszty50
  @StanowiskoId,
  null,
  null,
  null,
  @Zak_Id,
  @CntIdBase,
  @CntAdresWezla,
  3, --PRE_DzlId
  0 --PRE_PrmWymiar
  )
  set @SlowId = scope_identity()
  --[logowanie]
  declare @oid int
  set @oid = cdn.GetEOperatorID()
  if @oid > 0
  begin
   declare @obj_name nvarchar(128)
   set @obj_name =  '[' + @PRA_Kod + '] ' + @PRE_Imie1 + ' ' + @PRE_Nazwisko
   exec CDN.RejestrOperacjiContextInfo @oid
   exec CDN.RejestrOperacjiDodaj 24000, 0, @SlowId, @obj_name, 1, ''
  end
  insert into cdn.SchematPlatnosci
  (
   SPL_PodmiotTyp, SPL_PodmiotID, SPL_OdbPodmiotTyp, SPL_OdbPodmiotID, SPL_FplId, SPL_BnaId,
   SPL_Rodzaj, SPL_Kwota, SPL_Procent, SPL_RachunekNr, SPL_IBAN, SPL_LiczbaPorz, SPL_Reszta, SPL_Opis,
   SPL_OpeZalID, SPL_StaZalId, SPL_TS_Zal, SPL_OpeModID, SPL_StaModId, SPL_TS_Mod
  )
  values
  (
   3, @SlowId, 3, @SlowId, 1, NULL,
   0, 0, 100, '', 0, 1, 1, NULL,
   null, null, getdate(), null, null, getdate()
  )
 end else if (@OnlyNew <> 1)
 begin
  update CDN.PracKod
  set Pra_Kod = @Pra_Kod, PRA_Archiwalny = @PRA_Archiwalny
  where (isnull(@PRA_ImportRowId, '') <> '' and PRA_ImportRowId = @PRA_ImportRowId)
    or (isnull(@PRA_ImportRowId, '') = '' and PRA_Kod = @PRA_Kod)
  select @Pra_Id = Pra_PraId, @PRA_ParentId = PRA_ParentID, @PRA_Nadrzedny = PRA_Nadrzedny
  from CDN.PracKod
  where (isnull(@PRA_ImportRowId, '') <> '' and PRA_ImportRowId = @PRA_ImportRowId)
    or (isnull(@PRA_ImportRowId, '') = '' and PRA_Kod = @PRA_Kod)
  update CDN.PracEtaty
   set
   PRE_Nazwisko = @PRE_Nazwisko,
   PRE_Imie1 = @PRE_Imie1,
   PRE_Imie2 = @PRE_Imie2,
   PRE_ImieOjca = @PRE_ImieOjca,
   PRE_ImieMatki = @PRE_ImieMatki,
   PRE_DataUr = convert(datetime, @PRE_DataUr, 120),
   PRE_MiejsceUr = @PRE_MiejsceUr,
   PRE_NazwRodowe = @PRE_NazwRodowe,
   PRE_NazwRodoweM = @PRE_NazwRodoweM,
   PRE_Pesel = @PRE_Pesel,
   PRE_NipKraj = @PRE_NipKraj,
   PRE_NipE = replace(@PRE_NipE, ' ', ''),
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
   PRE_ZatrudnionyOd = case when @PRE_ZatrudnionyOd is not null then convert(datetime, @PRE_ZatrudnionyOd, 120) else PRE_ZatrudnionyOd end,
   PRE_PODMnoznikKoszty = @PRE_PODMnoznikKoszty,
   PRE_PODMnoznikUlga = @PRE_PODMnoznikUlga,
   PRE_PODUrzSkarbId = @Urz_Id,
   PRE_FPlId = @FPl_Id,
   PRE_KatId = @Kat_Id,
   PRE_KategoriaOpis = @PRE_KategoriaOpis,
   PRE_BNaId = @BNa_Id,
   PRE_RachunekNr = @PRE_RachunekNr,
   PRE_IBAN = @PRE_IBAN,
   PRE_HDKUwagi = @PRE_HDKUwagi,
   PRE_TS_Mod = getdate(),
   PRE_NieRozliczac = @PRE_NieRozliczac,
   PRE_RodzajDokumentu = @PRE_RodzajDokumentu,
   PRE_ETAEtatL = case when @PRE_ETAEtatL is not null then @PRE_ETAEtatL else PRE_ETAEtatL end,
   PRE_ETAEtatM = case when @PRE_ETAEtatM is not null then @PRE_ETAEtatM else PRE_ETAEtatM end,
   --PRE_KontoKsiegowe = CASE WHEN Isnull(@PRE_KontoKsiegowe, '') <> '' THEN @PRE_KontoKsiegowe else PRE_KontoKsiegowe end,
   --PRE_KontoKsiegowe2 = CASE WHEN Isnull(@PRE_KontoKsiegowe2, '') <> '' THEN @PRE_KontoKsiegowe2 else PRE_KontoKsiegowe2 end,
   PRE_ZakId = @Zak_Id,
   PRE_HDKEmail = @PRE_HDKEmail,
   PRE_ETADkmIdStanowisko = @StanowiskoId,
   PRE_CntId = @CntIdBase,
   PRE_AdresCentrum = @CntAdresWezla,
   PRE_OpeModId = @OpeId,
   PRE_OpeModKod = @OpeModKod,
   PRE_OpeModNazwisko = @OpeModNazwisko
  where PRE_PraId = @Pra_Id
  select @SlowId = PRE_PREId
   from CDN.PracEtaty
   where PRE_PRAId = @Pra_Id
  --[logowanie]
  declare @obj_name2 nvarchar(128)
  set @obj_name2 = '[' + @PRA_Kod + '] ' + @PRE_Imie1 + ' ' + @PRE_Nazwisko
  exec CDN.RejestrOperacjiDodaj 24000, 0, @SlowId, @obj_name, 2, 'Pracownik'
 end
 else
  RAISERROR('##OPT32476##', 16, 1)--raiserror('Taki zapis już istnieje. Element nie został dodany', 16, 1)--ERR_SQL_Place_ZapisIstnieje
 exec CDN.AktualizujPracIdx @Pra_Id, @PRA_Archiwalny, @PRA_ParentId, @PRA_Nadrzedny
end
