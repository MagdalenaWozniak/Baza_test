CREATE TABLE [CDN].[SentHistoria] (
    [SentH_SentHID]          INT             IDENTITY (1, 1) NOT NULL,
    [SentH_SentID]           INT             NOT NULL,
    [SentH_Korelacja]        VARCHAR (50)    NOT NULL,
    [SentH_CheckSum]         VARCHAR (50)    NOT NULL,
    [SentH_ModificationDate] DATETIME        NOT NULL,
    [SentH_SentTyp]          INT             NOT NULL,
    [SentH_Rodzaj]           INT             NOT NULL,
    [SentH_Status]           INT             NOT NULL,
    [SentH_DataOperacji]     DATETIME        NOT NULL,
    [SentH_Plik]             VARCHAR (255)   NOT NULL,
    [SentH_Opis]             NVARCHAR (1000) NOT NULL,
    [SentH_OpeID]            INT             NULL,
    [SentH_OpeKod]           VARCHAR (20)    NOT NULL,
    [SentH_OpeNazwisko]      NVARCHAR (50)   NOT NULL,
    CONSTRAINT [SentHistoria_Primary] PRIMARY KEY CLUSTERED ([SentH_SentHID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SentHistoriaSentZgloszenia] FOREIGN KEY ([SentH_SentID]) REFERENCES [CDN].[SentZgloszenia] ([Sent_SentID])
);


GO
CREATE NONCLUSTERED INDEX [SentHDataOperacji]
    ON [CDN].[SentHistoria]([SentH_DataOperacji] ASC) WITH (FILLFACTOR = 100);

