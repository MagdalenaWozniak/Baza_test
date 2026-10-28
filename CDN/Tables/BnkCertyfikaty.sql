CREATE TABLE [CDN].[BnkCertyfikaty] (
    [BnC_BnCID]       INT            IDENTITY (1, 1) NOT NULL,
    [BnC_BNaID]       INT            NOT NULL,
    [BnC_OpeID]       INT            NULL,
    [BnC_Nazwa]       NVARCHAR (256) NOT NULL,
    [BnC_Thumbprint]  NVARCHAR (256) NULL,
    [BnC_TypOperacji] INT            CONSTRAINT [DF_BnC_TypOperacji] DEFAULT ((0)) NOT NULL,
    [BnC_Content]     NVARCHAR (MAX) NULL,
    CONSTRAINT [BnC_Primary] PRIMARY KEY CLUSTERED ([BnC_BnCID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BnCBank] FOREIGN KEY ([BnC_BNaID]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BnCBankOpe]
    ON [CDN].[BnkCertyfikaty]([BnC_BNaID] ASC, [BnC_OpeID] ASC, [BnC_TypOperacji] ASC) WITH (FILLFACTOR = 100);

