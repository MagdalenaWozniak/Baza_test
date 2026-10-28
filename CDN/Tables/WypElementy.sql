CREATE TABLE [CDN].[WypElementy] (
    [WPE_WpeId]          INT             IDENTITY (1, 1) NOT NULL,
    [WPE_WplId]          INT             NOT NULL,
    [WPE_PraId]          INT             NULL,
    [WPE_TwpId]          INT             NULL,
    [WPE_Nazwa]          NVARCHAR (128)  NOT NULL,
    [WPE_Wartosc]        DECIMAL (15, 2) NOT NULL,
    [WPE_Ulga]           DECIMAL (15, 2) NOT NULL,
    [WPE_Koszty]         DECIMAL (15, 2) NOT NULL,
    [WPE_ZalFis]         DECIMAL (15, 2) NOT NULL,
    [WPE_NalFis]         DECIMAL (15, 2) NOT NULL,
    [WPE_PodstEmer]      DECIMAL (15, 2) NOT NULL,
    [WPE_PodstRent]      DECIMAL (15, 2) NOT NULL,
    [WPE_PodstChor]      DECIMAL (15, 2) NOT NULL,
    [WPE_PodstWypad]     DECIMAL (15, 2) NULL,
    [WPE_PodstFP]        DECIMAL (15, 2) NOT NULL,
    [WPE_PodstFGSP]      DECIMAL (15, 2) NULL,
    [WPE_PodstZdrow]     DECIMAL (15, 2) NULL,
    [WPE_SklEmerPrac]    DECIMAL (15, 2) NOT NULL,
    [WPE_SklEmerFirma]   DECIMAL (15, 2) NOT NULL,
    [WPE_SklRentPrac]    DECIMAL (15, 2) NOT NULL,
    [WPE_SklRentFirma]   DECIMAL (15, 2) NOT NULL,
    [WPE_SklChorPrac]    DECIMAL (15, 2) NOT NULL,
    [WPE_SklChorFirma]   DECIMAL (15, 2) NULL,
    [WPE_SklWypadPrac]   DECIMAL (15, 2) NOT NULL,
    [WPE_SklWypadFirma]  DECIMAL (15, 2) NULL,
    [WPE_SklFP]          DECIMAL (15, 2) NOT NULL,
    [WPE_SklFGSP]        DECIMAL (15, 2) NOT NULL,
    [WPE_Korekta]        TINYINT         NULL,
    [WPE_Brutto50]       DECIMAL (15, 2) NULL,
    [WPE_Koszty50]       DECIMAL (15, 2) NULL,
    [WPE_NrZUS]          INT             NULL,
    [WPE_TyUb]           INT             NOT NULL,
    [WPE_SklZdrowPrac]   DECIMAL (15, 2) NOT NULL,
    [WPE_SklZdrowFirma]  DECIMAL (15, 2) NOT NULL,
    [WPE_SklZdrowSuma]   DECIMAL (15, 2) NOT NULL,
    [WPE_KatId]          INT             NULL,
    [WPE_KategoriaOpis]  VARCHAR (50)    NOT NULL,
    [WPE_Temp]           INT             NOT NULL,
    [WPE_PodstFEP]       DECIMAL (15, 2) NOT NULL,
    [WPE_SklFEP]         DECIMAL (15, 2) NOT NULL,
    [WPE_Waluta]         VARCHAR (3)     NOT NULL,
    [WPE_WartoscWal]     DECIMAL (15, 2) NOT NULL,
    [WPE_Netto]          DECIMAL (15, 2) NOT NULL,
    [WPE_NettoWal]       DECIMAL (15, 2) NOT NULL,
    [WPE_Przychod50]     DECIMAL (15, 2) NOT NULL,
    [WPE_Archiwalny]     TINYINT         CONSTRAINT [DF_WPE_Archiwalny] DEFAULT ((0)) NOT NULL,
    [WPE_OpeZalId]       INT             NULL,
    [WPE_StaZalId]       INT             NULL,
    [WPE_TS_Zal]         DATETIME        NOT NULL,
    [WPE_OpeModId]       INT             NULL,
    [WPE_StaModId]       INT             NULL,
    [WPE_TS_Mod]         DATETIME        NOT NULL,
    [WPE_KosztyBezFIS]   DECIMAL (15, 2) CONSTRAINT [DF_WPE_KosztyBezFIS] DEFAULT ((0)) NOT NULL,
    [WPE_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_WPE_OpeModKod] DEFAULT ('') NOT NULL,
    [WPE_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_WPE_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [WPE_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_WPE_OpeZalKod] DEFAULT ('') NOT NULL,
    [WPE_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_WPE_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [WPE_PodstPPK]       DECIMAL (15, 2) CONSTRAINT [DF_WPE_PodstPPK] DEFAULT ((0)) NOT NULL,
    [WPE_SklPPKPrac1]    DECIMAL (15, 2) CONSTRAINT [DF_WPE_SklPPKPrac1] DEFAULT ((0)) NOT NULL,
    [WPE_SklPPKPrac2]    DECIMAL (15, 2) CONSTRAINT [DF_WPE_SklPPKPrac2] DEFAULT ((0)) NOT NULL,
    [WPE_SklPPKFirma1]   DECIMAL (15, 2) CONSTRAINT [DF_WPE_SklPPKFirma1] DEFAULT ((0)) NOT NULL,
    [WPE_SklPPKFirma2]   DECIMAL (15, 2) CONSTRAINT [DF_WPE_SklPPKFirma2] DEFAULT ((0)) NOT NULL,
    [WPE_ZalFisZwol]     TINYINT         CONSTRAINT [DF_WPE_ZalFisZwol] DEFAULT ((0)) NOT NULL,
    [WPE_PodstPITZwol]   DECIMAL (15, 2) CONSTRAINT [DF_WPE_PodstPITZwol] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [WPE_Primary] PRIMARY KEY CLUSTERED ([WPE_WpeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WPEKategoria] FOREIGN KEY ([WPE_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_WPEPraLInk] FOREIGN KEY ([WPE_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]),
    CONSTRAINT [FK_WPETwpLink] FOREIGN KEY ([WPE_TwpId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId]),
    CONSTRAINT [FK_WPEWplLink] FOREIGN KEY ([WPE_WplId]) REFERENCES [CDN].[Wyplaty] ([WPL_WplId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [WPEWplLink]
    ON [CDN].[WypElementy]([WPE_WplId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPEPraLInk]
    ON [CDN].[WypElementy]([WPE_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPETwpLink]
    ON [CDN].[WypElementy]([WPE_TwpId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPEKategoria]
    ON [CDN].[WypElementy]([WPE_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.WypElementy2WypSkladniki_Delete_Trigger
  ON CDN.WypElementy
  FOR DELETE
AS
SET NOCOUNT ON
-- obsługa kaskadowego kasowania wierszy z tabeli CDN.WypSkladniki
 DELETE FROM CDN.WypSkladniki WHERE WPS_RodzajZrodla = 9 AND WPS_ZrodloId IN (SELECT WpE_WpEId FROM deleted)
SET NOCOUNT OFF

GO
create trigger CDN.WypElementy_Update_Trigger
  on CDN.WypElementy
  for update
as
set nocount on
 declare @WpeId int, @PraId int
 select @WpeId = WPE_WpeId, @PraId = WPE_PraId from inserted
 declare @ZrodloId int
 /*select top 1 @ZrodloId = WPS_ZrodloId from cdn.WypSkladniki where WPS_RodzajZrodla = 29 and WPS_WpeId = @WpeId
 if @ZrodloId > 0
 begin
  declare @wartosc decimal(14,2)
  select @wartosc = sum(WPE_Wartosc) from cdn.WypElementy join cdn.WypSkladniki on WPE_WpeId = WPS_WpeId join cdn.Wyplaty on WPL_WplId = WPE_WplId
   where WPE_PraId = @PraId and WPL_Tryb not in (1, 2) and WPS_RodzajZrodla = 29 and WPS_ZrodloId = @ZrodloId
  update cdn.ZajeciaWynagr set ZAW_Splacono = abs(isnull(@wartosc,0)) where ZAW_ZawId = @zrodloid
 end*/
set nocount off
