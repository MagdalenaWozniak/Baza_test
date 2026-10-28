CREATE TABLE [CDN].[BnkRozRelacje] (
    [BRR_BRKID]   INT      NULL,
    [BRR_ZDokTyp] SMALLINT NULL,
    [BRR_ZDokID]  INT      NULL,
    [BRR_DDokTyp] SMALLINT NULL,
    [BRR_DDokID]  INT      NULL
);


GO
CREATE NONCLUSTERED INDEX [BRRRozKwoty]
    ON [CDN].[BnkRozRelacje]([BRR_BRKID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRRLZrodlo]
    ON [CDN].[BnkRozRelacje]([BRR_ZDokID] ASC, [BRR_ZDokTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkRozRelacje_InsertUpdateHandler
  ON CDN.BnkRozRelacje
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BRR_ZDokTyp=2)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkZapisy ON
                    inserted.BRR_ZDokID = CDN.BnkZapisy.BZp_BZpId
              WHERE CDN.BnkZapisy.BZp_BZpId IS NULL AND (inserted.BRR_ZDokTyp=2)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkZapisy##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BRR_ZDokTyp=1)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkZdarzenia ON
                    inserted.BRR_ZDokID = CDN.BnkZdarzenia.BZd_BZdId
              WHERE CDN.BnkZdarzenia.BZd_BZdId IS NULL AND (inserted.BRR_ZDokTyp=1)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkZdarzenia##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
