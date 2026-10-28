create procedure cdn.Altum_DodajPracownika
 @PracSynchId nvarchar(36), --PRA_ImportRowId --unikalny identyfikator pracownika (GUID)
 @Kod nvarchar(20),
 @Nazwisko nvarchar(40),
 @Imie nvarchar(30),
 @NIP nvarchar(13),
 @Pesel nvarchar(11),
 @URL nvarchar(255),
 @Opis nvarchar(1024),
 @Archiwalny tinyint,   --rezerwacja
 @MldKraj nvarchar(40), @MldWojewodztwo nvarchar(40), @MldUlica nvarchar(40), @MldNrDomu nvarchar(10), @MldNrLokalu nvarchar(10),
 @MldMiasto nvarchar(40), @MldKodPocztowy nvarchar(10), @MldPoczta nvarchar(40), @MldGmina nvarchar(40), @MldPowiat nvarchar(40),
 @ZamKraj nvarchar(40), @ZamWojewodztwo nvarchar(40), @ZamUlica nvarchar(40), @ZamNrDomu nvarchar(10), @ZamNrLokalu nvarchar(10),
 @ZamMiasto nvarchar(40), @ZamKodPocztowy nvarchar(10), @ZamPoczta nvarchar(40), @ZamGmina nvarchar(40), @ZamPowiat nvarchar(40),
 @KorKraj nvarchar(40), @KorWojewodztwo nvarchar(40), @KorUlica nvarchar(40), @KorNrDomu nvarchar(10), @KorNrLokalu nvarchar(10),
 @KorMiasto nvarchar(40), @KorKodPocztowy nvarchar(10), @KorPoczta nvarchar(40), @KorGmina nvarchar(40), @KorPowiat nvarchar(40),
 @Telefon1 nvarchar(20),
 @Telefon2 nvarchar(20),   --prywatny
 @Telefon3 nvarchar(20),   --służbowy
 @Fax nvarchar(20),
 @EMail nvarchar(127),
 @Throw nvarchar(256) output  --treść wyjątku
 as
 set nocount on
  set @Throw = ''
  declare @s nvarchar(128)
  if len(@Kod) = 0 or len(@Nazwisko) = 0 or len(@Imie) = 0
  begin
   set @Throw = '##OPT34221##'
   return
  end
  if len(@Kod) > 20
  begin
   set @Throw = '##OPT34222##%akronim%=' + @Kod + '##'
   return
  end
  if (select pra_praid from cdn.PracKod
   where PRA_Kod = @Kod) > 0
  begin
   set @Throw = '##OPT32390##%akronim%=' + @Kod + '##'
   return
  end
  begin try
  insert into cdn.prackod
    (PRA_Kod, PRA_ImportRowId, PRA_Nadrzedny, PRA_Archiwalny)
   values
    (@Kod, @PracSynchId, 0, 0)
  declare @NewPraId int
  set @NewPraId = 0
  select @NewPraId = PRA_PraId from cdn.PracKod
   where PRA_Kod = @Kod
  if @NewPraId > 0
  begin
   declare @OkresOd datetime, @OkresDo datetime
   set @OkresOd = convert(datetime, '1900-01-01', 120)
   set @OkresDo = convert(datetime, '2999-12-31', 120)
   declare @DataUrodzenia datetime
   if len(@Pesel) > 0
    set @DataUrodzenia = CDN.PobierzDateUrodzenia(@Pesel)
   declare @OpeId int
   set @OpeId = cdn.GetAltumOperatorID()
   declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
   exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
   insert into cdn.PracEtaty
     (
     PRE_ZrgId,PRE_PraId,PRE_PodmiotTyp,PRE_DzlId,PRE_CntId,PRE_KalId,PRE_ETATwpId,PRE_UBZTyuId,PRE_TypPracownika,
     PRE_WlascicielId,PRE_BnaId,PRE_FplId,
     PRE_Kod,PRE_Nazwisko,PRE_Imie1,PRE_Pesel,PRE_ETARodzajZatrudnienia,PRE_DataOd,PRE_DataDo,
     PRE_ZatrudnionyOd,PRE_ZatrudnionyDo,PRE_RachunekNr,PRE_IBAN,PRE_ZestCzasuPracy,PRE_WypNaKonto,PRE_NrwAktach,PRE_Filtr,
     PRE_NazwRodowe,PRE_Imie2,PRE_ImieOjca,PRE_ImieMatki,PRE_NazwRodoweM,
     PRE_DataUr,PRE_MiejsceUr,PRE_Obywatelstwo,PRE_Plec,PRE_StanCywilny,
     PRE_MLDKraj,PRE_MLDWojewodztwo,PRE_MLDPowiat,PRE_MLDGmina,PRE_MLDUlica,PRE_MLDNrDomu,PRE_MLDNrLokalu,PRE_MLDMiasto,
     PRE_MLDKodPocztowy,PRE_MLDPoczta,PRE_MLDAdres2,PRE_MLDGminaKod,
     PRE_HDKTelefon1,PRE_HDKTelefon2,PRE_NipKraj,PRE_NipE,PRE_DowOsobisty,PRE_DowGdzie,PRE_DowKiedy,PRE_DowWaznyDo,PRE_DowKto,PRE_Paszport,
     PRE_KORKraj,PRE_KORWojewodztwo,PRE_KORPowiat,PRE_KORGmina,PRE_KORUlica,PRE_KORNrDomu,PRE_KORNrLokalu,PRE_KORMiasto,
     PRE_KORKodPocztowy,PRE_KORPoczta,PRE_KORAdres2,
     PRE_ZAMKraj,PRE_ZAMWojewodztwo,PRE_ZAMPowiat,PRE_ZAMGmina,PRE_ZAMUlica,PRE_ZAMNrDomu,PRE_ZAMNrLokalu,PRE_ZAMMiasto,
     PRE_ZAMKodPocztowy,PRE_ZAMPoczta,PRE_ZAMAdres2,
     PRE_HDKFax,PRE_HDKTeleks,PRE_HDKSkrytkaPoczt,PRE_HDKWypOsoba,PRE_HDKWypAdres,PRE_HDKWypTelefon,
     PRE_AdresCentrum,
     PRE_PODMnoznikKoszty,PRE_PODMnoznikUlga,PRE_PODKosztyTytul,PRE_PODProcKosztyUzysk,PRE_PODZaniechPodat,PRE_PODUrzSkarbId,
     PRE_RefundacjaKwota,PRE_RefundOd,PRE_RefundDo,
     PRE_HDKWojStosunek,PRE_HDKWojStopien,PRE_HDKWojSpecjal,PRE_HDKWojWKU,PRE_HDKWojNrKsiaz,PRE_HDKWojPrzydzial,
     PRE_ETAStosunekPracy,PRE_ETADataZawarcia,PRE_ETARodzajUmowy,PRE_ETARozwiazUmowy,PRE_ETAMiejsce,PRE_ETAEtatL,PRE_ETAEtatM,
     PRE_ETAMinimalna, PRE_ETADataRozpocz,PRE_ETAStawka,PRE_ETAStawkaGodz,PRE_ETAStawkaL,PRE_ETAStawkaM,PRE_ETAWymiar,
     PRE_ETAStandard,PRE_ETAGwarantProcMin,
     PRE_KartaPobytu,PRE_StNiepelnosp,PRE_NiepelnospOd,PRE_NiepelnospDo,PRE_KodPokrew,PRE_WspolGosp,
     PRE_KodNiezdol,PRE_NiezdolOd,PRE_NiezdolDo, PRE_KodStGorniczego,PRE_GorniczeOd,PRE_GorniczeDo,
     PRE_KodWyksztal,PRE_WarSzczegolne,PRE_WarSzczegolneOd,PRE_WarSzczegolneDo,
     PRE_KodKasyChorych,PRE_KasaChData,
     PRE_UBZZusOd,PRE_UBZJestEmerytal,PRE_UBZJestRentowe,PRE_UBZJestChorobowe,PRE_UBZJestWypad,
     PRE_UBZZdrowOd,PRE_UBZEmerOd,PRE_UBZRentOd,PRE_UBZChorOd,PRE_UBZZdrowDobrOd,PRE_UBZZdrowKwotaPierwSkl,
     PRE_UBZEmerDo,PRE_UBZRentDo,PRE_UBZChorDo,PRE_UBZWypadDo,PRE_UBZZdrowDo,
     PRE_UBZEmerKod,PRE_UBZRentKod,PRE_UBZChorKod,PRE_UBZWypadKod,PRE_UBZZdrowKod,
     PRE_UBZJestDobrEmerytal,PRE_UBZJestDobrRentowe,PRE_UBZJestDobrChorobowe,PRE_UBZJestDobrZdrow,
     PRE_PrzekroczRok,PRE_PrzekroczMiesiac,PRE_PrzekroczKwota,PRE_PrzekroczInformacja,PRE_Przekroczenie,PRE_PrawoER,
     PRE_HDKUwagi,PRE_HDKPrawoJazdy,PRE_HDKPrawoJazdyKat,PRE_HDKEmail,PRE_HDKURL,
     PRE_MstIdMLD,PRE_MstIdZAM,PRE_MstIdKOR,
     PRE_MstPocztaMLD,PRE_MstPocztaZAM,PRE_MstPocztaKOR,PRE_MstMiejsceUr,
     PRE_ABSData,PRE_ABSChor35,PRE_ABSChor90,PRE_ABSChor6M,PRE_ABSOP60,PRE_ABSOP14,PRE_ABSUrlMiesKorekta,PRE_ABSUrlMies,PRE_ABSChorMiesKorekta,
     PRE_ABSPrawoZasChorOd,PRE_ABSFinansowanePracodawcaOd,PRE_IndywDRA,PRE_KatId,PRE_KategoriaOpis,
     PRE_KontoKsiegowe,PRE_WaznoscBadanOkres,
     PRE_LimitNadgodzin,PRE_IndywLimitNadgodzin,PRE_KodWyksztPFRON,PRE_HDKWiekEmerData,
     PRE_AdresDzialu,PRE_Opis,PRE_ETANormaDobowa,
     PRE_HDKRodzajMiejsc,PRE_UBZOgraniczSklZdrow,PRE_ABSLimitLiczbaDni,PRE_ABSProcWynChorFlaga,PRE_ABSProcWynChor,PRE_ETAPodstZdrowMnoznik,
     PRE_ETAIndywProcWypad,PRE_ETAIndywProcWypadProcent,PRE_HDKGUSGlowneMiejscePracy,PRE_HDKGUSPierwszaPraca,PRE_HDKGUSPoraNocna,PRE_HDKGUSPracSezonowy,
     PRE_NieRozliczac,PRE_DabId,
     PRE_NieNaliczacFP,PRE_NieNaliczacFGSP,PRE_PelneDaneAdresowePFRON,PRE_PomocPublicznaPFRON,PRE_WzrostZatrudnieniaPFRON,
     PRE_ZatrudRozwUmowyPFRON,PRE_ABSFinansowanePracodawca,PRE_ABSFinansowanePracodawcaDni,
     PRE_KodFEP,PRE_FEPOd,PRE_FEPDo,PRE_FPOd,PRE_FPDo,PRE_FGSPOd,PRE_FGSPDo,
     PRE_Oddelegowany,PRE_OddelegowanyDieta,PRE_OddelegowanyWaluta,PRE_OddelegowanyZUS,PRE_OddelegowanyFIS,PRE_WychPodstEmerRentOd,PRE_WychPodstEmerRentMax,
     PRE_RodzajDokumentu,PRE_PODNieLiczKoszty50,PRE_ETADkmIdStanowisko,PRE_ETADkmIdFunkcja,PRE_DkmIdKodZawodu,PRE_ETADkmIdWypowPowod,PRE_DkmIdPracodawca,
     PRE_Tymczasowy,PRE_ZastepowanyId,PRE_Zastepowany,PRE_ZastepowanyLista,PRE_ABSPierwszyLimit,PRE_Przelozony,PRE_ZamZamiastMld,PRE_TelefonSms,
     PRE_OpeZalId, PRE_OpeZalKod, PRE_OpeZalNazwisko, PRE_StaZalId,PRE_TS_Zal,PRE_OpeModId, PRE_OpeModKod, PRE_OpeModNazwisko, PRE_StaModId,PRE_TS_Mod
     )
    values
     (
     NULL, @NewPraId, 3, 3, 3, 1, NULL, 99999, 0,
     NULL, NULL, NULL,
     @Kod, @Nazwisko, @Imie, @Pesel, 0, @OkresOd, @OkresDo,
     NULL, NULL, '', 0, 0, 0, '', 0,
     '', '', '', '', '',
     @DataUrodzenia, '', 'POLSKIE', cdn.PodajPlec(@Imie, @Pesel), '',
     cdn.DomyslnyKraj(@MldKraj), @MldWojewodztwo, @MldPowiat, @MldGmina, @MldUlica, @MldNrDomu, @MldNrLokalu, @MldMiasto,
     @MldKodPocztowy, @MldPoczta, '', 0,
     @Telefon1, @Telefon2, '', @NIP, '', '', NULL, NULL, '', '',
     cdn.DomyslnyKraj(@KorKraj), @KorWojewodztwo, @KorPowiat, @KorGmina, @KorUlica, @KorNrDomu, @KorNrLokalu, @KorMiasto,
     @KorKodPocztowy, @KorPoczta, '',
     cdn.DomyslnyKraj(@ZamKraj), @ZamWojewodztwo, @ZamPowiat, @ZamGmina, @ZamUlica, @ZamNrDomu, @ZamNrLokalu, @ZamMiasto,
     @ZamKodPocztowy, @ZamPoczta, '',
     @Fax, '', '', '', '', '',
     '1',
     1, 1, 1, 0, 0, NULL,
     NULL, NULL, NULL,
     '', '', '', '', '', '',
     0, NULL, '', 0, '', 1, 1,
     0, NULL, 0, 0, 0, 0, 1,
     0, 100,
     '', 0, NULL, NULL, 0, 0,
     1, NULL, NULL, 0, NULL, NULL,
     0, '', NULL, NULL,
     '', NULL, /*KasaChorData*/
     NULL, 0, 0, 0, 0,
     NULL, NULL, NULL, NULL, NULL, 0,
     NULL, NULL, NULL, NULL, NULL,
     NULL, NULL, NULL, NULL, NULL,
     0, 0, 0, 0,
     NULL, NULL, NULL, NULL, NULL, 0,
     @Opis, 0, '', @EMail, @URL,
     NULL, NULL, NULL,
     NULL, NULL, NULL, NULL,
     NULL, 0, 0, 0, 0, 0, 0, 0, 0,
     NULL, NULL, 0, NULL /*KatId*/, '',
     '', NULL,
     NULL, 0, 0, NULL,
     '1', '', convert(datetime, '1899-12-30 08:00:00.000', 120),
     0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, NULL,
     0, 0, 0, 1, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL,
     0, 0, '', 1, 1, NULL, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, 0, NULL, '', 0, 0, '', 0, @Telefon3,
     @OpeId, @OpeModKod, @OpeModNazwisko, null, getdate(), @OpeId, @OpeModKod, @OpeModNazwisko, null, getdate()
     )
   declare @NewPreId int
   set @NewPreId = 0
   select @NewPreId = PRE_PreId from CDN.PracEtaty
    where PRE_PraId = @NewPraId and PRE_DataDo = @OkresDo
   --[logowanie]
   declare @obj_name nvarchar(128)
   set @obj_name = '[' + @Kod + '] ' + @Imie + ' ' + @Nazwisko
   declare @oid int
   set @oid = cdn.GetAltumOperatorID()
   if @oid > 0
   begin
    exec CDN.RejestrOperacjiContextInfo @oid
    exec CDN.RejestrOperacjiDodaj 24000, 0, @NewPreId, @obj_name, 1, ''
   end
   if @NewPreId > 0
   begin
    insert into cdn.SchematPlatnosci
    (
     SPL_PodmiotTyp, SPL_PodmiotID, SPL_OdbPodmiotTyp, SPL_OdbPodmiotID, SPL_FplId, SPL_BnaId,
     SPL_Rodzaj, SPL_Kwota, SPL_Procent, SPL_RachunekNr, SPL_IBAN, SPL_LiczbaPorz, SPL_Reszta, SPL_Opis,
     SPL_OpeZalID, SPL_StaZalId, SPL_TS_Zal, SPL_OpeModID, SPL_StaModId, SPL_TS_Mod
    )
    values
    (
     3, @NewPreId, 3, @NewPreId, 1, NULL,
     0, 0, 100, '', 0, 1, 1, NULL,
     null, null, getdate(), null, null, getdate()
    )
    insert into cdn.OpisKadry
    (
     OPK_RodzajZrodla, OPK_ZrodloId, OPK_PraId, OPK_DzlId, OPK_PrjId, OPK_Procent
    )
    values
    (
     16, @NewPreId, @NewPraId, 3, 1, 100
    )
    execute cdn.AktualizujPracIdx @NewPraId, 0, 0, 0
   end
  end
  end try
  begin catch
   set @Throw = '##OPT32391##'
  end catch
 set nocount off
