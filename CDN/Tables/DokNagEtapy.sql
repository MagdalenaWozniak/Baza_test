CREATE TABLE [CDN].[DokNagEtapy] (
    [DnE_DnEId]              INT             IDENTITY (1, 1) NOT NULL,
    [DnE_DnPrID]             INT             NULL,
    [DnE_EtapID]             INT             NULL,
    [DnE_Typ]                INT             NULL,
    [DnE_OpeId]              INT             NOT NULL,
    [DnE_Wykonany]           SMALLINT        NOT NULL,
    [DnE_Obowiazkowy]        TINYINT         NOT NULL,
    [DnE_CzyTerminWykonania] TINYINT         NOT NULL,
    [DnE_TerminWykonania]    DATETIME        NOT NULL,
    [DnE_TerminOd]           DATETIME        NOT NULL,
    [DnE_TerminDo]           DATETIME        NOT NULL,
    [DnE_RezerwujCzas]       TINYINT         NOT NULL,
    [DnE_Przypomnienie]      TINYINT         NOT NULL,
    [DnE_CzasPrzypomnienia]  DATETIME        NOT NULL,
    [DnE_Komentarz]          NVARCHAR (1024) NULL,
    CONSTRAINT [DnE_Primary] PRIMARY KEY CLUSTERED ([DnE_DnEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DnEProcesEtapy] FOREIGN KEY ([DnE_DnPrID]) REFERENCES [CDN].[DokNagProcesEtapy] ([DnPr_DnPrID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DnEProcesEtapy]
    ON [CDN].[DokNagEtapy]([DnE_DnPrID] ASC, [DnE_DnEId] ASC) WITH (FILLFACTOR = 100);

