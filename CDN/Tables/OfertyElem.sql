CREATE TABLE [CDN].[OfertyElem] (
    [OfL_OfLId]                  INT             IDENTITY (1, 1) NOT NULL,
    [OfL_OfDId]                  INT             NOT NULL,
    [OfL_Lp]                     INT             NOT NULL,
    [OfL_TwrId]                  INT             NOT NULL,
    [OfL_TwrKod]                 NVARCHAR (50)   NOT NULL,
    [OfL_TwrNazwa]               NVARCHAR (255)  NOT NULL,
    [OfL_TwrOpis]                NVARCHAR (1024) NOT NULL,
    [OfL_CenyKontrahenta]        INT             CONSTRAINT [DF_OfL_CenyKontrahenta] DEFAULT ((0)) NOT NULL,
    [OfL_Atr1_DeAId]             INT             NULL,
    [OfL_Atr1_Kod]               VARCHAR (20)    CONSTRAINT [DF_OfL_Atr1_Kod] DEFAULT ('') NOT NULL,
    [OfL_Atr1_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_OfL_Atr1_Wartosc] DEFAULT ('') NOT NULL,
    [OfL_Atr2_DeAId]             INT             NULL,
    [OfL_Atr2_Kod]               VARCHAR (20)    CONSTRAINT [DF_OfL_Atr2_Kod] DEFAULT ('') NOT NULL,
    [OfL_Atr2_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_OfL_Atr2_Wartosc] DEFAULT ('') NOT NULL,
    [OfL_Atr3_DeAId]             INT             NULL,
    [OfL_Atr3_Kod]               VARCHAR (20)    CONSTRAINT [DF_OfL_Atr3_Kod] DEFAULT ('') NOT NULL,
    [OfL_Atr3_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_OfL_Atr3_Wartosc] DEFAULT ('') NOT NULL,
    [OfL_Atr4_DeAId]             INT             NULL,
    [OfL_Atr4_Kod]               VARCHAR (20)    CONSTRAINT [DF_OfL_Atr4_Kod] DEFAULT ('') NOT NULL,
    [OfL_Atr4_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_OfL_Atr4_Wartosc] DEFAULT ('') NOT NULL,
    [OfL_Atr5_DeAId]             INT             NULL,
    [OfL_Atr5_Kod]               VARCHAR (20)    CONSTRAINT [DF_OfL_Atr5_Kod] DEFAULT ('') NOT NULL,
    [OfL_Atr5_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_OfL_Atr5_Wartosc] DEFAULT ('') NOT NULL,
    [OfC_TwrId]                  INT             NULL,
    [OfC_KntId]                  INT             NULL,
    [OfC_TypNB]                  TINYINT         NOT NULL,
    [OfC_Cena0]                  DECIMAL (17, 4) NOT NULL,
    [OfC_Rabat]                  DECIMAL (5, 2)  NOT NULL,
    [OfC_CenaW]                  DECIMAL (17, 4) NOT NULL,
    [OfC_Cena0WD]                DECIMAL (17, 4) NOT NULL,
    [OfC_CenaWWD]                DECIMAL (17, 4) NOT NULL,
    [OfC_KosztKGO]               DECIMAL (15, 2) CONSTRAINT [DF_OfL_KosztKGO] DEFAULT ((0)) NOT NULL,
    [OfC_Waluta]                 VARCHAR (3)     NOT NULL,
    [OfC_KursNumer]              INT             NOT NULL,
    [OfC_KursL]                  DECIMAL (15, 4) NOT NULL,
    [OfC_KursM]                  DECIMAL (5)     NOT NULL,
    [OfC_CenaT]                  DECIMAL (17, 4) NOT NULL,
    [OfC_Ilosc]                  DECIMAL (15, 4) NOT NULL,
    [OfC_Jm]                     NVARCHAR (20)   NOT NULL,
    [OfC_JmZ]                    NVARCHAR (20)   NOT NULL,
    [OfC_JmCalkowite]            TINYINT         NOT NULL,
    [OfC_JMPrzelicznikL]         DECIMAL (15, 2) NOT NULL,
    [OfC_JMPrzelicznikM]         DECIMAL (7)     NOT NULL,
    [OfC_IloscJM]                DECIMAL (15, 4) NOT NULL,
    [OfC_WartoscNetto]           DECIMAL (15, 2) NOT NULL,
    [OfC_WartoscBrutto]          DECIMAL (15, 2) NOT NULL,
    [OfC_WartoscNettoWal]        DECIMAL (15, 2) NOT NULL,
    [OfC_WartoscBruttoWal]       DECIMAL (15, 2) NOT NULL,
    [OfC_Stawka]                 DECIMAL (5, 2)  NOT NULL,
    [OfC_Flaga]                  SMALLINT        NOT NULL,
    [OFC_CenaZCzteremaMiejscami] TINYINT         CONSTRAINT [DF_OFC_ELEM_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    [OfL_AtrUtworzony]           INT             CONSTRAINT [DF_OfL_AtrUtworzony] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [OfL_Primary] PRIMARY KEY CLUSTERED ([OfL_OfLId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OfLOfertyDok] FOREIGN KEY ([OfL_OfDId]) REFERENCES [CDN].[OfertyDok] ([OfD_OfDId]) ON DELETE CASCADE
);


GO
CREATE TRIGGER CDN.OfertyElem_Insert_Trigger
  ON CDN.OfertyElem
  FOR Insert
AS
  SET NOCOUNT ON
 INSERT INTO CDN.TraElemAtr (TrA_TrEId, TrA_Lp, TrA_DeAId, TrA_Kod, TrA_Wartosc, TrA_ESklep, TrA_DokTyp, TrA_DokId)
  select 0, Twa_Lp ,TwA_DeAID, DeA_Kod, TwA_Wartosctxt, 0, 801, OfL_OfLId FROM INSERTED
  INNER JOIN CDN.TwrAtrybuty ON TwA_TwrID = OfL_TwrId
  INNER JOIN CDN.DefAtrybuty ON TwA_DeAID = DeA_DeAID
  WHERE OfL_AtrUtworzony = 0 AND TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 0
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.OfertyElem_Delete_Trigger
  ON CDN.OfertyElem
  FOR DELETE
AS
  SET NOCOUNT ON
 DELETE CDN.TraElemAtr FROM CDN.TraElemAtr JOIN deleted ON TrA_DokTyp=801 AND TrA_DokId=deleted.OfL_OfLId
  SET NOCOUNT OFF
