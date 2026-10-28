CREATE TABLE [CDN].[TrwaleCzesci] (
    [SrTC_SrtCID]   INT IDENTITY (1, 1) NOT NULL,
    [SrTC_ZestawID] INT NULL,
    [SrTC_CzescID]  INT NULL,
    CONSTRAINT [SrTC_Primary] PRIMARY KEY CLUSTERED ([SrTC_SrtCID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrTCZestaw] FOREIGN KEY ([SrTC_ZestawID]) REFERENCES [CDN].[Trwale] ([SrT_SrTID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTCZestaw]
    ON [CDN].[TrwaleCzesci]([SrTC_ZestawID] ASC, [SrTC_CzescID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TrwaleCzesci_InsertUpdateDelete_Trigger
  ON CDN.TrwaleCzesci
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
  IF EXISTS (SELECT * FROM inserted JOIN CDN.Trwale ON SrT_SrTID = inserted.SrTC_ZestawID WHERE SrT_Rodzaj<>1)
    BEGIN
      RAISERROR('##OPT32367##', 16, 1) -- RAISERROR('Nie można podłączać części do środka nie będącego zestawem.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM inserted JOIN CDN.Trwale ON SrT_SrTID = inserted.SrTC_CzescID WHERE SrT_Rodzaj<>2)
    BEGIN
      RAISERROR('##OPT32368##', 16, 1) -- RAISERROR('Nie można podłączać do zestawu środków nie będących częściami.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  UPDATE CDN.Trwale SET SrT_WZestawie = 1 WHERE SrT_SrTID IN (SELECT inserted.SrTC_CzescID FROM inserted)
  UPDATE CDN.Trwale SET SrT_WZestawie = 0 WHERE SrT_SrTID IN (SELECT deleted.SrTC_CzescID FROM deleted)
  SET NOCOUNT OFF
