CREATE TABLE [CDN].[Poreczyciele] (
    [POR_PorId]            INT            IDENTITY (1, 1) NOT NULL,
    [POR_DodId]            INT            NOT NULL,
    [POR_PraId]            INT            NULL,
    [POR_Osoba]            NVARCHAR (129) NOT NULL,
    [POR_Opis]             NVARCHAR (512) NOT NULL,
    [POR_PoreczycielLista] TINYINT        NOT NULL,
    [POR_OpeZalId]         INT            NULL,
    [POR_StaZalId]         INT            NULL,
    [POR_TS_Zal]           DATETIME       NOT NULL,
    [POR_OpeModId]         INT            NULL,
    [POR_StaModId]         INT            NULL,
    [POR_TS_Mod]           DATETIME       NOT NULL,
    [POR_OpeModKod]        VARCHAR (20)   CONSTRAINT [DF_POR_OpeModKod] DEFAULT ('') NOT NULL,
    [POR_OpeModNazwisko]   NVARCHAR (50)  CONSTRAINT [DF_POR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [POR_OpeZalKod]        VARCHAR (20)   CONSTRAINT [DF_POR_OpeZalKod] DEFAULT ('') NOT NULL,
    [POR_OpeZalNazwisko]   NVARCHAR (50)  CONSTRAINT [DF_POR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [POR_Primary] PRIMARY KEY CLUSTERED ([POR_PorId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PORDodLink] FOREIGN KEY ([POR_DodId]) REFERENCES [CDN].[Dodatki] ([DOD_DodId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PORDodLink]
    ON [CDN].[Poreczyciele]([POR_DodId] ASC) WITH (FILLFACTOR = 100);

