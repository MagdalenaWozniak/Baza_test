CREATE TABLE [CDN].[FaCyklTwrKnt] (
    [FCT_FcTID]                  INT             IDENTITY (1, 1) NOT NULL,
    [FCT_TypKnt]                 TINYINT         NOT NULL,
    [FCT_Ilosc]                  DECIMAL (15, 4) NOT NULL,
    [FCT_TypNB]                  TINYINT         NULL,
    [FCT_Cena]                   DECIMAL (17, 4) NOT NULL,
    [FCT_CenaBrutto]             DECIMAL (17, 4) NULL,
    [FCT_KntLp]                  INT             NOT NULL,
    [FCT_Waluta]                 VARCHAR (3)     CONSTRAINT [DF_FCT_Waluta] DEFAULT ('') NOT NULL,
    [FCT_CenaNettoPLN]           DECIMAL (17, 4) CONSTRAINT [DF_FCT_CenaNettoPLN] DEFAULT ((0)) NOT NULL,
    [FCT_CenaBruttoPLN]          DECIMAL (17, 4) CONSTRAINT [DF_FCT_CenaBruttoPLN] DEFAULT ((0)) NOT NULL,
    [FCT_CenaZCzteremaMiejscami] TINYINT         CONSTRAINT [DF_FCT_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    [FCT_FcEID]                  INT             CONSTRAINT [DF_FCT_FcEId] DEFAULT ((0)) NOT NULL,
    [FCT_FcKID]                  INT             CONSTRAINT [DF_FCT_FcKId] DEFAULT ((0)) NOT NULL,
    [FCT_JM]                     NVARCHAR (20)   NULL,
    [FCT_NabywcaKod]             VARCHAR (20)    NULL,
    [FCT_NabywcaNazwa]           NVARCHAR (352)  NULL,
    [FCT_OdbiorcaKod]            VARCHAR (20)    NULL,
    [FCT_OdbiorcaNazwa]          NVARCHAR (352)  NULL,
    [FCT_ObowiazujeOdTxt]        VARCHAR (22)    NULL,
    [FCT_ObowiazujeDoTxt]        VARCHAR (22)    NULL,
    CONSTRAINT [FCT_Primary] PRIMARY KEY CLUSTERED ([FCT_FcTID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_FCT_FaCyklElem] FOREIGN KEY ([FCT_FcEID]) REFERENCES [CDN].[FaCyklElem] ([FCE_FcEID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [FcTPozycjaElem]
    ON [CDN].[FaCyklTwrKnt]([FCT_FcEID] ASC, [FCT_TypKnt] ASC, [FCT_KntLp] ASC) WITH (FILLFACTOR = 100);

