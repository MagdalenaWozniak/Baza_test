CREATE TABLE [CDN].[WypSkladniki] (
    [WPS_WpsId]               INT             IDENTITY (1, 1) NOT NULL,
    [WPS_WplId]               INT             NOT NULL,
    [WPS_WpeId]               INT             NOT NULL,
    [WPS_PraId]               INT             NOT NULL,
    [WPS_DzlId]               INT             NOT NULL,
    [WPS_PnbId]               INT             NULL,
    [WPS_TwpId]               INT             NOT NULL,
    [WPS_RodzajZrodla]        INT             NULL,
    [WPS_ZrodloId]            INT             NULL,
    [WPS_Nazwa]               NVARCHAR (128)  NOT NULL,
    [WPS_Wartosc]             DECIMAL (15, 2) NOT NULL,
    [WPS_DataDanych]          DATETIME        NOT NULL,
    [WPS_DataOd]              DATETIME        NULL,
    [WPS_DataDo]              DATETIME        NULL,
    [WPS_Podstawa]            DECIMAL (15, 2) NULL,
    [WPS_OkresDni]            INT             NOT NULL,
    [WPS_OkresCzas]           DATETIME        NOT NULL,
    [WPS_EkwiwalentIlosc]     DECIMAL (15, 2) NOT NULL,
    [WPS_Procent]             DECIMAL (15, 2) NOT NULL,
    [WPS_Wartosc1]            DECIMAL (15, 2) NOT NULL,
    [WPS_Wartosc2]            DECIMAL (15, 2) NOT NULL,
    [WPS_Splacono]            DECIMAL (15, 2) NOT NULL,
    [WPS_SplaconoAll]         TINYINT         NOT NULL,
    [WPS_Zaliczka]            INT             NULL,
    [WPS_DstId]               INT             NULL,
    [WPS_HrmId]               INT             NULL,
    [WPS_Godziny]             DATETIME        NOT NULL,
    [WPS_WartoscWal]          DECIMAL (15, 2) NOT NULL,
    [WPS_Archiwalny]          TINYINT         CONSTRAINT [DF_WPS_Archiwalny] DEFAULT ((0)) NOT NULL,
    [WPS_OpeZalId]            INT             NULL,
    [WPS_StaZalId]            INT             NULL,
    [WPS_TS_Zal]              DATETIME        NOT NULL,
    [WPS_OpeModId]            INT             NULL,
    [WPS_StaModId]            INT             NULL,
    [WPS_TS_Mod]              DATETIME        NOT NULL,
    [WPS_PracaRodzic]         TINYINT         CONSTRAINT [DF_WPS_PracaRodzic] DEFAULT ((0)) NOT NULL,
    [WPS_PracaRodzicPodstawa] DECIMAL (15, 2) CONSTRAINT [DF_WPS_PracaRodzicPodstawa] DEFAULT ((0)) NOT NULL,
    [WPS_OkresCzasUmowa]      DATETIME        CONSTRAINT [DF_WPS_OkresCzasUmowa] DEFAULT ((-2)) NOT NULL,
    [WPS_OpeModKod]           VARCHAR (20)    CONSTRAINT [DF_WPS_OpeModKod] DEFAULT ('') NOT NULL,
    [WPS_OpeModNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_WPS_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [WPS_OpeZalKod]           VARCHAR (20)    CONSTRAINT [DF_WPS_OpeZalKod] DEFAULT ('') NOT NULL,
    [WPS_OpeZalNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_WPS_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [WPS_PodstawaSklWych]     DECIMAL (15, 2) CONSTRAINT [DF_WPS_PodstawaSklWych] DEFAULT ((0)) NOT NULL,
    [WPS_ZrodloIdExt]         INT             CONSTRAINT [DF_WPS_ZrodloIdExt] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [WPS_Primary] PRIMARY KEY CLUSTERED ([WPS_WpsId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TWPPnbLink] FOREIGN KEY ([WPS_PnbId]) REFERENCES [CDN].[PracNieobec] ([PNB_PnbId]),
    CONSTRAINT [FK_WPSDstLink] FOREIGN KEY ([WPS_DstId]) REFERENCES [CDN].[DefinicjeStref] ([DST_DstId]),
    CONSTRAINT [FK_WPSPraLink] FOREIGN KEY ([WPS_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]),
    CONSTRAINT [FK_WPSTwpLink] FOREIGN KEY ([WPS_TwpId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId]),
    CONSTRAINT [FK_WPSWpeLink] FOREIGN KEY ([WPS_WpeId]) REFERENCES [CDN].[WypElementy] ([WPE_WpeId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [WPSPraLink]
    ON [CDN].[WypSkladniki]([WPS_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPLWyplata]
    ON [CDN].[WypSkladniki]([WPS_WplId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPSWpeLink]
    ON [CDN].[WypSkladniki]([WPS_WpeId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPSTwpLink]
    ON [CDN].[WypSkladniki]([WPS_TwpId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TWPPnbLink]
    ON [CDN].[WypSkladniki]([WPS_PnbId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WpsZrodlo]
    ON [CDN].[WypSkladniki]([WPS_ZrodloId] ASC, [WPS_RodzajZrodla] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPSDstLink]
    ON [CDN].[WypSkladniki]([WPS_DstId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.WypSkladniki_InsertUpdate_Trigger
  ON CDN.WypSkladniki
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
-- Sprawdzenie obecności wierszy w tabeli nadrzędnej PracEtaty
IF EXISTS (SELECT * FROM inserted LEFT OUTER JOIN CDN.PracEtaty ON WPS_ZrodloId = PRE_PreId
           WHERE PRE_PreId IS NULL AND WPS_RodzajZrodla=1)
  BEGIN
 RAISERROR('##OPT32560##', 16, 1)
    --RAISERROR('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  PracEtaty). ', 16, 1)--ERR_SQL_Place_NieIstniejePowiazanieWPSPRE 32560
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie obecności wierszy w tabeli nadrzędnej PracKod
IF EXISTS (SELECT * FROM inserted LEFT OUTER JOIN CDN.PracKod ON WPS_ZrodloId = Pra_PraId
           WHERE Pra_PraId IS NULL AND WPS_RodzajZrodla IN (2,3,5,7,10,11))
  BEGIN
 RAISERROR('##OPT32561##', 16, 1)
    --RAISERROR('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  PracKod). ', 16, 1)--ERR_SQL_Place_NieIstniejePowiazanieWPSPRA 32561
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie obecności wierszy w tabeli nadrzędnej Dodatki
IF EXISTS (SELECT * FROM inserted LEFT OUTER JOIN CDN.Dodatki ON WPS_ZrodloId = Dod_DodId
           WHERE Dod_DodId IS NULL AND WPS_RodzajZrodla=4)
  BEGIN
 RAISERROR('##OPT32562##', 16, 1)
    --RAISERROR('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Dodatki). ', 16, 1)--ERR_SQL_Place_NieIstniejePowiazanieWPSDOD 32562
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie obecności wierszy w tabeli nadrzędnej PracNieobec
IF EXISTS (SELECT * FROM inserted LEFT OUTER JOIN CDN.PracNieobec ON WPS_ZrodloId = PNb_PNbId
           WHERE PNb_PNbId IS NULL AND WPS_RodzajZrodla=6)
  BEGIN
 RAISERROR('##OPT32563##', 16, 1)
    --RAISERROR('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  PracNieobec). ', 16, 1)--ERR_SQL_Place_NieIstniejePowiazanieWPSPNB 32563
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie obecności wierszy w tabeli nadrzędnej Umowy
IF EXISTS (SELECT * FROM inserted LEFT OUTER JOIN CDN.Umowy ON WPS_ZrodloId = Umw_UmwId
           WHERE Umw_UmwId IS NULL AND WPS_RodzajZrodla=8)
  BEGIN
 RAISERROR('##OPT32564##', 16, 1)
    --RAISERROR('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  Umowy). ', 16, 1)--ERR_SQL_Place_NieIstniejePowiazanieWPSUMW 32564
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie obecności wierszy w tabeli nadrzędnej WypElementy
IF EXISTS (SELECT * FROM inserted LEFT OUTER JOIN CDN.WypElementy ON WPS_ZrodloId = WpE_WpEId
           WHERE WpE_WpEId IS NULL AND WPS_RodzajZrodla=9)
  BEGIN
 RAISERROR('##OPT32565##', 16, 1)
    --RAISERROR('Nie istnieje zapis w tabeli nadrzędnej (powiązanie z tabelą  WypElementy). ', 16, 1)--ERR_SQL_Place_NieIstniejePowiazanieWPSWPE 32565
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
 --MC12
 declare @wartosc decimal(14,2), @zrodloid int, @trybwyplaty smallint, @wyplata int, @element int
 select @element = wps_wpeid from inserted
 select @wyplata = wpe_wplid from cdn.wypelementy where wpe_wpeid = @element
 select @trybwyplaty = wpl_tryb from cdn.wyplaty where wpl_wplid = @wyplata
 if @trybwyplaty not in (1, 2)
  begin
   select @zrodloid = wps_zrodloid from inserted
   select @wartosc = sum(wpe_wartosc) from cdn.WypElementy join cdn.WypSkladniki on WPE_WpeId = WPS_WpeId join cdn.Wyplaty on WPL_WplId = WPE_WplId
    where wpl_tryb not in (1, 2) and wps_rodzajzrodla = 8 and wps_zrodloid = @zrodloid
   update cdn.umowy set umw_splacono = isnull(@wartosc,0) where umw_umwid = @zrodloid
   --MC2015
   /*select @wartosc = sum(wpe_wartosc) from cdn.WypElementy join cdn.WypSkladniki on WPE_WpeId = WPS_WpeId join cdn.Wyplaty on WPL_WplId = WPE_WplId
    where wpl_tryb not in (1, 2) and wps_rodzajzrodla = 29 and wps_zrodloid = @zrodloid
   update cdn.ZajeciaWynagr set ZAW_Splacono = abs(isnull(@wartosc,0)) where ZAW_ZawId = @zrodloid*/
  end
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.WypSkladniki_Delete_Trigger
  ON CDN.WypSkladniki
  FOR DELETE
AS
SET NOCOUNT ON
 declare @id int, @iHrm int
 select @id = wps_wpsid, @iHrm = wps_hrmid from deleted
 if @iHrm > 0
 begin
  update cdn.harmonogram set hrm_uzyty = 0 where
   not exists (select wps_wpsid from cdn.wypskladniki where wps_hrmid = @iHrm)
 end
 --MC12
 declare @wartosc decimal(14,2)
 declare @zrodloid int
 select @zrodloid = wps_zrodloid from deleted
 select @wartosc = sum(wpe_wartosc) from cdn.wypskladniki, cdn.wypelementy, cdn.wyplaty
  where wps_wpeid = wpe_wpeid and wpe_wplid = wpl_wplid and wpl_tryb not in (1,2) and wps_rodzajzrodla = 8 and wps_zrodloid = @zrodloid
   update cdn.umowy set umw_splacono = isnull(@wartosc,0) where umw_umwid = @zrodloid
SET NOCOUNT OFF
