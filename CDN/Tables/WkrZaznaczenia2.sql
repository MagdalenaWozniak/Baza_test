CREATE TABLE [CDN].[WkrZaznaczenia2] (
    [WkZ2_GUID]     VARCHAR (50) NOT NULL,
    [WkZ2_RekordLp] INT          NOT NULL,
    [WkZ2_GIDTyp]   SMALLINT     NULL,
    [WkZ2_GIDFirma] INT          NULL,
    [WkZ2_GIDNumer] INT          NULL,
    [WkZ2_GIDLp]    SMALLINT     NULL,
    CONSTRAINT [WkZ2_Primary] PRIMARY KEY CLUSTERED ([WkZ2_GUID] ASC, [WkZ2_RekordLp] ASC) WITH (FILLFACTOR = 100)
);

