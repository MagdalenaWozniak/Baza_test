CREATE TABLE [CDN].[AnkGrupyPytan] (
    [AnkGp_AnkGpId]        INT            IDENTITY (1, 1) NOT NULL,
    [AnkGp_Nazwa]          NVARCHAR (250) NOT NULL,
    [AnkGp_Opis]           NVARCHAR (MAX) NOT NULL,
    [AnkGp_Waga]           INT            NOT NULL,
    [AnkGp_Domyslna]       TINYINT        NOT NULL,
    [AnkGp_Nieaktywna]     TINYINT        NOT NULL,
    [AnkGp_OpeZalID]       INT            NULL,
    [AnkGp_StaZalId]       INT            NULL,
    [AnkGp_TS_Zal]         DATETIME       NOT NULL,
    [AnkGp_OpeModID]       INT            NULL,
    [AnkGp_StaModId]       INT            NULL,
    [AnkGp_TS_Mod]         DATETIME       NOT NULL,
    [AnkGp_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_AnkGp_OpeModKod] DEFAULT ('') NOT NULL,
    [AnkGp_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_AnkGp_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AnkGp_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_AnkGp_OpeZalKod] DEFAULT ('') NOT NULL,
    [AnkGp_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_AnkGp_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AnkGp_Primary] PRIMARY KEY CLUSTERED ([AnkGp_AnkGpId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AnkGp_Nazwa_UniqueIx]
    ON [CDN].[AnkGrupyPytan]([AnkGp_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.AnkGrupyPytan_InsertUpdate_Trigger
ON CDN.AnkGrupyPytan
FOR INSERT, UPDATE
AS
 SET NOCOUNT ON
    IF UPDATE (AnkGp_Domyslna)
    BEGIN
  DECLARE @currentId INT;
  SELECT @currentId = inserted.AnkGp_AnkGpId FROM inserted WHERE inserted.AnkGp_Domyslna = 1
  IF @currentId IS NOT NULL
     BEGIN
   UPDATE cdn.AnkGrupyPytan
   SET cdn.AnkGrupyPytan.AnkGp_Domyslna = 0
   WHERE cdn.AnkGrupyPytan.AnkGp_AnkGpId <> @currentId
     END
    END
  SET NOCOUNT OFF
