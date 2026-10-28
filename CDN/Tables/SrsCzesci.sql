CREATE TABLE [CDN].[SrsCzesci] (
    [SrC_SrCId]                  INT              IDENTITY (1, 1) NOT NULL,
    [SrC_SrZId]                  INT              NOT NULL,
    [SrC_Lp]                     INT              NOT NULL,
    [SrC_TwrId]                  INT              NULL,
    [SrC_KatID]                  INT              NULL,
    [SrC_MmTreID]                INT              NULL,
    [SrC_MmZwrot]                INT              NOT NULL,
    [SrC_TwrKod]                 NVARCHAR (50)    NOT NULL,
    [SrC_TwrNazwa]               NVARCHAR (255)   NOT NULL,
    [SrC_Opis]                   NVARCHAR (1024)  NOT NULL,
    [SrC_SerwisantTyp]           INT              NOT NULL,
    [SrC_SerwisantId]            INT              NOT NULL,
    [SrC_MagId]                  INT              NULL,
    [SrC_Status]                 TINYINT          NOT NULL,
    [SrC_Dokument]               INT              NOT NULL,
    [SrC_Fakturowac]             TINYINT          NOT NULL,
    [SrC_TwCNumer]               INT              NOT NULL,
    [SrC_Cena0]                  DECIMAL (17, 4)  NOT NULL,
    [SrC_Rabat]                  DECIMAL (5, 2)   NOT NULL,
    [SrC_CenaNetto]              DECIMAL (17, 4)  NOT NULL,
    [SrC_CenaBrutto]             DECIMAL (17, 4)  NOT NULL,
    [SrC_IloscPobierana]         DECIMAL (15, 4)  NOT NULL,
    [SrC_IloscPobieranaJM]       DECIMAL (15, 4)  NOT NULL,
    [SrC_Ilosc]                  DECIMAL (15, 4)  NOT NULL,
    [SrC_IloscJM]                DECIMAL (15, 4)  NOT NULL,
    [SrC_JM]                     NVARCHAR (20)    NOT NULL,
    [SrC_JMZ]                    NVARCHAR (20)    NOT NULL,
    [SrC_JMPrzelicznikL]         DECIMAL (15, 2)  NOT NULL,
    [SrC_JMPrzelicznikM]         INT              NOT NULL,
    [SrC_WartoscNetto]           DECIMAL (15, 2)  NOT NULL,
    [SrC_WartoscBrutto]          DECIMAL (15, 2)  NOT NULL,
    [SrC_WartoscNettoWylicz]     DECIMAL (19, 6)  NOT NULL,
    [SrC_WartoscBruttoWylicz]    DECIMAL (19, 6)  NOT NULL,
    [SrC_WartoscZakupuWylicz]    DECIMAL (15, 2)  NOT NULL,
    [SrC_Cena0PLN]               DECIMAL (19, 6)  CONSTRAINT [DF_SrC_Cena0PLN] DEFAULT ((0)) NOT NULL,
    [SrC_CenaNettoPLN]           DECIMAL (19, 6)  CONSTRAINT [DF_SrC_CenaNettoPLN] DEFAULT ((0)) NOT NULL,
    [SrC_CenaBruttoPLN]          DECIMAL (19, 6)  CONSTRAINT [DF_SrC_CenaBruttoPLN] DEFAULT ((0)) NOT NULL,
    [SrC_WartoscNettoPLN]        DECIMAL (23, 10) CONSTRAINT [DF_SrC_WartoscNettoPLN] DEFAULT ((0)) NOT NULL,
    [SrC_WartoscBruttoPLN]       DECIMAL (23, 10) CONSTRAINT [DF_SrC_WartoscBruttoPLN] DEFAULT ((0)) NOT NULL,
    [SrC_Waluta]                 VARCHAR (3)      CONSTRAINT [DF_SrC_Waluta] DEFAULT ('') NOT NULL,
    [SrC_Stawka]                 DECIMAL (5, 2)   CONSTRAINT [DF_SrC_Stawka] DEFAULT ((0)) NOT NULL,
    [SrC_Atr1_DeAId]             INT              NULL,
    [SrC_Atr1_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrC_Atr1_Kod] DEFAULT ('') NOT NULL,
    [SrC_Atr1_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrC_Atr1_Wartosc] DEFAULT ('') NOT NULL,
    [SrC_Atr2_DeAId]             INT              NULL,
    [SrC_Atr2_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrC_Atr2_Kod] DEFAULT ('') NOT NULL,
    [SrC_Atr2_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrC_Atr2_Wartosc] DEFAULT ('') NOT NULL,
    [SrC_Atr3_DeAId]             INT              NULL,
    [SrC_Atr3_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrC_Atr3_Kod] DEFAULT ('') NOT NULL,
    [SrC_Atr3_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrC_Atr3_Wartosc] DEFAULT ('') NOT NULL,
    [SrC_Atr4_DeAId]             INT              NULL,
    [SrC_Atr4_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrC_Atr4_Kod] DEFAULT ('') NOT NULL,
    [SrC_Atr4_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrC_Atr4_Wartosc] DEFAULT ('') NOT NULL,
    [SrC_Atr5_DeAId]             INT              NULL,
    [SrC_Atr5_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrC_Atr5_Kod] DEFAULT ('') NOT NULL,
    [SrC_Atr5_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrC_Atr5_Wartosc] DEFAULT ('') NOT NULL,
    [SrC_FlagaVat]               SMALLINT         CONSTRAINT [DF_SrC_FlagaVat] DEFAULT ((2)) NOT NULL,
    [SrC_Zrodlowa]               DECIMAL (5, 2)   CONSTRAINT [DF_SrC_Zrodlowa] DEFAULT ((0)) NOT NULL,
    [SrC_TwrEan]                 VARCHAR (40)     CONSTRAINT [DF_SrC_TwrEan] DEFAULT ('') NOT NULL,
    [SrC_CenaZCzteremaMiejscami] TINYINT          CONSTRAINT [DF_SrC_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    [SrC_WartoscZakupu]          AS               ([CDN].[FNSRC_WARTOSCZAKUPU]([SRC_SRCID])),
    [SrC_UstawAtrSQL]            INT              CONSTRAINT [DF_SrC_UstawAtrSQL] DEFAULT ((-1)) NOT NULL,
    [SrC_IloscPobieranaDisp]     DECIMAL (15, 4)  CONSTRAINT [DF_SrC_IloscPobieranaDisp] DEFAULT ((0)) NOT NULL,
    [SrC_IloscDoPobraniaDisp]    DECIMAL (15, 4)  CONSTRAINT [DF_SrC_IloscDoPobraniaDisp] DEFAULT ((0)) NOT NULL,
    [SrC_IloscWydanaDisp]        DECIMAL (15, 4)  CONSTRAINT [DF_SrC_IloscWydanaDisp] DEFAULT ((0)) NOT NULL,
    [SrC_IloscDoWydaniaDisp]     DECIMAL (15, 4)  CONSTRAINT [DF_SrC_IloscDoWydaniaDisp] DEFAULT ((0)) NOT NULL,
    [SrC_MmZwrotDisp]            DECIMAL (15, 4)  CONSTRAINT [DF_SrC_MmZwrotDisp] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [SrC_Primary] PRIMARY KEY CLUSTERED ([SrC_SrCId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrcKategoria] FOREIGN KEY ([SrC_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_SrCZlecenia] FOREIGN KEY ([SrC_SrZId]) REFERENCES [CDN].[SrsZlecenia] ([SrZ_SrZId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrCZlecenia]
    ON [CDN].[SrsCzesci]([SrC_SrZId] ASC, [SrC_Lp] ASC, [SrC_SrCId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrCUsluga]
    ON [CDN].[SrsCzesci]([SrC_TwrId] ASC, [SrC_SrCId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrcKategoria]
    ON [CDN].[SrsCzesci]([SrC_KatID] ASC, [SrC_SrCId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrCTwrKod]
    ON [CDN].[SrsCzesci]([SrC_SrZId] ASC, [SrC_TwrKod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.SrsCzesci_Delete_Trigger ON cdn.SrsCzesci FOR DELETE
AS
  SET NOCOUNT ON
  -- usuwanie atrybutów powiązanych z częściami zlecenia serwisowego
  IF EXISTS ( SELECT * FROM deleted )
  BEGIN
    DELETE FROM cdn.TraElemAtr WHERE (TrA_TrEId IS NULL OR TrA_TrEId=0) AND TrA_DokTyp=902 AND TrA_DokId IN (SELECT SrC_SrCId FROM deleted)
  END
  SET NOCOUNT OFF
