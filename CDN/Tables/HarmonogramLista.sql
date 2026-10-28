CREATE TABLE [CDN].[HarmonogramLista] (
    [HRL_HrlId]          INT             IDENTITY (1, 1) NOT NULL,
    [HRL_HrmId]          INT             NOT NULL,
    [HRL_RataKapitalowa] DECIMAL (15, 2) NOT NULL,
    [HRL_Rok]            INT             NOT NULL,
    [HRL_Miesiac]        SMALLINT        NOT NULL,
    [HRL_RataOdsetkowa]  DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [HRL_Primary] PRIMARY KEY CLUSTERED ([HRL_HrlId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HRLHrmLink] FOREIGN KEY ([HRL_HrmId]) REFERENCES [CDN].[Harmonogram] ([HRM_HrmId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [HRLHrmLink]
    ON [CDN].[HarmonogramLista]([HRL_HrmId] ASC) WITH (FILLFACTOR = 100);

