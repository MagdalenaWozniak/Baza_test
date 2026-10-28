CREATE TABLE [CDN].[PozDeklZUS] (
    [PDZ_PdzId]            INT            IDENTITY (1, 1) NOT NULL,
    [PDZ_Kod]              VARCHAR (254)  NOT NULL,
    [PDZ_Rodzaj]           TINYINT        NOT NULL,
    [PDZ_Poziom]           INT            NOT NULL,
    [PDZ_Wybieralny]       INT            NOT NULL,
    [PDZ_Opis]             NVARCHAR (254) NOT NULL,
    [PDZ_KodNieobecnosci]  TINYINT        NOT NULL,
    [PDZ_Zwolnienie]       TINYINT        NOT NULL,
    [PDZ_KategoriaZUS]     TINYINT        NOT NULL,
    [PDZ_UbezpChor]        TINYINT        NOT NULL,
    [PDZ_UbezpWypad]       TINYINT        NOT NULL,
    [PDZ_TypRSA]           TINYINT        NOT NULL,
    [PDZ_RSAWedlugOkresDo] TINYINT        NOT NULL,
    [PDZ_ZjeId]            NVARCHAR (128) CONSTRAINT [DF_PDZ_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [PDZ_Primary] PRIMARY KEY CLUSTERED ([PDZ_PdzId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [PDZZjeLink]
    ON [CDN].[PozDeklZUS]([PDZ_ZjeId] ASC) WITH (FILLFACTOR = 100);

