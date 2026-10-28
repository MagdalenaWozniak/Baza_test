CREATE TABLE [CDN].[DefProjekty] (
    [PRJ_PrjId]          INT            IDENTITY (1, 1) NOT NULL,
    [PRJ_Kod]            VARCHAR (40)   NOT NULL,
    [PRJ_Nazwa]          NVARCHAR (255) NOT NULL,
    [PRJ_Symbol]         VARCHAR (20)   NOT NULL,
    [PRJ_Url]            VARCHAR (255)  NOT NULL,
    [PRJ_ParentId]       INT            NULL,
    [PRJ_Poziom]         SMALLINT       NOT NULL,
    [PRJ_Nieaktywny]     TINYINT        NOT NULL,
    [PRJ_Wezel]          NVARCHAR (255) NOT NULL,
    [PRJ_Lp]             INT            NOT NULL,
    [PRJ_StaZalId]       INT            NULL,
    [PRJ_OpeZalId]       INT            NULL,
    [PRJ_StaModId]       INT            NULL,
    [PRJ_Konto]          NVARCHAR (51)  NOT NULL,
    [PRJ_ImportAppId]    VARCHAR (5)    NULL,
    [PRJ_ImportRowId]    VARCHAR (36)   NULL,
    [PRJ_TS_Export]      DATETIME       NULL,
    [PRJ_OpeModId]       INT            NULL,
    [PRJ_DataOtw]        DATETIME       NULL,
    [PRJ_DataZam]        DATETIME       NULL,
    [PRJ_TS_Zal]         DATETIME       NULL,
    [PRJ_TS_Mod]         DATETIME       NULL,
    [PRJ_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_PRJ_OpeModKod] DEFAULT ('') NOT NULL,
    [PRJ_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PRJ_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PRJ_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_PRJ_OpeZalKod] DEFAULT ('') NOT NULL,
    [PRJ_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PRJ_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PRJ_Primary] PRIMARY KEY CLUSTERED ([PRJ_PrjId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrjKod]
    ON [CDN].[DefProjekty]([PRJ_ParentId] ASC, [PRJ_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PRJGridLookupFilter]
    ON [CDN].[DefProjekty]([PRJ_Kod] ASC, [PRJ_PrjId] ASC)
    INCLUDE([PRJ_Nieaktywny], [PRJ_Nazwa], [PRJ_Wezel]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DefProjekty_InsertUpdate_Trigger
  ON CDN.DefProjekty
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--kasowanie wskaźnika wyeksportowania
if not update (PRJ_TS_Export) and exists (select * from inserted where PRJ_TS_Export is not null)
 update cdn.DefProjekty set PRJ_TS_Export = null
  where PRJ_PrjId in (select PRJ_PrjId from inserted where PRJ_TS_Export is not null)
--ustawianie unikalnego identyfikatora
if exists (select * from inserted where PRJ_ImportRowId is null or PRJ_ImportRowId = '')
 update cdn.DefProjekty set PRJ_ImportRowId = newid()
  where PRJ_PrjId in (select PRJ_PrjId from inserted where PRJ_ImportRowId is null or PRJ_ImportRowId = '')
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.DefProjekty_Delete_Trigger
  ON CDN.DefProjekty
  FOR DELETE
AS
  SET NOCOUNT ON
    IF EXISTS (SELECT * FROM deleted WHERE deleted.Prj_PrjId = 1)
    BEGIN
      RAISERROR('Nie można kasować standardowego projektu. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w dniach kalendarzy
    /*IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.kalenddni where deleted.prj_prjid = kdg_prjid))
    BEGIN
      RAISERROR('Nie można kasować używanego projektu. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END*/
    -- sprawdzam, czy użyto strefy w dniach planu pracy
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.pracplandnigodz where deleted.prj_prjid = pgl_prjid))
    BEGIN
      RAISERROR('Nie można kasować używanego projektu. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w dniach planu pracy
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.pracpracadnigodz where deleted.prj_prjid = pgr_prjid))
    BEGIN
      RAISERROR('Nie można kasować używanego projektu. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w opisie analitycznym
    IF EXISTS (select * from deleted WHERE exists (select 1 from CDN.OpisPlace where deleted.prj_prjid = opp_prjid))
    BEGIN
      RAISERROR('Nie można kasować używanego projektu. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w opisie analitycznym
    IF EXISTS (select * from deleted WHERE exists (select 1 from CDN.OpisKadry where deleted.prj_prjid = opk_prjid))
    BEGIN
      RAISERROR('Nie można kasować używanego projektu. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy projekt ma podprojekty
    IF EXISTS (select * from deleted WHERE exists (select 1 from CDN.DefProjekty WHERE prj_parentid = deleted.prj_prjid))
    BEGIN
      RAISERROR('Kasowany projekt posiada podrzędne elementy. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
