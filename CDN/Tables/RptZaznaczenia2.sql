CREATE TABLE [CDN].[RptZaznaczenia2] (
    [RpZ2_GUID]     VARCHAR (50) NOT NULL,
    [RpZ2_RekordLp] INT          NOT NULL,
    [RpZ2_GIDTyp]   SMALLINT     NULL,
    [RpZ2_GIDFirma] INT          NULL,
    [RpZ2_GIDNumer] INT          NULL,
    [RpZ2_GIDLp]    SMALLINT     NULL,
    [RpZ2_KopiaLp]  SMALLINT     NOT NULL,
    CONSTRAINT [RpZ2_Primary] PRIMARY KEY CLUSTERED ([RpZ2_GUID] ASC, [RpZ2_RekordLp] ASC, [RpZ2_KopiaLp] ASC) WITH (FILLFACTOR = 100)
);

