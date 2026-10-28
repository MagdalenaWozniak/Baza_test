Create procedure [CDN].OAktualizujCentraPracownika
@IdCentrum int, -- nowe id centrum ktore trzeba przypisac do zapisow prc
@IdPracownika int,--id pracownika w optimie
@OkresOd datetime --nowy okresod z xl'a
as
set nocount on
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
declare @AdCentrum nvarchar(512)
set @AdCentrum = (select CNT_AdresWezla from cdn.Centra where CNT_CntId = @IdCentrum)
if exists (select PRE_PraId from cdn.PracEtaty where PRE_PraId = @IdPracownika and @OkresOd > PRE_DataOd and @OkresOd < PRE_DataDo)
begin
declare @PreId int
declare @dDo datetime
set @PreId = (select Pre_preId from cdn.PracEtaty where PRE_PraId = @IdPracownika and @OkresOd between PRE_DataOd and PRE_DataDo)
set @dDo = (select PRE_DataDo from cdn.PracEtaty where PRE_PreId = @PreId)
update cdn.PracEtaty
     set
  PRE_DataDo = dateadd(day,-1,@OkresOd)
     where
      PRE_PreId = @PreId
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
     PRE_OpeZalId,PRE_StaZalId,PRE_TS_Zal,PRE_OpeModId,PRE_StaModId,PRE_TS_Mod, PRE_FlotaPrawa, PRE_FlotaOperator
     )
   select PRE_ZrgId,PRE_PraId,PRE_PodmiotTyp,PRE_DzlId,PRE_CntId,PRE_KalId,PRE_ETATwpId,PRE_UBZTyuId,PRE_TypPracownika,
     PRE_WlascicielId,PRE_BnaId,PRE_FplId,
     PRE_Kod,PRE_Nazwisko,PRE_Imie1,PRE_Pesel,PRE_ETARodzajZatrudnienia,@OkresOd,@dDo,
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
     PRE_OpeZalId,PRE_StaZalId,PRE_TS_Zal,PRE_OpeModId,PRE_StaModId,PRE_TS_Mod,PRE_FlotaPrawa, PRE_FlotaOperator from cdn.PracEtaty where PRE_PreId = @PreId
    declare @newPreId int
  set @newPreId = scope_identity()
  INSERT INTO [CDN].[SchematPlatnosci]
           ([SPL_PodmiotTyp]
           ,[SPL_PodmiotID]
           ,[SPL_OdbPodmiotTyp]
           ,[SPL_OdbPodmiotID]
           ,[SPL_FplId]
           ,[SPL_BnaId]
           ,[SPL_Rodzaj]
           ,[SPL_Kwota]
           ,[SPL_Procent]
           ,[SPL_RachunekNr]
           ,[SPL_IBAN]
           ,[SPL_LiczbaPorz]
           ,[SPL_Reszta]
           ,[SPL_Opis]
           ,[SPL_OpeZalID]
           ,[SPL_StaZalId]
           ,[SPL_TS_Zal]
           ,[SPL_OpeModID]
           ,[SPL_StaModId]
           ,[SPL_TS_Mod])
 select [SPL_PodmiotTyp]
           ,@newPreId
           ,[SPL_OdbPodmiotTyp]
           ,@newPreId
           ,[SPL_FplId]
           ,[SPL_BnaId]
           ,[SPL_Rodzaj]
           ,[SPL_Kwota]
           ,[SPL_Procent]
           ,[SPL_RachunekNr]
           ,[SPL_IBAN]
           ,[SPL_LiczbaPorz]
           ,[SPL_Reszta]
           ,[SPL_Opis]
           ,null
           ,null
           ,getdate()
           ,null
           ,null
           ,getdate()
    from [CDN].[SchematPlatnosci] where
    SPL_PodmiotTyp = 3 and [SPL_PodmiotID] = @PreId
 insert into cdn.OpisKadry
    (
     OPK_RodzajZrodla, OPK_ZrodloId, OPK_PraId, OPK_DzlId, OPK_PrjId, OPK_Procent
    )
 select  OPK_RodzajZrodla, @newPreId, OPK_PraId, OPK_DzlId, OPK_PrjId, OPK_Procent
 from cdn.OpisKadry
 where OPK_RodzajZrodla = 16 and OPK_ZrodloId = @PreId
end
update cdn.PracEtaty
     set
  PRE_CntId = @IdCentrum, PRE_AdresCentrum = @AdCentrum
     where
      PRE_PraId = @IdPracownika and PRE_DataOd >= @OkresOd
 execute cdn.AktualizujPracIdx @IdPracownika,0,0,0
set nocount off
