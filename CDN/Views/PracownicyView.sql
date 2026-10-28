create view CDN.PracownicyView
(
 PracSynchId,
 PracId,
 Kod, Nazwisko, Imie,
 NIP, Pesel,
 URL, Opis, Aktywny,
 MldKraj, MldWojewodztwo, MldUlica, MldNrDomu, MldNrLokalu, MldMiasto, MldKodPocztowy, MldPoczta, MldGmina, MldPowiat,
 ZamKraj, ZamWojewodztwo, ZamUlica, ZamNrDomu, ZamNrLokalu, ZamMiasto, ZamKodPocztowy, ZamPoczta, ZamGmina, ZamPowiat,
 KorKraj, KorWojewodztwo, KorUlica, KorNrDomu, KorNrLokalu, KorMiasto, KorKodPocztowy, KorPoczta, KorGmina, KorPowiat,
 Telefon1, Telefon2, Telefon3, Fax, EMail
)
as
select
 PRA_ImportRowId,
 PRE_PraId,
 PRE_Kod, PRE_Nazwisko, PRE_Imie1,
 PRE_NIPE, PRE_Pesel,
 PRE_HDKURL, PRE_HDKUwagi, PRA_Archiwalny,
 PRE_MLDKraj, PRE_MLDWojewodztwo, PRE_MLDUlica, PRE_MLDNrDomu, PRE_MLDNrLokalu, PRE_MLDMiasto, PRE_MLDKodPocztowy, PRE_MLDPoczta, PRE_MLDGmina, PRE_MLDPowiat,
 PRE_ZAMKraj, PRE_ZAMWojewodztwo, PRE_ZAMUlica, PRE_ZAMNrDomu, PRE_ZAMNrLokalu, PRE_ZAMMiasto, PRE_ZAMKodPocztowy, PRE_ZAMPoczta, PRE_ZAMGmina, PRE_ZAMPowiat,
 PRE_KORKraj, PRE_KORWojewodztwo, PRE_KORUlica, PRE_KORNrDomu, PRE_KORNrLokalu, PRE_KORMiasto, PRE_KORKodPocztowy, PRE_KORPoczta, PRE_KORGmina, PRE_KORPowiat,
 PRE_HDKTelefon1, PRE_HDKTelefon2, PRE_TelefonSMS, PRE_HDKFax, PRE_HDKEmail
 from CDN.PracEtaty inner join cdn.PracKod on PRE_PraId = PRA_PraId
 where
  PRE_DataDo >= convert(datetime, '2999-12-31', 120)
