CREATE TABLE [CDN].[DetalKntOsoby] (
    [DKnO_DKnOId]      INT           IDENTITY (1, 1) NOT NULL,
    [DKnO_OptimaId]    INT           NOT NULL,
    [DKnO_DSKnOId]     INT           NOT NULL,
    [DKnO_DSKntId]     INT           NOT NULL,
    [DKnO_StanDetalID] INT           NOT NULL,
    [DKnO_Telefon]     VARCHAR (20)  NOT NULL,
    [DKnO_GSM]         VARCHAR (20)  NOT NULL,
    [DKnO_Informacje]  TINYINT       NOT NULL,
    [DKnO_Email]       NVARCHAR (60) NOT NULL,
    [DKnO_Nazwisko]    NVARCHAR (40) NOT NULL,
    CONSTRAINT [DKnO_Primary] PRIMARY KEY CLUSTERED ([DKnO_DKnOId] ASC) WITH (FILLFACTOR = 100)
);

