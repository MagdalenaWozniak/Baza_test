CREATE TABLE [CDN].[KompensatyNag] (
    [KPN_KPNID]          INT             IDENTITY (1, 1) NOT NULL,
    [KPN_DDfID]          INT             NULL,
    [KPN_NumerNr]        INT             NOT NULL,
    [KPN_NumerString]    VARCHAR (31)    NOT NULL,
    [KPN_NumerPelny]     AS              ([CDN].[FN_NUMERPELNY]([KPN_NUMERNR],[KPN_NUMERSTRING])),
    [KPN_NumerObcy]      NVARCHAR (256)  NOT NULL,
    [KPN_DataDok]        DATETIME        NOT NULL,
    [KPN_PodmiotTyp]     SMALLINT        NULL,
    [KPN_PodmiotID]      INT             NULL,
    [KPN_KatID]          INT             NULL,
    [KPN_Kategoria]      VARCHAR (50)    NOT NULL,
    [KPN_Waluta]         VARCHAR (3)     NOT NULL,
    [KPN_KontoWn]        VARCHAR (50)    NOT NULL,
    [KPN_KontoMa]        VARCHAR (50)    NOT NULL,
    [KPN_DekID]          INT             NULL,
    [KPN_PreDekID]       INT             NULL,
    [KPN_Opis]           NVARCHAR (256)  NOT NULL,
    [KPN_RazemKwotaRoz]  DECIMAL (15, 2) NOT NULL,
    [KPN_ImportAppId]    VARCHAR (5)     NULL,
    [KPN_ImportRowId]    VARCHAR (36)    NULL,
    [KPN_TS_Export]      DATETIME        NULL,
    [KPN_OpeZalID]       INT             NULL,
    [KPN_StaZalID]       INT             NULL,
    [KPN_TS_Zal]         DATETIME        NOT NULL,
    [KPN_OpeModID]       INT             NULL,
    [KPN_StaModID]       INT             NULL,
    [KPN_TS_Mod]         DATETIME        NOT NULL,
    [KPN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_KPN_OpeModKod] DEFAULT ('') NOT NULL,
    [KPN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_KPN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KPN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_KPN_OpeZalKod] DEFAULT ('') NOT NULL,
    [KPN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_KPN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [KPN_Numer]          AS              (case when [KPN_NUMEROBCY]<>'' then [KPN_NUMEROBCY] else [CDN].[FN_NUMERPELNY]([KPN_NUMERNR],[KPN_NUMERSTRING]) end),
    CONSTRAINT [KPN_Primary] PRIMARY KEY CLUSTERED ([KPN_KPNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KPNDokDefinicja] FOREIGN KEY ([KPN_DDfID]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_KPNKategoria] FOREIGN KEY ([KPN_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_KPNPodmiot] FOREIGN KEY ([KPN_PodmiotID], [KPN_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPNPodmiot]
    ON [CDN].[KompensatyNag]([KPN_PodmiotID] ASC, [KPN_PodmiotTyp] ASC, [KPN_DataDok] ASC, [KPN_KPNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPNKategoria]
    ON [CDN].[KompensatyNag]([KPN_KatID] ASC, [KPN_DataDok] ASC, [KPN_KPNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KPNDokDefinicja]
    ON [CDN].[KompensatyNag]([KPN_DDfID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPNNumer]
    ON [CDN].[KompensatyNag]([KPN_NumerString] ASC, [KPN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPNNumerPelny]
    ON [CDN].[KompensatyNag]([KPN_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KPNDekrety]
    ON [CDN].[KompensatyNag]([KPN_DekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KPNPreDekrety]
    ON [CDN].[KompensatyNag]([KPN_PreDekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPNGUID]
    ON [CDN].[KompensatyNag]([KPN_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.KompensatyNag_Delete_Trigger
ON CDN.KompensatyNag
FOR DELETE
AS
SET NOCOUNT ON
-- Skasowanie relacji do dokumentów CRM
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1145 AND DoR_DokumentId IN (SELECT KPN_KPNID FROM deleted)
SET NOCOUNT OFF

GO
Create Trigger CDN.KompensatyNag_InsertUpdate_Trigger
  On CDN.KompensatyNag
  For Insert, Update
As
Set NoCount On
-- Kasowanie wskanika wyeksportowania
-- If Not Update (KPN_TS_Export) And Exists (Select * From inserted Where KPN_TS_Export Is Not Null)
--  Update CDN.KompensatyNag Set KPN_TS_Export = Null Where KPN_KPNID In (Select KPN_KPNID From inserted Where KPN_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where KPN_ImportRowId Is Null Or KPN_ImportRowId = '')
  Update CDN.KompensatyNag Set KPN_ImportRowId = NewId()
  Where KPN_KPNID In (Select KPN_KPNID From inserted Where KPN_ImportRowId Is Null Or KPN_ImportRowId = '')
Set NoCount Off
