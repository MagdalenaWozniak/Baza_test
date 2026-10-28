CREATE PROCEDURE [CDN].[DetalStan_PobierzOperatorow]
@posId int,
@onlyActive tinyint
AS
BEGIN
SET NOCOUNT ON
IF @onlyActive = 1
BEGIN
 SELECT DSOpe_DSOpeID
      ,DSOpe_StanDetalID
      ,DSOpe_OptimaId
      ,DSOpe_Kod
      ,DSOpe_Nazwisko
      ,DSOpe_KodDlaDF
      ,DSOpe_Haslo
      ,DSOpe_NTSid
      ,DSOpe_NTKonto
      ,DSOpe_NTLogin
      ,DSOpe_OpeNieAktywny
      ,DSOpe_KodFunkcji
      ,DSOpe_ZmianaCenySprzedazy
      ,DSOpe_PrawoDoRabatowPozycja
      ,DSOpe_PrawoDoRabatowDokument
      ,DSOpe_StornoOstatniejPozycji
      ,DSOpe_StornoCalegoParagonu
      ,DSOpe_WplataDoKasy
      ,DSOpe_WyplataZKasy
      ,DSOpe_ReczneOtwarcieSzuflady
      ,DSOpe_RaportFiskalny
      ,DSOpe_RaportOkresowy
      ,DSOpe_PodgladStanuKasy
      ,DSOpe_PlatnoscInnymiFormami
      ,DSOpe_ZwrotTowaru
      ,DSOpe_FakturaDoParagonu
      ,DSOpe_PodgladDokWlasnych
      ,DSOpe_PodgladDokWszystkich
      ,DSOpe_KonfiguracjaProgramu
      ,DSOpe_KonfiguracjaInterfejsu
      ,DSOpe_OtwarcieZmiany
      ,DSOpe_ZamkniecieZmiany
      ,DSOpe_PrzekazanieParagonow
      ,DSOpe_EdycjaParagonow
      ,DSOpe_StanWszystkieMagazyny
      ,DSOpe_NieokreslonyPlatOdroczona
   ,DSOpe_ZmianaJM
      ,DSOpe_Karta
      ,DSOpe_MaxRabat
      ,DSOpe_TS_Mod
      ,DSOpe_DataLogowania
   ,DSOpe_ZmianaJM
   ,DSOpe_KontoDomenowe
   ,DSOpe_KontoDomenoweSID FROM CDN.DetalStanOperatorzy
 WHERE DSOpe_StanDetalID = @posId AND DSOpe_OpeNieAktywny = 0
END
ELSE
BEGIN
 SELECT DSOpe_DSOpeID
      ,DSOpe_StanDetalID
      ,DSOpe_OptimaId
      ,DSOpe_Kod
      ,DSOpe_Nazwisko
      ,DSOpe_KodDlaDF
      ,DSOpe_Haslo
      ,DSOpe_NTSid
      ,DSOpe_NTKonto
      ,DSOpe_NTLogin
      ,DSOpe_OpeNieAktywny
      ,DSOpe_KodFunkcji
      ,DSOpe_ZmianaCenySprzedazy
      ,DSOpe_PrawoDoRabatowPozycja
      ,DSOpe_PrawoDoRabatowDokument
      ,DSOpe_StornoOstatniejPozycji
      ,DSOpe_StornoCalegoParagonu
      ,DSOpe_WplataDoKasy
      ,DSOpe_WyplataZKasy
      ,DSOpe_ReczneOtwarcieSzuflady
      ,DSOpe_RaportFiskalny
      ,DSOpe_RaportOkresowy
      ,DSOpe_PodgladStanuKasy
      ,DSOpe_PlatnoscInnymiFormami
      ,DSOpe_ZwrotTowaru
      ,DSOpe_FakturaDoParagonu
      ,DSOpe_PodgladDokWlasnych
      ,DSOpe_PodgladDokWszystkich
      ,DSOpe_KonfiguracjaProgramu
      ,DSOpe_KonfiguracjaInterfejsu
      ,DSOpe_OtwarcieZmiany
      ,DSOpe_ZamkniecieZmiany
      ,DSOpe_PrzekazanieParagonow
      ,DSOpe_EdycjaParagonow
      ,DSOpe_StanWszystkieMagazyny
      ,DSOpe_NieokreslonyPlatOdroczona
   ,DSOpe_ZmianaJM
      ,DSOpe_Karta
      ,DSOpe_MaxRabat
      ,DSOpe_TS_Mod
      ,DSOpe_DataLogowania
   ,DSOpe_KontoDomenowe
   ,DSOpe_KontoDomenoweSID FROM CDN.DetalStanOperatorzy
 WHERE DSOpe_StanDetalID = @posId
END
SET NOCOUNT OFF
END
