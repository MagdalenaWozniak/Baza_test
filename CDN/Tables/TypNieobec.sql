CREATE TABLE [CDN].[TypNieobec] (
    [TNB_TnbId]                INT           IDENTITY (1, 1) NOT NULL,
    [TNB_PdzId]                INT           NOT NULL,
    [TNB_TwpId]                INT           NULL,
    [TNB_LnbId]                INT           NULL,
    [TNB_TyuId]                INT           NOT NULL,
    [TNB_TnkId]                INT           NOT NULL,
    [TNB_Nazwa]                VARCHAR (40)  NOT NULL,
    [TNB_Akronim]              VARCHAR (20)  NOT NULL,
    [TNB_Typ]                  INT           NOT NULL,
    [TNB_RozliczDni]           TINYINT       NOT NULL,
    [TNB_TypRozliczenia]       INT           NOT NULL,
    [TNB_PomnCzasPracy]        TINYINT       NOT NULL,
    [TNB_PomnCzasRNA]          TINYINT       NOT NULL,
    [TNB_PomnStazPracy]        TINYINT       NOT NULL,
    [TNB_PomnLimitUrlopu]      TINYINT       NOT NULL,
    [TNB_PomniejszWynagr]      TINYINT       NOT NULL,
    [TNB_Pomniejszenie]        TINYINT       NOT NULL,
    [TNB_Standardowy]          SMALLINT      NOT NULL,
    [TNB_Wycofany]             TINYINT       NOT NULL,
    [TNB_Nieaktywny]           TINYINT       NOT NULL,
    [TNB_OpeZalId]             INT           NULL,
    [TNB_StaZalId]             INT           NULL,
    [TNB_TS_Zal]               DATETIME      NULL,
    [TNB_OpeModId]             INT           NULL,
    [TNB_StaModId]             INT           NULL,
    [TNB_TS_Mod]               DATETIME      NULL,
    [TNB_Planowany]            TINYINT       CONSTRAINT [DF_TNB_Planowany] DEFAULT ((0)) NOT NULL,
    [TNB_PoZatwierdzeniu]      INT           NULL,
    [TNB_OpeModKod]            VARCHAR (20)  CONSTRAINT [DF_TNB_OpeModKod] DEFAULT ('') NOT NULL,
    [TNB_OpeModNazwisko]       NVARCHAR (50) CONSTRAINT [DF_TNB_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [TNB_OpeZalKod]            VARCHAR (20)  CONSTRAINT [DF_TNB_OpeZalKod] DEFAULT ('') NOT NULL,
    [TNB_OpeZalNazwisko]       NVARCHAR (50) CONSTRAINT [DF_TNB_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [TNB_WliczOkresPracyNaucz] TINYINT       CONSTRAINT [DF_TNB_WliczOkresPracyNaucz] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [TNB_Primary] PRIMARY KEY CLUSTERED ([TNB_TnbId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TNBLnbId] FOREIGN KEY ([TNB_LnbId]) REFERENCES [CDN].[LimitNieobec] ([LNB_LnbId]),
    CONSTRAINT [FK_TNBPdzLink] FOREIGN KEY ([TNB_PdzId]) REFERENCES [CDN].[PozDeklZUS] ([PDZ_PdzId]),
    CONSTRAINT [FK_TNBTnkLink] FOREIGN KEY ([TNB_TnkId]) REFERENCES [CDN].[TypNieobecKartaPracy] ([TNK_TnkId]),
    CONSTRAINT [FK_TNBTwpId] FOREIGN KEY ([TNB_TwpId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId]),
    CONSTRAINT [FK_TNBTyuLink] FOREIGN KEY ([TNB_TyuId]) REFERENCES [CDN].[TytUbezp] ([TYU_TyuId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TNBNazwa]
    ON [CDN].[TypNieobec]([TNB_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TNBTwpId]
    ON [CDN].[TypNieobec]([TNB_TwpId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TNBPdzLink]
    ON [CDN].[TypNieobec]([TNB_PdzId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TNBLnbId]
    ON [CDN].[TypNieobec]([TNB_LnbId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TNBTyuLink]
    ON [CDN].[TypNieobec]([TNB_TyuId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TNBTnkLink]
    ON [CDN].[TypNieobec]([TNB_TnkId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TypNieobec_Delete_Trigger
  ON CDN.TypNieobec
  FOR DELETE
AS
  SET NOCOUNT ON
    -- Sprawdzanie, czy nie skasowano kontrahenta o Id=1 (nieokreślony)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.TNB_Standardowy <> 0)
    BEGIN
      RAISERROR('Nie można kasować standardowego typu nieobecności. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TypNieobec_Update_Trigger
  ON CDN.TypNieobec
  FOR UPDATE
AS
  SET NOCOUNT ON
    IF EXISTS (SELECT * FROM deleted WHERE deleted.TNB_Standardowy <> 0)
    BEGIN
      RAISERROR('Nie można modyfikować standardowego typu nieobecności. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
