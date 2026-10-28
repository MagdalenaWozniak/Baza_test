CREATE TABLE [CDN].[RejestrOperacjiTypyOperacji] (
    [ROPTOp_Typ]   INT            NOT NULL,
    [ROPTOp_Nazwa] NVARCHAR (100) NOT NULL,
    [ROPTOp_Jezyk] INT            CONSTRAINT [DF_ROPTOp_Jezyk] DEFAULT ((1045)) NOT NULL,
    CONSTRAINT [ROPTOp_Primary] PRIMARY KEY CLUSTERED ([ROPTOp_Typ] ASC, [ROPTOp_Jezyk] ASC) WITH (FILLFACTOR = 100)
);

