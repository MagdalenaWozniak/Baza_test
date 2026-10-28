CREATE TABLE [CDN].[DlgNag] (
    [DLN_DLNId]                      INT             IDENTITY (1, 1) NOT NULL,
    [DLN_Status]                     SMALLINT        NOT NULL,
    [DLN_DDfId]                      INT             NULL,
    [DLN_NumerNr]                    INT             NOT NULL,
    [DLN_NumerString]                NVARCHAR (31)   NOT NULL,
    [DLN_NumerPelny]                 AS              ([CDN].[FN_NUMERPELNY]([DLN_NumerNr],[DLN_NumerString])),
    [DLN_DataDok]                    DATETIME        NOT NULL,
    [DLN_PodmiotTyp]                 INT             NOT NULL,
    [DLN_PodmiotId]                  INT             NOT NULL,
    [DLN_DataOd]                     DATETIME        NOT NULL,
    [DLN_DataDo]                     DATETIME        NOT NULL,
    [DLN_DataRozliczenia]            DATETIME        NOT NULL,
    [DLN_WyjazdZMZ]                  SMALLINT        NOT NULL,
    [DLN_Waluta]                     VARCHAR (3)     NOT NULL,
    [DLN_KursNumer]                  INT             NOT NULL,
    [DLN_KursL]                      DECIMAL (15, 4) NOT NULL,
    [DLN_KursM]                      DECIMAL (5)     NOT NULL,
    [DLN_KwotaSys]                   DECIMAL (15, 2) NOT NULL,
    [DLN_KwotaWal]                   DECIMAL (15, 2) NOT NULL,
    [DLN_Opis]                       NVARCHAR (255)  NULL,
    [DLN_BuforData]                  DATETIME        NULL,
    [DLN_BuforOperatorId]            INT             NULL,
    [DLN_PolecenieWyjazduData]       DATETIME        NULL,
    [DLN_PolecenieWyjazduOperatorId] INT             NULL,
    [DLN_WydatkiData]                DATETIME        NULL,
    [DLN_WydatkiOperatorId]          INT             NULL,
    [DLN_ZatwierdzenieData]          DATETIME        NULL,
    [DLN_ZatwierdzenieOperatorId]    INT             NULL,
    [DLN_WymagaPrzeliczenia]         SMALLINT        CONSTRAINT [DF_DLN_WymagaPrzeliczenia] DEFAULT ((0)) NOT NULL,
    [DLN_DekId]                      INT             NULL,
    [DLN_PreDekId]                   INT             NULL,
    [DLN_KPRId]                      INT             NULL,
    [DLN_Zrodlo]                     INT             CONSTRAINT [DF_DLN_Zrodlo] DEFAULT ((0)) NOT NULL,
    [DLN_OpeZalID]                   INT             NULL,
    [DLN_StaZalId]                   INT             NULL,
    [DLN_TS_Zal]                     DATETIME        NOT NULL,
    [DLN_OpeModID]                   INT             NULL,
    [DLN_StaModId]                   INT             NULL,
    [DLN_TS_Mod]                     DATETIME        NOT NULL,
    [DLN_OpeModKod]                  VARCHAR (20)    CONSTRAINT [DF_DLN_OpeModKod] DEFAULT ('') NOT NULL,
    [DLN_OpeModNazwisko]             NVARCHAR (50)   CONSTRAINT [DF_DLN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DLN_OpeZalKod]                  VARCHAR (20)    CONSTRAINT [DF_DLN_OpeZalKod] DEFAULT ('') NOT NULL,
    [DLN_OpeZalNazwisko]             NVARCHAR (50)   CONSTRAINT [DF_DLN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [DLN_ZakId]                      INT             NULL,
    [DLN_KatId]                      INT             NULL,
    [DLN_Kategoria]                  NVARCHAR (50)   NULL,
    [DLN_MiejsceDocelowe]            NVARCHAR (255)  NULL,
    [DLN_Zagraniczna]                SMALLINT        CONSTRAINT [DF_DLN_Zagraniczna] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DLN_Primary] PRIMARY KEY CLUSTERED ([DLN_DLNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DLNNumer]
    ON [CDN].[DlgNag]([DLN_NumerString] ASC, [DLN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DLNNumerPelny]
    ON [CDN].[DlgNag]([DLN_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DLNDekrety]
    ON [CDN].[DlgNag]([DLN_DekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DLNPreDekrety]
    ON [CDN].[DlgNag]([DLN_PreDekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DLNKPR]
    ON [CDN].[DlgNag]([DLN_KPRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DlgNag_Delete_Trigger
  ON CDN.DlgNag
  FOR DELETE
AS
  SET NOCOUNT ON
  Set ArithAbort On
-- Sprawdzenie, czy zapisy nie są zaksięgowane do KPiR
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.DLN_KpRId IS NOT NULL)
    BEGIN
   exec CDN.RiseOptimaException 32608
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane na konta
  IF EXISTS (SELECT * FROM deleted JOIN CDN.DekretyNag On DLN_DekId = DeN_DeNId)
    BEGIN
   exec CDN.RiseOptimaException 32609
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Skasowanie relacji do dokumentów CRM
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=114 AND DoR_DokumentId IN (SELECT DLN_DLNId FROM deleted)
Set NoCount Off
