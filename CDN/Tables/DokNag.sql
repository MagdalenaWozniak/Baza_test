CREATE TABLE [CDN].[DokNag] (
    [DoN_DoNID]          INT             IDENTITY (1, 1) NOT NULL,
    [DoN_DDfId]          INT             NULL,
    [DoN_SSID]           INT             NULL,
    [DoN_ProcesKod]      NVARCHAR (20)   NOT NULL,
    [DoN_EtapBiezacyLp]  INT             NOT NULL,
    [DoN_NumerObcy]      NVARCHAR (256)  NOT NULL,
    [DoN_NumerString]    VARCHAR (31)    NOT NULL,
    [DoN_NumerPelny]     AS              ([CDN].[FN_NUMERPELNY]([DON_NUMERNR],[DON_NUMERSTRING])),
    [DoN_NumerNr]        INT             NOT NULL,
    [DoN_Tytul]          NVARCHAR (50)   NULL,
    [DoN_Dotyczy]        NVARCHAR (1024) NULL,
    [DoN_DataDok]        DATETIME        NOT NULL,
    [DoN_OpiekunID]      INT             NULL,
    [DoN_OpiekunTyp]     INT             NULL,
    [DoN_Status]         INT             NULL,
    [DoN_Typ]            INT             NULL,
    [DoN_Katalog]        INT             NULL,
    [DoN_OpeZalID]       INT             NULL,
    [DoN_StaZalId]       INT             NULL,
    [DoN_TS_Zal]         DATETIME        NOT NULL,
    [DoN_OpeModID]       INT             NULL,
    [DoN_StaModId]       INT             NULL,
    [DoN_TS_Mod]         DATETIME        NOT NULL,
    [DoN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_DoN_OpeModKod] DEFAULT ('') NOT NULL,
    [DoN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_DoN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DoN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_DoN_OpeZalKod] DEFAULT ('') NOT NULL,
    [DoN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_DoN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [DoN_ImportAppId]    VARCHAR (5)     NULL,
    [DoN_ImportRowId]    VARCHAR (36)    NULL,
    [DoN_TS_Export]      DATETIME        NULL,
    [DoN_OriginId]       INT             NULL,
    CONSTRAINT [DoN_Primary] PRIMARY KEY CLUSTERED ([DoN_DoNID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DokNagKeyNumer]
    ON [CDN].[DokNag]([DoN_NumerString] ASC, [DoN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DokNagKeyTytul]
    ON [CDN].[DokNag]([DoN_Tytul] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DONDataDok]
    ON [CDN].[DokNag]([DoN_DataDok] ASC, [DoN_NumerString] ASC, [DoN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.DokNag_InsertUpdate_Trigger
  On CDN.DokNag
  For Insert, Update
As
Set NoCount On
-- Kasowanie wskaźnika wyeksportowania
If Not Update (DoN_TS_Export) And Exists (Select * From inserted Where DoN_TS_Export Is Not Null)
  Update CDN.DokNag Set DoN_TS_Export = Null Where DoN_DoNID In (Select DoN_DoNID From inserted Where DoN_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where DoN_ImportRowId Is Null Or DoN_ImportRowId = '')
  Update CDN.DokNag Set DoN_ImportRowId = NewId()
  Where DoN_DoNID In (Select DoN_DoNID From inserted Where DoN_ImportRowId Is Null Or DoN_ImportRowId = '')
Set NoCount Off

GO
CREATE TRIGGER CDN.DokNag_Delete_Trigger
  ON CDN.DokNag
  FOR DELETE
AS
  SET NOCOUNT ON
  -- obsługa kasowania
Delete From CDN.DokPodmioty Where DoP_DoNId In (Select DoN_DoNID From deleted)
Delete From CDN.DokAtrybuty Where DAt_DoNId In (Select DoN_DoNID From deleted)
Delete From CDN.CRMDokumenty Where CRD_TypDokumentu=750 AND CRD_DokumentId In (Select DoN_DoNID From deleted)
Delete From CDN.DokRelacje Where DoR_ParentId In (Select DoN_DoNID From deleted) and DoR_ParentTyp=750
Delete From CDN.DokRelacje Where DoR_DokumentId In (Select DoN_DoNID From deleted) and DoR_DokumentTyp=750
  SET NOCOUNT OFF
