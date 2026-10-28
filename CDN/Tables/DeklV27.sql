CREATE TABLE [CDN].[DeklV27] (
    [V27_V27ID]  INT             IDENTITY (1, 1) NOT NULL,
    [V27_DkNID]  INT             NOT NULL,
    [V27_Kwota]  DECIMAL (15, 2) NULL,
    [V27_LP]     INT             NOT NULL,
    [V27_NIP]    VARCHAR (255)   NOT NULL,
    [V27_Nazwa]  VARCHAR (350)   NULL,
    [V27_Numer]  INT             NOT NULL,
    [V27_Zmiana] TINYINT         NOT NULL,
    [V27_Typ]    INT             NOT NULL,
    CONSTRAINT [V27_Primary] PRIMARY KEY CLUSTERED ([V27_V27ID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_V27DeklNag] FOREIGN KEY ([V27_DkNID]) REFERENCES [CDN].[DeklNag] ([DkN_DkNID]) ON DELETE CASCADE
);

