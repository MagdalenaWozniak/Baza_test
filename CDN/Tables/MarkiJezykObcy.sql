CREATE TABLE [CDN].[MarkiJezykObcy] (
    [MrkJ_MrkJID]            INT            IDENTITY (1, 1) NOT NULL,
    [MrkJ_MrkID]             INT            NOT NULL,
    [MrkJ_JezykID]           SMALLINT       CONSTRAINT [DF_MrkJ_JezykID] DEFAULT ((1)) NOT NULL,
    [MrkJ_OpisHTML]          NVARCHAR (MAX) NOT NULL,
    [MrkJ_OpisKrotki]        NVARCHAR (500) NOT NULL,
    [MrkJ_MetaTytul]         NVARCHAR (100) NOT NULL,
    [MrkJ_MetaSlowaKluczowe] NVARCHAR (500) NOT NULL,
    [MrkJ_MetaOpis]          NVARCHAR (320) NOT NULL,
    [MrkJ_NazwaNag]          NVARCHAR (250) NOT NULL,
    CONSTRAINT [MrkJ_Primary] PRIMARY KEY CLUSTERED ([MrkJ_MrkID] ASC, [MrkJ_JezykID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_MrkJOdoMarki] FOREIGN KEY ([MrkJ_MrkID]) REFERENCES [CDN].[Marki] ([Mrk_MrkId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MrkJOID]
    ON [CDN].[MarkiJezykObcy]([MrkJ_MrkJID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.MarkiJezykObcy_InsertUpdate_Trigger
ON CDN.MarkiJezykObcy
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  UPDATE CDN.Marki SET Mrk_TS_Mod  =GETDATE()
  where Mrk_MrkId in ( select distinct MrkJ_MrkId From inserted)
  SET NOCOUNT OFF

GO
CREATE TRIGGER [CDN].[MarkiJezykObcy_Delete_Trigger]
  ON [CDN].[MarkiJezykObcy]
  FOR DELETE
AS
SET NOCOUNT ON
  UPDATE CDN.Marki SET Mrk_TS_Mod  =GETDATE()
  where Mrk_MrkId in ( select distinct MrkJ_MrkId From deleted)
SET NOCOUNT OFF
