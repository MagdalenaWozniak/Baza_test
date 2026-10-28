CREATE TABLE [CDN].[OkresoweHarmonogram] (
    [OkH_OkHId] INT             IDENTITY (1, 1) NOT NULL,
    [OkH_OkEId] INT             NOT NULL,
    [OkH_Data]  DATETIME        NOT NULL,
    [OkH_Kwota] DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [OkH_Primary] PRIMARY KEY CLUSTERED ([OkH_OkHId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OkHElement] FOREIGN KEY ([OkH_OkEId]) REFERENCES [CDN].[OkresoweElem] ([OkE_OkEId]) ON DELETE CASCADE
);

