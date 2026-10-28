CREATE TABLE [CDN].[SrsCyklElem] (
    [SrE_SrEId]                  INT             IDENTITY (1, 1) NOT NULL,
    [SrE_SrWId]                  INT             NOT NULL,
    [SrE_Typ]                    INT             NOT NULL,
    [SrE_Lp]                     INT             NOT NULL,
    [SrE_TwrId]                  INT             NULL,
    [SrE_KatID]                  INT             NULL,
    [SrE_TwrKod]                 NVARCHAR (50)   NOT NULL,
    [SrE_TwrNazwa]               NVARCHAR (255)  NOT NULL,
    [SrE_Opis]                   NVARCHAR (1024) NOT NULL,
    [SrE_Fakturowac]             TINYINT         NOT NULL,
    [SrE_TypCeny]                TINYINT         NOT NULL,
    [SrE_CenaNetto]              DECIMAL (17, 4) NOT NULL,
    [SrE_CenaBrutto]             DECIMAL (17, 4) NOT NULL,
    [SrE_Ilosc]                  DECIMAL (15, 4) NOT NULL,
    [SrE_IloscJM]                DECIMAL (15, 4) NOT NULL,
    [SrE_JM]                     NVARCHAR (20)   NOT NULL,
    [SrE_JMZ]                    NVARCHAR (20)   NOT NULL,
    [SrE_JMPrzelicznikL]         DECIMAL (15, 2) NOT NULL,
    [SrE_JMPrzelicznikM]         INT             NOT NULL,
    [SrE_WartoscNetto]           DECIMAL (15, 2) NOT NULL,
    [SrE_WartoscBrutto]          DECIMAL (15, 2) NOT NULL,
    [SrE_Atr1_DeAId]             INT             NULL,
    [SrE_Atr1_Kod]               VARCHAR (20)    CONSTRAINT [DF_SrE_Atr1_Kod] DEFAULT ('') NOT NULL,
    [SrE_Atr1_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_SrE_Atr1_Wartosc] DEFAULT ('') NOT NULL,
    [SrE_Atr2_DeAId]             INT             NULL,
    [SrE_Atr2_Kod]               VARCHAR (20)    CONSTRAINT [DF_SrE_Atr2_Kod] DEFAULT ('') NOT NULL,
    [SrE_Atr2_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_SrE_Atr2_Wartosc] DEFAULT ('') NOT NULL,
    [SrE_Atr3_DeAId]             INT             NULL,
    [SrE_Atr3_Kod]               VARCHAR (20)    CONSTRAINT [DF_SrE_Atr3_Kod] DEFAULT ('') NOT NULL,
    [SrE_Atr3_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_SrE_Atr3_Wartosc] DEFAULT ('') NOT NULL,
    [SrE_Atr4_DeAId]             INT             NULL,
    [SrE_Atr4_Kod]               VARCHAR (20)    CONSTRAINT [DF_SrE_Atr4_Kod] DEFAULT ('') NOT NULL,
    [SrE_Atr4_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_SrE_Atr4_Wartosc] DEFAULT ('') NOT NULL,
    [SrE_Atr5_DeAId]             INT             NULL,
    [SrE_Atr5_Kod]               VARCHAR (20)    CONSTRAINT [DF_SrE_Atr5_Kod] DEFAULT ('') NOT NULL,
    [SrE_Atr5_Wartosc]           NVARCHAR (100)  CONSTRAINT [DF_SrE_Atr5_Wartosc] DEFAULT ('') NOT NULL,
    [SrE_SerwisantTyp]           INT             NULL,
    [SrE_SerwisantId]            INT             NULL,
    [SrE_MagId]                  INT             NULL,
    [SrE_TwrEan]                 VARCHAR (40)    CONSTRAINT [DF_SrE_TwrEan] DEFAULT ('') NOT NULL,
    [SrE_CenaZCzteremaMiejscami] TINYINT         CONSTRAINT [DF_SrE_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    [SrE_UstawAtrSQL]            INT             CONSTRAINT [DF_SrE_UstawAtrSQL] DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [SrE_Primary] PRIMARY KEY CLUSTERED ([SrE_SrEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrEKategoria] FOREIGN KEY ([SrE_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_SrEZlecenia] FOREIGN KEY ([SrE_SrWId]) REFERENCES [CDN].[SrsCyklNag] ([SrW_SrWId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrEZlecenia]
    ON [CDN].[SrsCyklElem]([SrE_SrWId] ASC, [SrE_Typ] ASC, [SrE_Lp] ASC, [SrE_SrEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrEUsluga]
    ON [CDN].[SrsCyklElem]([SrE_TwrId] ASC, [SrE_SrEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrEKategoria]
    ON [CDN].[SrsCyklElem]([SrE_KatID] ASC, [SrE_SrEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrETwrKod]
    ON [CDN].[SrsCyklElem]([SrE_SrWId] ASC, [SrE_TwrKod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.SrsCyklElem_Delete_Trigger ON cdn.SrsCyklElem FOR DELETE
AS
  SET NOCOUNT ON
  -- usuwanie atrybutów powiazanych z pozycja zlecenia cyklicznego
  IF EXISTS ( SELECT * FROM deleted )
  BEGIN
    DELETE FROM cdn.TraElemAtr WHERE (TrA_TrEId IS NULL OR TrA_TrEId=0) AND TrA_DokTyp=907 AND TrA_DokId IN (SELECT SrE_SrEId FROM deleted)
  END
  SET NOCOUNT OFF
