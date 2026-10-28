CREATE TABLE [CDN].[AnkWzorzecAnkietyPyt] (
    [AnkWaP_AnkWaPId]           INT             IDENTITY (1, 1) NOT NULL,
    [AnkWaP_AnkWaNId]           INT             NOT NULL,
    [AnkWaP_Lp]                 INT             NOT NULL,
    [AnkWaP_Tresc]              NVARCHAR (1024) NOT NULL,
    [AnkWaP_Opis]               NVARCHAR (MAX)  NOT NULL,
    [AnkWaP_TypPytania]         TINYINT         NOT NULL,
    [AnkWaP_FormatPytOtwartego] TINYINT         NOT NULL,
    [AnkWaP_WielokrotnyWybor]   TINYINT         NOT NULL,
    [AnkWaP_AnkSoNId]           INT             NULL,
    [AnkWaP_Waga]               INT             NOT NULL,
    [AnkWaP_OdpWymagana]        TINYINT         NOT NULL,
    [AnkWaP_Nieaktywne]         TINYINT         NOT NULL,
    [AnkWaP_AnkSpId]            INT             NULL,
    [AnkWaP_AnkGpId]            INT             NOT NULL,
    [AnkWaP_GpTreeId]           INT             NOT NULL,
    [AnkWaP_GpParentId]         INT             NOT NULL,
    [AnkWaP_GpParentLp]         INT             NOT NULL,
    CONSTRAINT [AnkWaP_Primary] PRIMARY KEY CLUSTERED ([AnkWaP_AnkWaPId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AnkWaP_AnkWaN] FOREIGN KEY ([AnkWaP_AnkWaNId]) REFERENCES [CDN].[AnkWzorzecAnkietyNag] ([AnkWaN_AnkWaNId]) ON DELETE CASCADE
);

