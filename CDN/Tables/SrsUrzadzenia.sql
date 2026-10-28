CREATE TABLE [CDN].[SrsUrzadzenia] (
    [SrU_SrUId]          INT            IDENTITY (1, 1) NOT NULL,
    [SrU_Kod]            VARCHAR (50)   NOT NULL,
    [SrU_Nazwa]          NVARCHAR (251) NOT NULL,
    [SrU_EAN]            VARCHAR (128)  NULL,
    [SrU_PodmiotTyp]     SMALLINT       NULL,
    [SrU_PodmiotId]      INT            NULL,
    [SrU_OdbiorcaTyp]    SMALLINT       NULL,
    [SrU_OdbID]          INT            NULL,
    [SrU_SrRId]          INT            NULL,
    [SrU_TwRId]          INT            NULL,
    [SrU_Opis]           NVARCHAR (MAX) NOT NULL,
    [SrU_FCzynnosci]     TINYINT        CONSTRAINT [DF_SrU_FCzynnosci] DEFAULT ((1)) NOT NULL,
    [SrU_FCzesci]        TINYINT        CONSTRAINT [DF_SrU_FCzesci] DEFAULT ((0)) NOT NULL,
    [SrU_OpeZalId]       INT            NULL,
    [SrU_StaZalId]       INT            NULL,
    [SrU_TS_Zal]         DATETIME       NOT NULL,
    [SrU_OpeModId]       INT            NULL,
    [SrU_StaModId]       INT            NULL,
    [SrU_TS_Mod]         DATETIME       NOT NULL,
    [SrU_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_SrU_OpeModKod] DEFAULT ('') NOT NULL,
    [SrU_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SrU_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SrU_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_SrU_OpeZalKod] DEFAULT ('') NOT NULL,
    [SrU_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SrU_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SrU_Primary] PRIMARY KEY CLUSTERED ([SrU_SrUId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrUOdbiorca] FOREIGN KEY ([SrU_OdbID], [SrU_OdbiorcaTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_SrUPodmiot] FOREIGN KEY ([SrU_PodmiotId], [SrU_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE NONCLUSTERED INDEX [SrUTwrId]
    ON [CDN].[SrsUrzadzenia]([SrU_TwRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrUPodmiot]
    ON [CDN].[SrsUrzadzenia]([SrU_PodmiotId] ASC, [SrU_PodmiotTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrUKod]
    ON [CDN].[SrsUrzadzenia]([SrU_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrUNazwa]
    ON [CDN].[SrsUrzadzenia]([SrU_Nazwa] ASC, [SrU_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrUEAN]
    ON [CDN].[SrsUrzadzenia]([SrU_EAN] ASC, [SrU_SrUId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrURodzaj]
    ON [CDN].[SrsUrzadzenia]([SrU_SrRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrUOdbiorca]
    ON [CDN].[SrsUrzadzenia]([SrU_OdbID] ASC, [SrU_OdbiorcaTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.SrsUrzadzenia_Delete_Trigger
  ON CDN.SrsUrzadzenia
  FOR DELETE
AS
SET NOCOUNT ON
-- Skasowanie relacji do dokumentów z biblioteki
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=904 AND DoR_DokumentId=deleted.SrU_SrUId
SET NOCOUNT OFF
