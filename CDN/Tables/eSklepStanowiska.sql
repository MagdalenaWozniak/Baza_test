CREATE TABLE [CDN].[eSklepStanowiska] (
    [ESS_ESSId]                             INT            IDENTITY (1, 1) NOT NULL,
    [ESS_Nazwa]                             NVARCHAR (40)  NOT NULL,
    [ESS_Typ]                               TINYINT        NOT NULL,
    [ESS_ASSerwer]                          NVARCHAR (254) NOT NULL,
    [ESS_Hash]                              NVARCHAR (54)  NOT NULL,
    [ESS_IdKlienta]                         NVARCHAR (10)  NOT NULL,
    [ESS_IdISklep]                          INT            NOT NULL,
    [ESS_DomyslnaWaluta]                    VARCHAR (5)    NOT NULL,
    [ESS_DomyslnyMagazyn]                   INT            NOT NULL,
    [ESS_ExpZasoby]                         TINYINT        NOT NULL,
    [ESS_WyslijStanWszystkieMag]            TINYINT        NOT NULL,
    [ESS_StanyNaDzien]                      TINYINT        NOT NULL,
    [ESS_WyslijCechyPartii]                 TINYINT        NOT NULL,
    [ESS_TwGNumer]                          INT            NOT NULL,
    [ESS_SchematNumeracjiRO]                INT            NOT NULL,
    [ESS_SchematNumeracjiROSeria]           NVARCHAR (5)   NOT NULL,
    [ESS_ExpGrup]                           TINYINT        NOT NULL,
    [ESS_ExpGrupTyp]                        TINYINT        NOT NULL,
    [ESS_NrCeny]                            INT            NOT NULL,
    [ESS_NrCenyDomyslnej]                   INT            NOT NULL,
    [ESS_EsklepCena0]                       TINYINT        NOT NULL,
    [ESS_ExpCennik]                         TINYINT        NOT NULL,
    [ESS_ExpCennikTyp]                      TINYINT        NOT NULL,
    [ESS_KosztPrzesylki]                    INT            NOT NULL,
    [ESS_FormaPlatnosciESPOS1]              INT            NOT NULL,
    [ESS_FormaPlatnosciESPOS2]              INT            NOT NULL,
    [ESS_FormaPlatnosciESPOS3]              INT            NOT NULL,
    [ESS_FormaPlatnosciESPOS4]              INT            NOT NULL,
    [ESS_FormaPlatnosciESPOS5]              INT            NOT NULL,
    [ESS_KntSprawdzNIP]                     TINYINT        NOT NULL,
    [ESS_KntSprawdzEMail]                   TINYINT        NOT NULL,
    [ESS_KntGrupa]                          NVARCHAR (20)  NOT NULL,
    [ESS_DaneFirmyNazwa]                    NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyOpis]                     NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyUlica]                    NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyNrDomu]                   NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyNrMieszkania]             NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyMiasto]                   NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyKodPocztowy]              VARCHAR (254)  NOT NULL,
    [ESS_DaneFirmyWojewodztwo]              NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyTelefon]                  VARCHAR (254)  NOT NULL,
    [ESS_DaneFirmyEmail]                    NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyURL]                      VARCHAR (254)  NOT NULL,
    [ESS_DaneFirmyGG]                       NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmySkype]                    NVARCHAR (254) NOT NULL,
    [ESS_DaneFirmyLogo]                     INT            NOT NULL,
    [ESS_DaneFirmyRok]                      NVARCHAR (4)   NOT NULL,
    [ESS_DaneFirmyGSM]                      VARCHAR (254)  NOT NULL,
    [ESS_DaneFirmyFacebook]                 NVARCHAR (254) NOT NULL,
    [ESS_FakturaPDF]                        TINYINT        NOT NULL,
    [ESS_TS_Synchro]                        INT            NOT NULL,
    [ESS_TS_SynchroPotw]                    INT            NOT NULL,
    [ESS_TS_SynchroTwr]                     INT            NOT NULL,
    [ESS_TS_SynchroTwrPotw]                 INT            NOT NULL,
    [ESS_TS_SynchroKnt]                     INT            NOT NULL,
    [ESS_TS_SynchroKntPotw]                 INT            NOT NULL,
    [ESS_TS_SynchroGrup]                    INT            NOT NULL,
    [ESS_TS_SynchroGrupPotw]                INT            NOT NULL,
    [ESS_TS_SynchroSlowniki]                INT            NOT NULL,
    [ESS_TS_SynchroZestawyTwr]              INT            CONSTRAINT [DF_ESS_TS_SynchroZestawyTwr] DEFAULT ((0)) NOT NULL,
    [ESS_TS_SynchroZestawyTwrPotw]          INT            CONSTRAINT [DF_ESS_TS_SynchroZestawyTwrPotw] DEFAULT ((0)) NOT NULL,
    [ESS_TS_SynchroKntOptima]               INT            CONSTRAINT [DF_ESS_TS_SynchroKntOptima] DEFAULT ((0)) NOT NULL,
    [ESS_TS_SynchroKntOptimaPotw]           INT            CONSTRAINT [DF_ESS_TS_SynchroKntOptimaPotw] DEFAULT ((0)) NOT NULL,
    [ESS_StanSynchronizacji]                TINYINT        CONSTRAINT [DF_ESS_StanSynchronizacji] DEFAULT ((0)) NOT NULL,
    [ESS_TS_SynchroBin]                     INT            CONSTRAINT [DF_ESS_TS_SynchroBin] DEFAULT ((0)) NOT NULL,
    [ESS_TS_SynchroBinPotw]                 INT            CONSTRAINT [DF_ESS_TS_SynchroBinPotw] DEFAULT ((0)) NOT NULL,
    [ESS_TypSklepu]                         TINYINT        CONSTRAINT [DF_ESS_TypSklepu] DEFAULT ((0)) NOT NULL,
    [ESS_Nieaktywny]                        TINYINT        CONSTRAINT [DF_ESS_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [ESS_OstatnieDabId]                     INT            CONSTRAINT [DF_ESS_OstatnieDabId] DEFAULT ((0)) NOT NULL,
    [ESS_KontrolaLimituPlat]                TINYINT        CONSTRAINT [DF_ESS_KontrolaLimituPlat] DEFAULT ((0)) NOT NULL,
    [ESS_PierwszaSynchroLoginy]             TINYINT        CONSTRAINT [DF_ESS_PierwszaSynchroLoginy] DEFAULT ((0)) NOT NULL,
    [ESS_PierwszaSynchroZgody]              TINYINT        CONSTRAINT [DF_ESS_PierwszaSynchroZgody] DEFAULT ((0)) NOT NULL,
    [ESS_PierwszaSynchroDefAtr]             TINYINT        CONSTRAINT [DF_ESS_PierwszaSynchroDefAtr] DEFAULT ((0)) NOT NULL,
    [ESS_PomijajKosztyDostawyZeroweParagon] TINYINT        CONSTRAINT [DF_ESS_PomijajKosztyDostawyZeroweParagon] DEFAULT ((1)) NOT NULL,
    [ESS_PomijajKosztyDostawyZeroweFaktura] TINYINT        CONSTRAINT [DF_ESS_PomijajKosztyDostawyZeroweFaktura] DEFAULT ((0)) NOT NULL,
    [ESS_WersjaProt]                        DECIMAL (5, 2) CONSTRAINT [DF_ESS_WersjaProt] DEFAULT ((15)) NOT NULL,
    [ESS_OstatnieTwrId]                     INT            CONSTRAINT [DF_ESS_OstatnieTwrId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [ESS_Primary] PRIMARY KEY CLUSTERED ([ESS_ESSId] ASC) WITH (FILLFACTOR = 100)
);


GO
Create TRIGGER [CDN].[eSklepStanowiska_InsertUpdate_Trigger]
  ON [CDN].[eSklepStanowiska]
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  /*
  declare
  @IDSklep INT;
         DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
         SELECT ess_essId
         FROM inserted
       OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO @IDSklep
          IF @@FETCH_STATUS <> 0 BREAK
        END
      CLOSE Dodawane
      DEALLOCATE Dodawane
 */
   IF  UPDATE( ESS_TwGNumer)
   update cdn.eSklepStanowiska set ESS_TS_SynchroGrupPotw = 0 where ESS_ESSId in (SELECT ess_essId FROM inserted)
   IF  UPDATE( ESS_NrCeny)
     update cdn.eSklepStanowiska set ESS_TS_SynchroTwrPotw = 0 where ESS_ESSId in (SELECT ess_essId FROM inserted)
  IF  UPDATE( ESS_NrCenyDomyslnej)
     update cdn.eSklepStanowiska set ESS_TS_SynchroTwrPotw = 0 where ESS_ESSId in (SELECT ess_essId FROM inserted)
  IF  UPDATE( ESS_DomyslnaWaluta)
     update cdn.eSklepStanowiska set ESS_TS_SynchroTwrPotw = 0 where ESS_ESSId in (SELECT ess_essId FROM inserted)
  IF  UPDATE( ESS_EsklepCena0)
     update cdn.eSklepStanowiska set ESS_TS_SynchroTwrPotw = 0 where ESS_ESSId in (SELECT ess_essId FROM inserted)
  IF  UPDATE( ESS_WyslijCechyPartii)
     update cdn.eSklepStanowiska set ESS_TS_SynchroTwrPotw = 0 where ESS_ESSId in (SELECT ess_essId FROM inserted)
  SET NOCOUNT OFF
