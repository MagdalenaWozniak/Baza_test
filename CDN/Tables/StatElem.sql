CREATE TABLE [CDN].[StatElem] (
    [StE_StEId]          INT      IDENTITY (1, 1) NOT NULL,
    [StE_LiczbaElemEksp] INT      NOT NULL,
    [StE_LiczbaElemImp]  INT      NOT NULL,
    [StE_StNId]          INT      NOT NULL,
    [StE_TypElem]        SMALLINT NOT NULL,
    CONSTRAINT [StE_Primary] PRIMARY KEY CLUSTERED ([StE_StEId] ASC) WITH (FILLFACTOR = 100)
);

