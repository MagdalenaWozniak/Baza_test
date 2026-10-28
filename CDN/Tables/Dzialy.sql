CREATE TABLE [CDN].[Dzialy] (
    [DZL_DzlId]          INT            IDENTITY (1, 1) NOT NULL,
    [DZL_ZrgId]          INT            NULL,
    [DZL_Kod]            VARCHAR (40)   NOT NULL,
    [DZL_Nazwa]          NVARCHAR (254) NOT NULL,
    [DZL_ParentId]       INT            NULL,
    [DZL_Nieaktywny]     SMALLINT       NOT NULL,
    [DZL_AdresWezla]     NVARCHAR (512) NOT NULL,
    [DZL_Poziom]         SMALLINT       NOT NULL,
    [DZL_Lisc]           INT            NOT NULL,
    [DZL_AddMethod]      TINYINT        NOT NULL,
    [DZL_ImpId]          INT            NOT NULL,
    [DZL_Symbol]         VARCHAR (5)    NOT NULL,
    [DZL_LokId]          INT            NULL,
    [DZL_Last]           TINYINT        NOT NULL,
    [DZL_Konto]          NVARCHAR (51)  NOT NULL,
    [DZL_ImportAppId]    VARCHAR (5)    NULL,
    [DZL_ImportRowId]    VARCHAR (36)   NULL,
    [DZL_TS_Export]      DATETIME       NULL,
    [DZL_OpeZalId]       INT            NULL,
    [DZL_StaZalId]       INT            NULL,
    [DZL_TS_Zal]         DATETIME       NOT NULL,
    [DZL_OpeModId]       INT            NULL,
    [DZL_StaModId]       INT            NULL,
    [DZL_TS_Mod]         DATETIME       NOT NULL,
    [DZL_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_DZL_OpeModKod] DEFAULT ('') NOT NULL,
    [DZL_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_DZL_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DZL_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_DZL_OpeZalKod] DEFAULT ('') NOT NULL,
    [DZL_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_DZL_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [DZL_Primary] PRIMARY KEY CLUSTERED ([DZL_DzlId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DZLLokId] FOREIGN KEY ([DZL_LokId]) REFERENCES [CDN].[Lokalizacje] ([Lok_LokId]),
    CONSTRAINT [FK_DZLParrent] FOREIGN KEY ([DZL_ParentId]) REFERENCES [CDN].[Dzialy] ([DZL_DzlId]),
    CONSTRAINT [FK_DZLZrgId] FOREIGN KEY ([DZL_ZrgId]) REFERENCES [CDN].[ZestawyRegul] ([ZRG_ZrgId])
);


GO
CREATE NONCLUSTERED INDEX [DZLZrgId]
    ON [CDN].[Dzialy]([DZL_ZrgId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DZLInclude]
    ON [CDN].[Dzialy]([DZL_ParentId] ASC, [DZL_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DZLLokId]
    ON [CDN].[Dzialy]([DZL_LokId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DZLGridLookupFilter]
    ON [CDN].[Dzialy]([DZL_Kod] ASC, [DZL_DzlId] ASC)
    INCLUDE([DZL_Nieaktywny], [DZL_Nazwa], [DZL_AdresWezla]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Dzialy_Delete_Trigger
  ON CDN.Dzialy
  FOR DELETE
AS
  SET NOCOUNT ON
    -- Sprawdzanie, czy nie skasowano wydziału o Id=3 (FIRMA)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.DZL_DzlId = 3)
    BEGIN
      RAISERROR('Nie można kasować nadrzędnego wydziału FIRMA. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto działu w dniach kalendarzy
 -- WiNi cały IF wykomentowałem
    --IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.kalenddnigodz where deleted.dzl_dzlid = kdg_dzlid))
    --BEGIN
    --  RAISERROR('Nie można kasować używanego działu. ', 16, 1)
    --  ROLLBACK TRAN
    --  SET NOCOUNT OFF
    --  RETURN
    --END
    -- sprawdzam, czy użyto działu w dniach planu pracy
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.pracplandnigodz where deleted.dzl_dzlid = pgl_dzlid))
    BEGIN
      RAISERROR('Nie można kasować używanego działu. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto działu w dniach planu pracy
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.pracpracadnigodz where deleted.dzl_dzlid = pgr_dzlid))
    BEGIN
      RAISERROR('Nie można kasować używanego działu. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Dzialy_InsertUpdate_Trigger
  ON CDN.Dzialy
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--kasowanie wskaźnika wyeksportowania
if not update (DZL_TS_Export) and exists (select * from inserted where DZL_TS_Export is not null)
 update cdn.Dzialy set DZL_TS_Export = null
  where DZL_DzlId in (select DZL_DzlId from inserted where DZL_TS_Export is not null)
--ustawianie unikalnego identyfikatora
if exists (select * from inserted where DZL_ImportRowId is null or DZL_ImportRowId = '')
 update cdn.Dzialy set DZL_ImportRowId = newid()
  where DZL_DzlId in (select DZL_DzlId from inserted where DZL_ImportRowId is null or DZL_ImportRowId = '')
  SET NOCOUNT OFF
