CREATE TABLE [CDN].[SchematyOpakElem] (
    [SOE_SOEId] INT             IDENTITY (1, 1) NOT NULL,
    [SOE_SONId] INT             NULL,
    [SOE_Lp]    INT             NOT NULL,
    [SOE_TwrId] INT             NOT NULL,
    [SOE_Ilosc] DECIMAL (15, 4) NOT NULL,
    CONSTRAINT [SOE_Primary] PRIMARY KEY CLUSTERED ([SOE_SOEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SOENaglowek] FOREIGN KEY ([SOE_SONId]) REFERENCES [CDN].[SchematyOpakNag] ([SON_SONId]) ON DELETE CASCADE,
    CONSTRAINT [FK_SOETowar] FOREIGN KEY ([SOE_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SOENaglowek]
    ON [CDN].[SchematyOpakElem]([SOE_SONId] ASC, [SOE_SOEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SOETowar]
    ON [CDN].[SchematyOpakElem]([SOE_TwrId] ASC, [SOE_SOEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[SchematyOpakElem_InsertUpdateDelete_Trigger]
  ON CDN.SchematyOpakElem
  FOR INSERT, UPDATE, DELETE
AS
BEGIN
SET NOCOUNT ON
 IF EXISTS ( SELECT * FROM deleted )
  update CDN.SchematyOpakNag set SON_TS_Mod = getdate()
       where SON_SONId in (select SOE_SONId from deleted )
 IF EXISTS ( SELECT * FROM inserted )
  update CDN.SchematyOpakNag set SON_TS_Mod = getdate()
       where SON_SONId in (select SOE_SONId from inserted )
SET NOCOUNT OFF
END
