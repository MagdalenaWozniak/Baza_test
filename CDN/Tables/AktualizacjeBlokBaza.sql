CREATE TABLE [CDN].[AktualizacjeBlokBaza] (
    [AktBB_ID]         INT           NOT NULL,
    [AktBB_Uzytkownik] VARCHAR (50)  NULL,
    [AktBB_Czas]       DATETIME2 (7) NULL,
    CONSTRAINT [AktBB_Primary] PRIMARY KEY CLUSTERED ([AktBB_ID] ASC) WITH (FILLFACTOR = 100)
);

