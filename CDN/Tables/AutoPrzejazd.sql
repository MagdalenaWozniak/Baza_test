CREATE TABLE [CDN].[AutoPrzejazd] (
    [AuP_AuPID]          INT             IDENTITY (1, 1) NOT NULL,
    [AuP_AuEID]          INT             NOT NULL,
    [AuP_RokMies]        INT             NOT NULL,
    [AuP_Lp]             INT             NOT NULL,
    [AuP_DataZap]        DATETIME        NOT NULL,
    [AuP_AuTId]          INT             NULL,
    [AuP_Trasa]          NVARCHAR (1000) NULL,
    [AuP_Cel]            NVARCHAR (50)   NOT NULL,
    [AuP_Dlugosc]        DECIMAL (7, 2)  NOT NULL,
    [AuP_Miasto]         TINYINT         NOT NULL,
    [AuP_Stawka]         DECIMAL (7, 4)  NOT NULL,
    [AuP_OpeZalID]       INT             NULL,
    [AuP_StaZalId]       INT             NULL,
    [AuP_TS_Zal]         DATETIME        NOT NULL,
    [AuP_OpeModID]       INT             NULL,
    [AuP_StaModId]       INT             NULL,
    [AuP_TS_Mod]         DATETIME        NOT NULL,
    [AuP_PoczStanL]      DECIMAL (14, 2) NULL,
    [AuP_KonStanL]       DECIMAL (14, 2) NULL,
    [AuP_PrcId]          INT             NULL,
    [AuP_PrcNazwisko]    NVARCHAR (100)  NULL,
    [AuP_PrcAdres]       NVARCHAR (100)  NULL,
    [AuP_PrcTyp]         INT             NULL,
    [AuP_OpiekunTyp]     INT             NULL,
    [AuP_OpiekunId]      INT             NULL,
    [AuP_Potwierdzil]    INT             CONSTRAINT [DF_AuP_Potwierdzil] DEFAULT ((0)) NOT NULL,
    [AuP_DataPotw]       DATETIME        NULL,
    [AuP_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_AuP_OpeModKod] DEFAULT ('') NOT NULL,
    [AuP_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_AuP_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AuP_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_AuP_OpeZalKod] DEFAULT ('') NOT NULL,
    [AuP_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_AuP_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AuP_Primary] PRIMARY KEY CLUSTERED ([AuP_AuPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AuPAutoTrasa] FOREIGN KEY ([AuP_AuTId]) REFERENCES [CDN].[AutoTrasy] ([AuT_AuTID]),
    CONSTRAINT [FK_AuPLp] FOREIGN KEY ([AuP_AuEID]) REFERENCES [CDN].[AutoEwid] ([AuE_AuEID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuPAutoTrasa]
    ON [CDN].[AutoPrzejazd]([AuP_AuTId] ASC, [AuP_DataZap] ASC, [AuP_AuPID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuPLp]
    ON [CDN].[AutoPrzejazd]([AuP_AuEID] ASC, [AuP_RokMies] ASC, [AuP_Lp] ASC, [AuP_AuPID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuPChrono]
    ON [CDN].[AutoPrzejazd]([AuP_AuEID] ASC, [AuP_RokMies] ASC, [AuP_DataZap] ASC, [AuP_AuPID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.AutoPrzejazd_InsertUpdateDelete_Trigger
  ON CDN.AutoPrzejazd
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
--Ustalenie wartości RokMies
  IF EXISTS (SELECT * FROM inserted
             WHERE inserted.AuP_RokMies <> 100 *  YEAR(inserted.AuP_DataZap)
                                         + MONTH(inserted.AuP_DataZap))
    BEGIN
      UPDATE CDN.AutoPrzejazd
      SET
      CDN.AutoPrzejazd.AuP_RokMies =
            100 *  YEAR(CDN.AutoPrzejazd.AuP_DataZap)
            + MONTH(CDN.AutoPrzejazd.AuP_DataZap)
      FROM  CDN.AutoPrzejazd JOIN inserted
      ON    CDN.AutoPrzejazd.AuP_AuPId = inserted.AuP_AuPId
      WHERE CDN.AutoPrzejazd.AuP_RokMies <> 100 *  YEAR(CDN.AutoPrzejazd.AuP_DataZap)
            + MONTH(CDN.AutoPrzejazd.AuP_DataZap);
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32020##%%1%%=AutoPrzejazd##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
--Ustalenie wartości Lp
IF EXISTS (SELECT * FROM inserted)
BEGIN
  DECLARE @lp INT, @AuEID INT, @RokMies INT
  SELECT @AuEID = AuP_AuEID, @RokMies = AuP_RokMies FROM inserted
  SELECT @lp = MAX(AuP_Lp)+1 FROM CDN.AutoPrzejazd WHERE AuP_AuEID=@AuEID AND AuP_RokMies = @RokMies
  UPDATE CDN.AutoPrzejazd
      SET
      CDN.AutoPrzejazd.AuP_Lp = @lp
      FROM  CDN.AutoPrzejazd JOIN inserted
      ON    CDN.AutoPrzejazd.AuP_AuPId = inserted.AuP_AuPId
      WHERE inserted.AuP_Lp = 0
 IF @@ERROR <> 0
    BEGIN
  RAISERROR('##OPT32021##%%1%%=AutoPrzejazd##', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    END
END
-- Sprawdzenie, czy miesiąc nie jest rozliczony (insert, update)
  IF EXISTS (SELECT * FROM inserted
             JOIN   CDN.AutoRozlicz
             ON     inserted.AuP_AuEId   = CDN.AutoRozlicz.AuR_AuEId
                AND inserted.AuP_RokMies = CDN.AutoRozlicz.AuR_RokMies)
    BEGIN
      RAISERROR('##OPT32022##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy miesiąc nie jest rozliczony (delete, update)
  IF EXISTS (SELECT * FROM deleted
             JOIN   CDN.AutoRozlicz
             ON     deleted.AuP_AuEId   = CDN.AutoRozlicz.AuR_AuEId
                AND deleted.AuP_RokMies = CDN.AutoRozlicz.AuR_RokMies
             WHERE  deleted.AuP_Dlugosc <> 0)
    BEGIN
      RAISERROR('##OPT32022##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
