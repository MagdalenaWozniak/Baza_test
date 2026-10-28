CREATE TABLE [CDN].[SrsZlecenia] (
    [SrZ_SrZId]                   INT             IDENTITY (1, 1) NOT NULL,
    [SrZ_DDfId]                   INT             NOT NULL,
    [SrZ_KatID]                   INT             NULL,
    [SrZ_NumerString]             VARCHAR (31)    NOT NULL,
    [SrZ_NumerNr]                 INT             NOT NULL,
    [SrZ_NumerPelny]              AS              ([CDN].[FN_NUMERPELNY]([SRZ_NUMERNR],[SRZ_NUMERSTRING])),
    [SrZ_Bufor]                   SMALLINT        NOT NULL,
    [SrZ_Stan]                    SMALLINT        NOT NULL,
    [SrZ_DokStatus]               NVARCHAR (32)   NOT NULL,
    [SrZ_PodmiotTyp]              SMALLINT        NULL,
    [SrZ_PodmiotId]               INT             NULL,
    [SrZ_PodNazwa1]               NVARCHAR (50)   NOT NULL,
    [SrZ_PodNazwa2]               NVARCHAR (50)   NOT NULL,
    [SrZ_PodNazwa3]               NVARCHAR (250)  NOT NULL,
    [SrZ_PodKraj]                 NVARCHAR (40)   NOT NULL,
    [SrZ_PodWojewodztwo]          NVARCHAR (40)   NOT NULL,
    [SrZ_PodPowiat]               NVARCHAR (40)   NOT NULL,
    [SrZ_PodGmina]                NVARCHAR (40)   NOT NULL,
    [SrZ_PodUlica]                NVARCHAR (40)   NOT NULL,
    [SrZ_PodNrDomu]               NVARCHAR (10)   NOT NULL,
    [SrZ_PodNrLokalu]             NVARCHAR (10)   NOT NULL,
    [SrZ_PodMiasto]               NVARCHAR (40)   NOT NULL,
    [SrZ_PodKodPocztowy]          VARCHAR (10)    NOT NULL,
    [SrZ_PodPoczta]               NVARCHAR (40)   NOT NULL,
    [SrZ_PodAdres2]               NVARCHAR (40)   NOT NULL,
    [SrZ_Telefon]                 VARCHAR (40)    NOT NULL,
    [SrZ_Email]                   NVARCHAR (127)  NOT NULL,
    [SrZ_OdbiorcaTyp]             SMALLINT        NULL,
    [SrZ_OdbID]                   INT             NULL,
    [SrZ_OdbNazwa1]               NVARCHAR (50)   NOT NULL,
    [SrZ_OdbNazwa2]               NVARCHAR (50)   NOT NULL,
    [SrZ_OdbNazwa3]               NVARCHAR (250)  NOT NULL,
    [SrZ_OdbKraj]                 NVARCHAR (40)   NOT NULL,
    [SrZ_OdbWojewodztwo]          NVARCHAR (40)   NOT NULL,
    [SrZ_OdbPowiat]               NVARCHAR (40)   NOT NULL,
    [SrZ_OdbGmina]                NVARCHAR (40)   NOT NULL,
    [SrZ_OdbUlica]                NVARCHAR (40)   NOT NULL,
    [SrZ_OdbNrDomu]               NVARCHAR (10)   NOT NULL,
    [SrZ_OdbNrLokalu]             NVARCHAR (10)   NOT NULL,
    [SrZ_OdbMiasto]               NVARCHAR (40)   NOT NULL,
    [SrZ_OdbKodPocztowy]          VARCHAR (10)    NOT NULL,
    [SrZ_OdbPoczta]               NVARCHAR (40)   NOT NULL,
    [SrZ_OdbAdres2]               NVARCHAR (40)   NOT NULL,
    [SrZ_OdbTelefon]              VARCHAR (40)    NOT NULL,
    [SrZ_OdbEmail]                NVARCHAR (127)  NOT NULL,
    [SrZ_ZlecajacyId]             INT             NULL,
    [SrZ_ZlecajacyNazwisko]       NVARCHAR (40)   NOT NULL,
    [SrZ_ProwadzacyTyp]           SMALLINT        NULL,
    [SrZ_ProwadzacyId]            INT             NULL,
    [SrZ_Priorytet]               TINYINT         NOT NULL,
    [SrZ_SrUId]                   INT             NULL,
    [SrZ_DataDok]                 DATETIME        NOT NULL,
    [SrZ_DataPrzyjecia]           DATETIME        NULL,
    [SrZ_DataRealizacji]          DATETIME        NULL,
    [SrZ_CzasRealizacji]          DATETIME        NULL,
    [SrZ_DataZamkniecia]          DATETIME        NULL,
    [SrZ_MagId]                   INT             NULL,
    [SrZ_EtapId]                  INT             NULL,
    [SrZ_EtapOpis]                NVARCHAR (255)  NULL,
    [SrZ_EtapData]                DATETIME        NULL,
    [SrZ_Wykonano]                DECIMAL (5, 2)  NOT NULL,
    [SrZ_Opis]                    NVARCHAR (MAX)  NOT NULL,
    [SrZ_TypNB]                   TINYINT         NOT NULL,
    [SrZ_WartoscNetto]            DECIMAL (15, 2) NOT NULL,
    [SrZ_WartoscBrutto]           DECIMAL (15, 2) NOT NULL,
    [SrZ_WartoscNettoDoFA]        DECIMAL (15, 2) NOT NULL,
    [SrZ_WartoscBruttoDoFA]       DECIMAL (15, 2) NOT NULL,
    [SrZ_CzasRealizacjiCzynnosci] INT             NOT NULL,
    [SrZ_ZbiorczeFaCzesci]        TINYINT         NOT NULL,
    [SrZ_ZbiorczeTwrIdCzesci]     INT             NULL,
    [SrZ_ZbiorczeFaCzynnosci]     TINYINT         NOT NULL,
    [SrZ_ZbiorczeTwrIdCzynnosci]  INT             NULL,
    [SrZ_Waluta]                  VARCHAR (3)     CONSTRAINT [DF_SrZ_Waluta] DEFAULT ('') NOT NULL,
    [SrZ_KursNumer]               INT             CONSTRAINT [DF_SrZ_KursNumer] DEFAULT ((-1)) NOT NULL,
    [SrZ_KursL]                   DECIMAL (15, 4) CONSTRAINT [DF_SrZ_KursL] DEFAULT ((1)) NOT NULL,
    [SrZ_KursM]                   DECIMAL (5)     CONSTRAINT [DF_SrZ_KursM] DEFAULT ((1)) NOT NULL,
    [SrZ_DataKur]                 DATETIME        CONSTRAINT [DF_SrZ_DataKur] DEFAULT ((0)) NOT NULL,
    [SrZ_WartoscNettoDoFAPLN]     DECIMAL (15, 2) CONSTRAINT [DF_SrZ_WartoscNettoDoFAPLN] DEFAULT ((0)) NOT NULL,
    [SrZ_WartoscBruttoDoFAPLN]    DECIMAL (15, 2) CONSTRAINT [DF_SrZ_WartoscBruttoDoFAPLN] DEFAULT ((0)) NOT NULL,
    [SrZ_WartoscNettoPLN]         DECIMAL (15, 2) CONSTRAINT [DF_SrZ_WartoscNettoPLN] DEFAULT ((0)) NOT NULL,
    [SrZ_WartoscBruttoPLN]        DECIMAL (15, 2) CONSTRAINT [DF_SrZ_WartoscBruttoPLN] DEFAULT ((0)) NOT NULL,
    [SrZ_OpeZalId]                INT             NULL,
    [SrZ_StaZalId]                INT             NULL,
    [SrZ_TS_Zal]                  DATETIME        NOT NULL,
    [SrZ_OpeModId]                INT             NULL,
    [SrZ_StaModId]                INT             NULL,
    [SrZ_TS_Mod]                  DATETIME        NOT NULL,
    [SrZ_PrzedstawicielId]        INT             NULL,
    [SrZ_PrzedstawicielNazwisko]  NVARCHAR (40)   NULL,
    [SrZ_PrzedstawicielTelefon]   NVARCHAR (40)   NULL,
    [SrZ_ZlecajacyTelefon]        NVARCHAR (40)   NULL,
    [SrZ_FplTyp]                  TINYINT         CONSTRAINT [DF_SrZ_FplTyp] DEFAULT ((0)) NOT NULL,
    [SrZ_FplId]                   INT             NULL,
    [SrZ_TerminPlatTyp]           TINYINT         CONSTRAINT [DF_SrZ_TerminPlatTyp] DEFAULT ((0)) NOT NULL,
    [SrZ_TerminPlatData]          DATETIME        NULL,
    [SrZ_OpeModKod]               VARCHAR (20)    CONSTRAINT [DF_SrZ_OpeModKod] DEFAULT ('') NOT NULL,
    [SrZ_OpeModNazwisko]          NVARCHAR (50)   CONSTRAINT [DF_SrZ_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SrZ_OpeZalKod]               VARCHAR (20)    CONSTRAINT [DF_SrZ_OpeZalKod] DEFAULT ('') NOT NULL,
    [SrZ_OpeZalNazwisko]          NVARCHAR (50)   CONSTRAINT [DF_SrZ_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SrZ_Primary] PRIMARY KEY CLUSTERED ([SrZ_SrZId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrZKategoria] FOREIGN KEY ([SrZ_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_SrZMagId] FOREIGN KEY ([SrZ_MagId]) REFERENCES [CDN].[Magazyny] ([Mag_MagId]),
    CONSTRAINT [FK_SrZOdbiorca] FOREIGN KEY ([SrZ_OdbID], [SrZ_OdbiorcaTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_SrZPodmiot] FOREIGN KEY ([SrZ_PodmiotId], [SrZ_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_SrZZlecajacy] FOREIGN KEY ([SrZ_ZlecajacyId]) REFERENCES [CDN].[KntOsoby] ([KnO_KnOId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrZKategoria]
    ON [CDN].[SrsZlecenia]([SrZ_KatID] ASC, [SrZ_SrZId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrZUrzadzenia]
    ON [CDN].[SrsZlecenia]([SrZ_SrUId] ASC, [SrZ_SrZId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrZMagId]
    ON [CDN].[SrsZlecenia]([SrZ_MagId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrZPodmiot]
    ON [CDN].[SrsZlecenia]([SrZ_PodmiotId] ASC, [SrZ_PodmiotTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrZDokDef]
    ON [CDN].[SrsZlecenia]([SrZ_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrZNumer]
    ON [CDN].[SrsZlecenia]([SrZ_NumerString] ASC, [SrZ_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SsZDataDok]
    ON [CDN].[SrsZlecenia]([SrZ_DataDok] ASC, [SrZ_NumerString] ASC, [SrZ_NumerNr] ASC, [SrZ_SrZId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrZNumerPelny]
    ON [CDN].[SrsZlecenia]([SrZ_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrZProwadzacy]
    ON [CDN].[SrsZlecenia]([SrZ_ProwadzacyId] ASC, [SrZ_ProwadzacyTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrZEtap]
    ON [CDN].[SrsZlecenia]([SrZ_EtapId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrZZlecajacy]
    ON [CDN].[SrsZlecenia]([SrZ_ZlecajacyId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrZOdbiorca]
    ON [CDN].[SrsZlecenia]([SrZ_OdbID] ASC, [SrZ_OdbiorcaTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.SrsZlecenia_InsertUpdate_Trigger
ON CDN.SrsZlecenia
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
    IF Update (SrZ_CzasRealizacji)
    BEGIN
  If Exists( select * from inserted where inserted.SrZ_CzasRealizacji Is Null )
     Begin
   update cdn.SrsZlecenia
   set cdn.SrsZlecenia.SrZ_CzasRealizacji = convert(datetime,'1899-12-30  0:00:00',120)
   where cdn.SrsZlecenia.SrZ_SrZId in (select inserted.SrZ_SrZId from inserted where inserted.SrZ_CzasRealizacji Is Null)
     End
    End
    IF Update (SrZ_Stan)
    BEGIN
  UPDATE cdn.SrsCzesci
  SET
   SrC_IloscPobieranaDisp = CASE WHEN SrC_Status&1=1 OR SrC_Status&4=4 THEN SrC_IloscPobierana ELSE 0.00 END,
   SrC_IloscWydanaDisp = CASE WHEN CDN.StatusWydaniaCzesciNaZleceniu(SrC_SrCId) = 0 THEN 0.00 ELSE SrC_Ilosc END,
   SrC_IloscDoPobraniaDisp = CASE WHEN SrC_Status&1=1 OR SrC_Status&4=4 THEN 0.00 ELSE SrC_IloscPobierana END,
   SrC_IloscDoWydaniaDisp = CASE WHEN CDN.StatusWydaniaCzesciNaZleceniu(SrC_SrCId) = 0 THEN SrC_Ilosc ELSE 0.00 END,
   SrC_MmZwrotDisp = CASE WHEN SrC_MmZwrot=0 THEN 0.00 ELSE SrC_IloscPobierana-SrC_Ilosc END
  WHERE SrC_SrZId IN (SELECT inserted.SrZ_SrZId FROM inserted)
 END
  SET NOCOUNT OFF

GO
Create Trigger CDN.SrsZlecenia_Delete_Trigger
  On CDN.SrsZlecenia
  For Delete
As
Set NoCount On
-- Skasowanie relacji CRM - dokument serwisowy
  DELETE CDN.CrmDokumenty
  FROM CDN.CrmDokumenty JOIN deleted ON CRD_TypDokumentu=900 AND CRD_DokumentId=deleted.SrZ_SrZId
-- Skasowanie relacji do dokumentów z biblioteki  (WJ)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=900 AND DoR_DokumentId=deleted.SrZ_SrZId
Set NoCount Off
