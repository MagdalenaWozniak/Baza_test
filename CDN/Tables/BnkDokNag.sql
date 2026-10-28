CREATE TABLE [CDN].[BnkDokNag] (
    [BDN_BDNId]                INT             IDENTITY (1, 1) NOT NULL,
    [BDN_Typ]                  SMALLINT        NOT NULL,
    [BDN_DDfId]                INT             NULL,
    [BDN_NumerNr]              INT             NOT NULL,
    [BDN_NumerString]          VARCHAR (31)    NOT NULL,
    [BDN_NumerPelny]           AS              ([CDN].[FN_NUMERPELNY]([BDN_NUMERNR],[BDN_NUMERSTRING])),
    [BDN_DataDok]              DATETIME        NOT NULL,
    [BDN_PodmiotTyp]           SMALLINT        NULL,
    [BDN_PodmiotID]            INT             NULL,
    [BDN_KatID]                INT             NULL,
    [BDN_Kategoria]            VARCHAR (50)    NOT NULL,
    [BDN_Waluta]               VARCHAR (3)     NOT NULL,
    [BDN_KursNumer]            INT             NOT NULL,
    [BDN_KursL]                DECIMAL (15, 4) NOT NULL,
    [BDN_KursM]                DECIMAL (5)     NOT NULL,
    [BDN_RazemKwota1]          DECIMAL (15, 2) NOT NULL,
    [BDN_RazemKwotaSys1]       DECIMAL (15, 2) NOT NULL,
    [BDN_RazemKwota2]          DECIMAL (15, 2) NOT NULL,
    [BDN_RazemKwotaSys2]       DECIMAL (15, 2) NOT NULL,
    [BDN_OdsetkiTyp]           TINYINT         NOT NULL,
    [BDN_OdsetkiStopa]         DECIMAL (7, 2)  NOT NULL,
    [BDN_OdsetkiPodatkoweProg] DECIMAL (15, 2) CONSTRAINT [DF_BDN_OdsetkiPodatkoweProg] DEFAULT ((0)) NOT NULL,
    [BDN_KosztyDodatkowe]      DECIMAL (15, 2) CONSTRAINT [DF_BDN_KosztyDodatkowe] DEFAULT ((0)) NOT NULL,
    [BDN_KosztyDodatkoweSys]   DECIMAL (15, 2) CONSTRAINT [DF_BDN_KosztyDodatkoweSys] DEFAULT ((0)) NOT NULL,
    [BDN_GenerujPlatnosciKst]  TINYINT         CONSTRAINT [DF_BDN_GenerujPlatnosciKst] DEFAULT ((0)) NOT NULL,
    [BDN_FPlIDKst]             INT             NULL,
    [BDN_TerminKst]            DATETIME        NULL,
    [BDN_GenerujPlatnosciOds]  TINYINT         CONSTRAINT [DF_BDN_GenerujPlatnosciOds] DEFAULT ((0)) NOT NULL,
    [BDN_FPlIDOds]             INT             NULL,
    [BDN_TerminOds]            DATETIME        NULL,
    [BDN_Uwagi]                NVARCHAR (254)  NOT NULL,
    [BDN_DekID]                INT             NULL,
    [BDN_PreDekID]             INT             NULL,
    [BDN_Windykacja]           INT             CONSTRAINT [DF_BDN_Windykacja] DEFAULT ((0)) NOT NULL,
    [BDN_OpeZalID]             INT             NULL,
    [BDN_StaZalId]             INT             NULL,
    [BDN_TS_Zal]               DATETIME        NOT NULL,
    [BDN_OpeModID]             INT             NULL,
    [BDN_StaModId]             INT             NULL,
    [BDN_TS_Mod]               DATETIME        NOT NULL,
    [BDN_UwzglNalez]           TINYINT         CONSTRAINT [DF_BDN_UwzglNalez] DEFAULT ((0)) NOT NULL,
    [BDN_UwzglZobow]           TINYINT         CONSTRAINT [DF_BDN_UwzglZobow] DEFAULT ((0)) NOT NULL,
    [BDN_UwzglPrzych]          TINYINT         CONSTRAINT [DF_BDN_UwzglPrzych] DEFAULT ((0)) NOT NULL,
    [BDN_UwzglRozch]           TINYINT         CONSTRAINT [DF_BDN_UwzglRozch] DEFAULT ((0)) NOT NULL,
    [BDN_UwzglBufor]           TINYINT         CONSTRAINT [DF_BDN_UwzglBufor] DEFAULT ((0)) NOT NULL,
    [BDN_OpeModKod]            VARCHAR (20)    CONSTRAINT [DF_BDN_OpeModKod] DEFAULT ('') NOT NULL,
    [BDN_OpeModNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_BDN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BDN_OpeZalKod]            VARCHAR (20)    CONSTRAINT [DF_BDN_OpeZalKod] DEFAULT ('') NOT NULL,
    [BDN_OpeZalNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_BDN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [BDN_Primary] PRIMARY KEY CLUSTERED ([BDN_BDNId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BDNDokDefinicja] FOREIGN KEY ([BDN_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_BDNKategoria] FOREIGN KEY ([BDN_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_BDNPodmiot] FOREIGN KEY ([BDN_PodmiotID], [BDN_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BDNPodmiot]
    ON [CDN].[BnkDokNag]([BDN_PodmiotID] ASC, [BDN_PodmiotTyp] ASC, [BDN_Typ] ASC, [BDN_DataDok] ASC, [BDN_BDNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BDNKategoria]
    ON [CDN].[BnkDokNag]([BDN_KatID] ASC, [BDN_Typ] ASC, [BDN_DataDok] ASC, [BDN_BDNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BDNDokDefinicja]
    ON [CDN].[BnkDokNag]([BDN_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BDNNumer]
    ON [CDN].[BnkDokNag]([BDN_NumerString] ASC, [BDN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BDNNumerPelny]
    ON [CDN].[BnkDokNag]([BDN_Typ] ASC, [BDN_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.BnkDokNag_Delete_Trigger
  On CDN.BnkDokNag
  For Delete
As
Set NoCount On
-- Skasowanie relacji do dokumentów CRM  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp IN (1002, 1134) AND DoR_DokumentId=deleted.BDN_BDNId
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=222 AND DoR_DokumentId=deleted.BDN_BDNId
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_ParentTyp=222 AND DoR_ParentId=deleted.BDN_BDNId
Set NoCount Off

GO
CREATE TRIGGER CDN.BnkDokNag_DeleteHandler
  ON CDN.BnkDokNag
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted
   ON deleted.BDN_BDNId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp IN (106, 107))
  )
  DELETE CDN.BnkZdarzenia
  FROM CDN.BnkZdarzenia, deleted
  WHERE deleted.BDN_BDNId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp IN (106, 107))
SET NOCOUNT OFF
