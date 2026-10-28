CREATE TABLE [CDN].[AnkSlownikPytan] (
    [AnkSp_AnkSpId]              INT             IDENTITY (1, 1) NOT NULL,
    [AnkSp_Tresc]                NVARCHAR (1024) NOT NULL,
    [AnkSp_Opis]                 NVARCHAR (MAX)  NOT NULL,
    [AnkSp_AnkGpId]              INT             NULL,
    [AnkSp_TypPytania]           TINYINT         NOT NULL,
    [AnkSp_FormatPytOtwartego]   TINYINT         NOT NULL,
    [AnkSp_WielokrotnyWybor]     TINYINT         NOT NULL,
    [AnkSp_AnkSoNId]             INT             NULL,
    [AnkSp_Waga]                 INT             NOT NULL,
    [AnkSp_OdpWymagana]          TINYINT         NOT NULL,
    [AnkSp_Nieaktywne]           TINYINT         NOT NULL,
    [AnkSp_AktualizujSzablonOdp] TINYINT         NOT NULL,
    [AnkSp_OpeZalID]             INT             NULL,
    [AnkSp_StaZalId]             INT             NULL,
    [AnkSp_TS_Zal]               DATETIME        NOT NULL,
    [AnkSp_OpeModID]             INT             NULL,
    [AnkSp_StaModId]             INT             NULL,
    [AnkSp_TS_Mod]               DATETIME        NOT NULL,
    [AnkSp_OpeModKod]            VARCHAR (20)    CONSTRAINT [DF_AnkSp_OpeModKod] DEFAULT ('') NOT NULL,
    [AnkSp_OpeModNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_AnkSp_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AnkSp_OpeZalKod]            VARCHAR (20)    CONSTRAINT [DF_AnkSp_OpeZalKod] DEFAULT ('') NOT NULL,
    [AnkSp_OpeZalNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_AnkSp_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [AnkSp_AnkSonAuto]           INT             CONSTRAINT [DF_AnkSp_AnkSonAuto] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [AnkSp_Primary] PRIMARY KEY CLUSTERED ([AnkSp_AnkSpId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AnkSp_AnkGp] FOREIGN KEY ([AnkSp_AnkGpId]) REFERENCES [CDN].[AnkGrupyPytan] ([AnkGp_AnkGpId])
);


GO
CREATE TRIGGER CDN.AnkSlownikPytan_Delete_Trigger
ON CDN.AnkSlownikPytan
FOR DELETE
AS
 SET NOCOUNT ON
 DELETE FROM cdn.AnkSzablonOdpNag WHERE AnkSoN_Auto=1 AND AnkSoN_AnkSonId IN (SELECT d.AnkSp_AnkSonId FROM deleted d)
 SET NOCOUNT OFF
