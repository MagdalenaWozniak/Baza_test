CREATE TABLE [CDN].[TraFakZaliczkowe] (
    [TrZ_TrZID]             INT             IDENTITY (1, 1) NOT NULL,
    [TrZ_TrNID]             INT             NOT NULL,
    [TrZ_FZID]              INT             NOT NULL,
    [TrZ_Stawka]            DECIMAL (5, 2)  NOT NULL,
    [TrZ_Flaga]             SMALLINT        NOT NULL,
    [TrZ_Zrodlowa]          DECIMAL (5, 2)  NOT NULL,
    [TrZ_KwotaBrutto]       DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaBruttoSys]    DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaBruttoMax]    DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaBruttoSysMax] DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaNetto]        DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaNettoSys]     DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaNettoMax]     DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaNettoSysMax]  DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaVAT]          DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaVATSys]       DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaVATMax]       DECIMAL (15, 2) NOT NULL,
    [TrZ_KwotaVATSysMax]    DECIMAL (15, 2) NOT NULL,
    [TrZ_Typ]               TINYINT         NOT NULL,
    [TrZ_Waluta]            VARCHAR (3)     NOT NULL,
    [TrZ_NumerPelny]        VARCHAR (30)    NOT NULL,
    [TrZ_Uwzgledniac]       TINYINT         NOT NULL,
    CONSTRAINT [TrZ_Primary] PRIMARY KEY CLUSTERED ([TrZ_TrZID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_FakZalTraNag] FOREIGN KEY ([TrZ_TrNID]) REFERENCES [CDN].[TraNag] ([TrN_TrNID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [FakZalTraNag]
    ON [CDN].[TraFakZaliczkowe]([TrZ_TrNID] ASC) WITH (FILLFACTOR = 100);

