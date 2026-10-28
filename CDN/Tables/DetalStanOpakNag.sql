CREATE TABLE [CDN].[DetalStanOpakNag] (
    [DSON_DSONId]      INT           IDENTITY (1, 1) NOT NULL,
    [DSON_OptimaId]    INT           NOT NULL,
    [DSON_Nieaktywny]  TINYINT       NOT NULL,
    [DSON_Kod]         VARCHAR (20)  NOT NULL,
    [DSON_Nazwa]       NVARCHAR (50) NOT NULL,
    [DSON_StanDetalID] INT           NOT NULL,
    [DSON_TS_Mod]      DATETIME      NOT NULL,
    CONSTRAINT [DSON_Primary] PRIMARY KEY CLUSTERED ([DSON_DSONId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSONKod]
    ON [CDN].[DetalStanOpakNag]([DSON_Kod] ASC, [DSON_StanDetalID] ASC) WITH (FILLFACTOR = 100);

