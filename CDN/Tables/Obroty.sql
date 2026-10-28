CREATE TABLE [CDN].[Obroty] (
    [Obr_AccId]            INT             NOT NULL,
    [Obr_RokMies]          INT             NULL,
    [Obr_Typ]              TINYINT         NOT NULL,
    [Obr_ObrotyWn]         DECIMAL (15, 2) NOT NULL,
    [Obr_ObrotyMa]         DECIMAL (15, 2) NOT NULL,
    [Obr_ObrotyWnBufor]    DECIMAL (15, 2) NOT NULL,
    [Obr_ObrotyMaBufor]    DECIMAL (15, 2) NOT NULL,
    [Obr_ObrotyWnWal]      DECIMAL (15, 2) NOT NULL,
    [Obr_ObrotyMaWal]      DECIMAL (15, 2) NOT NULL,
    [Obr_ObrotyWnBuforWal] DECIMAL (15, 2) NOT NULL,
    [Obr_ObrotyMaBuforWal] DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [FK_ObrKonto] FOREIGN KEY ([Obr_AccId]) REFERENCES [CDN].[Konta] ([Acc_AccId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ObrKonto]
    ON [CDN].[Obroty]([Obr_AccId] ASC, [Obr_Typ] ASC, [Obr_RokMies] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ObrData]
    ON [CDN].[Obroty]([Obr_Typ] ASC, [Obr_RokMies] ASC, [Obr_AccId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Obroty_InsertUpdateDelete_Trigger
  ON CDN.Obroty
  FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
IF EXISTS (
          SELECT * FROM CDN.Konta JOIN CDN.OkresyObrach ON OOb_OObId = Acc_OObId
           WHERE OOb_Stan = 1
             AND Acc_AccId IN (SELECT Obr_AccId FROM deleted UNION SELECT Obr_AccId FROM inserted)
          )
  BEGIN
 exec CDN.RiseOptimaException 32634
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
SET NOCOUNT OFF
