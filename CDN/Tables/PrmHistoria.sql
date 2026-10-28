CREATE TABLE [CDN].[PrmHistoria] (
    [PrH_ID]             VARCHAR (20)    NULL,
    [PrH_GIDTyp]         SMALLINT        NOT NULL,
    [PrH_GIDFirma]       INT             NULL,
    [PrH_GIDNumer]       INT             NOT NULL,
    [PrH_GIDLp]          SMALLINT        NOT NULL,
    [PrH_IDPrm]          INT             NOT NULL,
    [PrH_RabatKwota]     DECIMAL (12, 2) NULL,
    [PrH_RodzajRabatu]   SMALLINT        NULL,
    [PrH_RabatProcent]   DECIMAL (12, 6) NULL,
    [PrH_RabatKwotaDokl] DECIMAL (16, 6) NULL,
    [PrH_RabatEfektywny] DECIMAL (12, 2) NULL,
    [PrH_TrEId]          INT             NOT NULL,
    CONSTRAINT [PrH_Primary] PRIMARY KEY CLUSTERED ([PrH_TrEId] ASC, [PrH_GIDTyp] ASC, [PrH_GIDNumer] ASC, [PrH_GIDLp] ASC, [PrH_IDPrm] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON),
    CONSTRAINT [FK_PrHPrimary] FOREIGN KEY ([PrH_TrEId]) REFERENCES [CDN].[TraElem] ([TrE_TrEID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PrHPrm]
    ON [CDN].[PrmHistoria]([PrH_IDPrm] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);

