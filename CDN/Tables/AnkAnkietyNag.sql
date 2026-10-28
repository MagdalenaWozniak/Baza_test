CREATE TABLE [CDN].[AnkAnkietyNag] (
    [AnkAnN_AnkAnNId]            INT             IDENTITY (1, 1) NOT NULL,
    [AnkAnN_DDfId]               INT             NOT NULL,
    [AnkAnN_NumerString]         VARCHAR (31)    NOT NULL,
    [AnkAnN_NumerPelny]          AS              ([CDN].[FN_NUMERPELNY]([AnkAnN_NumerNr],[AnkAnN_NumerString])),
    [AnkAnN_NumerNr]             INT             NOT NULL,
    [AnkAnN_DataDok]             DATETIME        NOT NULL,
    [AnkAnN_Stan]                INT             NOT NULL,
    [AnkAnN_PrzyczynaOdrzucenia] NVARCHAR (512)  NOT NULL,
    [AnkAnN_AnkWaNId]            INT             NULL,
    [AnkAnN_Nazwa]               NVARCHAR (512)  NOT NULL,
    [AnkAnN_Opis]                NVARCHAR (MAX)  NOT NULL,
    [AnkAnN_PodmiotTyp]          SMALLINT        NOT NULL,
    [AnkAnN_PodID]               INT             NOT NULL,
    [AnkAnN_OsobaId]             INT             NULL,
    [AnkAnN_OsobaTelefon]        VARCHAR (20)    NOT NULL,
    [AnkAnN_OsobaNazwisko]       NVARCHAR (40)   NOT NULL,
    [AnkAnN_TerminOd]            DATETIME        NOT NULL,
    [AnkAnN_TerminDo]            DATETIME        NOT NULL,
    [AnkAnN_Ocena]               DECIMAL (15, 2) NOT NULL,
    [AnkAnN_DataWypelnienia]     DATETIME        NULL,
    [AnkAnN_DataZatwierdzenia]   DATETIME        NULL,
    [AnkAnN_OpeZalID]            INT             NULL,
    [AnkAnN_StaZalId]            INT             NULL,
    [AnkAnN_TS_Zal]              DATETIME        NOT NULL,
    [AnkAnN_OpeModID]            INT             NULL,
    [AnkAnN_StaModId]            INT             NULL,
    [AnkAnN_TS_Mod]              DATETIME        NOT NULL,
    [AnkAnN_OpeModKod]           VARCHAR (20)    CONSTRAINT [DF_AnkAnN_OpeModKod] DEFAULT ('') NOT NULL,
    [AnkAnN_OpeModNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_AnkAnN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AnkAnN_OpeZalKod]           VARCHAR (20)    CONSTRAINT [DF_AnkAnN_OpeZalKod] DEFAULT ('') NOT NULL,
    [AnkAnN_OpeZalNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_AnkAnN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [AnkAnN_Eksport]             INT             NULL,
    CONSTRAINT [AnkAnN_Primary] PRIMARY KEY CLUSTERED ([AnkAnN_AnkAnNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AnkAnNNumer]
    ON [CDN].[AnkAnkietyNag]([AnkAnN_NumerString] ASC, [AnkAnN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.AnkAnkietyNag_Delete_Trigger
ON CDN.AnkAnkietyNag
FOR DELETE
AS
SET NOCOUNT ON
-- obsługa kasowania załączników
DELETE FROM CDN.DaneBinarneLinki WHERE DBL_DokumentTyp=710 AND DBL_DokumentId IN (SELECT DBL_DBLId FROM deleted)
-- relacje do dokumentów
DELETE CDN.DokRelacje FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=710 AND DoR_DokumentId IN (SELECT AnKAnN_AnkAnNId FROM deleted)
DELETE CDN.DokRelacje FROM CDN.DokRelacje JOIN deleted ON DoR_ParentTyp=710   AND DoR_ParentId   IN (SELECT AnKAnN_AnkAnNId FROM deleted)
SET NOCOUNT OFF
