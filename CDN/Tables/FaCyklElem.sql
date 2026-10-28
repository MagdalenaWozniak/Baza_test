CREATE TABLE [CDN].[FaCyklElem] (
    [FCE_FcEID]                  INT             IDENTITY (1, 1) NOT NULL,
    [FCE_FcNID]                  INT             NOT NULL,
    [FCE_TypNB]                  TINYINT         NULL,
    [FCE_Lp]                     INT             NOT NULL,
    [FCE_TwrID]                  INT             NULL,
    [FCE_Kod]                    VARCHAR (50)    NOT NULL,
    [FCE_Nazwa]                  NVARCHAR (255)  NOT NULL,
    [FCE_IloscTyp]               TINYINT         NULL,
    [FCE_Ilosc]                  DECIMAL (15, 4) NULL,
    [FCE_JM]                     NVARCHAR (20)   NULL,
    [FCE_CenaTyp]                TINYINT         NULL,
    [FCE_Cena]                   DECIMAL (17, 4) NULL,
    [FCE_CenaBrutto]             DECIMAL (17, 4) NULL,
    [FCE_GrupaCenowa]            SMALLINT        CONSTRAINT [DF_FCE_GrupaCenowa] DEFAULT ((0)) NOT NULL,
    [FCE_Waluta]                 VARCHAR (3)     CONSTRAINT [DF_FCE_Waluta] DEFAULT ('') NOT NULL,
    [FCE_CenaNettoPLN]           DECIMAL (17, 4) CONSTRAINT [DF_FCE_CenaNettoPLN] DEFAULT ((0)) NOT NULL,
    [FCE_CenaBruttoPLN]          DECIMAL (17, 4) CONSTRAINT [DF_FCE_CenaBruttoPLN] DEFAULT ((0)) NOT NULL,
    [FCE_CenaZCzteremaMiejscami] TINYINT         CONSTRAINT [DF_FCE_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    [FCE_IloscJM]                DECIMAL (15, 4) NULL,
    [FCE_JMZ]                    NVARCHAR (20)   NULL,
    [FCE_JMPrzelicznikL]         DECIMAL (15, 2) CONSTRAINT [DF_FCE_JMPrzelicznikL] DEFAULT ((1)) NOT NULL,
    [FCE_JMPrzelicznikM]         INT             CONSTRAINT [DF_FCE_JMPrzelicznikM] DEFAULT ((1)) NOT NULL,
    [FCE_MagId]                  INT             NULL,
    [FCE_CloneId]                INT             NULL,
    CONSTRAINT [FCE_Primary] PRIMARY KEY CLUSTERED ([FCE_FcEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_FcENaglowek] FOREIGN KEY ([FCE_FcNID]) REFERENCES [CDN].[FaCyklNag] ([FCN_FcNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FcENaglowek]
    ON [CDN].[FaCyklElem]([FCE_FcNID] ASC, [FCE_FcEID] ASC, [FCE_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [FcELp]
    ON [CDN].[FaCyklElem]([FCE_FcEID] ASC, [FCE_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.FaCyklElem_Delete_Trigger
  ON CDN.FaCyklElem
  FOR DELETE
AS
  SET NOCOUNT ON
  -- wykasuj dane o ilościach i cenach dla kontrahentów: TFS: 143940
  DELETE FROM cdn.FaCyklTwrKnt WHERE FCT_FcEId IN (SELECT FcE_FcEId FROM deleted)
  SET NOCOUNT OFF
