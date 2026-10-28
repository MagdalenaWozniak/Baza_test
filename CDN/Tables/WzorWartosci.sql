CREATE TABLE [CDN].[WzorWartosci] (
    [WZW_WzwId]      INT             IDENTITY (1, 1) NOT NULL,
    [WZW_TwpId]      INT             NULL,
    [WZW_Symbol]     VARCHAR (128)   NOT NULL,
    [WZW_Wzor]       NVARCHAR (256)  NOT NULL,
    [WZW_Nieaktywny] SMALLINT        NOT NULL,
    [WZW_Dodatkowe]  DECIMAL (15, 2) NOT NULL,
    [WZW_WzrId]      INT             NULL,
    CONSTRAINT [WZW_Primary] PRIMARY KEY CLUSTERED ([WZW_WzwId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WZWTypWyplata] FOREIGN KEY ([WZW_TwpId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [WZWWzrId]
    ON [CDN].[WzorWartosci]([WZW_WzrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WZWTypWyplata]
    ON [CDN].[WzorWartosci]([WZW_TwpId] ASC) WITH (FILLFACTOR = 100);

