CREATE TABLE [CDN].[AutoKoszty] (
    [AuK_AuKID]          INT             IDENTITY (1, 1) NOT NULL,
    [AuK_AuEID]          INT             NOT NULL,
    [AuK_RokMies]        INT             NOT NULL,
    [AuK_Lp]             INT             NOT NULL,
    [AuK_VaNId]          INT             NULL,
    [AuK_DataZap]        DATETIME        NOT NULL,
    [AuK_Dokument]       VARCHAR (256)   NOT NULL,
    [AuK_KatId]          INT             NULL,
    [AuK_Kategoria]      VARCHAR (50)    NOT NULL,
    [AuK_Wartosc]        DECIMAL (15, 2) NOT NULL,
    [AuK_OpeZalID]       INT             NULL,
    [AuK_StaZalId]       INT             NULL,
    [AuK_TS_Zal]         DATETIME        NOT NULL,
    [AuK_OpeModID]       INT             NULL,
    [AuK_StaModId]       INT             NULL,
    [AuK_TS_Mod]         DATETIME        NOT NULL,
    [AuK_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_AuK_OpeModKod] DEFAULT ('') NOT NULL,
    [AuK_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_AuK_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AuK_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_AuK_OpeZalKod] DEFAULT ('') NOT NULL,
    [AuK_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_AuK_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AuK_Primary] PRIMARY KEY CLUSTERED ([AuK_AuKID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AuKKategoria] FOREIGN KEY ([AuK_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_AuKLp] FOREIGN KEY ([AuK_AuEID]) REFERENCES [CDN].[AutoEwid] ([AuE_AuEID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuKLp]
    ON [CDN].[AutoKoszty]([AuK_AuEID] ASC, [AuK_RokMies] ASC, [AuK_Lp] ASC, [AuK_AuKID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuKChrono]
    ON [CDN].[AutoKoszty]([AuK_AuEID] ASC, [AuK_RokMies] ASC, [AuK_DataZap] ASC, [AuK_AuKID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AuKVatNag]
    ON [CDN].[AutoKoszty]([AuK_VaNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuKKategoria]
    ON [CDN].[AutoKoszty]([AuK_KatId] ASC, [AuK_DataZap] ASC, [AuK_AuKID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.AutoKoszty_InsertUpdateDelete_Trigger
  ON CDN.AutoKoszty
  FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
--Ustalenie wartości RokMies
  IF EXISTS (SELECT * FROM inserted
             WHERE inserted.AuK_RokMies <> 100 *  YEAR(inserted.AuK_DataZap)
                                         + MONTH(inserted.AuK_DataZap))
    BEGIN
      UPDATE CDN.AutoKoszty
      SET
      CDN.AutoKoszty.AuK_RokMies =
            100 *  YEAR(CDN.AutoKoszty.AuK_DataZap)
            + MONTH(CDN.AutoKoszty.AuK_DataZap)
      FROM  CDN.AutoKoszty JOIN inserted
      ON    CDN.AutoKoszty.AuK_AuKId = inserted.AuK_AuKId
      WHERE CDN.AutoKoszty.AuK_RokMies <> 100 *  YEAR(CDN.AutoKoszty.AuK_DataZap)
                                        + MONTH(CDN.AutoKoszty.AuK_DataZap);
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32020##%%1%%=AutoKoszty##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
--Ustalenie wartości Lp
IF EXISTS (SELECT * FROM inserted)
BEGIN
  DECLARE @lp INT, @AuEID INT, @RokMies INT
  SELECT @AuEID = AuK_AuEID, @RokMies = AuK_RokMies FROM inserted
  SELECT @lp = MAX(AuK_Lp)+1 FROM CDN.AutoKoszty WHERE AuK_AuEID=@AuEID AND AuK_RokMies = @RokMies
  UPDATE CDN.AutoKoszty
      SET
      CDN.AutoKoszty.AuK_Lp = @lp
      FROM  CDN.AutoKoszty JOIN inserted
      ON    CDN.AutoKoszty.AuK_AuKId = inserted.AuK_AuKId
      WHERE inserted.AuK_Lp = 0
 IF @@ERROR <> 0
    BEGIN
  RAISERROR('##OPT32021##%%1%%=AutoKoszty##', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    END
END
-- Sprawdzenie, czy miesiąc nie jest rozliczony (insert, update)
  IF EXISTS (SELECT * FROM inserted
             JOIN   CDN.AutoRozlicz
             ON     inserted.AuK_AuEId   = CDN.AutoRozlicz.AuR_AuEId
                AND inserted.AuK_RokMies = CDN.AutoRozlicz.AuR_RokMies)
    BEGIN
      RAISERROR('##OPT32022##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy miesiąc nie jest rozliczony (delete, update)
  IF EXISTS (SELECT * FROM deleted
             JOIN   CDN.AutoRozlicz
             ON     deleted.AuK_AuEId = CDN.AutoRozlicz.AuR_AuEId
                AND deleted.AuK_RokMies = CDN.AutoRozlicz.AuR_RokMies
             WHERE  deleted.AuK_Wartosc <> 0)
    BEGIN
      RAISERROR('##OPT32022##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    SET NOCOUNT OFF
