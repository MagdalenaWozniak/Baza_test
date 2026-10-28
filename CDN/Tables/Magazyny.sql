CREATE TABLE [CDN].[Magazyny] (
    [Mag_MagId]            INT            IDENTITY (1, 1) NOT NULL,
    [Mag_GIDNumer]         INT            NULL,
    [Mag_MagazynZwrotnyXL] TINYINT        NULL,
    [Mag_Typ]              SMALLINT       NOT NULL,
    [Mag_Symbol]           VARCHAR (20)   NOT NULL,
    [Mag_Nazwa]            NVARCHAR (50)  NOT NULL,
    [Mag_Opis]             NVARCHAR (254) NOT NULL,
    [Mag_Rejestr]          NVARCHAR (5)   NOT NULL,
    [Mag_NieAktywny]       TINYINT        NOT NULL,
    [Mag_MagIdXL]          INT            NULL,
    [Mag_Unijny]           TINYINT        NOT NULL,
    [Mag_UEKraj]           NVARCHAR (2)   NOT NULL,
    [Mag_KodTransakcji]    NVARCHAR (2)   NOT NULL,
    [Mag_OpeZalId]         INT            NULL,
    [Mag_StaZalId]         INT            NULL,
    [Mag_TS_Zal]           DATETIME       NOT NULL,
    [Mag_OpeModId]         INT            NULL,
    [Mag_StaModId]         INT            NULL,
    [Mag_TS_Mod]           DATETIME       NOT NULL,
    [Mag_TwCNumer]         INT            CONSTRAINT [DF_Mag_TwCNumer] DEFAULT ((0)) NOT NULL,
    [Mag_Konto]            VARCHAR (50)   NULL,
    [Mag_OpeModKod]        VARCHAR (20)   CONSTRAINT [DF_Mag_OpeModKod] DEFAULT ('') NOT NULL,
    [Mag_OpeModNazwisko]   NVARCHAR (50)  CONSTRAINT [DF_Mag_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Mag_OpeZalKod]        VARCHAR (20)   CONSTRAINT [DF_Mag_OpeZalKod] DEFAULT ('') NOT NULL,
    [Mag_OpeZalNazwisko]   NVARCHAR (50)  CONSTRAINT [DF_Mag_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [Mag_Adres]            INT            CONSTRAINT [DF_Mag_Adres] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Mag_Primary] PRIMARY KEY CLUSTERED ([Mag_MagId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MagSymbol]
    ON [CDN].[Magazyny]([Mag_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Magazyny_InsertUpdate_Trigger
  ON CDN.Magazyny
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
    -- Sprawdzanie, czy nie unieaktywniono magazynu domyślnego (o Id=1)
    IF EXISTS (SELECT * FROM inserted WHERE Mag_MagId = 1 AND Mag_NieAktywny <> 0)
    BEGIN
      RAISERROR('##OPT34519##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (select * from cdn.detalstanowiska where DSta_Nieaktywne = 0 and dsta_MagId  in (SELECT Mag_MagId FROM inserted where Mag_NieAktywny <> 0))
    BEGIN
      RAISERROR('##OPT34520##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 IF EXISTS (select * from cdn.eSklepMagazyny where  ESM_MagId  in (SELECT Mag_MagId FROM inserted where Mag_NieAktywny <> 0))
    BEGIN
      RAISERROR('##OPT34521##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 IF EXISTS (select * from cdn.eSklepMagazyny where  ESM_MagId  in (SELECT Mag_MagId FROM inserted where Mag_Typ <> 1))
    BEGIN
      RAISERROR('##OPT34522##''', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Magazyny_Delete_Trigger
  ON CDN.Magazyny
  FOR DELETE
AS
  SET NOCOUNT ON
    -- Sprawdzanie, czy nie skasowano magazynu domyślnego (o Id=1)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.Mag_MagId = 1)
    BEGIN
      RAISERROR('##OPT34515##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT tre_magid FROM cdn.traelem WHERE tre_magid in (SELECT deleted.Mag_MagId FROM deleted))
    BEGIN
      RAISERROR('##OPT34516##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 IF EXISTS (SELECT ESM_MagId FROM cdn.eSklepMagazyny WHERE ESM_MagId in (SELECT deleted.Mag_MagId FROM deleted))
    BEGIN
      RAISERROR('##OPT34517##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 IF EXISTS (SELECT DSta_MagId FROM cdn.DetalStanowiska WHERE DSta_MagId in (SELECT deleted.Mag_MagId FROM deleted))
    BEGIN
      RAISERROR('##OPT34518##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
   IF EXISTS (SELECT DSta_MagIdZwrotny FROM cdn.DetalStanowiska WHERE DSta_MagIdZwrotny in (SELECT deleted.Mag_MagId FROM deleted))
    BEGIN
      RAISERROR('##OPT34518##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
