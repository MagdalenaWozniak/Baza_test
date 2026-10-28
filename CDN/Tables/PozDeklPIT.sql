CREATE TABLE [CDN].[PozDeklPIT] (
    [PDP_PdpId]      INT            IDENTITY (1, 1) NOT NULL,
    [PDP_Kod]        VARCHAR (254)  NOT NULL,
    [PDP_Rodzaj]     TINYINT        NOT NULL,
    [PDP_Poziom]     INT            NOT NULL,
    [PDP_Wybieralny] INT            NOT NULL,
    [PDP_Opis]       NVARCHAR (254) NOT NULL,
    [PDP_PIT4]       INT            NOT NULL,
    [PDP_PIT11]      INT            NOT NULL,
    [PDP_PIT8A]      INT            NOT NULL,
    [PDP_PIT8B]      INT            NOT NULL,
    [PDP_PIT40]      INT            NOT NULL,
    [PDP_IFT1]       INT            NOT NULL,
    [PDP_PIT8C]      INT            NOT NULL,
    [PDP_Filtr]      TINYINT        NOT NULL,
    [PDP_PITR]       INT            CONSTRAINT [DF_PDP_PITR] DEFAULT ((0)) NOT NULL,
    [PDP_ZjeId]      NVARCHAR (128) CONSTRAINT [DF_PDP_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [PDP_Primary] PRIMARY KEY CLUSTERED ([PDP_PdpId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [PDPZjeLink]
    ON [CDN].[PozDeklPIT]([PDP_ZjeId] ASC) WITH (FILLFACTOR = 100);

