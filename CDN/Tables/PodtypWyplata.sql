CREATE TABLE [CDN].[PodtypWyplata] (
    [PTW_PtwId]       INT           IDENTITY (1, 1) NOT NULL,
    [PTW_TwpId]       INT           NOT NULL,
    [PTW_ParentSTS]   INT           NOT NULL,
    [PTW_ParentNazwa] NVARCHAR (40) NOT NULL,
    [PTW_ParentId]    INT           NOT NULL,
    CONSTRAINT [PTW_Primary] PRIMARY KEY CLUSTERED ([PTW_PtwId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PTWTwpLink] FOREIGN KEY ([PTW_TwpId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PTWTwpLink]
    ON [CDN].[PodtypWyplata]([PTW_TwpId] ASC) WITH (FILLFACTOR = 100);

