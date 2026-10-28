CREATE TABLE [CDN].[KodyCN] (
    [KCN_KCNId]          INT             IDENTITY (1, 1) NOT NULL,
    [KCN_Kod]            VARCHAR (8)     NOT NULL,
    [KCN_Opis]           NVARCHAR (1024) NOT NULL,
    [KCN_UzupJM]         NVARCHAR (20)   NOT NULL,
    [KCN_Masa]           TINYINT         NOT NULL,
    [KCN_OpeZalId]       INT             NULL,
    [KCN_StaZalId]       INT             NULL,
    [KCN_TS_Zal]         DATETIME        NOT NULL,
    [KCN_OpeModId]       INT             NULL,
    [KCN_StaModId]       INT             NULL,
    [KCN_TS_Mod]         DATETIME        NOT NULL,
    [KCN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_KCN_OpeModKod] DEFAULT ('') NOT NULL,
    [KCN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_KCN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KCN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_KCN_OpeZalKod] DEFAULT ('') NOT NULL,
    [KCN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_KCN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [KCN_Sent]           INT             CONSTRAINT [DF_KCN_Sent] DEFAULT ((0)) NOT NULL,
    [KCN_KodSent]        VARCHAR (4)     CONSTRAINT [DF_KCN_KodSent] DEFAULT ('') NOT NULL,
    [KCN_JMSent]         NVARCHAR (20)   CONSTRAINT [DF_KCN_JMSent] DEFAULT ('') NOT NULL,
    [KCN_Stawka]         DECIMAL (5, 2)  NULL,
    [KCN_Flaga]          SMALLINT        NULL,
    [KCN_Zrodlowa]       DECIMAL (5, 2)  NULL,
    CONSTRAINT [KCN_Primary] PRIMARY KEY CLUSTERED ([KCN_KCNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KCNKod]
    ON [CDN].[KodyCN]([KCN_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.KodyCN_Update_Trigger
  ON CDN.KodyCN
  FOR Update
AS
SET NOCOUNT ON
IF UPDATE (KCN_Kod)
  IF EXISTS (Select * From deleted Where KCN_Kod='99500000')
    BEGIN
      RAISERROR('##OPT34514##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.KodyCN_Delete_Trigger
  ON CDN.KodyCN
  FOR DELETE
AS
SET NOCOUNT ON
IF EXISTS (Select * From deleted Where KCN_Kod='99500000')
    BEGIN
      RAISERROR('##OPT34514##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
SET NOCOUNT OFF
