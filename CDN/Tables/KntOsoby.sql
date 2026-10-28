CREATE TABLE [CDN].[KntOsoby] (
    [KnO_KnOId]            INT            IDENTITY (1, 1) NOT NULL,
    [KnO_KntId]            INT            NOT NULL,
    [KnO_Tytul]            NVARCHAR (255) NOT NULL,
    [KnO_Plec]             TINYINT        NOT NULL,
    [KnO_Nazwisko]         NVARCHAR (40)  NOT NULL,
    [KnO_Kraj]             NVARCHAR (40)  NOT NULL,
    [KnO_Wojewodztwo]      NVARCHAR (40)  NOT NULL,
    [KnO_Powiat]           NVARCHAR (40)  NOT NULL,
    [KnO_Gmina]            NVARCHAR (40)  NOT NULL,
    [KnO_Ulica]            NVARCHAR (40)  NOT NULL,
    [KnO_NrDomu]           NVARCHAR (10)  NOT NULL,
    [KnO_NrLokalu]         NVARCHAR (10)  NOT NULL,
    [KnO_Miasto]           NVARCHAR (40)  NOT NULL,
    [KnO_KodPocztowy]      VARCHAR (10)   NOT NULL,
    [KnO_Poczta]           NVARCHAR (40)  NOT NULL,
    [KnO_Adres2]           NVARCHAR (256) NOT NULL,
    [KnO_Telefon]          VARCHAR (20)   NOT NULL,
    [KnO_TelefonSms]       VARCHAR (20)   CONSTRAINT [DF_KnO_TelefonSms] DEFAULT ('') NOT NULL,
    [KnO_GSM]              VARCHAR (20)   NOT NULL,
    [KnO_Email]            NVARCHAR (60)  NOT NULL,
    [KnO_Mailing]          TINYINT        CONSTRAINT [DF_KnO_Mailing] DEFAULT ((1)) NOT NULL,
    [KnO_Informacje]       TINYINT        NOT NULL,
    [KnO_Domyslny]         TINYINT        NOT NULL,
    [KnO_Nieaktywny]       TINYINT        CONSTRAINT [DF_KnO_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [KnO_LpAnonimizacji]   INT            CONSTRAINT [DF_KnO_LpAnonimizacji] DEFAULT ((0)) NOT NULL,
    [KnO_DataAnonimizacji] DATETIME       NULL,
    [KnO_OpeZalId]         INT            NULL,
    [KnO_StaZalId]         INT            NULL,
    [KnO_TS_Zal]           DATETIME       CONSTRAINT [DF_KnO_TS_Zal] DEFAULT (getdate()) NOT NULL,
    [KnO_OpeModId]         INT            NULL,
    [KnO_StaModId]         INT            NULL,
    [KnO_TS_Mod]           DATETIME       CONSTRAINT [DF_KnO_TS_Mod] DEFAULT (getdate()) NOT NULL,
    [KnO_OpeModKod]        VARCHAR (20)   CONSTRAINT [DF_KnO_OpeModKod] DEFAULT ('') NOT NULL,
    [KnO_OpeModNazwisko]   NVARCHAR (50)  CONSTRAINT [DF_KnO_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KnO_OpeZalKod]        VARCHAR (20)   CONSTRAINT [DF_KnO_OpeZalKod] DEFAULT ('') NOT NULL,
    [KnO_OpeZalNazwisko]   NVARCHAR (50)  CONSTRAINT [DF_KnO_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [KnO_EmailESklep]      NVARCHAR (60)  CONSTRAINT [DF_KnO_EmailESklep] DEFAULT ('') NOT NULL,
    CONSTRAINT [KnO_Primary] PRIMARY KEY CLUSTERED ([KnO_KnOId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KnOKontrahent] FOREIGN KEY ([KnO_KntId]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KnOKontrahent]
    ON [CDN].[KntOsoby]([KnO_KntId] ASC, [KnO_KnOId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.KntOsoby_Delete_Trigger
ON CDN.KntOsoby
FOR DELETE
AS
SET NOCOUNT ON
-- Skasowanie relacji do dokumentów CRM
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1114 AND DoR_DokumentId IN (SELECT KnO_KnOId FROM deleted)
--skasowanie zgod
  DELETE CDN.PodmiotRejestracjaZgod
  FROM CDN.PodmiotRejestracjaZgod JOIN deleted ON PRZ_PrzedstawicielId IN (SELECT KnO_KnOId FROM deleted)
SET NOCOUNT OFF
