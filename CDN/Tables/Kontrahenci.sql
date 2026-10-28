CREATE TABLE [CDN].[Kontrahenci] (
    [Knt_KntId]                     INT              IDENTITY (1, 1) NOT NULL,
    [Knt_PodmiotTyp]                SMALLINT         CONSTRAINT [DF_Knt_PodmiotTyp] DEFAULT ((1)) NULL,
    [Knt_Kod]                       VARCHAR (20)     NOT NULL,
    [Knt_GLN]                       VARCHAR (13)     NOT NULL,
    [Knt_EAN]                       VARCHAR (16)     NOT NULL,
    [Knt_Grupa]                     VARCHAR (20)     NOT NULL,
    [Knt_Nazwa1]                    NVARCHAR (50)    NOT NULL,
    [Knt_Nazwa2]                    NVARCHAR (50)    NOT NULL,
    [Knt_Nazwa3]                    NVARCHAR (250)   NOT NULL,
    [Knt_Kraj]                      NVARCHAR (40)    NOT NULL,
    [Knt_Wojewodztwo]               NVARCHAR (40)    NOT NULL,
    [Knt_Powiat]                    NVARCHAR (40)    NOT NULL,
    [Knt_Gmina]                     NVARCHAR (40)    NOT NULL,
    [Knt_Ulica]                     NVARCHAR (40)    NOT NULL,
    [Knt_NrDomu]                    NVARCHAR (10)    NOT NULL,
    [Knt_NrLokalu]                  NVARCHAR (10)    NOT NULL,
    [Knt_Miasto]                    NVARCHAR (40)    NOT NULL,
    [Knt_KodPocztowy]               VARCHAR (10)     NOT NULL,
    [Knt_Poczta]                    NVARCHAR (40)    NOT NULL,
    [Knt_Adres2]                    NVARCHAR (40)    NOT NULL,
    [Knt_NipKraj]                   VARCHAR (2)      NOT NULL,
    [Knt_NipE]                      NVARCHAR (20)    NOT NULL,
    [Knt_Nip]                       NVARCHAR (20)    NOT NULL,
    [Knt_Regon]                     VARCHAR (20)     NOT NULL,
    [Knt_Pesel]                     NVARCHAR (11)    NOT NULL,
    [Knt_Telefon1]                  VARCHAR (20)     NOT NULL,
    [Knt_Telefon2]                  VARCHAR (20)     NOT NULL,
    [Knt_TelefonSms]                VARCHAR (20)     CONSTRAINT [DF_Knt_TelefonSms] DEFAULT ('') NOT NULL,
    [Knt_Fax]                       VARCHAR (20)     NOT NULL,
    [Knt_Email]                     NVARCHAR (127)   NOT NULL,
    [Knt_URL]                       VARCHAR (254)    NOT NULL,
    [Knt_KrajISO]                   NVARCHAR (9)     NOT NULL,
    [Knt_Zezwolenie]                NVARCHAR (40)    NOT NULL,
    [Knt_KodTransakcji]             NVARCHAR (2)     NOT NULL,
    [Knt_BazaBR_GUID]               UNIQUEIDENTIFIER NULL,
    [Knt_BNaID]                     INT              NULL,
    [Knt_RachunekNr]                NVARCHAR (51)    NOT NULL,
    [Knt_IBAN]                      SMALLINT         NOT NULL,
    [Knt_OsTytul]                   NVARCHAR (20)    NOT NULL,
    [Knt_OsPlec]                    TINYINT          NOT NULL,
    [Knt_OsNazwisko]                NVARCHAR (40)    NOT NULL,
    [Knt_OsKraj]                    NVARCHAR (40)    NOT NULL,
    [Knt_OsWojewodztwo]             NVARCHAR (40)    NOT NULL,
    [Knt_OsPowiat]                  NVARCHAR (40)    NOT NULL,
    [Knt_OsGmina]                   NVARCHAR (40)    NOT NULL,
    [Knt_OsUlica]                   NVARCHAR (40)    NOT NULL,
    [Knt_OsNrDomu]                  NVARCHAR (10)    NOT NULL,
    [Knt_OsNrLokalu]                NVARCHAR (10)    NOT NULL,
    [Knt_OsMiasto]                  NVARCHAR (40)    NOT NULL,
    [Knt_OsKodPocztowy]             VARCHAR (10)     NOT NULL,
    [Knt_OsPoczta]                  NVARCHAR (40)    NOT NULL,
    [Knt_OsAdres2]                  NVARCHAR (256)   NOT NULL,
    [Knt_OsTelefon]                 VARCHAR (20)     NOT NULL,
    [Knt_OsGSM]                     VARCHAR (20)     NOT NULL,
    [Knt_OsEmail]                   NVARCHAR (40)    NOT NULL,
    [Knt_Informacje]                TINYINT          NOT NULL,
    [Knt_Upust]                     DECIMAL (5, 2)   NOT NULL,
    [Knt_LimitFlag]                 TINYINT          NOT NULL,
    [Knt_LimitKredytu]              DECIMAL (15, 2)  NOT NULL,
    [Knt_LimitPrzeterKredytFlag]    TINYINT          NOT NULL,
    [Knt_LimitPrzeterKredytWartosc] DECIMAL (15, 2)  NOT NULL,
    [Knt_Ceny]                      SMALLINT         NOT NULL,
    [Knt_FplID]                     INT              NULL,
    [Knt_MaxZwloka]                 SMALLINT         NOT NULL,
    [Knt_TerminPlat]                TINYINT          NOT NULL,
    [Knt_Termin]                    SMALLINT         NOT NULL,
    [Knt_KontoOdb]                  NVARCHAR (50)    NOT NULL,
    [Knt_KontoDost]                 NVARCHAR (50)    NOT NULL,
    [Knt_KatID]                     INT              NULL,
    [Knt_KatZakID]                  INT              NULL,
    [Knt_BlokadaDok]                TINYINT          NOT NULL,
    [Knt_LimitKredytuWal]           VARCHAR (3)      NOT NULL,
    [Knt_LimitKredytuWykorzystany]  DECIMAL (15, 2)  NOT NULL,
    [Knt_NieRozliczac]              TINYINT          NOT NULL,
    [Knt_PodatekVat]                TINYINT          NOT NULL,
    [Knt_Finalny]                   TINYINT          NOT NULL,
    [Knt_FinalnyWegiel]             TINYINT          CONSTRAINT [DF_Knt_FinalnyWegiel] DEFAULT ((0)) NOT NULL,
    [Knt_Export]                    TINYINT          NOT NULL,
    [Knt_Rodzaj]                    TINYINT          NOT NULL,
    [Knt_Rodzaj_Dostawca]           TINYINT          NOT NULL,
    [Knt_Rodzaj_Odbiorca]           TINYINT          NOT NULL,
    [Knt_Rodzaj_Konkurencja]        TINYINT          NOT NULL,
    [Knt_Rodzaj_Partner]            TINYINT          NOT NULL,
    [Knt_Rodzaj_Potencjalny]        TINYINT          NOT NULL,
    [Knt_Medialny]                  TINYINT          NOT NULL,
    [Knt_MalyPod]                   TINYINT          NOT NULL,
    [Knt_Rolnik]                    TINYINT          NOT NULL,
    [Knt_Nieaktywny]                TINYINT          NOT NULL,
    [Knt_Chroniony]                 TINYINT          NOT NULL,
    [Knt_Opis]                      NVARCHAR (MAX)   NOT NULL,
    [Knt_OdbiorcaId]                INT              NULL,
    [Knt_OpiekunTyp]                SMALLINT         NULL,
    [Knt_OpiekunId]                 INT              NULL,
    [Knt_OpiekunKsiegTyp]           SMALLINT         NULL,
    [Knt_OpiekunKsiegID]            INT              NULL,
    [Knt_OpiekunKsiegDomyslny]      TINYINT          NULL,
    [Knt_OpiekunPiKTyp]             SMALLINT         NULL,
    [Knt_OpiekunPiKID]              INT              NULL,
    [Knt_OpiekunPiKDomyslny]        TINYINT          NULL,
    [Knt_TerminZwrotuKaucji]        SMALLINT         NOT NULL,
    [Knt_NaliczajPlatnosc]          TINYINT          NOT NULL,
    [Knt_ZakazDokumentowHaMag]      TINYINT          NOT NULL,
    [Knt_ZgodaNaEFaktury]           TINYINT          NOT NULL,
    [Knt_TypWymiany]                TINYINT          NULL,
    [Knt_PowiazanyUoV]              TINYINT          CONSTRAINT [DF_Knt_PowiazanyUoV] DEFAULT ((0)) NOT NULL,
    [Knt_MetodaKasowa]              TINYINT          CONSTRAINT [DF_Knt_MetodaKasowa] DEFAULT ((0)) NOT NULL,
    [Knt_UWDId]                     INT              NULL,
    [Knt_UWDOddzial]                NVARCHAR (10)    NULL,
    [Knt_UWDEmail]                  NVARCHAR (30)    NULL,
    [Knt_TS_Export]                 DATETIME         NULL,
    [Knt_ImportAppId]               VARCHAR (5)      NULL,
    [Knt_ImportRowId]               VARCHAR (36)     NULL,
    [Knt_OpeZalID]                  INT              NULL,
    [Knt_StaZalId]                  INT              NULL,
    [Knt_TS_Zal]                    DATETIME         NOT NULL,
    [Knt_OpeModID]                  INT              NULL,
    [Knt_StaModId]                  INT              NULL,
    [Knt_TS_Mod]                    DATETIME         NOT NULL,
    [Knt_GIDTyp]                    SMALLINT         NULL,
    [Knt_GIDFirma]                  INT              NULL,
    [Knt_GIDNumer]                  INT              NULL,
    [Knt_GIDLp]                     SMALLINT         NULL,
    [Knt_eSklepID]                  INT              NULL,
    [Knt_FCzynnosci]                TINYINT          CONSTRAINT [DF_Knt_FCzynnosci] DEFAULT ((1)) NOT NULL,
    [Knt_FCzesci]                   TINYINT          CONSTRAINT [DF_Knt_FCzesci] DEFAULT ((0)) NOT NULL,
    [Knt_KorKraj]                   NVARCHAR (40)    NULL,
    [Knt_KorMiasto]                 NVARCHAR (40)    NULL,
    [Knt_KorKodPocztowy]            VARCHAR (10)     NULL,
    [Knt_KorPoczta]                 NVARCHAR (40)    NULL,
    [Knt_KorUlica]                  NVARCHAR (40)    NULL,
    [Knt_KorNrDomu]                 NVARCHAR (10)    NULL,
    [Knt_KorNrLokalu]               NVARCHAR (10)    NULL,
    [Knt_NieNaliczajOdsetek]        TINYINT          CONSTRAINT [DF_Knt_NieNaliczajOdsetek] DEFAULT ((0)) NOT NULL,
    [Knt_ESklep]                    TINYINT          CONSTRAINT [DF_Knt_ESklep] DEFAULT ((0)) NOT NULL,
    [Knt_ZwolnionyZAkcyzy]          TINYINT          CONSTRAINT [DF_Knt_ZwolnionyZAkcyzy] DEFAULT ((0)) NOT NULL,
    [Knt_WindykacjaSchematId]       INT              NULL,
    [Knt_WindykacjaOsobaId]         INT              NULL,
    [Knt_WindykacjaEMail]           NVARCHAR (127)   CONSTRAINT [DF_Knt_WindykacjaEMail] DEFAULT ('') NOT NULL,
    [Knt_WindykacjaTelefonSms]      VARCHAR (20)     CONSTRAINT [DF_Knt_WindykacjaTelefonSms] DEFAULT ('') NOT NULL,
    [Knt_Komornik]                  TINYINT          CONSTRAINT [DF_Knt_Komornik] DEFAULT ((0)) NOT NULL,
    [Knt_KomornikOkreg]             NVARCHAR (256)   NULL,
    [Knt_KomornikMiasto]            NVARCHAR (40)    NULL,
    [Knt_KomornikRewir]             NVARCHAR (256)   NULL,
    [Knt_NadID]                     INT              NULL,
    [Knt_Waluta]                    VARCHAR (3)      CONSTRAINT [DF_Knt_Waluta] DEFAULT ('') NOT NULL,
    [Knt_Algorytm]                  TINYINT          CONSTRAINT [DF_Knt_Algorytm] DEFAULT ((0)) NOT NULL,
    [Knt_NieUwzglVATZD]             TINYINT          CONSTRAINT [DF_Knt_NieUwzglVATZD] DEFAULT ((0)) NOT NULL,
    [Knt_GlID]                      INT              NULL,
    [Knt_LoginComarchCloud]         NVARCHAR (256)   NULL,
    [Knt_CJBTyp]                    SMALLINT         NULL,
    [Knt_CJBId]                     INT              NULL,
    [Knt_OpeModKod]                 VARCHAR (20)     CONSTRAINT [DF_Knt_OpeModKod] DEFAULT ('') NOT NULL,
    [Knt_OpeModNazwisko]            NVARCHAR (50)    CONSTRAINT [DF_Knt_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Knt_OpeZalKod]                 VARCHAR (20)     CONSTRAINT [DF_Knt_OpeZalKod] DEFAULT ('') NOT NULL,
    [Knt_OpeZalNazwisko]            NVARCHAR (50)    CONSTRAINT [DF_Knt_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [Knt_OpiekunDomyslny]           TINYINT          NULL,
    [Knt_LpAnonimizacji]            INT              CONSTRAINT [DF_Knt_LpAnonimizacji] DEFAULT ((0)) NOT NULL,
    [Knt_DataAnonimizacji]          DATETIME         NULL,
    [Knt_SplitPay]                  TINYINT          CONSTRAINT [DF_Knt_SplitPay] DEFAULT ((0)) NOT NULL,
    [Knt_Domena]                    NVARCHAR (127)   CONSTRAINT [DF_Knt_Domena] DEFAULT ('') NOT NULL,
    [Knt_DokumentTozsamosci]        NVARCHAR (50)    CONSTRAINT [DF_Knt_DokumentTozsamosci] DEFAULT ('') NOT NULL,
    [Knt_UmowaWegiel]               TINYINT          CONSTRAINT [DF_Knt_UmowaWegiel] DEFAULT ((0)) NOT NULL,
    [Knt_IdSisc]                    VARCHAR (17)     CONSTRAINT [DF_Knt_IdSisc] DEFAULT ('') NOT NULL,
    [Knt_eSklepZrodlo]              SMALLINT         CONSTRAINT [DF_Knt_eSklepZrodlo] DEFAULT ((7)) NOT NULL,
    [Knt_RachunekNr0]               AS               (CONVERT([nvarchar](51),replace(replace([KNT_RACHUNEKNR],'-',''),' ',''),(0))),
    [Knt_AwfZgoda]                  TINYINT          CONSTRAINT [DF_Knt_AwfZgoda] DEFAULT ((0)) NOT NULL,
    [Knt_AwfMonit]                  INT              CONSTRAINT [DF_Knt_AwfMonit] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Knt_Primary] PRIMARY KEY CLUSTERED ([Knt_KntId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KntBnkNazwy] FOREIGN KEY ([Knt_BNaID]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId]),
    CONSTRAINT [FK_KntCJB] FOREIGN KEY ([Knt_CJBId]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId]),
    CONSTRAINT [FK_KntFormaPlatnosci] FOREIGN KEY ([Knt_FplID]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId]),
    CONSTRAINT [FK_KntKategoria] FOREIGN KEY ([Knt_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_KntKategoriaZak] FOREIGN KEY ([Knt_KatZakID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_KntOdbiorca] FOREIGN KEY ([Knt_OdbiorcaId]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId]),
    CONSTRAINT [FK_KntParent] FOREIGN KEY ([Knt_NadID]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId])
);


GO
CREATE NONCLUSTERED INDEX [KntOdbiorca]
    ON [CDN].[Kontrahenci]([Knt_OdbiorcaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KntKod]
    ON [CDN].[Kontrahenci]([Knt_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KntGrupKod]
    ON [CDN].[Kontrahenci]([Knt_Grupa] ASC, [Knt_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KntNazwa]
    ON [CDN].[Kontrahenci]([Knt_Nazwa1] ASC, [Knt_KntId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KntGrupNazwa]
    ON [CDN].[Kontrahenci]([Knt_Grupa] ASC, [Knt_Nazwa1] ASC, [Knt_KntId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KntNIP]
    ON [CDN].[Kontrahenci]([Knt_Nip] ASC, [Knt_KntId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntBnkNazwy]
    ON [CDN].[Kontrahenci]([Knt_BNaID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntFormaPlatnosci]
    ON [CDN].[Kontrahenci]([Knt_FplID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntKategoria]
    ON [CDN].[Kontrahenci]([Knt_KatID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntKategoriaZak]
    ON [CDN].[Kontrahenci]([Knt_KatZakID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntOpiekun]
    ON [CDN].[Kontrahenci]([Knt_OpiekunId] ASC, [Knt_OpiekunTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KntGUID]
    ON [CDN].[Kontrahenci]([Knt_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntEAN]
    ON [CDN].[Kontrahenci]([Knt_EAN] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntGID]
    ON [CDN].[Kontrahenci]([Knt_GIDTyp] ASC, [Knt_GIDFirma] ASC, [Knt_GIDNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntRachunekNr0]
    ON [CDN].[Kontrahenci]([Knt_RachunekNr0] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KntGridLookupFilter]
    ON [CDN].[Kontrahenci]([Knt_Kod] ASC, [Knt_KntId] ASC)
    INCLUDE([Knt_Nieaktywny], [Knt_Nazwa1], [Knt_Nip]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntNieaktywny]
    ON [CDN].[Kontrahenci]([Knt_Nieaktywny] ASC)
    INCLUDE([Knt_KntId], [Knt_Kod], [Knt_Nip], [Knt_Nazwa1]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntBRGUID]
    ON [CDN].[Kontrahenci]([Knt_BazaBR_GUID] ASC)
    INCLUDE([Knt_Kod], [Knt_Telefon1], [Knt_Telefon2], [Knt_Email], [Knt_URL]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntGlID]
    ON [CDN].[Kontrahenci]([Knt_GlID] ASC)
    INCLUDE([Knt_KntId]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KntNadID]
    ON [CDN].[Kontrahenci]([Knt_NadID] ASC)
    INCLUDE([Knt_KntId]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Kontrahenci_Delete_Trigger
  ON CDN.Kontrahenci
  FOR DELETE
AS
SET NOCOUNT ON
-- Sprawdzanie, czy nie skasowano kontrahenta o Id=1 (nieokreślony)
IF EXISTS (SELECT * FROM deleted WHERE deleted.Knt_KntId = 1)
  BEGIN
    RAISERROR('##OPT32334##', 16, 1) -- RAISERROR('Nie można kasować kontrahenta domyślnego. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzanie, czy nie skasowano kontrahenta o Id=2 w O! off-line (rozliczenia)
IF EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = 1470 AND Fir_Wartosc = '4')
 IF EXISTS (SELECT * FROM deleted WHERE deleted.Knt_KntId = 2)
  BEGIN
    RAISERROR('##OPT32335##', 16, 1) -- RAISERROR('Nie można kasować kontrahenta służącego do realizacji rozliczeń. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
--IF ((select max(DSta_TS_SynchroKnt) from CDN.DetalStanowiska) >= (SELECT Knt_TS_Zal FROM deleted))
  declare @maxTS  DATETIME
  select @maxTS = max(DSta_TS_SynchroKnt) from CDN.DetalStanowiska where DSta_Typ != 2
  IF EXISTS(SELECT *  FROM deleted WHERE @maxTS >= Knt_TS_Zal)
  BEGIN
    RAISERROR('##OPT32336##', 16, 1) -- RAISERROR('Nie można kasować kontrahenta wysłanego do Detalu. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  select @maxTS = max(DSta_TS_SynchroKnt) from CDN.DetalStanowiska where DSta_Typ = 2
  IF EXISTS(SELECT *  FROM deleted WHERE @maxTS >= Knt_TS_Zal)
  BEGIN
    RAISERROR('##OPT32337##', 16, 1) -- RAISERROR('Kontrahent nie może być usunięty, został zsynchronizowany z Comarch ERP Mobile.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie wystąpień na fakturach cyklicznych  (WiNi)
  IF EXISTS( SELECT FCK_FCKID FROM CDN.FaCyklKnt WHERE FCK_PodmiotTyp = 1 AND FCK_PodmiotId In (Select Knt_KntId From deleted) )
  BEGIN
    RAISERROR('##OPT32338##', 16, 1) -- RAISERROR('Nie można usunąć wskazanej pozycji. Istnieją faktury cykliczne, na których występuje usuwany kontrahent.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.BnkZdarzenia
IF EXISTS (SELECT * FROM CDN.BnkZdarzenia join deleted ON Bzd_PodmiotTyp = 1 AND Bzd_PodmiotID = Knt_KntID)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=BnkZdarzenia##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą BnkZdarzenia). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.TraNag
IF EXISTS (
  SELECT * FROM CDN.TraNag, deleted
  WHERE Knt_KntId = TrN_OdbID AND TrN_OdbiorcaTyp = 1
  )
OR EXISTS (
  SELECT * FROM CDN.TraNag, deleted
  WHERE Knt_KntId = TrN_OdbDocID AND TrN_OdbiorcaDocTyp = 1
  )
OR EXISTS (
  SELECT * FROM CDN.TraNag, deleted
  WHERE Knt_KntId = TrN_PodZalID AND TrN_PodmiotZalTyp = 1
  )
OR EXISTS (
  SELECT * FROM CDN.TraNag, deleted
  WHERE Knt_KntId = TrN_PodID AND TrN_PodmiotTyp = 1
  )
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=TraNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TraNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.TraElem
IF EXISTS (
  SELECT * FROM CDN.TraElem, deleted
  WHERE Knt_KntId = TrE_PodID AND TrE_PodmiotTyp = 1
  )
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=TraElem##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TraElem). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.DokNag
IF EXISTS (
  SELECT * FROM CDN.DokPodmioty, deleted
  WHERE Knt_KntId = DoP_PodmiotID AND DoP_PodmiotTyp = 1
  )
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=DokNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą DokNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.KntOdbiorcy
--IF EXISTS (
-- SELECT * FROM CDN.KntOdbiorcy, deleted
--  WHERE Knt_KntId = Odb_OdbKntID
--  )
--  BEGIN
--    RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą KntOdbiorcy). ', 16, 1)
--   ROLLBACK TRAN
--    SET NOCOUNT OFF
--    RETURN
--  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.VatNag
IF EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE Knt_KntId = VaN_PodID    AND VaN_PodmiotTyp = 1)
OR EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE Knt_KntId = VaN_PodZalID AND VaN_PodmiotZalTyp = 1)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=VatNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą VatNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.EwidDodNag
IF EXISTS (SELECT * FROM CDN.EwidDodNag, deleted WHERE Knt_KntId = EDN_PodZalID AND EDN_PodmiotZalTyp = 1)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=EwidDodNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą EwidDodNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.DekretyNag
IF EXISTS (SELECT * FROM CDN.DekretyNag, deleted WHERE Knt_KntId = DeN_PodmiotId AND DeN_PodmiotTyp = 1)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=DekretyNag##', 16, 1) -- RAISERROR('Nie można usunąć kontrahenta wybranego na zapisie księgowym (powiązanie z tabelą DekretyNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.ZajeciaWynagr
IF EXISTS (SELECT * FROM CDN.ZajeciaWynagr, deleted WHERE Knt_KntId = ZaW_KntID)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=ZajeciaWynagr##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą ZajeciaWynagr). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.SentZgloszenia
  IF EXISTS (SELECT * FROM CDN.SentZgloszenia join deleted ON Sent_PodmiotTyp = 1 AND Sent_PodID = Knt_KntID)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=SentZgloszenia##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą SentZgloszenia). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.SchematPlatnosci
IF EXISTS (SELECT * FROM CDN.SchematPlatnosci, deleted WHERE SPl_PodmiotTyp = 3 AND SPl_OdbPodmiotTyp = 1 AND SPl_OdbPodmiotID = Knt_KntId)
  BEGIN
    RAISERROR('##OPT32339##', 16, 1) -- RAISERROR('Istnieją elementy schematu płatności pracownika, w których kontrahent jest odbiorcą płatności. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.FormyPlatnosci
IF EXISTS (SELECT * FROM CDN.FormyPlatnosci, deleted WHERE FPl_PodmiotTyp = 1 AND FPl_PodmiotID = Knt_KntID)
  BEGIN
    RAISERROR('##OPT32340##', 16, 1) -- RAISERROR('Usunięcie kontrahenta niemożliwe. Istnieją formy płatności, w których kontrahent jest płatnikiem. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie, czy kotrahent nie jest wysłany z mobile
IF EXISTS (SELECT * FROM CDN.DetalKontrahenci, deleted where DKnt_OptimaId = Knt_KntID)
 BEGIN
  RAISERROR('##OPT32337##', 16, 1) -- RAISERROR('Kontrahent nie może być usunięty, został zsynchronizowany z Comarch ERP Mobile.', 16, 1)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
-- Aktualizacja PodmiotyView
Delete CDN.PodmiotyView
  From CDN.PodmiotyView Join deleted On Pod_PodmiotTyp = 1 And Pod_PodId = Knt_KntId
-- obsługa kasowania rabatow dla kontrahenta
Delete From CDN.Rabaty Where
 Rab_Typ In (2, 4, 5) And
 Rab_PodmiotTyp = 1 And
 Rab_PodmiotId In (Select Knt_KntId From deleted)
Delete From CDN.KntOdbiorcy Where
 Odb_OdbKntId In (Select Knt_KntId From deleted)
Delete From CDN.KntOdbiorcy Where
 Odb_KntOdbId In (Select Knt_KntId From deleted)
-- obsługa kasowania schematow platnosci
Delete From CDN.SchematPlatnosci Where
 SPl_PodmiotTyp=1
 And SPl_PodmiotId In (Select Knt_KntId From deleted)
-- powiązania z esklep
Delete From CDN.eSklepKntRelacje Where
 ESK_KntOptimaID In (Select Knt_KntId From deleted)
-- Skasowanie relacji do dokumentów CRM
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1103 AND DoR_DokumentId IN (SELECT Knt_KntId FROM deleted)
-- Skasowanie relacji do dokumentów KRD
  DELETE CDN.KRD FROM CDN.KRD JOIN deleted ON KRD_KntId IN (SELECT Knt_KntId FROM deleted)
--skasowanie zgod
  Delete CDN.PodmiotRejestracjaZgod
   where PRZ_PodmiotTyp = 1 And PRZ_PodmiotId IN (SELECT Knt_KntId FROM deleted)
-- skasowanie JPK
Delete From CDN.DokKodyJPKV7 Where
 DKV7_ParentTyp = 0
 And DKV7_ParentID In (Select Knt_KntId From deleted)
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Kontrahenci_InsteadOfDelete_Trigger
  ON CDN.Kontrahenci
  INSTEAD OF DELETE
AS
SET NOCOUNT ON
  -- Sprawdzenie, czy towar nie jest wysłany do ESklepu
  IF EXISTS (SELECT * FROM cdn.KntESklepy JOIN deleted d ON d.Knt_KntID = KES_KntID)
    BEGIN
      RAISERROR('##OPT32341##', 16, 1) -- RAISERROR('Nie można kasować kontrahenta związanego z e-Sklep', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 DELETE cdn.Kontrahenci WHERE Knt_KntID IN (SELECT d.Knt_KntID FROM deleted d)
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Kontrahenci_InsertUpdateHandler
  ON CDN.Kontrahenci
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.Knt_OpiekunTyp=3)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.PracKod ON
                    inserted.Knt_OpiekunId = CDN.PracKod.PRA_PraId
              WHERE CDN.PracKod.PRA_PraId IS NULL AND (inserted.Knt_OpiekunTyp=3)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=PracKod##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Kontrahenci_InsertUpdate_Trigger
  ON CDN.Kontrahenci
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy kodu nie jest pusty
  IF EXISTS (SELECT * FROM inserted WHERE Knt_Kod = '')
    BEGIN
          RAISERROR('##OPT32342##', 16, 1) -- RAISERROR('Kod kontrahenta musi być wypełniony.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
-- Sprawdzenie, czy domyślnemu kontrahentowi nie zmieniono kodu
  IF EXISTS (SELECT * FROM inserted JOIN deleted ON inserted.Knt_KntId = deleted.Knt_KntId WHERE inserted.Knt_KntId = 1 AND inserted.Knt_Kod <> deleted.Knt_Kod)
    BEGIN
          RAISERROR('##OPT32343##', 16, 1) -- RAISERROR('Nie można zmieniać kodu kontrahenta domyślnego.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
-- Sprawdzenie, czy domyślnemu kontrahentowi OFF-LINE nie zmieniono kodu
 IF EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = 1470 AND Fir_Wartosc = '4')
  IF EXISTS (SELECT * FROM inserted JOIN deleted ON inserted.Knt_KntId = deleted.Knt_KntId WHERE inserted.Knt_KntId = 2 AND inserted.Knt_Kod <> deleted.Knt_Kod)
    BEGIN
          RAISERROR('##OPT32344##', 16, 1) -- RAISERROR('Nie można zmieniać kodu kontrahenta służącego do realizacji rozliczeń', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
-- Dopisanie gidnumer = id dla kontrahenta bez gidnumer
  If Update (Knt_KntId)
    Update CDN.Kontrahenci
      Set Knt_GIDNumer = inserted.Knt_KntId
    FROM cdn.Kontrahenci JOIN inserted ON cdn.Kontrahenci.Knt_KntId = inserted.Knt_KntId
      Where IsNull(inserted.Knt_GIDNumer,0) = 0
-- Sprawdzanie duplikacji identyfikatora GID
  If Update (Knt_GIDTyp) Or Update (Knt_GIDFirma) Or Update (Knt_GIDNumer)
    Begin
      If Exists (
        Select * From inserted A, CDN.Kontrahenci B Where
          A.Knt_GIDTyp   = B.Knt_GIDTyp   And
          A.Knt_GIDFirma = B.Knt_GIDFirma And
          A.Knt_GIDNumer = B.Knt_GIDNumer And
          A.Knt_KntId   <> B.Knt_KntId    And
          IsNull(A.Knt_GIDTyp, 0) <> 0    And
          IsNull(A.Knt_GIDFirma, 0) <> 0  And
          IsNull(A.Knt_GIDNumer, 0) <> 0)
        Begin
          RAISERROR('##OPT32230##', 16, 1) -- RaisError ('Duplikacja identyfikatora GID', 16,1)
          RollBack Tran
          Return
        End
    End
  If Update (Knt_eSklepID) AND Update (Knt_GIDNumer)
    BEGIN
      If NOT Exists (
        Select * From inserted A, CDN.eSklepKntRelacje B Where
          A.Knt_eSklepID = B.ESK_eSklepID  And
          A.Knt_GIDNumer = B.ESK_KnteSklepID And
          A.Knt_KntId   = B.ESK_KntOptimaID  And
          IsNull(A.Knt_GIDNumer, 0) <> 0  And
          IsNull(A.Knt_eSklepID, 0) <> 0 )
          INSERT INTO CDN.eSklepKntRelacje ( ESK_KntOptimaID,ESK_KnteSklepID,ESK_eSklepID)
          Select A.Knt_KntId,A.Knt_GIDNumer,A.Knt_eSklepID From inserted A WHERE IsNull(A.Knt_GIDNumer, 0) <> 0  And
          IsNull(A.Knt_eSklepID, 0) <> 0
    END
-- Sprawdzanie duplikacji EAN
  If Update (Knt_Kod) Or Update (Knt_EAN)
    Begin
      If Exists (
        Select * From inserted A, CDN.Kontrahenci B Where
         A.Knt_EAN = B.Knt_EAN And A.Knt_EAN <> '' And A.Knt_KntId <> B.Knt_KntId
        )
      Or Exists (
        Select * From inserted A, CDN.Kontrahenci B Where
         A.Knt_EAN = B.Knt_Kod And A.Knt_EAN <> '' And A.Knt_KntId <> B.Knt_KntId
        )
      Or Exists (
        Select * From inserted A, CDN.Kontrahenci B Where
         A.Knt_Kod = B.Knt_EAN And A.Knt_Kod <> '' And A.Knt_KntId <> B.Knt_KntId
        )
        Begin
          RAISERROR('##OPT32345##', 16, 1) -- RaisError ('Duplikacja identyfikatora EAN', 16,1)
          RollBack Tran
          Return
        End
    End
-- Sprawdzanie ustawień związanych ze Split payment
 IF UPDATE (Knt_NieRozliczac) OR UPDATE (Knt_SplitPay)
 BEGIN
  IF EXISTS (SELECT * FROM inserted WHERE inserted.Knt_SplitPay <> 0 AND inserted.Knt_NieRozliczac <> 0)
  BEGIN
   RAISERROR('##OPT32346##', 16, 1) -- RAISERROR('Kontrahent nie może mieć równocześnie zaznaczonych parametrów Split payment i Nie rozliczaj płatności.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
 END
 IF UPDATE (Knt_Finalny) OR UPDATE (Knt_SplitPay)
 BEGIN
  IF EXISTS (SELECT * FROM inserted WHERE inserted.Knt_SplitPay <> 0 AND inserted.Knt_Finalny <> 0)
  BEGIN
   RAISERROR('##OPT32347##', 16, 1) -- RAISERROR('Kontrahent o statusie Osoba fizyczna nie może mieć zaznaczonego parametru Split payment.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
 END
-- Kasowanie wskanika wyeksportowania
If Not Update (Knt_TS_Export) And Exists (Select * From inserted Where Knt_TS_Export Is Not Null)
  Update CDN.Kontrahenci Set Knt_TS_Export = Null Where Knt_KntId In (Select Knt_KntId From inserted Where Knt_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where Knt_ImportRowId Is Null Or Knt_ImportRowId = '')
  Update CDN.Kontrahenci Set Knt_ImportRowId = NewId()
  Where Knt_KntId In (Select Knt_KntId From inserted Where Knt_ImportRowId Is Null Or Knt_ImportRowId = '')
-- Ustawianie Knt_FPlId
If Update (Knt_FPlId)
 If Not Exists (Select * From CDN.Firma Where Fir_Numer=1470 And Fir_Wartosc='4')
  If Exists (Select * From inserted Where Knt_FPlId Is Null)
  Begin
   Declare @DefFPlId Int
   Select @DefFPlId = Knt_FPlId From CDN.Kontrahenci Where Knt_KntId = 1
   If @DefFPlId Is Null
    Select Top 1 @DefFPlId = FPl_FPlId From CDN.FormyPlatnosci Order By FPl_FPlId
   If @DefFPlId Is Not Null
    Update CDN.Kontrahenci Set Knt_FPlId = @DefFPlId
    Where Knt_KntId In (Select Knt_KntId From inserted Where Knt_FPlId Is Null)
  End
-- Aktualizacja Knt_GlID
Update CDN.Kontrahenci Set Knt_GlID = i.Knt_KntID
FROM CDN.Kontrahenci k INNER JOIN inserted i ON i.Knt_KntId = k.Knt_KntID
WHERE NOT EXISTS(SELECT * FROM deleted d WHERE d.Knt_KntID = i.Knt_KntID)
-- Aktualizacja PodmiotyView
--  Aktualizacja istniejących
Update CDN.PodmiotyView Set
  Pod_Kod          = A.Knt_Kod ,
  Pod_Nazwa1       = A.Knt_Nazwa1 ,
  Pod_Nazwa2       = A.Knt_Nazwa2 ,
  Pod_Nazwa3       = A.Knt_Nazwa3 ,
  Pod_Kraj         = A.Knt_Kraj ,
  Pod_Wojewodztwo  = A.Knt_Wojewodztwo ,
  Pod_Powiat       = A.Knt_Powiat ,
  Pod_Gmina        = A.Knt_Gmina ,
  Pod_Ulica        = A.Knt_Ulica ,
  Pod_NrDomu       = A.Knt_NrDomu ,
  Pod_NrLokalu     = A.Knt_NrLokalu ,
  Pod_Miasto       = A.Knt_Miasto ,
  Pod_KodPocztowy  = A.Knt_KodPocztowy ,
  Pod_Poczta       = A.Knt_Poczta ,
  Pod_Adres2       = A.Knt_Adres2 ,
  Pod_Telefon1     = A.Knt_Telefon1 ,
  Pod_Telefon2     = A.Knt_Telefon2 ,
  Pod_TelefonSms   = A.Knt_TelefonSms ,
  Pod_Email        = A.Knt_Email ,
  Pod_Nieaktywny   = A.Knt_Nieaktywny ,
  Pod_Rodzaj       = A.Knt_Rodzaj ,
  Pod_RodzajOpis   = Case A.Knt_Rodzaj When 1 Then 'odbiorca' When 2 Then 'dostawca' When 3 Then 'konkurencja' When 4 Then 'partner' Else 'nieokreślony' End ,
  Pod_Grupa        = A.Knt_Grupa ,
  Pod_NipKraj      = A.Knt_NipKraj ,
  Pod_NIP          = A.Knt_NipE ,
  Pod_Regon        = A.Knt_Regon ,
  Pod_Pesel        = A.Knt_Pesel ,
  Pod_LimitKredytu = A.Knt_LimitKredytu ,
  Pod_ImportRowId  = IsNull(A.Knt_ImportRowId, ''),
  Pod_KontoOdb     = A.Knt_KontoDost,
  Pod_KontoDost    = A.Knt_KontoOdb,
  Pod_NadID        = A.Knt_NadID,
  Pod_GlID         = CASE WHEN A.Knt_NadID Is NOT NULL THEN A.Knt_NadID ELSE A.Knt_KntID END,
  Pod_GlKod        = (SELECT CASE WHEN A.Knt_NadID Is NOT NULL THEN (SELECT C.Knt_Kod FROM cdn.Kontrahenci C WHERE C.Knt_KntID = A.Knt_NadID) ELSE A.Knt_Kod END),
  Pod_GlNazwa12    = (SELECT CASE WHEN A.Knt_NadID Is NOT NULL THEN (SELECT C.Knt_Nazwa1 + ' ' + C.Knt_Nazwa2 FROM cdn.Kontrahenci C WHERE C.Knt_KntID = A.Knt_NadID) ELSE A.Knt_Nazwa1 + ' ' + A.Knt_Nazwa2 END)
From CDN.PodmiotyView
--Join inserted B        On Pod_PodmiotTyp = 1 And Pod_PodId = B.Knt_KntId
--Join CDN.Kontrahenci A On A.Knt_KntId = B.Knt_KntId
-- Poniżej konstruujemy JOIN-a, który zwróci także duplikaty podłączone pod zmienianych kontrahentów - na duplikatach tych chcemy zaktualizować Pod_GlKod i Pod_GlNazwa12 jeśli się to zmieniło na głównym
Join (SELECT Knt_KntID = B.Knt_KntID FROM inserted JOIN CDN.Kontrahenci B ON B.Knt_GlID = inserted.Knt_KntId) D ON Pod_PodmiotTyp = 1 AND Pod_PodId = D.Knt_KntId
Join CDN.Kontrahenci A On A.Knt_KntId = D.Knt_KntId
--  Dodawanie nowych
Insert InTo CDN.PodmiotyView (
  Pod_PodmiotTyp   ,
  Pod_PodId        ,
  Pod_Kod          ,
  Pod_Nazwa1       ,
  Pod_Nazwa2       ,
  Pod_Nazwa3       ,
  Pod_Kraj         ,
  Pod_Wojewodztwo  ,
  Pod_Powiat       ,
  Pod_Gmina        ,
  Pod_Ulica        ,
  Pod_NrDomu       ,
  Pod_NrLokalu     ,
  Pod_Miasto       ,
  Pod_KodPocztowy  ,
  Pod_Poczta       ,
  Pod_Adres2       ,
  Pod_Telefon1     ,
  Pod_Telefon2     ,
  Pod_TelefonSms   ,
  Pod_Email     ,
  Pod_Nieaktywny   ,
  Pod_Rodzaj       ,
  Pod_RodzajOpis   ,
  Pod_Grupa        ,
  Pod_NipKraj      ,
  Pod_NIP          ,
  Pod_Regon        ,
  Pod_Pesel        ,
  Pod_LimitKredytu ,
  Pod_ImportRowId  ,
  Pod_KontoDost    ,
  Pod_KontoOdb     ,
  Pod_NadID        ,
  Pod_GlID         ,
  Pod_GlKod        ,
  Pod_GlNazwa12
 )
Select
  1                 ,
  A.Knt_KntId       ,
  A.Knt_Kod         ,
  A.Knt_Nazwa1      ,
  A.Knt_Nazwa2      ,
  A.Knt_Nazwa3      ,
  A.Knt_Kraj        ,
  A.Knt_Wojewodztwo ,
  A.Knt_Powiat      ,
  A.Knt_Gmina       ,
  A.Knt_Ulica       ,
  A.Knt_NrDomu      ,
  A.Knt_NrLokalu    ,
  A.Knt_Miasto      ,
  A.Knt_KodPocztowy ,
  A.Knt_Poczta      ,
  A.Knt_Adres2      ,
  A.Knt_Telefon1    ,
  A.Knt_Telefon2    ,
  A.Knt_TelefonSms  ,
  A.Knt_Email       ,
  A.Knt_Nieaktywny  ,
  A.Knt_Rodzaj      ,
  Case A.Knt_Rodzaj When 1 Then 'odbiorca' When 2 Then 'dostawca' When 3 Then 'konkurencja' When 4 Then 'partner' Else 'nieokreślony' End ,
  A.Knt_Grupa       ,
  A.Knt_NipKraj     ,
  A.Knt_NipE        ,
  A.Knt_Regon       ,
  A.Knt_Pesel       ,
  A.Knt_LimitKredytu,
  IsNull(A.Knt_ImportRowId,'') ,
  A.Knt_KontoOdb    ,
  A.Knt_KontoDost   ,
  A.Knt_NadID,
  CASE WHEN A.Knt_NadID Is NOT NULL THEN A.Knt_NadID ELSE A.Knt_KntID END,
  (SELECT CASE WHEN A.Knt_NadID Is NOT NULL THEN (SELECT C.Knt_Kod FROM cdn.Kontrahenci C WHERE C.Knt_KntID = A.Knt_NadID) ELSE A.Knt_Kod END),
  (SELECT CASE WHEN A.Knt_NadID Is NOT NULL THEN (SELECT C.Knt_Nazwa1 + ' ' + C.Knt_Nazwa2 FROM cdn.Kontrahenci C WHERE C.Knt_KntID = A.Knt_NadID) ELSE A.Knt_Nazwa1 + ' ' + A.Knt_Nazwa2 END)
From CDN.Kontrahenci A
Join inserted B On A.Knt_KntId = B.Knt_KntId
Left Outer Join CDN.PodmiotyView C On C.Pod_PodmiotTyp = 1 And C.Pod_PodId = B.Knt_KntId
Where C.Pod_PodId Is Null
-- Aktualizacja FaCyklKnt
Update CDN.FaCyklKnt Set
  FcK_Kod          = A.Knt_Kod ,
  FcK_Nazwa        = RTRIM(A.Knt_Nazwa1) + ' ' + RTRIM(A.Knt_Nazwa2) + ' ' + RTRIM(A.Knt_Nazwa3)
From CDN.FaCyklKnt
Join inserted B        On FcK_PodmiotTyp = 1 And FcK_PodmiotId = B.Knt_KntId
Join CDN.Kontrahenci A On A.Knt_KntId = B.Knt_KntId
Set NoCount OFF

GO
CREATE TRIGGER [CDN].Kontrahenci_Update_Limity_Trigger
  ON CDN.Kontrahenci
  FOR UPDATE
AS
  SET NOCOUNT ON
-- Aktualizacja limitu wykorzystanego na kontrahencie głównym w przypadku zmiany tegoż na kontrahencie podrzędnym
-- (sytuacja ma miejsce podczas dodawania, zmiany lub usuwania zdarzenia związanego z kontrahentem -
--  trigger na BnkZdarzenia aktualizuje wówczas Knt_LimitKredytuWykorzystany)
  IF UPDATE(Knt_LimitKredytuWykorzystany)
  BEGIN
    -- Najpierw aktualizacja limitu na kontrahentach nadrzędnych o wartość całkowitego limitu na zmienionych rekordach kontrahentów podrzędnych,
    -- w których przed aktualizacją (w triggerze BnkZdarzenia lub BnkZapisy) musiało być zero.
    Update CDN.Kontrahenci
      Set Knt_LimitKredytuWykorzystany = cdn.Kontrahenci.Knt_LimitKredytuWykorzystany + zmianaLimitu
    FROM cdn.Kontrahenci
      INNER JOIN (SELECT nadID = inserted.Knt_NadID, zmianaLimitu = SUM(inserted.Knt_LimitKredytuWykorzystany) FROM inserted WHERE inserted.Knt_NadID Is Not Null GROUP BY inserted.Knt_NadID) as A
   ON A.nadID = Knt_KntId
    -- Kiedy już wykorzystaliśmy zmienione kwoty limitów ustawiane z zewnątrz (w triggerze BnkZdarzenia lub BnkZapisy) na kontrahentach podrzędnych do ustawienia limitów na kontrahentach nadrzędnych
    -- możemy wyzerować limity na kontrahentach podrzędnych - one zawsze muszą być zerowe
    UPDATE CDN.Kontrahenci
      Set Knt_LimitKredytuWykorzystany = 0
    FROM cdn.Kontrahenci JOIN inserted ON cdn.Kontrahenci.Knt_KntId = inserted.Knt_KntId
      WHERE inserted.Knt_NadID Is Not Null
 END
Set NoCount OFF

GO
CREATE TRIGGER CDN.Kontrahenci_DeleteHandler
  ON CDN.Kontrahenci
  FOR DELETE
AS
SET NOCOUNT ON
    -- obsługa sprawdzania relacji restrict do tabeli CDN.TwrDost
    IF EXISTS
       ( SELECT * FROM CDN.TwrDost, deleted
          WHERE
                deleted.Knt_GIDTyp = CDN.TwrDost.TWD_KntTyp
            AND deleted.Knt_GIDFirma = CDN.TwrDost.TWD_KntFirma
            AND deleted.Knt_GIDNumer = CDN.TwrDost.TWD_KntNumer
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=TwrDost##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
SET NOCOUNT OFF
