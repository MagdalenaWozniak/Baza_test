CREATE TABLE [CDN].[SprawozdaniaFinansowePodpisy] (
    [SFP_SFPId]          INT            IDENTITY (1, 1) NOT NULL,
    [SFP_SFNId]          INT            NULL,
    [SFP_Nazwa]          NVARCHAR (255) NULL,
    [SFP_Podpis]         INT            NULL,
    [SFP_Odmowa]         INT            NULL,
    [SFP_Odcisk]         NVARCHAR (255) NULL,
    [SFP_TS_Oblicz]      DATETIME       NULL,
    [SFP_OpeZalID]       INT            NULL,
    [SFP_StaZalId]       INT            NULL,
    [SFP_TS_Zal]         DATETIME       NOT NULL,
    [SFP_OpeModID]       INT            NULL,
    [SFP_StaModId]       INT            NULL,
    [SFP_TS_Mod]         DATETIME       NOT NULL,
    [SFP_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_SFP_OpeModKod] DEFAULT ('') NOT NULL,
    [SFP_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SFP_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SFP_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_SFP_OpeZalKod] DEFAULT ('') NOT NULL,
    [SFP_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SFP_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SFP_Primary] PRIMARY KEY CLUSTERED ([SFP_SFPId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [SFPSFNId]
    ON [CDN].[SprawozdaniaFinansowePodpisy]([SFP_SFNId] ASC) WITH (FILLFACTOR = 100);

