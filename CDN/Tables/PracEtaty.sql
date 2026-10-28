CREATE TABLE [CDN].[PracEtaty] (
    [PRE_PreId]                       INT             IDENTITY (1, 1) NOT NULL,
    [PRE_ZrgId]                       INT             NULL,
    [PRE_PraId]                       INT             NOT NULL,
    [PRE_PodmiotTyp]                  SMALLINT        CONSTRAINT [DF_PRE_PodmiotTyp] DEFAULT ((3)) NULL,
    [PRE_DzlId]                       INT             CONSTRAINT [DF_PRE_DzlId] DEFAULT ((3)) NULL,
    [PRE_CntId]                       INT             CONSTRAINT [DF_PRE_CntId] DEFAULT ((3)) NULL,
    [PRE_KalId]                       INT             NULL,
    [PRE_ETATwpId]                    INT             NULL,
    [PRE_UBZTyuId]                    INT             NOT NULL,
    [PRE_TypPracownika]               TINYINT         NOT NULL,
    [PRE_WlascicielId]                INT             NULL,
    [PRE_BnaId]                       INT             NULL,
    [PRE_FplId]                       INT             NULL,
    [PRE_Kod]                         VARCHAR (20)    NOT NULL,
    [PRE_Nazwisko]                    NVARCHAR (40)   NOT NULL,
    [PRE_Imie1]                       NVARCHAR (30)   NOT NULL,
    [PRE_Pesel]                       NVARCHAR (11)   NOT NULL,
    [PRE_ETARodzajZatrudnienia]       INT             NOT NULL,
    [PRE_DataOd]                      DATETIME        NOT NULL,
    [PRE_DataDo]                      DATETIME        NOT NULL,
    [PRE_ZatrudnionyOd]               DATETIME        NULL,
    [PRE_ZatrudnionyDo]               DATETIME        NULL,
    [PRE_RachunekNr]                  NVARCHAR (51)   NOT NULL,
    [PRE_IBAN]                        SMALLINT        NOT NULL,
    [PRE_ZestCzasuPracy]              TINYINT         NOT NULL,
    [PRE_WypNaKonto]                  TINYINT         NOT NULL,
    [PRE_NrwAktach]                   NVARCHAR (19)   NOT NULL,
    [PRE_Filtr]                       TINYINT         NOT NULL,
    [PRE_NazwRodowe]                  NVARCHAR (40)   NOT NULL,
    [PRE_Imie2]                       NVARCHAR (30)   NOT NULL,
    [PRE_ImieOjca]                    NVARCHAR (30)   NOT NULL,
    [PRE_ImieMatki]                   NVARCHAR (30)   NOT NULL,
    [PRE_NazwRodoweM]                 NVARCHAR (40)   NOT NULL,
    [PRE_DataUr]                      DATETIME        NULL,
    [PRE_MiejsceUr]                   NVARCHAR (40)   NOT NULL,
    [PRE_Obywatelstwo]                NVARCHAR (30)   NOT NULL,
    [PRE_Plec]                        NVARCHAR (2)    NOT NULL,
    [PRE_StanCywilny]                 NVARCHAR (30)   NOT NULL,
    [PRE_MLDKraj]                     NVARCHAR (40)   NOT NULL,
    [PRE_MLDWojewodztwo]              NVARCHAR (40)   NOT NULL,
    [PRE_MLDPowiat]                   NVARCHAR (40)   NOT NULL,
    [PRE_MLDGmina]                    NVARCHAR (40)   NOT NULL,
    [PRE_MLDUlica]                    NVARCHAR (40)   NOT NULL,
    [PRE_MLDNrDomu]                   NVARCHAR (10)   NOT NULL,
    [PRE_MLDNrLokalu]                 NVARCHAR (10)   NOT NULL,
    [PRE_MLDMiasto]                   NVARCHAR (40)   NOT NULL,
    [PRE_MLDKodPocztowy]              VARCHAR (10)    NOT NULL,
    [PRE_MLDPoczta]                   NVARCHAR (40)   NOT NULL,
    [PRE_MLDAdres2]                   NVARCHAR (40)   NOT NULL,
    [PRE_MLDGminaKod]                 INT             NOT NULL,
    [PRE_HDKTelefon1]                 VARCHAR (20)    NOT NULL,
    [PRE_HDKTelefon2]                 VARCHAR (20)    NOT NULL,
    [PRE_NipKraj]                     VARCHAR (2)     NOT NULL,
    [PRE_NipE]                        VARCHAR (13)    NOT NULL,
    [PRE_DowOsobisty]                 NVARCHAR (12)   NOT NULL,
    [PRE_DowGdzie]                    NVARCHAR (30)   NOT NULL,
    [PRE_DowKiedy]                    DATETIME        NULL,
    [PRE_DowWaznyDo]                  DATETIME        NULL,
    [PRE_DowKto]                      NVARCHAR (40)   NOT NULL,
    [PRE_Paszport]                    NVARCHAR (9)    NOT NULL,
    [PRE_KORKraj]                     NVARCHAR (40)   NOT NULL,
    [PRE_KORWojewodztwo]              NVARCHAR (40)   NOT NULL,
    [PRE_KORPowiat]                   NVARCHAR (40)   NOT NULL,
    [PRE_KORGmina]                    NVARCHAR (40)   NOT NULL,
    [PRE_KORUlica]                    NVARCHAR (40)   NOT NULL,
    [PRE_KORNrDomu]                   NVARCHAR (10)   NOT NULL,
    [PRE_KORNrLokalu]                 NVARCHAR (10)   NOT NULL,
    [PRE_KORMiasto]                   NVARCHAR (40)   NOT NULL,
    [PRE_KORKodPocztowy]              VARCHAR (10)    NOT NULL,
    [PRE_KORPoczta]                   NVARCHAR (40)   NOT NULL,
    [PRE_KORAdres2]                   NVARCHAR (40)   NOT NULL,
    [PRE_ZAMKraj]                     NVARCHAR (40)   NOT NULL,
    [PRE_ZAMWojewodztwo]              NVARCHAR (40)   NOT NULL,
    [PRE_ZAMPowiat]                   NVARCHAR (40)   NOT NULL,
    [PRE_ZAMGmina]                    NVARCHAR (40)   NOT NULL,
    [PRE_ZAMUlica]                    NVARCHAR (40)   NOT NULL,
    [PRE_ZAMNrDomu]                   NVARCHAR (10)   NOT NULL,
    [PRE_ZAMNrLokalu]                 NVARCHAR (10)   NOT NULL,
    [PRE_ZAMMiasto]                   NVARCHAR (40)   NOT NULL,
    [PRE_ZAMKodPocztowy]              VARCHAR (10)    NOT NULL,
    [PRE_ZAMPoczta]                   NVARCHAR (40)   NOT NULL,
    [PRE_ZAMAdres2]                   NVARCHAR (40)   NOT NULL,
    [PRE_HDKFax]                      VARCHAR (20)    NOT NULL,
    [PRE_HDKTeleks]                   NVARCHAR (20)   NOT NULL,
    [PRE_HDKSkrytkaPoczt]             NVARCHAR (20)   NOT NULL,
    [PRE_HDKWypOsoba]                 NVARCHAR (50)   NOT NULL,
    [PRE_HDKWypAdres]                 NVARCHAR (60)   NOT NULL,
    [PRE_HDKWypTelefon]               VARCHAR (20)    NOT NULL,
    [PRE_AdresCentrum]                NVARCHAR (512)  CONSTRAINT [DF_PRE_AdresCentrum] DEFAULT ('') NOT NULL,
    [PRE_PODMnoznikKoszty]            DECIMAL (15, 2) NOT NULL,
    [PRE_PODMnoznikUlga]              DECIMAL (15, 2) NOT NULL,
    [PRE_PODKosztyTytul]              INT             NOT NULL,
    [PRE_PODProcKosztyUzysk]          DECIMAL (15, 2) NOT NULL,
    [PRE_PODZaniechPodat]             INT             NOT NULL,
    [PRE_PODUrzSkarbId]               INT             NULL,
    [PRE_RefundacjaKwota]             DECIMAL (15, 2) NULL,
    [PRE_RefundOd]                    DATETIME        NULL,
    [PRE_RefundDo]                    DATETIME        NULL,
    [PRE_HDKWojStosunek]              NVARCHAR (20)   NOT NULL,
    [PRE_HDKWojStopien]               NVARCHAR (60)   NOT NULL,
    [PRE_HDKWojSpecjal]               NVARCHAR (20)   NOT NULL,
    [PRE_HDKWojWKU]                   NVARCHAR (20)   NOT NULL,
    [PRE_HDKWojNrKsiaz]               NVARCHAR (20)   NOT NULL,
    [PRE_HDKWojPrzydzial]             NVARCHAR (20)   NOT NULL,
    [PRE_ETAStosunekPracy]            INT             NOT NULL,
    [PRE_ETADataZawarcia]             DATETIME        NULL,
    [PRE_ETARodzajUmowy]              NVARCHAR (40)   NOT NULL,
    [PRE_ETARozwiazUmowy]             INT             NOT NULL,
    [PRE_ETAMiejsce]                  NVARCHAR (30)   NOT NULL,
    [PRE_ETAEtatL]                    SMALLINT        NOT NULL,
    [PRE_ETAEtatM]                    SMALLINT        NOT NULL,
    [PRE_ETAMinimalna]                TINYINT         NOT NULL,
    [PRE_ETADataRozpocz]              DATETIME        NULL,
    [PRE_ETAStawka]                   DECIMAL (15, 2) NOT NULL,
    [PRE_ETAStawkaGodz]               TINYINT         NOT NULL,
    [PRE_ETAStawkaL]                  TINYINT         NOT NULL,
    [PRE_ETAStawkaM]                  TINYINT         NOT NULL,
    [PRE_ETAWymiar]                   TINYINT         NOT NULL,
    [PRE_ETAStandard]                 TINYINT         NOT NULL,
    [PRE_ETAGwarantProcMin]           DECIMAL (15, 2) NOT NULL,
    [PRE_KartaPobytu]                 NVARCHAR (1)    NOT NULL,
    [PRE_StNiepelnosp]                INT             NOT NULL,
    [PRE_NiepelnospOd]                DATETIME        NULL,
    [PRE_NiepelnospDo]                DATETIME        NULL,
    [PRE_KodPokrew]                   INT             NOT NULL,
    [PRE_WspolGosp]                   TINYINT         NOT NULL,
    [PRE_KodNiezdol]                  INT             CONSTRAINT [DF_PRE_KodNiezdol] DEFAULT ((1)) NOT NULL,
    [PRE_NiezdolOd]                   DATETIME        NULL,
    [PRE_NiezdolDo]                   DATETIME        NULL,
    [PRE_KodStGorniczego]             INT             NOT NULL,
    [PRE_GorniczeOd]                  DATETIME        NULL,
    [PRE_GorniczeDo]                  DATETIME        NULL,
    [PRE_KodWyksztal]                 INT             NOT NULL,
    [PRE_WarSzczegolne]               NVARCHAR (9)    NOT NULL,
    [PRE_WarSzczegolneOd]             DATETIME        NULL,
    [PRE_WarSzczegolneDo]             DATETIME        NULL,
    [PRE_KodKasyChorych]              NVARCHAR (3)    NOT NULL,
    [PRE_KasaChData]                  DATETIME        NULL,
    [PRE_UBZZusOd]                    DATETIME        NULL,
    [PRE_UBZJestEmerytal]             TINYINT         NOT NULL,
    [PRE_UBZJestRentowe]              TINYINT         NOT NULL,
    [PRE_UBZJestChorobowe]            TINYINT         NOT NULL,
    [PRE_UBZJestWypad]                TINYINT         NOT NULL,
    [PRE_UBZZdrowOd]                  DATETIME        NULL,
    [PRE_UBZEmerOd]                   DATETIME        NULL,
    [PRE_UBZRentOd]                   DATETIME        NULL,
    [PRE_UBZChorOd]                   DATETIME        NULL,
    [PRE_UBZZdrowDobrOd]              DATETIME        NULL,
    [PRE_UBZZdrowKwotaPierwSkl]       DECIMAL (15, 2) NOT NULL,
    [PRE_UBZEmerDo]                   DATETIME        NULL,
    [PRE_UBZRentDo]                   DATETIME        NULL,
    [PRE_UBZChorDo]                   DATETIME        NULL,
    [PRE_UBZWypadDo]                  DATETIME        NULL,
    [PRE_UBZZdrowDo]                  DATETIME        NULL,
    [PRE_UBZEmerKod]                  INT             NULL,
    [PRE_UBZRentKod]                  INT             NULL,
    [PRE_UBZChorKod]                  INT             NULL,
    [PRE_UBZWypadKod]                 INT             NULL,
    [PRE_UBZZdrowKod]                 INT             NULL,
    [PRE_UBZJestDobrEmerytal]         TINYINT         NOT NULL,
    [PRE_UBZJestDobrRentowe]          TINYINT         NOT NULL,
    [PRE_UBZJestDobrChorobowe]        TINYINT         NOT NULL,
    [PRE_UBZJestDobrZdrow]            TINYINT         NOT NULL,
    [PRE_PrzekroczRok]                INT             NULL,
    [PRE_PrzekroczMiesiac]            TINYINT         NULL,
    [PRE_PrzekroczKwota]              DECIMAL (15, 2) NULL,
    [PRE_PrzekroczInformacja]         TINYINT         NULL,
    [PRE_Przekroczenie]               TINYINT         NULL,
    [PRE_PrawoER]                     INT             NOT NULL,
    [PRE_HDKUwagi]                    NVARCHAR (1024) NOT NULL,
    [PRE_HDKPrawoJazdy]               TINYINT         NOT NULL,
    [PRE_HDKPrawoJazdyKat]            NVARCHAR (30)   NOT NULL,
    [PRE_HDKEmail]                    NVARCHAR (127)  NOT NULL,
    [PRE_HDKURL]                      VARCHAR (255)   NOT NULL,
    [PRE_MstIdMLD]                    INT             NULL,
    [PRE_MstIdZAM]                    INT             NULL,
    [PRE_MstIdKOR]                    INT             NULL,
    [PRE_MstPocztaMLD]                INT             NULL,
    [PRE_MstPocztaZAM]                INT             NULL,
    [PRE_MstPocztaKOR]                INT             NULL,
    [PRE_MstMiejsceUr]                INT             NULL,
    [PRE_ABSData]                     DATETIME        NULL,
    [PRE_ABSChor35]                   INT             NOT NULL,
    [PRE_ABSChor90]                   INT             NOT NULL,
    [PRE_ABSChor6M]                   INT             NOT NULL,
    [PRE_ABSOP60]                     INT             NOT NULL,
    [PRE_ABSOP14]                     INT             NOT NULL,
    [PRE_ABSUrlMiesKorekta]           TINYINT         NOT NULL,
    [PRE_ABSUrlMies]                  INT             NOT NULL,
    [PRE_ABSChorMiesKorekta]          TINYINT         NOT NULL,
    [PRE_ABSPrawoZasChorOd]           DATETIME        NULL,
    [PRE_ABSFinansowanePracodawcaOd]  DATETIME        NULL,
    [PRE_IndywDRA]                    TINYINT         NOT NULL,
    [PRE_KatId]                       INT             NULL,
    [PRE_KategoriaOpis]               VARCHAR (50)    NOT NULL,
    [PRE_KontoKsiegowe]               NVARCHAR (50)   NOT NULL,
    [PRE_WaznoscBadanOkres]           DATETIME        NULL,
    [PRE_LimitNadgodzin]              DATETIME        NULL,
    [PRE_IndywLimitNadgodzin]         TINYINT         NOT NULL,
    [PRE_KodWyksztPFRON]              INT             NOT NULL,
    [PRE_HDKWiekEmerData]             DATETIME        NULL,
    [PRE_AdresDzialu]                 NVARCHAR (512)  NOT NULL,
    [PRE_Opis]                        NVARCHAR (128)  NOT NULL,
    [PRE_ETANormaDobowa]              DATETIME        NOT NULL,
    [PRE_HDKRodzajMiejsc]             TINYINT         NOT NULL,
    [PRE_UBZOgraniczSklZdrow]         TINYINT         NOT NULL,
    [PRE_ABSLimitLiczbaDni]           INT             NOT NULL,
    [PRE_ABSProcWynChorFlaga]         TINYINT         NOT NULL,
    [PRE_ABSProcWynChor]              DECIMAL (15, 2) NOT NULL,
    [PRE_ETAPodstZdrowMnoznik]        DECIMAL (15, 2) NOT NULL,
    [PRE_ETAIndywProcWypad]           TINYINT         NOT NULL,
    [PRE_ETAIndywProcWypadProcent]    DECIMAL (15, 2) NOT NULL,
    [PRE_HDKGUSGlowneMiejscePracy]    TINYINT         NOT NULL,
    [PRE_HDKGUSPierwszaPraca]         TINYINT         NOT NULL,
    [PRE_HDKGUSPoraNocna]             TINYINT         NOT NULL,
    [PRE_HDKGUSPracSezonowy]          TINYINT         NOT NULL,
    [PRE_NieRozliczac]                TINYINT         NOT NULL,
    [PRE_DabId]                       INT             NULL,
    [PRE_NieNaliczacFP]               TINYINT         CONSTRAINT [DF_PRE_NieNaliczacFP] DEFAULT ((0)) NOT NULL,
    [PRE_NieNaliczacFGSP]             TINYINT         CONSTRAINT [DF_PRE_NieNaliczacFGSP] DEFAULT ((0)) NOT NULL,
    [PRE_PelneDaneAdresowePFRON]      TINYINT         NOT NULL,
    [PRE_PomocPublicznaPFRON]         TINYINT         NOT NULL,
    [PRE_WzrostZatrudnieniaPFRON]     TINYINT         NOT NULL,
    [PRE_ZatrudRozwUmowyPFRON]        TINYINT         NOT NULL,
    [PRE_ABSFinansowanePracodawca]    TINYINT         CONSTRAINT [DF_PRE_ABSFinansowanePracodawca] DEFAULT ((0)) NOT NULL,
    [PRE_ABSFinansowanePracodawcaDni] INT             CONSTRAINT [DF_PRE_ABSFinansowanePracodawcaDni] DEFAULT ((0)) NOT NULL,
    [PRE_KodFEP]                      INT             CONSTRAINT [DF_PRE_KodFEP] DEFAULT ((0)) NOT NULL,
    [PRE_FEPOd]                       DATETIME        NULL,
    [PRE_FEPDo]                       DATETIME        NULL,
    [PRE_FPOd]                        DATETIME        NULL,
    [PRE_FPDo]                        DATETIME        NULL,
    [PRE_FGSPOd]                      DATETIME        NULL,
    [PRE_FGSPDo]                      DATETIME        NULL,
    [PRE_Oddelegowany]                TINYINT         CONSTRAINT [DF_PRE_Oddelegowany] DEFAULT ((0)) NOT NULL,
    [PRE_OddelegowanyDieta]           DECIMAL (15, 2) CONSTRAINT [DF_PRE_OddelegowanyDieta] DEFAULT ((0)) NOT NULL,
    [PRE_OddelegowanyWaluta]          VARCHAR (3)     CONSTRAINT [DF_PRE_OddelegowanyWaluta] DEFAULT ('') NOT NULL,
    [PRE_OddelegowanyZUS]             TINYINT         NOT NULL,
    [PRE_OddelegowanyFIS]             TINYINT         NOT NULL,
    [PRE_WychPodstEmerRentOd]         DATETIME        NULL,
    [PRE_WychPodstEmerRentMax]        DECIMAL (15, 2) NOT NULL,
    [PRE_RodzajDokumentu]             TINYINT         NOT NULL,
    [PRE_PODNieLiczKoszty50]          TINYINT         NOT NULL,
    [PRE_ETADkmIdStanowisko]          INT             NULL,
    [PRE_ETADkmIdFunkcja]             INT             NULL,
    [PRE_DkmIdKodZawodu]              INT             NULL,
    [PRE_ETADkmIdWypowPowod]          INT             NULL,
    [PRE_DkmIdPracodawca]             INT             NULL,
    [PRE_Tymczasowy]                  TINYINT         CONSTRAINT [DF_PRE_Tymczasowy] DEFAULT ((0)) NOT NULL,
    [PRE_ZastepowanyId]               INT             NULL,
    [PRE_Zastepowany]                 NVARCHAR (128)  CONSTRAINT [DF_PRE_Zastepowany] DEFAULT ('') NOT NULL,
    [PRE_ZastepowanyLista]            TINYINT         CONSTRAINT [DF_PRE_ZastepowanyLista] DEFAULT ((0)) NOT NULL,
    [PRE_ABSPierwszyLimit]            TINYINT         CONSTRAINT [DF_PRE_ABSPierwszyLimit] DEFAULT ((0)) NOT NULL,
    [PRE_Przelozony]                  NVARCHAR (128)  CONSTRAINT [DF_PRE_Przelozony] DEFAULT ('') NOT NULL,
    [PRE_ZamZamiastMld]               TINYINT         CONSTRAINT [DF_PRE_ZamZamiastMld] DEFAULT ((0)) NOT NULL,
    [PRE_TelefonSms]                  VARCHAR (20)    CONSTRAINT [DF_PRE_TelefonSms] DEFAULT ('') NOT NULL,
    [PRE_FlotaPrawa]                  INT             CONSTRAINT [DF_PRE_FlotaPrawa] DEFAULT ((0)) NOT NULL,
    [PRE_FlotaOperator]               INT             NULL,
    [PRE_OpeZalId]                    INT             NULL,
    [PRE_StaZalId]                    INT             NULL,
    [PRE_TS_Zal]                      DATETIME        NOT NULL,
    [PRE_OpeModId]                    INT             NULL,
    [PRE_StaModId]                    INT             NULL,
    [PRE_TS_Mod]                      DATETIME        NOT NULL,
    [PRE_MLDKodKraju]                 NVARCHAR (2)    CONSTRAINT [DF_PRE_MLDKodKraju] DEFAULT ('') NOT NULL,
    [PRE_ZAMKodKraju]                 NVARCHAR (2)    CONSTRAINT [DF_PRE_ZAMKodKraju] DEFAULT ('') NOT NULL,
    [PRE_KORKodKraju]                 NVARCHAR (2)    CONSTRAINT [DF_PRE_KORKodKraju] DEFAULT ('') NOT NULL,
    [PRE_PODNierezydent]              TINYINT         CONSTRAINT [DF_PRE_PODNierezydent] DEFAULT ((0)) NOT NULL,
    [PRE_PODNipZagranicznyRodzaj]     INT             CONSTRAINT [DF_PRE_PODNipZagranicznyRodzaj] DEFAULT ((0)) NOT NULL,
    [PRE_PODNipZagraniczny]           NVARCHAR (50)   CONSTRAINT [DF_PRE_PODNipZagraniczny] DEFAULT ('') NOT NULL,
    [PRE_KontoKsiegowe2]              NVARCHAR (50)   CONSTRAINT [DF_PRE_KontoKsiegowe2] DEFAULT ('') NOT NULL,
    [PRE_PRMPracaRodzic]              TINYINT         CONSTRAINT [DF_PRE_PRMPracaRodzic] DEFAULT ((0)) NOT NULL,
    [PRE_PRMStawka]                   DECIMAL (15, 2) CONSTRAINT [DF_PRE_PRMStawka] DEFAULT ((0)) NOT NULL,
    [PRE_PRMWymiar]                   TINYINT         CONSTRAINT [DF_PRE_PRMWymiar] DEFAULT ((1)) NOT NULL,
    [PRE_PRMMinimalna]                TINYINT         CONSTRAINT [DF_PRE_PRMMinimalna] DEFAULT ((0)) NOT NULL,
    [PRE_PRMKalId]                    INT             NULL,
    [PRE_PRMEtatL]                    SMALLINT        CONSTRAINT [DF_PRE_PRMEtatL] DEFAULT ((1)) NOT NULL,
    [PRE_PRMEtatM]                    SMALLINT        CONSTRAINT [DF_PRE_PRMEtatM] DEFAULT ((2)) NOT NULL,
    [PRE_NieGenPodwZasMacierz]        TINYINT         CONSTRAINT [DF_PRE_NieGenPodwZasMacierz] DEFAULT ((0)) NOT NULL,
    [PRE_OddelegowanyKraj]            NVARCHAR (40)   CONSTRAINT [DF_PRE_OddelegowanyKraj] DEFAULT ('') NOT NULL,
    [PRE_OddelegowanyWalutaDieta]     VARCHAR (3)     CONSTRAINT [DF_PRE_OddelegowanyWalutaDieta] DEFAULT ('') NOT NULL,
    [PRE_ZakId]                       INT             NULL,
    [PRE_HDKGUSSymbolWykszt]          INT             CONSTRAINT [DF_PRE_HDKGUSSymbolWykszt] DEFAULT ((0)) NOT NULL,
    [PRE_HDKGUSSymbolSystemuCzP]      INT             CONSTRAINT [DF_PRE_HDKGUSSymbolSystemuCzP] DEFAULT ((10)) NOT NULL,
    [PRE_OpeModKod]                   VARCHAR (20)    CONSTRAINT [DF_PRE_OpeModKod] DEFAULT ('') NOT NULL,
    [PRE_OpeModNazwisko]              NVARCHAR (50)   CONSTRAINT [DF_PRE_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PRE_OpeZalKod]                   VARCHAR (20)    CONSTRAINT [DF_PRE_OpeZalKod] DEFAULT ('') NOT NULL,
    [PRE_OpeZalNazwisko]              NVARCHAR (50)   CONSTRAINT [DF_PRE_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [PRE_ABSOP30]                     INT             CONSTRAINT [DF_PRE_ABSOP30] DEFAULT ((0)) NOT NULL,
    [PRE_PrzychPoprzRok]              DECIMAL (15, 2) CONSTRAINT [DF_PRE_PrzychPoprzRok] DEFAULT ((0)) NOT NULL,
    [PRE_KodWygasniecia]              NVARCHAR (32)   CONSTRAINT [DF_PRE_KodWygasniecia] DEFAULT ('') NOT NULL,
    [PRE_KodPodstPrawRozw]            NVARCHAR (32)   CONSTRAINT [DF_PRE_KodPodstPrawRozw] DEFAULT ('') NOT NULL,
    [PRE_StronaInicjujaca]            INT             CONSTRAINT [DF_PRE_StronaInicjujaca] DEFAULT ((0)) NOT NULL,
    [PRE_PodstPrawRozw]               NVARCHAR (72)   CONSTRAINT [DF_PRE_PodstPrawRozw] DEFAULT ('') NOT NULL,
    [PRE_Nauczyciel]                  TINYINT         CONSTRAINT [DF_PRE_Nauczyciel] DEFAULT ((0)) NOT NULL,
    [PRE_ObowPrzechDokDo]             DATETIME        NULL,
    [PRE_ObywatelKodKraju]            NVARCHAR (2)    CONSTRAINT [DF_PRE_ObywatelKodKraju] DEFAULT ('') NOT NULL,
    [PRE_PPKOkresOd]                  DATETIME        NULL,
    [PRE_PPKOkresDo]                  DATETIME        NULL,
    [PRE_PPKSklPodstPrac]             DECIMAL (5, 2)  CONSTRAINT [DF_PRE_PPKSklPodstPrac] DEFAULT ((0)) NOT NULL,
    [PRE_PPKSklDodatPrac]             DECIMAL (5, 2)  CONSTRAINT [DF_PRE_PPKSklDodatPrac] DEFAULT ((0)) NOT NULL,
    [PRE_PPKObnizenieSkladki]         TINYINT         CONSTRAINT [DF_PRE_PPKObnizenieSkladki] DEFAULT ((0)) NOT NULL,
    [PRE_PPKDataObnizenia]            DATETIME        NULL,
    [PRE_PPKSklDodatFirma]            DECIMAL (5, 2)  CONSTRAINT [DF_PRE_PPKSklDodatFirma] DEFAULT ((0)) NOT NULL,
    [PRE_PPKDataSkladkiDodatkowej]    DATETIME        NULL,
    [PRE_PPKIndywSklDodatFirma]       TINYINT         CONSTRAINT [DF_PRE_PPKIndywSklDodatFirma] DEFAULT ((0)) NOT NULL,
    [PRE_PPKPrzekazDaneKontaktowe]    TINYINT         CONSTRAINT [DF_PRE_PPKPrzekazDaneKontaktowe] DEFAULT ((0)) NOT NULL,
    [PRE_PODZwolPIT26]                TINYINT         CONSTRAINT [DF_PRE_PODZwolPIT26] DEFAULT ((0)) NOT NULL,
    [PRE_BnaIdMikro]                  INT             NULL,
    [PRE_RachunekNrMikro]             NVARCHAR (51)   CONSTRAINT [DF_PRE_RachunekNrMikro] DEFAULT ('') NOT NULL,
    [PRE_IBANMikro]                   SMALLINT        CONSTRAINT [DF_PRE_IBANMikro] DEFAULT ((1)) NOT NULL,
    [PRE_PODKartaPodPrzychod]         DECIMAL (15, 2) CONSTRAINT [DF_PRE_PODKartaPodPrzychod] DEFAULT ((0)) NOT NULL,
    [PRE_PODKartaPodDochod]           DECIMAL (15, 2) CONSTRAINT [DF_PRE_PODKartaPodDochod] DEFAULT ((0)) NOT NULL,
    [PRE_PODRyczaltPrzychod]          DECIMAL (15, 2) CONSTRAINT [DF_PRE_PODRyczaltPrzychod] DEFAULT ((0)) NOT NULL,
    [PRE_PODRyczaltDochod]            DECIMAL (15, 2) CONSTRAINT [DF_PRE_PODRyczaltDochod] DEFAULT ((0)) NOT NULL,
    [PRE_PODZasOgolnePrzychod]        DECIMAL (15, 2) CONSTRAINT [DF_PRE_PODZasOgolnePrzychod] DEFAULT ((0)) NOT NULL,
    [PRE_PODZasOgolneDochod]          DECIMAL (15, 2) CONSTRAINT [DF_PRE_PODZasOgolneDochod] DEFAULT ((0)) NOT NULL,
    [PRE_MalzonekId]                  INT             NULL,
    [PRE_SynchronizacjaTNA]           TINYINT         CONSTRAINT [DF_PRE_SynchronizacjaTNA] DEFAULT ((1)) NOT NULL,
    [PRE_LogowanieTNA]                TINYINT         CONSTRAINT [DF_PRE_LogowanieTNA] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PRE_Primary] PRIMARY KEY CLUSTERED ([PRE_PreId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PRE_DkmIdKodZawodu] FOREIGN KEY ([PRE_DkmIdKodZawodu]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_PRE_DkmIdPracodawca] FOREIGN KEY ([PRE_DkmIdPracodawca]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_PRE_ETADkmIdFunkcja] FOREIGN KEY ([PRE_ETADkmIdFunkcja]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_PRE_ETADkmIdStanowisko] FOREIGN KEY ([PRE_ETADkmIdStanowisko]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_PRE_ETADkmIdWypowPowod] FOREIGN KEY ([PRE_ETADkmIdWypowPowod]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_PREBnaLink] FOREIGN KEY ([PRE_BnaId]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId]),
    CONSTRAINT [FK_PREBnaMikroLink] FOREIGN KEY ([PRE_BnaIdMikro]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId]),
    CONSTRAINT [FK_PRECntLink] FOREIGN KEY ([PRE_CntId]) REFERENCES [CDN].[Centra] ([CNT_CntId]),
    CONSTRAINT [FK_PREDzlLink] FOREIGN KEY ([PRE_DzlId]) REFERENCES [CDN].[Dzialy] ([DZL_DzlId]),
    CONSTRAINT [FK_PREFplLink] FOREIGN KEY ([PRE_FplId]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId]),
    CONSTRAINT [FK_PREKalLink] FOREIGN KEY ([PRE_KalId]) REFERENCES [CDN].[Kalendarze] ([KAL_KalId]),
    CONSTRAINT [FK_PREKategoria] FOREIGN KEY ([PRE_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_PREPraLink] FOREIGN KEY ([PRE_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE,
    CONSTRAINT [FK_PREPRMKalLink] FOREIGN KEY ([PRE_PRMKalId]) REFERENCES [CDN].[Kalendarze] ([KAL_KalId]),
    CONSTRAINT [FK_PRETyuLink] FOREIGN KEY ([PRE_UBZTyuId]) REFERENCES [CDN].[TytUbezp] ([TYU_TyuId]),
    CONSTRAINT [FK_PREWlascicielLink] FOREIGN KEY ([PRE_WlascicielId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]),
    CONSTRAINT [FK_PREZakLink] FOREIGN KEY ([PRE_ZakId]) REFERENCES [CDN].[Zaklady] ([Zak_ZakID]),
    CONSTRAINT [FK_PREZastepowanyLink] FOREIGN KEY ([PRE_ZastepowanyId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]),
    CONSTRAINT [FK_PREZrgId] FOREIGN KEY ([PRE_ZrgId]) REFERENCES [CDN].[ZestawyRegul] ([ZRG_ZrgId])
);


GO
CREATE NONCLUSTERED INDEX [PREZrgId]
    ON [CDN].[PracEtaty]([PRE_ZrgId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PREPraLink]
    ON [CDN].[PracEtaty]([PRE_PraId] ASC, [PRE_DataOd] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREDzlLink]
    ON [CDN].[PracEtaty]([PRE_DzlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREKalLink]
    ON [CDN].[PracEtaty]([PRE_KalId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREBnaLink]
    ON [CDN].[PracEtaty]([PRE_BnaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREFplLink]
    ON [CDN].[PracEtaty]([PRE_FplId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREWlascicielLink]
    ON [CDN].[PracEtaty]([PRE_WlascicielId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRETyuLink]
    ON [CDN].[PracEtaty]([PRE_UBZTyuId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREKategoria]
    ON [CDN].[PracEtaty]([PRE_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRECntLink]
    ON [CDN].[PracEtaty]([PRE_CntId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRE_EP_Idx]
    ON [CDN].[PracEtaty]([PRE_PraId] ASC, [PRE_DataOd] ASC, [PRE_Nazwisko] ASC, [PRE_TypPracownika] ASC, [PRE_PreId] ASC)
    INCLUDE([PRE_Imie1], [PRE_DataDo], [PRE_ZatrudnionyOd], [PRE_ZatrudnionyDo]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRE_EP_DataZatrudnienia_Idx]
    ON [CDN].[PracEtaty]([PRE_TypPracownika] ASC, [PRE_DataOd] ASC, [PRE_DataDo] ASC, [PRE_ZatrudnionyOd] ASC, [PRE_ZatrudnionyDo] ASC)
    INCLUDE([PRE_PraId], [PRE_Nazwisko], [PRE_Imie1], [PRE_CntId]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRE_EP_Data_Idx]
    ON [CDN].[PracEtaty]([PRE_DataOd] ASC, [PRE_DataDo] ASC)
    INCLUDE([PRE_PraId], [PRE_CntId]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREPRMKalLink]
    ON [CDN].[PracEtaty]([PRE_PRMKalId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREZakLink]
    ON [CDN].[PracEtaty]([PRE_ZakId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREBnaMikroLink]
    ON [CDN].[PracEtaty]([PRE_BnaIdMikro] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PREMalzonekLink]
    ON [CDN].[PracEtaty]([PRE_MalzonekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.PracEtaty_InsertUpdate_Trigger ON cdn.PracEtaty
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
-- Aktualizacja PodmiotyView
--  Aktualizacja istniejących
Update CDN.PodmiotyView Set
  Pod_Kod          = A.PRE_Kod ,
  Pod_Nazwa1       = A.PRE_Nazwisko ,
  Pod_Nazwa2       = A.PRE_Imie1 ,
  Pod_Nazwa3       = '' ,
  Pod_Kraj         = A.PRE_MLDKraj ,
  Pod_Wojewodztwo  = A.PRE_MLDWojewodztwo ,
  Pod_Powiat       = A.PRE_MLDPowiat ,
  Pod_Gmina        = A.PRE_MLDGmina ,
  Pod_Ulica        = A.PRE_MLDUlica ,
  Pod_NrDomu       = A.PRE_MLDNrDomu ,
  Pod_NrLokalu     = A.PRE_MLDNrLokalu ,
  Pod_Miasto       = A.PRE_MLDMiasto ,
  Pod_KodPocztowy  = A.PRE_MLDKodPocztowy ,
  Pod_Poczta       = A.PRE_MLDPoczta ,
  Pod_Adres2       = A.PRE_MLDAdres2 ,
  Pod_Telefon1     = A.PRE_HDKTelefon1 ,
  Pod_Telefon2     = A.PRE_HDKTelefon2 ,
  Pod_TelefonSms   = A.PRE_TelefonSms ,
  Pod_Email        = A.PRE_HDKEmail ,
  Pod_Nieaktywny   = C.PRA_Archiwalny ,
  Pod_Rodzaj       = Case A.PRE_TypPracownika When 1 Then -4 Else -3 End ,
  Pod_RodzajOpis   = Case A.PRE_TypPracownika When 1 Then 'wspólnik' Else 'pracownik' End ,
  Pod_Grupa        = '' ,
  Pod_NipKraj      = A.PRE_NipKraj ,
  Pod_NIP          = A.PRE_NipE ,
  Pod_Regon        = '' ,
  Pod_Pesel        = A.PRE_Pesel ,
  Pod_LimitKredytu = 0 ,
  Pod_ImportRowId  = C.PRA_ImportRowId,
  Pod_KontoOdb = A.PRE_KontoKsiegowe,
  Pod_KontoDost = A.PRE_KontoKsiegowe2,
  Pod_NadID        = NULL,
  Pod_GlID         = A.PRE_PRAId,
  Pod_GlKod        = A.PRE_Kod,
  Pod_GlNazwa12    = A.PRE_Nazwisko + ' ' + A.PRE_Imie1
From CDN.PodmiotyView
Join inserted B      On Pod_PodmiotTyp = 3 And Pod_PodId = B.PRE_PRAId
Join CDN.PracEtaty A On A.PRE_PREId = B.PRE_PREId
Join CDN.PracKod C   On C.PRA_PRAId = A.PRE_PRAId
WHERE A.PRE_DataDo = CONVERT(datetime, '2999-12-31', 120)
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
  Pod_KontoOdb     ,
  Pod_KontoDost    ,
  Pod_NadID        ,
  Pod_GlID         ,
  Pod_GlKod        ,
  Pod_GlNazwa12
 )
Select
  3                 ,
  A.PRE_PRAId       ,
  A.PRE_Kod         ,
  A.PRE_Nazwisko    ,
  A.PRE_Imie1       ,
  ''                ,
  A.PRE_MLDKraj        ,
  A.PRE_MLDWojewodztwo ,
  A.PRE_MLDPowiat      ,
  A.PRE_MLDGmina       ,
  A.PRE_MLDUlica       ,
  A.PRE_MLDNrDomu      ,
  A.PRE_MLDNrLokalu    ,
  A.PRE_MLDMiasto      ,
  A.PRE_MLDKodPocztowy ,
  A.PRE_MLDPoczta      ,
  A.PRE_MLDAdres2      ,
  A.PRE_HDKTelefon1 ,
  A.PRE_HDKTelefon2 ,
  A.PRE_TelefonSms ,
  A.PRE_HDKEmail ,
  C.PRA_Archiwalny,
  Case A.PRE_TypPracownika When 1 Then -4 Else -3 End ,
  Case A.PRE_TypPracownika When 1 Then 'wspólnik' Else 'pracownik' End ,
  ''                ,
  A.PRE_NipKraj     ,
  A.PRE_NipE        ,
  ''                ,
  A.PRE_Pesel       ,
  0                 ,
  C.PRA_ImportRowId ,
  A.PRE_KontoKsiegowe                ,
  A.PRE_KontoKsiegowe2,
  NULL,
  A.PRE_PRAId,
  A.PRE_Kod,
  A.PRE_Nazwisko + ' ' + A.PRE_Imie1
From CDN.PracEtaty A
Join inserted B      On A.PRE_PREId = B.PRE_PREId
Join CDN.PracKod C   On C.PRA_PRAId = B.PRE_PRAId
Left Outer Join CDN.PodmiotyView D On D.Pod_PodmiotTyp = 3 And D.Pod_PodId = B.PRE_PraId
Where D.Pod_PodId Is Null And A.PRE_DataDo = CONVERT(datetime, '2999-12-31', 120)
--14
declare @PracId int, @DabId int
select @PracId = PRE_PraId, @DabId = PRE_DabId from inserted
update cdn.pracetaty set pre_dabid = @DabId where pre_praid = @PracId
IF UPDATE(PRE_Kod) OR UPDATE(PRE_Nazwisko)
BEGIN
 UPDATE cdn.CrmUczestnicy
 SET CrU_Akronim = B.PRE_Kod, CrU_Nazwisko = B.PRE_Imie1 + SPACE(1) + B.PRE_Nazwisko
 FROM cdn.CrmUczestnicy
 JOIN inserted B  ON CrU_PodmiotTyp = 3 And CrU_PodmiotId = B.PRE_PRAId
END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.PracEtaty2WypSkladniki_Delete_Trigger
  ON CDN.PracEtaty
  FOR DELETE
AS
SET NOCOUNT ON
-- obsługa sprawdzania relacji restrict do tabeli CDN.WypSkladniki
IF EXISTS (SELECT * FROM CDN.WypSkladniki JOIN deleted ON PRE_PreId = WPS_ZrodloId
           WHERE CDN.WypSkladniki.WPS_RodzajZrodla=1)
  BEGIN
 RAISERROR('##OPT32559##', 16, 1)
    --RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą WypSkladniki). ', 16, 1)--ERR_SQL_Place_WypSkladnikiPowiazanieWPS 32559
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
 --MC8.5
 declare @id int
 select @id = pre_preid from deleted
 delete from cdn.opiskadry where opk_rodzajzrodla = 16 and opk_zrodloid = @id
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.PracEtaty_Delete_Trigger ON CDN.PracEtaty
FOR DELETE
AS
SET NOCOUNT ON
-- Skasowanie wystąpień na fakturach cyklicznych  (WiNi)
  IF EXISTS( SELECT FCK_FCKID FROM CDN.FaCyklKnt WHERE FCK_PodmiotTyp = 3 AND FCK_PodmiotId In (Select PRE_PREID From deleted) )
  BEGIN
    RAISERROR('##OPT32506##', 16, 1)--RAISERROR('Nie można usunąć wskazanej pozycji. Istnieją faktury cykliczne, na których występuje usuwany pracownik.', 16, 1)--ERR_SQL_Place_FACyklPracownik
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  IF EXISTS( SELECT FCK_FCKID FROM CDN.FaCyklKnt WHERE FCK_PodmiotTyp = 4 AND FCK_PodmiotId In (Select PRE_PREID From deleted) )
  BEGIN
    RAISERROR('##OPT32507##', 16, 1)--RAISERROR('Nie można usunąć wskazanej pozycji. Istnieją faktury cykliczne, na których występuje usuwany wspólnik.', 16, 1)--ERR_SQL_Place_FACyklWspolnik
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Skasowanie relacji do dokumentów CRM
 DELETE CDN.DokRelacje FROM CDN.DokRelacje WHERE DoR_DokumentTyp=24000 AND DoR_DokumentId IN (SELECT PRE_PREID FROM deleted)
SET NOCOUNT OFF
