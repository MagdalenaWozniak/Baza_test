CREATE TABLE [CDN].[DetalStanKonfiguracja] (
    [DSKnf_DSKnfId]             INT           IDENTITY (1, 1) NOT NULL,
    [DSKnf_StanDetalID]         INT           NOT NULL,
    [DSKnf_NazwaStanowiska]     NVARCHAR (50) NOT NULL,
    [DSKnf_TS_Synchro]          DATETIME      NOT NULL,
    [DSKnf_TS_SynchroTwr]       DATETIME      NOT NULL,
    [DSKnf_TS_SynchroKnt]       DATETIME      NOT NULL,
    [DSKnf_TS_SynchroTraNag]    DATETIME      NOT NULL,
    [DSKnf_TS_SynchroZapisKB]   DATETIME      NOT NULL,
    [DSKnf_TS_SynchroImportKnt] DATETIME      NOT NULL,
    [DSKnf_TS_SynchroOpak]      DATETIME      NOT NULL,
    [DSKnf_NumeracjaPA]         NVARCHAR (50) NOT NULL,
    [DSKnf_NumeracjaPAKor]      NVARCHAR (50) NOT NULL,
    [DSKnf_NumeracjaFS]         NVARCHAR (50) NOT NULL,
    [DSKnf_NumeracjaFSKor]      NVARCHAR (50) NOT NULL,
    [DSKnf_NumeracjaKP]         NVARCHAR (50) NOT NULL,
    [DSKnf_NumeracjaKW]         NVARCHAR (50) NOT NULL,
    [DSKnf_NumeracjaPKA]        NVARCHAR (50) NOT NULL,
    [DSKnf_Oddzial]             TINYINT       CONSTRAINT [DF_DSKnf_Oddzial] DEFAULT ((0)) NOT NULL,
    [DSKnf_TS_SynchroOptima]    DATETIME      CONSTRAINT [DF_DSKnf_TS_SynchroOptima] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DSKnf_Primary] PRIMARY KEY CLUSTERED ([DSKnf_DSKnfId] ASC) WITH (FILLFACTOR = 100)
);

