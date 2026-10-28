CREATE TABLE [CDN].[LimitNieobec] (
    [LNB_LnbId]           INT           IDENTITY (1, 1) NOT NULL,
    [LNB_Nazwa]           VARCHAR (40)  NOT NULL,
    [LNB_Skrot]           NVARCHAR (40) NOT NULL,
    [LNB_Podstawa]        INT           NOT NULL,
    [LNB_KumNieWykorz]    TINYINT       NOT NULL,
    [LNB_ZalezyOdStaz]    TINYINT       NOT NULL,
    [LNB_LiczPropDoZatr]  TINYINT       NOT NULL,
    [LNB_Godzinowy]       TINYINT       NOT NULL,
    [LNB_LiczbaDni]       INT           NOT NULL,
    [LNB_LiczbaDniDod]    INT           NOT NULL,
    [LNB_Staz]            TINYINT       NOT NULL,
    [LNB_Standardowy]     SMALLINT      NOT NULL,
    [LNB_Nieaktywny]      TINYINT       CONSTRAINT [DF_LNB_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [LNB_PoMiesiacach]    TINYINT       CONSTRAINT [DF_LNB_PoMiesiacach] DEFAULT ((0)) NOT NULL,
    [LNB_OpeZalId]        INT           NULL,
    [LNB_StaZalId]        INT           NULL,
    [LNB_TS_Zal]          DATETIME      NULL,
    [LNB_OpeModId]        INT           NULL,
    [LNB_StaModId]        INT           NULL,
    [LNB_TS_Mod]          DATETIME      NULL,
    [LNB_LiczPropDoEtatu] TINYINT       CONSTRAINT [DF_LNB_LiczPropDoEtatu] DEFAULT ((0)) NOT NULL,
    [LNB_OpeModKod]       VARCHAR (20)  CONSTRAINT [DF_LNB_OpeModKod] DEFAULT ('') NOT NULL,
    [LNB_OpeModNazwisko]  NVARCHAR (50) CONSTRAINT [DF_LNB_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [LNB_OpeZalKod]       VARCHAR (20)  CONSTRAINT [DF_LNB_OpeZalKod] DEFAULT ('') NOT NULL,
    [LNB_OpeZalNazwisko]  NVARCHAR (50) CONSTRAINT [DF_LNB_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [LNB_Primary] PRIMARY KEY CLUSTERED ([LNB_LnbId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [LNBNazwa]
    ON [CDN].[LimitNieobec]([LNB_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LNBSkrot]
    ON [CDN].[LimitNieobec]([LNB_Skrot] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.LimitNieobec_Delete_Trigger
  ON CDN.LimitNieobec
  FOR DELETE
AS
  SET NOCOUNT ON
    -- Sprawdzanie, czy nie skasowano limitu o Id=1 (nieokreślony)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.LNB_Standardowy <> 0)
    BEGIN
      RAISERROR('Nie można kasować standardowego limitu nieobecności. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.LimitNieobec_Update_Trigger
  ON CDN.LimitNieobec
  FOR UPDATE
AS
  SET NOCOUNT ON
    IF EXISTS (SELECT * FROM deleted WHERE deleted.LNB_Standardowy <> 0)
    BEGIN
      RAISERROR('Nie można modyfikować standardowego limitu nieobecności. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
