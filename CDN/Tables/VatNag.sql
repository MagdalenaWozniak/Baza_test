CREATE TABLE [CDN].[VatNag] (
    [VaN_VaNID]                    INT             IDENTITY (1, 1) NOT NULL,
    [VaN_Typ]                      SMALLINT        NOT NULL,
    [VaN_Rodzaj]                   TINYINT         NOT NULL,
    [VaN_Rejestr]                  NVARCHAR (20)   NOT NULL,
    [VaN_RokMies]                  INT             NOT NULL,
    [VaN_Lp]                       INT             NOT NULL,
    [VaN_DataObowiazkuPodatkowego] DATETIME        CONSTRAINT [DF_VaN_DataObowiazkuPodatkowego] DEFAULT (getdate()) NOT NULL,
    [VaN_DataPrawaOdliczenia]      DATETIME        CONSTRAINT [DF_VaN_DataPrawaOdliczenia] DEFAULT (getdate()) NOT NULL,
    [VaN_DataZap]                  DATETIME        NOT NULL,
    [VaN_DataWys]                  DATETIME        NOT NULL,
    [VaN_DataOpe]                  DATETIME        NOT NULL,
    [VaN_DataKur]                  DATETIME        NOT NULL,
    [VaN_KursDoKsiegowania]        TINYINT         NOT NULL,
    [VaN_DataKurDoVAT]             DATETIME        NOT NULL,
    [VaN_DeklRokMies]              INT             NOT NULL,
    [VaN_DeklRokMiesKasa]          INT             NOT NULL,
    [VaN_RozliczacVat7]            TINYINT         NOT NULL,
    [VaN_RozliczacVatUE]           TINYINT         NOT NULL,
    [VaN_AutoVat7Kasa]             TINYINT         NOT NULL,
    [VaN_MetodaKasowa]             TINYINT         CONSTRAINT [DF_VaN_MetodaKasowa] DEFAULT ((0)) NOT NULL,
    [VaN_IdentKsieg]               VARCHAR (50)    NOT NULL,
    [VaN_IdentKsiegNumeracja]      VARCHAR (50)    NULL,
    [VaN_IdentKsiegDDfID]          INT             NULL,
    [VaN_Dokument]                 VARCHAR (256)   NOT NULL,
    [VaN_KorektaDo]                NVARCHAR (256)  NOT NULL,
    [VaN_Korekta]                  TINYINT         NOT NULL,
    [VaN_Fiskalna]                 TINYINT         NOT NULL,
    [VaN_KorektaVAT]               TINYINT         NOT NULL,
    [VaN_Detal]                    TINYINT         NOT NULL,
    [VaN_Wewnetrzna]               TINYINT         NOT NULL,
    [VaN_PodmiotTyp]               SMALLINT        NULL,
    [VaN_PodID]                    INT             NULL,
    [VaN_KntNazwa1]                NVARCHAR (50)   NOT NULL,
    [VaN_KntNazwa2]                NVARCHAR (50)   NOT NULL,
    [VaN_KntNazwa3]                NVARCHAR (250)  NOT NULL,
    [VaN_KntKraj]                  NVARCHAR (40)   NOT NULL,
    [VaN_KntWojewodztwo]           NVARCHAR (40)   NOT NULL,
    [VaN_KntPowiat]                NVARCHAR (40)   NOT NULL,
    [VaN_KntGmina]                 NVARCHAR (40)   NOT NULL,
    [VaN_KntUlica]                 NVARCHAR (40)   NOT NULL,
    [VaN_KntNrDomu]                NVARCHAR (10)   NOT NULL,
    [VaN_KntNrLokalu]              NVARCHAR (10)   NOT NULL,
    [VaN_KntMiasto]                NVARCHAR (40)   NOT NULL,
    [VaN_KntKodPocztowy]           VARCHAR (10)    NOT NULL,
    [VaN_KntPoczta]                NVARCHAR (40)   NOT NULL,
    [VaN_KntAdres2]                NVARCHAR (40)   NOT NULL,
    [VaN_KntNipKraj]               VARCHAR (2)     NOT NULL,
    [VaN_KntNipE]                  NVARCHAR (20)   NOT NULL,
    [VaN_Pesel]                    NVARCHAR (11)   CONSTRAINT [DF_VaN_Pesel] DEFAULT ('') NOT NULL,
    [VaN_KntKonto]                 NVARCHAR (20)   NOT NULL,
    [VaN_Finalny]                  TINYINT         NOT NULL,
    [VaN_Export]                   TINYINT         NOT NULL,
    [VaN_PodatekVat]               TINYINT         CONSTRAINT [DF_VaN_PodatekVat] DEFAULT ((0)) NOT NULL,
    [VaN_MalyPod]                  TINYINT         NOT NULL,
    [VaN_Rolnik]                   TINYINT         NOT NULL,
    [VaN_PlatnikTyp]               SMALLINT        NULL,
    [VaN_PlatnikID]                INT             NULL,
    [VaN_PlatnikRachunekLp]        INT             NULL,
    [VaN_PlatnikKraj]              NVARCHAR (40)   CONSTRAINT [df_VaN_PlatnikKraj] DEFAULT ('') NOT NULL,
    [VaN_PlatnikWojewodztwo]       NVARCHAR (40)   CONSTRAINT [df_VaN_PlatnikWojewodztwo] DEFAULT ('') NOT NULL,
    [VaN_PlatnikPowiat]            NVARCHAR (40)   CONSTRAINT [df_VaN_PlatnikPowiat] DEFAULT ('') NOT NULL,
    [VaN_PlatnikGmina]             NVARCHAR (40)   CONSTRAINT [df_VaN_PlatnikGmina] DEFAULT ('') NOT NULL,
    [VaN_PlatnikUlica]             NVARCHAR (40)   CONSTRAINT [df_VaN_PlatnikUlica] DEFAULT ('') NOT NULL,
    [VaN_PlatnikNrDomu]            NVARCHAR (10)   CONSTRAINT [df_VaN_PlatnikNrDomu] DEFAULT ('') NOT NULL,
    [VaN_PlatnikNrLokalu]          NVARCHAR (10)   CONSTRAINT [df_VaN_PlatnikNrLokalu] DEFAULT ('') NOT NULL,
    [VaN_PlatnikMiasto]            NVARCHAR (40)   CONSTRAINT [df_VaN_PlatnikMiasto] DEFAULT ('') NOT NULL,
    [VaN_PlatnikKodPocztowy]       NVARCHAR (10)   CONSTRAINT [df_VaN_PlatnikKodPocztowy] DEFAULT ('') NOT NULL,
    [VaN_PlatnikPoczta]            NVARCHAR (40)   CONSTRAINT [df_VaN_PlatnikPoczta] DEFAULT ('') NOT NULL,
    [VaN_PlatnikAdres2]            NVARCHAR (40)   CONSTRAINT [df_VaN_PlatnikAdres2] DEFAULT ('') NOT NULL,
    [VaN_PlatnikNazwa1]            NVARCHAR (50)   CONSTRAINT [df_VaN_PlatnikNazwa1] DEFAULT ('') NOT NULL,
    [VaN_PlatnikNazwa2]            NVARCHAR (50)   CONSTRAINT [df_VaN_PlatnikNazwa2] DEFAULT ('') NOT NULL,
    [VaN_PlatnikNazwa3]            NVARCHAR (250)  CONSTRAINT [df_VaN_PlatnikNazwa3] DEFAULT ('') NOT NULL,
    [Van_PlatnikRachunekNr]        NVARCHAR (51)   CONSTRAINT [df_VaN_PlatnikRachunekNr] DEFAULT ('') NOT NULL,
    [VaN_KatID]                    INT             NULL,
    [VaN_Kategoria]                VARCHAR (50)    NOT NULL,
    [VaN_WzID]                     INT             NULL,
    [VaN_Rozliczono]               TINYINT         NOT NULL,
    [VaN_Zaplacono]                TINYINT         CONSTRAINT [DF_VaN_Zaplacono] DEFAULT ((0)) NOT NULL,
    [VaN_FplID]                    INT             NULL,
    [VaN_Termin]                   DATETIME        NOT NULL,
    [VaN_RazemNetto]               DECIMAL (15, 2) NOT NULL,
    [VaN_RazemNettoDoVAT]          DECIMAL (15, 2) NOT NULL,
    [VaN_RazemVAT]                 DECIMAL (15, 2) NOT NULL,
    [VaN_RazemVATDoVAT]            DECIMAL (15, 2) NOT NULL,
    [VaN_RazemBrutto]              DECIMAL (15, 2) NOT NULL,
    [VaN_RazemBruttoDoVAT]         DECIMAL (15, 2) NOT NULL,
    [VaN_RazemBruttoWal]           DECIMAL (15, 2) NOT NULL,
    [VaN_Waluta]                   VARCHAR (3)     NOT NULL,
    [VaN_WalutaDoVAT]              VARCHAR (3)     NOT NULL,
    [VaN_KursNumer]                INT             NOT NULL,
    [VaN_KursNumerDoVAT]           INT             NOT NULL,
    [VaN_KursL]                    DECIMAL (15, 4) NOT NULL,
    [VaN_KursLDoVAT]               DECIMAL (15, 4) NOT NULL,
    [VaN_KursM]                    DECIMAL (5)     NOT NULL,
    [VaN_KursMDoVAT]               DECIMAL (5)     NOT NULL,
    [VaN_Zaplata]                  DECIMAL (15, 2) NOT NULL,
    [VaN_WartoscZak]               DECIMAL (15, 2) NOT NULL,
    [VaN_AkcyzaWegiel]             DECIMAL (15, 2) CONSTRAINT [DF_VaN_AkcyzaWegiel] DEFAULT ((0)) NOT NULL,
    [VaN_AkcyzaWegiel_KolumnaKPR]  INT             CONSTRAINT [DF_VaN_AkcyzaWegiel_KolumnaKPR] DEFAULT ((0)) NOT NULL,
    [VaN_TrybNettoVAT]             TINYINT         CONSTRAINT [DF_VaN_TrybNettoVAT] DEFAULT ((0)) NOT NULL,
    [VaN_PodmiotZalTyp]            SMALLINT        NULL,
    [VaN_PodZalId]                 INT             NULL,
    [VaN_AppRowID]                 VARCHAR (20)    NULL,
    [VaN_AppID]                    INT             NULL,
    [VaN_TrnID]                    INT             NULL,
    [VaN_VanOrgId]                 INT             NULL,
    [VaN_CloProc]                  DECIMAL (5, 2)  NOT NULL,
    [VaN_CloWart]                  DECIMAL (15, 2) NOT NULL,
    [VaN_AkcyzaProc]               DECIMAL (5, 2)  NOT NULL,
    [VaN_AkcyzaWart]               DECIMAL (15, 2) NOT NULL,
    [VaN_PodImpProc]               DECIMAL (5, 2)  NOT NULL,
    [VaN_PodImpWart]               DECIMAL (15, 2) NOT NULL,
    [VaN_KpRID]                    INT             NULL,
    [VaN_RycID]                    INT             NULL,
    [VaN_DekID]                    INT             NULL,
    [VaN_PreDekID]                 INT             NULL,
    [VaN_ImportAppId]              VARCHAR (5)     NULL,
    [VaN_ImportRowId]              VARCHAR (36)    NULL,
    [VaN_TS_Export]                DATETIME        NULL,
    [VaN_OpeZalID]                 INT             NULL,
    [VaN_StaZalId]                 INT             NULL,
    [VaN_TS_Zal]                   DATETIME        NOT NULL,
    [VaN_OpeModID]                 INT             NULL,
    [VaN_StaModId]                 INT             NULL,
    [VaN_TS_Mod]                   DATETIME        NOT NULL,
    [VaN_Srw]                      SMALLINT        NULL,
    [VaN_NettoWal]                 AS              ([CDN].[SumVatTab_NettoWal]([VaN_VaNID])),
    [VaN_VATWal]                   AS              ([CDN].[SumVatTab_VATWal]([VaN_VaNID])),
    [VaN_RozliczacVat27]           TINYINT         NOT NULL,
    [VaN_JPK_FA]                   TINYINT         CONSTRAINT [DF_VaN_JPK_FA] DEFAULT ((0)) NOT NULL,
    [VaN_IdentKsiegStr]            AS              ([CDN].[IdentKsiStr]([VaN_IdentKsieg],[VaN_IdentKsiegNumeracja])),
    [VaN_IdentKsiegNr]             AS              ([CDN].[IdentKsiNr]([VaN_IdentKsieg],[VaN_IdentKsiegNumeracja])),
    [VaN_ZakID]                    INT             NULL,
    [VaN_DokumentyNadrzedne]       VARCHAR (256)   NULL,
    [VaN_ZbVaNID]                  INT             NULL,
    [VaN_OpeModKod]                VARCHAR (20)    CONSTRAINT [DF_VaN_OpeModKod] DEFAULT ('') NOT NULL,
    [VaN_OpeModNazwisko]           NVARCHAR (50)   CONSTRAINT [DF_VaN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [VaN_OpeZalKod]                VARCHAR (20)    CONSTRAINT [DF_VaN_OpeZalKod] DEFAULT ('') NOT NULL,
    [VaN_OpeZalNazwisko]           NVARCHAR (50)   CONSTRAINT [DF_VaN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [VaN_KwotaNKUP]                DECIMAL (15, 2) CONSTRAINT [DF_VaN_KwotaNKUP] DEFAULT ((0)) NOT NULL,
    [VaN_VATNKUP]                  DECIMAL (15, 2) CONSTRAINT [DF_VaN_VATNKUP] DEFAULT ((0)) NOT NULL,
    [VaN_DnpID]                    INT             NULL,
    [VaN_SplitPay]                 TINYINT         CONSTRAINT [DF_VaN_SplitPay] DEFAULT ((0)) NOT NULL,
    [VaN_OCR]                      TINYINT         CONSTRAINT [DF_VaN_OCR] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [VaN_Primary] PRIMARY KEY CLUSTERED ([VaN_VaNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_VanFormaPlatnosci] FOREIGN KEY ([VaN_FplID]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId]),
    CONSTRAINT [FK_VaNKategorie] FOREIGN KEY ([VaN_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_VaNKontrah] FOREIGN KEY ([VaN_PodID], [VaN_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE NONCLUSTERED INDEX [VaNDeklarac]
    ON [CDN].[VatNag]([VaN_Typ] ASC, [VaN_DeklRokMies] ASC, [VaN_RozliczacVat7] ASC, [VaN_Wewnetrzna] ASC)
    INCLUDE([VaN_VaNID], [VaN_Fiskalna], [VaN_Detal], [VaN_Finalny], [VaN_Export], [VaN_Rejestr]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNDeklarUE]
    ON [CDN].[VatNag]([VaN_Typ] ASC, [VaN_DeklRokMies] ASC, [VaN_RozliczacVatUE] ASC, [VaN_Export] ASC)
    INCLUDE([VaN_VaNID], [VaN_Rejestr], [VaN_Wewnetrzna]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNRejestrChrono]
    ON [CDN].[VatNag]([VaN_Typ] ASC, [VaN_Rejestr] ASC, [VaN_DataZap] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNChrono]
    ON [CDN].[VatNag]([VaN_Typ] ASC, [VaN_DataZap] ASC)
    INCLUDE([VaN_VaNID]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VanKPR]
    ON [CDN].[VatNag]([VaN_KpRID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNRyczalt]
    ON [CDN].[VatNag]([VaN_RycID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNDekrety]
    ON [CDN].[VatNag]([VaN_DekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNPreDekrety]
    ON [CDN].[VatNag]([VaN_PreDekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNKontrah]
    ON [CDN].[VatNag]([VaN_PodID] ASC, [VaN_PodmiotTyp] ASC, [VaN_Typ] ASC, [VaN_DataZap] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VanTrnZrd]
    ON [CDN].[VatNag]([VaN_TrnID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNPodmiotZal]
    ON [CDN].[VatNag]([VaN_PodZalId] ASC, [VaN_PodmiotZalTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNKategorie]
    ON [CDN].[VatNag]([VaN_KatID] ASC, [VaN_Typ] ASC, [VaN_DataZap] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VanFormaPlatnosci]
    ON [CDN].[VatNag]([VaN_FplID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [VaNGUID]
    ON [CDN].[VatNag]([VaN_ImportRowId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [VaNOrgId]
    ON [CDN].[VatNag]([VaN_VanOrgId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNIdentKsieg]
    ON [CDN].[VatNag]([VaN_IdentKsiegStr] ASC, [VaN_IdentKsiegNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaNIdentKsieg2]
    ON [CDN].[VatNag]([VaN_IdentKsieg] ASC, [VaN_VaNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VanDataWys]
    ON [CDN].[VatNag]([VaN_DataWys] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VanDokNagPliki]
    ON [CDN].[VatNag]([VaN_DnpID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.VatNag_Delete_Trigger
  ON CDN.VatNag
  FOR DELETE
AS
  SET NOCOUNT ON
  Set ArithAbort On
-- Sprawdzenie powiązania do zawiadomienia VATZD i statusu wysłania e-Deklaracji
  if exists (
              select VZD.DkN_RokMiesiac, CDN.VATZD_DeklaracjeVat7_Wyslana(VZD.DkN_RokMiesiac), DkE_WartoscL from
                    CDN.DeklNag VZD join CDN.DeklElem on (VZD.DkN_DkNId = DkE_DkNId)
                    where
                    VZD.DkN_TypDeklar in (402,403) and VZD.DkN_Finalna = 1 and DkE_Numer = 1
                    and DkE_WartoscL in (select deleted.VaN_VaNId from deleted)
                    and CDN.VATZD_DeklaracjeVat7_Wyslana(VZD.DkN_RokMiesiac) <> 0)
    BEGIN
      RAISERROR('##OPT32038##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  if exists (
              select VZD.DkN_RokMiesiac, CDN.VATZD_DeklaracjeVat7_Wyslana(VZD.DkN_RokMiesiac), VaZ_VaNId_ZK from
                    CDN.DeklNag VZD join CDN.VatZD on (VZD.DkN_DkNId = VaZ_DkNID)
                    where
                    VZD.DkN_TypDeklar in (402,403) and VZD.DkN_Finalna = 1
                    and VaZ_VaNId_ZK in  (select deleted.VaN_VaNId from deleted)
                    and CDN.VATZD_DeklaracjeVat7_Wyslana(VZD.DkN_RokMiesiac) <> 0)
    BEGIN
      RAISERROR('##OPT32038##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  if exists(
        select  * from
        CDN.DeklNag VZD
        join CDN.VatZD on (VZD.DkN_DkNId = VaZ_DkNID)
        join deleted on (deleted.VaN_VaNID = VaZ_VaNId)
        where
        VZD.DkN_TypDeklar in (402,403) and VZD.DkN_Finalna = 1
  )
  begin
        RAISERROR('##OPT34773##', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
  end
-- Sprawdzenie i usunięcie powiązania do zawiadomienia VATZD
  IF EXISTS ( select * from
    CDN.DeklNag join CDN.DeklElem on (DkN_DkNId = DkE_DkNId and DkN_TypDeklar in (402,403) and DkN_Finalna = 1 and DkE_Numer = 1)
    join deleted on (DkE_WartoscL = deleted.VaN_VaNId) )
    BEGIN
      update CDN.DeklElem Set DkE_WartoscL = 0, DkE_WartoscM =0, DkE_WartoscTekst = ''
      from
      CDN.DeklNag join CDN.DeklElem on (DkN_DkNId = DkE_DkNId and DkN_TypDeklar in (402,403) and DkE_Numer = 1)
      join deleted on (DkE_WartoscL = deleted.VaN_VaNId)
    END
  IF EXISTS ( select * from
    CDN.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNID and DkN_TypDeklar in (402,403))
    join deleted on (VaZ_VaNId_ZK = deleted.VaN_VaNId) )
    BEGIN
      update CDN.VatZD Set VaZ_VaNId_ZK = NULL
      from
      CDN.VatZD join deleted on (VaZ_VaNId_ZK = deleted.VaN_VaNId) where VaZ_Bufor = 0
   delete from CDN.VATZD where VaZ_VaZId in (select VaZ_VaZId from CDN.VatZD join deleted on (VaZ_VaNId_ZK = deleted.VaN_VaNId) where VaZ_Bufor = 1)
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane do ryczałtu
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.VaN_RycId IS NOT NULL)
    BEGIN
      RAISERROR('##OPT32023##%%1%%=Ryczalt##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane do KPiR
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.VaN_KpRId IS NOT NULL)
    BEGIN
      RAISERROR('##OPT32023##%%1%%=KPiR##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane na konta
  IF EXISTS (SELECT * FROM deleted JOIN CDN.DekretyNag On VaN_DekId = DeN_DeNId And DeN_Zrodlo = 2)
    BEGIN
      RAISERROR('##OPT32023##%%1%%=Dekrety##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Skasowanie relacji do dokumentów z biblioteki  (WJ)
  IF EXISTS( SELECT * FROM CDN.DokRelacje INNER JOIN deleted ON DoR_DokumentTyp=999 AND DoR_DokumentId=deleted.VaN_VaNId)
 DELETE CDN.DokRelacje
 FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=999 AND DoR_DokumentId=deleted.VaN_VaNId
-- Sprawdzenie, czy zapisy nie maja wygenerowanych dokumentow wewnetrznych
  IF EXISTS (SELECT * FROM deleted d JOIN CDN.VatNag v On d.VaN_VaNId = v.VaN_VaNOrgId AND v.VaN_Rodzaj != 10)
    BEGIN
      Declare @Numer NVarchar(30)
      Select Top 1 @Numer = v.VaN_Dokument FROM deleted d JOIN CDN.VatNag v On d.VaN_VaNId = v.VaN_VaNOrgId
      RAISERROR('##OPT32039##%%1%%=%s##', 16, 1, @Numer)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF (SELECT VaN_ZbVaNID FROM deleted d) IS NOT NULL
    BEGIN
      Declare @NumerZb NVarchar(30)
      Select Top 1 @NumerZb = v.VaN_Dokument FROM deleted d JOIN CDN.VatNag v On d.VaN_ZbVaNId = v.VaN_VaNId
      RAISERROR('##OPT32039##%%1%%=%s##', 16, 1, @NumerZb)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM CDN.TrwalePowiazania WHERE SrTP_DokumentTyp = 2 AND SrTP_DokumentID IN (SELECT VaN_VaNId FROM deleted))
    BEGIN
      RAISERROR('##OPT32026##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzamy powiązania z dokumentami ST innymi niż ulepszenie (one są zapisywane bezpośrednio na dokumencie)
  IF EXISTS (SELECT * FROM CDN.TrwaleHist WHERE SrH_TypDokumentu <> 1 AND SrH_DokumentTyp = 2 AND SrH_DokumentID IN (SELECT VaN_VaNId FROM deleted))
    BEGIN
      RAISERROR('##OPT32027##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzamy powiązania z dokumentami ulepszenia ST (one są zapisywane w tabeli podrzędnej względem dokumentów)
  IF EXISTS (SELECT * FROM CDN.TrwaleHistPowiazania WHERE SrHP_DokumentTyp = 2 AND SrHP_DokumentID IN (SELECT VaN_VaNID FROM deleted))
    BEGIN
      RAISERROR('##OPT32028##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM CDN.WyposazeniePowiazania WHERE WypP_DokumentTyp = 2 AND WypP_DokumentID IN (SELECT VaN_VaNId FROM deleted))
    BEGIN
      RAISERROR('##OPT32029##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (select * from CDN.DlgDokumenty where DLD_DokumentTyp = 2 and DLD_DokumentId in (SELECT VaN_VaNId FROM deleted))
    BEGIN
      RAISERROR('##OPT32030##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM CDN.AutoKoszty WHERE AuK_VaNId IN (SELECT VaN_VaNID FROM deleted))
    BEGIN
   RAISERROR('##OPT34820##', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
 END
-- obsługa kaskadowego uaktualniania zapisów źródłowych TraNag
  IF EXISTS (SELECT * FROM CDN.TraNag WHERE TrN_TypDokumentu <> 310 AND TrN_VaNId IN (SELECT VaN_VaNId FROM deleted))
    BEGIN
      UPDATE CDN.TraNag
      SET    TrN_VaNId = NULL
      WHERE  TrN_TypDokumentu <> 310 AND TrN_VaNId IN (SELECT VaN_VaNId FROM deleted);
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=TraNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
  IF EXISTS (SELECT * FROM CDN.VatNag JOIN deleted ON CDN.VatNag.VaN_VaNId = deleted.VaN_VaNOrgId)
    UPDATE CDN.VatNag SET VaN_Rodzaj = 0
    FROM CDN.VatNag JOIN deleted ON CDN.VatNag.VaN_VaNId = deleted.VaN_VaNOrgId
  IF EXISTS (SELECT * FROM CDN.VatNag JOIN deleted ON CDN.VatNag.VaN_ZbVaNID = deleted.VaN_VaNId)
    UPDATE CDN.VatNag SET VaN_Rodzaj = 0, VaN_ZbVaNID = NULL
    FROM CDN.VatNag JOIN deleted ON CDN.VatNag.VaN_ZbVaNID = deleted.VaN_VaNId
 IF EXISTS (SELECT * FROM CDN.VatNag JOIN deleted ON CDN.VatNag.VaN_VaNOrgId = deleted.VaN_VaNId)
 BEGIN
  UPDATE CDN.VatNag SET VaN_Rodzaj = 0
  FROM CDN.VatNag JOIN deleted ON CDN.VatNag.VaN_VaNOrgId = deleted.VaN_VaNId
  DELETE FROM CDN.VatNag WHERE VaN_VaNOrgId IN (select deleted.VaN_VaNId from deleted)
 END
 Declare @DokId Int
 Declare skasowane Cursor Local Fast_Forward For
  Select VaN_VaNId From deleted
 Open skasowane
 While 1=1
  Begin
   Fetch Next From skasowane InTo @DokId
   If @@Fetch_Status <> 0 Break
   Execute CDN.KasujRozliczenia 2, @DokId
  End
 Close skasowane
 Deallocate skasowane
 -- Usuwanie wymiarów analitycznych
 DECLARE @WADokumentTypZakup int = 0;
 DECLARE @WADokumentTypSprzedaz int = 0;
 select @WADokumentTypZakup=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Rejestr zakupu';
 select @WADokumentTypSprzedaz=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Rejestr sprzedaży';
 if exists(select * from CDN.WymiaryWartosci where WyW_DokumentTyp in (@WADokumentTypZakup, @WADokumentTypSprzedaz) and WyW_DokumentId in (select deleted.VaN_VaNId from deleted))
  delete from CDN.WymiaryWartosci where WyW_DokumentTyp in (@WADokumentTypZakup, @WADokumentTypSprzedaz)
  and WyW_DokumentId in (select deleted.VaN_VaNId from deleted)
 -- Ustawianie flagi dla OCR na powiąznych plikach OBD TFS 260788
 UPDATE cdn.DokNagPliki SET DnP_DlaOcr = 1 WHERE DnP_DnPId IN (SELECT VaN_DnpID FROM deleted)
-- skasowanie kodów JPK_V7
Delete From CDN.DokKodyJPKV7 Where
 DKV7_ParentTyp = 2
 And DKV7_ParentID In (Select deleted.VaN_VaNId From deleted)
-- Sprawdzenie powiązania do korekty podatku dochodowego
 IF EXISTS(
  SELECT *
  FROM CDN.DeklNag D
  JOIN CDN.KorektaPodatkuDochodowegoZD ON KZD_DkNID = D.DkN_DkNID
  JOIN deleted on (deleted.VaN_VaNID = KZD_DokumentID)
  WHERE KZD_DokumentTyp = 2 AND D.DkN_Finalna = 1
 )
 BEGIN
     RAISERROR('##OPT34841##', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
 END
Set NoCount Off

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[VatNag_Delete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.VatNag_DeleteHandler
  ON CDN.VatNag
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.VaN_VaNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=2)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.VaN_VaNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=2)
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted
   ON deleted.VaN_VaNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=2)
  )
  BEGIN
   CREATE TABLE #BZdIDs (ID INT)
   INSERT INTO #BZdIDs
    SELECT BZD_BZDID FROM CDN.BnkZdarzenia INNER JOIN deleted ON deleted.VaN_VaNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=2)
   EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001',
          @ObiektSubTyp = 'BZd_Kierunek',
          @ObiektID = 'BZd_BZdID',
          @ObiektNazwa = 'BZd_NumerPelny',
          @OperacjaTyp = 3,
          @Opis = '''''',
          @From = 'cdn.BnkZdarzenia',
          @Where = 'BZd_BZdID IN (SELECT ID FROM #BZdIDs)'
   DROP TABLE #BZdIDs
   DELETE CDN.BnkZdarzenia
   FROM CDN.BnkZdarzenia, deleted
   WHERE deleted.VaN_VaNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=2)
  END
    -- obsługa kaskadowego kasowania wierszy z tabeli CDN.DekretyNag (predekrety)
    IF EXISTS(SELECT D.VaN_PreDekID FROM Deleted D WHERE D.VaN_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.VaN_PreDekId = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF

GO
Create Trigger CDN.VatNag_InsertUpdate_Trigger
  On CDN.VatNag
  For Insert, Update
As
Set NoCount On
Declare
  @VaNId         Int,
  @KPRId         Int,
  @RYCId         Int,
  @DekId         Int,
  @PodmiotTyp    Int,
  @PodId         Int,
  @PodmiotZalTyp Int,
  @PodZalId      Int,
  @RokMies       Int,
  @DataZap       Datetime,
  @Termin        Datetime,
  @IdentKsieg    NVarchar(50),
  @IdentKsiegStr NVarchar(24),
  @IdentKsiegNr  Int,
  @Rejestr       NVarchar(20),
  @ImportRowId   NVarchar(36),
  @Typ           Int,
  @DeklRokMies   Int,
  @DeklRokMiesKasa Int,
  @RozliczacVat7 Int,
  @AutoVat7Kasa  Int,
 @TrNId     Int,
 @VanOrgId    Int,
 @DefiniowalnySchematID_DDfID INT,
 @DefiniowalnySchematID_Numeracja NVARCHAR(50),
 @DefiniowalnySchematID_Symbol NVARCHAR(5),
 @OObID INT
 SELECT @OObID = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer=244
Declare @TrNDekId Int
Declare Dodane Cursor Local Fast_Forward For
 Select
  VaN_VaNId         ,
  VaN_KPRId         ,
  VaN_RYCId         ,
  VaN_DekId         ,
  VaN_Typ           ,
  VaN_PodmiotTyp    ,
  VaN_PodId         ,
  VaN_PodmiotZalTyp ,
  VaN_PodZalId      ,
  VaN_RokMies       ,
  VaN_DeklRokMies   ,
  Van_DeklRokMiesKasa,
  VaN_DataZap       ,
  VaN_Termin        ,
  VaN_IdentKsieg    ,
  VaN_Rejestr       ,
  VaN_ImportRowId   ,
  VaN_RozliczacVat7 ,
  VaN_AutoVat7Kasa  ,
 VaN_TrNId      ,
 VaN_VanOrgId
 From inserted
Open Dodane
While 1=1
  Begin
    Fetch Next From Dodane InTo
      @VaNId         ,
      @KPRId         ,
      @RYCId         ,
      @DekId         ,
      @Typ           ,
      @PodmiotTyp    ,
      @PodId         ,
      @PodmiotZalTyp ,
      @PodZalId      ,
      @RokMies       ,
      @DeklRokMies   ,
      @DeklRokMiesKasa,
      @DataZap       ,
      @Termin        ,
      @IdentKsieg    ,
      @Rejestr       ,
      @ImportRowId   ,
      @RozliczacVat7 ,
      @AutoVat7Kasa  ,
    @TrNId     ,
    @VanOrgId
    If @@Fetch_Status <> 0 Break
    -- Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
    If Update (VaN_KPRId) And IsNull(@KPRId, 0) <> 0
      If Not Exists (Select * From CDN.ZapisyKPR Where KPR_KPRId = @KPRId)
        Begin
          RAISERROR('##OPT32024##%%1%%=ZapisyKPR##', 16, 1)
          RollBack Tran
          Return
        End
    -- Sprawdzanie obecności wierszy w tabeli nadrzędnej Ryczalt
    If Update (VaN_RycId) And IsNull(@RYCId, 0) <> 0
      If Not Exists (Select * From CDN.Ryczalt Where RYC_RYCId = @RYCId)
        Begin
          RAISERROR('##OPT32024##%%1%%=Ryczalt##', 16, 1)
          RollBack Tran
          Return
        End
    -- Sprawdzanie obecności wierszy w tabeli nadrzędnej Dekrety
    If Update (VaN_DekId) And IsNull(@DekId, 0) <> 0
      If Not Exists (Select * From CDN.DekretyNag Where DeN_DeNId = @DekId)
        Begin
          RAISERROR('##OPT32024##%%1%%=DekretyNag##', 16, 1)
          RollBack Tran
          Return
        End
    -- Sprawdzanie powiązania z podmiotem
    If (Update (VaN_PodmiotTyp) Or Update (VaN_PodId))
      Begin
        If IsNull(@PodmiotTyp, 0) <> 0 And IsNull(@PodId, 0) <> 0
          Begin
            If @PodmiotTyp = 1
              Begin
              --  Sprawdzanie obecności wiersza w tabeli Kontrahenci
                If Not Exists (Select * From CDN.Kontrahenci Where Knt_KntId = @PodId)
                  Begin
                    RAISERROR('##OPT32024##%%1%%=Kontrahenci##', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @PodmiotTyp = 2
              Begin
              --  Sprawdzanie obecności wiersza w tabeli BnkNazwy
                If Not Exists (Select * From CDN.BnkNazwy Where BNa_BNaId = @PodId)
                  Begin
                    RAISERROR('##OPT32024##%%1%%=BnkNazwy##', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @PodmiotTyp = 3
              Begin
              --  Sprawdzanie obecności wiersza w tabeli PracKod
                If Not Exists (Select * From CDN.PracKod Where Pra_PraId = @PodId)
                  Begin
                    RAISERROR('##OPT32024##%%1%%=PracKod##', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
            If @PodmiotTyp = 5
              Begin
              --  Sprawdzanie obecności wiersza w tabeli Urzedy
                If Not Exists (Select * From CDN.Urzedy Where Urz_UrzId = @PodId)
                  Begin
                    RAISERROR('##OPT32024##%%1%%=Urzedy##', 16, 1)
                    RollBack Tran
                    Return
                  End
              End
          End
        Else
          Begin
            Update CDN.VatNag
             Set VaN_PodmiotTyp = 1, VaN_PodId = 1
             Where VaN_VaNId = @VaNId
          End
      End
    -- Sprawdzanie powiązania z zaliczkobiorcą
    If (Update (VaN_PodmiotZalTyp) Or Update (VaN_PodZalId)) And
        IsNull(@PodmiotZalTyp, 0) <> 0 And IsNull(@PodZalId, 0) <> 0
      Begin
        If @PodmiotZalTyp = 1
          Begin
          --  Sprawdzanie obecności wiersza w tabeli Kontrahenci
            If Not Exists (Select * From CDN.Kontrahenci Where Knt_KntId = @PodZalId)
              Begin
                RAISERROR('##OPT32024##%%1%%=Kontrahenci##', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @PodmiotZalTyp = 2
          Begin
          --  Sprawdzanie obecności wiersza w tabeli BnkNazwy
            If Not Exists (Select * From CDN.BnkNazwy Where BNa_BNaId = @PodZalId)
              Begin
                RAISERROR('##OPT32024##%%1%%=BnkNazwy##', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @PodmiotZalTyp = 3
          Begin
          --  Sprawdzanie obecności wiersza w tabeli PracKod
            If Not Exists (Select * From CDN.PracKod Where Pra_PraId = @PodZalId)
              Begin
                RAISERROR('##OPT32024##%%1%%=PracKod##', 16, 1)
                RollBack Tran
                Return
              End
          End
        If @PodmiotZalTyp = 5
          Begin
          --  Sprawdzanie obecności wiersza w tabeli Urzedy
            If Not Exists (Select * From CDN.Urzedy Where Urz_UrzId = @PodZalId)
              Begin
                RAISERROR('##OPT32024##%%1%%=Urzedy##', 16, 1)
                RollBack Tran
                Return
              End
          End
      End
    -- Ustalenie wartości VaN_RokMies
    If @RokMies <> 100 * Year (@DataZap) + Month (@DataZap)
      Update CDN.VatNag Set VaN_RokMies = 100 * Year (@DataZap) + Month (@DataZap) Where VaN_VaNId = @VaNId
    If @DeklRokMies = 0 And @RozliczacVat7 <> 0
      Update CDN.VatNag Set VaN_DeklRokMies = 100 * Year (@DataZap) + Month (@DataZap) Where VaN_VaNId = @VaNId
    If @Typ=1 And @DeklRokMiesKasa=0 And @RozliczacVat7 <> 0 And @AutoVat7Kasa = 0
      Update CDN.VatNag Set VaN_DeklRokMiesKasa = 100 * Year (@Termin) + Month (@Termin) Where VaN_VaNId = @VaNId
    -- Ustawienie identyfikatora ksiegowego
    If Update (VaN_IdentKsieg)
    Begin
  If @IdentKsieg = ''
  Begin
   SELECT @DefiniowalnySchematID_DDfID=CDN.CzyUzywacDefniowalnegoSchematuID(@DataZap)
   IF( @DefiniowalnySchematID_DDfID <> 0)
   BEGIN
    -- Definiowalny schemat numeracji ID księgowego
    SELECT @DefiniowalnySchematID_Numeracja=DDf_Numeracja, @DefiniowalnySchematID_Symbol=Ddf_Symbol
    FROM CDN.DokDefinicje WHERE DDf_DDfID=@DefiniowalnySchematID_DDfID
    SET @IdentKsieg = CDN.PodajIDKsiegowe(@DataZap, @Rejestr, @OObID, @DefiniowalnySchematID_DDfID, 2);
    UPDATE CDN.VatNag SET VaN_IdentKsieg=@IdentKsieg, VaN_IdentKsiegDDfID=@DefiniowalnySchematID_DDfID, VaN_IdentKsiegNumeracja=@DefiniowalnySchematID_Numeracja
    WHERE VaN_VaNId = @VaNId
   END
   ELSE
   BEGIN
    Set @IdentKsiegStr = SubString(Convert(NVarchar(4), Year(@DataZap)),3,2) + '/' + @Rejestr
    If Exists (Select * From CDN.VatNag Where VaN_IdentKsiegStr = @IdentKsiegStr)
    Or Not Exists (Select * From CDN.VatNag Where VaN_Typ = @Typ And VaN_Rejestr = @Rejestr And Year(VaN_DataZap) = Year(@DataZap) And @DataZap >= Van_DataZap And VaN_VaNId <> @VaNId)
      Begin
     Select @IdentKsiegNr = IsNull(Max(VaN_IdentKsiegNr),0)+1 From CDN.VatNag Where VaN_IdentKsiegStr = @IdentKsiegStr
     Update CDN.VatNag
       Set VaN_IdentKsieg = LTrim(Str(@IdentKsiegNr)) + '/' + @IdentKsiegStr
       Where VaN_VaNId = @VaNId
      End
    Else
      Update CDN.VatNag
     Set VaN_IdentKsieg = SubString (VaN_Rejestr, 1, 19 - Len ( LTrim ( Str (VaN_VaNId))))+'/'+LTrim( Str (VaN_VaNId))
     Where VaN_VaNId = @VaNId
   END
  End
  Else
  Begin
   IF EXISTS(SELECT VaN_VaNID FROM CDN.VatNag WHERE Van_IdentKsieg=@IdentKsieg AND VaN_VaNID<>@VaNId)
    RAISERROR('##OPT32040##%%1%%=%s##', 16, 1, @IdentKsieg)
  End
    End
    -- Aktualizacja DekId dla dokumentow przeniesionych z faktur (TraNag)
    If Update (VaN_TrNId) And IsNull(@DekId, 0) = 0
      Begin
        Set @TrNDekId = Null
        Select Top 1 @TrNDekId = TrN_DekId From CDN.TraNag Where TrN_TrNId = @TrNId And IsNull(TrN_DekId, 0) <> 0
        If @TrNDekId Is Not Null
          Update CDN.VatNag Set VaN_DekId = @TrNDekId Where VaN_VaNId = @VaNId
      End
    -- Aktualizacja DekId w skojarzonych fakturach
    If Update (VaN_DekId) And IsNull (@DekId, 0) <> 0
      If Exists (Select * From deleted)
        If Not Exists (Select * From CDN.TraNag Where TrN_VaNId = @VaNId And TrN_DekId = @DekId )
          Update CDN.TraNag Set TrN_DekId = @DekId Where TrN_VaNId = @VaNId
    -- Ustawianie unikalnego identyfikatora
    If IsNull(@ImportRowId, '') = ''
      Update CDN.VatNag Set VaN_ImportRowId = NewId() Where VaN_VaNId = @VaNId
    -- kopiowanie atrybutów; UWAGA! tylko przy akcji insert
  if exists (select * From inserted) and not exists (select * from deleted)
  begin
   declare @_IDZrodla  NVarchar(3)
   declare @_SrcID    int
   declare @_DscID    int
   declare @LastIdentity int
   set @_IDZrodla = NULL
   set @_SrcID   = NULL
   set @_DscID   = @VaNId
   if IsNull(@TrNId, 0) <> 0
    begin
     set @_IDZrodla = 'TrN'
     set @_SrcID   = @TrNId
     set @LastIdentity = @@Identity
     exec CDN.KopiujAtrybutyDoVatNag @IDZrodla=@_IDZrodla, @SrcID=@_SrcID, @DscID=@_DscID
     exec CDN.UstawIdentity @NewIdentity=@LastIdentity
    end
    -- rezygnujemy na ten czas z tej funkcjonalności
   --if IsNull(@PodId , 0) <> 0 and @PodmiotTyp = 1
   -- begin
   --  set @_IDZrodla = 'Knt'
   --  set @_SrcID   = @PodId
   --  set @LastIdentity = @@Identity
   --  exec CDN.KopiujAtrybutyDoVatNag @IDZrodla=@_IDZrodla, @SrcID=@_SrcID, @DscID=@_DscID
   --  exec CDN.UstawIdentity @NewIdentity=@LastIdentity
   -- end
  end
  End
Close Dodane
Deallocate Dodane
Set NoCount Off
