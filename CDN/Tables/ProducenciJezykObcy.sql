CREATE TABLE [CDN].[ProducenciJezykObcy] (
    [PrdJ_PrdJID]            INT            IDENTITY (1, 1) NOT NULL,
    [PrdJ_PrdID]             INT            NOT NULL,
    [PrdJ_JezykID]           SMALLINT       CONSTRAINT [DF_PrdJ_JezykID] DEFAULT ((1)) NOT NULL,
    [PrdJ_OpisHTML]          NVARCHAR (MAX) NOT NULL,
    [PrdJ_OpisKrotki]        NVARCHAR (500) NOT NULL,
    [PrdJ_MetaTytul]         NVARCHAR (100) NOT NULL,
    [PrdJ_MetaSlowaKluczowe] NVARCHAR (500) NOT NULL,
    [PrdJ_MetaOpis]          NVARCHAR (320) NOT NULL,
    [PrdJ_NazwaNag]          NVARCHAR (250) NOT NULL,
    CONSTRAINT [PrdJ_Primary] PRIMARY KEY CLUSTERED ([PrdJ_PrdID] ASC, [PrdJ_JezykID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PrdJOdoProducenci] FOREIGN KEY ([PrdJ_PrdID]) REFERENCES [CDN].[Producenci] ([Prd_PrdId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrdJOID]
    ON [CDN].[ProducenciJezykObcy]([PrdJ_PrdJID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.ProducenciJezykObcy_InsertUpdate_Trigger
ON CDN.ProducenciJezykObcy
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  UPDATE CDN.Producenci SET Prd_TS_Mod  = GETDATE()
  where Prd_PrdId in ( select distinct PrdJ_PrdId From inserted)
  SET NOCOUNT OFF

GO
create TRIGGER [CDN].[ProducenciJezykObcy_Delete_Trigger]
  ON [CDN].[ProducenciJezykObcy]
  FOR DELETE
AS
SET NOCOUNT ON
  UPDATE CDN.Producenci SET Prd_TS_Mod  = GETDATE()
  where Prd_PrdId in ( select distinct PrdJ_PrdId From deleted)
SET NOCOUNT OFF
