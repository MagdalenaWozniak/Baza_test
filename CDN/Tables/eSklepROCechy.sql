CREATE TABLE [CDN].[eSklepROCechy] (
    [ESC_ESCID]         INT            IDENTITY (1, 1) NOT NULL,
    [ESC_TrEID]         INT            NOT NULL,
    [ESC_TwRID]         INT            NOT NULL,
    [ESC_Cecha_DeAId]   INT            NOT NULL,
    [ESC_Cecha_Wartosc] NVARCHAR (255) NOT NULL,
    CONSTRAINT [ESC_Primary] PRIMARY KEY CLUSTERED ([ESC_ESCID] ASC) WITH (FILLFACTOR = 100)
);

