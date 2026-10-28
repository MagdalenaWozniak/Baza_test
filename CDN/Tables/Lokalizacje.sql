CREATE TABLE [CDN].[Lokalizacje] (
    [Lok_LokId]          INT            IDENTITY (1, 1) NOT NULL,
    [Lok_Kod]            VARCHAR (40)   NOT NULL,
    [Lok_Nazwa]          NVARCHAR (254) NOT NULL,
    [Lok_Symbol]         VARCHAR (5)    NOT NULL,
    [Lok_Konto]          NVARCHAR (51)  NOT NULL,
    [Lok_Nieaktywny]     SMALLINT       NOT NULL,
    [LOK_ImportAppId]    VARCHAR (5)    NULL,
    [LOK_ImportRowId]    VARCHAR (36)   NULL,
    [LOK_TS_Export]      DATETIME       NULL,
    [Lok_OpeZalId]       INT            NULL,
    [Lok_StaZalId]       INT            NULL,
    [Lok_TS_Zal]         DATETIME       NOT NULL,
    [Lok_OpeModId]       INT            NULL,
    [Lok_StaModId]       INT            NULL,
    [Lok_TS_Mod]         DATETIME       NOT NULL,
    [Lok_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_Lok_OpeModKod] DEFAULT ('') NOT NULL,
    [Lok_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Lok_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Lok_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_Lok_OpeZalKod] DEFAULT ('') NOT NULL,
    [Lok_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Lok_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Lok_Primary] PRIMARY KEY CLUSTERED ([Lok_LokId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [LokKod]
    ON [CDN].[Lokalizacje]([Lok_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [LokGridLookupFilter]
    ON [CDN].[Lokalizacje]([Lok_Kod] ASC, [Lok_LokId] ASC)
    INCLUDE([Lok_Nieaktywny], [Lok_Nazwa]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Lokalizacje_Delete_Trigger
  ON CDN.Lokalizacje
  FOR DELETE
AS
  SET NOCOUNT ON
    -- Sprawdzanie, czy nie skasowano lokalizacji o Id=1 (BRAK)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.LOK_LokId = 1)
    BEGIN
      RAISERROR('##OPT32505##', 16, 1)--RAISERROR('Nie można kasować lokalizacji "brak". ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacLokalizacji
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Lokalizacje_InsertUpdate_Trigger
  ON CDN.Lokalizacje
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--kasowanie wskaźnika wyeksportowania
if not update (LOK_TS_Export) and exists (select * from inserted where LOK_TS_Export is not null)
 update cdn.Lokalizacje set LOK_TS_Export = null
  where LOK_LokId in (select LOK_LokId from inserted where LOK_TS_Export is not null)
--ustawianie unikalnego identyfikatora
if exists (select * from inserted where LOK_ImportRowId is null or LOK_ImportRowId = '')
 update cdn.Lokalizacje set LOK_ImportRowId = newid()
  where LOK_LokId in (select LOK_LokId from inserted where LOK_ImportRowId is null or LOK_ImportRowId = '')
  SET NOCOUNT OFF
