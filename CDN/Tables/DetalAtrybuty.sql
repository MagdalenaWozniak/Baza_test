CREATE TABLE [CDN].[DetalAtrybuty] (
    [DAtr_DAtrId]      INT            IDENTITY (1, 1) NOT NULL,
    [DAtr_OptimaId]    INT            NOT NULL,
    [DAtr_StanDetalID] INT            NOT NULL,
    [DAtr_DSAtrId]     INT            NOT NULL,
    [DAtr_objectType]  INT            NOT NULL,
    [DAtr_objectId]    INT            NOT NULL,
    [DAtr_classId]     INT            NOT NULL,
    [DAtr_valueId]     INT            NOT NULL,
    [DAtr_value]       NVARCHAR (MAX) NOT NULL,
    [DAtr_format]      NVARCHAR (10)  NOT NULL,
    [DAtr_valueType]   INT            NOT NULL,
    CONSTRAINT [DAtr_Primary] PRIMARY KEY CLUSTERED ([DAtr_DAtrId] ASC) WITH (FILLFACTOR = 100)
);

