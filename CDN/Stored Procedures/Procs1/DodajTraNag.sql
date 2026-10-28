-- Tworzenie nagłówka dokumentu WZ/PZ, WKA/PKA, Ofertowanie, FPF z Oferty
CREATE PROCEDURE CDN.DodajTraNag
  @TrN_TrNId_Zrd_List TEXT,          -- TrN_TrNId nagłówka do dodania lub do skopiowania (może być NULL, jeśli @TrN_Rodzaj_Doc IS NOT NULL AND @TrN_MagZrdId_Doc IS NOT NULL)
  @TrN_Rodzaj_Doc     INT,           -- TrN_Rodzaj dokumentu docelowego (może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
  @TrN_MagZrdId_Doc   INT,           -- TrN_MagZrdId dokumentu docelowego (może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
  @TrN_DataDok_Doc    DATETIME,      --
  @TrN_DataWys_Doc    DATETIME,      --
  @TrN_DataOpe_Doc    DATETIME,      --
  @ServerCfgString    NVARCHAR(250),  -- nazwa serwera z bazą konfiguracyjną
  @BazaCfgString      NVARCHAR(250),  -- nazwa bazy konfiguracyjnej
  @TrN_OpeZalId_Doc   INT,           -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
  @TrN_StaZalId_Doc   INT,           -- Sanowisko, z którego jest wykonywana operacja przekształcenia
  @DataToday          NVARCHAR(100),  -- Data Today z programu (może być inna niż z serwera)
  @Kontekst           INT,           -- Kontekst wywołania: 0 - WZ/PZ/WKA/PKA z formularza, 1 - WZ/PZ/WKA/PKA z listy, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
  @Seria              NVARCHAR(20) = '',
  @TrN_TrNId_Doc      INT OUTPUT     -- zwracany  TrN_TrNId dokumentu docelowego
AS
  SET NOCOUNT ON
   declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @TrN_OpeZalId_Doc, @OpeZalKod OUT, @OpeZalNazwisko OUT
  DECLARE
    -- numery dokumentów docelowych
    @TrN_NumerString_Doc  NVARCHAR(31),
    @TrN_NumerNr_Doc      INT,
    @PFzRO                INT,
    -- daty today z czasem i bez czasu
    @DataTodayNoTime      DATETIME,
    @DataTodayWithTime    DATETIME,
    -- do wyliczenia serii dla operatora
    @TrN_DDFId_Doc        INT,
    @SeriaOperatora       NVARCHAR(5),
    @RejestrOperatora     NVARCHAR(20),
    @Komunikat            NVARCHAR(255),
    @TrN_TrNId_Zrd        INT, -- Pojedyncze TrN_TrNId dokumentu do przekonwertowania, gdy jest tylko jeden dokument źródłowy
 @NRObcy      VARCHAR(max),
    @IleRO      INT,
    @KursNumer               NVARCHAR(10),
    @Waluta                  CHAR(3),
    @sqltxt1                 NVARCHAR(1024),
    @FullKnfName             NVARCHAR(512),
    @WalOstrzegaj            NVARCHAR(3),
    @TrN_DataDokChar         NVARCHAR(25),
    @KursLWalutaKoncowa      DECIMAL(15,4),
    @KursMWalutaKoncowa      DECIMAL(5,0),
    @dw                      INT,
    @data                    DATETIME,
    @WalKursL                DECIMAL(15,4),
    @WalKursM                DECIMAL(5,0),
    @Brak                    TINYINT,
 @NumerPelny              NVarchar(30),
 @TypDokumentu    int,
 -- piecząta firmy
    @PCID          int,
    @PCIDJS       int
    DECLARE @TrNID TABLE ( TrNId INT)
 insert into @TrNID select NextIdInt from  CDN.Text2TableInt ( @TrN_TrNId_Zrd_List )
 delete from @TrNID where TrNId not in (select trn_trnid from cdn.TraNag join @TrNID on TrN_TrNID = TrNId  join cdn.TraElem on TrE_TrNId = TrN_TrNID where TrE_MagId =  @TrN_MagZrdId_Doc)
  --wielozakladowosc
  declare @zakid int
  IF  ( SELECT ISNULL( MAX(Fir_Wartosc), 0 ) FROM cdn.Firma WHERE Fir_Numer =2240) = 1
 select @zakid = zak_zakid from cdn.Zaklady where Zak_Domyslny = 1
  -- dodanie nagłówka
  SELECT TOP 1 @TrN_TrNId_Zrd = NextIdINT FROM cdn.Text2TableINT ( @TrN_TrNId_Zrd_List )
  -- numery obce
  SET @NRObcy = ''
  SELECT @NRObcy = @NRObcy + CASE WHEN LEN(@NRObcy) = 0 THEN '' ELSE ' ' END + trn_numerobcy
  FROM cdn.tranag where LEN(trn_numerobcy) > 0 and TrN_TrNID in (select TrNId from @TrNID) and TrN_TypDokumentu = 308
  Select @IleRO = COUNT(TrNId) from @TrNID
  if LEN(@NRObcy) > 0 and @IleRO = 1
  select @NRObcy = ' '+@NRObcy
  --kontrola czy mozna wystawic dok na kontrahenta
  if @TrN_Rodzaj_Doc = 306008
  BEGIN
 if (select knt_ZakazDokumentowHaMag from cdn.Kontrahenci join cdn.TraNag on Knt_KntId = TrN_PodID where TrN_TrNID = @TrN_TrNId_Zrd and TrN_PodmiotTyp = 1) = 1
  BEGIN
      SET @Komunikat = '##OPT34110##'--'Dokument nie może być zapisany. Zakaz wystawiania dokumentów rozchodowych dla kontrahenta.'
      GOTO KOMUNIKAT
    END
  END
  -- ustalenie dat
  if @Kontekst = -1 -- zawsze data dzisiejsza
 SET @DataToday = CONVERT(NVARCHAR(10), GETDATE(), 120)
  SET @DataTodayWithTime = CONVERT( DATETIME, GETDATE(), 120 )
  SET @DataTodayNoTime   = CONVERT( DATETIME, SUBSTRING( @DataToday, 1, 10 ), 120 )
  -- musi być ustawiony TrN_TrNId lub TrN_Rodzaj wraz z magazynem źródłowym
  IF @TrN_TrNId_Zrd IS NULL AND ( @TrN_Rodzaj_Doc IS NULL OR @TrN_MagZrdId_Doc IS NULL )
    BEGIN
      SET @Komunikat = '##34463##'--' Nie ustawiono Rodzaju dokumentu docelowego ! '
      GOTO KOMUNIKAT
    END
  -- dane z konfiguracji akcyza
  /*SET @MiejsceOdbAkcyza = ''
  IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=2153 and Fir_Wartosc != '')
 SELECT @MiejsceOdbAkcyza = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=2153
  SET @TrN_Rodzaj_DocAkc = 0;
  if exists (select * from cdn.firma where Fir_Numer = 2161 and Fir_Wartosc > 0)
     and exists(select * from cdn.TraNag where TrN_TrNID = @TrN_TrNId_Zrd and TrN_TypDokumentu IN (302,305)AND TrN_ZwolnionyZAkcyzy= 1 AND TrN_FADokumentDostawy != 1)
     and exists (select * from cdn.TraElem where TrE_TrNID = @TrN_TrNId_Zrd and TrE_AkcyzaOpal > 0)
 SELECT @TrN_Rodzaj_DocAkc = @TrN_Rodzaj_Doc  + 990*/
  -- seria operatora
  SET @TrN_DDFId_Doc = CDN.DomyslnaDefinicja(@TrN_Rodzaj_Doc)
  IF ( SELECT TOP 1 DDf_SeriaOperatora FROM cdn.DokDefinicje WHERE DDF_DDFId = @TrN_DDFId_Doc ) = 1
    EXEC CDN.SeriaOperatora @ServerCfgString, @BazaCfgString, @TrN_OpeZalId_Doc, @SeriaOperatora OUTPUT, @RejestrOperatora OUTPUT
  SET @SeriaOperatora = ISNULL(@SeriaOperatora, '')
  if @Seria <> '' and @SeriaOperatora = ''
   SET @SeriaOperatora = @Seria
  SET @TrN_NumerString_Doc = CDN.NumerString
    (
       @TrN_Rodzaj_Doc,
       @TrN_OpeZalId_Doc,
       @TrN_StaZalId_Doc,
       @TrN_MagZrdId_Doc,
       @TrN_DataDok_Doc,
       @SeriaOperatora,
 default,
 default,
 default
    )
  SET @Komunikat = CDN.SprawdzNumerString ( @TrN_DDFId_Doc, @TrN_NumerString_Doc )
    IF @Komunikat <> '' GOTO KOMUNIKAT
  SELECT @TrN_NumerNr_Doc = ISNULL(MAX(TrN_NumerNr),0) + 1 FROM cdn.TraNag WHERE TrN_NumerString = @TrN_NumerString_Doc
  --pieczatka
  SELECT @PCIDJS = PCJS_PCJSID FROM CDN.PieczatkiJS WHERE case when  CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (307, 313) then @TrN_DataWys_Doc  else @TrN_DataDok_Doc end  BETWEEN PCJS_DataOd AND PCJS_DataDo
  SELECT @PCID = Pc_PCID  FROM CDN.Pieczatki WHERE case when  CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (307, 313) then @TrN_DataWys_Doc  else @TrN_DataDok_Doc end BETWEEN PC_DataOd AND PC_DataDo
  -- WZ/PZ/WKA/PKA
  IF CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (306, 307, 314, 313)
    BEGIN
      INSERT INTO CDN.TraNag
        (
           TrN_DDfId,
           TrN_TypDokumentu,
           TrN_ZwrId,
           TrN_FaId,
           TrN_NumerNr,
           TrN_NumerString,
           TrN_Bufor,
           TrN_VaNId,
           TrN_DataDok,
           TrN_DataWys,
           TrN_DataOpe,
           TrN_NumerObcy,
           TrN_NumerPelnyPrw,
           TrN_Korekta,
           TrN_Fiskalna,
           TrN_FiskalnaErr,
           TrN_Detal,
           TrN_Rodzaj,
           TrN_PodmiotTyp,
           TrN_PodID,
           TrN_PodNazwa1,
           TrN_PodNazwa2,
           TrN_PodNazwa3,
           TrN_PodKraj,
           TrN_PodWojewodztwo,
           TrN_PodPowiat,
           TrN_PodGmina,
           TrN_PodUlica,
           TrN_PodNrDomu,
           TrN_PodNrLokalu,
           TrN_PodMiasto,
           TrN_PodKodPocztowy,
           TrN_PodPoczta,
           TrN_PodAdres2,
           TrN_PodNipKraj,
           TrN_PodNipE,
           TrN_PodmiotGLN,
           TrN_Finalny,
     TrN_PodatekVat,
     TrN_Pesel,
           TrN_Export,
           TrN_OdbiorcaTyp,
           TrN_OdbID,
           TrN_OdbNazwa1,
           TrN_OdbNazwa2,
           TrN_OdbNazwa3,
           TrN_OdbKraj,
           TrN_OdbWojewodztwo,
           TrN_OdbPowiat,
           TrN_OdbGmina,
           TrN_OdbUlica,
           TrN_OdbNrDomu,
           TrN_OdbNrLokalu,
           TrN_OdbMiasto,
           TrN_OdbKodPocztowy,
           TrN_OdbPoczta,
           TrN_OdbAdres2,
           TrN_OdbNipKraj,
           TrN_OdbNipE,
           TrN_OdbiorcaGLN,
           TrN_OdbiorcaDocTyp,
           TrN_OdbDocID,
           TrN_OdbTelefon,
           TrN_OdbEmail,
           TrN_KatID,
           TrN_Kategoria,
           TrN_FPlId,
           TrN_Termin,
           TrN_RazemNetto,
           TrN_RazemVAT,
           TrN_RazemBrutto,
           TrN_RazemNettoWal,
           TrN_RazemVATWal,
           TrN_RazemBruttoWal,
           TrN_Waluta,
           TrN_KursNumer,
           TrN_KursL,
           TrN_KursM,
           TrN_PlatElemWalSys,
           TrN_VatDlaDokWal,
           TrN_PodmiotZalTyp,
           TrN_PodZalId,
           TrN_BlokadaPlatnosci,
           TrN_MagZrdId,
           TrN_MagDocId,
           TrN_TypNB,
           TrN_Rabat,
           TrN_Odebral,
           TrN_Opis,
           TrN_NotaKorPrzed,
           TrN_NotaKorPo,
           TrN_TrSTyp,
           TrN_DekId,
           TrN_TS_Export,
--           TrN_ImportAppId,
           TrN_ImportRowId,
           TrN_OpeZalID,
     TrN_OpeZalKod,
     TrN_OpeZalNazwisko,
           TrN_StaZalId,
           TrN_TS_Zal,
           TrN_OpeModID,
     TrN_OpeModKod,
     TrN_OpeModNazwisko,
           TrN_StaModId,
           TrN_TS_Mod,
           TrN_GIDTyp,
           TrN_GIDFirma,
           TrN_GIDNumer,
           TrN_GIDLp,
           TrN_Centrala,
           TrN_KodTransakcji,
           TrN_IsNId,
           TrN_DataTransportu,
           TrN_KodKraju,
           TrN_Anulowany,
           TrN_TaxFreePotwierdzony,
           TrN_PlatKaucje,
           TrN_RelTrNId,
           TrN_TerminZwrotuKaucji,
           TrN_DataKur,
           TrN_ZwolnionyZAkcyzy,
           TrN_AkcyzaDataOdbioruDo,
           TrN_AkcyzaDataOdbioruOd,
           TrN_AkcyzaDataRozpoczeciaPrzem,
     TrN_PlatnikID,
           TrN_PlatnikTyp,
           TrN_WartoscOO,
           TrN_StawkaNPOO,
     TrN_ZakID,
     TrN_OpeZatwID,
     TrN_OpeZatwKod,
     TrN_OpeZatwNazwisko,
           TrN_TS_Zatw,
     TrN_PCId,
     TrN_PCJSID,
     TrN_DokumentTozsamosci
         )
         SELECT
           @TrN_DDFId_Doc,                      -- TrN_DDfId,
           CONVERT(INT, @TrN_Rodzaj_Doc/1000),                             -- TrN_TypDokumentu,
           TrN_ZwrId,
           CASE                                                            -- TrN_FaId,
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (313, 314) THEN NULL
             ELSE @TrN_TrNId_Zrd
           END,
          @TrN_NumerNr_Doc,                                                -- TrN_NumerNr,
          @TrN_NumerString_Doc,                                            -- TrN_NumerString,
          CASE                                                             -- TrN_Bufor,
            WHEN @Kontekst IN (2,7,8) THEN 1
            ELSE TrN_Bufor
          END,
           NULL,                                                           -- TrN_VaNId,
          @TrN_DataDok_Doc,
          @TrN_DataWys_Doc,
          @TrN_DataOpe_Doc,
           case when @TrN_Rodzaj_Doc = 306008 then '' else TrN_NumerObcy end,
           TrN_NumerPelnyPrw,
           TrN_Korekta,
           0,
           0,
           TrN_Detal,
          @TrN_Rodzaj_Doc,                            -- TrN_Rodzaj,
           TrN_PodmiotTyp,
           TrN_PodID,
           TrN_PodNazwa1,
           TrN_PodNazwa2,
           TrN_PodNazwa3,
           TrN_PodKraj,
           TrN_PodWojewodztwo,
           TrN_PodPowiat,
           TrN_PodGmina,
           TrN_PodUlica,
           TrN_PodNrDomu,
           TrN_PodNrLokalu,
           TrN_PodMiasto,
           TrN_PodKodPocztowy,
           TrN_PodPoczta,
           TrN_PodAdres2,
           TrN_PodNipKraj,
           TrN_PodNipE,
           TrN_PodmiotGLN,
           TrN_Finalny,
     TrN_PodatekVat,
     TrN_Pesel,
           TrN_Export,
           TrN_OdbiorcaTyp,
           TrN_OdbID,
           TrN_OdbNazwa1,
           TrN_OdbNazwa2,
           TrN_OdbNazwa3,
           TrN_OdbKraj,
           TrN_OdbWojewodztwo,
           TrN_OdbPowiat,
           TrN_OdbGmina,
           TrN_OdbUlica,
           TrN_OdbNrDomu,
           TrN_OdbNrLokalu,
           TrN_OdbMiasto,
           TrN_OdbKodPocztowy,
           TrN_OdbPoczta,
           TrN_OdbAdres2,
           TrN_OdbNipKraj,
           TrN_OdbNipE,
           TrN_OdbiorcaGLN,
           TrN_OdbiorcaDocTyp,
           TrN_OdbDocID,
           TrN_OdbTelefon,
           TrN_OdbEmail,
           TrN_KatID,
           TrN_Kategoria,
           TrN_FPlId,
           CASE                                                   -- TrN_Termin,
             WHEN @TrN_Rodzaj_Doc = 306008 THEN   @TrN_DataWys_Doc + (TrN_Termin - TrN_DataDok)
             -- WZ/PZ - nie naliczamy płatności nigdy
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN ( 306, 307 ) THEN  TrN_Termin
             -- WKA/PKA z formularza lub z listy - naliczamy płatności zgodnie z dokumentem źródłowym
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 ) AND @Kontekst IN ( 0, 1 ) THEN TrN_Termin
             -- WKA/PKA z formularza lub z listy - naliczamy płatności zgodnie z dokumentem źródłowym
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 ) AND @Kontekst IN ( 2 ) THEN  @TrN_DataWys_Doc + (TrN_Termin - TrN_DataWys)
             -- w pozostałych przypadkach blokada płatności
             ELSE TrN_Termin
           END,
           TrN_RazemNetto,
           TrN_RazemVAT,
           TrN_RazemBrutto,
           TrN_RazemNettoWal,
           TrN_RazemVATWal,
           TrN_RazemBruttoWal,
           TrN_Waluta,
           TrN_KursNumer,
           TrN_KursL,
           TrN_KursM,
           TrN_PlatElemWalSys,
           TrN_VatDlaDokWal,
           TrN_PodmiotZalTyp,
           TrN_PodZalId,
           CASE                                                   -- TrN_BlokadaPlatnosci,
             -- WZ/PZ - nie naliczamy płatności nigdy
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN ( 306, 307 ) THEN  1
             -- WKA/PKA z formularza lub z listy - naliczamy płatności zgodnie z dokumentem źródłowym
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 ) AND @Kontekst IN ( 0, 1 ) THEN  ABS(ISNULL(TrN_PlatKaucje,0) - 1)
             -- WKA/PKA jako nowe z listy FA/FZ - naliczamy płatności zgodnie z domyślnym ustawieniem na karcie kontrahenta
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 ) AND @Kontekst IN ( 2 ) THEN ABS(ISNULL(Knt_NaliczajPlatnosc,0) - 1)
             -- w pozostałych przypadkach blokada płatności
             ELSE 1
           END,
           @TrN_MagZrdId_Doc,
           NULL,
           CASE             -- TrN_TypNB,
             -- WZ/PZ - nie naliczamy płatności nigdy
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 ) THEN  2
             ELSE TrN_TypNB
           END,
           TrN_Rabat,
           TrN_Odebral,
           case when @IleRO = 1 then SUBSTRING(TrN_Opis + @NRObcy, 1, 1024) else SUBSTRING( @NRObcy, 1, 1024) end,
           TrN_NotaKorPrzed,
           TrN_NotaKorPo,
           CASE                                                              -- TrN_TrSTyp,
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN ( 313, 314 ) THEN 0
             ELSE TrN_TrSTyp
           END,
           NULL,                                      -- TrN_DekId,
           NULL,
--           TrN_ImportAppId,
          NewId(),                                    --TrN_ImportRowId,
          @TrN_OpeZalId_Doc,                          -- TrN_OpeZalId
    @OpeZalKod,
    @OpeZalNazwisko,
          @TrN_StaZalId_Doc,                          -- TrN_StaZalId,
          @DataTodayWithTime,                         -- TrN_TS_Zal,
          @TrN_OpeZalId_Doc,                          -- TrN_OpeModID,
    @OpeZalKod,
    @OpeZalNazwisko,
          @TrN_StaZalId_Doc,                          -- TrN_StaModId,
          @DataTodayWithTime,                         -- TrN_TS_Mod,
           NULL,
           NULL,
           NULL,
           NULL,
           TrN_Centrala,
           TrN_KodTransakcji,
           TrN_IsNId,
           @TrN_DataOpe_Doc,
           TrN_KodKraju,
           TrN_Anulowany,
           TrN_TaxFreePotwierdzony,
           0,
           CASE                                       -- TrN_RelTrNId,
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (313, 314) THEN @TrN_TrNId_Zrd
             ELSE NULL
           END,
           CASE
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (313, 314) AND @Kontekst IN (0,1) THEN TrN_TerminZwrotuKaucji
             WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (313, 314) AND @Kontekst IN (2)   THEN @TrN_DataWys_Doc + ISNULL(Knt_TerminZwrotuKaucji,0)
             ELSE NULL
           END,
           TrN_DataKur,
           TrN_ZwolnionyZAkcyzy,
           CASE
             WHEN TrN_AkcyzaDataOdbioruDo IS NULL THEN TrN_DataOpe
             ELSE TrN_AkcyzaDataOdbioruDo
           END,
           CASE
             WHEN TrN_AkcyzaDataOdbioruOd IS NULL THEN TrN_DataOpe
             ELSE TrN_AkcyzaDataOdbioruOd
           END,
           CASE
             WHEN TrN_AkcyzaDataRozpoczeciaPrzem IS NULL THEN TrN_DataOpe
             ELSE TrN_AkcyzaDataRozpoczeciaPrzem
           END,
      TrN_PlatnikID,
           TrN_PlatnikTyp,
           TrN_WartoscOO,
           TrN_StawkaNPOO,
     @zakid,
     CASE
            WHEN @Kontekst IN (2,7,8) or TrN_Bufor = 1 THEN NULL
            ELSE @TrN_OpeZalId_Doc
           END,
     CASE
            WHEN @Kontekst IN (2,7,8) or TrN_Bufor = 1 THEN ''
            ELSE @OpeZalKod
           END,
     CASE
            WHEN @Kontekst IN (2,7,8) or TrN_Bufor = 1 THEN ''
            ELSE @OpeZalNazwisko
           END,
     CASE
            WHEN @Kontekst IN (2,7,8) or TrN_Bufor = 1 THEN NULL
            ELSE @DataTodayWithTime
           END,
     CASE WHEN @Kontekst IN (1,2) THEN @PCId else TrN_PCId end,
     CASE WHEN @Kontekst IN (1,2) THEN @PCIdJS else TrN_PCJSID end,
     TrN_DokumentTozsamosci
         FROM cdn.TraNag
           LEFT OUTER JOIN cdn.Kontrahenci ON TrN_PodmiotTyp = Knt_PodmiotTyp AND TrN_PodId = Knt_KntId
         WHERE TrN_TrNId = @TrN_TrNId_Zrd
      -- TrN_TrNId nowego dokumentu i relacje
      --SELECT @TrN_TrNId_Doc = ISNULL(MAX(TrN_TrNId),0) FROM cdn.TraNag //RT
      SET @TrN_TrNId_Doc = SCOPE_IDENTITY()
   --logi
      select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
      exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 1, ''
   if exists (select * from cdn.tranag where trn_trnid = @TrN_TrNId_Doc and trn_bufor = 0)
  exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 103, ''
    select @KursNumer = TrN_KursNumer,@Waluta = TrN_Waluta  from cdn.TraNag where TrN_TrNID = @TrN_TrNId_Doc
   if @TrN_Rodzaj_Doc = 306008  and ISNULL(@Waluta, '') <> ''
   BEGIN
   --pobranie notowania
  set @data = @TrN_DataDok_Doc - 1
     SELECT @dw = ( (DATEPART(dw, @data) + @@DATEFIRST-2) % 7 + 1)
    if  @dw = 7
       SET @data = @data-2
    if  @dw = 6
       SET @data = @data-1
  if @KursNumer != 1
     begin
     SELECT @TrN_DataDokChar    = CONVERT(NVARCHAR(25), @data, 102)
     SET @FullKnfName = CDN.GetFullKnfName()
     -- 1 = "Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)"
     IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 )
    SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540
     ELSE
    SELECT @WalOstrzegaj=1
     SET @sqltxt1 = 'EXEC ' + @FullKnfName + '.CDN.PobierzNotowania '''','+@KursNumer+','''+ @TrN_DataDokChar+''','+ @WalOstrzegaj+',1'
     CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta NVARCHAR(3) PRIMARY KEY, KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
     INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
     EXEC sp_executesql @sqltxt1
     -- istnienie waluty transakcji
     IF ISNULL(@Waluta, '') <> '' AND NOT EXISTS ( SELECT *
     FROM #Notowania
     WHERE UPPER(Waluta) = UPPER(@Waluta) )
    BEGIN
      SET @Komunikat = '##OPT34464##%%s1%%=' + @Waluta+ '##'--' Brak waluty ' + @Waluta + '.'
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
     -- kurs waluty transakcji
     SELECT TOP 1
     @Brak = Brak,
     @WalKursL = KursL,
     @WalKursM = KursM
     FROM #Notowania
     WHERE UPPER(Waluta) = UPPER(@Waluta)
     IF @Brak = 1
    BEGIN
      SET @Komunikat = '##OPT34465##%%s1%%=' + @Waluta+ '%%s2%%=' + @TrN_DataDokChar+ '##'--' Brak kursu ' + @Waluta + ' na dzień ' + @TrN_DataDokChar + ' ! '
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
     update cdn.TraNag set TrN_KursL =   @WalKursL,  TrN_KursM = @WalKursM, TrN_DataKur = @data where  TrN_TrNID = @TrN_TrNId_Doc
  end
  else
     update cdn.TraNag set  TrN_DataKur = @data where  TrN_TrNID = @TrN_TrNId_Doc
   END
        INSERT INTO [CDN].[TraNagRelacje]
                            ([TrR_TrNTyp]
                            ,[TrR_TrNId]
                            ,[TrR_FaTyp]
                            ,[TrR_FaId]
                            ,[TrR_Flaga])
                   select
                           CONVERT(INT, @TrN_Rodzaj_Doc/1000)
                           ,@TrN_TrNId_Doc
                           ,0
                           ,TrNID
                           ,CASE
                              WHEN CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (313, 314) THEN 1
                              ELSE 0
                           END
                   from @TrNID
     select @PFzRO = a.Trr_TrNId from cdn.tranagrelacje a
     where a.TrR_FaId =@TrN_TrNId_Zrd AND a.Trr_TrNTyp =308 AND a.Trr_FaTyp =320
     if @PFzRO > 0
        INSERT INTO [CDN].[TraNagRelacje]
                            ([TrR_TrNTyp]
                            ,[TrR_TrNId]
                            ,[TrR_FaTyp]
                            ,[TrR_FaId]
                            ,[TrR_Flaga])
  select CONVERT(INT, @TrN_Rodzaj_Doc/1000),@TrN_TrNId_Doc,0,a.Trr_TrNId,0
        from cdn.tranagrelacje a
        where a.TrR_FaId =@TrN_TrNId_Zrd AND a.Trr_TrNTyp =308 AND a.Trr_FaTyp =320
                   /*VALUES
                           (CONVERT(INT, @TrN_Rodzaj_Doc/1000)
                           ,@TrN_TrNId_Doc
                           ,0
                           ,@PFzRO
                           , 0
                           ) */
    END
  --   dodajemy atrybuty
   IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1823 and Fir_Wartosc = '1' and CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (306, 307, 314, 313))
    BEGIN
      INSERT INTO CDN.DokAtrybuty
        (
        [DAt_DeAId],
        [DAt_Kod],
        [DAt_WartoscTxt],
        [DAt_TrNId]
         )
      SELECT
         [DAt_DeAId],
         [DAt_Kod],
         [DAt_WartoscTxt],
         @TrN_TrNId_Doc
      FROM CDN.DokAtrybuty
      WHERE DaT_TrNId in (select TrNId from @TrNID)
    END
  -- Ofertowanie - dodajemy wiersz do OfertyDok
  IF CONVERT(INT, @TrN_Rodzaj_Doc/1000) = 800
   BEGIN
     SET @TrN_NumerNr_Doc = 1 + ( SELECT ISNULL(MAX(OfD_NumerNr),0) AS MaxNumerNr FROM CDN.OfertyDok WHERE OfD_NumerString = @TrN_NumerString_Doc )
     INSERT INTO CDN.OfertyDok  ( OfD_DDFId,     OfD_TypDokumentu,  OfD_NumerNr,      OfD_NumerString,      OfD_DataDok,     OfD_Nazwa, OfD_Body,   OfD_OpeZalId,     OfD_OpeZalKod, OfD_OpeZalNazwisko, OfD_StaZalId,    OfD_TS_Zal,  OfD_OpeModId, OfD_OpeModKod, OfD_OpeModNazwisko,     OfD_StaModId,            OfD_TS_Mod, OfD_NazwaSzablonu, OfD_TypNB  )
                      SELECT     @TrN_DDFId_Doc,              800, @TrN_NumerNr_Doc, @TrN_NumerString_Doc, @TrN_DataDok_Doc,        '',       '',  @TrN_OpeZalId_Doc, @OpeZalKod,    @OpeZalNazwisko, @TrN_StaZalId_Doc,  @DataTodayNoTime, @TrN_OpeZalId_Doc, @OpeZalKod, @OpeZalNazwisko, @TrN_StaZalId_Doc,  @DataTodayNoTime, '', 1
     SELECT @TrN_TrNId_Doc = ISNULL(MAX(OfD_OfDId),0) FROM cdn.OfertyDok
   END
  -- Faktura Pro-Forma z ofertowania - dodajemy nowy wiersz do TraNag
  IF CONVERT(INT, @TrN_Rodzaj_Doc/1000) = 320
    BEGIN
     DECLARE @sqltxt NVARCHAR (1000),@TmpSrvName SYSNAME
     --DECLARE @KursNumer INT
     SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
      IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
      SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
      SET @sqltxt = 'SELECT Kon_Wartosc FROM  ['
      IF @ServerCfgString <> @TmpSrvName
      SET @sqltxt = @sqltxt + @ServerCfgString +'].['
      SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.Konfig WHERE Kon_Numer = 260'
       CREATE TABLE #Kursy (KursNumer INT)
       INSERT INTO #Kursy  EXEC sp_executesql @sqltxt
       SELECT @KursNumer = KursNumer FROM #Kursy
        IF @KursNumer IS NULL
         SELECT @KursNumer = 2
         DROP TABLE #Kursy
      INSERT INTO CDN.TraNag
      (
        [TrN_DDfId],
        [TrN_TypDokumentu],
        [TrN_NumerNr],
        [TrN_NumerString],
        [TrN_Bufor],
        [TrN_DataDok],
        [TrN_DataWys],
        [TrN_DataOpe],
        [TrN_NumerObcy],
        [TrN_NumerPelnyPrw],
        [TrN_Korekta],
        [TrN_Fiskalna],
        [TrN_Detal],
        [TrN_Rodzaj],
        [TrN_PodNazwa1],
        [TrN_PodNazwa2],
        [TrN_PodNazwa3],
        [TrN_PodKraj],
        [TrN_PodWojewodztwo],
        [TrN_PodPowiat],
        [TrN_PodGmina],
        [TrN_PodUlica],
        [TrN_PodNrDomu],
        [TrN_PodNrLokalu],
        [TrN_PodMiasto],
        [TrN_PodKodPocztowy],
        [TrN_PodPoczta],
        [TrN_PodAdres2],
        [TrN_PodNipKraj],
        [TrN_PodNipE],
        [TrN_PodmiotGLN],
        [TrN_Finalny],
  [TrN_PodatekVat],
  [TrN_Pesel],
        [TrN_Export],
        [TrN_OdbNazwa1],
        [TrN_OdbNazwa2],
        [TrN_OdbNazwa3],
        [TrN_OdbKraj],
        [TrN_OdbWojewodztwo],
        [TrN_OdbPowiat],
        [TrN_OdbGmina],
        [TrN_OdbUlica],
        [TrN_OdbNrDomu],
        [TrN_OdbNrLokalu],
        [TrN_OdbMiasto],
        [TrN_OdbKodPocztowy],
        [TrN_OdbPoczta],
        [TrN_OdbAdres2],
        [TrN_OdbNipKraj],
        [TrN_OdbNipE],
        [TrN_OdbiorcaGLN],
        [TrN_Kategoria],
        [TrN_FPlId],
        [TrN_Termin],
        [TrN_RazemNetto],
        [TrN_RazemVAT],
        [TrN_RazemBrutto],
        [TrN_RazemNettoWal],
        [TrN_RazemVATWal],
        [TrN_RazemBruttoWal],
        [TrN_Waluta],
        [TrN_KursNumer],
        [TrN_KursL],
        [TrN_KursM],
        [TrN_PlatElemWalSys],
        [TrN_VatDlaDokWal],
        [TrN_BlokadaPlatnosci],
        [TrN_MagZrdId],
        [TrN_TypNB],
        [TrN_Rabat],
        [TrN_Odebral],
        [TrN_Opis],
        [TrN_NotaKorPrzed],
        [TrN_NotaKorPo],
        [TrN_TrSTyp],
        [TrN_OpeZalId],
  [TrN_OpeZalKod],
  [TrN_OpeZalNazwisko],
        [TrN_StaZalId],
        [TrN_TS_Zal],
        [TrN_OpeModId],
  [TrN_OpeModKod],
  [TrN_OpeModNazwisko],
        [TrN_StaModId],
        [TrN_TS_Mod],
        [TrN_Centrala],
        [TrN_KodTransakcji],
        [TrN_DataTransportu],
        [TrN_KodKraju],
        [TrN_Anulowany],
        [TrN_TaxFreePotwierdzony],
        [TrN_PlatKaucje],
        [TrN_DataKur]
      )
      SELECT
        @TrN_DDFId_Doc,                     --    [TrN_DDfId],
        CONVERT(INT, @TrN_Rodzaj_Doc/1000), --    [TrN_TypDokumentu],
        @TrN_NumerNr_Doc,                   --    [TrN_NumerNr],
        @TrN_NumerString_Doc,               --    [TrN_NumerString],
        1,                                  --    [TrN_Bufor],
        @TrN_DataDok_Doc,                   --    [TrN_DataDok],
        @TrN_DataDok_Doc,                   --    [TrN_DataWys],
        @TrN_DataDok_Doc,                   --    [TrN_DataOpe],
        '',                                 --    [TrN_NumerObcy],
        '',                                 --    [TrN_NumerPelnyPrw],
        0,                                  --    [TrN_Korekta],
        0,                                  --    [TrN_Fiskalna],
        0,                                  --    [TrN_Detal],
        @TrN_Rodzaj_Doc,                    --    [TrN_Rodzaj],
        '',                                 --    [TrN_PodNazwa1],
        '',                                 --    [TrN_PodNazwa2],
        '',                                 --    [TrN_PodNazwa3],
        '',                                 --    [TrN_PodKraj],
        '',                                 --    [TrN_PodWojewodztwo],
        '',                                 --    [TrN_PodPowiat],
        '',                                 --    [TrN_PodGmina],
        '',                                 --    [TrN_PodUlica],
        '',                                 --    [TrN_PodNrDomu],
        '',                                 --    [TrN_PodNrLokalu],
        '',                                 --    [TrN_PodMiasto],
        '',                                 --    [TrN_PodKodPocztowy],
        '',                                 --    [TrN_PodPoczta],
        '',                                 --    [TrN_PodAdres2],
        '',                                 --    [TrN_PodNipKraj],
        '',                                 --    [TrN_PodNipE],
        '',                                 --    [TrN_PodmiotGLN],
        1,                                  --    [TrN_Finalny],
  0,                                  --    [TrN_PodatekVat],
  '',                                 --    [TrN_Pesel],
        0,                                  --    [TrN_Export],
        '',                                 --    [TrN_OdbNazwa1],
        '',                                 --    [TrN_OdbNazwa2],
        '',                                 --    [TrN_OdbNazwa3],
        '',                                 --    [TrN_OdbKraj],
        '',                                 --    [TrN_OdbWojewodztwo],
        '',                                 --    [TrN_OdbPowiat],
        '',                                 --    [TrN_OdbGmina],
        '',                                 --    [TrN_OdbUlica],
        '',                                 --    [TrN_OdbNrDomu],
        '',                                 --    [TrN_OdbNrLokalu],
        '',                                 --    [TrN_OdbMiasto],
        '',                                 --    [TrN_OdbKodPocztowy],
        '',                                 --    [TrN_OdbPoczta],
        '',                                 --    [TrN_OdbAdres2],
        '',                                 --    [TrN_OdbNipKraj],
        '',                                 --    [TrN_OdbNipE],
        '',                                 --    [TrN_OdbiorcaGLN],
        '',                                 --    [TrN_Kategoria],
        1,                                  --    [TrN_FPlId],
        @TrN_DataDok_Doc,                   --    [TrN_Termin],
        0,                                  --    [TrN_RazemNetto],
        0,                                  --    [TrN_RazemVAT],
        0,                                  --    [TrN_RazemBrutto],
        0,                                  --    [TrN_RazemNettoWal],
        0,                                  --    [TrN_RazemVATWal],
        0,                                  --    [TrN_RazemBruttoWal],
        '',                                 --    [TrN_Waluta],
        @KursNumer,                         --    [TrN_KursNumer],
        1,                                  --    [TrN_KursL],
        1,                                  --    [TrN_KursM],
        0,                                  --    [TrN_PlatElemWalSys],
        0,                                  --    [TrN_VatDlaDokWal],
        1,                                  --    [TrN_BlokadaPlatnosci],
        1,                                  --    [TrN_MagZrdId],
        1,                                  --    [TrN_TypNB],
        0,                                  --    [TrN_Rabat],
        '',                                 --    [TrN_Odebral],
        '',                                 --    [TrN_Opis],
        '',                                 --    [TrN_NotaKorPrzed],
        '',                                 --    [TrN_NotaKorPo],
        0,                                  --    [TrN_TrSTyp],
        @TrN_OpeZalId_Doc,                  --    [TrN_OpeZalId],
  @OpeZalKod,
  @OpeZalNazwisko,
        @TrN_StaZalId_Doc,                  --    [TrN_StaZalId],
        @DataTodayWithTime,                 --    [TrN_TS_Zal],
        @TrN_OpeZalId_Doc,                  --    [TrN_OpeModId],
  @OpeZalKod,
  @OpeZalNazwisko,
        @TrN_StaZalId_Doc,                  --    [TrN_StaModId],
        @DataTodayWithTime,                 --    [TrN_TS_Mod],
        0,                                  --    [TrN_Centrala],
        '',                                 --    [TrN_KodTransakcji],
        '',                                 --    [TrN_DataTransportu],
        '',                                 --    [TrN_KodKraju]
        0,                                  --    [TrN_Anulowany]
        0,                                  --    [TrN_TaxFreePotwierdzony]
        0,                                  --    [TrN_PlatKaucje]
        @TrN_DataDok_Doc                    --    [TrN_DataKur]
      -- TrN_TrNId nowego dokumentu
      --SELECT @TrN_TrNId_Doc = ISNULL(MAX(TrN_TrNId),0) FROM cdn.TraNag //RT
      SET @TrN_TrNId_Doc = SCOPE_IDENTITY()
   --logi
      select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
      exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 1, ''
    END
  IF @Kontekst = -1 AND CONVERT(INT, @TrN_Rodzaj_Doc/1000) <> 800
    BEGIN
      INSERT INTO cdn.TraNag
      (
         TrN_DDfId,
         TrN_TypDokumentu,
         TrN_ZwrId,
         TrN_FaId,
         TrN_NumerNr,
         TrN_NumerString,
         TrN_Bufor,
         TrN_VaNId,
         TrN_DataDok,
         TrN_DataWys,
         TrN_DataOpe,
         TrN_NumerObcy,
         TrN_Korekta,
         TrN_Fiskalna,
         TrN_Detal,
         TrN_Rodzaj,
         TrN_PodmiotTyp,
         TrN_PodID,
         TrN_PodNazwa1,
         TrN_PodNazwa2,
         TrN_PodNazwa3,
         TrN_PodKraj,
         TrN_PodWojewodztwo,
         TrN_PodPowiat,
         TrN_PodGmina,
         TrN_PodUlica,
         TrN_PodNrDomu,
         TrN_PodNrLokalu,
         TrN_PodMiasto,
         TrN_PodKodPocztowy,
         TrN_PodPoczta,
         TrN_PodAdres2,
         TrN_PodNipE,
         TrN_Finalny,
   TrN_PodatekVat,
   TrN_Pesel,
         TrN_Export,
         TrN_OdbiorcaTyp,
         TrN_OdbID,
         TrN_OdbNazwa1,
         TrN_OdbNazwa2,
         TrN_OdbNazwa3,
         TrN_OdbKraj,
         TrN_OdbWojewodztwo,
         TrN_OdbPowiat,
         TrN_OdbGmina,
         TrN_OdbUlica,
         TrN_OdbNrDomu,
         TrN_OdbNrLokalu,
         TrN_OdbMiasto,
         TrN_OdbKodPocztowy,
         TrN_OdbPoczta,
         TrN_OdbAdres2,
         TrN_OdbNipE,
         TrN_KatID,
         TrN_Kategoria,
         TrN_FPlId,
         TrN_Termin,
         TrN_RazemNetto,
         TrN_RazemVAT,
         TrN_RazemBrutto,
         TrN_BlokadaPlatnosci,
         TrN_MagZrdId,
         TrN_MagDocId,
         TrN_TypNB,
         TrN_Rabat,
         TrN_Odebral,
         TrN_Opis,
         TrN_OpeZalID,
   TrN_OpeZalKod,
   TrN_OpeZalNazwisko,
         TrN_StaZalID,
         TrN_TS_Zal,
         TrN_OpeModID,
   TrN_OpeModKod,
   TrN_OpeModNazwisko,
         TrN_StaModID,
         TrN_TS_Mod,
         TrN_NotaKorPrzed,
         TrN_NotaKorPo,
         TrN_TrSTyp,
         TrN_Waluta,
         TrN_KursNumer,
         TrN_KursL,
         TrN_KursM,
         TrN_RazemNettoWal,
         TrN_Centrala,
         TrN_PodmiotGLN,
         TrN_OdbiorcaGLN,
         TrN_NumerPelnyPrw,
         TrN_PlatElemWalSys,
         TrN_VatDlaDokWal,
         TrN_RazemBruttoWal,
         TrN_RazemVATWal,
         TrN_PodNipKraj,
         TrN_OdbNipKraj,
         TrN_KodTransakcji,
         TrN_DataTransportu,
         TrN_KodKraju,
         TrN_Anulowany,
         TrN_TaxFreePotwierdzony,
         TrN_PlatKaucje,
         TrN_DataKur,
   TrN_PlatnikID,
         TrN_PlatnikTyp,
   TrN_ZakId,
         TrN_PCID,
         TrN_PCJSID
      )
      SELECT
        @TrN_DDfId_Doc,                       -- TrN_DDfId
        CONVERT(INT, @TrN_Rodzaj_Doc/1000),   -- TrN_TypDokumentu
         NULL,                                -- TrN_ZwrId,
         NULL,                                -- TrN_FaId,
        @TrN_NumerNr_Doc,                     -- TrN_NumerNr
        @TrN_NumerString_Doc,                 -- TrN_NumerString,
        1,                                    -- TrN_Bufor,
         NULL,                                -- TrN_VaNId,
        @TrN_DataDok_Doc,                     -- TrN_DataDok,
        @TrN_DataWys_Doc,                     -- TrN_DataWys,
        @TrN_DataOpe_Doc,                     -- TrN_DataOpe,
         '',                                  -- TrN_NumerObcy,
         0,                                   -- TrN_Korekta,
         0,                                   -- TrN_Fiskalna,
         0,                                   -- TrN_Detal,
        @TrN_Rodzaj_Doc,                      -- TrN_Rodzaj,
         1,                                   -- TrN_PodmiotTyp,
         1,                                   -- TrN_PodID,
         Knt_Nazwa1,                          -- TrN_PodNazwa1,
         Knt_Nazwa2,                          -- TrN_PodNazwa2,
         Knt_Nazwa3,                          -- TrN_PodNazwa3,
         Knt_Kraj,                            -- TrN_PodKraj,
         Knt_Wojewodztwo,                     -- TrN_PodWojewodztwo,
         Knt_Powiat,                          -- TrN_PodPowiat,
         Knt_Gmina,                           -- TrN_PodGmina,
         Knt_Ulica,                           -- TrN_PodUlica,
         Knt_NrDomu,                          -- TrN_PodNrDomu,
         Knt_NrLokalu,                        -- TrN_PodNrLokalu,
         Knt_Miasto,                          -- TrN_PodMiasto,
         Knt_KodPocztowy,                     -- TrN_PodKodPocztowy,
         Knt_Poczta,                          -- TrN_PodPoczta,
         Knt_Adres2,                          -- TrN_PodAdres2,
         Knt_NipE,                            -- TrN_PodNipE,
         1,                                   -- TrN_Finalny,
   0,                                   -- TrN_PodatekVat,
   '',                                  -- TrN_Pesel,
         0,                                   -- TrN_Export,
         1,                                   -- TrN_OdbiorcaTyp,
         1,                                   -- TrN_OdbID,
         Knt_Nazwa1,                          -- TrN_OdbNazwa1,
         Knt_Nazwa2,                          -- TrN_OdbNazwa2,
         Knt_Nazwa3,                          -- TrN_OdbNazwa3,
         Knt_Kraj,                            -- TrN_OdbKraj,
         Knt_Wojewodztwo,                     -- TrN_OdbWojewodztwo,
         Knt_Powiat,                          -- TrN_OdbPowiat,
         Knt_Gmina,                           -- TrN_OdbGmina,
         Knt_Ulica,                           -- TrN_OdbUlica,
         Knt_NrDomu,                          -- TrN_OdbNrDomu,
         Knt_nrLokalu,                        -- TrN_OdbNrLokalu,
         Knt_Miasto,                          -- TrN_OdbMiasto,
         Knt_KodPocztowy,                     -- TrN_OdbKodPocztowy,
         Knt_Poczta,                          -- TrN_OdbPoczta,
         Knt_Adres2,                          -- TrN_OdbAdres2,
         Knt_NipE,                            -- TrN_OdbNipE,
         NULL,                                -- TrN_KatID,
         '',                                  -- TrN_Kategoria,
         Knt_FPlId,                           -- TrN_FPlId,
        @TrN_DataDok_Doc,                     -- TrN_Termin,
         0,                                   -- TrN_RazemNetto,
         0,                                   -- TrN_RazemVAT,
         0,                                   -- TrN_RazemBrutto,
         1,                                   -- TrN_BlokadaPlatnosci,
        @TrN_MagZrdId_Doc,                    -- TrN_MagZrdId,
         NULL,                                -- TrN_MagDocId,
         1,                                   -- TrN_TypNB,
         0,                                   -- TrN_Rabat,
         '',                                  -- TrN_Odebral,
        CASE WHEN @TrN_Rodzaj_Doc in(303010,304010) then 'Dokument powstał z przekształcenia AI' else '' end,      -- TrN_Opis,
        @TrN_OpeZalId_Doc,                    -- TrN_OpeZalID,
  @OpeZalKod,
  @OpeZalNazwisko,
        @TrN_StaZalId_Doc,                    -- TrN_StaZalID,
         GETDATE(),                           -- TrN_TS_Zal,
        @TrN_OpeZalId_Doc,                    -- TrN_OpeModID,
  @OpeZalKod,
  @OpeZalNazwisko,
        @TrN_StaZalId_Doc,                    -- TrN_StaModID,
         GETDATE(),                           -- TrN_TS_Mod,
         '',                                  -- TrN_NotaKorPrzed,
         '',                                  -- TrN_NotaKorPo,
         0,                                   -- TrN_TrSTyp,
         '',                                  -- TrN_Waluta,
         2,                                   -- TrN_KursNumer,
         1,                                   -- TrN_KursL,
         1,                                   -- TrN_KursM,
         0,                                   -- TrN_RazemNettoWal,
         0,                                   -- TrN_Centrala,
         '',                                  -- TrN_PodmiotGLN,
         '',                                  -- TrN_OdbiorcaGLN,
         '',                                  -- TrN_NumerPelnyPrw,
         0,                                   -- TrN_PlatElemWalSys,
         0,                                   -- TrN_VatDlaDokWal,
         0,                                   -- TrN_RazemBruttoWal,
         0,                                   -- TrN_RazemVATWal,
         '',                                  -- TrN_PodNipKraj,
         '',                                  -- TrN_OdbNipKraj,
         '',                                  -- TrN_KodTransakcji,
         @TrN_DataOpe_Doc,                    -- TrN_DataTransakcji,
         '',                                  -- TrN_KodKraju,
         0,                                   -- TrN_Anulowany,
         0,                                   -- TrN_TaxFreePotwierdzony,
         0,                                   -- TrN_PlatKaucje
         @TrN_DataDok_Doc,                    -- TrN_DataKur
         Knt_KntID,
         1,
         @ZakId,
         @PCID,
         @PCIDJS
       FROM cdn.Kontrahenci WHERE Knt_KntId = 1
       -- Nowy TrN_TrNId
       --SET @TrN_TrNId_Doc  = ( SELECT ISNULL(MAX(TrN_TrNId),1) FROM cdn.TraNag )//RT
       SET @TrN_TrNId_Doc = SCOPE_IDENTITY()
   --logi
      select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
      exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 1, ''
     END
  -- Wyswietlenie komunikatu i rollback całej transakcji
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
