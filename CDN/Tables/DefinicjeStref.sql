CREATE TABLE [CDN].[DefinicjeStref] (
    [DST_DstId]          INT            IDENTITY (1, 1) NOT NULL,
    [DST_Akronim]        VARCHAR (20)   NOT NULL,
    [DST_Nazwa]          NVARCHAR (50)  NOT NULL,
    [DST_UwzglCzasPracy] TINYINT        NOT NULL,
    [DST_Symbol]         VARCHAR (3)    NOT NULL,
    [DST_ProcentWynZas]  DECIMAL (7, 2) NOT NULL,
    [DST_Standardowy]    TINYINT        NOT NULL,
    [DST_Nieaktywny]     TINYINT        CONSTRAINT [DF_DST_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [DST_OpeZalId]       INT            NULL,
    [DST_StaZalId]       INT            NULL,
    [DST_TS_Zal]         DATETIME       NOT NULL,
    [DST_OpeModId]       INT            NULL,
    [DST_StaModId]       INT            NULL,
    [DST_TS_Mod]         DATETIME       NOT NULL,
    [DST_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_DST_OpeModKod] DEFAULT ('') NOT NULL,
    [DST_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_DST_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DST_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_DST_OpeZalKod] DEFAULT ('') NOT NULL,
    [DST_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_DST_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [DST_Primary] PRIMARY KEY CLUSTERED ([DST_DstId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DstNazwa]
    ON [CDN].[DefinicjeStref]([DST_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DstAkronim]
    ON [CDN].[DefinicjeStref]([DST_Akronim] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DstSymbol]
    ON [CDN].[DefinicjeStref]([DST_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DefinicjeStref_Update_Trigger
  ON CDN.DefinicjeStref
  FOR UPDATE
AS
  SET NOCOUNT ON
    IF EXISTS (SELECT * FROM deleted WHERE deleted.DST_Standardowy <> 0)
    BEGIN
      RAISERROR('Nie można modyfikować standardowej Strefy. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.DefinicjeStref_Delete_Trigger
  ON CDN.DefinicjeStref
  FOR DELETE
AS
  SET NOCOUNT ON
    IF EXISTS (SELECT * FROM deleted WHERE deleted.DST_Standardowy <> 0)
    BEGIN
      RAISERROR('Nie można usunąć używanej strefy. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w dniach kalendarzy
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.kalenddnigodz where deleted.dst_dstid = kdg_strefa))
    BEGIN
      RAISERROR('Nie można usunąć używanej strefy. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w dniach planu pracy
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.pracplandnigodz where deleted.dst_dstid = pgl_strefa))
    BEGIN
      RAISERROR('Nie można usunąć używanej strefy. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w dniach planu pracy
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.pracpracadnigodz where deleted.dst_dstid = pgr_strefa))
    BEGIN
      RAISERROR('Nie można usunąć używanej strefy. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w dniach serii kalendarzy
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.seriekalpozgodz where deleted.dst_dstid = skp_strefa))
    BEGIN
      RAISERROR('Nie można usunąć używanej strefy. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- sprawdzam, czy użyto strefy w elementach zestawienia
    IF EXISTS (select * from deleted WHERE exists (select 1 from cdn.praczestawelem where deleted.dst_dstid = pzd_dstid))
    BEGIN
      RAISERROR('Nie można usunąć używanej strefy. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
