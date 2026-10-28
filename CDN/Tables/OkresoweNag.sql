CREATE TABLE [CDN].[OkresoweNag] (
    [OkN_OkNId]          INT             IDENTITY (1, 1) NOT NULL,
    [OkN_Symbol]         VARCHAR (20)    NOT NULL,
    [OkN_Nazwa]          NVARCHAR (50)   NOT NULL,
    [OkN_Uwagi]          NVARCHAR (255)  NOT NULL,
    [OkN_Dziennik]       VARCHAR (20)    NOT NULL,
    [OkN_Bufor]          TINYINT         NOT NULL,
    [OkN_Dokument]       VARCHAR (256)   NOT NULL,
    [OkN_KatId]          INT             NULL,
    [OkN_Kategoria]      VARCHAR (50)    NOT NULL,
    [OkN_Warunek]        NVARCHAR (1000) NOT NULL,
    [OkN_NieAktywny]     TINYINT         CONSTRAINT [DF_OkN_NieAktywny] DEFAULT ((0)) NOT NULL,
    [OkN_Harmonogram]    TINYINT         CONSTRAINT [DF_OkN_Harmonogram] DEFAULT ((0)) NOT NULL,
    [OkN_ZakresDat]      TINYINT         CONSTRAINT [DF_OkN_ZakresDat] DEFAULT ((0)) NOT NULL,
    [OkN_DataOd]         DATETIME        NULL,
    [OkN_DataDo]         DATETIME        NULL,
    [OkN_TS_Ksi]         DATETIME        NULL,
    [OkN_OpeZalID]       INT             NULL,
    [OkN_StaZalId]       INT             NULL,
    [OkN_TS_Zal]         DATETIME        NOT NULL,
    [OkN_OpeModID]       INT             NULL,
    [OkN_StaModId]       INT             NULL,
    [OkN_TS_Mod]         DATETIME        NOT NULL,
    [OkN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_OkN_OpeModKod] DEFAULT ('') NOT NULL,
    [OkN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_OkN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [OkN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_OkN_OpeZalKod] DEFAULT ('') NOT NULL,
    [OkN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_OkN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [OkN_Primary] PRIMARY KEY CLUSTERED ([OkN_OkNId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OkNKategoria] FOREIGN KEY ([OkN_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OkNSymbol]
    ON [CDN].[OkresoweNag]([OkN_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [OkNKategoria]
    ON [CDN].[OkresoweNag]([OkN_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [OkNNieAktywany]
    ON [CDN].[OkresoweNag]([OkN_NieAktywny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.OkresoweNag_DeleteHandler
  ON CDN.OkresoweNag
  FOR DELETE
AS
SET NOCOUNT ON
    -- obsługa sprawdzania relacji restrict do tabeli CDN.DekretyNag
    IF EXISTS
       ( SELECT * FROM CDN.DekretyNag, deleted
          WHERE
                deleted.OkN_OkNId = CDN.DekretyNag.DeN_WzorzecId
       AND (CDN.DekretyNag.DeN_WzorzecTyp=22)
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=DekretyNag##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
SET NOCOUNT OFF
