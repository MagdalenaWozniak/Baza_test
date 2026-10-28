CREATE TABLE [CDN].[TwrJezykObcy] (
    [TwrJ_TwrJID]            INT            IDENTITY (1, 1) NOT NULL,
    [TwrJ_TwrID]             INT            NOT NULL,
    [TwrJ_eSklepID]          INT            CONSTRAINT [DF_TwrJ_eSklepID] DEFAULT ((0)) NOT NULL,
    [TwrJ_JezykID]           SMALLINT       CONSTRAINT [DF_TwrJ_JezykID] DEFAULT ((1)) NOT NULL,
    [TwrJ_Nazwa]             NVARCHAR (255) NOT NULL,
    [TwrJ_NazwaHTML]         NVARCHAR (255) NOT NULL,
    [TwrJ_Opis]              NVARCHAR (MAX) NOT NULL,
    [TwrJ_OpisHTML]          NVARCHAR (MAX) NOT NULL,
    [TwrJ_OpisKrotki]        NVARCHAR (500) NOT NULL,
    [TwrJ_MetaTytul]         NVARCHAR (100) NOT NULL,
    [TwrJ_MetaSlowaKluczowe] NVARCHAR (500) NOT NULL,
    [TwrJ_MetaOpis]          NVARCHAR (320) NOT NULL,
    [TwrJ_Link]              NVARCHAR (50)  CONSTRAINT [DF_TwrJ_Link] DEFAULT ('') NOT NULL,
    [TwrJ_Szukaj]            NVARCHAR (512) CONSTRAINT [DF_TwrJ_Szukaj] DEFAULT ('') NOT NULL,
    CONSTRAINT [TwrJ_Primary] PRIMARY KEY CLUSTERED ([TwrJ_TwrID] ASC, [TwrJ_JezykID] ASC, [TwrJ_eSklepID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwrJOdoTowary] FOREIGN KEY ([TwrJ_TwrID]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwrJOID]
    ON [CDN].[TwrJezykObcy]([TwrJ_TwrJID] ASC) WITH (FILLFACTOR = 100);

