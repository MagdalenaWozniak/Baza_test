CREATE TABLE [CDN].[AnkWzorzecAnkietyNag] (
    [AnkWaN_AnkWaNId]       INT            IDENTITY (1, 1) NOT NULL,
    [AnkWaN_Kod]            NVARCHAR (250) NOT NULL,
    [AnkWaN_Nazwa]          NVARCHAR (512) NOT NULL,
    [AnkWaN_Opis]           NVARCHAR (MAX) NOT NULL,
    [AnkWaN_Nieaktywny]     TINYINT        NOT NULL,
    [AnkWaN_OpeZalID]       INT            NULL,
    [AnkWaN_StaZalId]       INT            NULL,
    [AnkWaN_TS_Zal]         DATETIME       NOT NULL,
    [AnkWaN_OpeModID]       INT            NULL,
    [AnkWaN_StaModId]       INT            NULL,
    [AnkWaN_TS_Mod]         DATETIME       NOT NULL,
    [AnkWaN_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_AnkWaN_OpeModKod] DEFAULT ('') NOT NULL,
    [AnkWaN_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_AnkWaN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AnkWaN_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_AnkWaN_OpeZalKod] DEFAULT ('') NOT NULL,
    [AnkWaN_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_AnkWaN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AnkWaN_Primary] PRIMARY KEY CLUSTERED ([AnkWaN_AnkWaNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AnkWaN_Kod_UniqueIx]
    ON [CDN].[AnkWzorzecAnkietyNag]([AnkWaN_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.AnkWzorzecAnkietyNag_Delete_Trigger
ON CDN.AnkWzorzecAnkietyNag
FOR DELETE
AS
SET NOCOUNT ON
-- relacje do dokumentów
DELETE CDN.DokRelacje FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=714 AND DoR_DokumentId IN (SELECT AnKWaN_AnkWaNId FROM deleted)
DELETE CDN.DokRelacje FROM CDN.DokRelacje JOIN deleted ON DoR_ParentTyp=714   AND DoR_ParentId   IN (SELECT AnKWaN_AnkWaNId FROM deleted)
SET NOCOUNT OFF
