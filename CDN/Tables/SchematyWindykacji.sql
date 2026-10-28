CREATE TABLE [CDN].[SchematyWindykacji] (
    [SwN_SwNId]          INT            IDENTITY (1, 1) NOT NULL,
    [SwN_Kod]            NVARCHAR (20)  NOT NULL,
    [SwN_Nazwa]          NVARCHAR (250) NOT NULL,
    [SwN_Domyslny]       TINYINT        NOT NULL,
    [SwN_Nieaktywny]     TINYINT        NOT NULL,
    [SwN_OpeZalId]       INT            NULL,
    [SwN_StaZalId]       INT            NULL,
    [SwN_TS_Zal]         DATETIME       NOT NULL,
    [SwN_OpeModId]       INT            NULL,
    [SwN_StaModId]       INT            NULL,
    [SwN_TS_Mod]         DATETIME       NOT NULL,
    [SwN_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_SwN_OpeModKod] DEFAULT ('') NOT NULL,
    [SwN_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SwN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SwN_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_SwN_OpeZalKod] DEFAULT ('') NOT NULL,
    [SwN_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SwN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SwN_Primary] PRIMARY KEY CLUSTERED ([SwN_SwNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SwN_KodUniqueIndex]
    ON [CDN].[SchematyWindykacji]([SwN_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.SchematyWindykacji_InsertUpdate_Trigger
ON CDN.SchematyWindykacji
FOR INSERT, UPDATE
AS
 SET NOCOUNT ON
    IF UPDATE (SwN_Domyslny)
    BEGIN
  DECLARE @currentId INT;
  SELECT @currentId = inserted.SwN_SwNId FROM inserted WHERE inserted.SwN_Domyslny = 1
  IF @currentId IS NOT NULL
     BEGIN
   UPDATE cdn.SchematyWindykacji
   SET cdn.SchematyWindykacji.SwN_Domyslny = 0
   WHERE cdn.SchematyWindykacji.SwN_SwNId <> @currentId
     END
    END
  SET NOCOUNT OFF
