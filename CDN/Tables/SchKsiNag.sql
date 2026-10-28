CREATE TABLE [CDN].[SchKsiNag] (
    [SKN_SKNId]          INT             IDENTITY (1, 1) NOT NULL,
    [SKN_Typ]            SMALLINT        NOT NULL,
    [SKN_PodTyp]         SMALLINT        NOT NULL,
    [SKN_Symbol]         VARCHAR (20)    NOT NULL,
    [SKN_Nazwa]          NVARCHAR (50)   NOT NULL,
    [SKN_Uwagi]          NVARCHAR (255)  NOT NULL,
    [SKN_Dziennik]       VARCHAR (20)    NOT NULL,
    [SKN_Bufor]          TINYINT         NOT NULL,
    [SKN_DataDok]        NVARCHAR (1000) NOT NULL,
    [SKN_DataWys]        NVARCHAR (1000) NOT NULL,
    [SKN_DataOpe]        NVARCHAR (1000) NOT NULL,
    [SKN_Dokument]       VARCHAR (1000)  NOT NULL,
    [SKN_Opis]           NVARCHAR (1000) NOT NULL,
    [SKN_Warunek]        NVARCHAR (2000) NOT NULL,
    [SKN_DataKonfig]     TINYINT         NOT NULL,
    [SKN_DataKsi]        NVARCHAR (50)   NOT NULL,
    [SKN_NieAktywny]     TINYINT         NOT NULL,
    [SKN_BrakKontroli]   TINYINT         NOT NULL,
    [SKN_OpeZalID]       INT             NULL,
    [SKN_StaZalId]       INT             NULL,
    [SKN_TS_Zal]         DATETIME        NOT NULL,
    [SKN_OpeModID]       INT             NULL,
    [SKN_StaModId]       INT             NULL,
    [SKN_TS_Mod]         DATETIME        NOT NULL,
    [SKN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_SKN_OpeModKod] DEFAULT ('') NOT NULL,
    [SKN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_SKN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SKN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_SKN_OpeZalKod] DEFAULT ('') NOT NULL,
    [SKN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_SKN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SKN_Primary] PRIMARY KEY CLUSTERED ([SKN_SKNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SKNSymbol]
    ON [CDN].[SchKsiNag]([SKN_Typ] ASC, [SKN_PodTyp] ASC, [SKN_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.SchKsiNag_DeleteHandler
  ON CDN.SchKsiNag
  FOR DELETE
AS
SET NOCOUNT ON
    -- obsługa sprawdzania relacji restrict do tabeli CDN.DekretyNag
    IF EXISTS
       ( SELECT * FROM CDN.DekretyNag, deleted
          WHERE
                deleted.SKN_SKNId = CDN.DekretyNag.DeN_WzorzecId
       AND (CDN.DekretyNag.DeN_WzorzecTyp=21)
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=DekretyNag##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
SET NOCOUNT OFF
