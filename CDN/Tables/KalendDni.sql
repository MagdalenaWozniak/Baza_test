CREATE TABLE [CDN].[KalendDni] (
    [KAD_KadId]          INT           IDENTITY (1, 1) NOT NULL,
    [KAD_KalId]          INT           NOT NULL,
    [KAD_Data]           DATETIME      NOT NULL,
    [KAD_TypDnia]        INT           NOT NULL,
    [KAD_OpeZalId]       INT           NULL,
    [KAD_StaZalId]       INT           NULL,
    [KAD_TS_Zal]         DATETIME      NOT NULL,
    [KAD_OpeModId]       INT           NULL,
    [KAD_StaModId]       INT           NULL,
    [KAD_TS_Mod]         DATETIME      NOT NULL,
    [KAD_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_KAD_OpeModKod] DEFAULT ('') NOT NULL,
    [KAD_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_KAD_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KAD_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_KAD_OpeZalKod] DEFAULT ('') NOT NULL,
    [KAD_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_KAD_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [KAD_OdwId]          INT           NULL,
    CONSTRAINT [KAD_Primary] PRIMARY KEY CLUSTERED ([KAD_KadId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KADData] FOREIGN KEY ([KAD_KalId]) REFERENCES [CDN].[Kalendarze] ([KAL_KalId]) ON DELETE CASCADE,
    CONSTRAINT [FK_KADOdwLink] FOREIGN KEY ([KAD_OdwId]) REFERENCES [CDN].[OpisyDniWolne] ([ODW_OdwId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KADData]
    ON [CDN].[KalendDni]([KAD_KalId] ASC, [KAD_Data] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.KalendDni_DeleteHandler
  ON CDN.KalendDni
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
  SELECT * FROM CDN.KalendDniGodz INNER JOIN deleted ON
   deleted.KAD_KadId = CDN.KalendDniGodz.Kdg_KadId
   )
  DELETE CDN.KalendDniGodz
  FROM CDN.KalendDniGodz, deleted
  WHERE deleted.KAD_KadId = CDN.KalendDniGodz.KDG_KadId
SET NOCOUNT OFF
