CREATE TABLE [CDN].[DokNagPliki] (
    [DnP_DnPID]          INT            IDENTITY (1, 1) NOT NULL,
    [DnP_DoNID]          INT            NULL,
    [DnP_Wersja]         SMALLINT       NOT NULL,
    [DnP_FileMode]       SMALLINT       NOT NULL,
    [DnP_DataDok]        DATETIME       NOT NULL,
    [DnP_Typ]            INT            NULL,
    [DnP_Archiwalny]     INT            NULL,
    [DnP_NazwaPliku]     NVARCHAR (255) NULL,
    [DnP_Sciezka]        NVARCHAR (255) NULL,
    [DnP_WBazie]         SMALLINT       NULL,
    [DnP_StaEditId]      INT            NULL,
    [DnP_OpeEditId]      INT            NULL,
    [DnP_OpeZalID]       INT            NULL,
    [DnP_StaZalId]       INT            NULL,
    [DnP_TS_Zal]         DATETIME       NOT NULL,
    [DnP_OpeModID]       INT            NULL,
    [DnP_StaModId]       INT            NULL,
    [DnP_TS_Mod]         DATETIME       NOT NULL,
    [DnP_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_DnP_OpeModKod] DEFAULT ('') NOT NULL,
    [DnP_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_DnP_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DnP_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_DnP_OpeZalKod] DEFAULT ('') NOT NULL,
    [DnP_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_DnP_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [DnP_DlaOcr]         INT            CONSTRAINT [DF_DnP_DlaOcr] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DnP_Primary] PRIMARY KEY CLUSTERED ([DnP_DnPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DnPDoNId] FOREIGN KEY ([DnP_DoNID]) REFERENCES [CDN].[DokNag] ([DoN_DoNID]) ON DELETE CASCADE
);


GO
Create Trigger CDN.DokNagPliki_Delete_Trigger
  On CDN.DokNagPliki
  For Delete
As
SET NOCOUNT ON
-- Skasowanie powiązanych danych w tabeli DaneBinarne
  DELETE From CDN.DaneBinarne WHERE DaB_TWAID In (SELECT DnP_DnPID FROM deleted) and DaB_Typ=2
-- Usunięcie powiązania z rejestrem vat
  IF EXISTS(SELECT * FROM sysobjects WHERE name = 'VatNag')
  BEGIN
 UPDATE cdn.VatNag SET VaN_DnPId = NULL WHERE VaN_DnPId IN (SELECT DnP_DnPID FROM deleted)
  END
SET NOCOUNT OFF
