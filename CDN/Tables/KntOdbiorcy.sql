CREATE TABLE [CDN].[KntOdbiorcy] (
    [Odb_OdbID]    INT     IDENTITY (1, 1) NOT NULL,
    [Odb_KntOdbID] INT     NULL,
    [Odb_OdbKntID] INT     NULL,
    [Odb_Domyslny] TINYINT NOT NULL,
    CONSTRAINT [Odb_Primary] PRIMARY KEY CLUSTERED ([Odb_OdbID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [KeyOdbKntID]
    ON [CDN].[KntOdbiorcy]([Odb_OdbKntID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KeyKntOdbID]
    ON [CDN].[KntOdbiorcy]([Odb_KntOdbID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.KntOdbiorcy_delete_Trigger
ON CDN.KntOdbiorcy
FOR DELETE
AS
BEGIN
 IF EXISTS( SELECT * FROM deleted LEFT OUTER JOIN CDN.Kontrahenci ON Odb_KntOdbID = Knt_KntId)
  UPDATE CDN.Kontrahenci
  SET Knt_TS_Export = NULL
  WHERE Knt_KntId in (SELECT Odb_KntOdbID FROM deleted)
END

GO
CREATE TRIGGER CDN.KntOdbiorcy_InsertUpdate_Trigger
ON CDN.KntOdbiorcy
FOR UPDATE, INSERT
AS
BEGIN
 IF EXISTS( SELECT * FROM inserted LEFT OUTER JOIN CDN.Kontrahenci ON Odb_KntOdbID = Knt_KntId)
  UPDATE CDN.Kontrahenci
  SET Knt_TS_Export = NULL
  WHERE Knt_KntId in (SELECT Odb_KntOdbID FROM inserted)
END
