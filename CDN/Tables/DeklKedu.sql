CREATE TABLE [CDN].[DeklKedu] (
    [DKK_DkkId]          INT            IDENTITY (1, 1) NOT NULL,
    [DKK_Data]           DATETIME       NOT NULL,
    [DKK_Nazwa]          VARCHAR (72)   NOT NULL,
    [DKK_Opis]           NVARCHAR (254) NOT NULL,
    [DKK_Zablokowana]    TINYINT        NOT NULL,
    [DKK_OpeZalId]       INT            NULL,
    [DKK_StaZalId]       INT            NULL,
    [DKK_TS_Zal]         DATETIME       NOT NULL,
    [DKK_OpeModId]       INT            NULL,
    [DKK_StaModId]       INT            NULL,
    [DKK_TS_Mod]         DATETIME       NOT NULL,
    [DKK_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_DKK_OpeModKod] DEFAULT ('') NOT NULL,
    [DKK_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_DKK_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DKK_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_DKK_OpeZalKod] DEFAULT ('') NOT NULL,
    [DKK_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_DKK_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [DKK_Primary] PRIMARY KEY CLUSTERED ([DKK_DkkId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DkkNazwa]
    ON [CDN].[DeklKedu]([DKK_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DeklKedu_Delete_Trigger
  ON CDN.DeklKedu
  FOR DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy deklaracja zostala zablokowana
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.DKK_Zablokowana = 1)
    BEGIN
      RAISERROR('##OPT34692##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
