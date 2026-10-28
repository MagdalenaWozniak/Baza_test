CREATE TABLE [CDN].[Rodzina] (
    [RDZ_RdzId]          INT           IDENTITY (1, 1) NOT NULL,
    [RDZ_PraId]          INT           NOT NULL,
    [RDZ_Nazwisko]       NVARCHAR (40) NOT NULL,
    [RDZ_Imie]           NVARCHAR (30) NOT NULL,
    [RDZ_DataUr]         DATETIME      NULL,
    [RDZ_Pesel]          NVARCHAR (11) NOT NULL,
    [RDZ_NipE]           VARCHAR (13)  NOT NULL,
    [RDZ_NipKraj]        VARCHAR (2)   NOT NULL,
    [RDZ_DowodOsob]      NVARCHAR (9)  NOT NULL,
    [RDZ_Paszport]       NVARCHAR (9)  NOT NULL,
    [RDZ_KodPokrew]      INT           NULL,
    [RDZ_DataUpraw]      DATETIME      NULL,
    [RDZ_DataUprawDo]    DATETIME      NULL,
    [RDZ_PozostajeUtrz]  TINYINT       NOT NULL,
    [RDZ_PozostajeGosp]  TINYINT       NOT NULL,
    [RDZ_KodNiepelnosp]  INT           NOT NULL,
    [RDZ_ADRKraj]        NVARCHAR (40) NOT NULL,
    [RDZ_ADRWojewodztwo] NVARCHAR (40) NOT NULL,
    [RDZ_ADRPowiat]      NVARCHAR (40) NOT NULL,
    [RDZ_ADRGmina]       NVARCHAR (41) NOT NULL,
    [RDZ_ADRUlica]       NVARCHAR (40) NOT NULL,
    [RDZ_ADRNrDomu]      NVARCHAR (10) NOT NULL,
    [RDZ_ADRNrLokalu]    NVARCHAR (11) NOT NULL,
    [RDZ_ADRMiasto]      NVARCHAR (40) NOT NULL,
    [RDZ_ADRKodPocztowy] VARCHAR (10)  NOT NULL,
    [RDZ_ADRPoczta]      NVARCHAR (40) NOT NULL,
    [RDZ_ADRAdres2]      NVARCHAR (40) NOT NULL,
    [RDZ_MstIdADR]       INT           NULL,
    [RDZ_MstPocztaADR]   INT           NULL,
    [RDZ_OpeZalId]       INT           NULL,
    [RDZ_StaZalId]       INT           NULL,
    [RDZ_TS_Zal]         DATETIME      NOT NULL,
    [RDZ_OpeModId]       INT           NULL,
    [RDZ_StaModId]       INT           NULL,
    [RDZ_TS_Mod]         DATETIME      NOT NULL,
    [RDZ_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_RDZ_OpeModKod] DEFAULT ('') NOT NULL,
    [RDZ_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_RDZ_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [RDZ_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_RDZ_OpeZalKod] DEFAULT ('') NOT NULL,
    [RDZ_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_RDZ_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [RDZ_Primary] PRIMARY KEY CLUSTERED ([RDZ_RdzId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_RDZPraLink] FOREIGN KEY ([RDZ_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [RDZPraLink]
    ON [CDN].[Rodzina]([RDZ_PraId] ASC, [RDZ_Nazwisko] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Rodzina_DeleteHandler
  ON CDN.Rodzina
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.Dodatki INNER JOIN deleted
   ON deleted.RDZ_RdzId = CDN.Dodatki.DOD_RdzId AND (CDN.Dodatki.DOD_RdzId IS NOT NULL)
  )
  DELETE CDN.Dodatki
  FROM CDN.Dodatki, deleted
  WHERE deleted.RDZ_RdzId = CDN.Dodatki.DOD_RdzId AND (CDN.Dodatki.DOD_RdzId IS NOT NULL)
SET NOCOUNT OFF
