CREATE TABLE [CDN].[HisWyksztal] (
    [HWY_HwyId]          INT            IDENTITY (1, 1) NOT NULL,
    [HWY_PraId]          INT            NOT NULL,
    [HWY_Nazwa]          NVARCHAR (140) NOT NULL,
    [HWY_OkresOd]        DATETIME       NULL,
    [HWY_OkresDo]        DATETIME       NULL,
    [HWY_Zawod]          NVARCHAR (30)  NOT NULL,
    [HWY_Specjalnosc]    NVARCHAR (30)  NOT NULL,
    [HWY_Stopien]        NVARCHAR (30)  NOT NULL,
    [HWY_Tytul]          NVARCHAR (30)  NOT NULL,
    [HWY_StazLata]       INT            NOT NULL,
    [HWY_StazMies]       INT            NOT NULL,
    [HWY_StazDni]        INT            NOT NULL,
    [HWY_StazWliczac]    TINYINT        NOT NULL,
    [HWY_OpeZalId]       INT            NULL,
    [HWY_StaZalId]       INT            NULL,
    [HWY_TS_Zal]         DATETIME       NOT NULL,
    [HWY_OpeModId]       INT            NULL,
    [HWY_StaModId]       INT            NULL,
    [HWY_TS_Mod]         DATETIME       NOT NULL,
    [HWY_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_HWY_OpeModKod] DEFAULT ('') NOT NULL,
    [HWY_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_HWY_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [HWY_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_HWY_OpeZalKod] DEFAULT ('') NOT NULL,
    [HWY_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_HWY_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [HWY_Primary] PRIMARY KEY CLUSTERED ([HWY_HwyId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HWYPraLink] FOREIGN KEY ([HWY_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [HWYPraLink]
    ON [CDN].[HisWyksztal]([HWY_PraId] ASC) WITH (FILLFACTOR = 100);

