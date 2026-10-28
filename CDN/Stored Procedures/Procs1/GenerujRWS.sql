CREATE PROCEDURE CDN.GenerujRWS
  @TrN_TrNId_PWP    INT,  -- TrN_TrNId PWP
  @Seria            NVARCHAR(20)=''
AS
SET NOCOUNT ON
  DECLARE
    -- Naglowek RWS
    @TrN_TrNId_RWS         INT,
    @TrN_Rodzaj_RWS        INT,
    @TrN_NumerNr_RWS       INT,
    @TrN_TypDokumentu_RWS  INT,
    @TrN_DataDok_RWS       DATETIME ,
    @TrN_OpeZalId_RWS      INT,
 @TrN_OpeZalKod_RWS      VARCHAR(20),
 @TrN_OpeZalNazwisko_RWS      NVARCHAR(50),
    @TrN_StaZalId_RWS      INT,
    @TrN_MagZrdId_RWS      INT,
    @TrN_ZwrId_RWS         INT,
    -- Naglowek PWP
    @TrN_TrSTyp_PWP        INT,
    @TrN_Bufor_PWP         INT,
    @TrN_DekId_PWP         INT,
    @TrN_OpeZalId_PWP      INT,
    @TrN_Korekta_PWP       INT,
    -- Dla numeru dokumentu
    @DDfId_RWS             INT,
    @Data                  DATETIME,
    @TrN_NumerString_RWS   NVARCHAR(100),
    @TrN_Opis_RWS          NVARCHAR(255),
    -- Elementy RWS
    @TrE_TrEId_RWS         INT,
    @TrE_Lp_RWS            INT,
    @TrE_KatId_RWS         INT,
    @TrE_TwrNazwa_RWS      NVARCHAR(255),
    @TrE_TwrOpis_RWS       NVARCHAR(1024),
    @TrE_TwrSWW_RWS        NVARCHAR(20),
    @TrE_Stawka_RWS        DECIMAL(5,2),
    @TrE_Flaga_RWS         SMALLINT,
    @TrE_Zrodlowa_RWS      DECIMAL(5,2),
    @TrE_TwCNumer_RWS      INT,
    @TrE_Waluta_RWS        NVARCHAR(3),
    @TrE_KursNumer_RWS     INT,
    @TrE_KursL_RWS         DECIMAL(15,4),
    @TrE_KursM_RWS         DECIMAL(5,0),
    @TrE_JMZ_RWS           NVARCHAR(20),
    @TrE_TwrNumerKat_RWS   NVARCHAR(20),
    @TrE_TwrEAN_RWS        NVARCHAR(40),
    @TrE_TwrKodDostawcy_RWS        NVARCHAR(50),
    @TrE_TwrKod_RWS        NVARCHAR(50),
    @TrE_TrEId_Old         INT,
    @TrE_Ilosc_Old         DECIMAL(15,4),
    @TrE_IloscJM_Old       DECIMAL(15,4),
 @TrE_KosztUslugi_Old   DECIMAL(15,4),
 @TrE_Typ               INT,
 @Tre_CenaZCzteremaMiejscami   SMALLINT,
    -- dla kursora po magazynach
    @PdE_PdEId          INT,
    @PdE_TrEId          INT,
 @PdE_WyborDostaw    SMALLINT,
    @PdE_Lp             SMALLINT,
    @PdE_DataWys        DATETIME,
    @PdE_DataOpe        DATETIME,
    @PdE_TwrId          INT,
    @PdE_MagId          INT,
    @PdE_Ilosc          DECIMAL(15,4),
    @PdE_Jm             NVARCHAR(20),
    @PdE_JmCalkowite    SMALLINT,
    @PdE_JMPrzelicznikL DECIMAL(15,2),
    @PdE_JMPrzelicznikM DECIMAL(7,0),
    @PdE_IloscJM        DECIMAL(15,4),
    @PdE_WartoscZakupu  DECIMAL(15,2),
    @PdE_TrEIdRWS_Prw   INT,
    -- baza konfiguracyjna
    @KnfSrv             SYSNAME,
    @KnfDb              SYSNAME,
    -- do wyliczenia serii dla operatora
    @SeriaOperatora       NVARCHAR(5),
    @RejestrOperatora     NVARCHAR(20),
    @DDFID                INT,
    @Schem                NVARCHAR(40),
    -- parametr decydujacy o agregacji
    @AgregujRWS     INT,
    -- piecząta firmy
    @PCID int,
    @PCIDJS int,
    -- do zakazow na magazyn
    @Mag_Symbol     NVARCHAR(20),
    @Tre_TwrKod     NVARCHAR(50),
    @Komunikat      NVARCHAR(512),
 --wielozakładowosc
 @zakid int,
 --logi
 @NumerPelny  NVarchar(30)
 DECLARE @Zalogowane TABLE ( NumerPelny NVarchar(30),Typ int )
  IF  ( SELECT ISNULL( MAX(Fir_Wartosc), 0 ) FROM cdn.Firma WHERE Fir_Numer =2240) = 1
  select @zakid = zak_zakid from cdn.Zaklady where Zak_Domyslny = 1
  -- TrN_TrSTyp i TrN_Bufor z PWP
  SELECT
    @TrN_TrSTyp_PWP = TrN_TrSTyp,
    @TrN_Bufor_PWP  = TrN_Bufor,
    @TrN_DekId_PWP  = ISNULL(TrN_DekId,0),
    @TrN_OpeZalId_PWP = TrN_OpeZalId
  FROM cdn.TraNag
  WHERE TrN_TrNId = @TrN_TrNId_PWP
  -- nie generujemy RWS, jeśli to jest księgowanie
  IF @TrN_DekId_PWP = 0
    BEGIN
  --sprawdzenie zakazów na magazyn
   SELECT @Mag_Symbol ='',@Tre_TwrKod=''
   SELECT @Mag_Symbol=Mag_Symbol,@Tre_TwrKod=Tre_TwrKod
     FROM cdn.ProdElem K
     JOIN cdn.TraElem ON TrE_TrEId = K.PdE_TrEId
     JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
     JOIN cdn.Magazyny on K.PdE_MagId=Mag_MagId
     JOIN cdn.Magazynzakazy on MaZ_MagId=K.PdE_MagId
     WHERE TrN_TrNId = @TrN_TrNId_PWP AND MaZ_OpeId = TrN_OpeModId
    IF @Mag_Symbol <> ''
    BEGIN
      --SET @Komunikat ='Operator ma ustawiony zakaz na magazyn '+ @Mag_Symbol +'. Zmień magazyn na recepturze towaru '+ @Tre_TwrKod +'.'
   SET @Komunikat = '##OPT34452##%%s1%%=' + @Mag_Symbol+ '%%s2%%='+ @Tre_TwrKod +'##'
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
      -- kasowanie elementów ze skojarzonych RWS ( moze byc wiele RWS na roznych magazynach )
      DECLARE @TrEId TABLE ( TrEId INT )
        INSERT INTO @TrEId
          SELECT TrE_TrEId
            FROM cdn.TraElem
              JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
              JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId
            WHERE TrN_TypDokumentu = 318 AND TrR_FaId = @TrN_TrNId_PWP
      IF EXISTS ( SELECT * FROM @TrEId )
        DELETE cdn.TraElem
          FROM cdn.TraElem
          JOIN @TrEId ON TrEId = TrE_TrEId
      -- Kursor po ProdElem
     DECLARE Magazyny CURSOR LOCAL FAST_FORWARD FOR
        SELECT K.PdE_PdEId, K.PdE_TrEId, K.PdE_Lp, K.PdE_DataWys, K.PdE_DataOpe, K.PdE_TwrId, K.PdE_MagId, K.PdE_Ilosc, K.PdE_Jm, K.PdE_JmCalkowite, K.PdE_JMPrzelicznikL, K.PdE_JMPrzelicznikM, K.PdE_IloscJM, K.PdE_WartoscZakupu, P.PdE_TrEIdRWS, TrN_Korekta, k.PdE_WyborDostaw
          FROM cdn.ProdElem K
            JOIN cdn.TraElem ON TrE_TrEId = K.PdE_TrEId
            JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
            LEFT OUTER JOIN cdn.ProdElem P ON P.PdE_PdEId = K.PdE_ZwrId
          WHERE TrN_TrNId = @TrN_TrNId_PWP
          ORDER BY K.PdE_MagId, TrE_Lp, K.PdE_Lp
          OPEN Magazyny
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Magazyny INTO @PdE_PdEId, @PdE_TrEId, @PdE_Lp, @PdE_DataWys, @PdE_DataOpe, @PdE_TwrId, @PdE_MagId, @PdE_Ilosc, @PdE_Jm, @PdE_JmCalkowite, @PdE_JMPrzelicznikL, @PdE_JMPrzelicznikM, @PdE_IloscJM, @PdE_WartoscZakupu, @PdE_TrEIdRWS_Prw, @TrN_Korekta_PWP,@PdE_WyborDostaw
                IF @@FETCH_STATUS <> 0 BREAK
                -- Generowania naglowkow dla magazynów, ktore wystepuja na subelementach korekcyjnych
                -- jesli naglowek isnieje, Update TrN_Bufor i TrN_TrSTyp
                IF EXISTS ( SELECT * FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 318 AND TrR_FaId = @TrN_TrNId_PWP AND TrN_MagZrdId = @PdE_MagId )
                  BEGIN
                    UPDATE cdn.TraNag SET
                      TrN_TrSTyp = @TrN_TrSTyp_PWP,
                      TrN_Bufor  = @TrN_Bufor_PWP
                    FROM CDN.TraNag
                    JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId
                    WHERE TrN_TypDokumentu = 318 AND TrR_FaId = @TrN_TrNId_PWP AND TrN_MagZrdId = @PdE_MagId
                  END
                -- nie ma naglowka RWS na danym magazynie - trzeba go zalozyc
                SELECT @TrN_Rodzaj_RWS = TrN_Rodzaj FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 318 AND TrR_FaId = @TrN_TrNId_PWP AND TrN_MagZrdId = @PdE_MagId
                IF NOT EXISTS ( SELECT * FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 318 AND TrR_FaId = @TrN_TrNId_PWP AND TrN_MagZrdId = @PdE_MagId )
                  BEGIN
                    -- składniki nagłówka z PWP
                    SELECT TOP 1
                      @TrN_DataDok_RWS     = TrN_DataDok,
                      @TrN_OpeZalId_RWS    = TrN_OpeModId,
       @TrN_OpeZalKod_RWS    = TrN_OpeModKod,
       @TrN_OpeZalNazwisko_RWS    = TrN_OpeModNazwisko,
                      @TrN_StaZalId_RWS    = TrN_StaModId
                    FROM CDN.TraNag
                    WHERE TrN_TrNId = @TrN_TrNId_PWP
                    -- Składniki naglowka
                    SELECT
                      @TrN_TypDokumentu_RWS = 318,
                      @TrN_MagZrdId_RWS     = @PdE_MagId
                    IF @TrN_Korekta_PWP = 0
                      SELECT
                        @TrN_Rodzaj_RWS       = 318000,
                        @TrN_Opis_RWS         = ' Rozchód składników do produkcji.',
                        @TrN_ZwrId_RWS        = NULL
                    ELSE
                      SELECT
                        @TrN_Rodzaj_RWS       = 318001,
                        @TrN_Opis_RWS         = ' Rozchód składników do produkcji - korekta.',
                        @TrN_ZwrId_RWS        = ( SELECT RP.TrN_TrNId
                                                  FROM cdn.TraNag RP                                -- pierwotny RWS
                                                    JOIN cdn.TraNagRelacje REL ON RP.TrN_TrNId = REL.TrR_TrNId
                                                    JOIN cdn.TraNag PP ON REL.TrR_FaId = PP.TrN_TrNId  -- pierwotny PWP
                                                    JOIN cdn.TraNag PK ON PK.TrN_ZwrId = PP.TrN_TrNId -- korekta PWP
                                                  WHERE PK.TrN_TrNId = @TrN_TrNId_PWP AND RP.TrN_TypDokumentu = 318
                                                    AND RP.TrN_MagZrdId = @PdE_MagId )
                    SELECT @KnfSrv = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID=1001
                    SELECT @KnfDb  = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID=1002
                    -- seria operatora
                    SET @DDfId_RWS = CDN.DomyslnaDefinicja(@TrN_Rodzaj_RWS)
                    IF ( SELECT TOP 1 DDf_SeriaOperatora FROM cdn.DokDefinicje WHERE DDF_DDFId = @DDFId_RWS ) = 1
                    EXEC CDN.SeriaOperatora @KnfSrv, @KnfDb, @TrN_OpeZalId_PWP, @SeriaOperatora OUTPUT, @RejestrOperatora OUTPUT
                    SET @SeriaOperatora = ISNULL(@SeriaOperatora, '')
                    if @SeriaOperatora = '' and @TrN_ZwrId_RWS is not null and  ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 2140 ) = 1
                    begin
      SELECT @DDFID = TrN_DDfId, @Schem = TrN_NumerString from cdn.tranag  where TrN_TrNID = @TrN_ZwrId_RWS
      SELECT @Seria = Seria from [CDN].[RozbijNumer](@DDFID,@Schem )
                    end
                    IF @Seria <> '' AND @SeriaOperatora = ''
     SET @SeriaOperatora = @Seria
                    -- NumerString dodawanego nagłówka
                    SET @TrN_NumerString_RWS = CDN.NumerString (
                                                                   @TrN_Rodzaj_RWS      , -- Rodzaj dokumentu
                                                                   @TrN_OpeZalId_RWS    , -- Operator inicjujący dokument do numeracji
                                                                   @TrN_StaZalId_RWS    , -- Stanowisko, na którym zainicjowano dokument
                                                                   @TrN_MagZrdId_RWS    , -- Id magazynu do numeracji
                                                                   @TrN_DataDok_RWS     , -- Data dokumentu
                                                                   @SeriaOperatora      ,  -- Seria operatora
                                           default,
                                           default,
                                           default
                                                                 )
                    SET @Komunikat = CDN.SprawdzNumerString ( @DDfId_RWS, @TrN_NumerString_RWS )
                    IF @Komunikat <> ''  AND @TrN_NumerString_RWS != ''
                    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
                    END
                    -- obliczenie kolejnego numeru dokumentu i insert naglowka
                    SET @TrN_NumerNr_RWS = 1 + ( SELECT ISNULL(MAX(TrN_NumerNr),0) AS MaxNumerNr FROM CDN.TraNag WHERE TrN_NumerString = @TrN_NumerString_RWS )
     --pieczatka
                    SELECT @PCIDJS = PCJS_PCJSID FROM CDN.PieczatkiJS WHERE @TrN_DataDok_RWS BETWEEN PCJS_DataOd AND PCJS_DataDo
                    SELECT @PCID = Pc_PCID  FROM CDN.Pieczatki WHERE @TrN_DataDok_RWS BETWEEN PC_DataOd AND PC_DataDo
                    INSERT INTO cdn.TraNag (TrN_DDfId,  TrN_TypDokumentu, TrN_ZwrId, TrN_FaId, TrN_NumerNr, TrN_NumerString, TrN_Bufor, TrN_VaNId, TrN_DataDok, TrN_DataWys, TrN_DataOpe, TrN_NumerObcy, TrN_Korekta,        TrN_Fiskalna,  TrN_Detal,      TrN_Rodzaj,     TrN_PodmiotTyp, TrN_PodID, TrN_PodNazwa1, TrN_PodNazwa2, TrN_PodKraj,    TrN_PodWojewodztwo, TrN_PodPowiat, TrN_PodGmina, TrN_PodUlica, TrN_PodNrDomu, TrN_PodNrLokalu, TrN_PodMiasto, TrN_PodKodPocztowy, TrN_PodPoczta, TrN_PodAdres2, TrN_PodNipE, TrN_Finalny, TrN_Export,
                                             TrN_OdbiorcaTyp,  TrN_OdbID, TrN_OdbNazwa1, TrN_OdbNazwa2, TrN_OdbKraj, TrN_OdbWojewodztwo, TrN_OdbPowiat, TrN_OdbGmina, TrN_OdbUlica, TrN_OdbNrDomu, TrN_OdbNrLokalu, TrN_OdbMiasto, TrN_OdbKodPocztowy, TrN_OdbPoczta, TrN_OdbAdres2,  TrN_OdbNipE,    TrN_KatID, TrN_Kategoria,  TrN_FPlId,     TrN_Termin,    TrN_RazemNetto, TrN_RazemVAT, TrN_RazemBrutto, /*TrN_WartoscZakupu,*/ TrN_BlokadaPlatnosci,  TrN_MagZrdId,   TrN_MagDocId, TrN_TypNB, TrN_Rabat, TrN_Odebral,      TrN_Opis, TrN_OpeZalID,  TrN_OpeZalKod, TrN_OpeZalNazwisko,
                                             TrN_TS_Zal, TrN_OpeModID, TrN_OpeModKod, TrN_OpeModNazwisko, TrN_TS_Mod, TrN_NotaKorPrzed, TrN_NotaKorPo,  TrN_TrSTyp, TrN_Waluta, TrN_KursNumer, TrN_KursL, TrN_KursM, TrN_RazemNettoWal, TrN_PodNazwa3, TrN_OdbNazwa3, TrN_Centrala, TrN_PodmiotGLN, TrN_OdbiorcaGLN, TrN_NumerPelnyPrw, TrN_PlatElemWalSys, TrN_RazemBruttoWal, TrN_RazemVATWal, TrN_PodNipKraj, TrN_OdbNipKraj, TrN_KodTransakcji, TrN_KodKraju, TrN_Anulowany, TrN_PlatKaucje, TrN_TaxFreePotwierdzony, TrN_VatDlaDokWal, TrN_DataKur,TrN_ZakID,
            TrN_OpeZatwID,TrN_OpeZatwKod,TrN_OpeZatwNazwisko,TrN_TS_Zatw,TrN_PCId,TrN_PCJSID)
                                     SELECT     @DDfId_RWS, @TrN_TypDokumentu_RWS, @TrN_ZwrId_RWS, @TrN_TrNId_PWP, @TrN_NumerNr_RWS, LEFT(@TrN_NumerString_RWS,31),@TrN_Bufor_PWP, TrN_VaNId, TrN_DataDok,  TrN_DataDok,   TrN_DataDok,     TrN_NumerObcy, TrN_Korekta,        TrN_Fiskalna,  TrN_Detal,     @TrN_Rodzaj_RWS, TrN_PodmiotTyp, TrN_PodID, TrN_PodNazwa1, TrN_PodNazwa2, TrN_PodKraj,    TrN_PodWojewodztwo, TrN_PodPowiat, TrN_PodGmina, TrN_PodUlica, TrN_PodNrDomu, TrN_PodNrLokalu, TrN_PodMiasto, TrN_PodKodPocztowy, TrN_PodPoczta, TrN_PodAdres2, TrN_PodNipE, TrN_Finalny, TrN_Export,
                                             TrN_OdbiorcaTyp,  TrN_OdbID, TrN_OdbNazwa1, TrN_OdbNazwa2, TrN_OdbKraj, TrN_OdbWojewodztwo, TrN_OdbPowiat, TrN_OdbGmina, TrN_OdbUlica, TrN_OdbNrDomu, TrN_OdbNrLokalu, TrN_OdbMiasto, TrN_OdbKodPocztowy, TrN_OdbPoczta, TrN_OdbAdres2,  TrN_OdbNipE,    TrN_KatID, TrN_Kategoria,  TrN_FPlId,     TrN_Termin,                 0,            0,               0, /*                0,*/ TrN_BlokadaPlatnosci, @PdE_MagId,              NULL, TrN_TypNB, TrN_Rabat, TrN_Odebral, @TrN_Opis_RWS, TrN_OpeZalID, TrN_OpeZalKod, TrN_OpeZalNazwisko, TrN_TS_Zal, TrN_OpeModID, TrN_OpeModKod, TrN_OpeModNazwisko, TrN_TS_Mod,
                                                            '',            '', @TrN_TrSTyp_PWP,     '',             0,         1,         1,                 0, TrN_PodNazwa3, TrN_OdbNazwa3,            0, TrN_PodmiotGLN, TrN_OdbiorcaGLN,                '',                  0,                  0,               0, TrN_PodNipKraj, TrN_OdbNipKraj,                '',           '',             0,              0,                       0,        0, TrN_DataKur, @ZakID, TrN_OpeZatwID,TrN_OpeZatwKod,TrN_OpeZatwNazwisko,TrN_TS_Zatw,@PCId,@PCIDJS
                                     FROM  cdn.TraNag
                                     WHERE TrN_TrNId = @TrN_TrNId_PWP
                    -- Nowy TrN_TrNId z RWS i oczywiscie relacje
                    SELECT @TrN_TrNId_RWS = @@IDENTITY
     --logi
     select @NumerPelny = TrN_numerPelny from cdn.tranag where trn_trnid = @TrN_TrNId_RWS
     if not exists(select * from @Zalogowane where NumerPelny = @NumerPelny and Typ in (1,2))
     begin
      insert into @Zalogowane select @NumerPelny,1
      exec [CDN].[RejestrOperacjiDodaj] @TrN_TypDokumentu_RWS,0, @TrN_TrNId_RWS, @NumerPelny, 1, ''
     end
                    INSERT INTO [CDN].[TraNagRelacje]
                            ([TrR_TrNTyp]
                            ,[TrR_TrNId]
                            ,[TrR_FaTyp]
                            ,[TrR_FaId]
                            ,[TrR_Flaga])
                    VALUES
                            (318
                            ,@TrN_TrNId_RWS
                            ,317
                            ,@TrN_TrNId_PWP
                            ,0)
     -- Atrybuty
                    IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1823 and Fir_Wartosc = '1' and @TrN_Korekta_PWP = 0)
                    BEGIN
                    --SET @TrN_TrNId_RWS    = ( SELECT TOP 1 TrN_TrNId FROM cdn.TraNag WHERE TrN_TypDokumentu = 318 AND TrN_FaId = @TrN_TrNId_PWP AND TrN_MagZrdId = @PdE_MagId )
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
        @TrN_TrNId_RWS
       FROM CDN.DokAtrybuty
       WHERE DaT_TrNId = @TrN_TrNId_PWP
                    END
                    IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1824 and Fir_Wartosc = '1' and @TrN_Korekta_PWP = 1 )
                    BEGIN
       --SET @TrN_TrNId_RWS    = ( SELECT TOP 1 TrN_TrNId FROM cdn.TraNag WHERE TrN_TypDokumentu = 318 AND TrN_FaId = @TrN_TrNId_PWP AND TrN_MagZrdId = @PdE_MagId )
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
         @TrN_TrNId_RWS
       FROM CDN.DokAtrybuty
       WHERE DaT_TrNId = @TrN_TrNId_PWP
                    END
                  END
                  ELSE
                  BEGIN
                     SELECT @TrN_TrNId_RWS = TrN_TrNId,@TrN_MagZrdId_RWS = TrN_MagZrdId ,@TrN_Rodzaj_RWS = TrN_Rodzaj,@Schem = TrN_NumerString,@DDfId_RWS = TrN_DDfId,@TrN_OpeZalId_RWS =TrN_OpeZalId, @TrN_OpeZalKod_RWS =TrN_OpeZalKod, @TrN_OpeZalNazwisko_RWS =TrN_OpeZalNazwisko, @TrN_StaZalId_RWS = TrN_StaZalId FROM cdn.TraNag JOIN cdn.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 318 AND TrR_FaId = @TrN_TrNId_PWP AND TrN_MagZrdId = @PdE_MagId
      --SELECT @Seria = Seria from [CDN].[RozbijNumer](@DDfId_RWS,@Schem )
                     IF @TrN_Korekta_PWP = 0
                      SELECT
                         @TrN_ZwrId_RWS        = NULL
                     ELSE
                      SELECT
                        @TrN_ZwrId_RWS        = ( SELECT RP.TrN_TrNId
                                                  FROM cdn.TraNag RP                                -- pierwotny RWS
                                                    JOIN cdn.TraNagRelacje REL ON RP.TrN_TrNId = REL.TrR_TrNId
                                                    JOIN cdn.TraNag PP ON REL.TrR_FaId = PP.TrN_TrNId  -- pierwotny PWP
                                                    JOIN cdn.TraNag PK ON PK.TrN_ZwrId = PP.TrN_TrNId -- korekta PWP
                                                  WHERE PK.TrN_TrNId = @TrN_TrNId_PWP AND RP.TrN_TypDokumentu = 318
                                                    AND RP.TrN_MagZrdId = @PdE_MagId )
     SELECT @KnfSrv = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID=1001
                    SELECT @KnfDb  = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID=1002
                    -- seria operatora
                    IF ( SELECT TOP 1 DDf_SeriaOperatora FROM cdn.DokDefinicje WHERE DDF_DDFId = @DDfId_RWS ) = 1
      EXEC CDN.SeriaOperatora @KnfSrv, @KnfDb, @TrN_OpeZalId_PWP, @SeriaOperatora OUTPUT, @RejestrOperatora OUTPUT
                    SET @SeriaOperatora = ISNULL(@SeriaOperatora, '')
                    if @SeriaOperatora = '' and @TrN_ZwrId_RWS is not null and  ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 2140 ) = 1
                    begin
      SELECT @DDFID = TrN_DDfId, @Schem = TrN_NumerString from cdn.tranag  where TrN_TrNID = @TrN_ZwrId_RWS
      SELECT @Seria = Seria from [CDN].[RozbijNumer](@DDFID,@Schem )
                    end
                    IF @Seria <> '' AND @SeriaOperatora = ''
      SET @SeriaOperatora = @Seria
      SELECT @TrN_DataDok_RWS= TrN_DataDok FROM CDN.TraNag WHERE TrN_TrNId = @TrN_TrNId_PWP
      SET @TrN_NumerString_RWS = ''
      -- NumerString dodawanego nagłówka
      SET @TrN_NumerString_RWS = CDN.NumerString (
                                                                   @TrN_Rodzaj_RWS      , -- Rodzaj dokumentu
                                                                   @TrN_OpeZalId_RWS    , -- Operator inicjujący dokument do numeracji
                                                                   @TrN_StaZalId_RWS    , -- Stanowisko, na którym zainicjowano dokument
                                                                   @TrN_MagZrdId_RWS    , -- Id magazynu do numeracji
                                                                   @TrN_DataDok_RWS     , -- Data dokumentu
                                                                   @SeriaOperatora      ,  -- Seria operatora
                                           default,
                                           default,
                                           default
                                                                 )
                    SET @Komunikat = CDN.SprawdzNumerString ( @DDfId_RWS, @TrN_NumerString_RWS )
                    IF @Komunikat <> ''  AND @TrN_NumerString_RWS != ''
                    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
                    END
                    if (@TrN_NumerString_RWS != '' and @Schem != @TrN_NumerString_RWS)
                    begin
                    SET @TrN_NumerNr_RWS =  ( SELECT ISNULL(MAX(TrN_NumerNr),0) AS MaxNumerNr FROM CDN.TraNag WHERE TrN_NumerString = @TrN_NumerString_RWS )
                    if exists (select * from cdn.TraNag where TrN_NumerString = @TrN_NumerString_RWS and TrN_NumerNr = @TrN_NumerNr_RWS and trn_trnid != @TrN_TrNId_RWS )
                    begin
      SET @TrN_NumerNr_RWS = @TrN_NumerNr_RWS + 1
      update  cdn.tranag set TrN_NumerString = @TrN_NumerString_RWS,TrN_NumerNr = @TrN_NumerNr_RWS where trn_trnid = @TrN_TrNId_RWS
                    end
                    else
      update  cdn.tranag set TrN_NumerString = @TrN_NumerString_RWS where trn_trnid = @TrN_TrNId_RWS
                    end
     --log
                    select @NumerPelny = TrN_numerPelny,@TrN_TypDokumentu_RWS = TrN_TypDokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_RWS
                    if not exists(select * from @Zalogowane where NumerPelny = @NumerPelny and Typ in (1,2))
                    begin
      insert into @Zalogowane select @NumerPelny,2
      exec [CDN].[RejestrOperacjiDodaj] @TrN_TypDokumentu_RWS,0, @TrN_TrNId_RWS, @NumerPelny, 2, ''
     end
                  END
                  -- Update dat w TraNag
                  SELECT @Data =TrN_DataDok  ,@TrN_OpeZalId_RWS    = TrN_OpeModId, @TrN_OpeZalKod_RWS    = TrN_OpeModKod, @TrN_OpeZalNazwisko_RWS    = TrN_OpeModNazwisko, @TrN_StaZalId_RWS    = TrN_StaModId FROM CDN.TraNag WHERE TrN_TrNId = @TrN_TrNId_PWP
                  --pieczatka firmy
                  SELECT @PCIDJS = PCJS_PCJSID FROM CDN.PieczatkiJS WHERE @Data BETWEEN PCJS_DataOd AND PCJS_DataDo
                  SELECT @PCID = Pc_PCID  FROM CDN.Pieczatki WHERE @Data BETWEEN PC_DataOd AND PC_DataDo
                  UPDATE cdn.TraNag SET
                    TrN_TS_mod = getdate(),
                    TrN_OpeModID = @TrN_OpeZalId_RWS,
                    TrN_OpeModKod = @TrN_OpeZalKod_RWS,
                    TrN_OpeModNazwisko = @TrN_OpeZalNazwisko_RWS,
                    TrN_StaModID = @TrN_StaZalId_RWS,
                    TrN_OpeZatwID = case when trn_bufor = 0 then @TrN_OpeZalId_RWS else null end,
                    TrN_OpeZatwKod= case when trn_bufor = 0 then @TrN_OpeZalKod_RWS else '' end,
                    TrN_OpeZatwNazwisko= case when trn_bufor = 0 then @TrN_OpeZalNazwisko_RWS else '' end,
                    TrN_TS_Zatw = case when trn_bufor = 0 then getdate() else null end,
                    TrN_PCID = @PCID,
                    TrN_PCJSID = @PCIDJS,
                    TrN_DataWys = @Data,
                    TrN_DataDok = @Data,
                    TrN_DataOpe = @Data
                  WHERE TrN_TrNId = @TrN_TrNId_RWS
      --logi
      if @TrN_Bufor_PWP = 0
      begin
     select @NumerPelny = TrN_numerPelny,@TrN_TypDokumentu_RWS = TrN_TypDokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_RWS
     if not exists(select * from @Zalogowane where NumerPelny = @NumerPelny and Typ in (103))
     begin
      insert into @Zalogowane select @NumerPelny,103
      exec [CDN].[RejestrOperacjiDodaj] @TrN_TypDokumentu_RWS,0, @TrN_TrNId_RWS, @NumerPelny, 103, ''
     end
      end
                  -- Dodanie elementu na podstawie ProdElem
                  SET @TrE_Lp_RWS       = ISNULL(( SELECT MAX(TrE_Lp) FROM cdn.TraElem JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId WHERE TrN_TrNId = @TrN_TrNId_RWS ),0 ) + 1
                  -- dane elementów
                  SELECT
                    @TrE_Waluta_RWS    = TrE_Waluta,
                    @TrE_KursNumer_RWS = TrE_KursNumer,
                    @TrE_KursL_RWS     = TrE_KursL,
                    @TrE_KursM_RWS     = TrE_KursM
                  FROM cdn.TraElem
                  WHERE TrE_TrEId = @PdE_TrEId
                  -- dane towaru
                  SELECT
                    @TrE_KatId_RWS       = Twr_KatId,
                    @TrE_TwrSWW_RWS      = Twr_SWW,
                    @TrE_Stawka_RWS      = Twr_Stawka,
                    @TrE_Flaga_RWS       = Twr_Flaga,
                    @TrE_Zrodlowa_RWS    = Twr_Zrodlowa,
                    @TrE_TwCNumer_RWS    = Twr_TwCNumer,
                    @TrE_TwrNazwa_RWS    = Twr_Nazwa,
                    @TrE_TwrOpis_RWS     = Twr_Opis,
                    @TrE_JMZ_RWS         = case when Twr_JM !=  @PdE_Jm then Twr_JM else '' end,
                    @TrE_TwrNumerKat_RWS = Twr_NumerKat,
                    @TrE_TwrEAN_RWS      = Twr_EAN,
     @TrE_TwrKodDostawcy_RWS  = Twr_KodDostawcy,
                    @TrE_TwrKod_RWS      = Twr_Kod,
                    @TrE_Typ    = Twr_Typ,
     @Tre_CenaZCzteremaMiejscami = Twr_CenaZCzteremaMiejscami
                  FROM cdn.Towary
                  WHERE Twr_TwrId = @PdE_TwrId
                  -- dodanie nowego elementu
                 IF (@TrE_Typ = 0)
                    INSERT INTO cdn.TraElem (  TrE_TrNId,             TrE_ZwrId, TrE_TrEIdProd,  TrE_Lp,     TrE_TypDokumentu, TrE_Aktywny,  TrE_DataDok,  TrE_DataOpe, TrE_PodmiotTyp, TrE_PodID,  TrE_KatId,      TrE_TwrId,  TrE_TwrNazwa,      TrE_TwrOpis,      TrE_TwrSWW,      TrE_Stawka,      TrE_Flaga,      TrE_Zrodlowa,      TrE_TwCNumer,      TrE_TypNB,     TrE_Cena0,  TrE_Rabat,     TrE_CenaW,  TrE_Waluta,      TrE_KursNumer,      TrE_KursL,      TrE_KursM,     TrE_CenaT,  TrE_Ilosc,  TrE_Jm,  TrE_JmCalkowite,  TrE_JmPrzelicznikL,  TrE_JmPrzelicznikM,  TrE_IloscJM, TrE_WartoscNetto, TrE_WartoscBrutto,  /*TrE_WartoscZakupu, */  TrE_JMZ,      TrE_TwrNumerKat,      TrE_TwrEAN,      TrE_TwrKod,      TrE_LpPow, TrE_Cena0WD, TrE_CenaWWD, TrE_WartoscNettoWal, TrE_WartoscBruttoWal, TrE_Prog, TrE_UpustTyp, TrE_Upust, TrE_UpustKnt, TrE_UpustKntTyp, TrE_KosztUslugi, TrE_Kaucja, TrE_IloscJMKW, TrE_IloscKW,
                                             TrE_Atr1_DeAId, TrE_Atr1_Kod, TrE_Atr1_Wartosc, TrE_Atr2_DeAId, TrE_Atr2_Kod, TrE_Atr2_Wartosc, TrE_Atr3_DeAId, TrE_Atr3_Kod, TrE_Atr3_Wartosc, TrE_Atr4_DeAId, TrE_Atr4_Kod, TrE_Atr4_Wartosc, TrE_Atr5_DeAId, TrE_Atr5_Kod, TrE_Atr5_Wartosc ,TrE_WartoscZakupuWylicz, TrE_WyborDostaw, TrE_MagId,TrE_TwrTyp ,TrE_TwrKodDostawcy,Tre_CenaZCzteremaMiejscami)
                    VALUES                ( @TrN_TrNId_RWS, @PdE_TrEIdRWS_Prw,    @PdE_TrEId, @TrE_Lp_RWS,              318,           1,        @Data,        @Data,              1,         1, @TrE_KatId_RWS, @PdE_TwrId, @TrE_TwrNazwa_RWS, @TrE_TwrOpis_RWS, @TrE_TwrSWW_RWS, @TrE_Stawka_RWS, @TrE_Flaga_RWS, @TrE_Zrodlowa_RWS, @TrE_TwCNumer_RWS,          1,             0,          0,             0, @TrE_Waluta_RWS, @TrE_KursNumer_RWS, @TrE_KursL_RWS, @TrE_KursM_RWS,         0, @PdE_Ilosc, @PdE_Jm, @PdE_JmCalkowite, @PdE_JmPrzelicznikL, @PdE_JmPrzelicznikM, @PdE_IloscJM,                0,                 0,  /*                0, */ @TrE_JMZ_RWS, @TrE_TwrNumerKat_RWS, @TrE_TwrEAN_RWS, @TrE_TwrKod_RWS,          0,           0,           0,                   0,                    0,        0,            0,         0,            0,               0, @PdE_WartoscZakupu/*0*/,          0,             0,           0,
                                            NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               ''            ,                      0,@PdE_WyborDostaw, @PdE_MagId,@TrE_Typ ,@TrE_TwrKodDostawcy_RWS,@Tre_CenaZCzteremaMiejscami )
                  ELSE
                  INSERT INTO cdn.TraElem (  TrE_TrNId,             TrE_ZwrId, TrE_TrEIdProd,  TrE_Lp,     TrE_TypDokumentu, TrE_Aktywny,  TrE_DataDok,  TrE_DataOpe, TrE_PodmiotTyp, TrE_PodID,  TrE_KatId,      TrE_TwrId,  TrE_TwrNazwa,      TrE_TwrOpis,      TrE_TwrSWW,      TrE_Stawka,      TrE_Flaga,      TrE_Zrodlowa,      TrE_TwCNumer,      TrE_TypNB,     TrE_Cena0,  TrE_Rabat,     TrE_CenaW,  TrE_Waluta,      TrE_KursNumer,      TrE_KursL,      TrE_KursM,     TrE_CenaT,  TrE_Ilosc,  TrE_Jm,  TrE_JmCalkowite,  TrE_JmPrzelicznikL,  TrE_JmPrzelicznikM,  TrE_IloscJM, TrE_WartoscNetto, TrE_WartoscBrutto,  /*TrE_WartoscZakupu, */  TrE_JMZ,      TrE_TwrNumerKat,      TrE_TwrEAN,      TrE_TwrKod,      TrE_LpPow, TrE_Cena0WD, TrE_CenaWWD, TrE_WartoscNettoWal, TrE_WartoscBruttoWal, TrE_Prog, TrE_UpustTyp, TrE_Upust, TrE_UpustKnt, TrE_UpustKntTyp, TrE_KosztUslugi, TrE_Kaucja, TrE_IloscJMKW, TrE_IloscKW,
                                             TrE_Atr1_DeAId, TrE_Atr1_Kod, TrE_Atr1_Wartosc, TrE_Atr2_DeAId, TrE_Atr2_Kod, TrE_Atr2_Wartosc, TrE_Atr3_DeAId, TrE_Atr3_Kod, TrE_Atr3_Wartosc, TrE_Atr4_DeAId, TrE_Atr4_Kod, TrE_Atr4_Wartosc, TrE_Atr5_DeAId, TrE_Atr5_Kod, TrE_Atr5_Wartosc ,TrE_WartoscZakupuWylicz, TrE_WyborDostaw, TrE_MagId,TrE_TwrTyp ,TrE_TwrKodDostawcy,Tre_CenaZCzteremaMiejscami  )
                    VALUES                ( @TrN_TrNId_RWS, @PdE_TrEIdRWS_Prw,    @PdE_TrEId, @TrE_Lp_RWS,              318,           1,        @Data,        @Data,              1,         1, @TrE_KatId_RWS, @PdE_TwrId, @TrE_TwrNazwa_RWS, @TrE_TwrOpis_RWS, @TrE_TwrSWW_RWS, @TrE_Stawka_RWS, @TrE_Flaga_RWS, @TrE_Zrodlowa_RWS, @TrE_TwCNumer_RWS,          1,             0,          0,             0, @TrE_Waluta_RWS, @TrE_KursNumer_RWS, @TrE_KursL_RWS, @TrE_KursM_RWS,         0, @PdE_Ilosc, @PdE_Jm, @PdE_JmCalkowite, @PdE_JmPrzelicznikL, @PdE_JmPrzelicznikM, @PdE_IloscJM,                0,                 0,  /*                0, */ @TrE_JMZ_RWS, @TrE_TwrNumerKat_RWS, @TrE_TwrEAN_RWS, @TrE_TwrKod_RWS,          0,           0,           0,                   0,                    0,        0,            0,         0,            0,               0,               0,          0,             0,           0,
                                            NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               ''            ,                      0,@PdE_WyborDostaw, @PdE_MagId,@TrE_Typ ,@TrE_TwrKodDostawcy_RWS ,@Tre_CenaZCzteremaMiejscami )
                  -- Id nowego elementu RWS
                  SET @TrE_TrEId_RWS = ( SELECT MAX(TrE_TrEId) FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_RWS)
                  -- Aktualizacja wartosci zakupu w ProdElem po zaktualizowaniu subelemntów kosztowych przez trigger elementowy na RWS
                  UPDATE cdn.ProdElem
                    SET PdE_WartoscZakupu = (
                                               SELECT sum(TrE_WartoscZakupu)
                                               FROM cdn.TraElem
                                               WHERE (TrE_TrEId = @TrE_TrEId_RWS or (Tre_Zwrid = @TrE_TrEId_RWS and TrE_TypDokumentu = 306))
                                            ),
                        PdE_TrEIdRWS = @TrE_TrEId_RWS
                    WHERE PdE_PdEId = @PdE_PdEId
                  /*UPDATE cdn.TrasElemDost
                    SET
                        TsD_PdEId = @PdE_PdEId
                    WHERE TsD_PdEId = @PdE_PdEId and @PdE_WyborDostaw = 1*/
                  if exists(select * from cdn.prodelem
                  left join cdn.TraElem RWS on pde_treidrws = TrE_TrEId
                  where tre_treid = @TrE_TrEId_RWS and Pde_WyborDostaw = 0 and TrE_WyborDostaw = 1 )
                  begin
       update cdn.prodelem  set Pde_WyborDostaw = 1
       where Pde_WyborDostaw = 0
       and  pde_treidrws in (select tre_treid from cdn.TraElem where tre_treid = @TrE_TrEId_RWS and TrE_WyborDostaw = 1)
       and PdE_PdEId = @PdE_PdEId
       update traselemdost set tsd_pdeid = @PdE_PdEId from cdn.traselemdost traselemdost
       join cdn.prodelem on pde_treidrws = tsd_TrEId
       where tsd_TrEId = @TrE_TrEId_RWS
                  end
      SELECT @PdE_WartoscZakupu = PdE_WartoscZakupu FROM cdn.ProdElem WHERE PdE_PdEId = @PdE_PdEId
                  -- Obsluga agregowania elementow RWS
                  SET @AgregujRWS = ( SELECT ISNULL( Fir_Wartosc,0) FROM cdn.Firma WHERE Fir_Numer = 1483 )
                  IF @AgregujRWS IN ( 1 ) AND @TrN_Rodzaj_RWS = 318000
                    BEGIN
                      SET @TrE_TrEId_Old = NULL
                      -- stare TrE_TrEId, TrE_Ilosc, TrE_IloscJM ale nie z wlasnie dodanego elementu
                      SELECT
                        @TrE_TrEId_Old         = TrE_TrEId,
                        @TrE_Ilosc_Old         = TrE_Ilosc,
                        @TrE_IloscJM_Old       = TrE_IloscJM,
                        @TrE_KosztUslugi_Old = TrE_KosztUslugi
                      FROM cdn.TraElem
                      WHERE
                        TrE_TrNId          = @TrN_TrNId_RWS      AND
                        TrE_TwrId          = @PdE_TwrId          AND
                        TrE_Jm             = @PdE_Jm             AND
                        TrE_JmCalkowite    = @PdE_JmCalkowite    AND
                        TrE_JmPrzelicznikL = @PdE_JmPrzelicznikL AND
                        TrE_JmPrzelicznikM = @PdE_JmPrzelicznikM AND
                        TrE_TrEId          <> @TrE_TrEId_RWS AND
      @PdE_WyborDostaw != 1  AND TrE_WyborDostaw != 1
                      -- skasowanie dodanego elementu i aktualizacja poprzedniego
                      IF @TrE_TrEId_Old IS NOT NULL
                        BEGIN
                          DELETE FROM cdn.TraElem WHERE TrE_TrEId = @TrE_TrEId_RWS
                          IF (@TrE_Typ = 1 or @PdE_WartoscZakupu = 0)
                          UPDATE cdn.TraElem SET
                            TrE_Ilosc         = @TrE_Ilosc_Old         + @PdE_Ilosc,
                            TrE_IloscJM       = @TrE_IloscJM_Old       + @PdE_IloscJM,
                            TrE_TrEIdProd = NULL
                          WHERE TrE_TrEId = @TrE_TrEId_Old
                          ELSE
                          UPDATE cdn.TraElem SET
                            TrE_Ilosc         = @TrE_Ilosc_Old         + @PdE_Ilosc,
                            TrE_IloscJM       = @TrE_IloscJM_Old       + @PdE_IloscJM,
                            TrE_TrEIdProd = NULL,
                            TrE_KosztUslugi = @TrE_KosztUslugi_Old       +@PdE_WartoscZakupu
                          WHERE TrE_TrEId = @TrE_TrEId_Old
                          -- wskaźnik na istniejący element RWS
                          UPDATE cdn.ProdElem SET
                            PdE_TrEIdRWS = @TrE_TrEId_Old
                          WHERE PdE_PdEId = @PdE_PdEId
                        END
                    END
                  -- Tabelka VAT dla RWS
                  EXEC cdn.AktualizujTraVATTraNag @TrN_TrNId_RWS
            END
          CLOSE Magazyny
      DEALLOCATE Magazyny
      -- Kasowanie naglowkow RWS, ktore nie maja elementow
      DELETE cdn.TraNag
        FROM cdn.TraNag
        LEFT OUTER JOIN cdn.TraElem ON TrE_TrNId = TrN_TrNId
        LEFT OUTER JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId
          WHERE TrN_TypDokumentu = 318
            AND TrR_FaId = @TrN_TrNId_PWP
            AND TrE_TrNId IS NULL
      -- teraz zbudowanie prawidłowego subelemntu (wartość elementu została dobrze policzona w poprzednim update)
      -- trigger elementowy jest czuły na TrE_Aktywny = 1 i TrE_Aktywny = 2
      --UPDATE cdn.TraElem SET TrE_Aktywny = 2 WHERE TrE_TrNId = @TrN_TrNId_PWP
   UPDATE cdn.TraSElemDost set TsD_DataOpe = TsD_DataOpe WHERE TsD_TrEId in(select TrE_TrEID from cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_PWP)  and TsD_PdEId != 0
   UPDATE cdn.ProdElem
                    SET PdE_WartoscZakupu =(
                                               SELECT sum(TrE_WartoscZakupu)
                                               FROM cdn.TraElem
                                               WHERE (TrE_TrEId = PdE_TrEIdRWS or (Tre_Zwrid = PdE_TrEIdRWS and TrE_TypDokumentu = 306))
                                            )
            from cdn.ProdElem
  left join cdn.traelem on TrE_TrEID = PdE_TrEId
  where tre_trnid  = @TrN_TrNId_PWP and PdE_WyborDostaw = 1
 if exists (select top 1 PdE_TrEId from cdn.ProdElem
  left join cdn.traelem on TrE_TrEID = PdE_TrEId
  where tre_trnid  = @TrN_TrNId_PWP and PdE_WyborDostaw = 1 )
  or exists
  (select * from cdn.TraSElemDost WHERE TsD_TrEId in(select TrE_TrEID from cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_PWP) and TsD_PdEId = 0)
  UPDATE cdn.TraElem SET TrE_Aktywny = 3 WHERE TrE_TrNId = @TrN_TrNId_PWP
 else
  UPDATE cdn.TraElem SET TrE_Aktywny = 2 WHERE TrE_TrNId = @TrN_TrNId_PWP
 if exists (select * from cdn.TraSElemDost WHERE TsD_TrEId in(select TrE_TrEID from cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_PWP) and TsD_PdEId = 0 )
 begin
  UPDATE cdn.TraSElemDost set TsD_DataOpe = TsD_DataOpe WHERE TsD_TrEId in(select TrE_TrEID from cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_PWP) and TsD_PdEId = 0
    end
    -- odbudowa tabelki VAT dla PWP
    EXEC cdn.AktualizujTraVATTraNag @TrN_TrNId_PWP
    UPDATE cdn.TraElem SET TrE_Aktywny = 1 WHERE TrE_TrNId = @TrN_TrNId_PWP and TrE_Aktywny in (2,3)
 -- jesli powstały WZKK to trzeba dla nich też zmienić aktywny na 1 i sprawdzić czy zasoby się zgadzają
 if exists ( SELECT TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod, TrE_TwrNazwa from cdn.TraElem
      WHERE TrE_TrNId in( select trn_trnid from cdn.tranag where trn_zwridwzkk = @TrN_TrNId_PWP) and TrE_Aktywny in (2,3))
   BEGIN
  UPDATE cdn.TraElem SET TrE_Aktywny = 1 WHERE TrE_TrNId in( select trn_trnid from cdn.tranag where trn_zwridwzkk = @TrN_TrNId_PWP) and TrE_Aktywny in (2,3)
  declare
  @TrE_TrEId1          INT,
  @TrE_TwrId1          INT,
  @TrE_TwrKod1         NVarchar(50),
  @TrE_TwrNazwa1       NVarchar(255),
  @TrE_DataOpe1        DATETIME
  DECLARE EKI CURSOR LOCAL FAST_FORWARD FOR
  SELECT TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod, TrE_TwrNazwa from cdn.TraElem
    WHERE TrE_TrNId in( select trn_trnid from cdn.tranag where trn_zwridwzkk = @TrN_TrNId_PWP)
    GROUP BY TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod, TrE_TwrNazwa
    OPEN EKI
    WHILE 1=1
    BEGIN
   FETCH NEXT FROM EKI INTO @TrE_TrEId1, @TrE_TwrId1, @TrE_DataOpe1, @TrE_TwrKod1,@TrE_TwrNazwa1
   IF @@FETCH_STATUS <> 0 BREAK
   SET @Komunikat = CDN.TwrZasobyErr ( @TrE_TrEId1, @TrE_TwrId1, @TrE_TwrKod,@TrE_TwrNazwa1, @TrE_DataOpe1 )
    IF @Komunikat <> ''
   BEGIN
     RAISERROR( @Komunikat, 16, 1)
     ROLLBACK TRAN
     SET NOCOUNT OFF
     RETURN
   END
    END
  CLOSE EKI
     DEALLOCATE EKI
   END
    DECLARE RWS CURSOR LOCAL FAST_FORWARD FOR
        select TrR_TrNId from cdn.tranagrelacje where TrR_FaId = @TrN_TrNId_PWP and TrR_TrNTyp = 318
    OPEN RWS
  WHILE 1=1
  BEGIN
            FETCH NEXT FROM RWS INTO @TrN_TrNId_RWS
            IF @@FETCH_STATUS <> 0 BREAK
   EXEC cdn.AktualizujTraVATTraNag @TrN_TrNId_RWS
  END
    CLOSE RWS
    DEALLOCATE RWS
    END
  SET NOCOUNT OFF
  -- dla potrzeb wywolania funkcji z poziomu programu procedura musi zwrócić cokolwiek, np. 0
  SELECT 0
