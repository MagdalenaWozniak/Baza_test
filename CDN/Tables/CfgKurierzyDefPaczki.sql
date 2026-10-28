CREATE TABLE [CDN].[CfgKurierzyDefPaczki] (
    [CKP_CKPID]              INT             IDENTITY (1, 1) NOT NULL,
    [CKP_CKKID]              INT             NOT NULL,
    [CKP_Waga]               DECIMAL (15, 2) NOT NULL,
    [CKP_Wysokosc]           DECIMAL (15, 2) NOT NULL,
    [CKP_Szerokosc]          DECIMAL (15, 2) NOT NULL,
    [CKP_Dlugosc]            DECIMAL (15, 2) NOT NULL,
    [CKP_SposobPakowania]    NVARCHAR (254)  NOT NULL,
    [CKP_SposobPakowaniaKey] NVARCHAR (254)  NOT NULL,
    [CKP_Gabaryt]            INT             CONSTRAINT [DF_CKP_Gabaryt] DEFAULT ((0)) NOT NULL,
    [CKP_Ostroznie]          INT             CONSTRAINT [DF_CKP_Ostroznie] DEFAULT ((0)) NOT NULL,
    [CKP_Niestandardowa]     INT             CONSTRAINT [DF_CKP_Niestandardowa] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [CKP_Primary] PRIMARY KEY CLUSTERED ([CKP_CKPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CKPCKKID] FOREIGN KEY ([CKP_CKKID]) REFERENCES [CDN].[CfgKurierzy] ([CKK_CKKID]) ON DELETE CASCADE
);

