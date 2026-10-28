CREATE TABLE [CDN].[SprawozdaniaFinansoweZalaczniki] (
    [SFZ_SFZId]          INT            IDENTITY (1, 1) NOT NULL,
    [SFZ_SFNId]          INT            NULL,
    [SFZ_DABId]          INT            NULL,
    [SFZ_Nazwa]          NVARCHAR (260) NULL,
    [SFZ_Typ]            INT            NULL,
    [SFZ_Wlasny]         INT            NULL,
    [SFZ_TS_Oblicz]      DATETIME       NULL,
    [SFZ_OpeZalID]       INT            NULL,
    [SFZ_StaZalId]       INT            NULL,
    [SFZ_TS_Zal]         DATETIME       NOT NULL,
    [SFZ_OpeModID]       INT            NULL,
    [SFZ_StaModId]       INT            NULL,
    [SFZ_TS_Mod]         DATETIME       NOT NULL,
    [SFZ_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_SFZ_OpeModKod] DEFAULT ('') NOT NULL,
    [SFZ_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SFZ_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SFZ_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_SFZ_OpeZalKod] DEFAULT ('') NOT NULL,
    [SFZ_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SFZ_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SFZ_Primary] PRIMARY KEY CLUSTERED ([SFZ_SFZId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [SFZSFNId]
    ON [CDN].[SprawozdaniaFinansoweZalaczniki]([SFZ_SFNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SFZDABId]
    ON [CDN].[SprawozdaniaFinansoweZalaczniki]([SFZ_DABId] ASC) WITH (FILLFACTOR = 100);

