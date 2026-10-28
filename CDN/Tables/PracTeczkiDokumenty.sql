CREATE TABLE [CDN].[PracTeczkiDokumenty] (
    [PTD_PtdId]             INT            IDENTITY (1, 1) NOT NULL,
    [PTD_PrtId]             INT            NOT NULL,
    [PTD_Nazwa]             NVARCHAR (256) NOT NULL,
    [PTD_RodzajLokalizacji] INT            NOT NULL,
    [PTD_Sciezka]           NVARCHAR (256) NOT NULL,
    [PTD_DabId]             INT            NULL,
    [PTD_Podpis]            TINYINT        NOT NULL,
    [PTD_FileMode]          SMALLINT       NOT NULL,
    [PTD_NazwaPliku]        NVARCHAR (255) NULL,
    [PTD_Wersja]            SMALLINT       NOT NULL,
    [PTD_Archiwalny]        INT            NULL,
    [PTD_WBazie]            SMALLINT       NULL,
    [PTD_StaEditId]         INT            NULL,
    [PTD_OpeEditId]         INT            NULL,
    [PTD_OpeZalID]          INT            NULL,
    [PTD_StaZalId]          INT            NULL,
    [PTD_TS_Zal]            DATETIME       NOT NULL,
    [PTD_OpeModID]          INT            NULL,
    [PTD_StaModId]          INT            NULL,
    [PTD_TS_Mod]            DATETIME       NOT NULL,
    [PTD_OpeModKod]         VARCHAR (20)   CONSTRAINT [DF_PTD_OpeModKod] DEFAULT ('') NOT NULL,
    [PTD_OpeModNazwisko]    NVARCHAR (50)  CONSTRAINT [DF_PTD_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PTD_OpeZalKod]         VARCHAR (20)   CONSTRAINT [DF_PTD_OpeZalKod] DEFAULT ('') NOT NULL,
    [PTD_OpeZalNazwisko]    NVARCHAR (50)  CONSTRAINT [DF_PTD_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_PTD_PtdId] PRIMARY KEY CLUSTERED ([PTD_PtdId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PTDPrtLink] FOREIGN KEY ([PTD_PrtId]) REFERENCES [CDN].[PracTeczki] ([PRT_PrtId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PTDPrtLink]
    ON [CDN].[PracTeczkiDokumenty]([PTD_PrtId] ASC, [PTD_PtdId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.PracTeczkiDokumenty_Delete_Trigger
  ON CDN.PracTeczkiDokumenty
  FOR DELETE
AS
  SET NOCOUNT ON
 declare @id int
 select @id = PTD_PtdId from deleted
 delete from cdn.DaneBinarne where DAB_Typ = 20 and DAB_TwAID = @id
  SET NOCOUNT OFF
