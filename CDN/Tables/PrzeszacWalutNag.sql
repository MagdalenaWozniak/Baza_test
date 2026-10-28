CREATE TABLE [CDN].[PrzeszacWalutNag] (
    [PWN_PWNID]          INT             IDENTITY (1, 1) NOT NULL,
    [PWN_OObId]          INT             NOT NULL,
    [PWN_NextOObId]      INT             NULL,
    [PWN_Bufor]          TINYINT         NOT NULL,
    [PWN_PrzezBufor]     TINYINT         NOT NULL,
    [PWN_DataDok]        DATETIME        NOT NULL,
    [PWN_Numer]          NVARCHAR (256)  NOT NULL,
    [PWN_KatID]          INT             NULL,
    [PWN_Kategoria]      VARCHAR (50)    NOT NULL,
    [PWN_Waluta]         VARCHAR (3)     NOT NULL,
    [PWN_KursNumer]      INT             NOT NULL,
    [PWN_KursL]          DECIMAL (15, 4) NOT NULL,
    [PWN_KursM]          DECIMAL (5)     NOT NULL,
    [PWN_AccWnId]        INT             NOT NULL,
    [PWN_AccMaId]        INT             NOT NULL,
    [PWN_KontoWn]        VARCHAR (50)    NOT NULL,
    [PWN_KontoMa]        VARCHAR (50)    NOT NULL,
    [PWN_DziID]          INT             NULL,
    [PWN_NextDziID]      INT             NULL,
    [PWN_Dziennik]       VARCHAR (20)    NULL,
    [PWN_NextDziennik]   VARCHAR (20)    NULL,
    [PWN_DekID]          INT             NULL,
    [PWN_NextDekID]      INT             NULL,
    [PWN_OpeZalID]       INT             NULL,
    [PWN_StaZalId]       INT             NULL,
    [PWN_TS_Zal]         DATETIME        NOT NULL,
    [PWN_OpeModID]       INT             NULL,
    [PWN_StaModId]       INT             NULL,
    [PWN_TS_Mod]         DATETIME        NOT NULL,
    [PWN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_PWN_OpeModKod] DEFAULT ('') NOT NULL,
    [PWN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_PWN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PWN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_PWN_OpeZalKod] DEFAULT ('') NOT NULL,
    [PWN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_PWN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PWN_Primary] PRIMARY KEY CLUSTERED ([PWN_PWNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PWNKontoMa] FOREIGN KEY ([PWN_AccMaId]) REFERENCES [CDN].[Konta] ([Acc_AccId]),
    CONSTRAINT [FK_PWNKontoWn] FOREIGN KEY ([PWN_AccWnId]) REFERENCES [CDN].[Konta] ([Acc_AccId])
);


GO
CREATE NONCLUSTERED INDEX [PWNOkres]
    ON [CDN].[PrzeszacWalutNag]([PWN_OObId] ASC, [PWN_NextOObId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWNBufor]
    ON [CDN].[PrzeszacWalutNag]([PWN_Bufor] ASC, [PWN_PrzezBufor] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWNWaluta]
    ON [CDN].[PrzeszacWalutNag]([PWN_Waluta] ASC, [PWN_KursNumer] ASC, [PWN_KursL] ASC, [PWN_KursM] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWNDokument]
    ON [CDN].[PrzeszacWalutNag]([PWN_DataDok] ASC, [PWN_Numer] ASC, [PWN_Dziennik] ASC, [PWN_DziID] ASC, [PWN_NextDziennik] ASC, [PWN_NextDziID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWNKonto]
    ON [CDN].[PrzeszacWalutNag]([PWN_AccWnId] ASC, [PWN_KontoWn] ASC, [PWN_AccMaId] ASC, [PWN_KontoMa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWNDekret]
    ON [CDN].[PrzeszacWalutNag]([PWN_DekID] ASC, [PWN_NextDekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWNKategoria]
    ON [CDN].[PrzeszacWalutNag]([PWN_KatID] ASC, [PWN_Kategoria] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWNView]
    ON [CDN].[PrzeszacWalutNag]([PWN_DataDok] ASC, [PWN_PWNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.PrzeszacWalutNag_Delete_Trigger
  ON CDN.PrzeszacWalutNag
  FOR DELETE
AS
  SET NOCOUNT ON
  IF EXISTS (SELECT * FROM deleted where deleted.PWN_Bufor=0)
    BEGIN
   exec CDN.RiseOptimaException 32645
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM deleted where deleted.PWN_DekID<>0 or deleted.PWN_NextDekID <> 0)
    BEGIN
   exec CDN.RiseOptimaException 32646
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
