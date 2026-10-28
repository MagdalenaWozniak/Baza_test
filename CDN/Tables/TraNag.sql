CREATE TABLE [CDN].[TraNag] (
    [TrN_TrNID]                                   INT             IDENTITY (1, 1) NOT NULL,
    [TrN_RelTrNId]                                INT             NULL,
    [TrN_FVMarza]                                 TINYINT         NULL,
    [TrN_FVMarzaRodzaj]                           TINYINT         NULL,
    [TrN_DDfId]                                   INT             NULL,
    [TrN_TypDokumentu]                            INT             NOT NULL,
    [TrN_ZwrId]                                   INT             NULL,
    [TrN_ZwrIdWZKK]                               INT             NULL,
    [TrN_FaId]                                    INT             NULL,
    [TrN_NumerNr]                                 INT             NOT NULL,
    [TrN_NumerString]                             VARCHAR (31)    NOT NULL,
    [TrN_NumerPelny]                              AS              ([CDN].[FN_NUMERPELNY]([TRN_NUMERNR],[TRN_NUMERSTRING])),
    [TrN_Bufor]                                   SMALLINT        NOT NULL,
    [TrN_Anulowany]                               INT             NOT NULL,
    [TrN_VaNId]                                   INT             NULL,
    [TrN_DataDok]                                 DATETIME        NOT NULL,
    [TrN_DataWys]                                 DATETIME        NOT NULL,
    [TrN_DataOpe]                                 DATETIME        NOT NULL,
    [TrN_NumerObcy]                               VARCHAR (256)   NOT NULL,
    [TrN_DataKur]                                 DATETIME        NOT NULL,
    [TrN_NumerPelnyPrw]                           VARCHAR (256)   NOT NULL,
    [TrN_TaxFreePotwierdzony]                     TINYINT         NOT NULL,
    [TrN_Korekta]                                 TINYINT         NOT NULL,
    [TrN_Fiskalna]                                TINYINT         NOT NULL,
    [TrN_FiskalnaErr]                             INT             NULL,
    [TrN_StatusString]                            AS              ([CDN].[FNTRNSTATUSSTRING]([TRN_TYPDOKUMENTU],[TRN_STATUSINT])),
    [TrN_StatusInt]                               INT             CONSTRAINT [DF_TrN_StatusInt] DEFAULT ((0)) NOT NULL,
    [TrN_RabatPromocyjny]                         DECIMAL (11, 4) NULL,
    [TrN_RabatKorekta]                            DECIMAL (11, 4) NULL,
    [TrN_Detal]                                   TINYINT         NOT NULL,
    [TrN_Rodzaj]                                  INT             NOT NULL,
    [TrN_PodmiotTyp]                              SMALLINT        NULL,
    [TrN_PodID]                                   INT             NULL,
    [TrN_PodNazwa1]                               NVARCHAR (50)   NOT NULL,
    [TrN_PodNazwa2]                               NVARCHAR (50)   NOT NULL,
    [TrN_PodNazwa3]                               NVARCHAR (250)  NOT NULL,
    [TrN_PodKraj]                                 NVARCHAR (40)   NOT NULL,
    [TrN_PodWojewodztwo]                          NVARCHAR (40)   NOT NULL,
    [TrN_PodPowiat]                               NVARCHAR (40)   NOT NULL,
    [TrN_PodGmina]                                NVARCHAR (40)   NOT NULL,
    [TrN_PodUlica]                                NVARCHAR (40)   NOT NULL,
    [TrN_PodNrDomu]                               NVARCHAR (10)   NOT NULL,
    [TrN_PodNrLokalu]                             NVARCHAR (10)   NOT NULL,
    [TrN_PodMiasto]                               NVARCHAR (40)   NOT NULL,
    [TrN_PodKodPocztowy]                          VARCHAR (10)    NOT NULL,
    [TrN_PodPoczta]                               NVARCHAR (40)   NOT NULL,
    [TrN_PodAdres2]                               NVARCHAR (40)   NOT NULL,
    [TrN_PodNipKraj]                              VARCHAR (2)     NOT NULL,
    [TrN_PodNipE]                                 NVARCHAR (20)   NOT NULL,
    [TrN_PodmiotGLN]                              VARCHAR (13)    NOT NULL,
    [TrN_Finalny]                                 TINYINT         NOT NULL,
    [TrN_PodatekVat]                              TINYINT         CONSTRAINT [DF_TrN_PodatekVat] DEFAULT ((0)) NOT NULL,
    [TrN_Pesel]                                   NVARCHAR (11)   CONSTRAINT [DF_TrN_Pesel] DEFAULT ('') NOT NULL,
    [TrN_Export]                                  TINYINT         NOT NULL,
    [TrN_ZwolnionyZAkcyzy]                        TINYINT         CONSTRAINT [DF_TrN_ZwolnionyZAkcyzy] DEFAULT ((0)) NOT NULL,
    [TrN_OdbiorcaTyp]                             SMALLINT        NULL,
    [TrN_OdbID]                                   INT             NULL,
    [TrN_OdbNazwa1]                               NVARCHAR (50)   NOT NULL,
    [TrN_OdbNazwa2]                               NVARCHAR (50)   NOT NULL,
    [TrN_OdbNazwa3]                               NVARCHAR (250)  NOT NULL,
    [TrN_OdbKraj]                                 NVARCHAR (40)   NOT NULL,
    [TrN_OdbWojewodztwo]                          NVARCHAR (40)   NOT NULL,
    [TrN_OdbPowiat]                               NVARCHAR (40)   NOT NULL,
    [TrN_OdbGmina]                                NVARCHAR (40)   NOT NULL,
    [TrN_OdbUlica]                                NVARCHAR (40)   NOT NULL,
    [TrN_OdbNrDomu]                               NVARCHAR (10)   NOT NULL,
    [TrN_OdbNrLokalu]                             NVARCHAR (10)   NOT NULL,
    [TrN_OdbMiasto]                               NVARCHAR (40)   NOT NULL,
    [TrN_OdbKodPocztowy]                          VARCHAR (10)    NOT NULL,
    [TrN_OdbPoczta]                               NVARCHAR (40)   NOT NULL,
    [TrN_OdbAdres2]                               NVARCHAR (40)   NOT NULL,
    [TrN_OdbNipKraj]                              VARCHAR (2)     NOT NULL,
    [TrN_OdbNipE]                                 NVARCHAR (20)   NOT NULL,
    [TrN_OdbiorcaGLN]                             VARCHAR (13)    NOT NULL,
    [TrN_OdbiorcaDocTyp]                          SMALLINT        NULL,
    [TrN_OdbDocID]                                INT             NULL,
    [TrN_OdbTelefon]                              VARCHAR (20)    NULL,
    [TrN_OdbEmail]                                NVARCHAR (127)  NULL,
    [TrN_PlatnikTyp]                              SMALLINT        NULL,
    [TrN_PlatnikID]                               INT             NULL,
    [TrN_FADokumentDostawy]                       TINYINT         CONSTRAINT [DF_TrN_FADokumentDostawy] DEFAULT ((0)) NOT NULL,
    [TrN_FinalnyWegiel]                           TINYINT         CONSTRAINT [DF_TrN_FinalnyWegiel] DEFAULT ((0)) NOT NULL,
    [TrN_NrListuPrzewozowego]                     NVARCHAR (150)  CONSTRAINT [DF_TrN_NrListuPrzewozowego] DEFAULT ('') NOT NULL,
    [TrN_KatID]                                   INT             NULL,
    [TrN_Kategoria]                               VARCHAR (50)    NOT NULL,
    [TrN_FPlId]                                   INT             NULL,
    [TrN_Termin]                                  DATETIME        NOT NULL,
    [TrN_TerminZwrotuKaucji]                      DATETIME        NULL,
    [TrN_RazemNetto]                              DECIMAL (15, 2) NOT NULL,
    [TrN_RazemVAT]                                DECIMAL (15, 2) NOT NULL,
    [TrN_RazemBrutto]                             DECIMAL (15, 2) NOT NULL,
    [TrN_RazemNettoWal]                           DECIMAL (15, 2) NOT NULL,
    [TrN_RazemVATWal]                             DECIMAL (15, 2) NOT NULL,
    [TrN_RazemBruttoWal]                          DECIMAL (15, 2) NOT NULL,
    [TrN_Waluta]                                  VARCHAR (3)     NOT NULL,
    [TrN_KursNumer]                               INT             NOT NULL,
    [TrN_KursL]                                   DECIMAL (15, 4) NOT NULL,
    [TrN_KursM]                                   DECIMAL (5)     NOT NULL,
    [TrN_PlatElemWalSys]                          TINYINT         NOT NULL,
    [TrN_VatDlaDokWal]                            TINYINT         NOT NULL,
    [TrN_PlatKaucje]                              TINYINT         NOT NULL,
    [TrN_PodmiotZalTyp]                           SMALLINT        NULL,
    [TrN_PodZalId]                                INT             NULL,
    [TrN_BlokadaPlatnosci]                        SMALLINT        NOT NULL,
    [TrN_MagZrdId]                                INT             NULL,
    [TrN_MagDocId]                                INT             NULL,
    [TrN_TypNB]                                   TINYINT         NOT NULL,
    [TrN_Rabat]                                   DECIMAL (5, 2)  NOT NULL,
    [TrN_RabatWartosc]                            DECIMAL (15, 2) CONSTRAINT [DF_TrN_RabatWartosc] DEFAULT ((0)) NOT NULL,
    [TrN_Odebral]                                 NVARCHAR (40)   NOT NULL,
    [TrN_Opis]                                    NVARCHAR (1024) NOT NULL,
    [TrN_ZwroconoCalaIlosc]                       TINYINT         NULL,
    [TrN_NotaKorPrzed]                            NVARCHAR (254)  NOT NULL,
    [TrN_NotaKorPo]                               NVARCHAR (254)  NOT NULL,
    [TrN_TrSTyp]                                  TINYINT         NOT NULL,
    [TrN_DekId]                                   INT             NULL,
    [TrN_TS_Export]                               DATETIME        NULL,
    [TrN_ImportAppId]                             VARCHAR (5)     NULL,
    [TrN_ImportRowId]                             VARCHAR (36)    NULL,
    [TrN_OpeZalID]                                INT             NULL,
    [TrN_StaZalId]                                INT             NULL,
    [TrN_TS_Zal]                                  DATETIME        NOT NULL,
    [TrN_OpeModID]                                INT             NULL,
    [TrN_StaModId]                                INT             NULL,
    [TrN_TS_Mod]                                  DATETIME        NOT NULL,
    [TrN_GIDTyp]                                  SMALLINT        NULL,
    [TrN_GIDFirma]                                INT             NULL,
    [TrN_GIDNumer]                                INT             NULL,
    [TrN_GIDLp]                                   SMALLINT        NULL,
    [TrN_eSklepID]                                INT             NULL,
    [TrN_NieOkreslonaWartoscKor]                  INT             NULL,
    [TrN_OFFPrawoDoFAPA]                          TINYINT         NULL,
    [TrN_OFFPrawoDoAnulowania]                    TINYINT         NULL,
    [TrN_OFFExportMag]                            TINYINT         NULL,
    [TrN_Centrala]                                TINYINT         NOT NULL,
    [TrN_KodTransakcji]                           NVARCHAR (2)    NOT NULL,
    [TrN_IsNId]                                   INT             NULL,
    [TrN_DataTransportu]                          DATETIME        NULL,
    [TrN_KodKraju]                                NVARCHAR (2)    NOT NULL,
    [TrN_DabId]                                   INT             NULL,
    [TrN_DataEFaktura]                            DATETIME        NULL,
    [TrN_OpeWysylajacy]                           NVARCHAR (60)   NULL,
    [TrN_EFakturaGUID]                            VARCHAR (36)    NULL,
    [TrN_DataPtwTaxFree]                          DATETIME        NULL,
    [TrN_PreDekID]                                INT             NULL,
    [TrN_TrybNettoVAT]                            INT             CONSTRAINT [DF_TrN_TrybNettoVAT] DEFAULT ((0)) NOT NULL,
    [TrN_AkcyzaMiejsceOdbioru]                    NVARCHAR (200)  NULL,
    [TrN_AkcyzaMiejsceWydania]                    NVARCHAR (200)  NULL,
    [TrN_AkcyzaDataRozpoczeciaPrzem]              DATETIME        NULL,
    [TrN_AkcyzaDataOdbioruOd]                     DATETIME        NULL,
    [TrN_AkcyzaDataOdbioruDo]                     DATETIME        NULL,
    [TrN_Srw]                                     SMALLINT        NULL,
    [TrN_PARodzajKor]                             INT             CONSTRAINT [DF_TrN_PARodzajKor] DEFAULT ((0)) NOT NULL,
    [TrN_MetodaKasowa]                            TINYINT         CONSTRAINT [DF_TrN_MetodaKasowa] DEFAULT ((0)) NOT NULL,
    [TrN_KorektaZTytulu]                          NVARCHAR (1024) CONSTRAINT [DF_TrN_KorektaZTytulu] DEFAULT ('') NOT NULL,
    [TrN_EdycjaTabelkiVAT]                        TINYINT         CONSTRAINT [DF_TrN_EdycjaTabelkiVAT] DEFAULT ((0)) NOT NULL,
    [TrN_PlatnoscNaWZ]                            TINYINT         CONSTRAINT [DF_TrN_PlatnoscNaWZ] DEFAULT ((0)) NOT NULL,
    [TrN_BzpId]                                   INT             CONSTRAINT [DF_TrN_BzpId] DEFAULT ((0)) NOT NULL,
    [TrN_RezerwacjaWew]                           TINYINT         CONSTRAINT [DF_TrN_RezerwacjaWew] DEFAULT ((0)) NOT NULL,
    [TrN_PAFACzesciowe]                           TINYINT         CONSTRAINT [DF_TrN_PAFACzesciowe] DEFAULT ((0)) NOT NULL,
    [TrN_AktualizacjaCenyZakKor]                  TINYINT         CONSTRAINT [DF_TrN_AktualizacjaCenyZakKor] DEFAULT ((0)) NOT NULL,
    [TrN_StawkaNPOO]                              TINYINT         CONSTRAINT [DF_TrN_StawkaNPOO] DEFAULT ((0)) NOT NULL,
    [TrN_WartoscOO]                               DECIMAL (15, 2) CONSTRAINT [DF_TrN_WartoscOO] DEFAULT ((0)) NOT NULL,
    [TrN_AwizoId]                                 INT             CONSTRAINT [DF_TrN_AwizoId] DEFAULT ((0)) NOT NULL,
    [TrN_DokMOSMMId]                              INT             CONSTRAINT [DF_TrN_DokMOSMMId] DEFAULT ((0)) NOT NULL,
    [TrN_ZakID]                                   INT             NULL,
    [TrN_OpeModKod]                               VARCHAR (20)    CONSTRAINT [DF_TrN_OpeModKod] DEFAULT ('') NOT NULL,
    [TrN_OpeModNazwisko]                          NVARCHAR (50)   CONSTRAINT [DF_TrN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [TrN_OpeZalKod]                               VARCHAR (20)    CONSTRAINT [DF_TrN_OpeZalKod] DEFAULT ('') NOT NULL,
    [TrN_OpeZalNazwisko]                          NVARCHAR (50)   CONSTRAINT [DF_TrN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [TrN_PunktyZam]                               INT             CONSTRAINT [DF_TrN_PunktyZam] DEFAULT ((0)) NOT NULL,
    [TrN_PunktyZap]                               INT             CONSTRAINT [DF_TrN_PunktyZap] DEFAULT ((0)) NOT NULL,
    [TrN_WartoscZakupu]                           AS              ([CDN].[FNTRN_WARTOSCZAKUPU]([TRN_TRNID])),
    [TrN_WeryfikacjaVATCzynnyData]                DATETIME        NULL,
    [TrN_WeryfikacjaVATCzynnyWartosc]             INT             NULL,
    [Trn_Sent]                                    INT             CONSTRAINT [DF_Trn_Sent] DEFAULT ((0)) NOT NULL,
    [TrN_eSklepZrodlo]                            INT             NULL,
    [TrN_eSklepRodzajDokumentu]                   TINYINT         NULL,
    [TrN_eSklepFormaPlatnosci]                    NVARCHAR (50)   NULL,
    [TrN_eSklepStatusPlatnosci]                   TINYINT         NULL,
    [TrN_eSklepUwagiKlienta]                      NVARCHAR (2048) NULL,
    [TrN_eSklepSposobDostawyTyp]                  SMALLINT        NULL,
    [TrN_eSklepSposobDostawyNazwa]                NVARCHAR (100)  NULL,
    [TrN_eSklepStatusDostawy]                     SMALLINT        CONSTRAINT [DF_TrN_eSklepStatusDostawy] DEFAULT ((-1)) NULL,
    [TrN_eSklepPunktOdbioruOsobistegoID]          INT             NULL,
    [TrN_eSklepPunktOdbioruOsobistegoIDeSklep]    INT             NULL,
    [TrN_eSklepPunktOdbioruOsobistegoNazwa1]      NVARCHAR (250)  NULL,
    [TrN_eSklepPunktOdbioruOsobistegoNazwa2]      NVARCHAR (250)  NULL,
    [TrN_eSklepPunktOdbioruOsobistegoKrajISO]     NVARCHAR (2)    NULL,
    [TrN_eSklepPunktOdbioruOsobistegoWojewodztwo] NVARCHAR (50)   NULL,
    [TrN_eSklepPunktOdbioruOsobistegoUlica]       NVARCHAR (50)   NULL,
    [TrN_eSklepPunktOdbioruOsobistegoNrBudynku]   NVARCHAR (10)   NULL,
    [TrN_eSklepPunktOdbioruOsobistegoNrLokalu]    NVARCHAR (10)   NULL,
    [TrN_eSklepPunktOdbioruOsobistegoMiasto]      NVARCHAR (50)   NULL,
    [TrN_eSklepPunktOdbioruOsobistegoKodPocztowy] NVARCHAR (10)   NULL,
    [TrN_eSklepPunktOdbioruOsobistegoTelefon]     NVARCHAR (20)   NULL,
    [TrN_eSklepPunktOdbioruOsobistegoGSM]         NVARCHAR (20)   NULL,
    [TrN_eSklepKodPaczkomatuPodst]                NVARCHAR (50)   NULL,
    [TrN_eSklepPaczkomatKodPaczki]                NVARCHAR (30)   NULL,
    [TrN_eSklepPaczkomatPodstMiasto]              NVARCHAR (50)   NULL,
    [TrN_eSklepPaczkomatPodstKodPocztowy]         NVARCHAR (10)   NULL,
    [TrN_eSklepPaczkomatPodstUlica]               NVARCHAR (50)   NULL,
    [TrN_eSklepPaczkomatPodstUlicaNR]             NVARCHAR (50)   NULL,
    [TrN_eSklepKodPaczkomatuRezerw]               NVARCHAR (50)   NULL,
    [TrN_eSklepPaczkomatRezerwMiasto]             NVARCHAR (50)   NULL,
    [TrN_eSklepPaczkomatRezerwKodPocztowy]        NVARCHAR (10)   NULL,
    [TrN_eSklepPaczkomatRezerwUlica]              NVARCHAR (50)   NULL,
    [TrN_eSklepPaczkomatRezerwUlicaNR]            NVARCHAR (50)   NULL,
    [TrN_OpeZatwID]                               INT             NULL,
    [TrN_TS_Zatw]                                 DATETIME        NULL,
    [TrN_OpeWydrID]                               INT             NULL,
    [TrN_TS_Wydr]                                 DATETIME        NULL,
    [TrN_OpeZatwKod]                              VARCHAR (20)    CONSTRAINT [DF_TrN_OpeZatwKod] DEFAULT ('') NOT NULL,
    [TrN_OpeZatwNazwisko]                         NVARCHAR (50)   CONSTRAINT [DF_TrN_OpeZatwNazwisko] DEFAULT ('') NOT NULL,
    [TrN_OpeWydrKod]                              VARCHAR (20)    CONSTRAINT [DF_TrN_OpeWydrKod] DEFAULT ('') NOT NULL,
    [TrN_OpeWydrNazwisko]                         NVARCHAR (50)   CONSTRAINT [DF_TrN_OpeWydrNazwisko] DEFAULT ('') NOT NULL,
    [TrN_PCID]                                    INT             NULL,
    [TrN_PCJSID]                                  INT             NULL,
    [TrN_eSklepPunktOdbioruOsobistegoEmail]       NVARCHAR (200)  NULL,
    [TrN_eSklepPunktOdbioruOsobistegoAPI]         NVARCHAR (MAX)  NULL,
    [TrN_eSklepPunktOdbioruOsobistegoSzerokosc]   NVARCHAR (12)   NULL,
    [TrN_eSklepPunktOdbioruOsobistegoDlugosc]     NVARCHAR (12)   NULL,
    [TrN_DokumentTozsamosci]                      NVARCHAR (50)   CONSTRAINT [DF_TrN_DokumentTozsamosci] DEFAULT ('') NOT NULL,
    [TrN_UmowaWegiel]                             TINYINT         CONSTRAINT [DF_TrN_UmowaWegiel] DEFAULT ((0)) NOT NULL,
    [TrN_NrListuPrzewozowegoTypKuriera]           INT             CONSTRAINT [DF_TrN_NrListuPrzewozowegoTypKuriera] DEFAULT ((0)) NOT NULL,
    [TrN_SplitPay]                                TINYINT         CONSTRAINT [DF_TrN_SplitPay] DEFAULT ((0)) NOT NULL,
    [TrN_WartoscSP]                               DECIMAL (15, 2) CONSTRAINT [DF_TrN_WartoscSP] DEFAULT ((0)) NOT NULL,
    [TrN_eSklepDataDost]                          DATETIME        NULL,
    [TrN_PlatnikRachunekLp]                       INT             CONSTRAINT [DF_TrN_PlatnikRachunekLp] DEFAULT ((0)) NOT NULL,
    [TrN_PlatnikRachunekNr]                       NVARCHAR (51)   CONSTRAINT [DF_TrN_PlatnikRachunekNr] DEFAULT ('') NOT NULL,
    [TrN_OpeEMailID]                              INT             NULL,
    [TrN_TS_EMail]                                DATETIME        NULL,
    [TrN_OpeEMailKod]                             VARCHAR (20)    CONSTRAINT [DF_TrN_OpeEMailKod] DEFAULT ('') NOT NULL,
    [TrN_OpeEMailNazwisko]                        NVARCHAR (50)   CONSTRAINT [DF_TrN_OpeEMailNazwisko] DEFAULT ('') NOT NULL,
    [TrN_AwfWyslano]                              DATETIME        NULL,
    CONSTRAINT [TrN_Primary] PRIMARY KEY CLUSTERED ([TrN_TrNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TrNDokDef] FOREIGN KEY ([TrN_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_TrNKategoria] FOREIGN KEY ([TrN_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_TrNMagazynDoc] FOREIGN KEY ([TrN_MagDocId]) REFERENCES [CDN].[Magazyny] ([Mag_MagId]),
    CONSTRAINT [FK_TrNMagazynZrd] FOREIGN KEY ([TrN_MagZrdId]) REFERENCES [CDN].[Magazyny] ([Mag_MagId]),
    CONSTRAINT [FK_TrNPieczatka] FOREIGN KEY ([TrN_PCID]) REFERENCES [CDN].[Pieczatki] ([PC_PCID]),
    CONSTRAINT [FK_TrNPieczatkaJS] FOREIGN KEY ([TrN_PCJSID]) REFERENCES [CDN].[PieczatkiJS] ([PCJS_PCJSID]),
    CONSTRAINT [FK_TrNPlatnik] FOREIGN KEY ([TrN_PlatnikID], [TrN_PlatnikTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_TrNPlatnosc] FOREIGN KEY ([TrN_FPlId]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId]),
    CONSTRAINT [FK_TrNPodmiot] FOREIGN KEY ([TrN_PodID], [TrN_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrNDataDok]
    ON [CDN].[TraNag]([TrN_TypDokumentu] ASC, [TrN_DataDok] ASC, [TrN_NumerString] ASC, [TrN_NumerNr] ASC, [TrN_Anulowany] ASC, [TrN_Bufor] ASC, [TrN_TrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrNNumer]
    ON [CDN].[TraNag]([TrN_NumerString] ASC, [TrN_NumerNr] ASC, [TrN_Anulowany] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrNTypNUmer]
    ON [CDN].[TraNag]([TrN_TypDokumentu] ASC, [TrN_NumerString] ASC, [TrN_NumerNr] ASC, [TrN_Anulowany] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrNNumerPelny]
    ON [CDN].[TraNag]([TrN_NumerPelny] ASC, [TrN_Anulowany] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrNPodmiot]
    ON [CDN].[TraNag]([TrN_PodID] ASC, [TrN_PodmiotTyp] ASC, [TrN_DataDok] ASC, [TrN_NumerString] ASC, [TrN_NumerNr] ASC, [TrN_TrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrNKategoria]
    ON [CDN].[TraNag]([TrN_KatID] ASC, [TrN_DataDok] ASC, [TrN_TrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNOdbiorca]
    ON [CDN].[TraNag]([TrN_OdbID] ASC, [TrN_OdbiorcaTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNOdbiorcaDoc]
    ON [CDN].[TraNag]([TrN_OdbDocID] ASC, [TrN_OdbiorcaDocTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNPodZaliczka]
    ON [CDN].[TraNag]([TrN_PodZalId] ASC, [TrN_PodmiotZalTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNPlatnosc]
    ON [CDN].[TraNag]([TrN_FPlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNDokDef]
    ON [CDN].[TraNag]([TrN_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNVatNag]
    ON [CDN].[TraNag]([TrN_VaNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNDekrety]
    ON [CDN].[TraNag]([TrN_DekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNPreDekrety]
    ON [CDN].[TraNag]([TrN_PreDekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrNZwrot]
    ON [CDN].[TraNag]([TrN_ZwrId] ASC, [TrN_TrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNFaktura]
    ON [CDN].[TraNag]([TrN_FaId] ASC, [TrN_RelTrNId] ASC, [TrN_ZwroconoCalaIlosc] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNMagazynZrd]
    ON [CDN].[TraNag]([TrN_MagZrdId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNMagazynDoc]
    ON [CDN].[TraNag]([TrN_MagDocId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrNGUID]
    ON [CDN].[TraNag]([TrN_ImportRowId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [TrNGID]
    ON [CDN].[TraNag]([TrN_GIDTyp] ASC, [TrN_GIDFirma] ASC, [TrN_GIDNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrNIntrastad]
    ON [CDN].[TraNag]([TrN_IsNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrN_ZwrIdWZKK]
    ON [CDN].[TraNag]([TrN_ZwrIdWZKK] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrN_Bufor]
    ON [CDN].[TraNag]([TrN_Bufor] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrN_Rodzaj]
    ON [CDN].[TraNag]([TrN_Rodzaj] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrN_DataWys]
    ON [CDN].[TraNag]([TrN_DataWys] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrN_DataOpe]
    ON [CDN].[TraNag]([TrN_DataOpe] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrN_RazemNetto]
    ON [CDN].[TraNag]([TrN_RazemNetto] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrN_Korekta]
    ON [CDN].[TraNag]([TrN_Korekta] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrN_OpeZalPodmiot]
    ON [CDN].[TraNag]([TrN_OpeZalID] ASC, [TrN_PodmiotTyp] ASC, [TrN_PodID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TraNag_InsertUpdate_Trigger
  ON CDN.TraNag
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
SET ARITHABORT ON
Declare
 @TrNId         Int,
 @GIDTyp        Int,
 @GIDFirma      Int,
 @GIDNumer      Int,
 @DekId         Int,
 @VaNId         Int,
 @TypDokumentu  Int,
 @PodmiotTyp    Int,
 @PodId         Int,
 @OdbiorcaTyp   Int,
 @OdbId         Int,
 @PodmiotZalTyp Int,
 @PodZalId      Int,
 @OdbiorcaDocTyp Int,
 @OdbDocId      Int,
 @Bufor         Int,
 @OFFPrawoDoAnulowania         Int,
 @Fiskalna      Int,
 @FiskalnaErr   Int,
 @ZwrId         Int,
 @DataOpe       DateTime,
 @Rodzaj        Int,
 @ImportRowId   NVarchar(36),
 @TS_Export     DateTime,
 @FaId          Int,
 @DataDok       DateTime,
 @DataWys       DateTime,
 @RazemNetto    Decimal(15,2),
 @NumerObcy     NVarchar(30),
 @PodNazwa1   NVarchar(50),
 @PodNazwa2   NVarchar(50),
 @PodNazwa3   NVarchar(250),
 @Kraj        NVarchar(40),
 @Ulica       NVarchar(40),
 @NrDomu      NVarchar(10),
 @NrLokalu    NVarchar(10),
 @Miasto       NVarchar(40),
 @KodPocztowy  NVarchar(10),
 @NIP        NVarchar(20)
DECLARE
 @DOBZM          DATETIME, -- Data Ostatniego BZM
 @TrS_TrSId      INT,
 @TrS_TrEId      INT,
 @TrS_TrSIdDost  INT,
 @TrS_ZwrId      INT,
 @TrS_TwrId      INT,
 @TrS_MagId      INT,
 @TrS_Rodzaj     INT,
 @TrS_Typ        INT,
 @TrS_Metoda     INT,
 @TrS_DataOpe    DATETIME,
 @TrS_Ilosc      DECIMAL(15,4),
 @TrS_Wartosc    DECIMAL(15,2),
 @TrS_Cena       DECIMAL(17,4),
 @NumerPelny     NVarchar(30),
 @KomunikatErr   NVarchar(255),
 @OperatorID  int,
 @OpeModKod   varchar(20),
 @OpeModNazwisko nvarchar(50),
 @Log    int,
 @WhereParam VARCHAR(1024)
Declare dodane Cursor Local Fast_Forward For
Select
 TrN_TrNId,
 TrN_GIDTyp,
 TrN_GIDFirma,
 TrN_GIDNumer,
 TrN_DekId,
 TrN_VaNId,
 TrN_TypDokumentu,
 TrN_PodmiotTyp,
 TrN_PodId,
 TrN_OdbiorcaTyp,
 TrN_OdbId,
 TrN_OdbiorcaDocTyp,
 TrN_OdbDocId,
 TrN_PodmiotZalTyp,
 TrN_PodZalId,
 TrN_Bufor,
 TrN_OFFPrawoDoAnulowania,
 TrN_Fiskalna,
 TrN_FiskalnaErr,
 TrN_ZwrId,
 TrN_DataOpe,
 TrN_Rodzaj,
 TrN_ImportRowId,
 TrN_TS_Export,
 TrN_FaId,
 TrN_NumerPelny,
 TrN_DataDok,
 TrN_DataWys,
 TrN_RazemNetto,
 TrN_NumerObcy,
 TrN_PodNazwa1,
 TrN_PodNazwa2,
 TrN_PodNazwa3,
 TrN_PodKraj,
 TrN_PodUlica,
 TrN_PodNrDomu,
 TrN_PodNrLokalu,
 TrN_PodMiasto,
 TrN_PodKodPocztowy,
 TrN_PodNIPe
 From inserted
Open Dodane
While 1=1
  Begin
    Fetch Next From Dodane InTo
      @TrNId,
      @GIDTyp,
      @GIDFirma,
      @GIDNumer,
      @DekId,
      @VaNId,
      @TypDokumentu,
      @PodmiotTyp,
      @PodId,
      @OdbiorcaTyp,
      @OdbId,
      @OdbiorcaDocTyp,
      @OdbDocId,
      @PodmiotZalTyp,
      @PodZalId,
      @Bufor,
      @OFFPrawoDoAnulowania,
      @Fiskalna,
      @FiskalnaErr,
      @ZwrId,
      @DataOpe,
      @Rodzaj,
      @ImportRowId,
      @TS_Export,
      @FaId,
      @NumerPelny,
      @DataDok,
      @DataWys,
      @RazemNetto,
      @NumerObcy,
      @PodNazwa1,
      @PodNazwa2,
      @PodNazwa3,
      @Kraj,
      @Ulica,
      @NrDomu,
      @NrLokalu,
      @Miasto ,
      @KodPocztowy ,
      @NIP
    If @@Fetch_Status <> 0 Break
 If (Update (TrN_OpeWydrID)
 AND UPDATE(TrN_OpeWydrKod)
 AND UPDATE(TrN_OpeWydrNazwisko)
 AND UPDATE(TrN_TS_Wydr)
 AND NOT UPDATE( TrN_TrNID)
 AND NOT UPDATE( TrN_TerminZwrotuKaucji)
 AND NOT UPDATE( TrN_OFFPrawoDoFAPA)
 AND NOT UPDATE( TrN_OFFPrawoDoAnulowania)
 AND NOT UPDATE( TrN_RelTrNId)
 AND NOT UPDATE( TrN_FVMarza)
 AND NOT UPDATE( TrN_DDfId)
 AND NOT UPDATE( TrN_TypDokumentu)
 AND NOT UPDATE( TrN_ZwrId)
 AND NOT UPDATE( TrN_FaId)
 AND NOT UPDATE( TrN_NumerNr)
 AND NOT UPDATE( TrN_NumerString)
 AND NOT UPDATE( TrN_Bufor)
 AND NOT UPDATE( TrN_Anulowany)
 AND NOT UPDATE( TrN_VaNId)
 AND NOT UPDATE( TrN_DataDok)
 AND NOT UPDATE( TrN_DataWys)
 AND NOT UPDATE( TrN_DataOpe)
 AND NOT UPDATE( TrN_NumerObcy)
 AND NOT UPDATE( TrN_NumerPelnyPrw)
 AND NOT UPDATE( TrN_TaxFreePotwierdzony)
 AND NOT UPDATE( TrN_Korekta)
 AND NOT UPDATE( TrN_Fiskalna)
 AND NOT UPDATE( TrN_FiskalnaErr)
 AND NOT UPDATE( TrN_RabatPromocyjny)
 AND NOT UPDATE( TrN_RabatKorekta)
 AND NOT UPDATE( TrN_Detal)
 AND NOT UPDATE( TrN_Rodzaj)
 AND NOT UPDATE( TrN_PodmiotTyp)
 AND NOT UPDATE( TrN_PodID)
 AND NOT UPDATE( TrN_PodNazwa1)
 AND NOT UPDATE( TrN_PodNazwa2)
 AND NOT UPDATE( TrN_PodNazwa3)
 AND NOT UPDATE( TrN_PodKraj)
 AND NOT UPDATE( TrN_PodWojewodztwo)
 AND NOT UPDATE( TrN_PodPowiat)
 AND NOT UPDATE( TrN_PodGmina)
 AND NOT UPDATE( TrN_PodUlica)
 AND NOT UPDATE( TrN_PodNrDomu)
 AND NOT UPDATE( TrN_PodNrLokalu)
 AND NOT UPDATE( TrN_PodMiasto)
 AND NOT UPDATE( TrN_PodKodPocztowy)
 AND NOT UPDATE( TrN_PodPoczta)
 AND NOT UPDATE( TrN_PodAdres2)
 AND NOT UPDATE( TrN_PodNipKraj)
 AND NOT UPDATE( TrN_PodNipE)
 AND NOT UPDATE( TrN_PodmiotGLN)
 AND NOT UPDATE( TrN_Finalny)
 AND NOT UPDATE( TrN_Export)
 AND NOT UPDATE( TrN_OdbiorcaTyp)
 AND NOT UPDATE( TrN_OdbID)
 AND NOT UPDATE( TrN_OdbNazwa1)
 AND NOT UPDATE( TrN_OdbNazwa2)
 AND NOT UPDATE( TrN_OdbNazwa3)
 AND NOT UPDATE( TrN_OdbKraj)
 AND NOT UPDATE( TrN_OdbWojewodztwo)
 AND NOT UPDATE( TrN_OdbPowiat)
 AND NOT UPDATE( TrN_OdbGmina)
 AND NOT UPDATE( TrN_OdbUlica)
 AND NOT UPDATE( TrN_OdbNrDomu)
 AND NOT UPDATE( TrN_OdbNrLokalu)
 AND NOT UPDATE( TrN_OdbMiasto)
 AND NOT UPDATE( TrN_OdbKodPocztowy)
 AND NOT UPDATE( TrN_OdbPoczta)
 AND NOT UPDATE( TrN_OdbAdres2)
 AND NOT UPDATE( TrN_OdbNipKraj)
 AND NOT UPDATE( TrN_OdbNipE)
 AND NOT UPDATE( TrN_OdbiorcaGLN)
 AND NOT UPDATE( TrN_OdbiorcaDocTyp)
 AND NOT UPDATE( TrN_OdbDocID)
 AND NOT UPDATE( TrN_KatID)
 AND NOT UPDATE( TrN_Kategoria)
 AND NOT UPDATE( TrN_FPlId)
 AND NOT UPDATE( TrN_Termin)
 AND NOT UPDATE( TrN_RazemNetto)
 AND NOT UPDATE( TrN_RazemVAT)
 AND NOT UPDATE( TrN_RazemBrutto)
 AND NOT UPDATE( TrN_RazemNettoWal)
 AND NOT UPDATE( TrN_RazemVATWal)
 AND NOT UPDATE( TrN_RazemBruttoWal)
 AND NOT UPDATE( TrN_Waluta)
 AND NOT UPDATE( TrN_KursNumer)
 AND NOT UPDATE( TrN_KursL)
 AND NOT UPDATE( TrN_KursM)
 AND NOT UPDATE( TrN_PlatElemWalSys)
 AND NOT UPDATE( TrN_PlatKaucje)
 AND NOT UPDATE( TrN_PodmiotZalTyp)
 AND NOT UPDATE( TrN_PodZalId)
 AND NOT UPDATE( TrN_BlokadaPlatnosci)
 AND NOT UPDATE( TrN_MagZrdId)
 AND NOT UPDATE( TrN_MagDocId)
 AND NOT UPDATE( TrN_TypNB)
 AND NOT UPDATE( TrN_Rabat)
 AND NOT UPDATE( TrN_Odebral)
 AND NOT UPDATE( TrN_Opis)
 AND NOT UPDATE( TrN_ZwroconoCalaIlosc)
 AND NOT UPDATE( TrN_NotaKorPrzed)
 AND NOT UPDATE( TrN_NotaKorPo)
 AND NOT UPDATE( TrN_TrSTyp)
 AND NOT UPDATE( TrN_DekId)
 AND NOT UPDATE( TrN_PreDekId)
 AND NOT UPDATE( TrN_TS_Export)
 AND NOT UPDATE( TrN_ImportAppId)
 AND NOT UPDATE( TrN_ImportRowId)
 AND NOT UPDATE( TrN_OpeZalID)
 AND NOT UPDATE( TrN_OpeZalKod)
 AND NOT UPDATE( TrN_OpeZalNazwisko)
 AND NOT UPDATE( TrN_StaZalId)
 AND NOT UPDATE( TrN_TS_Zal)
 AND NOT UPDATE( TrN_OpeModID)
 AND NOT UPDATE( TrN_OpeModKod)
 AND NOT UPDATE( TrN_OpeModNazwisko)
 AND NOT UPDATE( TrN_StaModId)
 AND NOT UPDATE( TrN_TS_Mod)
 AND NOT UPDATE( TrN_GIDTyp)
 AND NOT UPDATE( TrN_GIDFirma)
 AND NOT UPDATE( TrN_GIDNumer)
 AND NOT UPDATE( TrN_GIDLp)
 AND NOT UPDATE( TrN_Centrala)
 AND NOT UPDATE( TrN_KodTransakcji)
 AND NOT UPDATE( TrN_IsNId)
 AND NOT UPDATE( TrN_DataTransportu)
 AND NOT UPDATE( TrN_KodKraju)
 AND NOT UPDATE( TrN_VatDlaDokWal)
 AND NOT UPDATE( TrN_OFFExportMag)
 AND NOT UPDATE( TrN_DataKur)
 AND NOT UPDATE( TrN_OdbEmail)
 AND NOT UPDATE( TrN_OdbTelefon)
 AND NOT UPDATE( TrN_DabId)
 AND NOT UPDATE( TrN_DataEFaktura)
 AND NOT UPDATE( TrN_OpeWysylajacy)
 AND NOT UPDATE( TrN_EFakturaGUID)
 AND NOT UPDATE( TrN_DataPtwTaxFree))
         BEGIN
  Close Dodane
  Deallocate Dodane
  SET NOCOUNT OFF
  return
  END
If (UPDATE (TrN_OpeWydrID)
 AND UPDATE(TrN_OpeWydrKod)
 AND UPDATE(TrN_OpeWydrNazwisko)
 AND UPDATE(TrN_TS_Wydr)
 AND UPDATE (TrN_OpeEMailID)
 AND UPDATE(TrN_OpeEMailKod)
 AND UPDATE(TrN_OpeEMailNazwisko)
 AND UPDATE(TrN_TS_EMail)
 AND NOT UPDATE( TrN_TrNID)
 AND NOT UPDATE( TrN_TerminZwrotuKaucji)
 AND NOT UPDATE( TrN_OFFPrawoDoFAPA)
 AND NOT UPDATE( TrN_OFFPrawoDoAnulowania)
 AND NOT UPDATE( TrN_RelTrNId)
 AND NOT UPDATE( TrN_FVMarza)
 AND NOT UPDATE( TrN_DDfId)
 AND NOT UPDATE( TrN_TypDokumentu)
 AND NOT UPDATE( TrN_ZwrId)
 AND NOT UPDATE( TrN_FaId)
 AND NOT UPDATE( TrN_NumerNr)
 AND NOT UPDATE( TrN_NumerString)
 AND NOT UPDATE( TrN_Bufor)
 AND NOT UPDATE( TrN_Anulowany)
 AND NOT UPDATE( TrN_VaNId)
 AND NOT UPDATE( TrN_DataDok)
 AND NOT UPDATE( TrN_DataWys)
 AND NOT UPDATE( TrN_DataOpe)
 AND NOT UPDATE( TrN_NumerObcy)
 AND NOT UPDATE( TrN_NumerPelnyPrw)
 AND NOT UPDATE( TrN_TaxFreePotwierdzony)
 AND NOT UPDATE( TrN_Korekta)
 AND NOT UPDATE( TrN_Fiskalna)
 AND NOT UPDATE( TrN_FiskalnaErr)
 AND NOT UPDATE( TrN_RabatPromocyjny)
 AND NOT UPDATE( TrN_RabatKorekta)
 AND NOT UPDATE( TrN_Detal)
 AND NOT UPDATE( TrN_Rodzaj)
 AND NOT UPDATE( TrN_PodmiotTyp)
 AND NOT UPDATE( TrN_PodID)
 AND NOT UPDATE( TrN_PodNazwa1)
 AND NOT UPDATE( TrN_PodNazwa2)
 AND NOT UPDATE( TrN_PodNazwa3)
 AND NOT UPDATE( TrN_PodKraj)
 AND NOT UPDATE( TrN_PodWojewodztwo)
 AND NOT UPDATE( TrN_PodPowiat)
 AND NOT UPDATE( TrN_PodGmina)
 AND NOT UPDATE( TrN_PodUlica)
 AND NOT UPDATE( TrN_PodNrDomu)
 AND NOT UPDATE( TrN_PodNrLokalu)
 AND NOT UPDATE( TrN_PodMiasto)
 AND NOT UPDATE( TrN_PodKodPocztowy)
 AND NOT UPDATE( TrN_PodPoczta)
 AND NOT UPDATE( TrN_PodAdres2)
 AND NOT UPDATE( TrN_PodNipKraj)
 AND NOT UPDATE( TrN_PodNipE)
 AND NOT UPDATE( TrN_PodmiotGLN)
 AND NOT UPDATE( TrN_Finalny)
 AND NOT UPDATE( TrN_Export)
 AND NOT UPDATE( TrN_OdbiorcaTyp)
 AND NOT UPDATE( TrN_OdbID)
 AND NOT UPDATE( TrN_OdbNazwa1)
 AND NOT UPDATE( TrN_OdbNazwa2)
 AND NOT UPDATE( TrN_OdbNazwa3)
 AND NOT UPDATE( TrN_OdbKraj)
 AND NOT UPDATE( TrN_OdbWojewodztwo)
 AND NOT UPDATE( TrN_OdbPowiat)
 AND NOT UPDATE( TrN_OdbGmina)
 AND NOT UPDATE( TrN_OdbUlica)
 AND NOT UPDATE( TrN_OdbNrDomu)
 AND NOT UPDATE( TrN_OdbNrLokalu)
 AND NOT UPDATE( TrN_OdbMiasto)
 AND NOT UPDATE( TrN_OdbKodPocztowy)
 AND NOT UPDATE( TrN_OdbPoczta)
 AND NOT UPDATE( TrN_OdbAdres2)
 AND NOT UPDATE( TrN_OdbNipKraj)
 AND NOT UPDATE( TrN_OdbNipE)
 AND NOT UPDATE( TrN_OdbiorcaGLN)
 AND NOT UPDATE( TrN_OdbiorcaDocTyp)
 AND NOT UPDATE( TrN_OdbDocID)
 AND NOT UPDATE( TrN_KatID)
 AND NOT UPDATE( TrN_Kategoria)
 AND NOT UPDATE( TrN_FPlId)
 AND NOT UPDATE( TrN_Termin)
 AND NOT UPDATE( TrN_RazemNetto)
 AND NOT UPDATE( TrN_RazemVAT)
 AND NOT UPDATE( TrN_RazemBrutto)
 AND NOT UPDATE( TrN_RazemNettoWal)
 AND NOT UPDATE( TrN_RazemVATWal)
 AND NOT UPDATE( TrN_RazemBruttoWal)
 AND NOT UPDATE( TrN_Waluta)
 AND NOT UPDATE( TrN_KursNumer)
 AND NOT UPDATE( TrN_KursL)
 AND NOT UPDATE( TrN_KursM)
 AND NOT UPDATE( TrN_PlatElemWalSys)
 AND NOT UPDATE( TrN_PlatKaucje)
 AND NOT UPDATE( TrN_PodmiotZalTyp)
 AND NOT UPDATE( TrN_PodZalId)
 AND NOT UPDATE( TrN_BlokadaPlatnosci)
 AND NOT UPDATE( TrN_MagZrdId)
 AND NOT UPDATE( TrN_MagDocId)
 AND NOT UPDATE( TrN_TypNB)
 AND NOT UPDATE( TrN_Rabat)
 AND NOT UPDATE( TrN_Odebral)
 AND NOT UPDATE( TrN_Opis)
 AND NOT UPDATE( TrN_ZwroconoCalaIlosc)
 AND NOT UPDATE( TrN_NotaKorPrzed)
 AND NOT UPDATE( TrN_NotaKorPo)
 AND NOT UPDATE( TrN_TrSTyp)
 AND NOT UPDATE( TrN_DekId)
 AND NOT UPDATE( TrN_PreDekId)
 AND NOT UPDATE( TrN_TS_Export)
 AND NOT UPDATE( TrN_ImportAppId)
 AND NOT UPDATE( TrN_ImportRowId)
 AND NOT UPDATE( TrN_OpeZalID)
 AND NOT UPDATE( TrN_OpeZalKod)
 AND NOT UPDATE( TrN_OpeZalNazwisko)
 AND NOT UPDATE( TrN_StaZalId)
 AND NOT UPDATE( TrN_TS_Zal)
 AND NOT UPDATE( TrN_OpeModID)
 AND NOT UPDATE( TrN_OpeModKod)
 AND NOT UPDATE( TrN_OpeModNazwisko)
 AND NOT UPDATE( TrN_StaModId)
 AND NOT UPDATE( TrN_TS_Mod)
 AND NOT UPDATE( TrN_GIDTyp)
 AND NOT UPDATE( TrN_GIDFirma)
 AND NOT UPDATE( TrN_GIDNumer)
 AND NOT UPDATE( TrN_GIDLp)
 AND NOT UPDATE( TrN_Centrala)
 AND NOT UPDATE( TrN_KodTransakcji)
 AND NOT UPDATE( TrN_IsNId)
 AND NOT UPDATE( TrN_DataTransportu)
 AND NOT UPDATE( TrN_KodKraju)
 AND NOT UPDATE( TrN_VatDlaDokWal)
 AND NOT UPDATE( TrN_OFFExportMag)
 AND NOT UPDATE( TrN_DataKur)
 AND NOT UPDATE( TrN_OdbEmail)
 AND NOT UPDATE( TrN_OdbTelefon)
 AND NOT UPDATE( TrN_DabId)
 AND NOT UPDATE( TrN_DataEFaktura)
 AND NOT UPDATE( TrN_OpeWysylajacy)
 AND NOT UPDATE( TrN_EFakturaGUID)
 AND NOT UPDATE( TrN_DataPtwTaxFree))
         BEGIN
  Close Dodane
  Deallocate Dodane
  SET NOCOUNT OFF
  return
  END
     If (Update (trn_statusint)
        AND NOT UPDATE( TrN_TrNID)
 AND NOT UPDATE( TrN_TerminZwrotuKaucji)
 AND NOT UPDATE( TrN_OFFPrawoDoFAPA)
 AND NOT UPDATE( TrN_OFFPrawoDoAnulowania)
 AND NOT UPDATE( TrN_RelTrNId)
 AND NOT UPDATE( TrN_FVMarza)
 AND NOT UPDATE( TrN_DDfId)
 AND NOT UPDATE( TrN_TypDokumentu)
 AND NOT UPDATE( TrN_ZwrId)
 AND NOT UPDATE( TrN_FaId)
 AND NOT UPDATE( TrN_NumerNr)
 AND NOT UPDATE( TrN_NumerString)
 AND NOT UPDATE( TrN_Bufor)
 AND NOT UPDATE( TrN_Anulowany)
 AND NOT UPDATE( TrN_VaNId)
 AND NOT UPDATE( TrN_DataDok)
 AND NOT UPDATE( TrN_DataWys)
 AND NOT UPDATE( TrN_DataOpe)
 AND NOT UPDATE( TrN_NumerObcy)
 AND NOT UPDATE( TrN_NumerPelnyPrw)
 AND NOT UPDATE( TrN_TaxFreePotwierdzony)
 AND NOT UPDATE( TrN_Korekta)
 AND NOT UPDATE( TrN_Fiskalna)
 AND NOT UPDATE( TrN_FiskalnaErr)
 AND NOT UPDATE( TrN_RabatPromocyjny)
 AND NOT UPDATE( TrN_RabatKorekta)
 AND NOT UPDATE( TrN_Detal)
 AND NOT UPDATE( TrN_Rodzaj)
 AND NOT UPDATE( TrN_PodmiotTyp)
 AND NOT UPDATE( TrN_PodID)
 AND NOT UPDATE( TrN_PodNazwa1)
 AND NOT UPDATE( TrN_PodNazwa2)
 AND NOT UPDATE( TrN_PodNazwa3)
 AND NOT UPDATE( TrN_PodKraj)
 AND NOT UPDATE( TrN_PodWojewodztwo)
 AND NOT UPDATE( TrN_PodPowiat)
 AND NOT UPDATE( TrN_PodGmina)
 AND NOT UPDATE( TrN_PodUlica)
 AND NOT UPDATE( TrN_PodNrDomu)
 AND NOT UPDATE( TrN_PodNrLokalu)
 AND NOT UPDATE( TrN_PodMiasto)
 AND NOT UPDATE( TrN_PodKodPocztowy)
 AND NOT UPDATE( TrN_PodPoczta)
 AND NOT UPDATE( TrN_PodAdres2)
 AND NOT UPDATE( TrN_PodNipKraj)
 AND NOT UPDATE( TrN_PodNipE)
 AND NOT UPDATE( TrN_PodmiotGLN)
 AND NOT UPDATE( TrN_Finalny)
 AND NOT UPDATE( TrN_Export)
 AND NOT UPDATE( TrN_OdbiorcaTyp)
 AND NOT UPDATE( TrN_OdbID)
 AND NOT UPDATE( TrN_OdbNazwa1)
 AND NOT UPDATE( TrN_OdbNazwa2)
 AND NOT UPDATE( TrN_OdbNazwa3)
 AND NOT UPDATE( TrN_OdbKraj)
 AND NOT UPDATE( TrN_OdbWojewodztwo)
 AND NOT UPDATE( TrN_OdbPowiat)
 AND NOT UPDATE( TrN_OdbGmina)
 AND NOT UPDATE( TrN_OdbUlica)
 AND NOT UPDATE( TrN_OdbNrDomu)
 AND NOT UPDATE( TrN_OdbNrLokalu)
 AND NOT UPDATE( TrN_OdbMiasto)
 AND NOT UPDATE( TrN_OdbKodPocztowy)
 AND NOT UPDATE( TrN_OdbPoczta)
 AND NOT UPDATE( TrN_OdbAdres2)
 AND NOT UPDATE( TrN_OdbNipKraj)
 AND NOT UPDATE( TrN_OdbNipE)
 AND NOT UPDATE( TrN_OdbiorcaGLN)
 AND NOT UPDATE( TrN_OdbiorcaDocTyp)
 AND NOT UPDATE( TrN_OdbDocID)
 AND NOT UPDATE( TrN_KatID)
 AND NOT UPDATE( TrN_Kategoria)
 AND NOT UPDATE( TrN_FPlId)
 AND NOT UPDATE( TrN_Termin)
 AND NOT UPDATE( TrN_RazemNetto)
 AND NOT UPDATE( TrN_RazemVAT)
 AND NOT UPDATE( TrN_RazemBrutto)
 AND NOT UPDATE( TrN_RazemNettoWal)
 AND NOT UPDATE( TrN_RazemVATWal)
 AND NOT UPDATE( TrN_RazemBruttoWal)
 AND NOT UPDATE( TrN_Waluta)
 AND NOT UPDATE( TrN_KursNumer)
 AND NOT UPDATE( TrN_KursL)
 AND NOT UPDATE( TrN_KursM)
 AND NOT UPDATE( TrN_PlatElemWalSys)
 AND NOT UPDATE( TrN_PlatKaucje)
 AND NOT UPDATE( TrN_PodmiotZalTyp)
 AND NOT UPDATE( TrN_PodZalId)
 AND NOT UPDATE( TrN_BlokadaPlatnosci)
 AND NOT UPDATE( TrN_MagZrdId)
 AND NOT UPDATE( TrN_MagDocId)
 AND NOT UPDATE( TrN_TypNB)
 AND NOT UPDATE( TrN_Rabat)
 AND NOT UPDATE( TrN_Odebral)
 AND NOT UPDATE( TrN_Opis)
 AND NOT UPDATE( TrN_ZwroconoCalaIlosc)
 AND NOT UPDATE( TrN_NotaKorPrzed)
 AND NOT UPDATE( TrN_NotaKorPo)
 AND NOT UPDATE( TrN_TrSTyp)
 AND NOT UPDATE( TrN_DekId)
 AND NOT UPDATE( TrN_PreDekId)
 AND NOT UPDATE( TrN_TS_Export)
 AND NOT UPDATE( TrN_ImportAppId)
 AND NOT UPDATE( TrN_ImportRowId)
 AND NOT UPDATE( TrN_OpeZalID)
 AND NOT UPDATE( TrN_OpeZalKod)
 AND NOT UPDATE( TrN_OpeZalNazwisko)
 AND NOT UPDATE( TrN_StaZalId)
 AND NOT UPDATE( TrN_TS_Zal)
 AND NOT UPDATE( TrN_OpeModID)
 AND NOT UPDATE( TrN_OpeModKod)
 AND NOT UPDATE( TrN_OpeModNazwisko)
 AND NOT UPDATE( TrN_StaModId)
 AND NOT UPDATE( TrN_TS_Mod)
 AND NOT UPDATE( TrN_GIDTyp)
 AND NOT UPDATE( TrN_GIDFirma)
 AND NOT UPDATE( TrN_GIDNumer)
 AND NOT UPDATE( TrN_GIDLp)
 AND NOT UPDATE( TrN_Centrala)
 AND NOT UPDATE( TrN_KodTransakcji)
 AND NOT UPDATE( TrN_IsNId)
 AND NOT UPDATE( TrN_DataTransportu)
 AND NOT UPDATE( TrN_KodKraju)
 AND NOT UPDATE( TrN_VatDlaDokWal)
 AND NOT UPDATE( TrN_OFFExportMag)
 AND NOT UPDATE( TrN_DataKur)
 AND NOT UPDATE( TrN_OdbEmail)
 AND NOT UPDATE( TrN_OdbTelefon)
 AND NOT UPDATE( TrN_DabId)
 AND NOT UPDATE( TrN_DataEFaktura)
 AND NOT UPDATE( TrN_OpeWysylajacy)
 AND NOT UPDATE( TrN_EFakturaGUID)
 AND NOT UPDATE( TrN_DataPtwTaxFree))
         BEGIN
    Close Dodane
Deallocate Dodane
SET NOCOUNT OFF
return
  END
   IF EXISTS (SELECT * FROM CDN.TraNag WHERE TrN_TrNid = @TrNId AND TrN_DabID IS NOT NULL AND TrN_TypDokumentu = 301 and TrN_EfakturaGUID IS NOT NULL)
   AND ( EXISTS (SELECT * FROM deleted WHERE TrN_TrNId = @TrNId AND
    (
     @PodId <> TrN_PodId OR
     @DataOpe <> TrN_DataOpe OR
     @DataWys <> TrN_DataWys OR
     @RazemNetto <> TrN_RazemNetto OR
     @NumerObcy <> TrN_NumerObcy OR
     @PodNazwa1 <> TrN_PodNazwa1 OR
     @PodNazwa2 <> TrN_PodNazwa2 OR
     @PodNazwa3 <> TrN_PodNazwa3 OR
     @Kraj <> TrN_PodKraj OR
     @Ulica <> TrN_PodUlica OR
     @NrDomu <> TrN_PodNrDomu OR
     @NrLokalu <> TrN_PodNrLokalu OR
     @Miasto <> TrN_PodMiasto OR
     @KodPocztowy <> TrN_PodKodPocztowy OR
     @NIP <> TrN_PodNiPe
    )
    )
  )
     BEGIN
          RaisError ('##OPT34550##', 16,1)
          RollBack Tran
          Return
     END
-- blokada podwójnej fiskalizacji podczas zatwierdzania dokumentu
    If Update (TrN_Fiskalna) And @Fiskalna = 2
      If Exists(Select * From CDN.TraNag Where TrN_TrNId = @TrNId  AND TrN_Fiskalna = 1)
        Begin
   SET @Fiskalna = 1  -- nie można przechodzić z 1 na 2; tylko z 0 na 2 i z 2 na 1
        End
    -- Sprawdzanie unikalności GID
    If (Update (TrN_GIDTyp) Or Update (TrN_GIDFirma) Or Update (TrN_GIDNumer)) And
        @GIDTyp Is Not Null And @GIDFirma Is Not Null And @GIDNumer Is Not Null
      If Exists (
        Select * From CDN.TraNag Where
          TrN_GIDTyp   = @GIDTyp   And
          TrN_GIDFirma = @GIDFirma And
          TrN_GIDNumer = @GIDNumer And
          TrN_TrNId   <> @TrNId )
        Begin
          RaisError ('##OPT32230##', 16,1)
          RollBack Tran
          Return
        End
    --Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
    If Update (TrN_DekId) And IsNull(@DekId, 0) <> 0
      If Not Exists ( SELECT * FROM CDN.DekretyNag WHERE DeN_DeNId = @DekId )
        BEGIN
          RAISERROR('##OPT32242##%%tabela%%=DekretyNag##', 16, 1) --RAISERROR('Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
    --Sprawdzanie obecności wiersza w tabeli VatNag
    If (Update (TrN_VaNId) Or Update (TrN_TypDokumentu) ) And
        IsNull(@VaNId, 0) <> 0 And @TypDokumentu <> 310
      If Not Exists ( SELECT * FROM CDN.VatNag WHERE VaN_VaNId = @VaNId )
        BEGIN
          RAISERROR('##OPT32242##%%tabela%%=VatNag##', 16, 1) --RAISERROR('Brak wartości w tabeli nadrzędnej (VatNag) ', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
    --Sprawdzanie obecności wiersza w tabeli RemanentNag
    If (Update (TrN_VaNId) Or Update (TrN_TypDokumentu) ) And
        IsNull (@VaNId, 0) <> 0 And @TypDokumentu = 310
      If Not Exists ( SELECT * FROM CDN.RemanentNag Where ReN_ReNId = @VaNId )
        BEGIN
          RAISERROR('##OPT32242##%%tabela%%=RemanentNag##', 16, 1) --RAISERROR('Brak wartości w tabeli nadrzędnej (RemanentNag) ', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
    -- Sprawdzanie powiązania z podmiotem
    If (Update (TrN_PodmiotTyp) Or Update (TrN_PodId))
      Begin
        If IsNull(@PodmiotTyp, 0) <> 0 And IsNull(@PodId, 0) <> 0
          Begin
            If @PodmiotTyp = 1
              Begin
              --  Sprawdzanie obecności wiersza w tabeli Kontrahenci
                If Not Exists (Select * From CDN.Kontrahenci Where Knt_KntId = @PodId)
                  Begin
                    RAISERROR('##OPT32025##%%1%%=Kontrahenci##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Kontrahenci). ', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @PodmiotTyp = 2
              Begin
              --  Sprawdzanie obecności wiersza w tabeli BnkNazwy
                If Not Exists (Select * From CDN.BnkNazwy Where BNa_BNaId = @PodId)
                  Begin
                    RAISERROR('##OPT32025##%%1%%=BnkNazwy##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  BnkNazwy). ', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @PodmiotTyp = 3
              Begin
              --  Sprawdzanie obecności wiersza w tabeli PracKod
                If Not Exists (Select * From CDN.PracKod Where Pra_PraId = @PodId)
                  Begin
                    RAISERROR('##OPT32025##%%1%%=PracKod##', 16, 1) --RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  PracKod). ', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @PodmiotTyp = 5
              Begin
              --  Sprawdzanie obecności wiersza w tabeli Urzedy
                If Not Exists (Select * From CDN.Urzedy Where Urz_UrzId = @PodId)
                  Begin
                    RAISERROR('##OPT32025##%%1%%=Urzedy##', 16, 1) --RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Urzedy). ', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
          End
        Else
          Begin
            Update CDN.TraNag
             Set TrN_PodmiotTyp = 1, TrN_PodId = 1
             Where TrN_TrNId = @TrNId
            Update CDN.TraElem
             Set TrE_PodmiotTyp = 1, TrE_PodId = 1
             Where TrE_TrNId = @TrNId
          End
      End
    -- Sprawdzanie powiązania z odbiorcą
    If (Update (TrN_OdbiorcaTyp) Or Update (TrN_OdbId))
      Begin
        If IsNull(@OdbiorcaTyp, 0) <> 0 And IsNull(@OdbId, 0) <> 0
          Begin
            If @OdbiorcaTyp = 1
              Begin
              --  Sprawdzanie obecności wiersza w tabeli Kontrahenci
                If Not Exists (Select * From CDN.Kontrahenci Where Knt_KntId = @OdbId)
                  Begin
                    RAISERROR('##OPT32025##%%1%%=Kontrahenci##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Kontrahenci). ', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @OdbiorcaTyp = 2
              Begin
              --  Sprawdzanie obecności wiersza w tabeli BnkNazwy
                If Not Exists (Select * From CDN.BnkNazwy Where BNa_BNaId = @OdbId)
                  Begin
                    RAISERROR('##OPT32025##%%1%%=BnkNazwy##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  BnkNazwy). ', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @OdbiorcaTyp = 3
              Begin
              --  Sprawdzanie obecności wiersza w tabeli PracKod
                If Not Exists (Select * From CDN.PracKod Where Pra_PraId = @OdbId)
                  Begin
                    RAISERROR('##OPT32025##%%1%%=PracKod##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  PracKod). ', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @OdbiorcaTyp = 5
              Begin
              --  Sprawdzanie obecności wiersza w tabeli Urzedy
                If Not Exists (Select * From CDN.Urzedy Where Urz_UrzId = @OdbId)
                  Begin
                    RAISERROR('##OPT32025##%%1%%=Urzedy##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Urzedy). ', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
          End
        Else
          Begin
            Update CDN.TraNag
             Set TrN_OdbiorcaTyp = 1, TrN_OdbId = 1
             Where TrN_TrNId = @TrNId
          End
      End
    -- Sprawdzanie powiązania z zaliczkobiorcą
    If (Update (TrN_PodmiotZalTyp) Or Update (TrN_PodZalId)) And
        IsNull(@PodmiotZalTyp, 0) <> 0 And IsNull(@PodZalId, 0) <> 0
      Begin
        If @PodmiotZalTyp = 1
          Begin
          --  Sprawdzanie obecności wiersza w tabeli Kontrahenci
            If Not Exists (Select * From CDN.Kontrahenci Where Knt_KntId = @PodZalId)
              Begin
                RAISERROR('##OPT32025##%%1%%=Kontrahenci##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Kontrahenci). ', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @PodmiotZalTyp = 2
          Begin
          --  Sprawdzanie obecności wiersza w tabeli BnkNazwy
            If Not Exists (Select * From CDN.BnkNazwy Where BNa_BNaId = @PodZalId)
              Begin
                RAISERROR('##OPT32025##%%1%%=BnkNazwy##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  BnkNazwy). ', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @PodmiotZalTyp = 3
          Begin
          --  Sprawdzanie obecności wiersza w tabeli PracKod
            If Not Exists (Select * From CDN.PracKod Where Pra_PraId = @PodZalId)
              Begin
                RAISERROR('##OPT32025##%%1%%=PracKod##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  PracKod). ', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @PodmiotZalTyp = 5
          Begin
          --  Sprawdzanie obecności wiersza w tabeli Urzedy
            If Not Exists (Select * From CDN.Urzedy Where Urz_UrzId = @PodZalId)
              Begin
                RAISERROR('##OPT32025##%%1%%=Urzedy##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Urzedy). ', 16, 1)
                RollBack Tran
                Return
              End
          End
      End
    -- Sprawdzanie powiązania z zaliczkobiorcą
    If (Update (TrN_OdbiorcaDocTyp) Or Update (TrN_OdbDocId)) And
        IsNull(@OdbiorcaDocTyp, 0) <> 0 And IsNull(@OdbDocId, 0) <> 0
      Begin
        If @OdbiorcaDocTyp = 1
          Begin
          --  Sprawdzanie obecności wiersza w tabeli Kontrahenci
            If Not Exists (Select * From CDN.Kontrahenci Where Knt_KntId = @OdbDocId)
              Begin
                RAISERROR('##OPT32025##%%1%%=Kontrahenci##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Kontrahenci). ', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @OdbiorcaDocTyp = 2
          Begin
          --  Sprawdzanie obecności wiersza w tabeli BnkNazwy
            If Not Exists (Select * From CDN.BnkNazwy Where BNa_BNaId = @OdbDocId)
              Begin
                RAISERROR('##OPT32025##%%1%%=BnkNazwy##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  BnkNazwy). ', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @OdbiorcaDocTyp = 3
          Begin
          --  Sprawdzanie obecności wiersza w tabeli PracKod
            If Not Exists (Select * From CDN.PracKod Where Pra_PraId = @OdbDocId)
              Begin
                RAISERROR('##OPT32025##%%1%%=PracKod##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  PracKod). ', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @OdbiorcaDocTyp = 5
          Begin
          --  Sprawdzanie obecności wiersza w tabeli Urzedy
            If Not Exists (Select * From CDN.Urzedy Where Urz_UrzId = @OdbDocId)
              Begin
                RAISERROR('##OPT32025##%%1%%=Urzedy##', 16, 1)--RaisError ('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Urzedy). ', 16, 1)
                RollBack Tran
                Return
              End
          End
      End
-- Kontrola dokumentu anulowanego offline
    If @OFFPrawoDoAnulowania = 1
     IF EXISTS (SELECT * FROM CDN.TraNag Where TrN_ZwrId = @ZwrId And TrN_Bufor <> -1 AND TrN_TrNId > @TrNId AND  TrN_Rodzaj NOT IN (306071, 306072, 306061 ))
        BEGIN
          RAISERROR('##OPT34562##', 16, 1)--RAISERROR('Nie można anulować dokumentu, do którego istnieją późniejsze aktywne korekty', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
-- Kontrola dokumentu anulowanego
    If @Bufor = -1
      Begin
      -- Czy dokument nie jest zaksięgowany do rej. Vat
      If IsNull(@VaNId, 0) <> 0
        BEGIN
          RAISERROR('##OPT34563##', 16, 1)--RAISERROR('Nie można anulować dokumentu zaksięgowanego do rejestru Vat', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
      --sprawdzenie, czy faktura nie jest zaksięgowana do DekretyNag
      If IsNull(@DekId, 0) <> 0
        BEGIN
          RAISERROR('##OPT34564##', 16, 1)--RAISERROR('Nie można anulować dokumentu zaksięgowanego do dziennika (DekretyNag)', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
      --sprawdzenie, czy faktura nie jest zafiskalizowana
      IF @Fiskalna = 1 AND @FiskalnaErr = 0
        BEGIN
          RAISERROR('##OPT34041##', 16, 1)--RAISERROR('Nie można anulować dokumentu zafiskalizowanego', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
      --sprawdzenie, czy nie ma faktury korygującej do wymienionej faktury
      If Exists (Select * From CDN.TraNag Where TrN_ZwrId = @TrNId And TrN_Bufor<>-1 And  CDN.FzDoFrr( @TrNId, TrN_Rodzaj) = 0 AND  TrN_Rodzaj NOT IN (306071, 306072, 306061 ))
        BEGIN
          RAISERROR('##OPT34565##', 16, 1)--RAISERROR('Nie można anulować dokumentu, do którego istnieją aktywne korekty', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
      --sprawdzenie, czy nie ma faktury korygującej do wymienionej faktury korygującej (kolejnej w "łancuszku"
      IF EXISTS (SELECT * FROM CDN.TraNag Where TrN_ZwrId = @ZwrId And TrN_Bufor <> -1 AND TrN_TrNId > @TrNId AND  TrN_Rodzaj NOT IN (306071, 306072, 306061 ) and ISNULL(TrN_ZwrIdWZKK,0) =0) and  update(trn_bufor)
        BEGIN
          RAISERROR('##OPT34562##', 16, 1)--RAISERROR('Nie można anulować dokumentu, do którego istnieją późniejsze aktywne korekty', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
     IF EXISTS (SELECT A.TrR_TrNId FROM CDN.tranagrelacje A
               JOIN CDN.TraNagRelacje B ON B.TrR_FAId = A.TrR_FAId
               WHERE A.TrR_TrNId =  @TrNId and
                  A.TrR_TrNTyp=306 AND B.TrR_TrNTyp = 306 AND A.TrR_FaTyp = 320 AND B.TrR_FaTyp = 320
                  AND B.TrR_TrNId > @TrNId
                  AND NOT EXISTS (SELECT C.Trr_TrRId FROM CDN.TraNagRelacje C where B.TrR_TrNId = C.TrR_TrNID AND  c.Trr_FaTyp = 302))
        BEGIN
          RAISERROR('##OPT34566##', 16, 1)--RAISERROR('Nie można anulować dokumentu WZ powstałego z faktury proforma, jeśli istnieją późniejsze WZ', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
      --sprawdzenie, czy dokument nie należy do zamkniętego okresu
      -- dokumenty pierwotne moga byc anulowane w zamknietym okresie
      Set @DOBZM = Null
      SELECT @DOBZM = MAX(TrN_DataOpe) FROM CDN.TraNag WHERE TrN_Rodzaj = 310005
      If @DOBZM Is Not Null And @DataOpe <= @DOBZM And @Rodzaj Not In ( 301100, 302100, 305100, 311000)
        BEGIN
          RAISERROR('##OPT34567##', 16, 1)--RAISERROR('Dokument należy do zamkniętego okresu. ', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
      --sprawdzenie, czy z dokumentu o charakterze dostawy nie sprzedano już tej dostawy
      If Exists (Select * From CDN.TraElem B
       Join CDN.TraSElem C On C.TrS_TrEId=B.TrE_TrEId
       Join CDN.TraSElem D On D.TrS_TrSIdDost=C.TrS_TrSId And D.TrS_TrSId<>C.TrS_TrSId
       Where TrE_TrNId = @TrNId)
         BEGIN
           RAISERROR('##OPT34568##', 16, 1)--RAISERROR('Dostawy pochodzące z tego dokumentu zostały wykorzystane.', 16, 1)
           ROLLBACK TRAN
           SET NOCOUNT OFF
           RETURN
         END
      -- symulacja kasowania przy anulowaniu - czy nie przechodzimy przez zero ( dla AVCO i QUAN )
      -- kursor po wszystkich kasowanych subelementach z anulowanego dokumentu magazynowego
      If @TypDokumentu IN ( 310, 307, 303, 304, 306, 312, 302, 305, 317, 318  )
        Begin
          DECLARE Subelementy CURSOR LOCAL FAST_FORWARD FOR
           SELECT TrS_TrSId, TrS_TrEId, TrS_TrSIdDost, TrS_ZwrId, TrS_TwrId, TrS_MagId, TrS_Rodzaj, TrS_Typ, TrS_Metoda, TrS_DataOpe, TrS_Ilosc, TrS_Wartosc, TrS_Cena
           FROM TraSElem
           JOIN TraElem  ON TrS_TrEId = TrE_TrEId
           WHERE TrE_TrNId = @TrNId -- AND TrS_Metoda IN ( 3, 4 )
          OPEN Subelementy
          WHILE 1=1
            BEGIN
              -- dla każdego anulowanego subelementu odtworzenie ilosci i sprawdzenie, czy nie przekroczono zera
              FETCH NEXT FROM Subelementy INTO @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena
              IF @@FETCH_STATUS <> 0 BREAK
--              EXECUTE CDN.sp_AktualizujTwrIlosci 2, @TrS_TwrId, @TrS_MagId, @TrS_Typ, @TrS_DataOpe, @TrS_Ilosc, 0
--              SET @KomunikatErr = CDN.fn_TwrIlosciErr ( @TrS_TwrId, @TrS_MagId, @TrS_DataOpe )
            SET @KomunikatErr = CDN.TwrIlosciErr ( 2, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 0 )
--              EXECUTE CDN.sp_AktualizujTwrIlosci 1, @TrS_TwrId, @TrS_MagId, @TrS_Typ, @TrS_DataOpe, @TrS_Ilosc, 0
              IF @KomunikatErr <> ''
                BEGIN
                  RAISERROR( @KomunikatErr, 16, 1 )
                  ROLLBACK TRAN
                  RETURN
                END
            END
          CLOSE Subelementy
          DEALLOCATE Subelementy
        End
      --sprawdzenie, czy dokument nie jest dokumentem WZKK
      IF @Rodzaj IN (306071, 306072, 306061)
        BEGIN  -- jeśli posiada subelementy to nie może być anulowany
          IF EXISTS(SELECT TrS_TrSId FROM cdn.TraSElem  S
                           JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
                           JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
                           WHERE N.TrN_TrNId = @TrNId)
            BEGIN
              RAISERROR('##OPT34569##', 16, 1)--RAISERROR('Dokument jest korektą kosztu WZKK. ', 16, 1)
              ROLLBACK TRAN
              RETURN
            END
        END
      --ustawienie "nieaktywności" elementów
      UPDATE CDN.TraElem SET TrE_Aktywny = 0 WHERE TrE_TrNId = @TrNId
      -- Skasowanie rozliczen i płatności
      Execute CDN.KasujRozliczenia 1, @TrNId
      IF EXISTS (SELECT * FROM CDN.BnkZdarzenia JOIN CDN.BnkRozRelacje
                ON BZd_BZdId = BRR_ZDokId AND BRR_ZDokTyp = 1
                WHERE BZd_DokumentTyp In (1,101) AND BZd_DokumentId = @TrNId)
        BEGIN
          RAISERROR('##OPT34570##', 16, 1)--RAISERROR('Dokument posiada rozliczone płatności.', 16, 1)
          ROLLBACK TRAN
          RETURN
        END
      --kasowanie płatności do faktury
   SELECT @WhereParam = 'BZd_DokumentTyp In (1,101) AND BZd_DokumentId = ' + CONVERT(VARCHAR(15), @TrNId)
   if (@TypDokumentu != 345)
   EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001',
         @ObiektSubTyp = 'BZd_Kierunek',
         @ObiektID = 'BZd_BZdID',
         @ObiektNazwa = 'BZd_NumerPelny',
         @OperacjaTyp = 3, -- OptimaOperationType_Modyfikacja
         @Opis = '''''',
         @From = 'cdn.BnkZdarzenia',
         @Where = @WhereParam
      DELETE CDN.BnkZdarzenia WHERE BZd_DokumentTyp In (1,101) AND BZd_DokumentId = @TrNId
   --kasowanie relacji do dokumentów serwisowych  (WiNi)
      DELETE CDN.DokRelacje FROM CDN.DokRelacje WHERE DoR_DokumentTyp=@TypDokumentu AND DoR_DokumentId=@TrNId AND Dor_ParentTyp = 900
   --kasowanie zapisów do WZ
   if @Typdokumentu  = 306
  Execute CDN.KasujRozliczeniaWZ @TrNId
   --log z zapisem anulowania
   If Update (TrN_Bufor) and exists(select * from deleted where TrN_TrNID = @TrNId and TrN_Bufor = 0)
   BEGIN
  Declare @DokumentPodTyp INT
  SET @DokumentPodTyp = 0
  IF @Rodzaj in (302200,302202)
   SET @DokumentPodTyp = 1
  exec [CDN].[RejestrOperacjiDodaj] @Typdokumentu,@DokumentPodTyp, @TrNId, @NumerPelny, 107, ''
   END
  exec CDN.OpeDaneOperatora @OperatorID out, @OpeModKod OUT, @OpeModNazwisko OUT,@Log OUT
  --zmiana operatora na anulowanych
        UPDATE CDN.TraNag  SET
           TrN_OpeModId = @OperatorID,
   TrN_OpeModKod = @OpeModKod,
   TrN_OpeModNazwisko = @OpeModNazwisko,
           TrN_TS_Mod   = GETDATE()
         FROM CDN.TraNag A
         Where TrN_TrNId = @TrNId and @OperatorID > 0
      END -- Koniec anulowania
    -- Ustawianie unikalnego identyfikatora
    If IsNull(@ImportRowId,'') = ''
      Update CDN.TraNag Set TrN_ImportRowId = NewId()
      Where TrN_TrNId = @TrNId
    -- Aktualizacja wskaznika wyeksportowania w BnkZdarzenia
    If Update (TrN_TS_Export)
      If Exists (
        Select * From CDN.BnkZdarzenia
        Where BZd_DokumentTyp In (1,101) And BZd_DokumentId = @TrNId And Not (@TS_Export = BZd_TS_Export)
        )
        Update CDN.BnkZdarzenia Set BZd_TS_Export = @TS_Export
          Where BZd_DokumentTyp In (1,101) And BZd_DokumentId = @TrNId And Not (@TS_Export = BZd_TS_Export)
    -- Aktualizacja zapisow skojarzonych przy ksiegowaniu dokumentu
    If Update (TrN_DekId) And @DekId Is Not Null
      If Exists (Select * From deleted)
        Begin
          -- Faktura przeniesiona do Vat
          If @VaNId Is Not Null
            If Exists (Select * From CDN.VatNag Where VaN_VaNId = @VaNId And VaN_DekId Is Null)
              Update CDN.VatNag Set VaN_DekId = @DekId Where VaN_VaNId = @VaNId
          -- Faktura przekształcona z paragonu
          If  @Rodzaj = 302006
            If Exists (Select TrN_TrNId From Cdn.TraNagRelacje
                       join Cdn.TraNag on TrN_TrNId = TrR_FAId
                       Where TrR_TrNId = @TrNId and TrR_FaTyp = 302 and TrN_DekId Is Null)
              Update CDN.TraNag Set TrN_DekId = @DekId Where TrN_TrNId in (Select TrN_TrNId From Cdn.TraNagRelacje
                       join Cdn.TraNag on TrN_TrNId = TrR_FAId
                       Where TrR_TrNId = @TrNId and TrR_FaTyp = 302 and TrN_DekId Is Null)
/*          If @FaId Is Not Null And @Rodzaj = 302006
            If Exists (Select * From CDN.TraNag Where TrN_TrNId = @FaId And TrN_DekId Is Null)
              Update CDN.TraNag Set TrN_DekId = @DekId Where TrN_TrNId = @FaId*/
        End
      -- wyliczenie kolejnego numeru TrN_Anulowany dla dokumentów anulowanych - dla pozostałych 0
      UPDATE cdn.TraNag SET TrN_Anulowany =
       CASE @Bufor
       WHEN -1 THEN
                ( SELECT ISNULL(MAX(TrN_Anulowany), -2147483648 ) + 1 FROM cdn.TraNag WHERE TrN_NumerPelny = @NumerPelny AND TrN_Bufor = -1 AND TrN_TrNId <> @TrNId)
       ELSE  0  END
      WHERE TrN_TrNID = @TrNId
-- ZG 9.0 w związku z modyfikowaniem pieczątki (modyfikujących) przy księgowaniu do rejestrów VAT lub na konta.
      -- nie zmieniamy parametrów modyfikacji, jeśli jest to księgowanie do dekretów lub na konta
      IF UPDATE(TrN_VANId) OR UPDATE(TrN_DekId)
        UPDATE CDN.TraNag  SET
           TrN_OpeModId = D.TrN_OpeModId,
     TrN_OpeModKod = D.TrN_OpeModKod,
     TrN_OpeModNazwisko = D.TrN_OpeModNazwisko,
           TrN_StaModId = D.TrN_StaModId,
           TrN_TS_Mod   = D.TrN_TS_Mod
        FROM CDN.TraNag A
        JOIN ( SELECT
                 TrN_TrNId    = TrN_TrNId,
                 TrN_OpeModId = TrN_OpeModId,
     TrN_OpeModKod = TrN_OpeModKod,
     TrN_OpeModNazwisko = TrN_OpeModNazwisko,
                 TrN_StaModId = TrN_StaModId,
                 TrN_TS_Mod   = TrN_TS_Mod
               FROM deleted
               WHERE TrN_TrNId = @TrNId
              ) AS D ON D.TrN_TrNId = A.TrN_TrNId
        WHERE A.TrN_TrNId = @TrNId
   --sprawdzenie, czy dokument nie jest przed datą cięcia
      Set @DOBZM = Null
      select @DOBZM = convert(datetime,Fir_Wartosc,120) from cdn.Firma where Fir_Numer=1938
   if not exists (SELECT * FROM deleted WHERE TrN_TrNId = @TrNId and TrN_Bufor = 0)
      If @DOBZM Is Not Null And @DataOpe <= @DOBZM And @Rodzaj Not In ( 301100, 302100, 305100)
        BEGIN
          --set @KomunikatErr = 'Data dokumentu nie może być wcześniejsza niż: '+ convert(varchar(10),@DOBZM +1,120) + '. Na bazie została wykonana funkcja usuwania dokumentów. Zapisz dokument z datą poźniejszą.'
    set @KomunikatErr = '##OPT34571##%%s1%%=' + convert(varchar(10),@DOBZM +1,120)+ '##'--'Data dokumentu nie może być wcześniejsza niż: '+ convert(varchar(10),@DOBZM +1,120) + '. Na bazie została wykonana funkcja usuwania dokumentów. Zapisz dokument z datą poźniejszą.'
          RAISERROR(@KomunikatErr, 16, 1)
          ROLLBACK TRAN
          RETURN
        END
 End
Close Dodane
Deallocate Dodane
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TraNag_DeleteHandler
  ON CDN.TraNag
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS
       ( SELECT * FROM CDN.CRMDokumenty, deleted
          WHERE
                deleted.TrN_TrNID = CDN.CRMDokumenty.CRD_DokumentId
       AND (CDN.CRMDokumenty.CRD_TypDokumentu=1 AND CDN.CRMDokumenty.CRD_RodzajDokumentu=1)
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=CRMDokumenty##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.TrN_TrNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=1)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.TrN_TrNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=1)
    IF EXISTS(
   SELECT * FROM CDN.Zaliczki INNER JOIN deleted
   ON deleted.TrN_TrNID = CDN.Zaliczki.Zal_DokumentID AND (CDN.Zaliczki.Zal_DokumentTyp=1)
  )
  DELETE CDN.Zaliczki
  FROM CDN.Zaliczki, deleted
  WHERE deleted.TrN_TrNID = CDN.Zaliczki.Zal_DokumentID AND (CDN.Zaliczki.Zal_DokumentTyp=1)
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted
   ON deleted.TrN_TrNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp In (1,101))
  )
  begin
  --log
  declare
  @OperatorID  int,
  @OpeModKod   varchar(20),
  @OpeModNazwisko nvarchar(50),
  @Log int
  exec CDN.OpeDaneOperatora @OperatorID out, @OpeModKod OUT, @OpeModNazwisko OUT, @Log OUT
  if @Log <>0
  BEGIN
   INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
    select  1001,BZd_Kierunek,BZd_BZdID,BZd_NumerPelny, GETDATE(),case when @OpeModNazwisko = '' then @OpeModKod else @OpeModNazwisko end ,3,'' FROM CDN.BnkZdarzenia, deleted
   WHERE deleted.TrN_TrNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp In (1,101))
  END
  DELETE CDN.BnkZdarzenia
  FROM CDN.BnkZdarzenia, deleted
  WHERE deleted.TrN_TrNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp In (1,101))
  end
    IF EXISTS(SELECT D.TrN_PreDekID FROM Deleted D WHERE D.TrN_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.TrN_PreDekId = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TraNag_Update_Trigger
 ON CDN.TraNag
 FOR UPDATE
AS
 SET NOCOUNT ON
  if exists(select I.TrN_PreDekID from Inserted I join Deleted D On (I.Trn_TrnId = D.TrN_TrNId)
    where I.TrN_Bufor = -1 and I.TrN_Bufor <> D.TrN_Bufor)
  BEGIN
  -- Usuwanie wymiarów analitycznych
    DECLARE @WADokumentTypZakup int = 0;
    DECLARE @WADokumentTypSprzedaz int = 0;
    select @WADokumentTypZakup=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Faktury zakupu';
    select @WADokumentTypSprzedaz=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Faktury sprzedaży';
    if exists(select * from CDN.WymiaryWartosci where WyW_DokumentTyp in (@WADokumentTypZakup, @WADokumentTypSprzedaz) and WyW_DokumentId in (select Inserted.TrN_TrNId from Inserted where Inserted.TrN_Bufor = -1))
                delete from CDN.WymiaryWartosci where WyW_DokumentTyp in (@WADokumentTypZakup, @WADokumentTypSprzedaz)
                and WyW_DokumentId in (select Inserted.TrN_TrNId from Inserted where Inserted.TrN_Bufor = -1)
    if exists(select I.TrN_PreDekID from Inserted I where I.TrN_PreDekID is not null)
      delete from CDN.DekretyNag  where DeN_DeNId in (
        select I.TrN_PreDekID from Inserted I join Deleted D On (I.Trn_TrnId = D.TrN_TrNId)
        where I.TrN_Bufor = -1 and I.TrN_Bufor <> D.TrN_Bufor )
  END
  ELSE
    if (Update (TrN_Fiskalna) AND UPDATE(TrN_FiskalnaErr))
    if not exists(
        select * from CDN.dokKodyJPKV7
        join cdn.KodyJPKV7 on KV7_KV7Id = DKV7_KV7Id
        join Inserted on trn_trnid = DKV7_ParentID and DKV7_ParentTyp = 1 and KV7_Kod = 'FP'
 )
 and
    not exists(
        select * from CDN.dokKodyJPKV7
        join cdn.KodyJPKV7 on KV7_KV7Id = DKV7_KV7Id
        join Inserted on trn_trnid = DKV7_ParentID and DKV7_ParentTyp = 1 and KV7_Rodzaj =3
  )
        INSERT INTO [CDN].[DokKodyJPKV7]
           ([DKV7_ParentTyp]
           ,[DKV7_ParentID]
           ,[DKV7_KV7ID]
     ,[DKV7_Status])
        select 1,TrN_trNID,KV7_KV7ID, 3 from Inserted
        join cdn.KodyJPKV7 on KV7_Kod = 'FP'
        where TrN_Fiskalna = 1 and isnull(TrN_FiskalnaErr,0) = 0 and TrN_TypDokumentu = 302
 SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TraNag_Delete_Trigger
  ON CDN.TraNag
  FOR DELETE
AS
  SET NOCOUNT ON
  Set ArithAbort On
--Sprawdzanie, czy dokument może byc skasowany (jest w buforze)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.TrN_Bufor <> 1 AND deleted.TrN_Rodzaj <> 310005 )
        BEGIN
          RAISERROR('##OPT29447##', 16, 1)--RAISERROR('Nie wolno kasować dokumentów nie będących w buforze. ', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    IF EXISTS (SELECT * FROM deleted WHERE deleted.TrN_Rodzaj=310005 AND deleted.TrN_VaNId Is Not Null)
        BEGIN
          RAISERROR('##OPT34572##', 16, 1)--RAISERROR('Nie wolno kasować BZM przeniesionego do spisu z natury. ', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
-- Sprawdzenie, czy zapisy nie są zaksięgowane na konta
  IF EXISTS (SELECT * FROM deleted
             WHERE TrN_DekId IS NOT NULL)
    BEGIN
      RAISERROR('##OPT32370##', 16, 1)--RAISERROR('Nie można kasować zapisów zaksięgowanych (DekretyNag)', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane do VatNag
  IF EXISTS (SELECT * FROM deleted
             WHERE TrN_VaNId IS NOT NULL AND TrN_Rodzaj<>310000 AND TrN_Bufor=1)
    BEGIN
      RAISERROR('##OPT32373##', 16, 1)--RAISERROR('Nie można kasować zapisów zaksięgowanych (VatNag)', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Skasowanie RWS dla PWP
  IF EXISTS (SELECT * FROM deleted WHERE TrN_Bufor = 1 AND TrN_TypDokumentu = 317)
  BEGIN
  declare
  @OperatorID  int,
  @OpeModKod   varchar(20),
  @OpeModNazwisko nvarchar(50),
  @Log int
  exec CDN.OpeDaneOperatora @OperatorID out, @OpeModKod OUT, @OpeModNazwisko OUT, @Log OUT
  if @Log <>0
  BEGIN
   INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
   select  TrN_TypDokumentu,0,TrN_TrNID,TrN_NumerPelny, GETDATE(),case when @OpeModNazwisko = '' then @OpeModKod else @OpeModNazwisko end ,3,'' from  CDN.TraNag
   WHERE CDN.TraNag.TrN_TypDokumentu=318 AND TrN_TrNId In
   (SELECT TrR_FAId FROM deleted
   JOIN CDN.TraNagRelacje  ON deleted.TrN_TrNId = TrR_TrNId
   WHERE deleted.TrN_Bufor = 1 AND deleted.TrN_TypDokumentu = 317)
  END
  DELETE FROM CDN.TraNag
  WHERE CDN.TraNag.TrN_TypDokumentu=318 AND TrN_TrNId In
  (SELECT TrR_FAId FROM deleted
  JOIN CDN.TraNagRelacje  ON deleted.TrN_TrNId = TrR_TrNId
  WHERE deleted.TrN_Bufor = 1 AND deleted.TrN_TypDokumentu = 317)
  END
  -- DELETE FROM CDN.TraNag JOIN CDN.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE CDN.TraNag.TrN_TypDokumentu=318 AND TrR_FaId In (SELECT TrN_TrNId FROM deleted WHERE deleted.TrN_Bufor = 1 AND deleted.TrN_TypDokumentu = 317)
-- Skasowanie relacji do dokumentów serwisowych  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=deleted.TrN_TypDokumentu AND DoR_DokumentId=deleted.TrN_TrNId
-- skasowanie kodów JPK_V7
Delete From CDN.DokKodyJPKV7 Where
 DKV7_ParentTyp = 1
 And DKV7_ParentID In (Select TrN_TrNId From deleted)
-- Skasowanie relacji do dokumentów HaMag  (RT)
/* (SO) wykomentowalem, relacje sa kasowane w procedurach Anulowania lub Rozpinania dokumentow
  DELETE CDN.TraNagRelacje
  FROM CDN.TraNagRelacje JOIN deleted ON (Trr_TrNTyp=deleted.TrN_TypDokumentu AND TrR_TrNId=deleted.TrN_TrNId)
  DELETE CDN.TraNagRelacje
  FROM CDN.TraNagRelacje JOIN deleted ON (Trr_FaTyp=deleted.TrN_TypDokumentu AND TrR_FaId=deleted.TrN_TrNId)
*/
-- Wykonanie akcji dla kasowania Bilansu Zamkniecia Magazynu oraz rozpinania rozliczen
      DECLARE @TrN_TrNId INT, @TrN_DataOpe DATETIME
      DECLARE @TrN_Rodzaj Int
      DECLARE Kasowane CURSOR LOCAL FAST_FORWARD FOR
        SELECT deleted.TrN_TrNId, deleted.TrN_DataOpe, deleted.TrN_Rodzaj
          FROM deleted
          ORDER BY deleted.TrN_DataOpe DESC
          OPEN Kasowane
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Kasowane INTO @TrN_TrNId, @TrN_DataOpe, @TrN_Rodzaj
              IF @@FETCH_STATUS <> 0 BREAK
              Execute CDN.KasujRozliczenia 1, @TrN_TrNId
              If @TrN_Rodzaj = 310005
                EXECUTE CDN.NaliczajKWS 2, @TrN_DataOpe, 0, @TrN_DataOpe
     IF  @TrN_Rodzaj IN ( 307010, 302008, 305008, 306008,  301011 , 306004, 307004,302009, 306010,304000,304008,312008,312100)
     and exists (select trr_trrid from cdn.TraNagRelacje where trr_trnid = @TrN_TrNId and trr_fatyp in (308,309))
       EXECUTE CDN.UstawStatusRezerwacji_New 0,@TrN_TrNId
            END
          CLOSE Kasowane
      DEALLOCATE Kasowane
 -- Usuwanie wymiarów analitycznych
 if exists(select * from CDN.WymiaryWartosci where WyW_DokumentTyp in (select id from CDN.ListaDokumentowWymiarowanych() where konfiguracja in ('Faktury', 'Handel')) and WyW_DokumentId in (select deleted.TrN_TrNId from deleted))
  delete from CDN.WymiaryWartosci where WyW_DokumentTyp in (select id from CDN.ListaDokumentowWymiarowanych() where konfiguracja in ('Faktury', 'Handel'))
  and WyW_DokumentId in (select deleted.TrN_TrNId from deleted)
--kurierzy
 update cdn.SenditZleceniePrzesylki set SZL_FaId= 0 where SZL_FaId in(select deleted.TrN_TrNId from deleted)
  Set NoCount Off

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[TraNag_Delete_Trigger]', @order = N'first', @stmttype = N'delete';

