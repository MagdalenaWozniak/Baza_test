CREATE  PROCEDURE [CDN].[DetalStan_AktualizujOperatorow]
 @StanDetalID int,
 @OptimaId int,
 @Kod NVARCHAR(20),
 @Nazwisko NVARCHAR(50),
 @KodDlaDF NVARCHAR(10),
 @KodFunkcji NVARCHAR(20),
 @ZmianaCenySprzedazy tinyint,
 @PrawoDoRabatowPozycja tinyint,
 @PrawoDoRabatowDokument tinyint,
 @StornoOstatniejPozycji tinyint,
 @StornoCalegoParagonu tinyint,
 @WplataDoKasy tinyint,
 @WyplataZKasy tinyint,
 @ZamkniecieZmiany tinyint,
 @ReczneOtwarcieSzuflady tinyint,
 @RaportFiskalny tinyint,
 @RaportOkresowy tinyint,
 @PodgladStanuKasy tinyint,
 @PlatnoscInnymiFormami tinyint,
 @ZwrotTowaru tinyint,
 @FakturaDoParagonu tinyint,
 @PodgladDokWlasnych tinyint,
 @PodgladDokWszystkich tinyint,
 @KonfiguracjaProgramu tinyint,
 @KonfiguracjaInterfejsu tinyint,
 @OtwarcieZmiany tinyint,
 @PrzekazanieParagonow tinyint,
 @EdycjaParagonow tinyint,
 @StanWszystkieMagazyny tinyint,
 @NieokreslonyPlatOdroczona tinyint,
 @ZmianaJM tinyint,
 @DateTSSynchr datetime,
 @KontoDomenowe VARCHAR(100),
 @KontoDomenoweSID VARCHAR(200)
AS
SET NOCOUNT ON
DECLARE
  @DSOpe_DSOpeID INT
 --nieaktywny dla wszystkich operatorow
 UPDATE CDN.DetalStanOperatorzy SET DSOpe_OpeNieAktywny = 1 Where DSOpe_OpeNieAktywny = 0 and DSOpe_StanDetalID = @StanDetalID and  DSOpe_TS_Mod < @DateTSSynchr
  SELECT @DSOpe_DSOpeID = DSOpe_DSOpeID
    FROM CDN.DetalStanOperatorzy
    WHERE DSOpe_OptimaId = @OptimaId and DSOpe_StanDetalID = @StanDetalID
  IF @DSOpe_DSOpeID IS NULL
    BEGIN
INSERT INTO CDN.DetalStanOperatorzy
           (DSOpe_StanDetalID
            ,DSOpe_OptimaId
           ,DSOpe_Kod
           ,DSOpe_Nazwisko
           ,DSOpe_KodDlaDF
           ,DSOpe_Haslo
           ,DSOpe_OpeNieAktywny
           ,DSOpe_KodFunkcji
           ,DSOpe_ZmianaCenySprzedazy
           ,DSOpe_PrawoDoRabatowPozycja
           ,DSOpe_PrawoDoRabatowDokument
           ,DSOpe_StornoOstatniejPozycji
           ,DSOpe_StornoCalegoParagonu
           ,DSOpe_WplataDoKasy
           ,DSOpe_WyplataZKasy
           ,DSOpe_ZamkniecieZmiany
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
           ,DSOpe_TS_Mod
           ,DSOpe_NTSid
           ,DSOpe_NTKonto
           ,DSOpe_NTLogin
           ,DSOpe_OtwarcieZmiany
           ,DSOpe_PrzekazanieParagonow
           ,DSOpe_EdycjaParagonow
           ,DSOpe_StanWszystkieMagazyny
           ,DSOpe_Karta
           ,DSOpe_DataLogowania
           ,DSOpe_NieokreslonyPlatOdroczona
     ,DSOpe_ZmianaJM
     ,DSOpe_KontoDomenowe
     ,DSOpe_KontoDomenoweSID )
     VALUES (
            @StanDetalID,
            @OptimaId,
            @Kod,
            @Nazwisko,
            @KodDlaDF,
            '',
            0,
            @KodFunkcji,
            @ZmianaCenySprzedazy,
            @PrawoDoRabatowPozycja,
            @PrawoDoRabatowDokument,
            @StornoOstatniejPozycji,
            @StornoCalegoParagonu,
            @WplataDoKasy,
            @WyplataZKasy,
            @ZamkniecieZmiany,
            @ReczneOtwarcieSzuflady,
            @RaportFiskalny,
            @RaportOkresowy,
            @PodgladStanuKasy,
            @PlatnoscInnymiFormami,
            @ZwrotTowaru,
            @FakturaDoParagonu,
            @PodgladDokWlasnych,
            @PodgladDokWszystkich,
            @KonfiguracjaProgramu,
            @KonfiguracjaInterfejsu,
            @DateTSSynchr,
            '',
            '',
            '',
            @OtwarcieZmiany,
            @PrzekazanieParagonow,
            @EdycjaParagonow,
            @StanWszystkieMagazyny,
            '',
            0,
           @NieokreslonyPlatOdroczona,
     @ZmianaJM,
     @KontoDomenowe,
     @KontoDomenoweSID)
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalStanOperatorzy
           SET
            DSOpe_OptimaId = @OptimaId
           ,DSOpe_Kod = @Kod
           ,DSOpe_Nazwisko = @Nazwisko
           ,DSOpe_KodFunkcji = @KodFunkcji
           ,DSOpe_OpeNieAktywny = 0
           ,DSOpe_ZmianaCenySprzedazy = @ZmianaCenySprzedazy
           ,DSOpe_PrawoDoRabatowPozycja = @PrawoDoRabatowPozycja
           ,DSOpe_PrawoDoRabatowDokument = @PrawoDoRabatowDokument
           ,DSOpe_StornoOstatniejPozycji = @StornoOstatniejPozycji
           ,DSOpe_StornoCalegoParagonu = @StornoCalegoParagonu
           ,DSOpe_WplataDoKasy = @WplataDoKasy
           ,DSOpe_WyplataZKasy = @WyplataZKasy
           ,DSOpe_ZamkniecieZmiany = @ZamkniecieZmiany
           ,DSOpe_ReczneOtwarcieSzuflady = @ReczneOtwarcieSzuflady
           ,DSOpe_RaportFiskalny = @RaportFiskalny
           ,DSOpe_RaportOkresowy = @RaportOkresowy
           ,DSOpe_PodgladStanuKasy = @PodgladStanuKasy
           ,DSOpe_PlatnoscInnymiFormami = @PlatnoscInnymiFormami
           ,DSOpe_ZwrotTowaru = @ZwrotTowaru
           ,DSOpe_FakturaDoParagonu = @FakturaDoParagonu
           ,DSOpe_PodgladDokWlasnych = @PodgladDokWlasnych
           ,DSOpe_PodgladDokWszystkich = @PodgladDokWszystkich
           ,DSOpe_KonfiguracjaProgramu = @KonfiguracjaProgramu
           ,DSOpe_KonfiguracjaInterfejsu = @KonfiguracjaInterfejsu
           ,DSOpe_TS_Mod = @DateTSSynchr
           ,DSOpe_KodDlaDF = @KodDlaDF
           ,DSOpe_OtwarcieZmiany = @OtwarcieZmiany
           ,DSOpe_PrzekazanieParagonow = @PrzekazanieParagonow
           ,DSOpe_EdycjaParagonow = @EdycjaParagonow
           ,DSOpe_StanWszystkieMagazyny = @StanWszystkieMagazyny
           ,DSOpe_NieokreslonyPlatOdroczona = @NieokreslonyPlatOdroczona
     ,DSOpe_ZmianaJM = @ZmianaJM
     ,DSOpe_KontoDomenowe = @KontoDomenowe
     ,DSOpe_KontoDomenoweSID  = @KontoDomenoweSID
  WHERE @DSOpe_DSOpeID = DSOpe_DSOpeID
      END
  SET NOCOUNT OFF
