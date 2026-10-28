CREATE TABLE [CDN].[FaCyklNag] (
    [FCN_FcNID]                       INT             IDENTITY (1, 1) NOT NULL,
    [FCN_Kod]                         VARCHAR (20)    NOT NULL,
    [FCN_Nazwa]                       NVARCHAR (50)   NOT NULL,
    [FCN_DataOstatniej]               DATETIME        NULL,
    [FCN_Nieaktywny]                  TINYINT         NOT NULL,
    [FCN_OkresCyklu]                  TINYINT         NOT NULL,
    [FCN_DzienTygodnia]               TINYINT         NOT NULL,
    [FCN_DzienMiesiaca]               TINYINT         NULL,
    [FCN_PowtarzajCo]                 TINYINT         NULL,
    [FCN_PowtarzajCoData]             DATETIME        NULL,
    [FCN_TypDokumentu]                INT             NULL,
    [FCN_DdfID]                       INT             NULL,
    [FCN_NumerNr]                     INT             NULL,
    [FCN_NumerString]                 VARCHAR (31)    NULL,
    [FCN_DoBufora]                    TINYINT         NOT NULL,
    [FCN_MagID]                       INT             NULL,
    [FCN_TypNB]                       TINYINT         NOT NULL,
    [FCN_DataDokTyp]                  TINYINT         NOT NULL,
    [FCN_DataDok]                     DATETIME        NOT NULL,
    [FCN_DataSprzedazyTyp]            TINYINT         NOT NULL,
    [FCN_DataSprzedazy]               DATETIME        NOT NULL,
    [FCN_FPlTyp]                      TINYINT         NOT NULL,
    [FCN_FplID]                       INT             NULL,
    [FCN_TerminPlatTyp]               TINYINT         NOT NULL,
    [FCN_TerminPlatDzien]             SMALLINT        NULL,
    [FCN_KategoriaTyp]                TINYINT         NOT NULL,
    [FCN_KatID]                       INT             NULL,
    [FCN_Kategoria]                   VARCHAR (50)    NOT NULL,
    [FCN_Uwagi]                       NVARCHAR (254)  NOT NULL,
    [FCN_Przypomnienie]               TINYINT         NOT NULL,
    [FCN_OpeZalID]                    INT             NULL,
    [FCN_StaZalID]                    INT             NULL,
    [FCN_TS_Zal]                      DATETIME        NOT NULL,
    [FCN_OpeModID]                    INT             NULL,
    [FCN_StaModID]                    INT             NULL,
    [FCN_TS_Mod]                      DATETIME        NOT NULL,
    [FCN_DataDokDzienMiesiaca]        TINYINT         NULL,
    [FCN_DataSprzedazyDzienMiesiaca]  TINYINT         NULL,
    [FCN_DataKolejnegoGen]            DATETIME        NULL,
    [FCN_CzasPrzypomnienia]           DATETIME        NULL,
    [FCN_OpisNaFakturze]              NVARCHAR (1024) NULL,
    [FCN_GenerujAutomatycznie]        TINYINT         CONSTRAINT [DF_FCN_GenerujAutomatycznie] DEFAULT ((0)) NOT NULL,
    [FCN_AutomatWyslijEmailDoKnt]     TINYINT         CONSTRAINT [DF_FCN_AutomatWyslijEmailDoKnt] DEFAULT ((0)) NOT NULL,
    [FCN_AutomatEmailSzablonId]       INT             NULL,
    [FCN_AutomatWydrukId]             INT             NULL,
    [FCN_AutomatWydrukStandardowy]    TINYINT         NULL,
    [FCN_Waluta]                      VARCHAR (3)     CONSTRAINT [DF_FCN_Waluta] DEFAULT ('') NOT NULL,
    [FCN_KursNumer]                   INT             CONSTRAINT [DF_FCN_KursNumer] DEFAULT ((-1)) NOT NULL,
    [FCN_KursL]                       DECIMAL (15, 4) CONSTRAINT [DF_FCN_KursL] DEFAULT ((1)) NOT NULL,
    [FCN_KursM]                       DECIMAL (5)     CONSTRAINT [DF_FCN_KursM] DEFAULT ((1)) NOT NULL,
    [FCN_DataKur]                     DATETIME        CONSTRAINT [DF_FCN_DataKur] DEFAULT ((0)) NOT NULL,
    [FCN_OpeModKod]                   VARCHAR (20)    CONSTRAINT [DF_FCN_OpeModKod] DEFAULT ('') NOT NULL,
    [FCN_OpeModNazwisko]              NVARCHAR (50)   CONSTRAINT [DF_FCN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [FCN_OpeZalKod]                   VARCHAR (20)    CONSTRAINT [DF_FCN_OpeZalKod] DEFAULT ('') NOT NULL,
    [FCN_OpeZalNazwisko]              NVARCHAR (50)   CONSTRAINT [DF_FCN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [FCN_BlokujDuplikatyKnt]          TINYINT         CONSTRAINT [DF_FCN_BlokujDuplikatyKnt] DEFAULT ((1)) NOT NULL,
    [FCN_PrzenosNaFaAtrybutyKartyKnt] TINYINT         CONSTRAINT [DF_FCN_PrzenosNaFaAtrybutyKartyKnt] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [FCN_Primary] PRIMARY KEY CLUSTERED ([FCN_FcNID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FCNKod]
    ON [CDN].[FaCyklNag]([FCN_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [FCNNazwa]
    ON [CDN].[FaCyklNag]([FCN_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.FaCyklNag_Delete_Trigger
  ON CDN.FaCyklNag
  FOR DELETE
AS
  SET NOCOUNT ON
  DELETE FROM cdn.FaCyklElem WHERE FcE_FcNID IN (SELECT FcN_FcNID FROM deleted)
  DELETE FROM cdn.FaCyklKnt  WHERE FcK_FcNID IN (SELECT FcN_FcNID FROM deleted)
  SET NOCOUNT OFF
