CREATE TABLE [CDN].[KntESklepyPrzedstawiciele] (
    [KESP_KESPID]                 INT            IDENTITY (1, 1) NOT NULL,
    [KESP_KntID]                  INT            NOT NULL,
    [KESP_eSklepID]               INT            NOT NULL,
    [KESP_PrzedstawicielID]       INT            NOT NULL,
    [KESP_Domyslny]               TINYINT        NOT NULL,
    [KESP_NieAktywny]             TINYINT        CONSTRAINT [DF_KESP_NieAktywny] DEFAULT ((0)) NOT NULL,
    [KESP_Email]                  NVARCHAR (127) NOT NULL,
    [KESP_Nazwisko]               NVARCHAR (40)  NOT NULL,
    [KESP_PrzedstawicieleSklepID] INT            CONSTRAINT [DF_KESP_PrzedstawicieleSklepID] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [KESP_Primary] PRIMARY KEY CLUSTERED ([KESP_KESPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KESPESS] FOREIGN KEY ([KESP_eSklepID]) REFERENCES [CDN].[eSklepStanowiska] ([ESS_ESSId]),
    CONSTRAINT [FK_KESPKnt] FOREIGN KEY ([KESP_KntID]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KESPKntESS]
    ON [CDN].[KntESklepyPrzedstawiciele]([KESP_KntID] ASC, [KESP_eSklepID] ASC, [KESP_PrzedstawicielID] ASC) WITH (FILLFACTOR = 100);

